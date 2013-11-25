
class gg.stat.Stat 

  # list of dynamically registered stat classes
  @klasses = []

  # dynamically add a new class definition
  @addKlass: (klass) ->
    # TODO: check for overlapping aliases and warn/throw error
    @klasses.push klass

  # @return mapping from alias -> stat class object
  @getKlasses: ->
    klasses = _.compact @klasses.concat [
      gg.stat.Identity
      gg.stat.Bin1D
      gg.stat.Boxplot
      gg.stat.Loess
      gg.stat.Sort
      gg.stat.CDF
      gg.stat.Bin2D
    ]

    ret = {}
    _.each klasses, (klass) ->
      for alias in _.flatten [klass.aliases]
        ret[alias] = klass
    ret

  @fromSpec: (spec) ->
    klasses = @getKlasses()
    klass = klasses[spec.type]
    new klass spec if klass?
