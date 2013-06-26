#<< gg/wf/barrier

# A Barrier Transformation
#
class gg.core.BForm extends gg.wf.Barrier
  @ggpackage = "gg.core.BForm"

  parseSpec: ->
    @log "XForm spec: #{JSON.stringify @spec}"

    @params.putAll
      inputSchema: @extractAttr "inputSchema"
      outputSchema: @extractAttr "outputSchema"
      defaults: @extractAttr "defaults"
    @params.ensure "klassname", [], @constructor.ggpackage

    # wrap compute in a verification method
    compute = @spec.f or @compute.bind(@)
    @compute = (tables, envs, params) =>
      gg.core.BForm.multiAddDefaults tables, envs, params, @log
      gg.core.BForm.multiValidateInput tables, envs, params
      compute tables, envs, params

  extractAttr: (attr, spec=null) ->
    spec = @spec unless spec?
    val = _.findGoodAttr spec, [attr], null
    val = @[attr] unless val?
    if _.isFunction val
      val.constructorname = @constructor.ggpackage
    val



  @multiAddDefaults: (tables, envs, params, log) ->
    _.times tables.length, (idx) =>
      gg.core.XForm.addDefaults tables[idx], envs[idx], params, log

  @multiValidateInput: (tables, envs, params) ->
    _.each tables, (table, idx) =>
      gg.core.XForm.validateInput table, envs[idx], params

  @scalesList: (tables, envs) ->
    _.map envs, (env) -> env.get 'scales'

  #
  # Convenience functions during workflow execution
  #
  @paneInfo: (table, env) ->
    ret =
      facetX: env.get(gg.facet.base.Facets.facetXKey)
      facetY: env.get(gg.facet.base.Facets.facetYKey)
      layer: env.get "layer"
    ret

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
    vals = []
    for env in envs
      if env.contains key
        vals.push env.get(key)
    vals = _.uniq vals
    vals.sort()
    vals

  paneInfo: (args...) -> gg.core.BForm.paneInfo args...
  scalesList: (args...) -> gg.core.BForm.scalesList args...
  scales: (args...) -> gg.core.BForm.scales args...
  facetEnvs: (args...) -> gg.core.BForm.facetEnvs args...
  pick: (args...) -> gg.core.BForm.pick args...


