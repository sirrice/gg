#<< gg/wf/barrier

class gg.scale.train.Data extends gg.wf.SyncBarrier
  @ggpackage = "gg.scale.train.Data"

  compute: (pairtable, params) ->
    gg.scale.train.Data.train pairtable, params, @log

  # these training methods assume that the tables's attribute names
  # have been mapped to the aesthetic attributes that the scales
  # expect
  @train: (pairtable, params, log) ->
    log ?= console.log

    pairtable = pairtable.partitionOn ['facet-x', 'facet-y', 'layer']
    partitions = pairtable.partition pairtable.cols
    for [key, p] in partitions
      table = p.left()
      md = p.right()
      md.each (row) ->
        set = row.get 'scales'
        set.train table, row.get('posMapping')

    pairtable = gg.scale.train.Master.train(pairtable, params)
    pairtable

