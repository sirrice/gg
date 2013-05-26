#<< gg/pos/position


class gg.pos.Dodge extends gg.pos.Position
  @aliases = ["dodge"]

  addDefaults: (table, env) ->

  inputSchema: -> ['x', 'x0', 'x1', 'y', 'y0', 'y1', 'group']

  parseSpec: -> super

  compute: (table, env) ->
    groups = table.split (row) -> JSON.stringify [row.get('x0'), row.get('x1')]
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
    table = table.clone()
    table.each (row) ->
      key = JSON.stringify row.get("group")
      idx = key2Idx[key]
      width = row.get('x1') - row.get('x0')
      newWidth = width / nkeys
      x = row.get 'x'
      newx = x - width/2 + idx*newWidth + newWidth
      newx0 = newx - newWidth / 2
      newx1 = newx + newWidth / 2

      row.set 'x', newx
      row.set 'x0', newx0
      row.set 'x1', newx1

      log.warn "#{key}\tidx: #{idx}\told: #{x},#{width}\tnew: #{newx},#{newWidth}"


    table

