#<< gg/pos/position


class gg.pos.Jitter extends gg.core.XForm
  @ggpackage = "gg.pos.Jitter"
  @aliases = "jitter"

  inputSchema: -> ['x', 'y']

  parseSpec: ->
    super
    config = 
      scale: 0.2
      xScale: 
        name: ['x', 'scale']
        default: null
        f: (v) -> v or 0
      yScale:
        name: ['y', 'scale']
        default: null
        f: (v) -> v or 0

    @params.putAll gg.parse.Parser.extractWithConfig(@spec, config)

  compute: (pairtable, params) ->
    table = pairtable.left()
    md = pairtable.right()
    scales = md.any 'scales'
    schema = table.schema
    xcols = _.filter gg.scale.Scale.xs, (col) -> table.has col
    ycols = _.filter gg.scale.Scale.ys, (col) -> table.has col
    map = [] 
    Schema = data.Schema

    xRange = scales.scale("x").range()
    xScale = (xRange[1] - xRange[0]) * params.get('xScale')
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

    yRange = scales.scale("y").range()
    yScale = (yRange[1] - yRange[0]) * params.get('yScale')
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


