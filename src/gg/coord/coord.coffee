#<< gg/core/xform

class gg.coord.Coordinate extends gg.core.XForm
  @ggpackage = "gg.coord.Coordinate"
  @log = gg.util.Log.logger @ggpackage

  compute: (pairtable, params) -> 
    throw Error("#{@name}.compute() not implemented")

  @klasses: ->
    klasses = [
      gg.coord.Identity
      gg.coord.YFlip
      gg.coord.XFlip
      gg.coord.Flip
      gg.coord.Swap
    ]
    ret = {}
    _.each klasses, (klass) ->
      for alias in _.flatten [klass.aliases]
        ret[alias] = klass
    ret

  @fromSpec: (spec) ->
    klasses = gg.coord.Coordinate.klasses()
    klass = klasses[spec.type]

    @log "fromSpec: #{klass.name}\tspec: #{JSON.stringify spec}"
    new klass spec
