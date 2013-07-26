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
# The inputs data structure is a nested array of gg.wf.Data objects.
#
class gg.wf.Node extends events.EventEmitter
  @ggpackage = "gg.wf.Node"
  @type = "node"
  @id: -> gg.wf.Node::_id += 1
  _id: 0


  constructor: (@spec={}) ->
    @flow = @spec.flow or null
    @inputs = []
    @type = @constructor.type
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
    logname = "#{@constructor.name}: #{@name}-#{@id}"
    @log = gg.util.Log.logger @constructor.ggpackage, logname


    @parseSpec()

  parseSpec: -> null

  # inputs is an array, one for each parent
  setup: (@nParents, @nChildren) ->
    @inputs = _.times @nParents, () -> null

  # not ready until every input slot is filled
  ready: -> _.all @inputs, (input) -> input?
  nReady: -> _.compact(@inputs).length

  setInput: (idx, input) -> @inputs[idx] = input

  # Output a result and call the appropriate handlers using @emit
  # @param outidx output port
  # @param data nested array of gg.wf.Data objects
  output: (outidx, data) ->
    # this block is all debugging code
    listeners = @listeners outidx
    n = listeners.length
    flat = gg.wf.Inputs.flatten(data)[0]
    noutputs = flat.length
    tablesizes = _.map flat, (data) ->
      if data? and data.table?
        data.table.nrows()
      else
        -1
    @log.info "output: port(#{outidx}) ntables: #{noutputs}"
    @log "tablesizes: #{tablesizes}"
    @log data

    @emit outidx, @id, outidx, data
    @emit "output", @id, outidx, data

  pstore: -> gg.prov.PStore.get @flow, @

  # Convenienc method to check if this is a barrier
  isBarrier: -> @type is "barrier"

  #
  # The calling function is responsible for calling ready
  # run() will check if node is ready, but will throw an Error if so
  #
  run: -> throw Error("gg.wf.Node.run not implemented")

  compile: -> [@]




  ###############
  #
  # The following are serialization and deserialization methods
  #
  ###############

  @fromJSON: (json) ->
    klassname = json.klassname
    klass = _.ggklass klassname
    spec =
      name: json.name
      nChildren: json.nChildren
      nParents: json.nParents
      location: json.location
      params: gg.util.Params.fromJSON json.params
    console.log spec
    o = new klass spec
    console.log json
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
      flow: @flow
    o = new @constructor spec
    o.id = @id if keepid
    o

