
class gg.data.SchemaMap

  @inferMapping: (source) ->



  # map from source table to new schema
  # The naive implementation:
  # 1. recursively flattens the source table
  # 2. groups flat table on target non-array attributes
  #
  # @param source  starting table
  # @param tSchema target schema to transform table into
  #                schema's leaf attributes must be a subset of the attributes
  #                in table's schema
  @transform: (source, tSchema) ->
    sSchema = source.schema
    target = new gg.data.RowTable tSchema

    source_all = sSchema.leafAttrs()
    source_nonarray = _.reject source_all, sSchema.inArray.bind(sSchema)
    source_array = _.filter source_all, sSchema.inArray.bind(sSchema)
    target_all = tSchema.leafAttrs()
    target_nonarray = _.reject target_all, tSchema.inArray.bind(tSchema)
    target_array = _.filter target_all, tSchema.inArray.bind(tSchema)

    if _.any(target_all, (tAttr) -> tAttr not in source_all)
      throw Error("Can't map ??? -> #{tAttr}")
    
    # how many array attributes are in the target?
    arr_keys = _.uniq _.map target_array, (attr) ->
      tSchema.attrToKeys[attr]

    flattened = source.flatten(null, true)
    gbFunc = (row) -> 
      _.o2map target_nonarray, (attr) -> [attr, row.get(attr)]
    groups = flattened.split gbFunc

    for group in groups
      subtable = group.table
      groupdata = group.key
      rowData = {}

      _.each group.key, (val, attr) ->
        if tSchema.isNested attr
          rowData[attr] = {} unless attr of rowData
        else if tSchema.inNested attr
          nestKey = tSchema.attrToKeys[attr]
          rowData[nestKey] = {} unless nestKey of rowData
          rowData[nestKey][attr] = val
        else
          rowData[attr] = val

      arrs = _.o2map arr_keys, (arr_key) -> [arr_key, []]
      subtable.each (subrow) ->
        _.each arrs, (arr, k) -> arr.push {}
        for key in target_array
          if subrow.contains key
            arr_key = tSchema.attrToKeys[key]
            arr = arrs[arr_key]
            _.last(arr)[key] = subrow.get key
      _.extend rowData, arrs

      target.addRow rowData

    target





