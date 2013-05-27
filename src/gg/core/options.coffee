
class gg.core.Options

  constructor: (@g, @spec) ->
    @width = _.findGood [@spec.width, @spec.w, 800]
    @height = _.findGood [@spec.height, @spec.h, 600]
    @w = @width
    @h = @height
    @title = _.findGood [@spec.title, null]
    @xaxis = _.findGood [@spec.xaxis, @spec.x, "xaxis"]
    @yaxis = _.findGood [@spec.yaxis, @spec.y, "yaxis"]

