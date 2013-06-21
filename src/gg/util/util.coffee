#<< gg/util/uniquequeue
#<< gg/util/textsize
#<< gg/util/aesmap

_ = require 'underscore'


class gg.util.Util
  @toJSON: (o, path=[]) ->
    if path.length >= 25
      console.log o
      throw Error("Max stack #{path} hit")
    if o? and 'ggpackage' of o.constructor
      ret = { type: 'gg', ggpackage: o.constructor.ggpackage }
      ret.val = o.toJSON()
    else if _.isFunction o
      # functions are expected to be pure and not use context
      ret = { type: "function", val: null, props: {} }
      ret.val = o.toString()
      _.each _.keys(o), (k) ->
        path.push k
        ret.props[k] = gg.util.Util.toJSON(o[k], path)
        path.pop()
    else if _.isArray o
      ret = { type: "array", val: [], props: {} }
      _.each o, (v, idx) ->
        path.push idx
        ret.val.push gg.util.Util.toJSON(v, path)
        path.pop()
      _.each _.reject(_.keys(o), _.isNumber), (k) ->
        path.push k
        ret.props[k] = gg.util.Util.toJSON(o[k], path)
        path.pop()
    else if _.isObject o
      ret = { type: "object", val: {} }
      _.each o, (v,k) ->
        path.push k
        ret.val[k] = gg.util.Util.toJSON(v, path)
        path.pop()
    else
      ret = { type: 'primitive', val: o }
    ret

  @fromJSON: (json) ->
    type = json.type
    switch json.type
      when 'gg'
        klass = _.ggklass json.ggpackage
        klass.fromJSON json.val
      when 'array'
        ret = []
        _.each json.val, (v) ->
          ret.push gg.util.Util.fromJSON(v)
        _.each json.props, (vjson, k) ->
          ret[k] = gg.util.Util.fromJSON(vjson)
        ret
      when 'object'
        ret = {}
        _.each json.val, (v, k) ->
          ret[k] = gg.util.Util.fromJSON(v)
        ret
      when 'function'
        ret = Function("return (#{json.val})")()
        _.each json.props, (vjson, k) ->
          ret[k] = gg.util.Util.fromJSON(vjson)
        ret
      else
        json.val



  @ggklass: (ggpackage) ->
    cmd = "return ('gg' in window)? window.#{ggpackage} : #{ggpackage}"
    Function(cmd)()

  @isValid: (v) -> not(_.isNull(v) or _.isNaN(v) or _.isUndefined(v))

  # @param f returns an array [key, val]
  #        that sets the map's key, value pair
  @o2map: (o, f=((v, idx)->[v,v])) ->
    ret = {}
    _.each o, (args...) ->
      pair = f args...
      ret[pair[0]] = pair[1]
    ret

  @list2map: (args...) -> @o2map args...

  @sum: (arr) -> _.reduce arr, ((a,b) -> a+b), 0

  @findGood: (list) ->
    ret = _.find list, (v)->v != null and v?
    if typeof ret is "undefined"
        if list.length then _.last(list) else undefined
    else
        ret

  @findGoodAttr: (obj, attrs, defaultVal=null) ->
    unless obj?
      return defaultVal
    attr = _.find attrs, (attr) -> obj[attr] != null and obj[attr]?
    if typeof attr is "undefined" then defaultVal else obj[attr]

  @isSubclass: (instance, partype) ->
      c = instance
      while c?
          if c.constructor.name is partype.name
              return yes
          unless c.constructor.__super__?
              return no
          c = c.constructor.__super__

  @isType: (args...) -> @isSubclass args...

  @subSvg: (svg, opts, tag="g") ->
    el = svg.append(tag)
    left = findGood [opts.left, 0]
    top = findGood [opts.top, 0]
    el.attr("transform", "translate(#{left},#{top})")
    _.each opts, (val, attr) ->
      el.attr(attr, val) unless attr in ['left', 'top']
    el

  @repeat: (n, val) -> _.times(n, (->val))

  @min: (arr, f, ctx) ->
    arr = _.reject arr, (v) ->
      _.isNaN(v) or _.isNull(v) or _.isUndefined(v)
    _.min arr, f, ctx

  @max: (arr, f, ctx) ->
    arr = _.reject arr, (v) ->
      _.isNaN(v) or _.isNull(v) or _.isUndefined(v)
    _.max arr, f, ctx





findGood = gg.util.Util.findGood
findGoodAttr = gg.util.Util.findGoodAttr

_.mixin
  toJSON: gg.util.Util.toJSON
  fromJSON: gg.util.Util.fromJSON
  ggklass: gg.util.Util.ggklass
  isValid: gg.util.Util.isValid
  list2map: gg.util.Util.list2map
  o2map: gg.util.Util.o2map
  sum: gg.util.Util.sum
  mmin: gg.util.Util.min
  mmax: gg.util.Util.max
  findGood: gg.util.Util.findGood
  findGoodAttr: gg.util.Util.findGoodAttr
  isSubclass: gg.util.Util.isSubclass
  isType: gg.util.Util.isSubclass
  textSize: gg.util.Textsize.textSize
  exSize: gg.util.Textsize.exSize
  fontsize: gg.util.Textsize.fontSize
  subSvg: gg.util.Util.subSvg
  repeat: gg.util.Util.repeat
  mapToFunction: gg.util.Aesmap.mapToFunction
  mappingToFunctions: gg.util.Aesmap.mappingToFunctions




