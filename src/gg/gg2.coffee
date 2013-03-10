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
#<< gg/wf/flow
#<< gg/graphic
#<< gg/facets
#<< gg/layer
#<< gg/geom
#<< gg/scale
#<< gg/stats


# makes sure the gg namespace has all the classes defined
_.extend @, gg

# this sets MODULE.gg as the fromSpec method
fromSpec = (spec) -> new gg.Graphic spec
@gg = fromSpec





#)(this)
