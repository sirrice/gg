# @param undef undefined variable
_myfunc = (exports,undef) ->

    _ = exports._
    d3 = exports.d3

    if !_ and !d3 and require?
        d3 = require 'd3'
        _ = require 'underscore'



    #<< gg/graphic.coffee
    #<< gg/facets.coffee
    #<< gg/layer.coffee
    #<< gg/geom
    #<< gg/scale
    #<< gg/stats



    exports.gg = (spec, opts) -> return gg.Graphic.fromSpec spec, opts




_myfunc(this)
