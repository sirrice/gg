#<< gg/util
class gg.Statistic #extends gg.wf.Composite
    constructor: (@spec) ->
        super

    isDiscrete: (aes, colname, table) ->

    run: (tables) ->


    compute: (tables) ->

class gg.Bin extends gg.Statistic
    constructor: (@spec) ->
        super @spec

        @inSchema = ['x']

        @binwidth = specget 'binwidth', @scales('x').domain() / 30


    getgroupcols: ->
        groups = specget ['group', 'groups']
        groups = _.filter @scales().aesthetics(), @isDiscrete if not groups?








class gg.Statistic
    constructor: (spec) ->
        @group = spec.group or false
        @variable = spec.variable # why just a single variable?
        @requiredAES = []
        @defaultAES
        @defaultMapping

    ensureAES: (data) ->
        if not data? or not data.length
            true
        _.every @requiredAES, (aes) -> aes of data[0]



class gg.BinStatistic extends gg.Statistic
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

class gg.SumStatistic extends gg.Statistic
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

class gg.BoxPlotStatistic extends gg.Statistic
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

class gg.IdentityStatistic extends gg.Statistic
    constructor: (spec) ->
        super spec

    compute: (data) ->
        data







