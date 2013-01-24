# @param undef undefined variable
_myfunc = (exports,undef) ->

    _ = exports._
    d3 = exports.d3

    if !_ and !d3 and require?
        d3 = require 'd3'
        _ = require 'underscore'



    #<< gg/graphic
    #<< gg/facets
    #<< gg/layer
    #<< gg/geom
    #<< gg/scale
    #<< gg/stats



    exports.gg = (spec, opts) -> return gg.Graphic.fromSpec spec, opts




_myfunc(this)
