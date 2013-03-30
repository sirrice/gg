# TODOs

1. in aesthetic mappings, differentiate evaled expressions and string constants

1. render bars

1. FIX THIS
   var __func__ = function(row) {
     var d = row['d'];var r = row['r'];var g = row['g'];var f = row['f'];var t = row['t'];var get = row['get'];var ncols = row['ncols'];var x = row['x'];var y = row['y'];var fill = row['fill'];

     var fill-opacity = row['fill-opacity']; // <----------------- error!
     return 0.6;
   }

1. detect discrete aesthetics and split at the beginning of the workflow
2. Support grouping and propogating mapped aesthetics down the
   workflow

1. allocate panes after computing the axis tick size of y axis to know how much spacing to give

1. name the phases and the operators more consistently and predictably

1. documentation

1. draw facet labels after geometries

1. support tables as columns (for lines)


1. allow aesthetics aliases

  color: "attr2"

  actually compiles to

  fill: "attr2"
  stroke: "attr2"


# DONE

x. fixed problem where scales.scale('x') returns same gg.scale for all layers
x. make stats work
x. make positioning work
x. make sure retraining scales after positioning works
   -> facets set position range in allocatePanes.  need to make sure if
      ranges are set that they will be used in future.
   -> stop overwriting existing scales objects?


