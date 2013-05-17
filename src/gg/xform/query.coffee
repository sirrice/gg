#<< gg/core/xform


# Generalized SQL-like query operator.
# 99% of the gg operators should be able to compile down to
# a subset of this operator's components (in execution order):
#
# 1) unnest: STRING
#    array attribute that should be unnested
#
# 2) filter: [ (row) -> bool ]
#    array of boolean filter functions
#
# 3) groupby: { attrname: STRING | (row)->value }
#    attribute(s) to group by
#    the groupby attributes are also attached to each row
#
# 4) aggregate: { attrname: (rows) -> value }*
#    compute aggregate
#
# 5) project: { attrname: attr | (row) -> value }
#    project row attributes.
#    can't directly do deep inspection into object or array columns
class gg.xform.Query extends gg.core.XForm
  constructor: (@g, @spec) ->
    super @g, @spec

  @fromSpec: (g, spec) ->
    unnest = spec.unnest
    filter = spec.filter

