#<< gg/core/bform

class gg.scale.train.Data extends gg.core.BForm
  parseSpec: ->
    super

  # these training methods assume that the tables's attribute names
  # have been mapped to the aesthetic attributes that the scales
  # expect
  compute: (tables, envs, params) ->
    fTrain = ([t,e]) =>
      info = @paneInfo t, e
      posMapping = e.get 'posMapping'
      config = e.get 'scalesconfig'
      scaleset = config.scales info.layer

      @log "trainOnData: cols:    #{t.schema.toSimpleString()}"
      @log "trainOnData: set.id:  #{scaleset.id}"
      @log "trainOnData: pos:     #{JSON.stringify posMapping}"


      scaleset.train t, null, posMapping
      e.put 'scales', scaleset

    _.each _.zip(tables, envs), fTrain
    tables


