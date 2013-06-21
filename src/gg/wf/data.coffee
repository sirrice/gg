#
# class that encapsulates data passed through the xforms
#
class gg.wf.Data
    constructor: (@table, @env=null) ->
      @env = new gg.wf.Env unless @env?

    clone: -> new gg.wf.Data @table, @env.clone()


    toJSON: -> ""
    @fromJSON: -> throw Error("not implemented")

#
# Data structure to implement a pseuda-monad
#
class gg.wf.Env extends gg.util.Params
  clone: ->
    # compute all the non-JSONable elements
    removedEls =
      svg: _.clone(@rm 'svg')

    _.each _.keys(@data), (key) =>
      if _.isFunction @data[key]
        removedEls[key] = @rm key

    clone = gg.wf.Env.fromJSON @toJSON()
    @merge removedEls
    clone.merge removedEls
    clone



  @fromJSON: (json) ->
    data = _.fromJSON json
    new gg.wf.Env data

