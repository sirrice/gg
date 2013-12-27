"use strict"

data = require 'ggdata'
prov = require 'ggprov'
ggutil = require 'ggutil'
events = require 'events'
# this is a problem because of how node deals with _
_ = require 'underscore'
io = require 'socket.io-client'
async = require 'async'

# Wrap all the server side node-module includes here
try
  pg = require "pg"
catch err
  pg = null
  # silently eat the error

# Need to do this because underscore is an asshole and sets the
# exports variable if we don't
exports = module.exports = @

#<< gg/parse/*
#<< gg/core/graphic


# makes sure the gg namespace has all the classes defined
_.extend @, gg

# this sets MODULE.gg as the fromSpec method
fromSpec = (spec) -> new gg.core.Graphic spec

@gg = fromSpec
_.extend @gg, gg
@gg.data = data
@gg.io = io
@gg.prov = prov
#@gg.log = gg.util.Log

