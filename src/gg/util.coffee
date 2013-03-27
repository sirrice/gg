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

findGood = (list) ->
    ret = _.find list, (v)->v != null and v?
    if typeof ret is "undefined"
        if list.length then _.last(list) else undefined
    else
        ret

isSubclass = (instance, partype) ->
    c = instance
    while c?
        if c.constructor.name is partype.name
            return yes
        unless c.constructor.__super__?
            return no
        c = c.constructor.__super__

exSize = (() ->
  cache = {}
  _f = (pt=12) ->
    if pt of cache
      cache["#{pt}"]
    else
      try
        alphas = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ"
        body = document.getElementsByTagName("body")[0]
        div = document.createElement("div")
        div.textContent = alphas
        size = if _.isNumber(pt) then "#{pt}pt" else pt
        css =
          display: "none"
          "font-size": size
          padding: "none"
          margin: "none"
        _.each css,  (v,k) -> div.style[k] = v
        body.appendChild(div)
        width = div.clientWidth / alphas.length
        height = div.clientHeight
        width = 12 if width is 0
        height = 12 if height is 0

        if _.any [width, height], _.isNaN
          throw Error("exSize: width(#{width}), height(#{height})")

        {
          width: width
          height: height
          w: width
          h: height
        }
      catch error
        {
          width: 20
          height: 20
          w: 20
          h: 20
        }
  _f
)()

# search for the optimal size for text to be contained within
# a bounding box.  Useful for text/label layout
fontSize = (() ->
  larger = (div, size) ->
    div.style["font-size"] = "#{size}pt"
    [sw, sh] = [div[0].scrollWidth, div[0].scrollHeight]
    sw > div.clientWidth or sh > div.clientHeight


  f = (text, width, height, font="arial") ->
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
      if larger div, size
         if size > 50
           size /= 2
         else
           size -= 1
      else
         if larger div, size + 1
           break
         size += 5

    body.removeChild(div)
    size
  f
)()

subSvg = (svg, opts, tag="g") ->
  el = svg.append(tag)
  left = findGood [opts.left, 0]
  top = findGood [opts.top, 0]
  el.attr("transform", "translate(#{left},#{top})")
  _.each opts, (val, attr) ->
    el.attr(attr, val) unless attr in ['left', 'top']
  el

repeat = (n, val) -> _.times(n, (->val))


_.mixin
  findGood: findGood
  isSubclass: isSubclass
  cross: @cross
  exSize: exSize
  fontsize: fontSize
  subSvg: subSvg
  repeat: repeat




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

