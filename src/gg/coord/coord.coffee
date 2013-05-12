#<< gg/core/xform

class gg.coord.Coordinate extends gg.core.XForm
  constructor: (@layer, @spec={}) ->
    g = @layer.g if @layer?
    super g, @spec
    @parseSpec()


  @klasses: ->
    klasses = [
      gg.coord.Identity
      gg.coord.YFlip
      gg.coord.XFlip
      gg.coord.Flip
    ]
    ret = {}
    _.each klasses, (klass) ->
      if _.isArray klass.aliases
        _.each klass.aliases, (alias) -> ret[alias] = klass
      else
        ret[klass.aliases] = klass
    ret

  @fromSpec: (layer, spec) ->
    klasses = gg.coord.Coordinate.klasses()
    if _.isString spec
      type = spec
      spec = {}
    else
      type = _.findGood [spec.type, spec.pos, "identity"]

    klass = klasses[type] or gg.coord.Identity

    console.log "Coordinate.fromSpec: klass #{klass.name} from spec #{JSON.stringify spec}"

    ret = new klass layer, spec
    ret

  compute: (table, env, node) -> @map table, env, node

  map: (table, env) -> throw Error("#{@name}.map() not implemented")


