#<< gg/wf/node

class gg.xform.EnvPut extends gg.core.XForm
  @ggpackage = "gg.xform.EnvPut"
  @type = "envput"


  parseSpec: ->
    # data is a mapping of key -> val where
    # key:  label name in environment
    # val:  label value or a function with signature
    #       (data) -> value
    #
    # note: if function, it will be evaluated when the key
    #       is accessed
    super
    @params.ensure 'pairs', [], {}

  compute: (pairtable, params) ->
    md = pairtable.getMD()
    pairs = params.get 'pairs'
    mapping = _.o2map pairs, (v, k) ->
      [k, () -> v]
    md = gg.data.Transform.mapCols md,
      mapping
    ret = new gg.data.PairTable pairtable.getTable(), md
    ret



