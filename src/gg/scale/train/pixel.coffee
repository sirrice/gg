#<< gg/core/bform

# Train on a table that has been mapped to aesthetic domain.
#
# This is tricky because the table has lost the original
# data types e.g., numerical values mapped to color strings
# - invert the table using scales retrieved with original table's
#   data types
#   - only invert data columns that have been mapped
#     (how to detect this?)
#   - only invert columns that were _originally_ numerical
#     because they are the only scales that could expand
#   - what about derived values? (e.g., width)
# - reset the domains of the scales
# - train scales now that tables are in original domain
#
# Need to invert the aesthetic columns to be in the value domain
# before training
#
#
class gg.scale.train.Pixel extends gg.core.BForm
  @ggpackage = "gg.scale.train.Pixel"


  compute: (datas, params) ->
    # 0) copy existing scales
    # 1) iterate through each column, compute bounds
    # 2) invert bounds
    # 3) merge bounds with existing scales
    # 4) map tables once to invert using old scales + apply new scales

    Schema = gg.data.Schema
    fOldScaleSet = ([t, e], idx) =>
      scaleset = e.get 'scales'
      scaleset = scaleset.clone()
      @log "#{idx} origScaleSet: #{scaleset.toString()}"
      scaleset


    # 1. use old scales to invert column value
    # 2. merge domains into a fresh scaleset
    #    - reset domains of non-ordinal scales
    #    - preserve ordinal scales
    # 3. preserve existing ranges
    fMergeDomain = ([t, e, oldscaleset], idx) =>
      newscaleset = oldscaleset.clone()
      seen = {}
      posMapping = e.get 'posMapping'
      @log "#{idx} posMapping: #{JSON.stringify posMapping}"

      f = (table, oldscale, aes) =>
        return if _.isSubclass oldscale, gg.scale.Identity

        @log "#{idx} retrive #{aes}: #{oldscale.aes}\t#{oldscale.type}"

        if newscaleset.contains oldscale.aes
          newscale = newscaleset.scale oldscale.aes, Schema.unknown
        else
          newscale = oldscale.clone()
          newscaleset.scale newscale
        col = table.getColumn(aes).filter _.isValid

        unless col? and col.length > 0
          @log "#{idx} mergeDomain: aes #{aes} #{col? and col.length>0}"
          @log "#{idx} mergeDomain: #{newscale.toString()}"
          return
        if _.isSubclass oldscale, gg.scale.BaseCategorical
          @log "#{idx} mergeDomain: categorical.  skipping"
          @log "#{idx} mergeDomain: #{newscale.toString()}"
          return

        # Reset the domain if this is the first time we've seen it
        if newscale.id not of seen
          newscale.resetDomain()
          seen[newscale.id] = yes

        # col has pixel (range) units, so first invert
        @log "#{idx} oldScale: #{oldscale.toString()}"
        range = oldscale.defaultDomain col
        domain = _.map range, (v) ->
          if v? then oldscale.invert v else null
        newscale.mergeDomain domain
        @log "#{idx} mergeDomain: #{aes}\trange: #{range}"
        @log "#{idx} mergeDomain: #{aes}\tdomain: #{domain}"
        @log "#{idx} mergeDomain: #{newscale.toString()}"

      oldscaleset.useScales t, posMapping, f
      e.put 'scales', newscaleset

    fRescale = ([t, e, oldScales], idx ) =>
      @log "#{idx} fRescale called layer: #{e.get "layer"}"
      scaleset = e.get 'scales'
      posMapping = e.get 'posMapping'
      mappingFuncs = {}
      rescale = (table, scale, aes) =>
        return if scale.type == Schema.ordinal
        oldScale = oldScales.scale aes, Schema.unknown, posMapping
        g = (v) -> scale.scale oldScale.invert(v)
        mappingFuncs[aes] = g
        @log "#{idx} rescale: old: #{oldScale.toString()}"
        @log "#{idx} rescale: new: #{scale.toString()}"

      scaleset.useScales t, posMapping, rescale
      @log "#{idx} #{scaleset.toString()}"
      t.map mappingFuncs
      t

    # 0) setup some variables we'll need
    tables = _.map datas, (d) -> d.table
    envs = _.map datas, (d) -> d.env
    oldScaleSets = _.map _.zip(tables, envs), fOldScaleSet
    args = _.zip(tables, envs, oldScaleSets)

    # 1) compute new scales
    _.each args, fMergeDomain

    # 2) retrain scales across facets/layers and expand domains
    #    must be done before rescaling!
    gg.scale.train.Master.train datas, params

    # 3} invert data using old scales, then apply new scales
    newTables = _.map args, fRescale

    _.times newTables.length, (idx) ->
      datas[idx].table = newTables[idx]
    datas




