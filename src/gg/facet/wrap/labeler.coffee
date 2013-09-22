#<< gg/core/bform

#
# * Adds facetid to the environment for the data element
# * Collects all of the xy values and adds to each env
#
# This needs to be a barrier because some layers may not have
# facet data that other layers have because different layers _could_
# have different data sources!
#
# Also because it adds Data objects to the full @inputs object
class gg.facet.wrap.Labeler extends gg.core.BForm
  @ggpackage = "gg.facet.wrap.Labeler"

  compute: (datas, params) ->
    Facets = gg.facet.base.Facets
    getXFacet = (data) -> data.env.get Facets.facetXKey
    getYFacet = (data) -> data.env.get Facets.facetYKey

    xs = _.uniq _.map datas, getXFacet
    ys = _.uniq _.map datas, getYFacet
    xys = _.cross xs, ys
    @log "xs: #{JSON.stringify xs}"
    @log "ys: #{JSON.stringify ys}"

    _.each datas, (data, idx) ->
      data.env.put Facets.facetXYKeys, xys
      data.env.put Facets.facetId, "facet-#{idx}"
    datas


