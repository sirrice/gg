#<< gg/core/bform

# This needs to be a barrier because some layers may not have
# facet data that other layers have because different layers _could_
# have different data sources!
#
# Also because it adds Data objects to the full @inputs object
class gg.facet.grid.Labeler extends gg.core.BForm
  @ggpackage = "gg.facet.grid.Labeler"

  compute: (tables, envs, params) ->
    Facets = gg.facet.base.Facets
    getXFacet = (env) -> env.get Facets.facetXKey
    getYFacet = (env) -> env.get Facets.facetYKey

    xs = _.uniq _.map envs, getXFacet
    ys = _.uniq _.map envs, getYFacet
    xys = _.cross xs, ys

    for env in envs
      env.put Facets.facetXYKeys, xys
    tables


