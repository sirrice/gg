#<< gg/scale/categorical

class gg.scale.Shape extends gg.scale.BaseCategorical
  @aliases = "shape"

  constructor: (@padding=1) ->
      customTypes = ['star', 'ex']
      @symbolTypes = d3.svg.symbolTypes.concat customTypes
      @d3Scale = d3.scale.ordinal().range @symbolTypes
      @invertScale = d3.scale.ordinal().domain @d3Scale.range()
      @symbScale = d3.svg.symbol()
      @type = gg.data.Schema.ordinal
      super

  range: (interval) -> # not allowed
  scale: (v) ->
    throw Error("shape scale not thought through yet")
    size = args[0] if args? and args.length
    type = @d3Scale v
    r = Math.sqrt(size / 5) / 2
    diag = Math.sqrt(2) * r
    switch type
      when 'ex'
          "M#{-diag},#{-diag}L#{diag},#{diag}" +
              "M#{diag},#{-diag}L#{-diag},#{diag}"
      when 'cross'
          "M#{-3*r},0H#{3*r}M0,#{3*r}V#{-3*r}"
      when 'star'
          tr = 3*r
          "M#{-tr},0H#{tr}M0,#{tr}V#{-tr}" +
              "M#{-tr},#{-tr}L#{tr},#{tr}" +
              "M#{tr},#{-tr}L#{-tr},#{tr}"
      else
          @symbScale.size(size).type(@d3Scale v)()


