#<< gg/core/bform

# Merges scale sets across facets and layers into a single
# master scale set, then merges components back to each layer's
# scale set
class gg.scale.train.Master extends gg.core.BForm
  @ggpackage = "gg.scale.train.Master"


  parseSpec: ->
    super
    @params.ensure 'scalesTrain', [], 'fixed'

  compute: (pairtable, params) ->
    gg.scale.train.Master.train pairtable, params

  @train: (pairtable, params) ->
    scalesTrain = params.get('scalesTrain') or 'fixed'

    table = pairtable.getTable()
    md = pairtable.getMD()

    if scalesTrain is 'fixed'
      scalesList = _.uniq md.getColumn 'scales'
      masterScales = gg.scale.Set.merge scalesList
      #@expandDomains masterScales
      md = gg.data.Transform.mapCols md,
        scales: (scales) ->
          scales.merge masterScales, no
          scales
    else
      md = @trainFreeScales md

    new gg.data.PairTable table, md


  @trainFreeScales: (md, xs, ys) ->
    # fix this for extended facets
    xFacet = 'facet-x'
    yFacet = 'facet-y'

    xscalesList = _.o2map md.partition(xFacet), (p) ->
      key = p.get 0, xFacet
      scales = gg.scale.Set.merge p.getColumn('scales')
      [key, scales.exclude(gg.scale.Scale.ys)]

    yscalesList = _.o2map md.partition(yFacet), (p) ->
      key = p.get 0, yFacet
      scales = gg.scale.Set.merge p.getColumn('scales')
      [key, scales.exclude(gg.scale.Scale.xs)]

    ps = _.map md.partition(['facet-x', 'facet-y']), (p) ->
      x = p.get 0, xFacet
      y = p.get 0, yFacet
      gg.data.Transform.mapCols p,
        scales: (scales) ->
          scales.merge xscalesList[x], no
          scales.merge yscalesList[y], no
          scales

    return new gg.data.MultiTable null, ps

  expandDomains: (scalesSet) ->
    return scalesSet

    _.each scalesSet.scalesList(), (scale) =>
      return unless scale.type is gg.data.Schema.numeric

      [mind, maxd] = scale.domain()
      extra = if mind == maxd then 1 else Math.abs(maxd-mind) * 0.05
      mind = mind - extra
      maxd = maxd + extra
      scale.domain [mind, maxd]

    # XXX: this should be done in the scales/scalesSet object!!!


