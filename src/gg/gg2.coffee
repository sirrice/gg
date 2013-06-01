"use strict"

events = require 'events'
science = require 'science'
# this is a problem because of how node deals with _
_ = require 'underscore'
io = require "socket.io-client"

# Need to do this because underscore is an asshole and sets the exports
# variable if we don't
exports = module.exports = @

#<< gg/util/*
#<< gg/data/table
#<< gg/wf/flow
#<< gg/core/graphic
#<< gg/facet/facet
#<< gg/layer/layers
#<< gg/geom/geom
#<< gg/scale/scales
#<< gg/stat/stat


# makes sure the gg namespace has all the classes defined
_.extend @, gg

# this sets MODULE.gg as the fromSpec method
fromSpec = (spec) -> new gg.core.Graphic spec
@gg = fromSpec
_.extend @gg, gg

