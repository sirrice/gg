#<< gg/xform

class gg.Position extends gg.XForm
  # noop!

  @fromSpec: (layer, spec) ->
    if _.isString spec
      new gg.Position layer, {type: spec}
    else
      new gg.Position layer, spec


