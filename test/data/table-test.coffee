require "../envdata"
vows = require "vows"
assert = require "assert"


suite = vows.describe "table.js"
Table = data.Table
Schema = data.Schema

makeTable = (n=10, type="row") ->
  rows = _.times 10, (i) -> {
    a: i%2, 
    b: "#{i}"
    x: i
    y: {
      z: i
    }
  }
  Table.fromArray rows, null, type

checks = 
  "filter x < 4":
    topic: (t) ->
      t.filter (row) -> row.get('x') < 4
    "has 4 rows": (t) ->
      assert.equal t.nrows(), 4

  
  "partition on a":
    topic: (t) -> t.partition(['a'])
    "has 2 rows": (t) ->
      assert.equal t.nrows(), 2

    "single function aggregate c=count(x), s=sum(x)": 
      topic: (t) ->
        t.aggregate [
          {
            alias: ['c', 's']
            f: (arr) ->
              vals = _.map(arr, (o)->o.get('x'))
              {
                c: arr.length
                s: _.reduce(vals, ((a,b)->a+b), 0)
              }
            type: data.Schema.numeric
          }
        ]
      "is correct": (t) ->
        t.each (row) ->
          assert.equal row.get('s'), row.get('a')*5+20
          assert.equal row.get('c'), 5

    "multi function aggregate c=count(x), s=sum(x)": 
      topic: (t) ->
        t.aggregate [
          data.ops.Aggregate.count 'c'
          data.ops.Aggregate.sum 'x', 's'
        ]
      "is correct": (t) ->
        t.each (row) ->
          assert.equal row.get('s'), row.get('a')*5+20
          assert.equal row.get('c'), 5



  "union with itself":
    topic: (t) -> t.union t
    "has 20 rows": (t) ->
      assert.equal t.nrows(), 20

  "limit 2":
    topic: (t) -> t.limit 2
    "has 2 rows": (t) ->
      assert.equal t.nrows(), 2
      t.each (row) ->
        assert.lt row.get('x'), 3

  "offset 5 limit 2":
    topic: (t) -> t.offset(5).limit 2
    "has 2 rows": (t) ->
      assert.equal t.nrows(), 2
    "5 <= x < 7": (t) ->
      t.each (row) ->
        assert.lte 5, row.get('x')
        assert.lt row.get('x'), 7

  "other table  { x: i+5, t: i%3}":
    topic: (t) ->
      rows = _.times 10, (i) -> { x: i+5, b: i%3}
      t2 = data.Table.fromArray rows
      [t, t2]

    "cross product via .cross()":
      topic: ([t1, t2]) -> t1.cross t2
      "has 100 rows": (t) ->
        assert.equal t.nrows(), 100

    "cross product via join":
      topic: ([t1, t2]) -> t1.join t2, []
      "has 100 rows": (t) ->
        assert.equal t.nrows(), 100

    "outer join on x":
      topic: ([t1, t2]) -> t1.join t2, ['x']
      "has 15 rows": (t) ->
        assert.equal t.nrows(), 15

    "left join on x":
      topic: ([t1, t2]) -> t1.join t2, ['x'], "left"
      "has 10 rows": (t) ->
        assert.equal t.nrows(), 10

    "right join on x":
      topic: ([t1, t2]) -> t1.join t2, ['x'], "right"
      "has 10 rows": (t) ->
        assert.equal t.nrows(), 10

    "inner join on x":
      topic: ([t1, t2]) -> t1.join t2, ['x'], "inner"
      "has 5 rows": (t) ->
        assert.equal t.nrows(), 5

 

  "project":
    topic: (t) ->
      t.project [
        {
          alias: 'x',
          f: _.identity
          cols: 'x'
          type: data.Schema.numeric
        }
        {
          alias: 'y'
          f: (x) -> x + 100
          cols: 'x'
          type: data.Schema.numeric
        }
        {
          alias: 'z'
          f: (row) -> row.get('x') * 100
          cols: '*'
          type: data.Schema.numeric
        }
        {
          alias: ['n', 'm']
          f: (x) -> {n: -x, m: -x-1000}
          type: data.Schema.numeric
          cols: 'x'
        }
      ]

    "values correct": (t) ->
      t.each (row) ->
        x = row.get 'x'
        assert.equal row.get('y'), (x+100), "y is wrong #{row.get 'y'} != #{x+100}"
        assert.equal row.get('z'), (x*100), "z is wrong #{row.get 'z'} != #{x*100}"
        assert.equal row.get('n'), -x, "n is wrong #{row.get 'n'} != #{-x}"
        assert.equal row.get('m'), (-x-1000), "m is wrong #{row.get 'm'} != #{-x-1000}"


  "can be turned to json and parsed back": (t) ->
    json = t.toJSON()
    t2 = data.Table.fromJSON json

    assert.deepEqual t.schema.toJSON(), t2.schema.toJSON()
    rows1 = t.getRows()
    rows2 = t2.getRows()
    _.each _.zip(rows1, rows2), ([r1, r2]) ->
      assert.equal r1.get('a'), r2.get('a'), "a's should be equal: #{r1.get('a')} != #{r2.get('a')}"


tests = 
  topic: makeTable
_.extend tests, checks

suite.addBatch
  "table": tests




suite.export module
