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
  parseSpec: ->
    super

    @params.ensure 'scaleTrain', [], @g.facets.scales


  compute: (tables, envs, params) ->
    # 0) copy existing scales
    # 1) iterate through each column, compute bounds
    # 2) invert bounds
    # 3) merge bounds with existing scales
    # 4) map tables once to invert using old scales + apply new scales


    fOldScaleSet = ([t, e, info]) =>
      #scaleset = @scales info.facetX, info.facetY, info.layer
      scaleset = e.get 'scales'
      scaleset = scaleset.clone()
      @log "origScaleSet: #{scaleset.toString()}"
      scaleset


    # 1. use old scales to invert column value
    # 2. merge domains into a fresh scaleset
    #    - reset domains of non-ordinal scales
    #    - preserve ordinal scales
    # 3. preserve existing ranges
    fMergeDomain = ([t, e, info, oldscaleset]) =>
      newscaleset = oldscaleset.clone()
      seen = {}
      posMapping = e.get 'posMapping'

      f = (table, oldscale, aes) =>
        return if _.isSubclass oldscale, gg.scale.Identity

        newscale = newscaleset.scale oldscale.aes, oldscale.type
        col = table.getColumn(aes).filter _.isValid

        unless col? and col.length > 0
          @log "mergeDomain: aes #{aes} #{col? and col.length>0}"
          @log "mergeDomain: #{newscale.toString()}"
          return
        if _.isSubclass oldscale, gg.scale.BaseCategorical
          @log "mergeDomain: categorical.  skipping"
          @log "mergeDomain: #{newscale.toString()}"
          return

        # Reset the domain if this is the first time we've seen it
        if newscale.id not of seen
          newscale.resetDomain()
          seen[newscale.id] = yes

        # col has pixel (range) units, so first invert
        range = oldscale.defaultDomain col
        domain = _.map range, (v) ->
          if v? then oldscale.invert v else null
        newscale.mergeDomain domain
        @log "mergeDomain: #{aes}\trange: #{range}"
        @log "mergeDomain: #{aes}\tdomain: #{domain}"
        @log "mergeDomain: #{newscale.toString()}"

      oldscaleset.useScales t, posMapping, f
      e.put 'scales', newscaleset

    fRescale = ([t, e, info, oldScales]) =>
      scaleset = e.get 'scales'
      posMapping = e.get 'posMapping'
      mappingFuncs = {}
      rescale = (table, scale, aes) =>
        oldScale = oldScales.scale aes, scale.type
        g = (v) -> scale.scale oldScale.invert(v)
        mappingFuncs[aes] = g
        @log "rescale: old: #{oldScale.toString()}"
        @log "rescale: new: #{scale.toString()}"


      console.log scaleset.toString()
      scaleset.useScales t, posMapping, rescale
      clone = t.clone()
      clone.map mappingFuncs
      clone.schema = t.schema
      clone

    # 0) setup some variables we'll need
    infos = _.map _.zip(tables, envs), ([t,e]) => @paneInfo t, e
    oldScaleSets = _.map _.zip(tables, envs, infos), fOldScaleSet
    args = _.zip(tables, envs, infos, oldScaleSets)

    # 1) compute new scales
    _.each args, fMergeDomain

    # 2) retrain scales across facets/layers and expand domains
    #    must be done before rescaling!
    gg.scale.train.Master.train tables, envs, params

    # 3} invert data using old scales, then apply new scales
    newTables = _.map args, fRescale

    newTables




