

class gg.data.TableSet 

  constructor: (@tables) ->

  schemas: -> _.map @tables, (table) -> table.schema
  checkSchema: (cols) ->
    for schema in @schemas()
      for col in cols
        unless schema.has col
          return no
    yes

  # can only partition on columns present in every table!
  partition: (cols) ->
    unless @checkSchema cols
      throw Error "cols #{cols.join(' ')} not in all schemas"



