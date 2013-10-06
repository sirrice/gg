

# Collection of PairTables
# Provides same APi as pairtable
class gg.data.TableSet 

  constructor: (@pairtables) ->

  schemas: -> _.map @pairtables, (table) -> table.schema
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
    
    for table in @pairtables
      partitions = table.partitionJoin cols
    
    
