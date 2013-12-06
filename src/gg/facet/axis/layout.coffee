_ = require 'underscore'

# find best orientation for the text labels, given 
# - the labels (or all of them if ordinal)
# - container

# x and y axes can each be numeric or ordinal
# numeric can be dealt with easily (pick opt number of ticks)
# ordinal has options (in order):
# - smaller font 
# - rotate
# - substring
# - ignore
#
# such that:
#
# * font >= 8pt
# * < 20% horizontal space for y axis
# * >100px horizontal space for graphic
# * similarly for vertical space
#
# @return container and render options for x and y axes
#
class gg.facet.axis.Layout 

  # @param plot container bound object
  # @param em size of a "typical" character
  # @param scale the gg.scale.scale object
  @layoutYAxis: (c, em, scale, el, opts={}) ->
    maxWidthPerc = opts.maxWidthPerc 
    maxWidthPerc ?= 0.3

    [w, h] = [c.w(), c.h()]
    ret = 
      rotate: no
      formatter: String
      opts: 
        class: 'axis x' 
      nticks: 2
      bound: new gg.util.Bound 0, 0, em.w, h
      nchars: null



    d3scale = scale.d3()
    axis = d3.svg.axis().scale(d3scale).orient('left')
    ret.nticks = Math.ceil h/em.h

    if scale.type in [data.Schema.numeric, data.Schema.date]
      ret.nticks = Math.min(5, ret.nticks)
      ret.formatter = d3.format(',.3g')
      labels = d3scale.ticks ret.nticks

      labels = labels.map ret.formatter
    else
      labels = _.sample d3scale.domain(), ret.nticks
      labels = labels.map ret.formatter

    maxlabel = _.max labels, (label) -> label.length
    size = gg.util.Textsize.textSize maxlabel, ret.opts, el
    ret.bound.x1 = size.width

    maxWidth = w * maxWidthPerc
    if size.width > maxWidth
      ret.bound.x1 = maxWidth
      nchars = Math.floor(maxlabel.length * maxWidth / size.width)
      ret.formatter = (label) -> ret.formatter(label).substr 0, nchars
      ret.nchars = nchars

    ret



  @layoutXAxis: (c, em, scale, el, opts={}) ->
    maxHeightPerc = opts.maxHeightPerc
    maxHeightPerc ?= 0.3
    [w, h] = [c.w(), c.h()]
    ret = 
      rotate: no
      formatter: String
      css: 
        class: 'axis x' 
        padding: '2px'
      nticks: 2
      nchars: null
      bound: new gg.util.Bound 0, 0, w, em.h

    axis = d3.svg.axis().scale(scale.d3()).orient('bottom')
    d3scale = scale.d3()

    if scale.type in [data.Schema.numeric, data.Schema.date]
      formatter = axis.tickFormat or d3scale.tickFormat
      if formatter? and _.isFunction formatter
        formatter = formatter()
      formatter ?= String

      nticks = 2
      for n in [1...10]
        labels = d3scale.ticks(n).map formatter
        sizes = labels.map (label) ->
          gg.util.Textsize.textSize(label, ret.css, el).width
        if d3.sum(sizes) < w
          nticks = n
        else
          break
      
      ret.formatter = formatter
      ret.nticks = nticks

    else
      labels = scale.domain().map String
      longestlabel = _.max labels, (label) -> label.length
      avgchars = d3.mean labels.map((label) -> label.length)
      concated = labels.join ' '
      fontopts = gg.util.Textsize.fit concated, w, em.h, 8, ret.css, el
      ncharsrm = concated.length - fontopts.nchar
      nperlabel = 1.0 * ncharsrm / labels.length 

      ret.css['font-size'] = fontopts['font-size']
      ret.css.font = fontopts.font
      ret.css.size = fontopts.size

      # Cutting is sufficient
      if nperlabel < 5 and nperlabel < avgchars * 0.3
        nchars = fontopts.nchar/labels.length
        ret.formatter = (label) ->
          String(label).substr 0, nchars
        ret.nticks = labels.length
        ret.nchars = nchars


      # rotate this fucker
      else
        longlabels = labels.filter (label) -> label.length >= longestlabel.length * .7
        sizes = longlabels.map (label) -> gg.util.Textsize.textSize(label, ret.css).w
        longestlabel = _.max longlabels, (label, idx) -> sizes[idx]
        longestsize = d3.max sizes

        maxH = h * maxHeightPerc
        axisH = d3.min [maxH, longestsize]
        plotH = h - axisH
        nchars = Math.floor(longestlabel.length * axisH / longestsize)

        ret.rotate = yes
        ret.formatter = (label) -> String(label).substr 0, nchars
        ret.nticks = Math.min labels.length, Math.floor(w / em.w)
        ret.bound = new gg.util.Bound 0, 0, w, axisH
        ret.nchars = nchars

    ret



