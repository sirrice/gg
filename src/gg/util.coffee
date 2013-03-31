_ = require 'underscore'

@cross = (arr1, arr2) ->
    ret = []
    _.map arr1, (a1, i) ->
        _.map arr2, (a2, j) ->
            ret.push { x: a1, y: a2, i:i, j:j }
    ret

@attributeValue = (layer, aes, defaultVal, args...) ->
    if aes of layer.mappings
        (d) -> layer.scaledValue d, aes, args...
    else
        (d) -> defaultVal
@attrVal = @attributeValue

@groupData = (data, groupBy) ->
    if not groupBy? then [data] else _.groupBy data, groupBy

@splitByGroups = (data, group, variable) ->
    groups = {}
    if group
        _.each data, (d) =>
            g = d[group]
            groups[g] = [] if not groups[g]?
            groups[g].push d[variable]
    else
        groups['data'] = _.pluck data, variable
    groups

class gg.Util

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

  @_exSizeCache = {}
  @_defaultWidth = 19.23076923076923
  @_defaultHeights = (->
    defaultHeights = {}
    pixels = [1,4,5,6,7,9,10,12,14,15,17,18,20,22,23,24,27,28,29,31,32,33,36,37,38,40,42,42,44,45,47,49,50,52,55,55,56,59,60,61,64,65,66,68,69,70,72,74,75]
    for fontSize, idx in _.range(1, 50)
      defaultHeights["#{fontSize}pt"] = pixels[idx]
    return defaultHeights
  )()
  @exDefault: (fontSize) ->
    {
      width: gg.Util._defaultWidth
      w: gg.Util._defaultWidth
      height: gg.Util._defaultHeights[fontSize] or 18
      h: gg.Util._defaultHeights[fontSize] or 18
    }

  @textSize: (text, opts) ->
    try
      body = document.getElementsByTagName("body")[0]
      div = document.createElement("span")
      div.textContent = text
      css =
        opacity: 0
        "font-size": "12pt"
        "font-family": "arial"
        padding: 0
        margin: 0
      _.extend css, opts

      _.each css,  (v,k) -> div.style[k] = v

      body.appendChild div
      width = $(div).width()
      height = $(div).height()
      #width = div.clientWidth
      #height = div.clientHeight
      body.removeChild div

      if _.any [width, height], ((v) -> _.isNaN(v) or v is 0)
        throw Error("exSize: width(#{width}), height(#{height})")

      ret = {
        width: width
        height: height
        w: width
        h: height
      }
      ret
    catch error
      console.log "textSize returning defaults because of: #{error}"
      defaults = gg.Util.exDefault opts["font-size"]
      defaults.width = defaults.w = defaults.width * text.length
      defaults

  @exSize: (opts) ->
    optsJson = JSON.stringify opts
    if optsJson of gg.Util._exSizeCache
      gg.Util._exSizeCache[optsJson]
    else
      alphas = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ"
      ret = gg.Util.textSize alphas, opts

      ret.width = ret.w = ret.w / alphas.length
      gg.Util._exSizeCache[optsJson] = ret
      ret

  # search for the optimal size for text to be contained within
  # a bounding box.  Useful for text/label layout
  @larger: (div, size) ->
    div.style["font-size"] = "#{size}pt"
    [sw, sh] = [div[0].scrollWidth, div[0].scrollHeight]
    sw > div.clientWidth or sh > div.clientHeight


  @fontSize: (text, width, height, font="arial") ->
    body = document.getElementsByTagName("body")[0]
    div = document.createElement("div")
    _.extend div.style, {
       width: width
       height: height
       position: "absolute"
       color: "white"
       opacity: 0
       top: 0
       left: 0
       "font-family": font
    }
    div.textContent = text
    body.appendChild(div)

    size = 100
    n = 0
    while n < 100
      n += 1
      if gg.Util.larger div, size
         if size > 50
           size /= 2
         else
           size -= 1
      else
         if gg.Util.larger div, size + 1
           break
         size += 5

    body.removeChild(div)
    size

  @subSvg: (svg, opts, tag="g") ->
    el = svg.append(tag)
    left = findGood [opts.left, 0]
    top = findGood [opts.top, 0]
    el.attr("transform", "translate(#{left},#{top})")
    _.each opts, (val, attr) ->
      el.attr(attr, val) unless attr in ['left', 'top']
    el

  @repeat: (n, val) -> _.times(n, (->val))


findGood = gg.Util.findGood
findGoodAttr = gg.Util.findGoodAttr

_.mixin
  sum: gg.Util.sum
  findGood: gg.Util.findGood
  findGoodAttr: gg.Util.findGoodAttr
  isSubclass: gg.Util.isSubclass
  cross: @cross
  textSize: gg.Util.textSize
  exSize: gg.Util.exSize
  fontsize: gg.Util.fontSize
  subSvg: gg.Util.subSvg
  repeat: gg.Util.repeat




class gg.UniqQueue

    constructor: (args=[]) ->
        @list = []
        @id2item = {}
        _.each args, (item) => @push item


    push: (item) ->
        key = @key item
        unless key of @id2item
            @list.push item
            @id2item[key] = yes
        @

    pop: ->
        if @list.length == 0
            throw Error("list is empty")
        item = @list.shift()
        key = @key item
        delete @id2item[key]
        item

    length: -> @list.length
    empty: -> @length() is 0

    key: (item) ->
        if item?
            if _.isObject item
                if 'id' of item
                    item.id
                else
                    item.toString()
            else
                "" + item
        else
            null

