
class gg.stat.Stat extends gg.core.XForm
  # list of dynamically registered stat classes
  @klasses = []

  # dynamically add a new class definition
  @addKlass: (klass) ->
    # TODO: check for overlapping aliases and warn/throw error
    @klasses.push klass

  # @return mapping from alias -> stat class object
  @getKlasses: ->
    klasses = @klasses.concat [
      gg.stat.IdentityStat
      gg.stat.Bin1D
      gg.stat.BoxplotStat
      gg.stat.LoessStat
      gg.stat.SortStat
      gg.stat.CDF
      gg.stat.Bin2D
    ]

    ret = {}
    _.each klasses, (klass) ->
      if _.isArray klass.aliases
        _.each klass.aliases, (alias) -> ret[alias] = klass
      else
        ret[klass.aliases] = klass
    ret

  @fromSpec: (spec) ->
    klasses = @getKlasses()
    if _.isString spec
      type = spec
      spec = {}
    else
      type = _.findGood [spec.type, spec.stat, "identity"]

    klass = klasses[type] or gg.stat.IdentityStat
    ret = new klass spec
    @log "klass #{klass.name} from type: #{type}"
    ret





