#<< gg/prov/pstore


class gg.prov.OPStore extends gg.util.Graph

  constructor: (@flow, @op) ->
    super
    @id (o) -> JSON.stringify op

  
  writeSchema: ->
  writeData: (outpath, inpath) ->
    @connect inpath, outpath, "data"
