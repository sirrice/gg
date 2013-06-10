

class gg.xform.AddCol extends gg.core.XForm
  parseSpec: ->
    super

    @params.putAll
      colname: _.findGood [@spec.colname, @spec.col, @spec.key]
      envkey: _.findGood [@spec.envkey, @spec.key]

    throw Error() unless params.get('colname')?
    throw Error() unless params.get('envkey')?


  compute: (table, env, node) ->
    t.addConstColumn
