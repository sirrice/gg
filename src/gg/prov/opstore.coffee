#<< gg/prov/pstore


class gg.prov.OPStore extends gg.util.Graph

  constructor: (@flow, @op) ->
    super
    @id (o) -> JSON.stringify "#{@flow.id}-#{@op.id}"

  
  writeSchema: (outAttrs, inAttrs) ->
    for outAttr in outAttrs
      for inAttr in inAttrs
        @connect outAttr, inAttr, "schema"


  writeData: (outpath, inpath) ->
    @connect inpath, outpath, "data"
