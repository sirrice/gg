
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
        log "#{params.get 'name'}: input schema did not contain #{missing.join(",")}"
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

    mapping = _.map defaults, (v, k) ->
      if k == 'group'
        unless _.isObject v
          throw Error "group default value should be object: #{v}"
        log "adding:  #{k} -> #{v}"
        f = (row) ->
          newv = _.clone v
          _.extend newv, row.get('group') if row.has 'group'
          newv
        return [k, f, gg.data.Schema.object]

      if table.has k
        return null
      else
        log "adding:  #{k} -> #{v}"
        return _.mapToFunction table, k, v
    mapping = _.compact mapping
    table = gg.data.Transform.transform table, mapping
    new gg.data.PairTable table, pt.getMD()


  @ensureScales: (pairtable, params, log) ->
    md = pairtable.getMD()
    unless md.nrows() <= 1
      log "@scales called with multiple rows: #{md.nrows()}"
    if md.nrows() == 0 
      log "@scales called with no md rows"
      log pairtable.getTable()
      throw Error "@scales called with no md rows"
    unless md.has 'scalesconfig'
      md = md.setColumn 'scalesconfig', gg.scale.Config.fromSpec({})
    unless md.has 'scales'
      f = (row) ->
        layer = row.get 'layer'
        config = row.get 'scalesconfig'
        config.scales(layer)

      md = gg.data.Transform.transform md, [
        ['scales', f, gg.data.Schema.object]
      ]
      new gg.data.PairTable pairtable.getTable(), md
    else
      pairtable



  @scales: (pairtable, params, log) ->
    md = pairtable.getMD()
    unless md.nrows() <= 1
      log.warn "@scales called with multiple rows: #{md.raw()}"
    if md.nrows() == 0 
      throw Error "@scales called with no md rows"
    if md.has 'scales'
      md.get 0, 'scales'
    else
      layer = md.get 0, 'layer'
      config = md.get 0, 'scalesconfig'
      scaleset = config.scales layer
      md = md.setColumn 'scales', scaleset
      scaleset

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


