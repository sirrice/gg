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

class gg.facet.pane.Container
  constructor: (
    @c, # container for the inner pane, not the container
    @x,
    @y,
    @bXFacet,
    @bYFacet,
    @bXAxis,
    @bYAxis,
    @labelHeight,
    @yAxisW) ->
      null

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
    x0 = @yAxisC().w()
    y0 = @xFacetC().h()
    new gg.core.Bound x0, y0,
      x0 + @c.w(), y0 + @c.h()


  xFacetC: ->
    new gg.core.Bound @yAxisW * @bYAxis, 0,
      @yAxisW * @bYAxis + @c.w(),
      @labelHeight * @bXFacet

  yFacetC: ->
    x0 = @yAxisW * @bYAxis + @c.width()
    y0 = @labelHeight * @bXFacet
    new gg.core.Bound x0, y0,
      x0 + @labelHeight * @bYFacet,
      y0 + @c.h()


  xAxisC: ->
    x0 = @yAxisW * @bYAxis
    y0 = @c.h() + @labelHeight*@bXFacet
    new gg.core.Bound x0, y0,
      x0 + @c.w(),
      y0 + @labelHeight * @bXAxis

  yAxisC: ->
    new gg.core.Bound 0, @labelHeight * @bXFacet,
      @yAxisW * @bYAxis,
      @labelHeight * @bXFacet + @c.h()
