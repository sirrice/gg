JSON.prettify = function(o, tabsize, maxlinesize) {
  tabsize = tabsize || 2;
  maxlinesize = maxlinesize || 30;
  var tab = _.times(tabsize, function(){return ' '}).join('');
  var list = prettylist(o, tab, maxlinesize);
  return list.join("\n");
}

// @param tab number of spaces for an indentation level
// return a list of strings, each is one line
var prettylist = function(o, tab, maxlinesize) {

  if (_.isFunction(o)) {
    return "Function";
  } else if (_.isArray(o)) {
    var list = _.map(o, function(v, idx) {
      var sublist = prettylist(v, tab);
      if (idx < o.length-1) {
        sublist[sublist.length-1] += ",";
      }
      return sublist;
    });
    list = _.flatten(list);

    // if the list can fit in one line, then do so
    if (list.join('').length < 30) {
      list = list.join(' ');
      return ["[" + list + "]"];
    }

    // indent each item by one level
    list = _.map(list, function(v) {
      return tab + v;
    });
    list.unshift("[");
    list.push("]");

    return list;

  } else if (_.isObject(o)) {
    var size = _.size(o);
    var idx = 0;
    var onelines = true;
    var list = _.map(o, function(v,k) {
      var vlist = prettylist(v, tab);
      vlist[0] = "\""+k+"\"" + ": " + vlist[0];
      if (idx < size-1) {
        vlist[vlist.length-1] = vlist[vlist.length-1] + ", ";
      }
      onelines = onelines && (vlist.length == 1);
      idx += 1;
      return vlist;
    });
    list = _.flatten(list);

    // if the object can fit in one line, then do so
    if (list.join('').length < maxlinesize && onelines) {
      return ["{" + list.join(" ") + "}"];
    }

    // indent each item by one level
    list = _.map(list, function(v) {
      return tab + v;
    });
    list.unshift("{");
    list.push("}");
    return list;

  }

  return [JSON.stringify(o)];
};

