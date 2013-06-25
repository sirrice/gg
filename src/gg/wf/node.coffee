#<< gg/util/*
#<< gg/data/table

try
  events = require 'events'
catch error
  console.log error

#
# Implements a generic processing node that doesn't run
#
#
# ::Specification::
#
# {
#   type: [exec, split, join, barrier, multicast]
#   name: {String}
#   params: Params or Object
# }
#
# :: Compute ::
#
# The @compute function that external users provide are of the following signature:
#
#   (inputs, params) -> table(s)
#
# The inputs data structured is a nested array of gg.wf.Data objects.
#
class gg.wf.Node extends events.EventEmitter
  @ggpackage = "gg.wf.Node"
  @id: -> gg.wf.Node::_id += 1
  _id: 0


  constructor: (@spec={}) ->
    @inputs = []
    @type = "node"
    @id = gg.wf.Node.id()
    @nChildren = @spec.nChildren or 0
    @nParents = @spec.nParents or 0
    @location = @spec.location or "client" # or "server"

    #
    # User specified properties
    #
    @name = @spec.name or "#{@type}-#{@id}"
    @params = new gg.util.Params @spec.params
    @params.ensure "klassname", [], @constructor.ggpackage
    logname = "#{@name}-#{@id}\t#{@constructor.name}"
    @log = gg.util.Log.logger logname, gg.util.Log.WARN

    @parseSpec()

  parseSpec: -> null

  # inputs is an array, one for each parent
  setup: (@nParents, @nChildren) ->
    @inputs = _.times @nParents, () -> null

  # not ready until every input slot is filled
  ready: -> _.all @inputs, (input) -> input?
  nReady: -> _.compact(@inputs).length

  setInput: (idx, input) -> @inputs[idx] = input

  output: (outidx, data) ->
    listeners = @listeners outidx
    n = listeners.length
    @log.warn "output: port(#{outidx}) "
    @emit outidx, @id, outidx, data
    @emit "output", @id, outidx, data

    listeners = _.map(listeners, (l)->l.portidx)


  #
  # The calling function is responsible for calling ready
  # run() will check if node is ready, but will throw an Error if so
  #
  run: -> throw Error("gg.wf.Node.run not implemented")

  compile: -> [@]

  @fromJSON: (json) ->
    klassname = json.klassname
    klass = _.ggklass klassname
    spec =
      name: json.name
      nChildren: json.nChildren
      nParents: json.nParents
      location: json.location
      params: gg.util.Params.fromJSON json.params
    o = new klass spec
    o.id = json.id if json.id?
    o

  # XXX: may lose SVG and other non-clonable parameters!!
  toJSON: ->
    reject = (o) -> o? and (o.ENTITY_NODE? or o.jquery? or o.selectAll?)
    {
      klassname: @constructor.ggpackage
      id: @id
      name: @name
      nChildren: @nChildren
      nParents: @nParents
      location: @location
      params: @params.toJSON(reject)
    }


  clone: (keepid=no) ->
    spec =
      name: @name
      nChildren: @nChildren
      nParents: @nParents
      location: @location
      params: @params.clone()
    o = new @constructor spec
    o.id = @id if keepid
    o

