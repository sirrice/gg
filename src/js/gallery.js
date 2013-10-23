var all_specs = [
  geom_area
  ,geom_interval
  ,geom_point_1
  ,geom_point_sum
  ,geom_point_interval
  ,geom_point_2
  ,geom_point_3
  ,geom_dotplot
  ,colored_lines
  ,colored_lines_multi
  ,geom_boxplot
  ,geom_boxplot2
];



;(function (all_specs) {

  var render = function(specs) {
    if(!("layers" in specs)) {
      specs = _.flatten([specs]);
      specs = {layers: specs};
    }
    var ex = function () {
      return d3.select("#gallery").append("span");
    };
    specs.data = genData(500);
    if (!specs.opts)  specs.opts = {};
    specs.opts.w = 600;
    specs.opts.h = 400;
    
    var plot = gg(specs);
    plot.render(ex());
  }

  var genData = function(npts) {
    Math.seedrandom("zero");
    var gauss = science.stats.distribution.gaussian();

    bigdata = _.map(_.range(0, npts), function(d) {
      g = Math.floor(Math.random() * 3) + 1;
      f = Math.floor(Math.random() * 3);
      t = Math.floor(Math.random() * 2);
      gauss.variance(d * 30.0 / npts);

      return {d: Math.floor(d/3), e: ((d + gauss())*(2+Math.sin(d/50))) * (g) - (d),  g: g, f:f, t:t};
    });

    return bigdata;
  }


  $(document).ready(function() {
     _.each(all_specs, render);

  });
})(all_specs);



