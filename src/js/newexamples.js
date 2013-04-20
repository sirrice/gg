;(function () {

  // This file contains the code to define the graphics and then
  // renders them using data randomly generated by data.js.

  $(document).ready(function() {
    Math.seedrandom("zero");

    groupf = function(row){
              return {
                color: row.get('t'),
                fill: row.get('t')
              }
            }


    var specs = {
      layers: [

      {
        geom: {
          type: "area",
          aes: {
            x: "d",
            y: "r",
            //group: "{{color: t, fill: t, stroke: t, \"fill-opacity\": 0.4}}"
            group: function(row) {
              t = row.get('t')
              return {
                color: t,
                fill: t,
                stroke: t,
                "fill-opacity": 0.4
              }
            }
          }
        }
        ,pos: "stack"
        ,coord: "flip"
      }
        /*
      ,
      {
        geom: { type: "boxplot", aes: {x: '{String(group)+"q"}', fill: "group", "stroke-width": 2, stroke: "group" } },
        stat: { type: "boxplot", aes: {group: 't', x: 'r'} }
      }
      */
      /*
     ,
      {
        geom: { type:"interval", aes: {y: 'total', r: 'total'} },
        aes: {x: 'd', y: 'r', 'fill': 'f',  "fill-opacity": 0.9},
        stat: "bin",
        coord: "yflip"
      }
      */
      /*
      ,
      {
        geom: { type:"point"}//, aes: {y: 'total', r: 'total', fill: 'red'} }
        ,aes: {x: 'd', y: 'r', r: 'g', fill: '{g*10 + f}', stroke: "black", "fill-opacity": 0.4}
        //,pos: { type: 'jitter', y:0.5, x:0}
        //stat: "bin"

      }
      */

      ],
      //facets: {x: 'f', y: 'g', xLabel: "XFACET!", fontSize: "10pt"},
      scales: {
        x: {type: 'linear'},
        y: {type: 'linear'},//, lim: [0, 500]},
        r: {type: 'linear', range: [3,6]}
      },
      opts: {
        title: "baller plot!"
      }

    }

    console.log(JSON.stringify(specs));



    var w    = 800;
    var h    = 600;
    var ex   = function () { return d3.select('#examples').append('span'); };
    var bigdata = _.map(_.range(0, 50), function(d) {
      g = Math.floor(Math.random() * 2);
      f = Math.floor(Math.random() * 3);
      t = Math.floor(Math.random() * 3);
      return {d:d, r: d + d*Math.random(), g: g, f:f, t:t};
    })

    var scatterplot = gg(specs)
    scatterplot.render(w, h, ex(), bigdata)

  });
})();
