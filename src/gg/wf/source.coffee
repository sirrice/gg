#<< gg/wf/node


class gg.wf.Source extends gg.wf.Exec
  @ggpackage = "gg.wf.Source"

  constructor: (@spec={}) ->
    super
    @type = "source"
    @name = _.findGood [@spec.name, "#{@type}-#{@id}"]


  compute: (table, env, params) ->
    throw Error("Source not setup to generate tables")


class gg.wf.TableSource extends gg.wf.Source
  @ggpackage = "gg.wf.TableSource"

  constructor: ->
    super
    @name = @spec.name or "tablesource"

  parseSpec: ->
    super

    unless @params.contains 'table'
      throw Error("TableSource needs a table as parameter")

  compute: (table, env, params) ->
    params.get('table')

class gg.wf.RowSource extends gg.wf.Source
  @ggpackage = "gg.wf.RowSource"

  constructor: ->
    super
    @name = @spec.name or "rowsource"

  parseSpec: ->
    super

    @params.ensure "rows", ["array", "row"], null
    unless @params.get('rows')?
      throw Error("RowSource needs a table as parameter")

  compute: (table, env, params) ->
    gg.data.RowTable.fromArray params.get('rows')



class gg.wf.CsvSource extends gg.wf.Source
  @ggpackage = "gg.wf.CsvSource"

  constructor: (@spec) ->
    super
    @name = "CSVSource"

  parseSpec: ->
    super
    unless @params.contains 'url'
      throw Error("CsvSource needs a URL")

  run: ->
    url = @params.get("url")
    d3.csv url, (arr) =>
      table = gg.data.RowTable.fromArray arr

      f = (data) =>
        new gg.wf.Data table, data.env
      outputs = gg.wf.Inputs.mapLeaves @inputs[0], f
      @output 0, outputs


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

    unless @params.get("uri")?
      throw Error "SQLSource needs a connection URI: params.put 'uri', <URI>"
    unless @params.get("query")?
      throw Error "SQLSource needs a query string"

  run: ->
    unless pg?
      throw Error("pg is not allowed on the client side")

    uri = @params.get "uri"
    query = @params.get "q"
    @log.level = 0
    @log pg
    @log "uri: #{uri}"
    @log "query: #{query}"
    client = new pg.Client uri
    client.connect (err) =>
      throw Error(err) if err?

      client.query query, (err, result) =>
        throw Error err if err?

        rows = result.rows
        table = gg.data.RowTable.fromArray rows
        client.end()

        f = (data) =>
          new gg.wf.Data table, data.env
        outputs = gg.wf.Inputs.mapLeaves @inputs[0], f
        @log outputs
        @output 0, outputs


# MapSource
