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
      xcols = _.filter gg.scale.Scale.xs, (col) -> table.has col
      map.push {
        alias: xcols
        cols: xcols
        f: (args...) -> 
          rand = (0.5 - Math.random()) * xScale
          o = {}
          for col, idx in xcols
            o[col] = args[idx] + rand
          o
      }

    if schema.type('y') is Schema.numeric
      yRange = scales.scale("y", Schema.unknown).range()
      yScale = (yRange[1] - yRange[0]) * params.get('yScale')
      ycols = _.filter gg.scale.Scale.ys, (col) -> table.has col
      map.push {
        alias: ycols
        cols: ycols
        f: (args...) -> 
          rand = (0.5 - Math.random()) * yScale
          o = {}
          for col, idx in ycols
            o[col] = args[idx] + rand
          o
      }

    table = table.project map, yes
    pairtable.left table
    pairtable


