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

Current Implementation can render
---------------

Screenshot!

<img src="https://raw.github.com/sirrice/gg/new-model/docs/imgs/screenshot.png"/>



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

- [ ] support params/args in xforms
   -> add @param() to xform method list
- [ ] Support grouping and propogating mapped discrete aesthetics down the workflow
- [ ] allow aesthetics aliases
    color: "attr2"
   actually compiles to
    fill: "attr2"
    stroke: "attr2"


Scales

- [ ] support detecting scales types (color scales esp)

Coordinate System


- [ ] Coordinate systems (esp. pie charts)


Rendering

- [ ] draw facet labels after geometries


Misc

- [ ] name the phases and the operators more consistently and predictably
- [ ] documentation
- [ ] Regularize/rationalize/document use of CSS for controlling appearence.
- [ ] In-browser interactive graphic builder. (REPL?)



Tables

- [ ] support tables as columns (blocker for line charts).
- [ ] add types to tables

# DONE

- [x] allocate panes after computing the a[x]s tick size of y a[x]s to know how much spacing to give
- [x] allow aesthetics with dashes in name (e.g., fill-opacity) in evaled JS scripts
    -> currently var fill-opacity = row['fill-opacity']
- [x] render bars
- [x] in aesthetic mappings, differentiate evaled e[x]ressions and string constants
    -> evaled e[x]ressions are of form: "{ JAVASCRIPT }"
      string values are ""
- [x] fi[x]instantiating barriers
- [x] fi[x]d problem where scales.scale('[x]) returns same gg.scale for all layers
- [x] make stats work
- [x] make positioning work
- [x] make sure retraining scales after positioning works
    -> facets set position range in allocatePanes.  need to make sure if
      ranges are set that they will be used in future.
    -> stop overwriting e[x]sting scales objects?




Original code jacked from [http://gigamonkey.github.com/gg/](http://gigamonkey.github.com/gg/).



