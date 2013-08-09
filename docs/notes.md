Desired Features
----------

1. Keep workflow from breaking (not rendering facets) when table contains null values
1. <strike>SQL source operator.  Server only</strike>
1. Compile a server-side source + map/group operator into a SQL statement
1. Implement a generalized Group-by aggregate operator
1. Schema based provenance.  Use to do between-operator schema mapping
1. Data provenance to map from dom element to data and back
1. Better JS interface
  * ggplot2-like interface
1. Node-failure tolerance.  If a node throws an exception, dont block workflow on the next barrier, keep going.



July 22, 2013
---------------
Braindump of provenance model

hierarchical model (e.g., protobuf-style) of a complete "provenance object".  
Developer specifies this model using some language

    flow > op* > env > key/val
               > table > schema > attr
                       > data > row


Provenance store provides the following:

1) models parent/child relationships between provenance objects
   add/alter model
2) provides INSERT api
   new dataset/execution
   updated data (insert/delete)
3) provides SELECT api
   every node has a prev/next semantics to the prev/next object

Some Details

1) Every element has an ID which is the path in this model
   How does dev construct this path?  Want to cache parent path/define a context.
2) Materialization, Storage, and Indexing schemes
3) Needs access to gg runtime for re-execution.




July 10, 2013
----------------

Ideal syntax

    // comment
    geom: point
    stat: loess
    aes:
        x: a
        y: a*b            // interpreted
        stroke: 10        //
        text: "string"    //
        color: {js a*b}   // explicitly javascript
    coord: flip
    facet: x: a, y: b
    debug: gg: INT, gg.wf: INT
    opts: key: val, key: val
          (key, val) (key, val)
        



July 9, 2013
----------------

## Query types

Some query attributes

1. Path length
1. Target/final node in query path
1. Fetch data or just relationship? 
1. Mid-query Cardinality
1. Provenance size e.g., data provenance or config/static prov
1. Result cardinality
  * similar to boolean result
  * top k
  * random sample
  * sample
1. Boolean result? e.g., points share source data?
1. Granularity e.g., partition/dataset/user/row/column

## Provenance

### Operator type hierarchy

    node
      barrier
        bform
      exec
        xform
      split
      merge
    
* flow stores op dependencies    
* node stores param dependencies
* barrier/exec/split/merge/source stores wf.Data dependencies
* xform/bform stores Schema dependencies 
* compute() stores row and env dependencies
 

### Provenance Store is a graph store

Fundamentally, the following operations

1. put(output(s), input(s), metadata?)
2. join(left, dataset, direction=(back/forw))

Lots of opportunities for optimizations based on the query logs

* Index the outputs/inputs
* Encodings
* Collapse provenance across operations
* Materialize source provenance in output provenance records


### Operator Provenance.  

At a high level, we want to comprehensively track the provenance of operators:

1. operator <--> operator
2. operator --> parameters

Operators are hierarchical, so tracking operators means tracking all sub-structures:

    Operator
    -> params 
    -> inputs
       -> gg.wf.Data
          -> Env
          -> Table
             -> Schema
                -> Attr
             -> Row

By default, assume that sub-structures are mapped (somehow), and allow overrides

Need:

1. Way to id each sub-structure
2. Map input output ids

Need to track within `addDefaults()` and `compute()`

Params provenance

1. Params --> Operator


Schema provenance

1. input schema <--> output schema

Operator provennace

1. Input <--> output port
2. Parent output port <--> child input port

Dataset provenance

1. index into @inputs <--> index into outputs 
2. input data object <--> output data object

Env provenance

1. Operator <--> env key
    * What input(s) did key depend on?

Tuple provenance

1. input rowid <--> output rowid.  

#### Representation

Conceptually, these can be stored as triples of:

    ((input value, type), (output value, type), relationship)
    
but this is pretty inefficient e.g.,

    ((wf.Data object, "dataset"), (wf.Data object, "dataset"), "")
    (("a", "attribute"), ("x", "attribute"), "")
    (("a", "attribute"), (wf.Data object, "dataset"), "schema")

    
### Transforming between schemas

1. given input table, output schema and a mapping object, return an output table




July 1, 2013
----------------

Added hooks in logger so that debugging levels can be specified through the `debug` components of gg spec.  Each key/val pair specifies a class path prefix and the debugging level:
    
    {
        debug: {
            "gg":        gg.util.Log.ERROR   // by default, only show errors
            "gg.wf":     gg.util.Log.DEBUG   // show all log msgs in gg.wf package
            "gg.wf.rpc": gg.util.log.ERROR   // but only errors in rpc package
        }
    }      

Added node->[list of nodes] optimizer rule.

Switched node location from "clientonly" flag to "location = client/server" key/val pair.

Wrote first version of postgres-source node.  Works unless there are null values in query result:

      {
        layers: [{ geom: "rect"}],
        aes: {
          x: "crime",
          y: "num"
        },
        facets: { y: "day" },
        data: {
          type: "jdbc",
          conn: "postgres://sirrice@localhost:5432/test",
          q: "select day_week as day, computedcrimecode as crime, count(*) as num 
              from crime 
              where computedcrimecode is not null and day_week is not null 
              group by day, crime;"
        },
        opts: {
          width: 1000,
          height: 500
        }
      };

    



June 27, 2013
----------------

Sucessfully switched to simpler model.  Currently

1. On execution, client serializes and registers workflow with server
2. Nodes block until full result set is competed -- no incremental computing
3. Nodes are labeled with the location they should execute (client/server)
4. Workflows are executed via message passing, and edges that cross client/server
   boundaries are serialized and passed.
5. Workflow runner uses a clearing house that figures out what node to pass a dataset off to next.
   Runner has access to a read-only workflow instance.

Next step -- operator to SQL mapping

1. <strike>set server-side only operator</strike>
1. <strike>node->node rule</strike>

Misc

1. Reorganize package hierarchy.
1. util/ is really messy


June 20, 2013
------------------

Talked to Sam, the execution model is too complicated.  Switching to model where

1. each operator consumes and produces a nested array of gg.wf.Data objects
  * run(nestedArray, params) -> nestedArray
    * emits its results
    * returns its results too
  * ready() -> bool
  * Single child nodes
    * exec calls compute on the leaves (each gg.wf.Data object)
    * split transforms each leaf into an array of gg.wf.Data objects
    * join merges the leaf arrays
  * Multi-child nodes
    * barrier takes multiple arrays as input, and sends each array out to the corresponding child nodes
    * multicast "clones" its inputs and sends the clones to the corresponding child nodes
2. no parallelization except within an operator.
   This means each operator is blocking until its complete
3. workflow tracks
  * number of input slots and children for each operator
  * consumes operator output and places them in child slots
  * calls operator.ready()
  * doesnt need to instantiate


June 17, 2013
-------------------

Implemented simple RPC-based barrier and exec using socket.io.  Can run the facet layout algorithm.

Changed the workflow runner to use callback based execution (for rpc nodes).

Need a way to pass static functions (inputSchema, outputSchema, validate) to the server.  In general,
@params may include static functions.  Need an automatic way to identify them.

  * inputSchema
  * defaults
  * outputSchema
  * provenanceCode



June 10, 2013
-------------
* DONE separate facet/graphic layout from rendering
  * layout just computes bounds for containers, render actually creates and styles elements

* DONE Separate specification based data (@params) from values
  derived from data (e.g., yAxisText)
  * @params is stored in the object
  * env stores values derived from data

Serializing a wf Operator

* Methods can be referenced using a function object, or the containing class
  * klass name + params object fully describe a single transform
  * add parent/child/port relationships to serialize a workflow node
* XForm operators can be re-instantiated
  * inputSchema
  * outputSchema
  * provenance stuff
  * defaults
  * compute
  * klassname
* wf nodes simply call compute
* Workflow state
  * children, parents, port relationships

* Create Specs for workflow
* Be able to mark operators as client/server
* Support passing functions or function references to the server
* Differentiate XForm/BForm rpc operators from wf operators
* DONE: Run facet layout algorithm on the server and pass control back
  * Either serialize compute function, or add a pointer to
    retrieve function on the server side
  * Latter needs to unique ID every function


* Validation requires
  * data schema validation
  * environment validation
  * parameter validation


### Distinguishing State

Compute operators

1. only depends on env, data, params
2. params dont change
3. use param.get() to access parameters
4. use env.get()/put() to access runtime values
5. use table to access data
6. certain env variables are guaranteed to exist for certain operator types
   (stat operators have access to scales)
7. everything needs to be JSONable -- has toJSON() and fromJSON()

Workflow operators

1. class properties are all workflow management related
   only "node.params" can be used in the computation
2. compute signature is f(table, env, params)

Params

* Processed spec valuess
* Options
* Distinguish functions that should be called and fuctions that are interpreted as blobs

Env

* Svg elements
* Containers
* Facet values
* Label text

Main SVG dom elements:

    baseSvg
      facetsSvg
        plotSvg
          paneSvg





June 07, 2013
--------------

Lost all the previous notes thanks to stupidity with git.

Switching all operators to be pure functions that only depend on three data
structures that are passed into the operators

1. User defined parameter values.  Assigned at compile time
2. Table(s)
3. Environment values (derived from computation)

This decision was because splitting execution between the browser and backend
is too complex otherwise.



