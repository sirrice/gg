#<< gg/core/bform

# Merges scale sets across facets and layers into a single
# master scale set, then merges components back to each layer's
# scale set
class gg.scale.train.Master extends gg.core.BForm
  parseSpec: ->
    @params.ensure 'scalesTrain', [], 'fixed'

  compute: (tables, envs, params) ->
    gg.scale.train.Master.train tables, envs, params
    tables

  @train: (tables, envs, params) ->
    scalesTrain = params.get('scalesTrain') or 'fixed'
    scaleSetList = @scalesList tables, envs
    masterScaleSet = gg.scale.Set.merge scaleSetList
    #@expandDomains masterScaleSet

    if scalesTrain is 'fixed'
      _.each envs, (env) ->
        scaleSet = env.get 'scales'
        scaleSet.merge masterScaleSet, true
    else
      xs = @pick envs, 'x'
      ys = @pick envs, 'y'
      @trainFreeScales envs, xs, ys


  @trainFreeScales: (envs, xs, ys) ->
    xKey = gg.facet.base.Facets.facetXKey
    yKey = gg.facet.base.Facets.facetYKey

    xScaleSets = _.map xs, (x) ->
      xenvs = _.filter envs, (env) -> env.get(xKey) is x
      gg.scale.Set.merge(_.map xenvs, (e) -> e.get 'scales')
        .exclude(gg.scale.Scale.ys)

    yScaleSets = _.map ys, (y) ->
      yenvs = _.filter envs, (env) -> env.get(yKey) is y
      gg.scale.Set.merge(_.map yenvs, (e) -> e.get 'scales')
        .exclude(gg.scale.Scale.xs)

    # Expand Domains (not implemented)

    # Merge into each layer's scale sets
    _.each envs, (env) ->
      x = env.get xKey
      y = env.get yKey
      xidx = _.indexOf xs, x
      yidx = _.indexOf ys, y
      scaleSet = env.get('scales')
      scaleSet.merge xScaleSets[xidx], no
      scaleSet.merge yScaleSets[yidx], no


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


