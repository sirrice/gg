

# A Barrier Transformation
#
class gg.core.BForm extends gg.core.XForm

  parseSpec: ->
    super

  @scalesList: (tables, envs) ->
    _.map envs, (env) -> env.get 'scales'

  # Retrieve _any_ of the scaleSets related to the x/y facet
  @scales: (tables, envs, xFacet, yFacet) ->
    fEnvs = @facetEnvs tables, envs, xFacet, yFacet
    if fEnvs.length == 0
      throw Error("couldn't find scales for x/yfacet: #{xFacet}/#{yFacet}")
    fEnvs[0].get 'scales'

  # Return the env objects that match the x/y facet
  @facetEnvs: (tables, envs, xFacet, yFacet) ->
    xKey = gg.facet.base.Facets.facetXKey
    yKey = gg.facet.base.Facets.facetYKey
    _.filter envs, (env) -> env.get(xKey) is xFacet and env.get(yKey) is yFacet

  # pick "key" from list of env objects.
  @pick: (envs, key, defaultVal=null) ->
    vals = _.map envs, (e) -> e.get(key) or defaultVal
    vals = _.uniq vals
    vals.sort()
    vals

  scalesList: (args...) -> gg.core.BForm.scalesList args...
  scales: (args...) -> gg.core.BForm.scales args...
  facetEnvs: (args...) -> gg.core.BForm.facetEnvs args...
  pick: (args...) -> gg.core.BForm.pick args...


  @multiAddDefaults: (tables, envs, params) ->
    _.times tables.length, (idx) =>
      @addDefaults tables[idx], envs[idx], params

  @multiValidateInput: (tables, envs, params) ->
    _.each tables, (table, idx) =>
      @validateInput table, envs[idx], params

  compile: ->
    spec = _.clone @spec
    _compute = (tables, envs, params) =>
      # optionally clone tables?

      gg.core.BForm.multiAddDefaults tables, envs, params
      gg.core.BForm.multiValidateInput tables, envs, params
      compute = params.get '__compute__'
      compute tables, envs, params

    spec.params = @params.clone()
    spec.params.put 'compute', _compute
    spec.params.put '__compute__', (args...) => @compute args...
    node = new gg.wf.Barrier spec
    [node]
