gg notes
==============

ggplot2 strangeness/confusion
-----------------

### Mixture of responsibilites

stat+geom shorthand mixes together

1. stat input columns,
2. stat output columns
3. aesthetics mapping (x=x)

for example:

    ggplot(diamonds) + stat_bin(aes(x=x,y=..x..), geom='point')
    # stat_bin outputs ..x.., ..count.., ..density..
    # aes(x=..x..) is not possible in this format


### stat invisibly replaces dataset with new dataset

This may be less of an issue, but explicit schema transformations are better than implicit

    stat_bin(aes(x))
    # replaces exsiting dataset with a new dataset with attributes
    # x, density, count

### Layers are implicit

stat and geom functions implicitly create layers.  rather create
layers explicitly because it follows the mental model.  The mental model
is:

1. map inputs to statistical function(s) using aes mapping
2. execute statistical functions, which output new schema
3. map new schema to attributes geometry objects
4. figure out layout automatically

### Facets are data only

Would like to facet by

1. statistical/sampling model
2. aesthetic mappings
3. variables

### Customization

Customization is really difficult/confusing.  Would like

1. high level constraints that affect the layout algorithms
2. well defined handles to rendered objects to explicit manipulate them
   or theme them (via CSS)
3. completely separate theming from rendered vis

### Interactivity

1. Single pane interactions (requires handles, objects)
   hover, click, select, zoom
2. Single pane manipulations
   Change geometry, stats, data, filter
3. Multi-pane synchronized interactions
   brush/link


### Objects not self describing

1. should have references to underlying datasets/row

### Combined shape/line type/colors

Currently, can only independently map aesthetic -> shape/line/color.  Want ability to
map aesthetic -> shape x color

    if x -> shape x color:
    x    symbol
    0    green circle
    1    blue circle
    2    green square
    3    blue square




GGplot-JS notes
---------------

### Tough Queries

    ggplot(diamonds) +
    geom_bar(aes(color, carat, group=clarity, fill=clarity, color=clarity),
             position='dodge', stat='identity', ymax=10000) +
    stat_bin(aes(x, group=clarity, color=clarity),
             alpha=0.3,position='jitter', geom='point') +
    facet_grid(cut~., scales='free_y')

1. combination of discrete (geom_bar) and continuous (stat_bin) axes shows
   only first axis is rendered
1. Also shows that rendering continuous on discrete axes ok, but not vice versa.  (weird)
2. faceting shows that the discrete and continuous scales are aligned across
   facets (in fixed scales mode)
2. `geom_bar` shows that dodge requires rejiggering (not sure how) scales
   to plot the tick marks appropriately
3. `stat_bin` shows that statistics are computed after grouping by clarity


### Processing model

Very similar to ggplot2's at a high level, but makes many processes explicit

* Facet partitions data up, and each partition flows through the same set of transformations.
* Statistics and geometries are modeled as xforms, which define a specific input and output data schema.
* Mappers map one data schema into another (replaces the aes() shorthand in ggplot2)
* transformation pipeline is a list of stats/mappings ending at a geom object
* Scales are single variable transformations, trained right before sending data to geom object
* Inputs to scales need to be materialized
* Faceting on models/xforms/variables should (ideally) just prepend to the xform pipeline

Where does interaction come into play?

### User Specifications

spec:

    flow: [ [ {xform:, map: {}, opts…}, …,  {xform, map:{}, opts…}, {geom, map:{}, opts…} ],
            []  ]
    facets: { x: facetFunction | aes | facetList,
              y: facetFunction | aes | facetList,
              type: grid/wrap,
              scales: free/fixed,
              sizing: free/fixed}
    map: { shape: "circle", x: "{r+10}"
    scales
    coordinates
    guides: { guide-1: [color]
    options (themes)

    xforms: statistics, sampling, jitter/positioning


     facetXFunction: (flow) -> flow
     facetFunction: (row) -> string
     facetList: list of models, variable names,
     facetObject: object of [label] -> [model or variable name]


### Components

* **Grid Layout**: plots a set of self-rendering objects in a grid layout, with options to add labels above each cell.
* **Flow**: Replaces ggplot's layer.  Manages a pipeline of xforms, and ensures that mappings are adhered to.  geom is always the sink
* **Mapper*: translation
* **Storage Engine?**: backend to server/datavore/something?
* **Faceter**: partition data, prepend xforms/defaults to each subfacet
* **XForm**: transformations with well defined input/output schemas.  Required vs optional attrs
* **Geom**: well defined input schema, output is an SVG


### Adoption

Need auxilary tools to make system easy to use and configure

* CSS based customization for _most_ things
* Configuration embedded as HTML tags a.la [exhibit](http://simile-widgets.org/exhibit/)
* Direct manipulation of viz
* Easily exportable -- links or self-contained vizes.
* Easily configurable (if recieved an exported viz)
* Drag and drop configuration
* Support many input data formats (gdocs, HTML table, csv, etc)





Old notes
---------------


## Processing flow

1. facet prepares data
    * split data by facets.  pData = a facet's data
    * create pane objects
    - compute nrows, ncols
1. compute per layer pre-rendering
    - setup scales
1. compute for each layer _during rendering_
    - group pData by group attribute
    - stats on each group
    - scale domain and range
      (if there is conflicting x-axis mappings, 1 scale _per layer_!!!)
    - track merged domains for each (continuous scale, ordinal scale, text is separate)
    - select a default scale for each plot, its ticks will be plotted
1. compute scales across panels
    - all y axis scales in same row should be same across the layers
    - all x axis scales in same col should be same across the layers
1. Compute internal geometry schemas
    - turn y, width into y1, y2 etc schema
    - but still keep existing attributes for the scales!!!
1. Reposition geometries
    - update scales to accurately reflect changes
    - Is there a clear API to add positioning?
    - e.g., dodge makes the rendered columns at a single tick wider (by using enclosing containers?)
    - e.g., jitter may be done by adding rand() to the data before sending to scale)


## scales

Multiple levels of scales!

1. default for a geometry/aesthetic
2. default defined by spec.scales
3. default defined by spec.layers[X].scales

Centralize location where scales are defined (scalefactory)

* fromSpec(basespec)
* getScale(aes, panel=X, layer=X)


Multiple instances of scales

1. Each panel.layer has a local scale
2. Each panel decides which X/Y coordinate scale to end up plotting
    3. each layer's scaletype, aesthetic needs to be merged and synchronized
3. Panel scales need to be synchronized
4. Graphic scales for legend (categorical, color, group)

## facet renders containers
    - then calls panes to render themselves
1. pane plots data
    - plot default (first layer) scales
1. layers
    - plot geometries


## Questions

where does themeing, interactions come into play?



## Component Responsibilites

1. Graphic
    * render top level container
    * render title, guides
    * hub to access everything else + convenience accessors
1. Facet
    * instantiate and manage panes
    * layout panes
    * split up datasets
    * provide defaults for scales
    * ensure scales are all consistent (for guides)
    * render pane containers, facet labels
1. Pane
    * contain layers
    * provide default scales
    * train layer scales
    * render axes, plot area
1. Layer
    * split dataset into groups
    * compute stats on each group
    * Update its individual scale
1. Geometry
    * track position selection
    *
1. Position
1. Guides
    * Map aesthetic(s) to legends (1 legend, multiple aesthetics)
    * Track


### User Specifications

spec:

    layers: [ {  geometry:,
               mapping: {
                   x:, y:, group:, color:, text:, show
               }
               statistic: {kind: 'identity', group: function, variable}
               visual attributes (e.g., size, fill, width, etc),
           }]
    facets: { x: facetFunction or aes or facetList,
              y:,
              type: grid/wrap,
              scales: free/fixed,
              sizing: free/fixed}
    scales
    coordinates
    guides: { guide-1: [color]
    options (themes)

    opts
      paddingX, paddingY, padding

     facetFunction: (row) -> string
     facetList: list of models, variable names,
     facetObject: object of [label] -> [model or variable name]

### Misc

      compute statistics
      compute scales
      render
     defaults:
      mapping
      geom: point
      statistic: inteval
      position: none
     scales
       facetid,aes -> scale object
     facets: everything is a grid
       x,y -> singlefacet +
       layer
        mapping
        subset of data
        statistic
        scale from graphic
        coordinate
        position
        theme
        geom (row) -> svg object, w/ units derived from @scale()


Other Libraries
----------------

### Javascript

1. d3
1. [https://github.com/trifacta/vega/wiki/Data-Transforms]Vega.
1. protovis
1. [Polychart](http://polychart.com/js) inspired by grammar of graphics
1. [DVL](https://github.com/vogievetsky/DVL)
1. [Dance](https://github.com/michael/dance)
1. [NVD3](http://novus.github.com/nvd3/) [live examples](http://nvd3.org/livecode/)
1. [chartio]()
1. [graphene](https://github.com/jondot/graphene)
1. [Rickshaw](http://code.shutterstock.com/rickshaw/)
1. [Cubism](http://square.github.com/cubism/)
2. [ggplotjs](http://code.google.com/p/ggplot-js/)  paltry version
1. [flotr]https://code.google.com/p/flotr/

### Other Languages

1. ggplot2 (R )
2. Lattice (R )
3. Graphical Programming Language (SPSS)
4. ViZML
5.


### Commercial competitors

1. [Platfora](http://www.platfora.com/deployment/)
1. Qliktech/tableau/spotfire
1. Splunk


Plots to replicate
------------

* http://blog.uber.com/2012/06/23/uberdata-building-the-perfect-uber-party-city/
* http://blog.uber.com/2012/11/12/uberdata-mapping-a-citys-flow-using-ubers-ridership-data/
* http://mashable.com/2013/04/03/bitcoin-value-plunges/

Questions
------------

1. where to hook in interaction?  click, drag, select, brush, link, change dimensions, zoom
2. where to hook in custom theme?  (at least coloring)
   generate CSS?
   how to support interactivity then?


