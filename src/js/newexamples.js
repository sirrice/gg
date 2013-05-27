/*
 {"layers":[{
  "geom": "boxplot",
  "aes": {
    "y": "e",
   "x": "{Math.floor(d/25)*25}",
"group": "{{fill: Math.floor(d/25)*25}}"
  }, "stat": "boxplot", "scales": {"fill":"color"}
},
{ "geom": "point", "aes": {"x":"d", "y": "e", "fill": "f"}},
{ "geom": "line", "aes": {"x":"d", "y": "e"}, "stat": "loess"},
{ "geom": "line", "aes": {"x":"d", "y":"e"}}
]
}
*/


// Crazy Spec
//
var crazy = {
  "opts": { "title": "baller plot!" }
  ,
    facets: {y: "t", x: "f"},
    layers: [
    { geom:{
                type: "rect", aes: {y: "{total/100}"}},
      aes: {
            x: "d",
                y: "e"
                    },
        stat: "bin"
    },
    { geom: "boxplot",
        aes: {
                   x: function(row) {return Math.floor(row.get('d') / 500) * 500;},
                       y: "e"
                           }, stat: "boxplot"
    },
    {
        "geom": "line",
          "aes": {
                "x": "d",
                    "y": "e",
                       group: {color: "g", "stroke-width": 2}
                  },
             stat: {type:"loess", bw: 0.3, acc: 1e-12},
               scales: {
                    stroke: {type: "color", range: ["black", "red", "green"]}
                              }
    },


    {
        "geom": "line",
          "aes": {
                "x": "d",
                    "y": "e",
                       group: {color: "g", "stroke-opacity": 0.2}
                   }
    }


  ]
}

var geom_boxplot2 =
{
  layers:[
  {
    "geom": "boxplot",
    "aes": {
      "x": "f",
      "y": "e",
      "group": { color: "f"}
    }, "stats": "boxplot"
  },

  {
   "geom": "point",
   "aes": {
     x: 'g',
     y: 'e',
     group: {color: 'g'}
   }
  },

   {
     geom: "line",
     aes: {
       x: "d",
       y: "e"
     }
   }
  ],
  facets: {x: "t"}
};
//geom_boxplot2.layers = [geom_boxplot2.layers[0]];
delete geom_boxplot2.facets;

var geom_area = {
  geom: {
    type: "area",
    aes: {
      x: "d",
      y: "e",
      group: "{{fill: t, stroke: t}}"
    }
  }
  ,pos: "stack"
  ,scales: { fill: { type: "color" }}
};

var geom_boxplot =  {
  geom: { type: "boxplot",
          aes: {
             x: '{String(group)+"q"}',
             fill: "group",
             stroke: "group" }
        }
 ,stat: { type: "boxplot", aes: {group: 't', x: 'e'} }
 ,scales: {
    y: {type: 'linear'},//, lim: [0, 500]},
    r: {type: 'linear', range: [3,6]},
    fill: {type: "color"},
    stroke: {type: "color"}
  }
};

var geom_interval = {
  geom: { type:"interval", aes: {y: '{total/(1+count)}'} }
 ,aes: {x: 'd', y: 'e', 'fill': 'f',  "fill-opacity": 0.9}
 ,stat: "bin"
 //,coord: "yflip"
};

var geom_point_1 = {
  geom: "point"
 ,aes: {x: 'd', y: 'e'}
}

var geom_point_sum = {
  geom: "point"
 ,aes: {x: 'd', y: 'e'}
 ,stat: "bin"

}

var geom_point_interval = {
  geom: "interval"
 ,aes: {x: 'd', y: 'e'}
 ,stat: "bin"
}

var geom_point_2 = {
  geom: "point"
 ,aes: {x: 'd', y: 'e', r: 'g'}
 ,scales: { r: { range: [2, 10] } }

}

var geom_point_3 = {
  geom: "point"
 ,aes: {x: 'd', y: 'e', r: 'g', fill: 'f'}
  ,scales: {
    fill: "color",
    r: { range: [2, 10] }
  }

};

var geom_point_4 = {
  geom: "point"
 ,aes: {x: 'd', y: 'e', r: 'g', color: "f"}
  ,pos: { type: 'jitter'}
  ,scales: {
    fill: "color",
    r: { range: [2, 10] }
  }

};

var colored_lines = {
  geom: "line",
  aes: {
    x: 'd',  y: "e",
    group : {color: "g"}
  },
  pos: "stack"
};




/*  var geom_point_5 = {
  geom: { type:"point"}
 ,aes: {x: 'd', y: 'e', r: 'g', fill: '{g*10 + f}'}
  ,pos: { type: 'jitter', y:0.5, x:0}
  ,stat: "bin"
  ,scales: {
    fill: {type: "color"},
    y: {type: 'linear'},
    r: { range: [1, 5] }
  }

}
*/




var geoms = {
  //area: geom_area,
  //boxplot: geom_boxplot,
  //interval: geom_interval,
  boxplot: geom_boxplot2,
  point: geom_point_1
  ,sum: geom_point_sum
  ,interval: geom_point_interval
  ,radius: geom_point_2
  ,color: geom_point_3
  ,jitter: geom_point_4
  ,line: colored_lines
};

var selected_geoms = {
  point: false,
  boxplot:false,
  line: true

};













;(function (geoms, selected_geoms) {
  var bigdata = [];



  var reset_query = function() {
    var layers = _.map(selected_geoms, function(checked, name){
      if (checked) { return geoms[name]; }
    });
    layers = _.compact(layers)[0]
    var specs = layers;
    /*var specs = {
      layers: layers
    }*/
    $("#query").val(JSON.prettify(specs, 2, 10));
    render_query();
  };

  var render_query = function() {
    var text = $("#query").val();
    eval("var specs = " + text);
    //var specs = JSON.parse(text);
    if(!("layers" in specs)) {
      specs = _.flatten([specs]);
      specs = {layers: specs};
    }
    render(specs);
  }


  var setup_queryselect = function() {
    var controls = $("#controls");
    var geom_controls = $("<div></div>");
    controls.append(geom_controls);

    _.each(geoms, function(gspec, name) {
      var check = $("<input name='foo' id='cb_"+name+"' value='"+name+"' type='radio'/>");
      //var check = $("<input name='foo' id='cb_"+name+"' value='"+name+"' type='checkbox'/>");
      check
        .change(function(){
          var name = $('input[type=radio]:checked').val()
          selected_geoms = {}
          selected_geoms[name] = true;


          reset_query();
        })
    //if (selected_geoms[name])
    //       check.attr("checked", "checked")

      var label = $("<label>")
        .append(check)
        .append($("<span>" + name + "</span>"))

      geom_controls.append(label)

    });

    $("#submit").click(function() {
      render_query();
    });
  }

  var setup_sample_data = function(data, n) {
    if (!data || data.length == 0) return;
    var row = data[0];
    var keys = _.keys(row);
    keys = ['d', 'e', 'g', 'f', 't'];
    var table = $("#sample_data");
    n = Math.min(data.length, n || 5);
    _.each(_.range(n), function(idx) {
      var tr = $("<tr></tr>");
      var row = data[idx];
      _.map(keys, function(key) {
        var td = $("<td></td>")
          .text(row[key]);
        tr.append(td);
      });
      table.append(tr);
    });
  }

  var render = function(specs) {
    var ex   = function () {
      $("#examples").empty();
      return d3.select('#examples').append('span');
    };
    var plot = gg(specs);
    plot.render(ex(), bigdata);

    return;

    var wf = plot.compile();
    var text = [];
    text.push("digraph G {");
    text.push("graph [rankdir=LR]");
    _.each(wf.graph.edges(), function(edge) {
      var n1 = edge[0];
      var n2 = edge[1];
      var md = edge[2].type;
      var color = md=="normal"?"black":"green";
      text.push("\""+n1.name + "\" -> \"" + n2.name + "\" [color=\""+color+"\"];");
    })
    text.push("}");
    //console.log(text.join("\n"));
  }


  // This file contains the code to define the graphics and then
  // renders them using data randomly generated by data.js.

  $(document).ready(function() {
    Math.seedrandom("zero");
    var gauss = science.stats.distribution.gaussian();


    //
    // Generate random data with float attributes: d, r, g, f, t
    //
    var npts = 5000;
    bigdata = _.map(_.range(0, npts), function(d) {
      g = Math.floor(Math.random() * 3) + 1;
      f = Math.floor(Math.random() * 3);
      t = Math.floor(Math.random() * 2);
      gauss.variance(d * 30.0 / npts);

      return {d: Math.floor(d/3), e: ((d + gauss())*(2+Math.sin(d/50))) * (g) - (d),  g: g, f:f, t:t};
    });

    setup_sample_data(bigdata);


    setup_queryselect()

    // create and render

    reset_query();
    //render_query();


  });
})(geoms, selected_geoms);

