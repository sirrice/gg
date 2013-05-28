#<< gg/wf/node
#<< gg/pos/position
#<< gg/geom/render
#<< gg/scale/scales






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
class gg.geom.Geom # not an XForm!!
  @log = gg.util.Log.logger "Geom", gg.util.Log.WARN

  constructor: (@layer, @spec) ->
    @g = @layer.g

    @render = null
    @map = null
    @reparam = null
    @unparam = null

    @parseSpec()

  # { type:, aes:, param:}
  parseSpec: ->
    @render = gg.geom.Render.fromSpec @layer, @spec.type
    @map = gg.xform.Mapper.fromSpec @g, @spec

  name: -> @constructor.name.toLowerCase()
  posMapping: -> {}

  @klasses = []

  @addKlass: (klass) ->
    @klasses.push klass

  @getKlasses: ->
    klasses = @klasses.concat [
        gg.geom.Point
        gg.geom.Line
        gg.geom.Path
        gg.geom.Area
        gg.geom.Rect
        gg.geom.Polygon
        gg.geom.Hex
        gg.geom.Boxplot
        gg.geom.Glyph
        gg.geom.Edge
        gg.geom.Text
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

    klasses = @getKlasses()

    klass = klasses[spec.type] or gg.geom.Point
    @log "fromSpec\t#{JSON.stringify spec}"
    @log "fromSpec: klass: #{spec.type} -> #{klass.name}"

    spec.name = klass.name unless spec.name?
    geom = new klass(layer, spec)

    geom





class gg.geom.Step extends gg.geom.Geom
  @aliases: "step"

class gg.geom.Path extends gg.geom.Geom
  @aliases: "path"

class gg.geom.Polygon extends gg.geom.Geom
    @aliases: "polygon"

class gg.geom.Hex extends gg.geom.Geom
    @aliases: "hex"

class gg.geom.Glyph extends gg.geom.Geom
    @aliases: "glyph"

class gg.geom.Edge extends gg.geom.Geom
    @aliases: "edge"
