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
    env = new gg.wf.Env
    _.each @data, (v,k) =>
      if v? and  _.isFunction v.clone
        env.put k, v.clone()
      else if _.isFunction v
        env.put k, v
      else if _.isArray(v) and v.selectAll? # is this d3 selection?
        env.put k, v
      else
        env.put k, _.clone(v)
    env


  @fromJSON: (json) ->
    params = gg.util.Params.fromJSON json
    new gg.wf.Env params

