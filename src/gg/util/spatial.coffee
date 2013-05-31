#<< gg/util/array
#
# Ghetto no-update spatial tree index
# using ghetto grids.  Ghetto.
#
# Did I mention ghetto?


# Usage:
#
#   idx = new gg.util.SpatialIndex()
#   idx.gridBounds( bounds )
#   idx.load( boxes )
#
class gg.util.SpatialIndex
  # @param boxes array of objects to index
  # bounding boxes are of the format [[xmin,xmax][ymin,ymax]]
  constructor: (@keyf=null, @valf=null) ->
    @keyf = ((box) -> box) unless @keyf?
    @valf = ((box) -> box) unless @valf?
    @gbounds = null
    @gboundsFixed = false
    @cells = null
    @ncells = null
    @cellsize = null
    @debug = no

  gridBounds: (@gbounds) ->
    @gboundsFixed = yes
    @
  cellSize: (@cellsize) -> @
  load: (boxes) ->
    @boxes = new gg.util.MArray()
    _.each boxes, (box) => @boxes.add box
    @gbounds = null unless @gboundsFixed
    @computeMetadata()
    @createIndex()
    @


  # Get or set the key (bounding box) accessor
  # By default, the getter is item.box
  key: (getter=null) ->
    if getter?
      getter = ((box) -> box[getter]) unless _.isFunction(getter)
      @keyf = getter
    @keyf

  # Get or set the value accessor
  val: (getter=null) ->
    if getter?
      getter = ((box) -> box[getter]) unless _.isFunction(getter)
      @valf = getter
    @valf

  computeMetadata: ->
    # 1) find the x and y grid sizes
    #    max(min(bounding boxes) or total grid size / 30)

    minx = Infinity
    maxx = -Infinity
    miny = Infinity
    maxy = -Infinity
    sumboxw = 0
    sumboxh = 0
    minboxw = Infinity
    minboxh = Infinity

    _.each @boxes, (box) =>
      [x,y] = @keyf box
      w = x[1]-x[0]
      h = y[1]-y[0]
      minx = Math.min x[0], minx
      maxx = Math.max x[1], maxx
      miny = Math.min y[0], miny
      maxy = Math.max y[1], maxy
      minboxw = Math.min w, minboxw
      minboxh = Math.min h, minboxh
      sumboxw += w
      sumboxh += h

    # TODO: check if nothing was updated for some reason
    n = @boxes.length
    globalw = maxx - minx
    globalh = maxy - miny
    cellw = Math.max(globalw / 30.0, sumboxw/n)
    cellh = Math.max(globalh / 30.0, sumboxh/n)
    @gbounds = [[minx, maxx], [miny, maxy]] unless @gbounds?
    @cellsize = [cellw, cellh] unless @cellsize?

    nxcells = Math.ceil(globalw / @cellsize[0])
    nycells = Math.ceil(globalh / @cellsize[1])
    @ncells = [nxcells, nycells]


    if @debug
      console.log "global: #{@gbounds}"
      console.log "cellsize: #{@cellsize}"
      console.log "ncells: #{@ncells}"


  createIndex: ->
    # 2) allocate grid cells and indexing function into cells
    # 3) assign box indexes into the cells
    [nx, ny] = @ncells
    ncells = (nx+1)*(ny+1)
    @cells = _.times ncells, () -> new gg.util.MArray()
    _.each @boxes, (box, boxidx) =>
      @add box, boxidx
    if @debug
      console.log "created #{ncells} cells in index"


  # @param box an indexed item
  # @param boxidx add box to index if null, otherwise assume that
  #        it is the correct index into @boxes
  add: (box, boxidx=null) ->
    boxidx = @boxes.add box unless boxidx?
    cellbound = @box2cellbound box
    @eachCell cellbound, (cell, pos) =>
      cell.add boxidx

  rm: (box) ->
    val = @valf box
    bound = @keyf box
    cellbound = @bound2cellbound bound
    boxIdxs = {}
    # remove from the index
    @eachCell cellbound, (cell, pos) =>
      for boxIdx, cellIdx in cell
        continue unless boxIdx?
        continue if boxIdx of boxIdxs

        box = @boxes[boxIdx]
        if @valf(box) == val
          cell.rmIdx cellIdx
          boxIdxs[boxIdx] = yes

    # remove from global boxes list
    _.each boxIdxs, (ignore, boxIdx) =>
      @boxes.rmIdx boxIdx
    _.size boxIdxs

  get: (bound) ->
    ret = {}
    # collect a set of boxidxs
    boxIdxs = {}
    cellbound = @bound2cellbound bound
    @eachCell cellbound, (cell, pos) =>
      _.each cell, (boxIdx) =>
        return unless boxIdx?
        return unless @boxes[boxIdx]?
        boxIdxs[boxIdx] = yes

    # filter and retrive the boxes
    _.compact _.map boxIdxs, (ignore, boxidx) =>
      @boxes[boxidx] if @intersects @keyf(@boxes[boxidx]), bound

  getSlow: (bound) ->
    _.compact _.map @boxes, (box) =>
      box if box? and (@intersects bound, @keyf(box))


  # @param cellbound box of grid cells
  # @param f function: (cell, [cellx, celly]) ->
  eachCell: ([cellx, celly], f) ->
    for x in [cellx[0]..cellx[1]]
      for y in [celly[0]..celly[1]]
        cellidx = @cell2cellidx [x,y]
        cell = @cells[cellidx]
        f cell, [x,y]


  # do the two bounding boxes overlap
  intersects: (b1, b2) ->
    mins = [
      b1[0][0]
      b1[1][0]
      b2[0][0]
      b2[1][0]
    ]
    maxs = [
      b2[0][1]
      b2[1][1]
      b1[0][1]
      b1[1][1]
    ]
    ret = not (_.any _.zip(mins, maxs), (([min,max]) ->
      min >= max))
    ret



  # @param cell [cellx, celly] position
  # @return index into @cells array
  cell2cellidx: (cell) ->
    cell[0] + @ncells[0] * cell[1]

  # @paramm box an indexed item
  # @return cell bound
  box2cellbound: (box) ->
    bound = @keyf box
    @bound2cellbound bound

  # @param x [xmin, xmax]
  # @param y [ymin, ymax]
  bound2cellbound: ([x, y]) ->
    mincell = @pt2cell [x[0], y[0]]
    maxcell = @pt2cell [x[1], y[1]]
    [[mincell[0], maxcell[0]], [mincell[1], maxcell[1]]]


  pt2cell: ([x,y]) ->
    xcell = Math.floor((x - @gbounds[0][0]) / @cellsize[0])
    ycell = Math.floor((y - @gbounds[1][0]) / @cellsize[1])
    [xcell, ycell]









  intersection: (box) ->





