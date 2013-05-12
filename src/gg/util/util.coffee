#<< gg/util/uniquequeue
#<< gg/util/textsize
#<< gg/util/aesmap

_ = require 'underscore'


class gg.util.Util

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







findGood = gg.util.Util.findGood
findGoodAttr = gg.util.Util.findGoodAttr

_.mixin
  sum: gg.util.Util.sum
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




