#<< gg/pos/position

class gg.pos.Text extends gg.pos.Position
  @aliases = ["text"]

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

    boxes = gg.pos.Text.anneal boxes
    console.log "got #{boxes.length} boxes from annealing"

    _.each boxes, (box, idx) ->
      console.log box
      row = table.get(idx)
      row.set 'x0', box[0][0]
      row.set 'x1', box[0][1]
      row.set 'y0', box[1][0]
      row.set 'y1', box[1][1]

    table




  # @param boxes list of [ [x0, x1], [y0, y1] ] arrays
  # @return same list of boxes but with optimized x0, x1, y0, y1 vals
  @anneal: (boxes) ->
    for box in boxes
      if _.any(_.union(box[0], box[1]), _.isNaN)
        console.log "box is invalid: #{box}"
        throw Error()

    n = boxes.length
    boxes = _.map boxes, (box) ->
      box: box
      pos: 0

    [pos2box, positions] = @genPositions()


    utility = (boxes) ->
      nOverlap = 0
      for i in _.range(n)
        for j in _.range(i+1,n)
          if gg.pos.Text.bOverlap(boxes[i].box, boxes[j].box)
            nOverlap += 1
      - nOverlap

    curScore = utility boxes
    T = 2.466303 # 1-e^(-1/T) = 2/3
    minImprovement = 0
    optimalScore = 0
    for nAnneal in [0...5]
      maxi = n * 20
      nAccepted = 0
      nImproved = 0
      startScore = curScore
      console.log "\n\n"

      for i in [0...maxi]
        posIdx = Math.floor(Math.random()*positions.length)
        boxIdx = Math.floor(Math.random()*n)
        pos = positions[posIdx]
        cost = pos[1]
        box = boxes[boxIdx]
        boxp = pos2box box, posIdx
        boxes[boxIdx] = boxp

        newScore = utility boxes
        delta = newScore - curScore
        if newScore > curScore
          console.log "new score: anneal(#{nAnneal}) iter(#{i}) #{newScore} vs #{curScore} #{box.box} -> #{boxes[boxIdx].box}"
          nImproved += 1

        if (newScore < curScore and
            Math.random() > 1.0-Math.exp(-delta/T))
          boxes[boxIdx] = box
        else
          nAccepted += 1
          curScore = newScore

        break if nAccepted >= n*5

      break if nImproved == 0
      break unless curScore > startScore + minImprovement
      break if curScore >= optimalScore

      T *= 0.9

    console.log "done.  #{boxes.length} boxes"
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
    positions =
      0: 0
      1: 1
      2: 1
      3: 1
      4: 2
      5: 2
      6: 2
      7: 2
    positions = _.map positions, (v,k)->[k,v]

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
        pos: position
      }

    [pos2box, positions]


