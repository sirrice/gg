#<< gg/core/xform
#<< gg/data/schema

class gg.geom.reparam.Text extends gg.core.XForm
  constructor: (@g, @spec) ->
    super
    @parseSpec()

  defaults: ->
    group: "1"

  inputSchema: ->
    ['x', 'y', 'text']

  outputSchema: (table, env) ->
    numeric = gg.data.Schema.numeric
    gg.data.Schema.fromSpec
      group: table.schema.typeObj "group"
      x: numeric
      x0: numeric
      x1: numeric
      y: numeric
      y0: numeric
      y1: numeric
      text: gg.data.Schema.ordinal

  compute: (table, env, node) ->
    gg.wf.Stdout.print table, null, 5, gg.util.Log.logger("text")
    attrs = ['x', 'y', 'text']
    inArr = _.map attrs, ((attr)->table.schema.inArray attr)
    unless _.all(inArr) or not (_.any inArr)
      throw Error("attributes must all be in arrays or all not")

    table = table.clone()

    if table.schema.inArray 'x'
      throw Error("don't support labels for within arrays")
      table.each (row) ->
        texts = row.get 'text'
        sizes = _.map texts, _.textSize

        xs = row.get 'x'
        ys = row.get 'y'
        r
        # XXX: retrieve text CSS for proper sizing
        size = _.textSize row.get('Text')
        [w,h] = [size.w, size.h]
        [w,h]

    table.each (row) ->
      x = row.get 'x'
      y = row.get 'y'
      size = _.textSize row.get("text")
      row.set "x0", x
      row.set "x1", x+size.w
      row.set "y0", y
      row.set "y1", y+size.h

    table


