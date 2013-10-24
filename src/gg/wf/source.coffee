#<< gg/wf/node


class gg.wf.Source extends gg.wf.Node
  @ggpackage = "gg.wf.Source"
  @type = "source"

  parseSpec: ->
    super
    @params.ensure "tabletype", [], "row"
    @params.ensure 'compute', ['f'], null

  compute: (pairtable, params, cb) ->
    throw Error("Source not setup to generate tables")
  
  run: ->
    throw Error("node not ready") unless @ready()
    params = @params
    compute = @params.get('compute') or @compute.bind(@)
    pt = @inputs[0]

    compute pt, params, (err, pairtable) =>
      @error err if err?
      @output 0, pairtable


class gg.wf.TableSource extends gg.wf.Source
  @ggpackage = "gg.wf.TableSource"

  constructor: ->
    super
    @name = @spec.name or "tablesource"

  parseSpec: ->
    super

    unless @params.contains 'table'
      if 'table' of @spec
        @params.put 'table', @spec.table
      else
        throw Error("TableSource needs a table as parameter")

  compute: (pt, params, cb) ->
    pt = new gg.data.PairTable params.get('table'), pt.getMD()
    cb(null, pt)

class gg.wf.RowSource extends gg.wf.Source
  @ggpackage = "gg.wf.RowSource"

  constructor: ->
    super
    @name = @spec.name or "rowsource"

  parseSpec: ->
    super

    @params.ensure "rows", ["array", "row"], null
    @params.require "rows", "RowSource needs a table as parameter"
    unless @params.get('rows')?
      throw Error "RowSource needs a table as parameter"

  compute: (pt, params, cb) ->
    table = gg.data.Table.fromArray(
      params.get('rows'), 
      null, 
      params.get('tabletype'))
    pt = new gg.data.PairTable table, pt.getMD()
    cb null, pt



class gg.wf.CsvSource extends gg.wf.Source
  @ggpackage = "gg.wf.CsvSource"

  constructor: (@spec) ->
    super
    @name = "CSVSource"

  parseSpec: ->
    super
    @params.require 'url', 'CsvSource needs a URL'

  compute: (pt, params, cb) ->
    url = params.get 'url'
    tabletype = params.get 'tabletype'
    d3.csv url, (arr) ->
      table = gg.data.Table.fromArray arr, null, tabletype
      pt = new gg.data.PairTable table, pt.getMD()
      cb null, pt

class gg.wf.SQLSource extends gg.wf.Source
  @ggpackage = "gg.wf.SQLSource"

  constructor: (@spec) ->
    super
    @name = "SQLSource"

  parseSpec: ->
    super
    @params.put "location", "server"
    @params.ensure "uri", ["conn", "connection", "url"], null
    @params.ensure "query", ["q"], null

    @params.require 'uri', "SQLSource needs a connection URI: params.put 'uri', <URI>"
    @params.require 'query', "SQLSource needs a query string"

  compute: (pt, params, cb) ->
    unless pg?
      throw Error("pg is not allowed on the client side")

    uri = params.get "uri"
    query = params.get "q"
    tabletype = params.get 'tabletype'
    @log "uri: #{uri}"
    @log "query: #{query}"
    client = new pg.Client uri
    client.connect (err) ->
      if err?
        cb err, null
        throw Error(err)

      client.query query, (err, result) ->
        if err?
          cb err, null
          throw Error(err)

        rows = result.rows
        client.end()

        table = gg.data.Table.fromArray rows, null, tabletype
        pt = new gg.data.PairTable table, pt.getMD()
        cb null, pt



class gg.wf.CacheSource extends gg.wf.Source
  @ggpackage = "gg.wf.CacheSource"

  construtor: ->
    super
    @name = "CacheSource"

  parseSpec: ->
    super
    unless @params.has 'guid'
      throw Error("can't run cache source without a guid key")

  compute: (pt, params, cb) ->
    guid = params.get 'guid'
    db = gg.wf.Cache.getDB()
    ntables = parseInt db[guid]
    partitions = []

    for idx in [0...ntables]
      keyprefix = "#{guid}-#{idx}"
      tkey = "#{keyprefix}-table"
      mdkey = "#{keyprefix}-md"
      tJson = JSON.parse db[tkey]
      mdJson = JSON.parse db[mdkey]
      t = gg.data.Table.fromJSON tJson
      md = gg.data.Table.fromJSON mdJson
      partitions.push new gg.data.PairTable(t, md)

    if partitions.length == 1
      cb null, partitions[0]
    else
      cb null, new gg.data.TableSet(partitions)


