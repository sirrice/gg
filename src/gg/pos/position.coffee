#<< gg/core/xform

class gg.pos.Position 
  @ggpackage = "gg.pos.Position"

  @klasses: ->
    klasses = _.compact [
      gg.pos.Identity
      gg.pos.Shift
      gg.pos.Jitter
      gg.pos.Stack
      gg.pos.Dodge
      gg.pos.Text
      gg.pos.Bin2D
      gg.pos.DotPlot
    ]
    ret = {}
    _.each klasses, (klass) ->
      for alias in _.flatten [klass.aliases]
        ret[alias] = klass
    ret

  @fromSpec: (spec) ->
    klasses = gg.pos.Position.klasses()
    klass = klasses[spec.type]
    new klass spec

