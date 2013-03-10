#<< gg/wf/xform


# router for instantiating specific geometries
class gg.Geom
    constructor: (@layer, @spec) ->
        @g = @layer.g

    svg: -> @layer.svg
    layerScales: -> @layer.scales()
    facetScales: -> @layer.facetScales()


    mappingXform: -> throw Error()
    renderXform: ->  throw Error()
    name: -> @constructor.name.toLowerCase()

    @klasses: ->
        klasses = [
            gg.Point,
            gg.Line,
            gg.Step,
            gg.Path,
            gg.Area,
            gg.Interval,
            gg.Rect,
            gg.Polygon,
            gg.Hex,
            gg.Schema,
            gg.Glyph,
            gg.Edge
        ]
        ret = {}
        _.each klasses, (klass) -> ret[klass.name] = klass
        ret

    @fromSpec: (layer, spec) ->
        klasses = gg.Geom.klasses()
        if _.isString spec
            type = spec
            spec = { geom: type }
        else
            type = findGood [spec.geom, spec.type,  "point"]

        klass = findGood [type, gg.Point]
        geom = new klass layer, spec
        geom

# x,y,r,x0,x1,y0,y1, ...
class gg.Point extends gg.Geom
    @name: "point"


    mappingXform: ->
        (table) ->
            {
                x: 'x',
                y: 'y',
                r: 'r',
                x0: 'x-r/2',
                x1: 'x+r/2',
                y0: 'y-r/2',
                y1: 'y+r/2'
            }

    renderXforms: ->
        # need to access the proper svg container for the geom
        (table) =>
            @svg.selectAll("g.#{klass}")
                .data(table)
                .enter()
                .append("g")
                .attr("class", "#{klass}")

            table





class gg.Line extends gg.Geom
    @name: "line"

class gg.Step extends gg.Geom
    @name: "step"

class gg.Path extends gg.Geom
    @name: "path"

class gg.Area extends gg.Geom
    @name: "area"

class gg.Interval extends gg.Geom
    @name: "interval"

class gg.Rect extends gg.Geom
    @name: "rect"

class gg.Polygon extends gg.Geom
    @name: "polygon"

class gg.Hex extends gg.Geom
    @name: "hex"

# boxplot
class gg.Schema extends gg.Geom
    @name: "schema"

class gg.Glyph extends gg.Geom
    @name: "glyph"

class gg.Edge extends gg.Geom
    @name: "edge"
