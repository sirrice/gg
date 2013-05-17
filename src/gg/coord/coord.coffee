#<< gg/core/xform

class gg.coord.Coordinate extends gg.core.XForm
  @log = gg.util.Log.logger "Coord"
  constructor: (@layer, @spec={}) ->
    g = @layer.g if @layer?
    super g, @spec
    @parseSpec()
    @log = gg.util.Log.logger @constructor.name, gg.util.Log.WARN


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

    @log "fromSpec: #{klass.name}\tspec: #{JSON.stringify spec}"

    ret = new klass layer, spec
    ret

  compute: (table, env, node) -> @map table, env, node

  map: (table, env) -> throw Error("#{@name}.map() not implemented")


