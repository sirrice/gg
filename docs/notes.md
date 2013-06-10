TODO

* separate facet/graphic layout from rendering
  * layout just computes bounds for containers, render actually creates and styles elements

* Separate specification based data (@params) from values derived from data (e.g., yAxisText)
  * @params is stored in the object
  * env stores values derived from data

* Validation requires
  * data schema validation
  * environment validation
  * parameter validation


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

Main Svgs

    baseSvg
      facetsSvg
        plotSvg
          paneSvg

B/XForm and Node operators

* parameters are submitted in spec.params


gg operators



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
