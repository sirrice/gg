#<< gg/wf/node
#<< gg/position
#<< gg/geom-render
#<< gg/scales






# Geoms are a holding house for tree types of XForms (not an XForm itself):
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
# {
#   type: STRINg
#   aes: {}
#   param: {}
# }
#
# aes:    maps the output of the stats xforms into
#         something the geometries can consume
#         (e.g., picking if y should be sum or count)
# type:   specifies what high level geometry to render
#
class gg.Geom # not an XForm!! #extends gg.XForm

  constructor: (@layer, @spec) ->
    @g = @layer.g

    @render = null
    @invertScales = null
    @applyScales = null
    @map = null
    @reparam = null
    @unparam = null

    @parseSpec()

  # { type:, aes:, param:}
  parseSpec: ->
    @render = gg.GeomRender.fromSpec @layer, @spec.type
    @applyScales = new gg.ScalesApply @layer, {name: "applyScales"}
    @invertScales = new gg.ScalesInvert @layer, {name: "invertScales"}
    console.log "#####: #{JSON.stringify @spec}"
    @map = new gg.Mapper @g, @spec

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
    spec = _.clone spec

    klasses = gg.Geom.klasses()

    klass = klasses[spec.type] or gg.Point
    spec.name = klass.name unless spec.name?
    geom = new klass(layer, spec)

    console.log "geom.fromSpec\t#{JSON.stringify spec}"
    console.log "geom klass: #{spec.type} -> #{klass.name}"

    geom


# x,y,r,x0,x1,y0,y1, ...
class gg.Point extends gg.Geom
  @aliases: ["point"]

  parseSpec: ->
    super
    reparamSpec =
      name: "point-reparam"
      inputSchema: ['x', 'y']
      map:
        x: 'x'
        y: 'y'
        r: 'r'
        x0: 'x'
        x1: 'x'
        y0: 'y'
        y1: 'y'

    @reparam = new gg.Mapper @g, reparamSpec
    @render = new gg.GeomRenderPointSvg @layer, {}


class gg.Line extends gg.Geom
  @aliases: "line"

  parseSpec: ->
    super
    @reparam = new gg.ReparamLine @g, {name: "line-reparam"}
    @render = new gg.GeomRenderLineSvg @layer, {}
    @unparam = new gg.UnparamLine @g, {name: "line-unparam"}

class gg.ReparamLine extends gg.XForm
  constructor: (@g, @spec) ->
    super
    @parseSpec()

  parseSpec: -> super

  defaults: (table, env, node) ->
    #scales = @scales table, env
    #y0 = scales.scale('y').minRange()

    {
      group: '1'
    #  y0: y0
    #  y1: (row) -> row.get 'y'
    }

  inputSchema: -> ['x', 'y']

  compute: (table, env, node) ->
    scales = @scales table, env
    y0 = scales.scale('y').minRange()
    console.log "gg.ReparamLine.compute: y0 set to #{y0}"
    table.each (row) ->
      row.set('y1', row.get('y')) unless row.hasAttr('y1')
      row.set('y0', y0) unless row.hasAttr('y0')


    scales = @scales(table, env)
    _.map table.get(0), (val, key) =>
      scales.scale(key).type


    groups = table.split 'group'
    rows = _.map groups, (group) ->
      groupTable = group.table
      groupKey = group.key
      rowData =
        pts: groupTable.raw()
        group: groupKey
      rowData

    new gg.RowTable rows

class gg.UnparamLine extends gg.XForm
  constructor: (@g, @spec) ->
    super
    @parseSpec()

  inputSchema: -> ['group', 'pts']

  compute: (table, env, node) ->
    rawrow = table.get(1).flatten().raw() if table.nrows() > 1
    console.log "unparamline rawrow: #{JSON.stringify rawrow}"
    table.flatten()



class gg.Step extends gg.Geom
  @aliases: "step"

class gg.Path extends gg.Geom
  @aliases: "path"

class gg.Area extends gg.Geom
  @aliases: "area"

  parseSpec: ->
    super
    @reparam = new gg.ReparamLine @g, {name: "area-reparam"}
    @render = new gg.GeomRenderAreaSvg @layer, {}
    @unparam = new gg.UnparamLine @g, {name: "area-unparam"}


class gg.Interval extends gg.Geom
  @aliases: ["interval", "rect"]
  parseSpec: ->
    super

    @reparam = new gg.ReparamInterval @g, {name: "interval-reparam"}
    @render = new gg.GeomRenderRectSvg @layer, {}


class gg.ReparamInterval extends gg.XForm
  constructor: (@g, @spec) ->
    super
    @parseSpec()

  parseSpec: ->
    super

  inputSchema: ->
    ['x', 'y']

  compute: (table, env, node) ->
    scales = @scales table, env
    yscale = scales.scale 'y'

    # XXX: assume xs is numerical!!
    xs = _.uniq(table.getColumn("x")).sort (a,b)->a-b
    diffs = _.map _.range(xs.length-1), (idx) ->
      xs[idx+1]-xs[idx]
    mindiff = _.min diffs or 1
    width = mindiff * 0.8
    minY = yscale.minDomain()
    getHeight = (row) -> yscale.scale(Math.abs(yscale.invert(row.get('y')) - minY))


    table.transform {
        x: 'x'
        y: 'y'
        r: 'r'
        x0: (row) -> row.get('x') - width/2.0
        x1: (row) -> row.get('x') + width/2.0
        y0: (row) -> Math.min(yscale.scale(minY), row.get('y'))
        y1: (row) -> Math.max(yscale.scale(minY), row.get('y'))
        width: width
        height: (row) -> Math.abs(row.get('y') - yscale.scale(minY))

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
