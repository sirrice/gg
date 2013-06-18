#<< gg/wf/node

class gg.wf.Source extends gg.wf.Node
  @ggpackage = "gg.wf.Source"

  constructor: (@spec={}) ->
    super
    @type = "source"
    @name = _.findGood [@spec.name, "#{@type}-#{@id}"]

    @params.ensure 'compute', ['f'], ((args...)=>@compute args...)

  compute: ->
    throw Error("Source not setup to generate tables")

  ready: -> yes

  run: ->
    # always ready!
    compute = @params.get 'compute'
    env = new gg.wf.Env
    console.log "running with params #{@params}"
    table = compute null, env, @params
    @output 0, new gg.wf.Data(table, env)
    table





class gg.wf.TableSource extends gg.wf.Source
  @ggpackage = "gg.wf.TableSource"

  constructor: (@spec) ->
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

    unless @params.contains 'url'
      throw Error("CsvSource needs a URL")

  compute: ->
    throw Error("not implemented")
# CSVSource
# JDBC/SQLSource
# MapSource
