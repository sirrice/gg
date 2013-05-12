#<< gg/core/xform

class gg.pos.Position extends gg.core.XForm
  constructor: (@layer, @spec={}) ->
    g = @layer.g if @layer?
    super g, @spec
    @parseSpec()


  @klasses: ->
    klasses = [
      gg.pos.Identity
      gg.pos.Shift
      gg.pos.Jitter
      gg.pos.Stack
    ]
    ret = {}
    _.each klasses, (klass) ->
      if _.isArray klass.aliases
        _.each klass.aliases, (alias) -> ret[alias] = klass
      else
        ret[klass.aliases] = klass
    ret

  @fromSpec: (layer, spec) ->
    klasses = gg.pos.Position.klasses()
    if _.isString spec
      type = spec
      spec = {}
    else
      type = _.findGood [spec.type, spec.pos, "identity"]

    klass = klasses[type] or gg.pos.Identity

    console.log "Position.fromSpec: klass #{klass.name} from spec #{JSON.stringify spec}"

    ret = new klass layer, spec
    ret

class gg.pos.Identity extends gg.pos.Position
  @aliases = ["identity"]






