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
    scalesTrain = params.get('scalesTrain') or "fixed"

    table = pairtable.left()
    md = pairtable.right()

    if scalesTrain is 'fixed'
      sets = _.uniq md.all 'scales'
      masterSet = new gg.scale.MergedSet sets
      #@expandDomains masterScales

      for set in sets
        set.merge masterSet
    else
      @trainFreeScales md
    pairtable


  @trainFreeScales: (md, xs, ys) ->
    # fix this for extended facets
    xFacet = 'facet-x'
    yFacet = 'facet-y'


    xscalesList = {}
    md.partition(xFacet).each (p) ->
      key = p.get xFacet
      scales = new gg.scale.MergedSet p.get('table').all('scales')
      xscalesList[key] = scales.exclude(gg.scale.Scale.ys)

    yscalesList = {}
    md.partition(yFacet).each (p) ->
      key = p.get yFacet
      scales = new gg.scale.MergedSet p.get('table').all('scales')
      yscalesList[key] =  scales.exclude(gg.scale.Scale.xs)

    md.distinct(xFacet, yFacet).each (row) ->
      x = row.get xFacet
      y = row.get yFacet
      for set in row.get('scales')
        set.merge xscalesList[x]
        set.merge yscalesList[y]

    md

  expandDomains: (scalesSet) ->
    return scalesSet

    _.each scalesSet.scalesList(), (scale) =>
      return unless scale.type is data.Schema.numeric

      [mind, maxd] = scale.domain()
      extra = if mind == maxd then 1 else Math.abs(maxd-mind) * 0.05
      mind = mind - extra
      maxd = maxd + extra
      scale.domain [mind, maxd]

    # XXX: this should be done in the scales/scalesSet object!!!


