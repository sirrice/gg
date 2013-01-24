class Statistic
    constructor: (spec) ->
        @group = spec.group or false
        @variable = spec.variable # why just a single variable?


class BinStatistic extends gg.Statistic
    constructor: (spec) ->
        @bins = spec.bins or 20
        super spec

    compute: (data) ->
        vals = _.pluck data, @variable
        histogram = d3.layout.histogram().bins(@bins)
        freq = histogram vals
        histogram.frequency false
        density = histogram vals
        _.map freq, (bin, i) =>
            bin: i, count: bin.y, density: density[i].y, ncount: bin.y / data.length or 0

class SumStatistic extends gg.Statistic
    constructor: (spec) ->
        super spec

    compute: (data) ->
        grps = groupData data, @group
        value = _.bind (point) => point[@variable]
        _.map grps, (values, name) =>
            {
                group : name,
                count: values.length,
                sum: d3.sum(values, value),
                min: d3.min(values, value),
                max: d3.max(values, value)
            }

class BoxPlotStatistic extends gg.Statistic
    constructor: (spec) ->
        super spec

    # @return [min, max]
    dataRange: (data) ->
        flattened = _.flatten data
        [
            _.min(_.pluck flattened, 'min'),
            _.max(_.pluck flattened, 'max')
        ]

    compute: (data) ->
        grps = splitByGroups data, @group, @variable

        _.map grps, (vals, name) =>
            vals.sort d3.ascending

            q1 = d3.quantile vals, 0.25
            median = d3.quantile vals, 0.5
            q3 = d3.quantile vals, 0.75
            min = vals[0]
            max = vals[vals.length - 1]
            fr = 1.5 * (q3-q1)
            lowerIdx = d3.bisectLeft vals, q1 - fr
            upperIdx = (d3.bisectRight vals, q3 + fr, lowerIdx) - 1
            lower = vals[lowerIdx]
            upper = vals[upperIdx]
            outliers = vals.slice(0, lowerIdx).concat(vals.slice(upperIdx + 1))

            {
                group: name,
                q1: q1,
                median: median,
                q3: q3,
                lower: lower,
                upper: upper,
                outliers: outliers,
                min: min,
                max: max
            }

class IdentityStatistic extends gg.Statistic
    constructor: (spec) ->
        super spec

    compute: (data) ->
        data







groupData = (data, groupBy) ->
    if not groupBy? then [data] else _.groupBy data, groupBy
splitByGroups = (data, group, variable) ->
    groups = {}
    if group
        _.each data, (d) =>
            g = d[group]
            groups[g] = [] if not groups[g]?
            groups[g].push d[variable]
    else
        groups['data'] = _.pluck data, variable
    groups


