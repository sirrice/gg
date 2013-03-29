;(function () {

  // This file contains the code to define the graphics and then
  // renders them using data randomly generated by data.js.

  $(document).ready(function() {

      var specs = {
        layers: [ {
          geom: { type:"point", aes: {y: 'total', r: 'total', "fill-opacity": 0.6,  fill: 'f'} },
          aes: {x: 'd', y: 'r', 'fill': 'f',  "fill-opacity": 0.9},
          pos: {type: "jitter", scale:0.05},
          stat: "bin"
        } ],
        facets: {x: 'f', y: 'g', fontSize: "15pt"},
        scales: {
          x: {type: 'log'},
          y: {type: 'log'},
          r: {type: 'linear', range: [1,4]}
        }
      }



      var w    = 800;
      var h    = 600;
      var ex   = function () { return d3.select('#examples').append('span'); };
      var bigdata = _.map(_.range(0, 1000), function(d) {
        g = Math.floor(Math.random() * 3);
        f = Math.floor(Math.random() * 3);
        t = Math.floor(Math.random() * 3);
        return {d:d, r: d, g: g, f:f, t:t};
      })

      var scatterplot = gg(specs)
      scatterplot.render(w, h, ex(), bigdata)
  });
})();
