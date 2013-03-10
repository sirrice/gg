#
#
# This file describes the graphics specification syntax
#
# graphic:
#   {
#     [layerspec,]
#     [facetspec,]
#     [scalespec,]
#     [options,]
#   }
#
# layerspec:
#   layers: [ [(layerspec|layershorthand),]* ]
#
# layerspec:
#   [ [xformspec,]* ]
#
# layershorthand:
#   {
#     geom: STRING,
#     (aes|aesthetic|mapping): aesmapping,
#     (stat|stats|statistic): xformspec
#   }
#
#
# xformspec:
#   {
#     xform: STRING,
#     [arg,]*
#   }
#
# arg: // transformation parameters
#   STRING: STRING | NUMBER | FUNCTION
#
#
# facetspec:
#   facets: {
#     (x|y): ???
#     type: grid|wrap,
#     scales: free|fixed,
#     (size|sizing): free|fixed
#   }
#
# scalespec:
#   scales: {
#     [ aesthetic: scale, ]*
#   }
#
# scale:
#   {
#     [type: STRING,]
#     [lim: [min, max],]
#     [domain: [min, max] | [STRING,...],]
#     [range: [min, max] | [STRING,...],]
#   }
#
# aesthetic: (x|y|color|texture|size|shape|width)
#
# options: // rendering options e.g., paddingX, paddingY, fontsize
#   ???
#
#
#
#
# Here is a single set of scales, but possibly multiple mappings
# during pre and post stats.
# By default, the user specifies the post stats mapping
#






###

0-D

Point: ( x, y, r, x0, x1, y0, y1, [all other variables…] )
1-D

Line: ( (x, y)*, [grouping keys] )
Step: ( (x, y)*, [grouping keys] ) // renders step path
Path: ( (x0, x1, y0, y1)* [grouping keys] )
2-D

Area -> ( (x,y)*, [grouping keys] )
Interval -> ( x, y, width, x0=x, x1=x+width, y0=0, y1=y, [all other variables…] )
Rect -> ( x, w, y, h, x0=x, x1=x+w, y0=y, y1=y+h, [all other variables…] )
Polygon -> ( (x,y)*, [grouping keys] )
difference from line/area is that the polygon is closed
Hex -> ( x, y, r, [all other variables] )
N-D

Schema: ( x, q0, q1, q2, q3, [y]*, [all other variables…] )
Glyph: ( x0, x1, y0, y1, glyphname, [glyph specific variables] )
Glyph can be used to generate symbols
Network

edge: ( v1, v2, [weight], )

###
