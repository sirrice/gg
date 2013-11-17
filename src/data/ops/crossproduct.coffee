class data.ops.Cross extends data.Table
  constructor: (@left, @right, @jointype, @leftf=null, @rightf=null) ->
    @schema = @left.schema.clone()
    @schema.merge @right.schema.clone()
    @setup()

  setup: ->
    defaultf = -> new data.Row(new data.Schema)
    @leftf ?= defaultf
    @rightf ?= defaultf
    liter = @left.iterator()
    riter = @right.iterator()
    lhasRows = liter.hasNext()
    rhasRows = riter.hasNext()
    liter.close()
    riter.close()

    switch @jointype
      when "left"
        unless rhasRows
          @right = data.Table.fromArray([@rightf()], @right.schema) 
          
      when "right"
        unless lhasRows
          tmp = @left
          @left = @right
          @right = tmp
          @right = data.Table.fromArray([@leftf()], @left.schema) 

      when "outer"
        unless lhasRows
          tmp = @left
          @left = @right
          @right = tmp
          @right = data.Table.fromArray([@leftf()], @left.schema) 
        else unless rhasRows
          @right = data.Table.fromArray([@rightf()], @right.schema) 
          
  iterator: ->
    class Iter
      constructor: (@left, @right) ->
        @liter = @left.iterator()
        @riter = @right.iterator()
        @lrow = null
        @reset()

      reset: ->
        @liter.reset()
        @riter.reset()

      next: ->
        throw Error("iterator has no more elements") unless @hasNext()
        @lrow.clone().merge @riter.next()

      hasNext: ->
        @lrow = null unless @riter.hasNext()

        while @liter.hasNext() and not(@lrow? and @riter.hasNext())
          @riter.reset()
          @lrow = @liter.next()

        @lrow? and @riter.hasNext()

      close: ->
        @left = @right = null
        @liter.close()
        @riter.close()

    new Iter @left, @right


