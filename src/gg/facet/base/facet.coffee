#<< gg/util/*

#
# Processing:
# 1) Splits dataset to be processed for different facets
#
# Rendering
# 1) Allocates svg elements for each facet pane and
# 2) Provides API to access them
#
# XXX: in the future, this should be an abstract class that computes
#      offset and sizes of containers, and subclasses should use them
#      to create appropriate SVG/Canvas elements
#
#
# Spec:
#
#   facets: {
#     desc: "x * y + z"
#     (x|y): ???
#     type: grid|wrap,
#     scales: free|fixed,
#     (size|sizing): free|fixed
#     padding
#     class
#   }
#
#   opts {
#     showXAxis
#     showYAxis
#
#   }
#
class gg.facet.base.Facets
  @ggpackage = "gg.facet.base.Facets"
  #@facetXKey = "facet-x"
  #@facetYKey = "facet-y"
  #@facetXYKeys = "facet-xy"
  @facetKeys = "facet-keys"
  @facetId = "facet-id"

  constructor: (@g, @spec={}) ->
    @log = gg.util.Log.logger @ggpackage, "Facets"

    @parseSpec()

    @labeler = @labelerNodes()
    @trainer = new gg.scale.train.Master(
      name: 'facet_train').compile()


    # These should be replaced with _actual_ implementations
    layoutParams = @layoutParams.clone()
    layoutParams.put 'klassname', 'gg.facet.grid.Layout'
    @layout1 = new gg.facet.base.Layout(
      name: 'facet-layout1'
      params: @layoutParams).compile()
    @layout2 = new gg.facet.base.Layout(
      name: 'facet-layout2'
      params: @layoutParams).compile()
    @render = new gg.facet.base.Render(
      name: 'facet-render'
      params: @renderParams).compile()


  parseSpec: ->
    splitConfig = 
      x: null
      y: null
      scales: 'fixed'
      type: 'grid'
      sizing: 'fixed'
      options: @g.options

    layoutConfig =
      showXAxis: 
        names: ['showx']
        default: yes
      showYAxis:
        names: 'showy'
        default: yes
      ncol: null  # only matters for wrap
      nrow: null  # only matters for wrap
      paddingPane: 
        name: 'padding'
        default: 5
      margin: 1
      options: @g.options

    renderConfig = 
      fXLabel:
        names: ['xlabel']
        default: 'x facets'
      fYLabel:
        names: ['ylabel']
        default: 'y facets'
      cssClass: 
        names: ['facetclass', 'class']
        default: ''
      showXTicks: true
      showYTicks: true
      options: @g.options
      location: "client"

    @splitParams = new gg.util.Params(
      gg.parse.Parser.extractWithConfig @spec, splitConfig
    )

    @layoutParams = new gg.util.Params(
      gg.parse.Parser.extractWithConfig @spec, layoutConfig
    )

    @renderParams = new gg.util.Params(
      gg.parse.Parser.extractWithConfig @spec, renderConfig
    )


  labelerNodes: ->
    log = @log

    f = (pairtable, params) ->
      t = pairtable.left()
      md = pairtable.right()
      xcol = params.get 'x'
      ycol = params.get 'y'

      mapping = [
        {
          alias: ['facet-keys', 'facet-id', 'facet-x', 'facet-y']
          f: (xfacet, yfacet) -> 
            'facet-x': xfacet
            'facet-y': yfacet
            'facet-keys': "key-#{xfacet}-#{yfacet}"
            'facet-id': "facet-#{xfacet}-#{yfacet}"
          type: data.Schema.ordinal
          cols: [xcol, ycol]
        }
      ]
      t = t.project mapping, yes

      pairtable.left t
      pairtable = pairtable.ensure ['facet-x' ,'facet-y', 'facet-id', 'facet-keys']
      pairtable

    gg.wf.SyncBarrier.create f, @splitParams, 'facet-labeler'

  @fromSpec: (g, spec) ->
    klass = switch spec.type
      when "grid"
        gg.facet.grid.Facets
      else
        gg.facet.grid.Facets

    new klass g, spec



