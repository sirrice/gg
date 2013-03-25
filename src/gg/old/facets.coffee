#<< gg/facet
class gg.old.Facets
    constructor: () ->

    @fromSpec = (spec, graphic) ->
        # use spec contents to create single or multi-facets
        if spec?
            if spec.type is 'wrap'
                throw 'Wrap facets not implemented'
                new gg.WrapFacet graphic, spec
            else
                new gg.GridFacet graphic, spec
        else
            new gg.SingleFacet graphic, {}


