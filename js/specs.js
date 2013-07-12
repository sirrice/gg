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

var f500 = function(row) {return Math.floor(row.get("g")/500)*500;};
var geom_boxplot2 =
{
  layers:[
  {
    "geom": "boxplot",
    "aes": {
      "x": "f",
      "y": "e",
      "group": { color: "f" }
    }, "stats": "boxplot"
  }
  ],
  facets: {x: "t"}
};

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
  layers: [{
    aes: {
      group: { color: "t" }
      ,y: "d"
      ,x: "{Math.floor(e/100)*100}"
    }
   ,geom: { 
      type: "boxplot"
    }
  ,pos: "dodge"
  ,stat: { type: "boxplot" }
  ,scales: {
      y: {type: 'linear', lim: [0, 50]}
      ,r: {type: 'linear', range: [3,6]}
      ,fill: "color"
      ,stroke: "color"
    }
  }]
  ,facets: {x: "g"}
  ,debug: {
    "gg.scale.train.pixel": 0,
    "gg.scale.set": 0
  }
}

var geom_interval = {
  layers: [{
    geom: { type:"interval", aes: {y: '{total/(1+count)}'} }
   ,aes: {x: 'd', y: 'e', 'fill': 'f',  "fill-opacity": 0.9}
   ,stat: "bin"
   //,coord: "yflip"
  }],
  facets: {y: 't', x: 'g'}
};

var geom_point_1 = {layers:[{
  geom: "point"
 ,aes: {x: 'd', y: 'e'}
}], facets: {x: 'f', y: 't', ylabel: "T", xlabel: "F"},
  opts: {title: "hi"}
  }

var geom_point_sum = {
  geom: "point"
 ,aes: {x: 'd', y: 'e'}
 ,stat: "bin"

}

var geom_point_interval = {
  layers: [{
    geom: "interval"
   ,pos: "dodge"
   ,aes: {x: '{Math.floor(d/10.)*10 + "d"}', y: 'e', group: {color: 'g'}}
   ,stat: "bin"
  }],
  facets: {y: 't'}
}


var geom_point_2 = {
  geom: "point"
 ,aes: {x: 'd', y: 'e', r: 'g'}
 ,scales: { r: { range: [2, 10] } }

}

var geom_point_3 = {
  geom: "point"
 ,aes: {x: 'd', y: 'e', r: 'g', fill: 'g'}
  ,scales: {
    fill: "color",
    r: { range: [2, 10] }
  }

};

var geom_point_4 = {
  geom: "point"
 ,aes: {x: 'd', y: 'e', r: 'g', color: "g"}
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
  }
};

var colored_lines_multi = {
  layers: [
  {
  geom: "line",
  pos: "stack"
  },
  {geom: "line"
  }
  ],
  aes: {
    x: 'd',  y: "e",
    group : {color: "g"}
  }
};




var geom_point_5 = {
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




