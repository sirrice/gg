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
      table = p.left()
      md = p.right()
      if md.has 'posMapping'
        pms = md.all 'posMapping'
      else
        pms = _.times md.nrows(), ()->null
      sets = md.all 'scales'
      uniqs = _.uniq(_.zip(pms, sets), false, ([pm, set]) -> set.id)
      _.each uniqs, ([pm, set]) ->
        set.train table, pm

    pairtable = data.PairTable.union partitions
    pairtable = gg.scale.train.Master.train pairtable, params
    pairtable

