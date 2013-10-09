
class gg.core.FormUtil 
  
  # 
  # Single data methods
  #

  # throws exception if inputs don't validate with schema
  @validateInput: (pt, params, log) ->
    table = pt.getTable()
    return yes unless table.nrows() > 0
    iSchema = params.get "inputSchema", pt, params
    return unless iSchema?

    missing = _.reject iSchema, (col) -> table.has col
    if missing.length > 0
      if log?
        log log.logname
        gg.wf.Stdout.print table, null, 5, log
      throw Error("#{params.get 'name'}: input schema did not contain #{missing.join(",")}")
    yes

  # adds default values for non-existent attributes in
  # data table.
  @addDefaults: (pt, params, log) ->
    table = pt.getTable()
    defaults = params.get "defaults", pt, params
    if log?
      log "table schema: #{table.schema.toString()}"
      log "expected:     #{JSON.stringify defaults}"

    for col, val of defaults
      unless table.has col
        log "adding:   #{col} -> #{val}" if log?
        table = table.addConstColumn col, val
    new gg.data.PairTable table, pt.getMD()



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


