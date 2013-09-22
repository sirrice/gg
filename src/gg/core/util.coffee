
class gg.core.FormUtil 
  
  # 
  # Single data methods
  #

  # throws exception if inputs don't validate with schema
  @validateInput: (data, params, log) ->
    table = data.table
    env = data.env
    return yes unless table.nrows() > 0
    iSchema = params.get "inputSchema", data, params
    return unless iSchema?
    missing = _.reject iSchema, (attr) -> table.contains attr
    if missing.length > 0
      if log?
        log log.logname
        gg.wf.Stdout.print table, null, 5, log
      throw Error("#{params.get 'name'}: input schema did not contain #{missing.join(",")}")

  # adds default values for non-existent attributes in
  # data table.
  @addDefaults: (data, params, log) ->
    table = data.table
    env = data.env
    defaults = params.get "defaults", data, params
    if log?
      log "table schema: #{table.schema.toSimpleString()}"
      log "expected:     #{JSON.stringify defaults}"
    _.each defaults, (val, col) =>
      unless table.contains col
        if log?
          log "adding:      #{col} -> #{val}"
        table.addConstColumn col, val

  @paneInfo: (data) ->
    ret =
      facetX: data.env.get(gg.facet.base.Facets.facetXKey)
      facetY: data.env.get(gg.facet.base.Facets.facetYKey)
      layer: data.env.get "layer"
    ret

  @scales: (data) ->
    env = data.env
    layer = env.get "layer"
    unless env.contains "scales"
      config = env.get "scalesconfig"
      scaleset = config.scales layer
      env.put "scales", scaleset
    env.get "scales"

  #
  # Multi-data methods
  #


  @multiAddDefaults: (datas, params, log) ->
    for data in datas
      gg.core.FormUtil.addDefaults data, params, log

  @multiValidateInput: (datas, params) ->
    for data in datas
      gg.core.FormUtil.validateInput data, params

  @scalesList: (datas) ->
    _.map datas, (data) -> data.env.get 'scales'

  # Return the Data objects that match the x/y facet
  @facetDatas: (datas, xFacet, yFacet) ->
    Facets = gg.facet.base.Facets
    _.filter datas, (data) ->
        (data.env.get(Facets.facetXKey) is xFacet and
         data.env.get(Facets.facetYKey) is yFacet)

  @facetEnvs: (datas, xFacet, yFacet) ->
    _.map @facetDatas(datas, xFacet, yFacet), (data) -> data.env

  @facetTables: (datas, xFacet, yFacet) ->
    _.map @facetDatas(datas, xFacet, yFacet), (data) -> data.table

  # pick "key" from list of env objects.
  @pick: (datas, key) ->
    vals = []
    for data in datas 
      vals.push data.env.get(key)
    vals = _.uniq vals
    vals.sort()
    vals


