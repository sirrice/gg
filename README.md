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

<html>
<ggplot2js!doctype html>
<script src="https://raw.github.com/sirrice/gg/new-model/lib/gg.js"></script>
<link rel="stylesheet" type="text/css" href="https://raw.github.com/sirrice/gg/new-model/lib/gg.css">
<script>
;(function () {
  $(document).ready(function() {
    Math.seedrandom("zero");
    var specs = {
      layers: [
        {
          geom: { type:"interval", aes: {y: 'total', r: 'total'} },
          aes: {x: 'd', y: 'r', 'fill': 'f',  "fill-opacity": 0.9},
          stat: "bin"
        }
       ,{
          geom: { type:"point"},
          aes: {x: 'd', y: 'r', fill: '{g*10 + f}', "fill-opacity": 0.4}
        }
      ],
      facets: {x: 'f', y: 'g', xLabel: "custom x facet label", fontSize: "10pt"},
      scales: {
        x: {type: 'linear'},
        y: {type: 'linear'},
        r: {type: 'linear', range: [3,6]}
      },
      opts: {
        title: "Custom plot title!"
      }
    }

    var w    = 800;
    var h    = 600;
    var ex   = function () { return d3.select('#examples').append('span'); };
    var bigdata = _.map(_.range(0, 500), function(d) {
      g = Math.floor(Math.random() * 3);
      f = Math.floor(Math.random() * 3);
      t = Math.floor(Math.random() * 3);
      return {d:d, r: d*100, g: g, f:f, t:t};
    })

    var scatterplot = gg(specs)
    scatterplot.render(w, h, ex(), bigdata)

  });
})();
</script>
<div id="examples"></div>
</ggplot2js!doctype>
</html>

TODOs
---------

- Implement positioners, especially for stacked and side-by-side bar charts.
- Facets.
- Keys for aesthetics other than x and y.
- Size scales for more geometries.
- Coordinate systems (esp. pie charts)
- Regularize/rationalize/document use of CSS for controlling appearence.
- In-browser interactive graphic builder. (REPL?)


Related Technologies
-----------

* ggplot (+ shiny?)
* ggobi
* tableau
* protovis
* perfuse
*


Original code jacked from [http://gigamonkey.github.com/gg/](http://gigamonkey.github.com/gg/).



