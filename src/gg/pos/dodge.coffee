#<< gg/pos/position


class gg.pos.Dodge extends gg.pos.Position
  @ggpackage = "gg.pos.Dodge"
  @aliases = ["dodge"]

  parseSpec: ->
    super
    @params.put "padding", _.findGoodAttr @spec, ['pad', 'padding'], 0.05

  inputSchema: -> ['x', 'x0', 'x1', 'group']#, 'y', 'y0', 'y1', 'group']


  compute: (data, params) ->
    table = data.table
    env = data.env
    groups = table.split (row) -> [row.get('x0'),row.get('x1')]
    maxGroup = _.mmax groups, (group) -> group.table.nrows()
    keys = _.uniq _.flatten _.map(groups, (group) -> _.uniq(group.table.getColumn "group"))
    keys = _.uniq _.map(keys, (key) -> JSON.stringify key)
    key2Idx = {}
    _.each keys, (key, idx) =>
      @log.warn "key #{key} -> #{idx}"
      key2Idx[key] = idx
    nkeys = keys.length
    @log.warn "ngroups: #{groups.length}\tnKeys: #{nkeys}"

    log = @log
    padding = 1.0 - params.get('padding')
    table.each (row) ->
      key = JSON.stringify row.get("group")
      idx = key2Idx[key]
      width = row.get('x1') - row.get('x0')
      newWidth = padding * width / nkeys
      x = row.get 'x'
      newx = x - width/2 + idx*newWidth + newWidth
      newx0 = newx - newWidth / 2
      newx1 = newx + newWidth / 2

      row.set 'x', newx
      row.set 'x0', newx0
      row.set 'x1', newx1

      log "#{key}\tidx: #{idx}\told: #{x},#{width}\tnew: #{newx},#{newWidth}"


    data

