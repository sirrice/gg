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

  #
  # 0) copy existing scales
  # 1) iterate through each column, compute bounds
  # 2) invert bounds
  # 3) merge bounds with existing scales
  # 4) map tables once to invert using old scales + apply new scales
  #
  compute: (pairtable, params) ->

    log = @log
    fOldScales = (pt, idx) ->
      s = pt.getMD().get(0, 'scales').clone()
      log "#{idx} origScales: #{s.toString()}"
      s

    # 0) setup some variables we'll need
    partitions = pairtable.fullPartition()
    oldScaleSets = _.map partitions, fOldScales
    args = _.zip(partitions, oldScaleSets)

    # 1) compute new scales
    fMergeDomain = @constructor.createMergeDomain @log
    partitions = _.map args, fMergeDomain
    tset = new gg.data.TableSet partitions

    # 2) retrain scales across facets/layers and expand domains
    #    must be done before rescaling!
    tset = gg.scale.train.Master.train tset, params
    partitions = tset.fullPartition()
    args = _.zip(partitions, oldScaleSets)

    # 3} invert data using old scales, then apply new scales
    fRescale = @constructor.createRescale @log
    partitions = _.map args, fRescale

    new gg.data.TableSet partitions



    # 1. use old scales to invert column value
    # 2. merge domains into a fresh scaleset
    #    - reset domains of non-ordinal scales
    #    - preserve ordinal scales
    # 3. preserve existing ranges
  @createMergeDomain: (log) ->
    Schema = gg.data.Schema
    ([pt, oldscaleset], idx) ->
      t = pt.getTable()
      md = pt.getMD()
      posMapping = md.get 0, 'posMapping'
      newscaleset = oldscaleset.clone()
      seen = {}

      f = (table, oldscale, aes) ->
        return table if _.isSubclass oldscale, gg.scale.Identity

        log "#{idx} retrive #{aes}: #{oldscale.aes}\t#{oldscale.type}"

        if newscaleset.contains oldscale.aes
          newscale = newscaleset.scale oldscale.aes, Schema.unknown
        else
          newscale = oldscale.clone()
          newscaleset.scale newscale
        col = table.getColumn(aes).filter _.isValid

        unless col? and col.length > 0
          log "#{idx} mergeDomain: aes #{aes} #{col? and col.length>0}"
          log "#{idx} mergeDomain: #{newscale.toString()}"
          return table
        if _.isSubclass oldscale, gg.scale.BaseCategorical
          log "#{idx} mergeDomain: categorical.  skipping"
          log "#{idx} mergeDomain: #{newscale.toString()}"
          return table

        # Reset the domain if this is the first time we've seen it
        if newscale.id not of seen
          newscale.resetDomain()
          seen[newscale.id] = yes

        # col has pixel (range) units, so first invert
        log "#{idx} oldScale: #{oldscale.toString()}"
        range = oldscale.defaultDomain col
        domain = _.map range, (v) ->
          if v? then oldscale.invert v else null
        newscale.mergeDomain domain
        log "#{idx} mergeDomain: #{aes}\trange: #{range}"
        log "#{idx} mergeDomain: #{aes}\tdomain: #{domain}"
        log "#{idx} mergeDomain: #{newscale.toString()}"
        table

      t = oldscaleset.useScales t, posMapping, f
      md = gg.data.Transform.mapCols md,
        'scales': () -> newscaleset
      new gg.data.PairTable t, md



  @createRescale: (log) ->
    Schema = gg.data.Schema
    ([pt, oldscaleset], idx ) ->
      t = pt.getTable()
      md = pt.getMD()
      scaleset = md.get 0, 'scales'
      posMapping = md.get 0, 'posMapping'
      layer = md.get 0, 'layer'
      mappingFuncs = {}
      log "#{idx} fRescale called layer: #{layer}"

      rescale = (table, scale, aes) =>
        return table if scale.type == Schema.ordinal
        oldScale = oldscaleset.scale aes, Schema.unknown, posMapping
        g = (v) -> scale.scale oldScale.invert(v)
        mappingFuncs[aes] = g
        log "#{idx} rescale: old: #{oldScale.toString()}"
        log "#{idx} rescale: new: #{scale.toString()}"
        table

      scaleset.useScales t, posMapping, rescale
      log "#{idx} #{scaleset.toString()}"
      t = gg.data.Transform.mapCols t, mappingFuncs
      new gg.data.PairTable t, md


