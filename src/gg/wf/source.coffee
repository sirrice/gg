#<< gg/wf/node

class gg.wf.Source extends gg.wf.Node
  @ggpackage = "gg.wf.Source"

  constructor: (@spec={}) ->
    super
    @type = "source"
    @name = _.findGood [@spec.name, "#{@type}-#{@id}"]


  compute: ->
    throw Error("Source not setup to generate tables")

  ready: -> yes

  run: ->
    env = new gg.wf.Env
    table = @compute null, env, @params

    outputs = [ new gg.wf.Data(table, env) ]
    @output 0, outputs
    outputs

class gg.wf.TableSource extends gg.wf.Source
  @ggpackage = "gg.wf.TableSource"

  parseSpec: ->
    super

    unless @params.contains 'table'
      throw Error("TableSource needs a table as parameter")

  compute: (table, env, params) ->
    console.log params
    params.get 'table'


class gg.wf.CsvSource extends gg.wf.Source
  @ggpackage = "gg.wf.CsvSource"

  constructor: (@spec) ->
    super
    @name = "CSVSource"

  parseSpec: ->
    super
    unless @params.contains 'url'
      throw Error("CsvSource needs a URL")

  compute: (table, env, params) ->
    url = params.get("url")
    d3.csv url, (arr) =>
      table = gg.data.RowTable.fromArray arr
      env = new gg.wf.Env
      data = new gg.wf.Data table, env
      outputs = [ data ]
      @output 0, outputs


class gg.wf.SQLSource extends gg.wf.Source
  parseSpec: ->
    super
    @params.put "location", "server"

  compute: (table, env, params) ->
    throw Error()

# CSVSource
# JDBC/SQLSource
# MapSource
