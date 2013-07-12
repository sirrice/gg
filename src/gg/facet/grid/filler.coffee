#<< gg/core/xform

#
#
class gg.facet.grid.FillFacets extends gg.wf.Block
  @ggpackage = "gg.facet.grid.FillFacets"

  parseSpec: ->
    @params.ensure "klassname", [], @constructor.ggpackage

  compute:  (datas, params) ->
    Facets = gg.facet.base.Facets
    getXFacet = (env) -> env.get Facets.facetXKey
    getYFacet = (env) -> env.get Facets.facetYKey

    return datas if datas.length == 0

    schemaBase = datas[0].table.schema.clone()
    envBase = datas[0].env.clone()
    xys = envBase.get Facets.facetXYKeys
    xy2data = _.o2map datas, (data) ->
      xy = [getXFacet(data.env), getYFacet(data.env)]
      [JSON.stringify(xy), data]

    @log "xys: #{JSON.stringify xys}"


    # Create a new wf.Data object for facet x, y
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

    filledDatas = _.map xys, ([x,y]) =>
      key = JSON.stringify [x,y]
      data = xy2data[key]
      data = newData x,y unless data?

      data.table.addConstColumn Facets.facetXKey, x
      data.table.addConstColumn Facets.facetYKey, y
      data

    for data in filledDatas
      x = getXFacet data.env
      y = getYFacet data.env
      @log "data #{x} #{y} has #{data.table.nrows()}"

    filledDatas


