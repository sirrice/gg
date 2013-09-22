#<< gg/core/xform

class gg.coord.Coordinate extends gg.core.XForm
  @ggpackage = "gg.coord.Coordinate"
  @log = gg.util.Log.logger @ggpackage

  compute: (data, params) -> 
    @map data, params

  map: (data, params) -> 
    throw Error("#{@name}.map() not implemented")

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

  @fromSpec: (spec) ->
    klasses = gg.coord.Coordinate.klasses()
    if _.isString spec
      type = spec
      spec = {}
    else
      type = _.findGood [spec.type, spec.pos, "identity"]

    klass = klasses[type] or gg.coord.Identity

    @log "fromSpec: #{klass.name}\tspec: #{JSON.stringify spec}"

    ret = new klass spec
    ret

