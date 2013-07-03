
class gg.facet.grid.Labeler extends gg.wf.Barrier
  @ggpackage = "gg.facet.grid.Labeler"

  run:  ->
    throw Error("node nod ready") unless @ready()

    Facets = gg.facet.base.Facets
    getXFacet = (env) -> env.get Facets.facetXKey
    getYFacet = (env) -> env.get Facets.facetYKey

    inputs = _.map @inputs, (subinputs) ->
      gg.wf.Inputs.flatten(subinputs)[0]
    [flat, md] = gg.wf.Inputs.flatten(@inputs)
    xs = _.uniq _.map flat, (data) -> getXFacet data.env
    ys = _.uniq _.map flat, (data) -> getYFacet data.env
    xys = _.cross xs, ys
    xy2data = _.o2map flat, (data) ->
      xy = [getXFacet(data.env), getYFacet(data.env)]
      [JSON.stringify(xy), data]

    return if flat.length == 0
    schemaBase = flat[0].table.schema.clone()
    envBase = flat[0].env.clone()

    newData = (x, y) =>
      table = new gg.data.RowTable schemaBase.clone()
      env = envBase.clone()
      env.put Facets.facetXKey, x
      env.put Facets.facetYKey, y
      data = new gg.wf.Data table, env
      @log "created dummy for
        facet #{x}, #{y} and
        input #{inputidx}"
      data


    outputs = _.map inputs, (input) =>
      _.map xys, ([x,y]) =>
        key = JSON.stringify [x,y]
        data = xy2data[key]
        data = newData x,y unless data?

        data.table.addConstColumn Facets.facetXKey, x
        data.table.addConstColumn Facets.facetYKey, y
        data


    for data in _.flatten(outputs)
      x = getXFacet data.env
      y = getYFacet data.env
      @log "data #{x} #{y} has #{data.table.nrows()}"

    ###
    for datas in inputs
      for data in datas
        env = data.env
        Facets = gg.facet.base.Facets
        x = env.get Facets.facetXKey
        y = env.get Facets.facetYKey
        data.table.addConstColumn Facets.facetXKey, x
        data.table.addConstColumn Facets.facetYKey, y
    ###

    for output, idx in outputs
      @output idx, output
    return outputs




    xfacets = _.uniq _.map flat, (data) -> data.env.get Facets.facetXKey
    yfacets = _.uniq _.map flat, (data) -> data.env.get Facets.facetYKey

    @log "inputs: #{JSON.stringify _.map(inputs, (i)->i.length)}"
    @log "xfacet: #{JSON.stringify xfacets}"
    @log "yfacet: #{JSON.stringify yfacets}"
    @log "md structure: #{JSON.stringify md}"

    xy2data = _.o2map flat, (data) ->
      key = [data.env.get(Facets.facetXKey), data.env.get(Facets.facetYKey)]
      [key, data]

    outputs = []
    if flat.length > 0
      schemaBlueprint = flat[0].table.schema
      envBlueprint = flat[0].env
      for subinputs, inputidx in inputs
        output = []
        outputs.push output

        for x in xfacets
          for y in yfacets
            key = [x,y]
            data = xy2data[key]
            unless data?
              table = new gg.data.RowTable schemaBlueprint.clone()
              env = envBlueprint.clone()
              env.put Facets.facetXKey, x
              env.put Facets.facetYKey, y
              data = new gg.wf.Data table, env
              @log "created dummy for
                facet #{x}, #{y} and
                input #{inputidx}"

            data.table.addConstColumn Facets.facetXKey, x
            data.table.addConstColumn Facets.facetYKey, y
            @log "added constcol to #{x}, #{y}
              with nrows #{data.table.nrows()}"

            output.push data

    _.each outputs, (output, idx) =>
      @output idx, output
    outputs

