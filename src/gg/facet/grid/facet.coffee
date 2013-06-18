#<< gg/facet/base/facet


class gg.facet.grid.Facets extends gg.facet.base.Facets
  constructor: ->
    super

    @layout1 = new gg.facet.grid.Layout(
      name: 'facet-layout1'
      params: @layoutParams).compile()
    @layout2 = new gg.facet.grid.Layout(
      name: 'facet-layout2'
      params: @layoutParams).compile()



  renderPanes: ->
    new gg.facet.pane.Svg(
      name: 'render-panes').compile()
