TODO

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

Distinguishing State
--------------------

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



