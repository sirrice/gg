"use strict"

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

#<< gg/core/graphic


# makes sure the gg namespace has all the classes defined
_.extend @, gg

# this sets MODULE.gg as the fromSpec method
fromSpec = (spec) -> new gg.core.Graphic spec

# render array of numbers
renderArray = (array, domEl, userSpec={}) ->
  defaultSpec =
    layers: [
      geom: "rect"
    ]
  spec = _.clone defaultSpec
  spec = _.extend spec, userSpec

  rows = _.map array, (v, idx) ->
    { x: idx, y: v }
  console.log rows[0..15]
  plot = new gg.core.Graphic spec
  plot.render domEl, rows


@gg = fromSpec
_.extend @gg, gg
@gg.renderArray = renderArray
@gg.io = io
@gg.log = gg.util.Log

