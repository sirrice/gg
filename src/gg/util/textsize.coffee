_ = require "underscore"


class gg.util.Textsize
  @log = gg.util.Log.logger "gg.util.Textsize", "Textsize"

  @_exSizeCache = {}
  @_defaultWidths = (->
    defaultWidths = {}
    pixels = [0.5576923076923077, 1.6346153846153846, 2.173076923076923, 2.769230769230769, 3.8653846153846154, 4.384615384615385, 4.865384615384615, 6.038461538461538, 6.480769230769231, 7.115384615384615, 8.211538461538462, 8.673076923076923, 9.211538461538462, 10.288461538461538, 10.788461538461538, 11.461538461538462, 12.557692307692308, 12.942307692307692, 13.596153846153847, 14.653846153846153, 15.096153846153847, 15.76923076923077, 16.884615384615383, 17.26923076923077, 17.826923076923077, 19, 19.442307692307693, 20, 21.23076923076923, 21.615384615384617, 22.23076923076923, 23.28846153846154, 23.76923076923077, 24.403846153846153, 25.48076923076923, 25.923076923076923, 26.51923076923077, 27.596153846153847, 28.076923076923077, 28.71153846153846, 29.73076923076923, 30.307692307692307, 30.76923076923077, 32, 32.34615384615385, 32.98076923076923, 34.17307692307692, 34.57692307692308, 35.17307692307692]
    for fontSize, idx in _.range(1, 50)
      defaultWidths["#{fontSize}pt"] = pixels[idx]
    return defaultWidths
  )()
  @_defaultHeights = (->
    defaultHeights = {}
    pixels = [1,4,5,6,7,9,10,12,14,15,17,18,20,22,23,24,27,28,29,31,32,33,36,37,38,40,42,42,44,45,47,49,50,52,55,55,56,59,60,61,64,65,66,68,69,70,72,74,75]
    for fontSize, idx in _.range(1, 50)
      defaultHeights["#{fontSize}pt"] = pixels[idx]
    return defaultHeights
  )()
  @exDefault: (fontSize) ->
    size =
      width: gg.util.Textsize._defaultWidths[fontSize] or 10
      height: gg.util.Textsize._defaultHeights[fontSize] or 18
    size.w = size.width
    size.h = size.height
    size

  # @param text the string to compute size of
  # @param opts css attributes
  # @return {width: [pixels], height: [pixels]}
  @textSize: (text, opts={}) ->
    log = gg.util.Textsize.log
    try
      body = document.getElementsByTagName("body")[0]
      div = document.createElement("span")
      div.textContent = text
      css =
        opacity: 0
        padding: 0
        margin: 0
        position: "absolute"
        left: -10000000
      _.extend css, opts
      $(div).css css
      $(div).attr css

      body.appendChild div
      width = div.clientWidth# $(div).width()
      height = div.clientHeight# $(div).height()
      #body.removeChild div

      log "textsize of #{text}: #{width}x#{height} with #{JSON.stringify opts}"

      if _.any [width, height], ((v) -> _.isNaN(v) or v is 0)
        throw Error("exSize: width(#{width}), height(#{height})")

      ret =
        width: width
        height: height
        w: width
        h: height
      ret
    catch error
      fontsize =
        if 'font-size' of opts
          opts['font-size']
        else
          '12pt'
      defaults = gg.util.Textsize.exDefault fontsize
      log = gg.util.Textsize.log
      log.warn "default textsz: #{text}\t#{defaults.w} x #{defaults.h}.  err: #{error}"
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

  # Checks if div size is greater than bounding box
  # @param div a dom element selection
  # @param size font-size
  # @param dms bounding box
  @larger: (div, size, dims) ->
    div.style['font-size'] = "#{size}pt"
    [sw, sh] = [div.scrollWidth, div.scrollHeight]
    @log "larger: #{size}pt: #{[sw, sh]} vs #{dims.w}, #{dims.h}"
    sw > dims.w or sh > dims.h
    #sw > div[0].clientWidth or sh > div[0].clientHeight


  # Search for the largest font size (pt) for text to be contained
  # within a bounding box.  Useful for text/label layout
  #
  # @param text the string
  # @param width pixel width of the bounding box
  # @param height pixel height of bounding box
  # @param opts css attributes applied to text
  # @return integer of font point size
  @fontSize: (text, width, height, opts) ->
    body = document.getElementsByTagName("body")[0]
    div = document.createElement("div")
    css =
       color: "white"
       "font-family": "arial"
    _.extend css, opts
    _.extend css,
       left: -100000
       position: "absolute"

    $(div)
      .css(css)
      .attr(
        width: width
        height: height)
      .text(text)

    body.appendChild div


    dim = {w: width, h: height}
    size = 100
    n = 0
    while n < 100
      n += 1
      if gg.util.Textsize.larger div, size, dim
         if size > 50
           size /= 2
         else
           size -= 1
      else
         if gg.util.Textsize.larger div, size + 1, dim
           break
         size += 5

    div.remove()
    size

  # allow chopping up the string
  # @
  @fit: (text="", width, height, minfont, opts={}) ->
    optsize = @fontSize text, width, height, opts
    @log "optsize:   #{optsize}"
    @log "minfont:   #{minfont}"
    @log "container: #{width} x #{height}"
    @log "text:      #{text}"
    if optsize < minfont
      opts["font-size"] = "#{minfont}pt"
      dim = @textSize text, opts
      @log "dim:    #{dim.w}"
      nchar = Math.floor(text.length * width / dim.w)
      text = text.substr 0, nchar
      optsize = minfont

    opts["font-size"] = "#{optsize}pt"
    dim = @textSize text, opts

    {
      text: text
      font: optsize
      size: optsize
      w: dim.w
      h: dim.h
    }



