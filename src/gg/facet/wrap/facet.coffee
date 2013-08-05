#<< gg/facet/base/facet


class gg.facet.wrap.Facets extends gg.facet.base.Facets
  @ggpackage = "gg.facet.grid.Facets"

  constructor: ->
    super

    @layout1 = new gg.facet.wrap.Layout(
      name: 'facet-layout1'
      params: @layoutParams).compile()
    @layout2 = new gg.facet.wrap.Layout(
      name: 'facet-layout2'
      params: @layoutParams).compile()
    @renderpanes = new gg.facet.pane.Svg(
        name: 'render-panes').compile()

  renderPanes: -> @renderpanes

  labelerNodes: ->
    [
      new gg.facet.wrap.Labeler
    ]
