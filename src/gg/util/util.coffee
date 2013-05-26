#<< gg/util/uniquequeue
#<< gg/util/textsize
#<< gg/util/aesmap

_ = require 'underscore'


class gg.util.Util

  @isValid: (v) ->
    not(_.isNull v or _.isNaN v or _.isUndefined v)

  # @param f returns an array [key, val]
  #        that sets the map's key, value pair
  @list2map: (list, f=((v, idx)->[v,v])) ->
    ret = {}
    _.each list, (v, idx) ->
      pair = f v, idx
      ret[pair[0]] = pair[1]
    ret


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
  isValid: gg.util.Util.isValid
  list2map: gg.util.Util.list2map
  sum: gg.util.Util.sum
  mmin: gg.util.Util.min
  mmax: gg.util.Util.max
  findGood: gg.util.Util.findGood
  findGoodAttr: gg.util.Util.findGoodAttr
  isSubclass: gg.util.Util.isSubclass
  textSize: gg.util.Textsize.textSize
  exSize: gg.util.Textsize.exSize
  fontsize: gg.util.Textsize.fontSize
  subSvg: gg.util.Util.subSvg
  repeat: gg.util.Util.repeat
  mapToFunction: gg.util.Aesmap.mapToFunction
  mappingToFunctions: gg.util.Aesmap.mappingToFunctions




