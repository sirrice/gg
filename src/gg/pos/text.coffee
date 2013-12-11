#<< gg/pos/position

class gg.pos.Text extends gg.core.XForm
  @ggpackage = "gg.pos.Text"
  @aliases = ["text"]

  parseSpec: ->
    super
    config = 
      bFast:
        names: 'fast'
        default: no
      innerLoop: 15
      temperature:
        names: ['T', 't', 'temp', 'temperature']
        default: 2.466303  # 1-e^(-1/T) = 2/3

    @params.putAll gg.parse.Parser.extractWithConfig(@spec, config)

  inputSchema: ->
    ['x', 'y', 'text']

  compute: (pairtable, params) ->
    table = pairtable.left()
    md = pairtable.right()

    # box: [[x0, x1], [y0, y1]]
    boxes = table.each (row) ->
      [
        [row.get('x0'), row.get('x1')]
        [row.get('y0'), row.get('y1')]
        [row.get('x0'), row.get('y0')]
      ]

    start = Date.now()
    bFast = params.get 'bFast'
    innerLoop = params.get 'innerLoop'
    temperature = params.get 'temperature'
    boxes = gg.util.layout.Anneal.anneal boxes, temperature, bFast, innerLoop
    @log.debug "got #{boxes.length} boxes from annealing"
    @log.debug "took #{Date.now()-start} ms"

    Schema = data.Schema
    mapping = [
      ['x0', ((x0, x1, y0, y1, x, y, idx) -> boxes[idx][0][0])]
      ['x1', ((x0, x1, y0, y1, x, y, idx) -> boxes[idx][0][1])]
      ['y0', ((x0, x1, y0, y1, x, y, idx) -> boxes[idx][1][0])]
      ['y1', ((x0, x1, y0, y1, x, y, idx) -> boxes[idx][1][1])]
      ['x',  ((x0, x1, y0, y1, x, y, idx) -> boxes[idx][0][0])]
      ['y',  ((x0, x1, y0, y1, x, y, idx) -> boxes[idx][1][0])]
    ]
    mapping = _.map mapping, (map) ->
      {
        alias: map[0]
        f: map[1]
        type: Schema.numeric
        cols: ['x0', 'x1', 'y0', 'y1', 'x', 'y']
      }
    table = table.project mapping, yes
    pairtable.left table
    pairtable



