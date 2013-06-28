
Workflow Overview
--------------------

Workflow Nodes
-------------------

Each workflow node emits a nested array of [gg.wf.Data](https://github.com/sirrice/gg/blob/master/src/gg/wf/data.coffee) objects.  The nested hierarchy encapsulates prior partitioning operations performed on the orginial dataset.  The node object shields the developer from explicitly dealing with the nested arrays by defining several classes of node types, described below.

Each node subclasses the [gg.wf.Node](https://github.com/sirrice/gg/blob/master/src/gg/wf/node.coffee) class.  You really only need to understand the following methods, and override the last.

#### node.constructor(spec)

Takes as input a specification of the following structure

  {
    name:     STRING              # name of the node
    params:   gg.util.Param obj   # A parameter object
  }

#### node.run()

Executes the node.  Interally, it prepares the input data and calls compute.  For example, it may call compute on each [gg.wf.Data](https://github.com/sirrice/gg/blob/master/src/gg/wf/data.coffee) object or flatten the nested array before calling compute.  The node classes section will describe the details.


#### node.compute(compute(table(s), env(s), params) returns table(s)

The compute function actually transforms input table(s) to output table(s).

Table is a [gg.data.Table](https://github.com/sirrice/gg/blob/master/src/gg/data/table.coffee) object, env is a [gg.wf.Env](https://github.com/sirrice/gg/blob/master/src/gg/wf/data.coffee) object, and params is defined in the node constructor.

The reason why we use **table(s)** is because different node types take and emit either a single table or an array of tables.  Internally, before **compute()** is called, gg will package the nested array of [gg.wf.Data](https://github.com/sirrice/gg/blob/master/src/gg/wf/data.coffee) objects into the appropriate form.  These semantics are described below.

## Node classes

Exec, split, merge all are connected to a single parent node and at most one child node (0 if it is a sink).  The other classes have different numbers of parents or children.

### Exec

**run()** executes **compute()** on each leaf in the nested array and preserves the existing nested hierarchy.   **compute()**'s signature is

  compute(table, env, params) returns table

### Split

Split partitions each dataset into 1 or more partitions based on a user defined splitting criteria.  **run()** executes **compute()** on each leaf in the nested array and adds an additional level to the hierarchy.   **compute()** is predefined (the developer doesn't subclass it) and its signature is:

  compute(table, env, params) returns tables

**compute()** looks up a splitting function, **params.get("splitFunc")**, which defines the function that splits the table.  Developers can either subclass [gg.wf.Split](https://github.com/sirrice/gg/blob/master/src/gg/wf/split.coffee) and override the **splitFunc(table, env, params)** method, or set the "splitFunc" key in the params objects when instantiating the Split node. **splitFunc**'s signature is:

  splitFunc(table, env, params) returns Array

where the return value is an array of dictionaries:

  [
    {
      table: gg.wf.Table
      key: Object
    }*
  ]

For example, if the input is `[ (1,2,3), (4,5,6) ]`, where `(1,2,3)` is a table with three rows, and the splitting function partitions each table into odd and even values, then the node's output would be `[ [(1,3), (2)], [(5), (4,6)] ]`.

 **splitFunc** would be:

  splitFunc = (table, env, params) ->
    table.split (row) -> row % 2

and its output on `(1,2,3)` would be

  [ { table: (1,3), key: 1 }, { table: (2), key: 2 } ]


### Merge

This node merges leaf partitions in the hierarchy and reduces the height by one.  It searches for leaf arrays of [gg.wf.Data](https://github.com/sirrice/gg/blob/master/src/gg/wf/data.coffee) objects and unions them.  The developer should not need to subclass this or override any of its methods.

For example, if the input is

  [ [(1,3), (2)], [(5), (4,6)] ]

Then the operator will call **compute** twice:

  compute( [(1,3), (2)], ...)
  compute( [(5), (4,6)], ...)


### Source

### Barrier

N parents and N children.

### Multicast


