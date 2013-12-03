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
                       color: "g", "stroke-width": 2
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
                    color: "g", "stroke-opacity": 0.2
                   }
    }


  ]
}

var f500 = function(row) {return Math.floor(row.get("g")/500)*500;};

var geom_dotplot = {
  facets: {x:'t'},
  "layers": [ 
    {
      "aes": { "x": "e" }, 
      "geom": "point", 
      "pos": { "type": "dot", "r": 4 }
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
      color: "f"
    }, "stats": "boxplot"
  }
  ],
  facets: {x: "t"}
};

var geom_area = {
  layers: [{
    geom: {
      type: "area"
    }
    ,aes: {
      x: "d",
      y: "e",
      fill: 't', stroke: 't'
    }
    ,pos: "stack"
    ,stat: 'loess'
    ,scales: { fill: { type: "color" }}
  }]
};


var geom_boxplot =  {
  opts: {optimizer: true, guid: "foobar"},
  debug: {'gg.wf.rule':0, 'gg.wf.flow': 0},
  layers: [{
    aes: {
      color: "g"
      ,y: "d"
      ,x: "{Math.floor(e/200)*200}"
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
}

var geom_interval = {
  layers: [{geom: 'interval'}, {
    geom: { type:"interval", aes: {y: '{total/(1+count)}'} }
   ,stat: "bin"
  }]
  ,aes: {x: 'd', y: 'e', 'fill': 'f',  "fill-opacity": 0.9}
  ,facets: {y: 't', x: 'g'}
};

var geom_interval = {
  "layers": [
    {
      "geom": {
        "type": "rect"
      }, 
      "stat": "bin",scales: {color: 'color'}
    }
  ], 

      "aes": {
        "x": "d", 
        "y": "e", 
        "color": "g"
      }
};

var geom_point_1 = {
  layers:[{ geom: "point"}],
  aes: {x: 'd', y: 'e'}
  // ,facets: {x: 'f', y: 't', ylabel: "T", xlabel: "F"}
  // ,opts: {title: "hi"}
}

var geom_point_sum = {
  layers: [{geom: "point"}]
 ,aes: {x: 'd', y: 'e'}
 ,stat: "bin"

}

var geom_point_interval = {
  layers: [
    {
      geom: "point"
    },
    {
      geom: 'rect',
      stat: 'bin'
    }
  ],
  aes: {
    x: 'd',
    y: 'e',
    color: 'g'
  },
  facets: {y: 't'}
}


var geom_point_2 = {
  layers: [{geom: "point"}]
 ,aes: {x: 'd', y: 'e', r: 'g'}
 ,scales: { r: { range: [2, 10] } }

}

var geom_point_3 = {
  layers: [{geom: "point"}]
 ,aes: {x: 'd', y: 'e', r: 'g', fill: 'g'}
  ,scales: {
    fill: "color",
    r: { range: [2, 10] }
  }

};

var geom_point_4 = {
  layers: [
   { geom: "point" ,pos: { type: 'jitter'} }
  ]
  ,aes: {x: 'd', y: 'e', r: 'g', color: "g"}
  ,scales: {
    fill: "color",
    r: { range: [2, 10] }
  }

};

var colored_lines = {
  layers: [{geom: "line", stat: 'loess'}],
  aes: {
    x: 'd',  y: "e",
    color: "g"
  }
};

var colored_lines_multi = {
  layers: [
  {
  geom: "line",
  pos: "stack"
  },
  {geom: "area"  }
  ],
  aes: {
    x: 'd',  y: "e",
    color: "g"
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



var geom_taxi = {
  debug: {'gg.wf.std': 0},
  opts: { uri: 'http://localhost:8881' },
  data: {
    type: 'jdbc',
    q: "select date_trunc('hour', pickup_time) as x, count(*) as y from pickups where pickup_time >= '2012-5-1' and pickup_time < '2012-5-3' group by x order by x",
    uri: "postgresql://localhost/bigdata"
  },
  layers: [{geom: "point"}],
  aes: { x: "{new Date(x)}", y: "{parseInt(y)}" }
         
}


var geom_bin2d = {
  "layers": [
    {
      "geom": {
        "type": "bin2d", aes: {color: 'sum'}
      }, stat: "bin2d"
    }
  ], 
  "aes": {
    "x": "d", 
    "y": "e",
    z: 1
  }, facets: {x: 'g'}
} ;
