


class gg.parse.Parser

  @parse: (spec) ->
    global = @parseGlobal spec


    layers = spec.layers
    layers = _.flatten [layers]
    layers = [{}] if layers.length == 0
    layers = _.map layers, (l) =>
      @parseLayer l, global

    {
      layers: layers
      facets: global.facets
      data: global.data
      debug: global.debug
      options: global.options
    }



  @parseGlobal: (spec) ->
    {
      facets: @extractFacets spec
      aes: @extractAes spec
      geom: @extractGeom spec
      scales: @extractScales spec
      coord: @extractCoord spec
      stat: @extractStat spec
      pos: @extractPos spec
      debug: @extractDebug spec
      options: @extractOpts spec
      data: @extractData spec
    }


  @parseLayer: (spec, global) ->
    aes = _.clone global.aes
    _.extend aes, @extractAes(spec, {})
    scales = _.clone global.scales
    _.extend scales, @extractScales(spec, {})

    {
      aes: aes
      data: @extractData spec
      geom: @extractGeom spec, global.geom
      scales: scales
      coord: @extractCoord spec, global.coord
      stat: @extractStat spec, global.stat
      pos: @extractPos spec, global.pos
    }

  @extractData: (spec) ->
    data = null
    if spec?
      data = spec.data
    data

  @extractFacets: (spec) ->
    facet = @attr spec, ['facet', 'facets'], "none"
    facet = @normalize facet, "none"
    facet.x ?= null
    facet.y ?= null

    if facet.x? or facet.y?
      if facet.type not in ['grid', 'wrap']
        facet.type = 'grid'
    else
      facet.type = 'none'
    facet


  @extractAes: (spec, defaultval={}) ->
    aes = @attr spec, ['aes', 'map', 'mapping', 'aesthetic', 'aesthetics'], {}
    unless _.isObject aes
      throw Error "asethetic should be an object: #{JSON.stringify aes}"
    aes

  @extractPos: (spec, defaultval='identity') ->
    pos = @attr spec, ['pos', 'position'], defaultval
    pos = @normalize pos
    pos

  @extractCoord: (spec, defaultval='identity') ->
    coord = @attr spec, ['coord', 'coords', 'coordinate', 'coordinates'], defaultval
    coord = @normalize coord

  @extractGeom: (spec, defaultval='point') ->
    geom = @attr spec, ['geom', 'geoms', 'shape', 'geometry'], defaultval
    geom = @normalize geom
    geom

  @extractStat: (spec, defaultval='identity') ->
    stat = @attr spec, ['stat', 'stats', 'statistic', 'statistics'], defaultval
    stat = @normalize stat
    stat

  @extractOpts: (spec, defaultval={}) ->
    opts = @attr spec, ['opt', 'opts', 'options'], defaultval
    unless _.isObject opts
      throw Error "options should be an object: #{JSON.stringify opts}"
    opts

  @extractDebug: (spec, defaultval={}) ->
    debug = @attr spec, ['debug'], defaultval
    unless _.isObject debug
      throw Error "debug should be an object: #{JSON.stringify debug}"
    debug

  @extractScales: (spec, defaultval={}) ->
    scales = @attr spec, ['scales', 'scale'], defaultval
    unless _.isObject scales
      throw Error "scales should be an object: #{JSON.stringify scales}"
    scales = _.o2map scales, (subspec, col) =>
      [col, @normalize(subspec, 'linear')]
    scales

  @normalize: (spec, defaulttype=null) ->
    if _.isString spec
      { type: spec, aes: {} }
    else if _.isArray spec
      spec = _.map spec, (subspec) => @normalize subspec, defaulttype
    else
      unless spec.type?
        unless defaulttype?
          throw Error "spec doesn't have a type: #{JSON.stringify spec}"
        spec.type = defaulttype
      spec.aes = @extractAes spec
      spec

  @attr: (spec, attrs, defaultval=null) ->
    for attr in attrs
      return spec[attr] if spec? and spec[attr]?
    defaultval


  @extractWithConfig: (spec, config) ->
    o = {}
    for key, desc of config
      if _.isObject desc
        if 'default' of desc or 'names' of desc
          names = _.compact _.flatten [key, desc.names]
          defaultval = desc.default or null
        else
          names = [key]
          defaultval = desc
      else
        names = [key]
        defaultval = desc

      for name in names
        if spec[name]?
          o[name] = spec[name]

      o[key] ?= defaultval
    o

