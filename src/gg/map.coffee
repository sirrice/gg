# Mappers are tied closely with XForms
class gg.Mapper# extends gg.wf.Node
    # @param mapping output attribute -> input attribute/function
    constructor: (@mapping) ->
        super

        @funcs = {}
        @strings = {}

        @xform


    # does mapper output @param aes?
    outputs: (aes) -> aes of @mapping

    aesthetics: -> _.keys @mapping

    compute: (tables) -> _.map tables, @mapAll


    mapAll: (data, aes=null) -> _.map data, (d) => @map(d, aes)

    # @param d a datum
    # @param aes transform and return a single aesthetic value
    #            if null, then return the datum with all attributes
    #            mapped
    # @return single value if aes != null, otherwise the full
    #         transfromed datum
    map: (d, aes=null) ->
        if aes? then  @mapAes d, aes else @mapDatum d

    mapDatum: (d) ->
        _.mapObj _.uniq(_.keys(d).concat(_.keys(@mapping))), (aes) =>
            [aes, @mapAes(d, aes)]

    # @param aes target aesthetic
    mapAes: (d, aes) ->
        if aes not of @mapping
            return null

        key = @mapping[aes]
        if _.isNumber(d) and not Number.isFinite d
            console.log 'blah'

        if typeof key is 'function'
            key d
        else if key of d
            d[key]
        else if aes of @strings
            key
        else if aes isnt 'text'
            if key.length is 0 or (key[0] is '{' and key[1] is '}')
                @strings[aes] = key
            else if not (aes of @funcs)
                # XXX: This is risky, need to be
                # certain that user creating plot is safe
                cmds = (_.map d, (val, k) => "var #{k} = d['#{k}'];")
                cmds.push "return #{key}; "
                cmd = cmds.join('')
                fcmd = "var __func__ = function(d) {#{cmd}}"
                eval(fcmd)
                @funcs[aes] = __func__
            @funcs[aes](d)
        else
            key


    # @param spec the Xform specification
    # of the form {xform: '', mapping/aes/map: { }}
    @fromSpec: (spec) ->
        if not spec?
            new gg.IdentityMapper
        else
            mapping = spec.mapper or spec.mapping or spec.aes or {}
            if _.isEmpty mapping
                new gg.IdentityMapper
            else
                new gg.Mapper mapping



class gg.IdentityMapper extends gg.Mapper
    constructor: () ->
        super

    aesthetics: -> @xform.inSchema
    outputs: (aes) -> true
    compute: (tables) -> tables
    mapAll: (data) -> data
    map: (d, aes=null) -> if aes? then d[aes] else d
    mapAes: (d, aes) -> d[aes]
    mapDatum: (d) -> d





