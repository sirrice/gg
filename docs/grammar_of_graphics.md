# gg-js implementation notes

## Background

### Grammar of Graphics (GoG)

Grammar of graphics defines a set of orthogonal components that are involved in producing a graphic.  At a high level, a graphic is created via the following discrete steps:

0. Ingest a dataset
1. Variables: Define variables from dataset (a variable is like a column in a table)
2. Algebra: Use algebraic operators (\* / +) to compute cross products, nesting, and concat variables
3. Scales: Map variables to numerical domain (strings to numbers, apply log transforms etc)
4. Statistics: compute statistics over the data
5. Geom: map statistics to generic geometrical objects
6. Position: modify positioning of geometries (e.g., add jitter to scatter plot points)
6. Coord: transform geometries based on a coordinate system (maps, polar, etc)
7. Aesthetics: add color, texture, and other aesthetic properties
8. Render the graphic (e.g., onto canvas or svg element)

<img src="./imgs/process.png" width=700/>

The purpose of such a grammar is to promote fast data analysis iterations:

- Visualization systems that assume an external process transforms and analyzes the data, and simply preforms rendering does not allow the analyst to e.g., view the same analysis under log transformations
- Wilkinson argues that the Vis system must control the transformation and analysis steps as well.  (note: the data is largely assumed to be clean)


### ggplot2

In the R library ggplot2, graphics are decomposed into the following components:

1. Data: an R data.frame.  Think database table with attribute names, dynamic typing, and tuples.
1. Facets: Define the 2 dimensional faceting to render a grid of subplots
1. Layers: Defines the statistical transformation, aesthetics, and geometry (e.g., line, point, etc) to be rendered in a single "layer"
1. Scales: x, y scales.  Ensures that domain and range of rendered data is consistent across layers and facets.
1. Coordinates: The coordinate system e.g., polar, map, euclidian.

The processing workflow is roughly:

1. Facet definition partitions the data by the facet variables.  
    * Each partition is processed independently and turns into a subplot
2. Scales transform attributes (log transformations)
2. A grouping specification may further split the partition into groups
    * This is so multiple lines can be plot (e.g., one curve for each department in a school) 
3. Statistics (e.g., sum, count, smoothing function) are computed on each of the groups 
    * e.g., total cost for each of the departments
4. Aesthetics map the attributes output from Statistics to geometry parameters (e.g., pressure -> x coordinate)
4. Scales are trained so that the domains of the X and Y axes are consistent.
5. The plot title, subtitle, etc are rendered
8. Facets allocate space for each subplot, and draws the facet labels
5. Scales ranges are mapped to pixel lengths
6. Scales are used to compute geometry parameters (e.g., x,y location, width of rectangle)
7. Coordinates transform geometry parameters into a different coordinate space
8. Geometries are rendered in each subplot
9. Axes are rendered
10. Guides (legends) are rendered

The downside to this model is that the code is difficult to understand and extend.  The data flow is not apparent, and the execution steps are not trivially mappable to the R code specification.


## gg-js

gg-js also uses the concept of layers, which defines how a single geometry type is rendered from the data.  In contrast to ggplot2, a layer's rendering pipeline is explicitly modeled as a workflow.

The rendering jobs are separated into:

1. Rendering title, subtitle, legends
2. Rendering facets, which allocates space for each subplot
1. Rendering geometries in the layers of a subplot (e.g., lines, points)
2. Rendering axes for each subplot

The bulk of the work lies in (4), which needs to transform data, compute statistics, and render geometric objects.  In the process, it also *trains the scales*, meaning it computes the domains and ranges of each aesthetic component (e.g., the domain of the x,y variables), which is necessary to know how to render the axes and legends.  This is implemented with a generic workflow that is compiled from high level specifications.  The workflow is presented next.



### Rendering a Layer (low level)

The observation is that every step in ggplot2's/grammar of graphics' pipeline involves data/schema transformations.  In other words, each step takes as input a structured dataset, and outputs another structured dataset.  The operators are:

* *XForm*: transforms an input table into an output table and have a well-defined input and output schema.  
* Special classes of XForm operators include
    * *Map*: mapping one schema into another schema.  Useful for mapping an output table to an operator's input schema.
    * *Identity*: Transforming one or more columns but keeping the same schema
* *Split*: partitions the dataset by a value of a grouping function.  The rest of the transformations until the paired *Join* operator are duplicated and executed on each partition independently.
* *Join*: Paired with a *Split* operator.  Concats the transformed partitions into a single table, and adds a column that identifies tuples from each partition.  Note: a *split* followed immediately by a *join* does not return an identical table because join adds a column for the partition ids.
* *TrainScales*: Takes the output of all instances of the previous operator, and feeds each transformed dataset to the corresponding instance of the subsequent operator (This will be apparent in the next section)
* *Placeholder*: Wraps around a subset of the workflow to provide it with a name.  Used by facetting to dynamically replace portions of the workflow.  For example, a noop placeholder named "sampler" may be replaces with operators that implement different sampling techniques.  

For example, the following defines a single layer's transformation workflow:

    layer: [ 
        {xform: "log", base: 10, var: "x"}      // outputs same schema as input table
       ,{xform: "trainscales"}                  // train scales
       ,{xform: "applyscales"}                  // apply scale transformations (e.g., log10 transformation)

       // The following are statistical transformations
       ,{xform: "split", on: "a"}               // Computing separate histograms for each value of "a"
       ,{xform: "bin", x: "x", binwidth: 10}    // computes histogram w/bucket size 10
                                                // output schema: [x, binwidth, count]
       ,{xform: "join"}                         // concat outputs of xforms since most recent "split" operation
       
       
       // The following are geometry related transformations
       ,{xform: "trainscales"}                  // train the scales' domains from the transformed data
       ,{xform: "geom-box"}                     // transform data table into {x, width, height} box schema
       ,{xform: "stack"}                        // update 
       ,{xform: "coord-polar"}
       ,{xform: "geom-box-render"}              // Render the boxes
           ]


### Mid-level Architecture

Naturally there are distinct steps and an order to the workflow.  Below is an example of a concrete workflow that generates a faceted graphic consisting of a single layer:

<img src="imgs/mid-level flow.png" width=750/>

* Facets define a grid of subplots, each with a partition of the data (e.g., partition by university).  The workflow is replicated and executed for each partition.  
* While each partition is largely processed independently, there are two points of coordination (Scale1, Scale2) to synchronize the Scales objects.  
* Univariate transforms may modify the values of a single column (e.g., apply a log scale's log transform), or add additional columns to the table.  
* The Stats component computes statistics (e.g., total number of students by department) and may execute an internal workflow (e.g., split by department, then count the students each of the sub-partitions).  
* After the statistics are computed, the schema and data values may have changed (the y axis is a count rather than a column in the original table), so the scales need to be re-trained.  
* Finally, the blue boxes turn the data table into a standardized geometry schema (geom), update the positionings of the geometries (position), transform the coordinates (coord), add color/texture/etc, and finally render the geometries.


#### Univariate Transforms

These include such as defining new columns, scaling columns, filling in null values, etc.  

Schema changes are incremental: 1) no changes 2) adding column 3) renaming column 4) removing column

The key points is that there are two types of scalings:

1. Transform values using functions or math expressions.  For example `log(column)`
2. Transform the values using the Scales.  For example, `x-scale.transform(column)`.  The key difference from `log(column)` is that the transformation is invertable so that labels in pre-transformed units can be rendered.


??? How does the system know which `column` to use in `x-scale.transform(column)`?



#### Scales

Scales map variable values to values of aesthetic attributes (e.g., x, y, color, fill, width, alpha, size) and are responsible for generating labels, axes, and legends.  Although the data in each facet may have different value ranges, so that each subplot and each layer may compute a unique set of scales, users typically expect to see a single consistent legend, and that axes are consistent across subplots.  Thus Scales must be computed across subplots and layers.

Scale1 is used so statistics can be computed consistently for each partition.  For example, so that histogram bucket sizes are the same across subplots.

Scale2 is used because the final aesthetic scales may be defined over summary statistics (e.g., count of students).  Thus the units/value range of the scales need to be re-calibrated.


#### Stats

Compute arbitrary statistics.  The operators may define input and output schema requirements, and *Map* operators may need to be used to map an input table to the required input schema.

#### Geom

Map the statistical summaries into a schema understood by the rest of the components.  The schema includes variants of [x, x0, x1, y, y0, y1, width, height, color, size, fill, alpha, texture, etc].  Each output tuple represents the data to render a single graphical element (point, rectangle, line, etc)

This is likely a wrapper around a dynamically generated *Map* operator. 

#### Position

Reposition geometries in response to overlap.  For example, adding jitter to a scatter plot, or stacking bars in a bar plot.  Another use is to create [dotplots](http://www.cs.uic.edu/~wilkinson/Publications/dots.pdf) -- more informative variants of histograms that render each tuple as a circle, and stack overlapping circles.

The schema does not change.

#### Coordinate Transform

The input schema contains positional columns (e.g., x, y, x0, x1, y1, y2).  These columns are transformed based on the coordinate -- either flipped, transposed, reversed, or polar coordinate.

It's not clear what the schema for supporting polar coordinates looks like

#### Aesthetics

### High-Level Feature Requirements 

#### Facets

* 1D wrap, 2D grid, or nested (to support mosaics p. 343 GoG)
* Pixels allocated to subplots can be equi-sized or varied by value range of subplots' data
* Can facet on different workflow implementations (facet by sampling techniques)
* Can facet on a set of variables (to compare variables)
* Can facet on a partitioning function (to compare different, possibly overlapping, segments of a time series)

#### Scales

Scales are non-trivial because they interact with almost every component.

* Need scales for each layer, subplot, and overall graphic
* Positional scales need to track the correct label and value range (transformations may lose this info)
* Training scales across layers need to support conflicting data types and have sane defaults
* Training across subplots (due to facetting) depends on if subplots are equi-sized or variable sized
* Layer, Subplot, and graphic level scales accessible by all components


#### Labels

Text geometries and axis labels need to support smart layout to avoid overlap.

* Can detect its pixel size
* Can detect overlapping labels
* Understands possible options (move the label, shrink size of text) in response to overlap

