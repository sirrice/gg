#<< gg/stat
class gg.old.Statistics
    @fromSpec: (spec) ->
        new {
            identity: gg.IdentityStatistic,
            bin: gg.BinStatistic,
            box: gg.BoxPlotStatistic,
            sum: gg.SumStatistic,
        }[spec.kind](spec)


