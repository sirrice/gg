#<< gg/wf/node
#<< gg/position



# transforms data -> pixel/aesthetic values
class gg.GeomTransform extends gg.XForm
  constructor: (@layer, @spec) ->
    super @layer.g, @spec
    @parseSpec()


  compute: (table, env) ->
    info = @paneInfo table, env
    scalesSet = @scales table, env
    table = table.clone()

    console.log "topixel:aesthetics: #{scalesSet.aesthetics()}"
    _.each scalesSet.aesthetics(), (aes) =>
      scale = scalesSet.scale aes
      f = (v) -> scale.scale(v)
      console.log "topixel: #{aes} scale is (#{scale.domain()}) -> (#{scale.range()})"
      table.map f, aes if table.contains aes
    table






# Geoms are a holding house for tree types of XForms
#
# 1) Schema Mapping -- from stats outputs to geometry-expected schemas
# 2) apply scales -- actually transforming from data domain to pixel range
# 3) Positioning
# 4) Rendering
#
# Each of these XForms are defined elsewhere. A Geom class defines a
# preset series of XForms, which are accessible via @nodes()
#
# router for instantiating specific geometries
#
#
# Spec has following grammar:
#
# layershorthand:
#   {
#     geom: STRING | { type: STRING, (aes|map|mapping): aesmapping }
#     (aes|aesthetic|mapping): aesmapping,
#     (stat|stats|statistic): xformspec
#     pos: posspec
#   }
#
#
# spec.geom.aes maps the output of the stats xforms into
#               something the geometries can consume
#               (e.g., picking if y should be sum or count)
# spec.geom.type specifies what high level geometry to render
# spec.aes:     the mapping to perform before statistics
#               (XXX: fold into spec.stat?)
# spec.pos:     position
#
class gg.Geom extends gg.XForm

    constructor: (@layer, @spec) ->
      super @layer.g, @spec

      @mapping = null
      @position = null
      @render = null
      @transformDomain = null
      @parseSpec()

    svg: -> @layer.svg
    scales: -> @layer.scales()

    parseSpec: ->
      geomSpec = @spec.geom
      aesSpec = null
      unless _.isString geomSpec
        geomType = geomSpec.type
        aesSpec = findGood [
          geomSpec.aes,
          geomSpec.aesthetics,
          geomSpec.map,
          geomSpec.mapping, null]
        console.log "post-stats mapping spec: #{JSON.stringify aesSpec}"
        if aesSpec?
          @mapping = new gg.Mapper @g,
            aes:aesSpec
            name:"post-stats mapping"
      else
        geomType = geomSpec
      @render = gg.GeomRender.fromSpec @layer, geomType


      posSpec = findGood [@spec.pos, @spec.position, "identity"]
      @position = gg.Position.fromSpec @layer, posSpec
      @transformDomain = new gg.GeomTransform @layer,
        name: "topixel"


    mappingXForm: ->if @mapping? then @mapping.compile() else []
    geomMappingXForm: -> []
    transformDomainXForm: -> @transformDomain.compile()
    positionXForm: -> @position.compile()
    renderXForm: -> @render.compile()
    compile: -> _.flatten [@mappingXForm(), @positionXForm(), @renderXForm()]
    name: -> @constructor.name.toLowerCase()

    @klasses: ->
        klasses = [
            gg.Point,
            gg.Line,
            gg.Step,
            gg.Path,
            gg.Area,
            gg.Interval,
            gg.Rect,
            gg.Polygon,
            gg.Hex,
            gg.Schema,
            gg.Glyph,
            gg.Edge
        ]
        ret = {}
        _.each klasses, (klass) ->
          if _.isArray klass.aliases
            _.each klass.aliases, (alias) -> ret[alias] = klass
          else
            ret[klass.aliases] = klass
        ret

    @fromSpec: (layer, spec) ->
        klasses = gg.Geom.klasses()
        geomSpec = spec.geom
        if _.isString geomSpec
          type = geomSpec
        else
          geomAttrs = ["geom", "type"]
          type = findGood geomSpec, geomAttrs, "point"
        console.log klasses
        console.log spec

        klass = findGood [klasses[type], gg.Point]
        console.log "geom klass: #{type} -> #{klass.name}"
        spec["name"] = klass.name unless spec["name"]?
        geom = new klass(layer, spec)
        geom


# x,y,r,x0,x1,y0,y1, ...
class gg.Point extends gg.Geom
    @aliases: ["point"]

    defaults: ->
      r: 2

    inputSchema: ->
      ['x', 'y']

    # called reparameterize in ggplot2
    geomMappingXForm: ->
      (new gg.Mapper @g,
        name: "point-reparam"
        defaults: @defaults()
        inputSchema: @inputSchema()
        map:
          x: 'x'
          y: 'y'
          r: 'r'
          x0: 'x'
          x1: 'x'
          y0: 'y'
          y1: 'y').compile()

    renderXForm: -> (new gg.GeomRenderPointSvg @layer, {}).compile()


class gg.Line extends gg.Geom
    @aliases: "line"



class gg.Step extends gg.Geom
    @aliases: "step"

class gg.Path extends gg.Geom
    @aliases: "path"

class gg.Area extends gg.Geom
    @aliases: "area"

# XXX: DOES NOT WORK YET!
class gg.Interval extends gg.Geom
    @aliases: ["interval", "rect"]
    defaults: -> {}

    inputSchema: ->
      ['x', 'y']

    geomMappingXForm: ->
      xform = new gg.Foo @g, { name: "interval-reparam"}
      xform.compile()

    renderXForm: -> (new gg.GeomRenderRectSvg @layer, {}).compile()

class gg.Foo extends gg.XForm
  constructor: (@g, @spec) ->
    super
    @parseSpec()

  parseSpec: ->
    super

  inputSchema: ->
    ['x', 'y']

  compute: (table, env, node) ->
    scales = @scales(table, env)
    yscale = scales.scale 'y'


    # XXX: assume xs is numerical!!
    xs = _.uniq(table.getColumn("x")).sort (a,b)->a-b
    diffs = _.map _.range(xs.length-1), (idx) ->
      xs[idx+1]-xs[idx]
    mindiff = _.min diffs or 1
    width = mindiff * 0.8


    table.transform {
        x: 'x'
        y: 'y'
        r: 'r'
        x0: (row) -> row.get('x') - width/2.0
        x1: (row) -> row.get('x') + width/2.0
        y0: (row) -> yscale.scale(Math.min(yscale.minDomain(), yscale.invert(row.get 'y')))
        y1: (row) -> yscale.scale(Math.max(yscale.minDomain(), yscale.invert(row.get 'y')))
    }, yes
    table


class gg.Rect extends gg.Geom
    @aliases: "rect"

class gg.Polygon extends gg.Geom
    @aliases: "polygon"

class gg.Hex extends gg.Geom
    @aliases: "hex"

# boxplot
class gg.Schema extends gg.Geom
    @aliases: "schema"

class gg.Glyph extends gg.Geom
    @aliases: "glyph"

class gg.Edge extends gg.Geom
    @aliases: "edge"
