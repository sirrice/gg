gg
===

Javascript DSL for Grammar of Graphics extended to support interactivity and
backend data-processing support.  Written in coffeescript

Setup
------

Install node

    brew install node

Install gg

    npm install

Install coffeescrip

    ---

Compile

    cake build
    cake release

Current Implementation
---------------

Screenshot!

[<img src="https://raw.github.com/sirrice/gg/new-model/docs/imgs/screenshot.png"/> ](http://bl.ocks.org/sirrice/5653573)



Related Technologies
-----------

* ggplot2 (+ shiny?)
* ggobi
* tableau
* protovis
* perfuse
* cranvas


TODO
------------------

XForms

- Ues a consistent spec for an xform (layers also use this)

    {
      type: STRING
      aes: {
        [aesthetic: MAPPING SPEC]* //
        [group: MAPPING SPEC]      // precede computation with split, follow with join/label
      }
      [param: [STRING | NUMBER | OBJECT | FUNCTION]]*
    }

- Support asynchronous operators (send to thread, send to REST API)
- Support data/table spec option
  - what should the API be?
- support params/args in xforms
   -> add @param() to xform method list
- Support grouping and propogating mapped discrete aesthetics down the workflow
- allow aesthetics aliases
    color: "attr2"
   actually compiles to
    fill: "attr2"
    stroke: "attr2"

Workflow

- support

Scales

- use provenance data to decide the "correct" scales to use for a table column
- allow position scales to use same units/pixel


Coordinate System


- Coordinate systems (esp. pie charts)


Rendering

- draw facet labels after geometries


Misc

- remove nested arrays from tables, and support partition by clauses in xform operators
- name the phases and the operators more consistently and predictably
- documentation
- Regularize/rationalize/document use of CSS for controlling appearence.
- In-browser interactive graphic builder. (REPL?)

Provenance

- add provenance system


Tables

- figure out sane semantics for table mapping if a nested value is mapped



DONE!
-------------

- support detecting scales types (color scales esp)
- FIX COORD SWAP, AND CONSOLIDATE TABLE COLUMNS ONTO SINGLE SCALE OBJECT, TYPED SCHEMAS?
- support tables as columns (blocker for line charts).
- add types to tables
- allocate panes after computing the a[x]s tick size of y a[x]s to know how much spacing to give
- allow aesthetics with dashes in name (e.g., fill-opacity) in evaled JS scripts
    -> currently var fill-opacity = row['fill-opacity']
- render bars
- in aesthetic mappings, differentiate evaled e[x]ressions and string constants
    -> evaled e[x]ressions are of form: "{ JAVASCRIPT }"
      string values are ""
- fix instantiating barriers
- fixed problem where scales.scale('[x]) returns same gg.scale for all layers
- make stats work
- make positioning work
- make sure retraining scales after positioning works
    -> facets set position range in allocatePanes.  need to make sure if
      ranges are set that they will be used in future.
    -> stop overwriting e[x]sting scales objects?




Acknowledgements
-----------

* Original code jacked from [http://gigamonkey.github.com/gg/](http://gigamonkey.github.com/gg/).
* Lots of inspiration from the fantastic [http://ggplot2.org/](ggplot2).
* [http://en.wikipedia.org/wiki/Leland_Wilkinson](Leland Wilkinson's) grammar of graphics is what started this all.



