# TODOs

XForms

1. support params/args in xforms
   -> add @param() to xform method list
2. Support grouping and propogating mapped discrete aesthetics down the workflow
1. allow aesthetics aliases
    color: "attr2"
   actually compiles to
    fill: "attr2"
    stroke: "attr2"


Scales

1. support detecting scales types (color scales esp)


Rendering

1. draw facet labels after geometries


Misc

1. name the phases and the operators more consistently and predictably
1. documentation


Tables

1. add types to tables
1. support tables as columns (for lines)

# DONE

x. allocate panes after computing the axis tick size of y axis to know how much spacing to give
x. allow aesthetics with dashes in name (e.g., fill-opacity) in evaled JS scripts
   -> currently var fill-opacity = row['fill-opacity']
x. render bars
x. in aesthetic mappings, differentiate evaled expressions and string constants
   -> evaled expressions are of form: "{ JAVASCRIPT }"
      string values are ""
x. fix instantiating barriers
x. fixed problem where scales.scale('x') returns same gg.scale for all layers
x. make stats work
x. make positioning work
x. make sure retraining scales after positioning works
   -> facets set position range in allocatePanes.  need to make sure if
      ranges are set that they will be used in future.
   -> stop overwriting existing scales objects?


