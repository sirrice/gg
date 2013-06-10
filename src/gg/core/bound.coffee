
class gg.core.Bound
  constructor: (@x0, @y0, @x1=null, @y1=null) ->
    @x1 = @x0 unless @x0?
    @y1 = @y0 unless @y0?

  @empty: -> new gg.core.Bound 0, 0

  width: -> @x1 - @x0
  height: -> @y1 - @y0
  w: -> @width()
  h: -> @height()

  clone: -> new gg.core.Bound @x0, @y0, @x1, @y1


  clear: ->
    @x0 = Number.MAX_VALUE
    @y0 = Number.MAX_VALUE
    @x1 = -Number.MAX_VALUE
    @y1 = -Number.MAX_VALUE

  add: (x, y) ->
    @x0 = x if x < @x0
    @x1 = x if x > @x1
    @y0 = y if y < @y0
    @y1 = y if y > @y1

  merge: (b) ->
    @add b.x0, b.y0
    @add b.x1, b.y1

  expand: (dx, dy=null) ->
    dy = dx unless dy?
    @x0 -= dx
    @y0 -= dy
    @x1 += dx
    @y1 += dy

  shrink: (dx, dy=null) ->
    dy = dx unless dy?
    @expand -dx, -dy


  d: (dx, dy=null) ->
    dy = dx unless dy?
    @x0 += dx
    @x1 += dx
    @y0 += dy
    @y1 += dy

  encloses: (b) ->
    b? and (
      @x0 <= b.x0 and
      @y0 <= b.y0 and
      @x1 >= b.x1 and
      @y1 >= b.y1
    )

  intersects: (b) ->
    b? and not (
      @x1 < b.x0 or
      @x0 > b.x1 or
      @y1 < b.y0 or
      @y0 > b.y1
    )


  contains: (x,y) ->
    not (
      x < @x0 or
      x > @x1 or
      y < @y0 or
      y > @y1
    )






