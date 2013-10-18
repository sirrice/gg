#<< gg/core/bform

class gg.scale.train.Data extends gg.core.BForm
  @ggpackage = "gg.scale.train.Data"

  parseSpec: ->
    super

  compute: (pairtable, params) ->
    gg.scale.train.Data.train pairtable, params, @log

  # these training methods assume that the tables's attribute names
  # have been mapped to the aesthetic attributes that the scales
  # expect
  @train: (pairtable, params, log) ->
    log ?= console.log
    pairtable = pairtable.ensure pairtable.sharedCols()
    pairtable = gg.core.FormUtil.ensureScales pairtable, params, log
    partitions = pairtable.fullPartition()

    for p in partitions
      table = p.getTable()
      md = p.getMD()
      posMapping = md.get 0, 'posMapping'
      scales = md.get 0, 'scales'

      log "trainOnData: nrows:   #{table.nrows()}"
      log "trainOnData: cols:    #{table.schema.toSimpleString()}"
      log "trainOnData: set.id:  #{scales.id}"
      log "trainOnData: pos:     #{JSON.stringify posMapping}"

      scales.train table, posMapping
      log scales.toString()

    pairtable = new gg.data.TableSet partitions
    pairtable = gg.scale.train.Master.train pairtable, params
    pairtable

