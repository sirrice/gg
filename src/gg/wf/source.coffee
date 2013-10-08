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

    pt = new gg.data.PairTable
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
    pt.table = params.get('table')
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
    pt.table = gg.data.Table.fromArray(
      params.get('rows'), 
      null, 
      params.get('tabletype'))
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
      pt.table = table
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
        pt.table = table
        cb null, pt

