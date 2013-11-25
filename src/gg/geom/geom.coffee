#<< gg/wf/node
#<< gg/pos/position
#<< gg/geom/render
#<< gg/scale/scales



# Geoms are a holding house for tree types of XForms (not an XForm itself):
#
# 1) Schema Mapping -- from stats outputs to geometry-expected schemas
# 2) Reparameterizing -- adding/deriving the expected attributes
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
class gg.geom.Geom
  @ggpackage = "gg.geom.Geom"
  @log = gg.util.Log.logger @ggpackage,  "Geom"

  constructor: (@layer, @spec) ->
    @g = @layer.g

    @render = null
    @map = null
    @reparam = null

    @parseSpec()

  # { type:, aes:, param:}
  parseSpec: ->
    @render = gg.geom.Render.fromSpec @spec
    @map = gg.xform.Mapper.fromSpec @spec

  # @return mapping of attribute -> aesthetic
  # this should be deprecated once prov "works"
  posMapping: -> {}

  @fromSpec: (layer, spec) ->
    spec = _.clone spec
    klasses = @getKlasses()
    unless spec.type of klasses
      throw Error "geom #{spec.type} not found"

    klass = klasses[spec.type] 
    spec.name = klass.name unless spec.name?
    new klass layer, spec


  @klasses = []

  @addKlass: (klass) ->
    @klasses.push klass

  @getKlasses: ->
    klasses = _.compact @klasses.concat [
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
        gg.geom.Bin2D
    ]
    ret = {}
    _.each klasses, (klass) ->
      if _.isArray klass.aliases
        _.each klass.aliases, (alias) -> ret[alias] = klass
      else
        ret[klass.aliases] = klass
    ret





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
