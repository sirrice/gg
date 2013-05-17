#<< gg/wf/node

class gg.wf.Source extends gg.wf.Node
  constructor: (@spec={}) ->
    super @spec

    @compute = @spec.f or @compute
    @type = "source"
    @name = _.findGood [@spec.name, "#{@type}-#{@id}"]

  compute: -> throw Error("#{@name}: Source not setup to generate tables")
  ready: -> yes

  run: ->
    # always ready!
    table = @compute()
    @output 0, new gg.wf.Data(table, new gg.wf.Env)
    table





class gg.wf.TableSource extends gg.wf.Source
  constructor: (@spec) ->
    super @spec

    @table = @spec.table

  compute: -> @table


