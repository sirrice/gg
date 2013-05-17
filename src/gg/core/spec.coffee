
class gg.core.Spec


  parseAes: (schema, spec) ->
    position = _.pick spec, positionAess
    if 'group' of spec
      group = spec.group
    else
      group = {}
      aess = _.keys spec
      aess = aess.filter (aes) -> not isPosition aes

      _.each aess, (aes) ->
        # provenance query
        cols = schema.getColnames aes
        return unless cols? and cols.length > 0

        if scales.scale(aes).type is gg.data.Schema.ordinal
          group[aes] = spec[aes]

      group


    position['group'] = group


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
#     pos: posspec
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
#     [type: (log,pow,continuous,discrete),]
#     [lim: [min, max],]
#     [domain: [min, max] | [STRING,...],]
#     [range: [min, max] | [STRING,...],]
#     [expand: [mult, add]]
#
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
# There is a single set of scales, but possibly multiple mappings
# during pre and post stats.
# By default, the user specifies the pre stats mapping
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
