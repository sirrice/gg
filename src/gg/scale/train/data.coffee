#<< gg/core/bform

class gg.scale.train.Data extends gg.core.BForm
  parseSpec: ->
    super
    @params.ensureAll
      config: [['scalesConfig'], @spec.scalesConfig]

  # these training methods assume that the tables's attribute names
  # have been mapped to the aesthetic attributes that the scales
  # expect
  compute: (tables, envs, params) ->
    config = params.get 'config'
    fTrain = ([t,e]) =>
      info = @paneInfo t, e
      posMapping = @posMapping info.layer
      scaleset = config.scales info.layer

      @log "trainOnData: cols:    #{t.schema.toSimpleString()}"
      @log "trainOnData: set.id:  #{scaleset.id}"

      scaleset.train t, null, posMapping
      e.put 'scales', scaleset

    _.each _.zip(tables, envs), fTrain
    tables


