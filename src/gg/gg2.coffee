###
# @param undef undefined variable
((exports,undef) ->

    _ = exports._
    d3 = exports.d3

    if !_ and !d3 and require?
        d3 = require 'd3'
        _ = require 'underscore'

###


#<< gg/graphic
#<< gg/facets
#<< gg/layer
#<< gg/geom
#<< gg/scale
#<< gg/stats


@_gg = gg
@gg = (spec, opts) -> return _gg.Graphic.fromSpec spec, opts
_.extend @gg, @_gg
_.extend @gg.prototype, @_gg



#)(this)
