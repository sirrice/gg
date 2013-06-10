
class gg.core.Options

  constructor: (@spec) ->
    @width = _.findGood [@spec.width, @spec.w, 800]
    @height = _.findGood [@spec.height, @spec.h, 600]
    @w = @width
    @h = @height

    # Graphic Title
    @title = _.findGood [@spec.title, null]

    # X and y axis labels
    @xaxis = _.findGood [@spec.xaxis, @spec.x, "xaxis"]
    @yaxis = _.findGood [@spec.yaxis, @spec.y, "yaxis"]

    # Hide all facets, titles and axes?
    @minimal = _.findGood [@spec.minimal, false]

  clone: ->
    new gg.core.Options _.clone(@spec)
