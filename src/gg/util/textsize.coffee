_ = require "underscore"


class gg.util.Textsize
  @log = gg.util.Log.logger "Textsize"
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
      width: gg.util.Textsize._defaultWidth
      w: gg.util.Textsize._defaultWidth
      height: gg.util.Textsize._defaultHeights[fontSize] or 18
      h: gg.util.Textsize._defaultHeights[fontSize] or 18
    }

  # @param text the string to compute size of
  # @param opts css attributes
  # @return {width: [pixels], height: [pixels]}
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
      _.extend div.style, css

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
      log = gg.util.Textsize.log
      log.warn "return defaults.  error: #{error}"
      defaults = gg.util.Textsize.exDefault opts["font-size"]
      defaults.width = defaults.w = defaults.width * text.length
      defaults

  # @param opts css attributes
  # @return {width: [pixels], height: [pixels]}
  @exSize: (opts) ->
    optsJson = JSON.stringify opts
    if optsJson of gg.util.Textsize._exSizeCache
      gg.util.Textsize._exSizeCache[optsJson]
    else
      alphas = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ"
      ret = gg.util.Textsize.textSize alphas, opts

      ret.width = ret.w = ret.w / alphas.length
      gg.util.Textsize._exSizeCache[optsJson] = ret
      ret

  @larger: (div, size) ->
    div.style["font-size"] = "#{size}pt"
    [sw, sh] = [div[0].scrollWidth, div[0].scrollHeight]
    sw > div.clientWidth or sh > div.clientHeight


  # Search for the largest font size (pt) for text to be contained
  # within a bounding box.  Useful for text/label layout
  #
  # @param text the string
  # @param width pixel width of the bounding box
  # @param height pixel height of bounding box
  # @param opts css attributes applied to text
  # @return number
  @fontSize: (text, width, height, opts) ->
    body = document.getElementsByTagName("body")[0]
    div = document.createElement("div")
    css = {
       width: width
       height: height
       position: "absolute"
       color: "white"
       opacity: 0
       top: 0
       left: 0
       "font-family": "arial"
    }
    _.extend css, opts
    _.extend div.style, css

    div.textContent = text
    body.appendChild(div)

    size = 100
    n = 0
    while n < 100
      n += 1
      if gg.util.Textsize.larger div, size
         if size > 50
           size /= 2
         else
           size -= 1
      else
         if gg.util.Textsize.larger div, size + 1
           break
         size += 5

    body.removeChild(div)
    size


