"use strict"

events = require 'events'
_ = require 'underscore'

# Need to do this because underscore is an asshole and sets the exports
# variable if we don't
exports = module.exports = @

#<< gg/util
#<< gg/table
#<< gg/wf/flow
#<< gg/graphic
#<< gg/facet
#<< gg/layer
#<< gg/geom
#<< gg/scale
#<< gg/stat


# makes sure the gg namespace has all the classes defined
_.extend @, gg

# this sets MODULE.gg as the fromSpec method
fromSpec = (spec) -> new gg.Graphic spec
@gg = fromSpec
_.extend @gg, gg

