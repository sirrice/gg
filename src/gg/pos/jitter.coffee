#<< gg/pos/position


class gg.pos.Jitter extends gg.pos.Position
  @aliases = "jitter"

  inputSchema: -> ['x', 'y']

  parseSpec: ->
    @scale = _.findGood [@spec.scale, 0.2]
    @xScale = _.findGood [@spec.xScale, @spec.x, null]
    @yScale = _.findGood [@spec.yScale, @spec.y, null]
    if @xScale? or @yScale?
      @xScale = @xScale or 0
      @yScale = @yScale or 0
    else
      @xScale = @yScale = @scale
    super

  compute: (table, env) ->
    scales = @scales table, env
    schema = table.schema
    map = {}
    Schema = gg.data.Schema

    if schema.type('x') is Schema.numeric
      xRange = scales.scale("x", Schema.numeric).range()
      xScale = (xRange[1] - xRange[0]) * @xScale
      map['x'] = (v) -> v + (0.5 - Math.random()) * xScale

    if schema.type('y') is Schema.numeric
      yRange = scales.scale("y", Schema.numeric).range()
      yScale = (yRange[1] - yRange[0]) * @yScale
      map['y'] = (v) -> v + (0.5 - Math.random()) * yScale

    table.map map
    table


