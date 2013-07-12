#<< gg/pos/position

class gg.pos.Text extends gg.pos.Position
  @ggpackage = "gg.pos.Text"
  @aliases = ["text"]

  parseSpec: ->
    super

    tempAttrs = ['T', 't', 'temp', 'temperature']
    @params.putAll(
      bFast = - _.findGood [@spec.fast, false]
      innerLoop = _.findGood [@spec.innerLoop, 15]
      temperature = _.findGoodAttr @spec, tempAttrs, 2.466303 # 1-e^(-1/T) = 2/3
    )

  inputSchema: ->
    ['x', 'y', 'text']


  compute: (data, params) ->
    table = data.table
    env = data.env
    attrs = ['x', 'y', 'text']
    inArr = _.map attrs, ((attr)->table.schema.inArray attr)
    unless _.all(inArr) or not (_.any inArr)
      throw Error("attributes must all be in arrays or all not")

    # box: [[x0, x1], [y0, y1]]
    boxes = table.each (row) ->
      [
        [row.get('x0'), row.get('x1')]
        [row.get('y0'), row.get('y1')]
        [row.get('x0'), row.get('y0')]
      ]

    start = Date.now()
    bFast = params.get 'bFast'
    innerLoop = params.get 'innerLoop'
    temperature = params.get 'temperature'
    boxes = gg.pos.Text.anneal boxes, bFast, innerLoop, temperature
    console.log "got #{boxes.length} boxes from annealing"
    console.log "took #{Date.now()-start} ms"

    _.each boxes, (box, idx) ->
      row = table.get(idx)
      row.set 'x0', box[0][0]
      row.set 'x1', box[0][1]
      row.set 'y0', box[1][0]
      row.set 'y1', box[1][1]

    data




  # @param boxes list of [ [x0, x1], [y0, y1] ] arrays
  # @return same list of boxes but with optimized x0, x1, y0, y1 vals
  @anneal: (boxes, bFast, innerLoop=10, T=2.4) ->
    #
    # setup the boxes
    #
    for box in boxes
      if _.any(_.union(box[0], box[1]), _.isNaN)
        console.log "box is invalid: #{box}"
        throw Error()
      if box.length == 2
        # add pivot point.  Defaults to lower left
        box.push [box[0][0], box[1][0]]

    n = boxes.length
    keyf = (box) -> box.box
    valf = (box) -> box.idx
    boxes = _.map boxes, (box, idx) ->
      w = box[0][1]-box[0][0]
      h = box[1][1]-box[1][0]
      {
        box: box
        idx: idx
        pos: 0
        bound: [
          [box[0][0]-w,box[0][1]]
          [box[1][0]-h,box[1][1]]
        ]
      }

    # create spatial index
    gridBounds = @bounds(_.map boxes, (box)->box.bound)
    index = new gg.util.SpatialIndex(keyf, valf)
      .gridBounds(gridBounds)
      .load(boxes)


    [pos2box, positions] = @genPositions()

    #
    # Perform Annealing
    #
    level = @log.level
    @log.level = gg.util.Log.DEBUG
    findTicket = (overlaps, ticket) ->
      for o, idx in overlaps
        ticket -= o
        return idx if ticket <= 0
      throw Error()

    minImprovement = 0
    optimalScore = 0
    for nAnneal in [0...10]
      nImproved = 0
      overlapArr = _.map boxes, (box) -> index.get(box.box).length
      startScore = - _.sum(overlapArr) + boxes.length

      for i in [0...(boxes.length*innerLoop)]
        # pick a configuration from an area with lots of overlap
        # pick a random new configuration for a random box
        _posIdx = Math.floor(Math.random()*positions.length)
        [posIdx, cost] = positions[_posIdx]

        # Lottery-based sampling.
        # Each box has number of tickets equal to its
        # number of overlaps
        if bFast
          ticket = Math.floor(Math.random() * _.sum(overlapArr))
          boxIdx = findTicket overlapArr, ticket
        else
          boxIdx = Math.floor(Math.random()*n)
        box = boxes[boxIdx]
        box2 = pos2box box, posIdx

        # evaluate benefit of this guy
        curOvBoxes = index.get box.box
        curOverlap = curOvBoxes.length
        newOvBoxes = index.get box2.box
        newOverlap = newOvBoxes.length
        newOverlap += 1 unless box2 in newOvBoxes
        delta = curOverlap - newOverlap
        nImproved += 1 if delta > 0

        # Anneal
        bAccept = (delta > 0 or Math.random() <= 1-Math.exp(-delta/T))
        if bAccept
          boxes[boxIdx] = box2
          # update overlaps if accepted
          _.each curOvBoxes, (b) -> overlapArr[b.idx] -= 1
          _.each curOverlap, (b) -> overlapArr[b.idx] += 1
          overlapArr[box2.idx] = newOverlap
          index.rm box
          index.add box2

        if nImproved >= n*5
          @log "nImproved #{nImproved} >= n*5 #{n*5}"
          break

      curScore = -_.sum _.map boxes, (box) ->
        index.get(box.box).length-1

      if nImproved == 0
        @log "n:#{nAnneal}: nImproved: 0"
        break
      unless curScore > startScore + minImprovement
        @log "n:#{nAnneal}: #{curScore} < #{startScore}"
        break
      if curScore >= optimalScore
        @log "n:#{nAnneal}: optimal score"
        break

      @log "n#{nAnneal}: nImproved: #{nImproved} score: #{startScore} to #{curScore}"

      T *= 0.9

    @log "n:#{nAnneal} score: #{curScore}"

    @log.level = level
    _.map boxes, (box) -> box.box


  # @param b1 [ [xmin, xmax], [ymin, ymax] ]
  # @param b2 [ [xmin, xmax], [ymin, ymax] ]
  # @return true if b1 intersects b2, false otherwise
  @bOverlap: (b1, b2) ->
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


  # @return [function, positions]
  # function:  (box, position id) -> new box
  # positions: list of [position id, cost] pairs
  @genPositions: ->
    posCosts =
      0: 1
      1: 1
      2: 1
      3: 1
      4: 2
      5: 2
      6: 2
      7: 2
      8: 3
      9: 3
      10: 3
      11: 3
      12: 3
      13: 3
      14: 3
      15: 3
    maxCost = 1 + _.mmax _.values(posCosts)

    positions = []
    _.each _.values(posCosts), (cost, pos) ->
      _.times (maxCost-cost), ->
        positions.push [pos, cost]

    pos2box = (box, position) ->
      x = box.box[2][0]
      y = box.box[2][1]
      w = box.box[0][1] - box.box[0][0]
      h = box.box[1][1] - box.box[1][0]
      pt = switch position
        when 0  then [x,y]
        when 1  then [x,y-h]
        when 2  then [x-w,y-h]
        when 3  then [x-w,y]
        when 4  then [x-w/2,y]
        when 5  then [x-w/2,y-h]
        when 6  then [x,y-h/2]
        when 7  then [x-w,y-h/2]
        when 8  then [x-w/4,y]
        when 9  then [x-w/4,y-h]
        when 10 then [x,y-h/4]
        when 11 then [x-w,y-h/4]
        when 12  then [x-w*3/4,y]
        when 13  then [x-w*3/4,y-h]
        when 14 then [x,y-h*3/4]
        when 15 then [x-w,y-h*3/4]
        else throw Error("position #{position} is invalid")
      {
        box: [[pt[0], pt[0]+w], [pt[1], pt[1]+h], box.box[2]]
        idx: box.idx
        pos: position
        bound: box.bound
      }

    [pos2box, positions]

  @bounds: (boxes) ->
    f = (memo, box) ->
      memo[0][0] = Math.min memo[0][0], box[0][0]
      memo[0][1] = Math.max memo[0][1], box[0][1]
      memo[1][0] = Math.min memo[1][0], box[1][0]
      memo[1][1] = Math.max memo[1][1], box[1][1]
      memo
    _.reduce boxes, f, [[Infinity,-Infinity],[Infinity,-Infinity]]


