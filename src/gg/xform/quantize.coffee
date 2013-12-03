#<< gg/wf/exec
#<< gg/core/xform

class gg.xform.Quantize extends gg.core.XForm
  @ggpackage = "gg.xform.Quantize"

  parseSpec: ->
    @log @params
    @params.ensureAll
      cols: [[], []]
      nBins: [['nBins', "nbins", "bin", "n", "nbin", "bins"], 20]

    cols = @params.get "cols"
    cols = _.compact _.flatten [cols]
    throw Error "need >0 cols to group on" if cols.length is 0

    # nBins keeps track of the number of distinct values for each
    # gbAttr attribute
    nBins = @params.get "nBins"
    nBins = _.times(cols.length, () -> nBins) if _.isNumber nBins
    unless nBins.length == cols.length
      throw Error "nBins length #{nBins.length} != cols length #{cols.length}"

    @params.put "nBins", nBins
    @log "nBins now #{JSON.stringify nBins}"
    super


  compute: (pairtable, params) ->
    table = pairtable.left()
    md = pairtable.right()
    return pairtable if table.nrows() == 0

    schema = table.schema
    scales = md.any 'scales'
    cols = params.get "cols"
    nBins = params.get "nBins"
    return pairtable unless cols.length > 0
    @log "scales: #{scales.toString()}"
    @log "get mapping functions on #{cols}, #{nBins}"

    mapping = @constructor.getQuantizers(
      cols, schema, nBins, scales
    )
    @log mapping
    table = table.project mapping, yes
    pairtable.left table
    pairtable


  # Create hash functions 
  @getQuantizers: (cols, schema, nBins, scales) ->
    _.map cols, (col, idx) ->
      type = schema.type col
      scale = scales.scale col, type
      domain = scale.domain()
      f = gg.xform.Quantize.quantizer(
        col, type, nBins[idx], domain
      )
      {
        alias: col
        f
        fstr: f.toString()
        type
        cols: col
      }



  # Given a table column and its domain, return hash function
  # that maps value in the domain to a bucket index
  @quantizer: (col, type, nbins, domain) ->
    toKey = _.identity
    if nbins == -1
      type = data.Schema.ordinal

    switch type
      when data.Schema.ordinal
        toKey = _.identity

      when data.Schema.numeric
        [minD, maxD] = [domain[0], domain[1]]
        binRange = (maxD - minD) * 1.0
        binSize = binRange / nbins
        toKey = (v) -> 
          idx = Math.ceil((v-minD) / binSize - 1)
          idx = Math.max(0, idx)
          ret = (idx * binSize) + minD + (binSize / 2)
          console.log "#{v} --> #{ret}"
          ret

      when data.Schema.date
        domain = [domain[0].getTime(), domain[1].getTime()]
        [minD, maxD] = [domain[0], domain[1]]
        binRange = (maxD - minD) * 1.0
        binSize = (binRange / nbins)
        toKey = (v) ->
          time = v.getTime()
          idx = Math.ceil((time-minD) / binSize - 1)
          idx = Math.max(0, idx)
          date = (Math.ceil(idx * binSize) + minD + binSize/2)
          new Date date

      else
        throw Error("I don't support binning on col type: #{type}")

    toKey



