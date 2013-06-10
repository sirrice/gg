#<< gg/core/bform

class gg.scale.train.Data extends gg.core.BForm
  parseSpec: ->
    @config = @spec.scalesConfig# or new gg.scale.Config()
    @scales = @spec.scales
    super

  # these training methods assume that the tables's attribute names
  # have been mapped to the aesthetic attributes that the scales
  # expect
  compute: (tables, envs, node) ->
    fTrain = ([t,e]) =>
      info = @paneInfo t, e
      posMapping = @posMapping info.layer
      scaleset = @config.scales info.layer
      #scales = e.get 'scales'
      #scales = @scales info.facetX, info.facetY, info.layer

      @log "trainOnData: cols:    #{t.schema.toSimpleString()}"
      @log "trainOnData: set.id:  #{scaleset.id}"

      scaleset.train t, null, posMapping
      e.put 'scales', scaleset

    _.each _.zip(tables, envs), fTrain
    tables


