#<< gg/core/xform


#
# group attribute
#
class gg.geom.Render extends gg.core.XForm
  constructor: (@spec={}) ->
    @spec.name = _.findGoodAttr @spec, ['name'], @constructor.name
    super
    @parseSpec()
    @log = gg.util.Log.logger @spec.name


  parseSpec: ->
    super
    @params.put "clientonly", yes

  svg: (table, env, node) -> env.get('svg').pane

  groups: (g, klass, data) ->
    g.selectAll("g.#{klass}")
      .data(data)
      .enter()
      .append('g')
      .classed(klass, true)

  agroup: (g, klass, data) ->
    g.append("g")
      .classed(klass, true)
      .data(data)


  # given a dictionary of attributes, add them to the dom element
  applyAttrs: (domEl, attrs) ->
    _.each attrs, (val, attr) -> domEl.attr attr, val
    domEl

  compute: (table, env, node) ->
    @log "rendering #{table.nrows()} rows"
    gg.wf.Stdout.print table, null, 2, @log
    @render table, env, node
    table

  # @override this
  render: (table) -> throw Error("#{@name}.render() not implemented")

  @klasses: ->
    klasses = [
      gg.geom.svg.Point
      gg.geom.svg.Line
      gg.geom.svg.Rect
      gg.geom.svg.Area
      gg.geom.svg.Boxplot
      gg.geom.svg.Text
    ]
    ret = {}
    _.each klasses, (klass) ->
      if _.isArray klass.aliases
        _.each klass.aliases, (alias) -> ret[alias] = klass
      else
        ret[klass.aliases] = klass
    ret


  @fromSpec: (spec) ->
    klasses = gg.geom.Render.klasses()
    if _.isString spec
      type = spec
      spec = {type: type}
    else
      type = _.findGoodAttr spec, ['geom', 'type', 'shape'], 'point'

    klass = klasses[type] or gg.geom.svg.Point
    gg.util.Log.logger("geom.Render") "Render klass #{type} -> #{klass.name}"
    new klass spec










class gg.geom.GeomRenderPath extends gg.geom.Render
class gg.geom.GeomRenderPolygon extends gg.geom.Render
class gg.geom.GeomRenderGlyph extends gg.geom.Render

