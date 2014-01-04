#<< gg/wf/barrier

# Train on a table that has been mapped to aesthetic domain.
#
# For numeric domains (numeric and date):
#
# 1. invert x/y values to get domain
# 2. train on inverted values to derive new domain
# 3. keep the same ranges
#
# For categorical domains (ordinal and object):
#
# 1. compute new range values using x/y values
# 2. resize ranges based on newrange/oldrange ratio
#
###################
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
class gg.scale.train.Pixel extends gg.wf.SyncBarrier
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
    timer = new gg.util.Timer()
    timer.start('fullpart')
    # why full partition?
    pairtable = pairtable.partitionOn ['facet-x', 'facet-y', 'layer']
    partitions = pairtable.partition ['facet-x', 'facet-y', 'layer']
    timer.stop('fullpart')

    scales = {}    # aes -> scaletype -> scale
    ranges = {}    # aes -> scaletype -> range
    hasscale = (col, type) ->
      (col of scales) and (type of scales[col])
    getscale = (col, scale) ->
      type = scale.type
      scales[col] = {} unless col of scales
      unless type of scales[col]
        scales[col][type] = scale.clone() 
        scales[col][type].resetDomain()
      scales[col][type]

    getrange = (col, type) ->
      ranges[col] = {} unless col of ranges
      ranges[col][type] = [Infinity, -Infinity] unless type of ranges[col]
      ranges[col][type]


    timer.start('first')
    for [key, p] in partitions
      left = p.left()
      md = p.right()
      posMapping = md.any 'posMapping'
      set = md.any 'scales'
      cols = _.filter left.cols(), (col) ->
        (posMapping[col] or col) in gg.scale.Scale.xys

      console.log "colprov x1 = #{left.colProv 'x1'}"
      for col in cols
        s = set.get col, null, posMapping
        continue if s.frozen
        xycol = posMapping[col] or col
        switch s.type
          when data.Schema.ordinal, data.Schema.object
            vals = left.all col
            range = getrange xycol, s.type
            range[0] = Math.min range[0], _.mmin(vals)
            range[1] = Math.max range[1], _.mmax(vals)

          when data.Schema.numeric, data.Schema.date
            vals = left.all col
            # convert pixel values into domain
            d = _.map s.defaultDomain(vals), (v) ->
              if _.isValid(v) and _.isFinite(v) 
                s.invert(v) 
              else 
                null
            if d.length > 0 and _.all(d, _.isValid)
              getscale(xycol, s).mergeDomain d


    timer.stop('first')

    timer.start('second')
    partitions = _.map partitions, ([key, p]) ->
      left = p.left()
      right = p.right()

      posMapping = right.any 'posMapping'
      set = right.any 'scales'
      oldset = set.clone()
      cols = _.filter left.cols(), (col) ->
        (posMapping[col] or col) in gg.scale.Scale.xys
      
      mappings = _.map cols, (col) ->
        s = set.get col, null, posMapping
        oldscale = oldset.get col, null, posMapping
        if s.frozen
          console.log "skipping #{col} in layer #{right.any 'layer'} because its frozen"
          return 
        xycol = posMapping[col] or col

        f = switch s.type
          when data.Schema.ordinal, data.Schema.object
            newrange = getrange xycol, s.type
            oldrange = [_.mmin(oldscale.range()), _.mmax(oldscale.range())]
            newsize = newrange[1] - newrange[0]
            oldsize = oldrange[1] - oldrange[0]
            if newsize > oldsize
              ratio = oldsize / newsize
              resize = (oldsize - oldsize*ratio) / 2
              newrange = [oldrange[0]+resize, oldrange[1]-resize]
              #s.range newrange
              ((col,s,ratio,resize) ->
                (v) -> v #*ratio+resize
              )(col, s, ratio, resize)

          when data.Schema.numeric, data.Schema.date
            if hasscale(xycol, s.type)
              s.domain getscale(xycol, s).domain()
              if _.isEqual(s.domain(), oldscale.domain())
                null
              else
                ((col, s, oldscale) -> 
                  (v) -> s.scale oldscale.invert(v)
                )(col, s, oldscale)

        if f?
          {
            alias: col
            cols: col
            f: f
            type: s.type
          }

      left = left.project mappings, yes

      # XXX: This is necessary so values are only rescaled _once_!
      p.left left.once()
      [key, p]

    timer.stop('second')
    console.log timer.toString()

    for [key, partition] in partitions
      pairtable.update key, partition
    pairtable


