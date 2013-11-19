#<< gg/pos/position


class gg.pos.Jitter extends gg.core.XForm
  @ggpackage = "gg.pos.Jitter"
  @aliases = "jitter"

  inputSchema: -> ['x', 'y']

  parseSpec: ->
    super
    scale = _.findGood [@spec.scale, 0.2]
    xScale = _.findGood [@spec.xScale, @spec.x, null]
    yScale = _.findGood [@spec.yScale, @spec.y, null]
    if xScale? or yScale?
      xScale = xScale or 0
      yScale = yScale or 0
    else
      xScale = yScale = scale

    @params.putAll
      xScale: xScale
      yScale: yScale

  compute: (pairtable, params) ->
    table = pairtable.left()
    md = pairtable.right()
    scales = md.any 'scales'
    schema = table.schema
    map = [] 
    Schema = data.Schema

    if schema.type('x') is Schema.numeric
      xRange = scales.scale("x", Schema.unknown).range()
      xScale = (xRange[1] - xRange[0]) * params.get('xScale')
      map.push {
        alias: 'x'
        col: 'x'
        f: (v) -> v + (0.5 - Math.random()) * xScale
      }

    if schema.type('y') is Schema.numeric
      yRange = scales.scale("y", Schema.unknown).range()
      yScale = (yRange[1] - yRange[0]) * params.get('yScale')
      map.push {
        alias: 'y'
        col: 'y'
        f: (v) -> v + (0.5 - Math.random()) * yScale
      }

    table = table.project map, yes
    pairtable.left table
    pairtable


