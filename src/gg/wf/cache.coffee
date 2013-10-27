#<< gg/wf/node


class gg.wf.Cache extends gg.wf.Node
  @ggpackage = "gg.wf.Cache"

  parseSpec: ->
    super
    unless @params.has "guid"
      throw Error("cacher requires a guid!")

  @getDB: ->
    unless window?
      return null
    unless window.localStorage?
      return null
    window.localStorage

  run: ->
    throw Error("node not ready") unless @ready()

    guid = @params.get 'guid'
    db = gg.wf.Cache.getDB()
    unless db?
      throw Error "Cache cannot run without a DB"

    try
      @trySave guid
    catch err
      @log.warn "error storing. try clear db and save again: #{err.message}"
      try
        db.clear()
        @trySave guid
        @log.warn "success!"
      catch err
        @log.warn "save failed second time. aborting #{err.message}"
        for pairtable, idx in @inputs
          delete db["#{guid}-#{idx}-table"]
          delete db["#{guid}-#{idx}-md"]
        delete db[guid] 
        @log.warn "done aborting"

    for pairtable, idx in @inputs
      @output idx, pairtable
  
  trySave: (guid) ->
    db = gg.wf.Cache.getDB()

    db[guid] = @inputs.length
    for pairtable, idx in @inputs
      key = "#{guid}-#{idx}"
      [t, md] = [pairtable.getTable(), pairtable.getMD()]
      tstr = t.serialize()
      md = md.clone()
      md.rmColumn 'svg' if md.has('svg')
      mdstr = md.serialize()

      db["#{key}-table"] = tstr
      db["#{key}-md"] = mdstr





    
   