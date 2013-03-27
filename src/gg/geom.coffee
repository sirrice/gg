#<< gg/wf/node



# transforms data -> pixel/aesthetic values
class gg.GeomTransform extends gg.XForm
  constructor: (@layer, @spec) ->
    super @layer.g, @spec
    @parseSpec()


  compute: (table, env) ->
    info = @paneInfo table, env
    scalesSet = @g.scales.scales(info.facetX, info.facetY, info.layer)
    table = table.clone()
    _.each scalesSet.aesthetics(), (aes) =>
      f = (v) -> scalesSet.scale(aes).scale(v)
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
#     geom: STRING,
#     (aes|aesthetic|mapping): aesmapping,
#     (stat|stats|statistic): xformspec
#     pos: posspec
#   }
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
      aesSpec = findGood [@spec['post-stats'], @spec['pre-geom'], null]
      posSpec = findGood [@spec.pos, @spec.position, "identity"]

      @mapping = new gg.Mapper @g, @spec if aesSpec?
      @position = gg.Position.fromSpec @layer, @spec.pos
      @render = gg.GeomRender.fromSpec @layer, @spec.geom
      @transformDomain = new gg.GeomTransform @layer, {name: "topixel"}
      console.log @render

    mappingXForm: -> if @mapping? then @mapping.compile() else []
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
        _.each klasses, (klass) -> ret[klass.name] = klass
        ret

    @fromSpec: (layer, spec) ->
        klasses = gg.Geom.klasses()
        if _.isString spec
          type = spec
          spec = { geom: type }
        else
          type = findGood [spec.geom, spec.type,  "point"]


        klass = findGood [klasses[type], gg.Point]
        spec["name"] = klass.name unless spec["name"]?
        geom = new klass(layer, spec)
        geom


# x,y,r,x0,x1,y0,y1, ...
class gg.Point extends gg.Geom
    @name: "point"

    defaults: ->
      r: 2

    inputSchema: ->
      ['x', 'y']

    mappingXForm: ->
      (new gg.Mapper @g,
        name: "point-mapper"
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
    @name: "line"



class gg.Step extends gg.Geom
    @name: "step"

class gg.Path extends gg.Geom
    @name: "path"

class gg.Area extends gg.Geom
    @name: "area"

class gg.Interval extends gg.Geom
    @name: "interval"

class gg.Rect extends gg.Geom
    @name: "rect"

class gg.Polygon extends gg.Geom
    @name: "polygon"

class gg.Hex extends gg.Geom
    @name: "hex"

# boxplot
class gg.Schema extends gg.Geom
    @name: "schema"

class gg.Glyph extends gg.Geom
    @name: "glyph"

class gg.Edge extends gg.Geom
    @name: "edge"
