"use strict"
###
# @param undef undefined variable
((exports,undef) ->

    _ = exports._
    d3 = exports.d3

    if !_ and !d3 and require?
        d3 = require 'd3'
        _ = require 'underscore'

###


events = require 'events'
_ = require 'underscore'

# Need to do this because underscore is an asshole and sets the exports variable
# if we don't
exports = module.exports = @


#<< gg/table
#g/graphic
#g/facets
#g/layer
#g/geom
#g/scale
#g/stats


# this sets MODULE._gg = gg
@_gg = gg

# this sets MODULE.gg = gg
# so can do new gg.gg(spec, opts)
# toaster defines gg as the module namec
@gg = (spec, opts) -> return _gg.Graphic.fromSpec spec, opts
_.extend @gg, @_gg
_.extend @gg.prototype, @_gg


#)(this)
