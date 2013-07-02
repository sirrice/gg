#<< gg/util/log
#<< gg/data/*

# Data spec:
#
#   "data": FULLSPEC | TABLE | DATASTRING
#
#   FULLSPEC = {
#     type: "table" | "rows" | "csv" | "jdbc" | function
#     name: STRING
#     val: TABLE | DATASTRING | FUNCTION
#   }
#
#   TABLE = gg.data.Table object | Array of dictionaries
#
#   DATASTRING = "*.csv" | "postgresql://*"
#
#   FUNCTION = () -> gg.data.Table | array
#
class gg.core.Data
  @ggpackage = "gg.core.Data"
  @log = gg.util.Log.logger @ggpackage, "dataspec"

  constructor: (@defaults, @layerDefaults, @specs={}) ->
    @log = gg.util.Log.logger gg.core.Data.ggpackage, "dataspec"

  @fromSpec: (spec, layerSpecs={}) ->
    defaults = @loadSpec spec

    lDefaults = _.o2map layerSpecs, (lSpec, layerIdx) =>
      [layerIdx, @loadSpec lSpec.data]

    specs =
      spec: _.clone spec
      layerSpecs: _.clone layerSpecs

    new gg.core.Data defaults, lDefaults, specs



  @loadSpec: (spec) ->
    return {} unless spec?

    if _.isType spec, gg.data.Table
      spec =
        type: "table"
        val: spec
    else if _.isArray spec
      spec =
        type: "rows"
        val: spec
    else if gg.core.Data.isCsvString spec
      spec =
        type: "csv"
        val: spec
    else if _.isFunction spec
      spec =
        type: "function"
        val: spec
    else unless _.isObject spec
      spec = {}

    type = spec.type
    val = spec.val
    spec.name = spec.name or ""

    spec

  @isCsvString: (o) ->
    _.all [
      () -> _.isString(o)
      () -> /\.csv$/.test(o.toLowerCase())
    ], ((f) -> f())

  @isJDBCString: (o) ->
    _.all [
      () -> _.isString(o)
      () -> /^(postgres|mysql):\/\//.test o.toLowerCase()
    ], ((f) -> f())


  setDefault: (spec) ->
    @defaults = gg.core.Data.loadSpec spec

  addLayerDefaults: (layer) ->
    lIdx = layer.layerIdx
    dataSpec = layer.spec.data
    @layerDefaults[lIdx] = gg.core.Data.loadSpec dataSpec
    @specs.layerSpecs[lIdx] = layer.spec
    @log "addLayer: #{layer.spec}"


  data: (layerIdx) ->
    spec =
      if layerIdx?
        @layerDefaults[layerIdx] or @defaults
      else
        @defaults

    @log spec

    unless spec?
      @log.warn "no data defined"
      return null

    unless spec.type?
      @log.warn "spec.type not defined"
      return null

    # to gg.wf.Source object
    node = switch spec.type
      when "table"
        new gg.wf.TableSource
          params:
            table: spec.val

      when "rows"
        new gg.wf.RowSource
          params:
            rows: spec.val

      when "csv"
        new gg.wf.CsvSource
          params:
            url: spec.val

      when "jdbc", "sql", "query", "db", "database", "postgres"
        new gg.wf.SQLSource
          params: spec

      when "function"
        null

      else
        null

    node





