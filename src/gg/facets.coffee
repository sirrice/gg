#<< gg/facet
class gg.Facets
    constructor: () ->

    @fromSpec = (spec, graphic) ->
        # use spec contents to create single or multi-facets
        if spec?
            throw 'Other facets not implemented'
        else
            new gg.SingleFacet graphic


