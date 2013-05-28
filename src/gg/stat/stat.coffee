
class gg.stat.Stat extends gg.core.XForm
  constructor: (@layer, @spec={}) ->
    super @layer.g, @spec

    @map = null

    @parseSpec()

  parseSpec: ->
    if _.findGoodAttr(@spec, ['aes', 'aesthetic', 'mapping', 'map'], null)?
      mapSpec = _.clone @spec
      mapSpec.name = "stat-map" unless mapSpec.name?
      @map = gg.xform.Mapper.fromSpec @g, mapSpec

  @klasses = []

  @addKlass: (klass) ->
    # TODO: check for overlapping aliases and warn/throw error
    @klasses.push klass

  @getKlasses: ->
    klasses = @klasses.concat [
      gg.stat.IdentityStat
      gg.stat.Bin1DStat
      gg.stat.BoxplotStat
      gg.stat.LoessStat
      gg.stat.SortStat
    ]

    ret = {}
    _.each klasses, (klass) ->
      if _.isArray klass.aliases
        _.each klass.aliases, (alias) -> ret[alias] = klass
      else
        ret[klass.aliases] = klass
    ret

  @fromSpec: (layer, spec) ->
    klasses = @getKlasses()
    if _.isString spec
      type = spec
      spec = {}
    else
      type = _.findGood [spec.type, spec.stat, "identity"]

    klass = klasses[type] or gg.stat.IdentityStat
    ret = new klass layer, spec
    console.log klasses
    console.log "klass #{klass.name} from type: #{type}"
    ret


  compile: ->
    node = super
    ret = []
    ret.push @map.compile() if @map?
    ret.push node
    _.compact _.flatten ret









