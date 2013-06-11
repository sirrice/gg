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
    @params.ensure 'config', [], @spec.scalesConfig


  compute: (tables, envs, params) ->
    # 0) copy existing scales
    # 1) iterate through each column, compute bounds
    # 2) invert bounds
    # 3) merge bounds with existing scales
    # 4) map tables once to invert using old scales + apply new scales

    fAessType = ([t, e, info]) =>
      #scales = @scales info.facetX, info.facetY, info.layer
      scaleset = e.get 'scales'
      posMapping = @posMapping info.layer
      # only table columns that have a corresponding
      # ordinal scale are allowed
      f = (aes) =>
        _.map scaleset.types(aes, posMapping), (type) =>
          unless type is gg.data.Schema.ordinal
            if t.contains aes, type
              @log "aestype: #{aes}-#{type}"
              {aes: aes, type: type}

      _.compact _.flatten _.map t.colNames(), f

    fOldScaleSet = ([t, e, info]) =>
      #scaleset = @scales info.facetX, info.facetY, info.layer
      scaleset = e.get 'scales'
      scaleset = scaleset.clone()
      scaleset


    fMergeDomain = ([t, e, info, aessTypes]) =>
      #scales = @scales info.facetX, info.facetY, info.layer
      scaleset = e.get 'scales'
      posMapping = @posMapping info.layer
      f = (table, scale, aes) =>
        col = table.getColumn(aes)
        col = col.filter _.isValid
        return unless col? and col.length > 0

        # col has pixel (range) units
        range = scale.defaultDomain col
        domain = _.map range, (v) ->
          if v? then scale.invert v else null
        scale.mergeDomain domain
        @log "merge: #{aes}\trange: #{range}"
        @log "merge: #{aes}\tdomain: #{domain}"
        @log "merge: #{scale.toString()}"

      scaleset.useScales t, aessTypes, posMapping, f

    fRescale = ([t, e, info, aessTypes, oldScales]) =>
      #scales = @scales info.facetX, info.facetY, info.layer
      scaleset = e.get 'scales'
      posMapping = @posMapping info.layer
      mappingFuncs = {}
      rescale = (table, scale, aes) =>
        oldScale = oldScales.scale aes, scale.type
        g = (v) -> scale.scale oldScale.invert(v)
        mappingFuncs[aes] = g
        @log "rescale: old: #{oldScale.toString()}"
        @log "rescale: new: #{scale.toString()}"


      scaleset.useScales t, aessTypes, posMapping, rescale
      clone = t.clone()
      clone.map mappingFuncs
      clone.schema = t.schema
      clone

    # 0) setup some variables we'll need
    infos = _.map _.zip(tables, envs), ([t,e]) => @paneInfo t, e
    allAessTypes = _.map _.zip(tables, envs, infos), fAessType
    oldScaleSets = _.map _.zip(tables, envs, infos), fOldScaleSet
    args = _.zip(tables, envs, infos, allAessTypes, oldScaleSets)

    # 1) compute new scales
    _.each args, fMergeDomain

    # 2) retrain scales across facets/layers and expand domains
    #    must be done before rescaling!
    gg.scale.train.Master.train tables, envs, params

    # 3} invert data using old scales, then apply new scales
    newTables = _.map args, fRescale

    newTables




