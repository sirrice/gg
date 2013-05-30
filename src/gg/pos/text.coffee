#<< gg/pos/position

class gg.pos.Text extends gg.pos.Position
  @aliases = ["text"]

  parseSpec: ->
    super

    @bFast = _.findGood [@spec.fast, false]
    @innerLoop = _.findGood [@spec.innerLoop, 15]

  defaults: ->

  inputSchema: ->
    ['x', 'y', 'text']


  compute: (table, env, node) ->
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
    boxes = gg.pos.Text.anneal boxes, @bFast, @innerLoop
    console.log "got #{boxes.length} boxes from annealing"
    console.log "took #{Date.now()-start} ms"

    _.each boxes, (box, idx) ->
      row = table.get(idx)
      row.set 'x0', box[0][0]
      row.set 'x1', box[0][1]
      row.set 'y0', box[1][0]
      row.set 'y1', box[1][1]

    table




  # @param boxes list of [ [x0, x1], [y0, y1] ] arrays
  # @return same list of boxes but with optimized x0, x1, y0, y1 vals
  @anneal: (boxes, bFast, innerLoop=10) ->
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

    gridBounds = @bounds(_.map boxes, (box)->box.bound)
    [pos2box, positions] = @genPositions()

    index = new gg.util.SpatialIndex(keyf, valf)
      .gridBounds(gridBounds)
      .load(boxes)

    utility = (boxes) ->
      if bFast
        - _.sum(_.map boxes, (box) ->index.get(box.box).length)
      else
        nOverlap = 0
        for b1 in boxes
          for b2 in boxes
            if gg.pos.Text.bOverlap b1.box, b2.box
              nOverlap += 1
        - nOverlap

    #
    # Perform Annealing
    #
    level = @log.level
    @log.level = gg.util.Log.DEBUG

    curScore = utility boxes
    T = 2.466303 # 1-e^(-1/T) = 2/3
    minImprovement = 0
    optimalScore = 0
    for nAnneal in [0...10]
      nImproved = 0
      startScore = curScore

      for i in [0...(n*innerLoop)]
        # pick a random new configuration for a random box
        _posIdx = Math.floor(Math.random()*positions.length)
        boxIdx = Math.floor(Math.random()*n)
        [posIdx, cost] = positions[_posIdx]
        box = boxes[boxIdx]
        box2 = pos2box box, posIdx

        # evaluate benefit of this guy
        if bFast
          curOverlap = index.get(box.box).length
          index.rm box
          index.add box2
          newOverlap = index.get(box2.box).length
          delta = curOverlap - newOverlap
        else
          boxes[boxIdx] = box2
          newScore = utility boxes
          delta = newScore - curScore

        if delta > 0
          nImproved += 1
          @log "new score: anneal(#{nAnneal}) iter(#{i}) #{delta}"

        # Anneal
        bAccept = (delta > 0 or Math.random() <= 1-Math.exp(-delta/T))

        if bFast
          if bAccept
            boxes[boxIdx] = box2
          else
            index.rm box2
            index.add box
        else
          if bAccept
            curScore = newScore
          else
            boxes[boxIdx] = box


        if nImproved >= n*5
          @log "nImproved #{nImproved} >= n*5 #{n*5}"
          break

      if bFast
        curScore = utility boxes

      if nImproved == 0
        @log "0 improvements after #{i} iter at temperature #{T}, breaking"
        break
      unless curScore > startScore + minImprovement
        @log "no improvments: iter #{i} temp: #{T}, #{curScore} < #{startScore}"
        break
      if curScore >= optimalScore
        @log "optimal score, breaking"
        break

      T *= 0.9

    @log "done.  #{boxes.length} boxes after #{nAnneal} iters with #{curScore} score"

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
  # positions: list of [position id, cost] pairs
  # function:  (box, position id) -> new box
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
        when 0 then [x,y]
        when 1 then [x,y-h]
        when 2 then [x-w,y-h]
        when 3 then [x-w,y]
        when 4 then [x-w/2,y]
        when 5 then [x-w/2,y-h]
        when 6 then [x,y-h/2]
        when 7 then [x-w,y-h/2]
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


