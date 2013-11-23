
class gg.core.FormUtil 
  
  # 
  # Single data methods
  #

  # throws exception if inputs don't validate with schema
  @validateInput: (pt, params, log) ->
    table = pt.left()
    unless table.nrows() > 0
      return yes

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
    table = pt.left()
    defaults = params.get "defaults", pt, params
    if log?
      log "table schema: #{table.schema.toString()}"
      log "expected:     #{JSON.stringify defaults}"

    mapping = _.map defaults, (v, k) ->
      if k == 'group'
        unless _.isObject v
          throw Error "group default value should be object: #{v}"
        log "adding:  #{k} -> #{v}"
        f = (group, idx) ->
          newv = _.clone v
          _.extend newv, group if group?
          newv
        return {
          alias: k
          f: f
          cols: 'group'
        }

      if table.has k
        return null
      else
        log "adding:  #{k} -> #{v}"
        return _.mapToFunction table, k, v
    mapping = _.compact mapping
    table = table.project mapping, yes
    pt.left table
    pt

  @ensureScales: (pt, params, log) ->
    md = pt.right()
    unless md.nrows() <= 1
      log "@scales called with multiple rows: #{md.nrows()}"
    if md.nrows() == 0 
      log "@scales called with no md rows"
      log pt.left().raw()
      throw Error "@scales called with no md rows"
    unless md.has 'scalesconfig'
      md = md.setColVal 'scalesconfig', gg.scale.Config.fromSpec({})
    unless md.has 'scales'
      f = (row) ->
          return row.get 'scales' if row.get('scales')?
          layer = row.get 'layer'
          config = row.get 'scalesconfig'
          config.scales(layer)

      md = md.project [ { alias: 'scales', f: f, type: data.Schema.object } ], yes
      pt.right md
      pt
    else
      pt


  @scales: (pt, params, log) ->
    md = pt.right()
    unless md.nrows() <= 1
      log.warn "@scales called with multiple rows: #{md.raw()}"

    if md.nrows() == 0 
      throw Error "@scales called with no md rows"
    if md.has 'scales'
      md.any 'scales'
    else
      row = md.any()
      layer = row.get 'layer'
      config = row.get 'scalesconfig'
      scaleset = config.scales layer
      md = md.setColVal 'scales', scaleset
      pt.right md
      scaleset


