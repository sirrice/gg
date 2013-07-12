#<< gg/core/bform

# This needs to be a barrier because some layers may not have
# facet data that other layers have because different layers _could_
# have different data sources!
#
# Also because it adds Data objects to the full @inputs object
class gg.facet.grid.Labeler extends gg.core.BForm
  @ggpackage = "gg.facet.grid.Labeler"

  compute: (datas, params) ->
    Facets = gg.facet.base.Facets
    getXFacet = (data) -> data.env.get Facets.facetXKey
    getYFacet = (data) -> data.env.get Facets.facetYKey

    xs = _.uniq _.map datas, getXFacet
    ys = _.uniq _.map datas, getYFacet
    xys = _.cross xs, ys
    @log "xs: #{JSON.stringify xs}"
    @log "ys: #{JSON.stringify ys}"

    for data in datas
      data.env.put Facets.facetXYKeys, xys
    datas


