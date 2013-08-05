#<< gg/core/bound


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
    @bXFacet,
    @bYFacet,
    @bXAxis,
    @bYAxis,
    @labelHeight,
    @yAxisW,
    @padding=5) ->
      @lpad = @rpad = @upad = @bpad = 0
      @lpad = @padding unless @bYAxis
      @rpad = @padding unless @bYFacet
      @bpad = @padding unless @bXAxis
      @upad = @padding unless @bXFacet

  clone: ->
    gg.facet.pane.Container.fromJSON @toJSON()

  toJSON: ->
    c: _.toJSON @c
    xidx: _.toJSON @xidx
    yidx: _.toJSON @yidx
    x: _.toJSON @x
    y: _.toJSON @y
    bXFacet: @bXFacet
    bYFacet: @bYFacet
    bXAxis: @bXAxis
    bYAxis: @bYAxis
    labelHeight: @labelHeight
    yAxisW: @yAxisW

  @fromJSON: (json) ->
    new gg.facet.pane.Container(
      _.fromJSON json.c
      _.fromJSON json.xidx
      _.fromJSON json.yidx
      _.fromJSON json.x
      _.fromJSON json.y
      json.bXFacet
      json.bYFacet
      json.bXAxis
      json.bYAxis
      json.labelHeight
      json.yAxisW
    )

  toString: ->
    JSON.stringify @toJSON()


  #
  # bounds for the container (pane + facets + axes)
  #
  w: -> @c.w() + @labelHeight * @bYFacet + @yAxisW * @bYAxis
  h: -> @c.h() + @labelHeight * (@bXFacet + @bXAxis)
  top: -> @c.y0 - @labelHeight * @bXFacet
  left: -> @c.x0 - @yAxisW * @bYAxis
  bound: ->
    new gg.core.Bound @left(), @top(),
      @left() + @w(),
      @top() + @h()


  #
  # The following accessors return Bounds relative to top-left of the container
  #

  drawC: ->
    x0 = @yAxisW * @bYAxis + @lpad
    y0 = @labelHeight * @bXFacet + @upad
    w = @c.w() - @rpad - @lpad
    h = @c.h() - @bpad - @upad
    new gg.core.Bound x0, y0, x0+w, y0+h


  xFacetC: ->
    x0 = @yAxisW * @bYAxis + @lpad
    y0 = 0
    w = @c.w() - @rpad - @lpad
    h = @labelHeight * @bXFacet
    new gg.core.Bound x0, y0, x0+w, y0+h

  yFacetC: ->
    x0 = @yAxisW * @bYAxis + @c.width()
    y0 = @labelHeight * @bXFacet + @upad
    w = @labelHeight * @bYFacet
    h = @c.h() - @upad - @bpad
    new gg.core.Bound x0, y0, x0+w, y0+h

  xAxisC: ->
    x0 = @yAxisW * @bYAxis + @lpad
    y0 = @c.h() + @labelHeight*@bXFacet
    w = @c.w() - @lpad - @rpad
    h = @labelHeight * @bXAxis
    new gg.core.Bound x0, y0, x0+w, y0+h

  yAxisC: ->
    x0 = 0
    y0 = @labelHeight * @bXFacet + @upad
    w = @yAxisW * @bYAxis
    h = @c.h() - @upad - @bpad
    new gg.core.Bound x0, y0, x0+w, y0+h
