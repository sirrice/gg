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
    gg.scale.train.Pixel.train pairtable, params, @log

  @train: (pairtable, params, log) ->
    fOldScales = (pt, idx) ->
      s = pt.right().any('scales').clone()
      log "#{idx} origScales: #{s.toString()}"
      s

    # 0) setup some variables we'll need
    partitions = pairtable.fullPartition()
    oldScaleSets = _.map partitions, fOldScales
    args = _.zip(partitions, oldScaleSets)

    # 1) compute new scales
    fMergeDomain = @createMergeDomain log
    partitions = _.map args, fMergeDomain
    tset = data.PairTable.union partitions

    # 2) retrain scales across facets/layers and expand domains
    #    must be done before rescaling!
    tset = gg.scale.train.Master.train tset, params
    partitions = tset.fullPartition()
    args = _.zip(partitions, oldScaleSets)

    # 3} invert data using old scales, then apply new scales
    fRescale = @createRescale log
    partitions = _.map args, fRescale

    data.PairTable.union partitions


    # 1. use old scales to invert column value
    # 2. merge domains into a fresh scaleset
    #    - reset domains of non-ordinal scales
    #    - preserve ordinal scales
    # 3. preserve existing ranges
  @createMergeDomain: (log) ->
    Schema = data.Schema
    ([pt, oldscaleset], idx) ->
      t = pt.left()
      md = pt.right()
      posMapping = md.any('posMapping') or {}
      newscaleset = oldscaleset.clone()
      seen = {}

      f = (table, oldscale, aes) ->
        return table if _.isType oldscale, gg.scale.Identity
        return table if oldscale.frozen

        log "#{idx} retrive #{aes}: #{oldscale.aes}\t#{oldscale.type}"

        if newscaleset.contains oldscale.aes, t.schema.type(aes)
          newscale = newscaleset.scale oldscale.aes, t.schema.type(aes)
        else if newscaleset.contains oldscale.aes
          newscale = newscaleset.scale oldscale.aes, Schema.unknown
        else
          newscale = oldscale.clone()
          newscaleset.scale newscale
        col = table.all(aes).filter _.isValid

        unless col? and col.length > 0
          log "#{idx} mergeDomain: aes #{aes} #{col? and col.length>0}"
          log "#{idx} mergeDomain: #{newscale.toString()}"
          return table
        if _.isType oldscale, gg.scale.BaseCategorical
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
      md = md.setColVal 'scales', newscaleset
      pt.left t
      pt.right md
      pt



  @createRescale: (log) ->
    Schema = data.Schema
    ([pt, oldscaleset], idx ) ->
      t = pt.left()
      md = pt.right()
      scaleset = md.any 'scales'
      posMapping = md.any('posMapping') or {}
      layer = md.any 'layer'
      mappingFuncs = []
      log "#{idx} fRescale called layer: #{layer}"

      rescale = (table, scale, aes) =>
        if scale.type == Schema.ordinal
          log "scale ordinal, skipping: #{aes}"
          return table 
        return table if scale.frozen
        tabletype = table.schema.type aes
        if oldscaleset.contains (posMapping[aes] or aes), tabletype
          oldScale = oldscaleset.scale aes, tabletype, posMapping
        else
          oldScale = oldscaleset.scale aes, Schema.unknown, posMapping
        g = (v) -> scale.scale oldScale.invert(v)
        mappingFuncs.push {
          alias: aes
          f: g
          type: data.Schema.unknown
        }
        log "#{idx} rescale: old: #{oldScale.toString()}"
        log "#{idx} rescale: new: #{scale.toString()}"
        table

      scaleset.useScales t, posMapping, rescale
      log "#{idx} #{scaleset.toString()}"
      t = t.mapCols mappingFuncs

      if no and t.has 'y'
        ys = t.all 'y'
        yscale = scaleset.get 'y', [t.schema.type('y'), Schema.unknown]
        range = yscale.range()
        [miny, maxy] = [_.min(ys), _.max(ys)]
        if miny < range[0]
          console.log(yscale.toString())
          throw Error("shit, rescaled y(#{miny}) is < range(#{range[0]}) ")
        if maxy > range[1]
          console.log(yscale.toString())
          throw Error("shit, rescaled y(#{maxy}) is > range(#{range[1]})")

      pt.left t
      pt.right md
      pt


