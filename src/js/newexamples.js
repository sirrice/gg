
var geoms = {
  //area: geom_area,
  //boxplot: geom_boxplot,
  area: geom_area
  ,interval: geom_interval
  ,point: geom_point_1
  ,sum: geom_point_sum
  //,interval: geom_point_interval
  ,radius: geom_point_2
  ,color: geom_point_3
  ,jitter: geom_point_4
  ,line: colored_lines
  ,multiline: colored_lines_multi
  ,boxplot: geom_boxplot
  ,ptinterval: geom_point_interval
  ,dotplot: geom_dotplot
  ,taxi: geom_taxi
  ,bin2d: geom_bin2d
};

var selected_geoms = {
  area: false,
  point: false,
  interval: false,
  boxplot:false,
  //color: true,
  radius: false,
  line: false,
  jitter:false,
  multiline: false,
  ptinterval: false,
  taxi: false,
    bin2d: true

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
    console.log(specs)
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
    var guid = gg.util.Util.hashCode(JSON.stringify(specs));
    console.log(specs)
    if (!specs.data) {
      specs.data = gg.data.Table.fromArray(bigdata, null, 'row')
    }
    //specs.opt = {optimize: true, guid: guid}
    var plot = gg(specs);
    plot.render(ex());
    plot.on("done", function(debug) {

      debug = _.map(debug, function(o, id) {
        return [o['name'], o['cost']]
      })
      debug = _.sortBy(debug, function(o) { return o[1] })
      var cost = gg.util.Util.sum(_.map(debug, function(o){return o[1]}));
      debug = _.map(debug, function(o) {
        console.log(o[0] + "\t\t" + o[1]);
        return {x: o[0], y: o[1]}
      })
      console.log("total cost\t\t" + cost);

      var dspecs = {
        layers: [
          {geom:'rect'}
        ],
        data: debug
      };
      var dplot = gg(dspecs);
      $("#debug").empty()
      dplot.render(d3.select("#debug").append("span"));

    })

    //return;

    var wf = plot.workflow;
    var text = [];
    text.push("digraph G {");
    text.push("graph [rankdir=TD]");
    _.each(wf.graph.edges(), function(edge) {
      var n1 = edge[0];
      var n2 = edge[1];
      var md = edge[2];
      var color = md=="normal"?"black":"green";
      text.push("\""+n1.name + "\" -> \"" + n2.name + "\" [color=\""+color+"\"];");
    })
    text.push("}");
    console.log(text.join("\n"));
  }


  // This file contains the code to define the graphics and then
  // renders them using data randomly generated by data.js.

  $(document).ready(function() {
    Math.seedrandom("zero");
    var gauss = science.stats.distribution.gaussian();


    //
    // Generate random data with float attributes: d, r, g, f, t
    //
    var npts = 100;
    bigdata = _.map(_.range(0, npts), function(d) {
      g = d % 2//Math.floor(Math.random() * 3) + 1;
      f = Math.floor(Math.random() * 3);
      t = Math.floor(Math.random() * 2);
      gauss.variance(d * 30.0 / npts);
      d = Math.floor(d/3)
      e = ((d + gauss())*(2+Math.sin(d/50))) * (g) - (d)
      //e = d

      return {d: d, e: e,  g: g, f:f, t:t};
    });

    setup_sample_data(bigdata);


    setup_queryselect()

    // create and render

    reset_query();
    //render_query();


  });
})(geoms, selected_geoms);

