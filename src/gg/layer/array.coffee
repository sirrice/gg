#<< gg/layer/layer


class gg.layer.Array
  xformToString: (xform) ->
    if _.isSubclass xform, gg.stat.Stat
      "S"
    else if _.isSubclass xform, gg.xform.Mapper
      "M"
    else if _.isSubclass xform, gg.pos.Position
      "P"
    else if _.isSubclass xform, gg.geom.Render
      "R"
    else if _.isSubclass xform, gg.geom.Geom
      "G"

  parseArraySpec: (spec) ->
    # Explicit list of transformations
    # ensure that the list ends with geom/render nodes
    @xforms = _.map spec, (xformspec) -> gg.core.XForm.fromSpec xformspec
    klasses = _.map @xforms, (xform) => @xformToString xform
    klassStr = klasses.join ""
    validregex = /^([MS]*)(G|(?:M?P?R))$/
    unless regex.test klassStr
      throw Error("Layer: series of XForms not valid (#{klassStr})")

    [entireStr, statChars, geomChars] = validregex.exec(klassStr)
    [sidx, eidx] = [s, statChars.length()]
    @stats = @xforms[sidx...eidx]
    [sidx, eidx] = [eidx, eidx+geomChars.length()]
    throw Error("gg.Geom.parseArraySpec: not implemented. Needs to be thought through")
    @geoms = @xforms[sidx...eidx]
    if geomChars is "G"
      geom = @geoms[0]
      @geoms = [geom.mappingXForm(), geom.positionXForm()]
      @renders = [geom.renderXForm()]
    else
      @renders = [_.last @geoms]
      @geoms = _.initial @geoms


