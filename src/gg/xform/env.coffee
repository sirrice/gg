#<< gg/wf/node

class gg.xform.EnvPut extends gg.core.XForm
  @ggpackage = "gg.xform.EnvPut"
  @type = "envput"


  parseSpec: ->
    # data is a mapping of key -> val where
    # key:  label name in environment
    # val:  label value or a function with signature
    #       (pt) -> value
    #
    # note: if function, it will be evaluated when the key
    #       is accessed
    super
    @params.ensure 'pairs', [], {}

  compute: (pairtable, params) ->
    md = pairtable.right()
    pairs = params.get 'pairs'
    for k, v of pairs
      md = md.setColVal k, v
    pairtable.right md
    pairtable



