// Example of running gg in node

var d3 = require('d3');
var _ = require('underscore');
//var gg = require('./gg.js');
var gg = require('./gg2.js');


var linechart = gg.gg({
    layers: [
        { geometry: 'line', mapping: { x: 'd', y: 'r', group: 'subject', color: 'subject'} },
        { geometry: 'point', mapping: {x:'d', y: 'r', group: 'subject', color: 'subject'} },
        { geometry: 'text', mapping: { x: 'd', y: 'r', text: '{d}, {r}' },offsetX: -20 }
    ]
});

gg.sampleData = {};

gg.sampleData.upwardSubjects = (function () {
    var subjects = ['a', 'b', 'c', 'd'];
    var x = 0;
    var y = 0;
    return _.flatten(_.map(_.range(20), function (i) {
        x += 1;//Math.round(Math.random() * 30);
        y += 1;//Math.round(Math.abs(20 - Math.random() * 30));
        return _.map(subjects, function(subject, i) {
            var skew = i + 1;
            return { d: x, r: y * (1 * skew), subject: subject };
        })
    }));
}());

var div = d3.select(document.createElement('div'));
var data = gg.sampleData;
var w    = 1000;
var h    = 800;

linechart.render(w, h, div, data.upwardSubjects);
divhtml = div.html();
var template = " <!doctype html> <html> <head> <meta charset='utf-8'> <title>The Grammar of Graphics</title> <link rel='stylesheet' type='text/css' href='gg.css'/> <script src='json2.js'></script> <script src='jquery-1.7.2.min.js'></script> <script src='d3.v2.min.js'></script> <script src='underscore-min.js'></script> <script src='gg2.js'></script> <script src='data.js'></script> <script src='examples.js'></script> </head> <body> <h1>The Grammar of Graphics</h1> <div id='examples'>" + divhtml + "</div> </body> </html>";
console.log(template);

