
# Container that manages all layout bound info to for a pane.  It encapsulates
# the pane itself, and the four sides, each of which may render a facet or axis.
#
#          xfacet
#          ______
#         |      |
#   yaxis | pane | yFacet
#         |______|
#          xaxis
#

class gg.facet.pane.Container
  @ggpackage = 'gg.facet.pane.Container'

  # @param c pane container in _absolute_ coordinates to the parent container
  #        all container accessors (including for pane) should be done using
  #        method calls, which return bounds relative to upper left corner of
  #        @bound()
  constructor: (
    @c, # container for the inner pane, not the container
    @xidx,
    @yidx,
    @x,
    @y,
    @xFacetH,
    @yFacetW,
    @xAxisH,
    @yAxisW,
    @opts={}) ->

      @padding = @opts.padding or 5

      @lpad = @rpad = @upad = @bpad = 0
      @lpad = @padding unless @yAxisW
      @rpad = @padding unless @yFacetW
      #@bpad = @padding unless @bXAxis
      @upad = @padding unless @xFacetH

  clone: ->
    new gg.facet.pane.Container(
      @c.clone(),
      @xidx,
      @yidx,
      @x,
      @y,
      @xFacetH,
      @yFacetW,
      @xAxisH,
      @yAxisW,
      @opts
    )

  toJSON: ->
    c: _.toJSON @c
    xidx: _.toJSON @xidx
    yidx: _.toJSON @yidx
    x: _.toJSON @x
    y: _.toJSON @y
    xFacetH: @xFacetH
    yFacetW: @yFacetW
    xAxisH: @xAxisH
    yAxisW: @yAxisW

  @fromJSON: (json) ->
    new gg.facet.pane.Container(
      _.fromJSON json.c
      _.fromJSON json.xidx
      _.fromJSON json.yidx
      _.fromJSON json.x
      _.fromJSON json.y
      json.xFacetH
      json.yFacetW
      json.xAxisH
      json.yAxisW
    )

  toString: ->
    JSON.stringify {
      xidx: @xidx
      yidx: @yidx
      c: @c.toString()
    }

  #
  # bounds for the container (pane + facets + axes)
  #
  w: -> @c.w() + @yFacetW + @yAxisW 
  h: -> @c.h() + @xFacetH + @xAxisH 
  top: -> @c.y0 - @xFacetH
  left: -> @c.x0 - @yAxisW
  bound: ->
    new gg.util.Bound @left(), @top(),
      @left() + @w(),
      @top() + @h()


  #
  # The following accessors return Bounds relative to top-left of the container
  #

  drawC: ->
    x0 = @yAxisW + @lpad
    y0 = @xFacetH + @upad
    w = @c.w() - @rpad - @lpad
    h = @c.h() - @bpad - @upad
    new gg.util.Bound x0, y0, x0+w, y0+h


  xFacetC: ->
    x0 = @yAxisW + @lpad
    y0 = 0
    w = @c.w() - @rpad - @lpad
    h = @xFacetH
    new gg.util.Bound x0, y0, x0+w, y0+h

  yFacetC: ->
    x0 = @yAxisW + @c.width()
    y0 = @xFacetH + @upad
    w = @yFacetW
    h = @c.h() - @upad - @bpad
    new gg.util.Bound x0, y0, x0+w, y0+h

  xAxisC: ->
    x0 = @yAxisW + @lpad
    y0 = @c.h() + @xFacetH
    w = @c.w() - @lpad - @rpad
    h = @xAxisH 
    new gg.util.Bound x0, y0, x0+w, y0+h

  yAxisC: ->
    x0 = 0
    y0 = @xFacetH + @upad
    w = @yAxisW
    h = @c.h() - @upad - @bpad
    new gg.util.Bound x0, y0, x0+w, y0+h
