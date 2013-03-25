


class gg.wf.TableSource extends gg.wf.Source
  constructor: (@spec) ->
    super @spec

    @table = @spec.table

  compute: -> @table


