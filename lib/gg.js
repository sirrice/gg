;(function(e,t,n){function i(n,s){if(!t[n]){if(!e[n]){var o=typeof require=="function"&&require;if(!s&&o)return o(n,!0);if(r)return r(n,!0);throw new Error("Cannot find module '"+n+"'")}var u=t[n]={exports:{}};e[n][0](function(t){var r=e[n][1][t];return i(r?r:t)},u,u.exports)}return t[n].exports}var r=typeof require=="function"&&require;for(var s=0;s<n.length;s++)i(n[s]);return i})({1:[function(require,module,exports){
// shim for using process in browser

var process = module.exports = {};

process.nextTick = (function () {
    var canSetImmediate = typeof window !== 'undefined'
    && window.setImmediate;
    var canPost = typeof window !== 'undefined'
    && window.postMessage && window.addEventListener
    ;

    if (canSetImmediate) {
        return function (f) { return window.setImmediate(f) };
    }

    if (canPost) {
        var queue = [];
        window.addEventListener('message', function (ev) {
            if (ev.source === window && ev.data === 'process-tick') {
                ev.stopPropagation();
                if (queue.length > 0) {
                    var fn = queue.shift();
                    fn();
                }
            }
        }, true);

        return function nextTick(fn) {
            queue.push(fn);
            window.postMessage('process-tick', '*');
        };
    }

    return function nextTick(fn) {
        setTimeout(fn, 0);
    };
})();

process.title = 'browser';
process.browser = true;
process.env = {};
process.argv = [];

process.binding = function (name) {
    throw new Error('process.binding is not supported');
}

// TODO(shtylman)
process.cwd = function () { return '/' };
process.chdir = function (dir) {
    throw new Error('process.chdir is not supported');
};

},{}],2:[function(require,module,exports){
(function(process){if (!process.EventEmitter) process.EventEmitter = function () {};

var EventEmitter = exports.EventEmitter = process.EventEmitter;
var isArray = typeof Array.isArray === 'function'
    ? Array.isArray
    : function (xs) {
        return Object.prototype.toString.call(xs) === '[object Array]'
    }
;
function indexOf (xs, x) {
    if (xs.indexOf) return xs.indexOf(x);
    for (var i = 0; i < xs.length; i++) {
        if (x === xs[i]) return i;
    }
    return -1;
}

// By default EventEmitters will print a warning if more than
// 10 listeners are added to it. This is a useful default which
// helps finding memory leaks.
//
// Obviously not all Emitters should be limited to 10. This function allows
// that to be increased. Set to zero for unlimited.
var defaultMaxListeners = 10;
EventEmitter.prototype.setMaxListeners = function(n) {
  if (!this._events) this._events = {};
  this._events.maxListeners = n;
};


EventEmitter.prototype.emit = function(type) {
  // If there is no 'error' event listener then throw.
  if (type === 'error') {
    if (!this._events || !this._events.error ||
        (isArray(this._events.error) && !this._events.error.length))
    {
      if (arguments[1] instanceof Error) {
        throw arguments[1]; // Unhandled 'error' event
      } else {
        throw new Error("Uncaught, unspecified 'error' event.");
      }
      return false;
    }
  }

  if (!this._events) return false;
  var handler = this._events[type];
  if (!handler) return false;

  if (typeof handler == 'function') {
    switch (arguments.length) {
      // fast cases
      case 1:
        handler.call(this);
        break;
      case 2:
        handler.call(this, arguments[1]);
        break;
      case 3:
        handler.call(this, arguments[1], arguments[2]);
        break;
      // slower
      default:
        var args = Array.prototype.slice.call(arguments, 1);
        handler.apply(this, args);
    }
    return true;

  } else if (isArray(handler)) {
    var args = Array.prototype.slice.call(arguments, 1);

    var listeners = handler.slice();
    for (var i = 0, l = listeners.length; i < l; i++) {
      listeners[i].apply(this, args);
    }
    return true;

  } else {
    return false;
  }
};

// EventEmitter is defined in src/node_events.cc
// EventEmitter.prototype.emit() is also defined there.
EventEmitter.prototype.addListener = function(type, listener) {
  if ('function' !== typeof listener) {
    throw new Error('addListener only takes instances of Function');
  }

  if (!this._events) this._events = {};

  // To avoid recursion in the case that type == "newListeners"! Before
  // adding it to the listeners, first emit "newListeners".
  this.emit('newListener', type, listener);

  if (!this._events[type]) {
    // Optimize the case of one listener. Don't need the extra array object.
    this._events[type] = listener;
  } else if (isArray(this._events[type])) {

    // Check for listener leak
    if (!this._events[type].warned) {
      var m;
      if (this._events.maxListeners !== undefined) {
        m = this._events.maxListeners;
      } else {
        m = defaultMaxListeners;
      }

      if (m && m > 0 && this._events[type].length > m) {
        this._events[type].warned = true;
        console.error('(node) warning: possible EventEmitter memory ' +
                      'leak detected. %d listeners added. ' +
                      'Use emitter.setMaxListeners() to increase limit.',
                      this._events[type].length);
        console.trace();
      }
    }

    // If we've already got an array, just append.
    this._events[type].push(listener);
  } else {
    // Adding the second element, need to change to array.
    this._events[type] = [this._events[type], listener];
  }

  return this;
};

EventEmitter.prototype.on = EventEmitter.prototype.addListener;

EventEmitter.prototype.once = function(type, listener) {
  var self = this;
  self.on(type, function g() {
    self.removeListener(type, g);
    listener.apply(this, arguments);
  });

  return this;
};

EventEmitter.prototype.removeListener = function(type, listener) {
  if ('function' !== typeof listener) {
    throw new Error('removeListener only takes instances of Function');
  }

  // does not use listeners(), so no side effect of creating _events[type]
  if (!this._events || !this._events[type]) return this;

  var list = this._events[type];

  if (isArray(list)) {
    var i = indexOf(list, listener);
    if (i < 0) return this;
    list.splice(i, 1);
    if (list.length == 0)
      delete this._events[type];
  } else if (this._events[type] === listener) {
    delete this._events[type];
  }

  return this;
};

EventEmitter.prototype.removeAllListeners = function(type) {
  if (arguments.length === 0) {
    this._events = {};
    return this;
  }

  // does not use listeners(), so no side effect of creating _events[type]
  if (type && this._events && this._events[type]) this._events[type] = null;
  return this;
};

EventEmitter.prototype.listeners = function(type) {
  if (!this._events) this._events = {};
  if (!this._events[type]) this._events[type] = [];
  if (!isArray(this._events[type])) {
    this._events[type] = [this._events[type]];
  }
  return this._events[type];
};

})(require("__browserify_process"))
},{"__browserify_process":1}],3:[function(require,module,exports){
(function(global){d3=function(){function t(t){return t.target}function n(t){return t.source}function e(t,n){try{for(var e in n)Object.defineProperty(t.prototype,e,{value:n[e],enumerable:!1})}catch(r){t.prototype=n}}function r(t){for(var n=-1,e=t.length,r=[];e>++n;)r.push(t[n]);return r}function u(t){return Array.prototype.slice.call(t)}function i(){}function a(t){return t}function o(){return!0}function c(t){return"function"==typeof t?t:function(){return t}}function l(t,n,e){return function(){var r=e.apply(n,arguments);return arguments.length?t:r}}function f(t){return null!=t&&!isNaN(t)}function s(t){return t.length}function h(t){return t.trim().replace(/\s+/g," ")}function g(t){for(var n=1;t*n%1;)n*=10;return n}function p(t){return 1===t.length?function(n,e){t(null==n?e:null)}:t}function d(t){return t.responseText}function m(t){return JSON.parse(t.responseText)}function v(t){var n=Di.createRange();return n.selectNode(Di.body),n.createContextualFragment(t.responseText)}function y(t){return t.responseXML}function M(){}function b(t){function n(){for(var n,r=e,u=-1,i=r.length;i>++u;)(n=r[u].on)&&n.apply(this,arguments);return t}var e=[],r=new i;return n.on=function(n,u){var i,a=r.get(n);return 2>arguments.length?a&&a.on:(a&&(a.on=null,e=e.slice(0,i=e.indexOf(a)).concat(e.slice(i+1)),r.remove(n)),u&&e.push(r.set(n,{on:u})),t)},n}function x(t,n){return n-(t?Math.ceil(Math.log(t)/Math.LN10):1)}function _(t){return t+""}function w(t,n){var e=Math.pow(10,3*Math.abs(8-n));return{scale:n>8?function(t){return t/e}:function(t){return t*e},symbol:t}}function S(t){return function(n){return 0>=n?0:n>=1?1:t(n)}}function k(t){return function(n){return 1-t(1-n)}}function E(t){return function(n){return.5*(.5>n?t(2*n):2-t(2-2*n))}}function A(t){return t*t}function N(t){return t*t*t}function T(t){if(0>=t)return 0;if(t>=1)return 1;var n=t*t,e=n*t;return 4*(.5>t?e:3*(t-n)+e-.75)}function q(t){return function(n){return Math.pow(n,t)}}function C(t){return 1-Math.cos(t*Ni/2)}function z(t){return Math.pow(2,10*(t-1))}function D(t){return 1-Math.sqrt(1-t*t)}function L(t,n){var e;return 2>arguments.length&&(n=.45),arguments.length?e=n/(2*Ni)*Math.asin(1/t):(t=1,e=n/4),function(r){return 1+t*Math.pow(2,10*-r)*Math.sin(2*(r-e)*Ni/n)}}function F(t){return t||(t=1.70158),function(n){return n*n*((t+1)*n-t)}}function H(t){return 1/2.75>t?7.5625*t*t:2/2.75>t?7.5625*(t-=1.5/2.75)*t+.75:2.5/2.75>t?7.5625*(t-=2.25/2.75)*t+.9375:7.5625*(t-=2.625/2.75)*t+.984375}function j(){qi.event.stopPropagation(),qi.event.preventDefault()}function P(){for(var t,n=qi.event;t=n.sourceEvent;)n=t;return n}function R(t){for(var n=new M,e=0,r=arguments.length;r>++e;)n[arguments[e]]=b(n);return n.of=function(e,r){return function(u){try{var i=u.sourceEvent=qi.event;u.target=t,qi.event=u,n[u.type].apply(e,r)}finally{qi.event=i}}},n}function O(t){var n=[t.a,t.b],e=[t.c,t.d],r=U(n),u=Y(n,e),i=U(I(e,n,-u))||0;n[0]*e[1]<e[0]*n[1]&&(n[0]*=-1,n[1]*=-1,r*=-1,u*=-1),this.rotate=(r?Math.atan2(n[1],n[0]):Math.atan2(-e[0],e[1]))*zi,this.translate=[t.e,t.f],this.scale=[r,i],this.skew=i?Math.atan2(u,i)*zi:0}function Y(t,n){return t[0]*n[0]+t[1]*n[1]}function U(t){var n=Math.sqrt(Y(t,t));return n&&(t[0]/=n,t[1]/=n),n}function I(t,n,e){return t[0]+=e*n[0],t[1]+=e*n[1],t}function V(t){return"transform"==t?qi.interpolateTransform:qi.interpolate}function X(t,n){return n=n-(t=+t)?1/(n-t):0,function(e){return(e-t)*n}}function Z(t,n){return n=n-(t=+t)?1/(n-t):0,function(e){return Math.max(0,Math.min(1,(e-t)*n))}}function B(){}function $(t,n,e){return new J(t,n,e)}function J(t,n,e){this.r=t,this.g=n,this.b=e}function G(t){return 16>t?"0"+Math.max(0,t).toString(16):Math.min(255,t).toString(16)}function K(t,n,e){var r,u,i,a=0,o=0,c=0;if(r=/([a-z]+)\((.*)\)/i.exec(t))switch(u=r[2].split(","),r[1]){case"hsl":return e(parseFloat(u[0]),parseFloat(u[1])/100,parseFloat(u[2])/100);case"rgb":return n(nn(u[0]),nn(u[1]),nn(u[2]))}return(i=aa.get(t))?n(i.r,i.g,i.b):(null!=t&&"#"===t.charAt(0)&&(4===t.length?(a=t.charAt(1),a+=a,o=t.charAt(2),o+=o,c=t.charAt(3),c+=c):7===t.length&&(a=t.substring(1,3),o=t.substring(3,5),c=t.substring(5,7)),a=parseInt(a,16),o=parseInt(o,16),c=parseInt(c,16)),n(a,o,c))}function W(t,n,e){var r,u,i=Math.min(t/=255,n/=255,e/=255),a=Math.max(t,n,e),o=a-i,c=(a+i)/2;return o?(u=.5>c?o/(a+i):o/(2-a-i),r=t==a?(n-e)/o+(e>n?6:0):n==a?(e-t)/o+2:(t-n)/o+4,r*=60):u=r=0,en(r,u,c)}function Q(t,n,e){t=tn(t),n=tn(n),e=tn(e);var r=pn((.4124564*t+.3575761*n+.1804375*e)/fa),u=pn((.2126729*t+.7151522*n+.072175*e)/sa),i=pn((.0193339*t+.119192*n+.9503041*e)/ha);return ln(116*u-16,500*(r-u),200*(u-i))}function tn(t){return.04045>=(t/=255)?t/12.92:Math.pow((t+.055)/1.055,2.4)}function nn(t){var n=parseFloat(t);return"%"===t.charAt(t.length-1)?Math.round(2.55*n):n}function en(t,n,e){return new rn(t,n,e)}function rn(t,n,e){this.h=t,this.s=n,this.l=e}function un(t,n,e){function r(t){return t>360?t-=360:0>t&&(t+=360),60>t?i+(a-i)*t/60:180>t?a:240>t?i+(a-i)*(240-t)/60:i}function u(t){return Math.round(255*r(t))}var i,a;return t%=360,0>t&&(t+=360),n=0>n?0:n>1?1:n,e=0>e?0:e>1?1:e,a=.5>=e?e*(1+n):e+n-e*n,i=2*e-a,$(u(t+120),u(t),u(t-120))}function an(t,n,e){return new on(t,n,e)}function on(t,n,e){this.h=t,this.c=n,this.l=e}function cn(t,n,e){return ln(e,Math.cos(t*=Ci)*n,Math.sin(t)*n)}function ln(t,n,e){return new fn(t,n,e)}function fn(t,n,e){this.l=t,this.a=n,this.b=e}function sn(t,n,e){var r=(t+16)/116,u=r+n/500,i=r-e/200;return u=gn(u)*fa,r=gn(r)*sa,i=gn(i)*ha,$(dn(3.2404542*u-1.5371385*r-.4985314*i),dn(-.969266*u+1.8760108*r+.041556*i),dn(.0556434*u-.2040259*r+1.0572252*i))}function hn(t,n,e){return an(180*(Math.atan2(e,n)/Ni),Math.sqrt(n*n+e*e),t)}function gn(t){return t>.206893034?t*t*t:(t-4/29)/7.787037}function pn(t){return t>.008856?Math.pow(t,1/3):7.787037*t+4/29}function dn(t){return Math.round(255*(.00304>=t?12.92*t:1.055*Math.pow(t,1/2.4)-.055))}function mn(t){return Ii(t,Ma),t}function vn(t){return function(){return pa(t,this)}}function yn(t){return function(){return da(t,this)}}function Mn(t,n){function e(){this.removeAttribute(t)}function r(){this.removeAttributeNS(t.space,t.local)}function u(){this.setAttribute(t,n)}function i(){this.setAttributeNS(t.space,t.local,n)}function a(){var e=n.apply(this,arguments);null==e?this.removeAttribute(t):this.setAttribute(t,e)}function o(){var e=n.apply(this,arguments);null==e?this.removeAttributeNS(t.space,t.local):this.setAttributeNS(t.space,t.local,e)}return t=qi.ns.qualify(t),null==n?t.local?r:e:"function"==typeof n?t.local?o:a:t.local?i:u}function bn(t){return RegExp("(?:^|\\s+)"+qi.requote(t)+"(?:\\s+|$)","g")}function xn(t,n){function e(){for(var e=-1;u>++e;)t[e](this,n)}function r(){for(var e=-1,r=n.apply(this,arguments);u>++e;)t[e](this,r)}t=t.trim().split(/\s+/).map(_n);var u=t.length;return"function"==typeof n?r:e}function _n(t){var n=bn(t);return function(e,r){if(u=e.classList)return r?u.add(t):u.remove(t);var u=e.className,i=null!=u.baseVal,a=i?u.baseVal:u;r?(n.lastIndex=0,n.test(a)||(a=h(a+" "+t),i?u.baseVal=a:e.className=a)):a&&(a=h(a.replace(n," ")),i?u.baseVal=a:e.className=a)}}function wn(t,n,e){function r(){this.style.removeProperty(t)}function u(){this.style.setProperty(t,n,e)}function i(){var r=n.apply(this,arguments);null==r?this.style.removeProperty(t):this.style.setProperty(t,r,e)}return null==n?r:"function"==typeof n?i:u}function Sn(t,n){function e(){delete this[t]}function r(){this[t]=n}function u(){var e=n.apply(this,arguments);null==e?delete this[t]:this[t]=e}return null==n?e:"function"==typeof n?u:r}function kn(t){return{__data__:t}}function En(t){return function(){return ya(this,t)}}function An(t){return arguments.length||(t=qi.ascending),function(n,e){return!n-!e||t(n.__data__,e.__data__)}}function Nn(t,n,e){function r(){var n=this[i];n&&(this.removeEventListener(t,n,n.$),delete this[i])}function u(){function u(t){var e=qi.event;qi.event=t,o[0]=a.__data__;try{n.apply(a,o)}finally{qi.event=e}}var a=this,o=Yi(arguments);r.call(this),this.addEventListener(t,this[i]=u,u.$=e),u._=n}var i="__on"+t,a=t.indexOf(".");return a>0&&(t=t.substring(0,a)),n?u:r}function Tn(t,n){for(var e=0,r=t.length;r>e;e++)for(var u,i=t[e],a=0,o=i.length;o>a;a++)(u=i[a])&&n(u,a,e);return t}function qn(t){return Ii(t,xa),t}function Cn(t,n){return Ii(t,wa),t.id=n,t}function zn(t,n,e,r){var u=t.__transition__||(t.__transition__={active:0,count:0}),a=u[e];if(!a){var o=r.time;return a=u[e]={tween:new i,event:qi.dispatch("start","end"),time:o,ease:r.ease,delay:r.delay,duration:r.duration},++u.count,qi.timer(function(r){function i(r){return u.active>e?l():(u.active=e,h.start.call(t,f,n),a.tween.forEach(function(e,r){(r=r.call(t,f,n))&&d.push(r)}),c(r)||qi.timer(c,0,o),1)}function c(r){if(u.active!==e)return l();for(var i=(r-g)/p,a=s(i),o=d.length;o>0;)d[--o].call(t,a);return i>=1?(l(),h.end.call(t,f,n),1):void 0}function l(){return--u.count?delete u[e]:delete t.__transition__,1}var f=t.__data__,s=a.ease,h=a.event,g=a.delay,p=a.duration,d=[];return r>=g?i(r):qi.timer(i,g,o),1},0,o),a}}function Dn(t){return null==t&&(t=""),function(){this.textContent=t}}function Ln(t,n,e,r){var u=t.id;return Tn(t,"function"==typeof e?function(t,i,a){t.__transition__[u].tween.set(n,r(e.call(t,t.__data__,i,a)))}:(e=r(e),function(t){t.__transition__[u].tween.set(n,e)}))}function Fn(){for(var t,n=Date.now(),e=qa;e;)t=n-e.then,t>=e.delay&&(e.flush=e.callback(t)),e=e.next;var r=Hn()-n;r>24?(isFinite(r)&&(clearTimeout(Aa),Aa=setTimeout(Fn,r)),Ea=0):(Ea=1,Ca(Fn))}function Hn(){for(var t=null,n=qa,e=1/0;n;)n.flush?(delete Ta[n.callback.id],n=t?t.next=n.next:qa=n.next):(e=Math.min(e,n.then+n.delay),n=(t=n).next);return e}function jn(t,n){var e=t.ownerSVGElement||t;if(e.createSVGPoint){var r=e.createSVGPoint();if(0>za&&(Li.scrollX||Li.scrollY)){e=qi.select(Di.body).append("svg").style("position","absolute").style("top",0).style("left",0);var u=e[0][0].getScreenCTM();za=!(u.f||u.e),e.remove()}return za?(r.x=n.pageX,r.y=n.pageY):(r.x=n.clientX,r.y=n.clientY),r=r.matrixTransform(t.getScreenCTM().inverse()),[r.x,r.y]}var i=t.getBoundingClientRect();return[n.clientX-i.left-t.clientLeft,n.clientY-i.top-t.clientTop]}function Pn(){}function Rn(t){var n=t[0],e=t[t.length-1];return e>n?[n,e]:[e,n]}function On(t){return t.rangeExtent?t.rangeExtent():Rn(t.range())}function Yn(t,n){var e,r=0,u=t.length-1,i=t[r],a=t[u];return i>a&&(e=r,r=u,u=e,e=i,i=a,a=e),(n=n(a-i))&&(t[r]=n.floor(i),t[u]=n.ceil(a)),t}function Un(){return Math}function In(t,n,e,r){function u(){var u=Math.min(t.length,n.length)>2?Gn:Jn,c=r?Z:X;return a=u(t,n,c,e),o=u(n,t,c,qi.interpolate),i}function i(t){return a(t)}var a,o;return i.invert=function(t){return o(t)},i.domain=function(n){return arguments.length?(t=n.map(Number),u()):t},i.range=function(t){return arguments.length?(n=t,u()):n},i.rangeRound=function(t){return i.range(t).interpolate(qi.interpolateRound)},i.clamp=function(t){return arguments.length?(r=t,u()):r},i.interpolate=function(t){return arguments.length?(e=t,u()):e},i.ticks=function(n){return Bn(t,n)},i.tickFormat=function(n){return $n(t,n)},i.nice=function(){return Yn(t,Xn),u()},i.copy=function(){return In(t,n,e,r)},u()}function Vn(t,n){return qi.rebind(t,n,"range","rangeRound","interpolate","clamp")}function Xn(t){return t=Math.pow(10,Math.round(Math.log(t)/Math.LN10)-1),t&&{floor:function(n){return Math.floor(n/t)*t},ceil:function(n){return Math.ceil(n/t)*t}}}function Zn(t,n){var e=Rn(t),r=e[1]-e[0],u=Math.pow(10,Math.floor(Math.log(r/n)/Math.LN10)),i=n/r*u;return.15>=i?u*=10:.35>=i?u*=5:.75>=i&&(u*=2),e[0]=Math.ceil(e[0]/u)*u,e[1]=Math.floor(e[1]/u)*u+.5*u,e[2]=u,e}function Bn(t,n){return qi.range.apply(qi,Zn(t,n))}function $n(t,n){return qi.format(",."+Math.max(0,-Math.floor(Math.log(Zn(t,n)[2])/Math.LN10+.01))+"f")}function Jn(t,n,e,r){var u=e(t[0],t[1]),i=r(n[0],n[1]);return function(t){return i(u(t))}}function Gn(t,n,e,r){var u=[],i=[],a=0,o=Math.min(t.length,n.length)-1;for(t[o]<t[0]&&(t=t.slice().reverse(),n=n.slice().reverse());o>=++a;)u.push(e(t[a-1],t[a])),i.push(r(n[a-1],n[a]));return function(n){var e=qi.bisect(t,n,1,o)-1;return i[e](u[e](n))}}function Kn(t,n){function e(e){return t(n(e))}var r=n.pow;return e.invert=function(n){return r(t.invert(n))},e.domain=function(u){return arguments.length?(n=0>u[0]?Qn:Wn,r=n.pow,t.domain(u.map(n)),e):t.domain().map(r)},e.nice=function(){return t.domain(Yn(t.domain(),Un)),e},e.ticks=function(){var e=Rn(t.domain()),u=[];if(e.every(isFinite)){var i=Math.floor(e[0]),a=Math.ceil(e[1]),o=r(e[0]),c=r(e[1]);if(n===Qn)for(u.push(r(i));a>i++;)for(var l=9;l>0;l--)u.push(r(i)*l);else{for(;a>i;i++)for(var l=1;10>l;l++)u.push(r(i)*l);u.push(r(i))}for(i=0;o>u[i];i++);for(a=u.length;u[a-1]>c;a--);u=u.slice(i,a)}return u},e.tickFormat=function(t,u){if(2>arguments.length&&(u=Da),!arguments.length)return u;var i,a=Math.max(.1,t/e.ticks().length),o=n===Qn?(i=-1e-12,Math.floor):(i=1e-12,Math.ceil);return function(t){return a>=t/r(o(n(t)+i))?u(t):""}},e.copy=function(){return Kn(t.copy(),n)},Vn(e,t)}function Wn(t){return Math.log(0>t?0:t)/Math.LN10}function Qn(t){return-Math.log(t>0?0:-t)/Math.LN10}function te(t,n){function e(n){return t(r(n))}var r=ne(n),u=ne(1/n);return e.invert=function(n){return u(t.invert(n))},e.domain=function(n){return arguments.length?(t.domain(n.map(r)),e):t.domain().map(u)},e.ticks=function(t){return Bn(e.domain(),t)},e.tickFormat=function(t){return $n(e.domain(),t)},e.nice=function(){return e.domain(Yn(e.domain(),Xn))},e.exponent=function(t){if(!arguments.length)return n;var i=e.domain();return r=ne(n=t),u=ne(1/n),e.domain(i)},e.copy=function(){return te(t.copy(),n)},Vn(e,t)}function ne(t){return function(n){return 0>n?-Math.pow(-n,t):Math.pow(n,t)}}function ee(t,n){function e(n){return a[((u.get(n)||u.set(n,t.push(n)))-1)%a.length]}function r(n,e){return qi.range(t.length).map(function(t){return n+e*t})}var u,a,o;return e.domain=function(r){if(!arguments.length)return t;t=[],u=new i;for(var a,o=-1,c=r.length;c>++o;)u.has(a=r[o])||u.set(a,t.push(a));return e[n.t].apply(e,n.a)},e.range=function(t){return arguments.length?(a=t,o=0,n={t:"range",a:arguments},e):a},e.rangePoints=function(u,i){2>arguments.length&&(i=0);var c=u[0],l=u[1],f=(l-c)/(Math.max(1,t.length-1)+i);return a=r(2>t.length?(c+l)/2:c+f*i/2,f),o=0,n={t:"rangePoints",a:arguments},e},e.rangeBands=function(u,i,c){2>arguments.length&&(i=0),3>arguments.length&&(c=i);var l=u[1]<u[0],f=u[l-0],s=u[1-l],h=(s-f)/(t.length-i+2*c);return a=r(f+h*c,h),l&&a.reverse(),o=h*(1-i),n={t:"rangeBands",a:arguments},e},e.rangeRoundBands=function(u,i,c){2>arguments.length&&(i=0),3>arguments.length&&(c=i);var l=u[1]<u[0],f=u[l-0],s=u[1-l],h=Math.floor((s-f)/(t.length-i+2*c)),g=s-f-(t.length-i)*h;return a=r(f+Math.round(g/2),h),l&&a.reverse(),o=Math.round(h*(1-i)),n={t:"rangeRoundBands",a:arguments},e},e.rangeBand=function(){return o},e.rangeExtent=function(){return Rn(n.a[0])},e.copy=function(){return ee(t,n)},e.domain(t)}function re(t,n){function e(){var e=0,i=n.length;for(u=[];i>++e;)u[e-1]=qi.quantile(t,e/i);return r}function r(t){return isNaN(t=+t)?0/0:n[qi.bisect(u,t)]}var u;return r.domain=function(n){return arguments.length?(t=n.filter(function(t){return!isNaN(t)}).sort(qi.ascending),e()):t},r.range=function(t){return arguments.length?(n=t,e()):n},r.quantiles=function(){return u},r.copy=function(){return re(t,n)},e()}function ue(t,n,e){function r(n){return e[Math.max(0,Math.min(a,Math.floor(i*(n-t))))]}function u(){return i=e.length/(n-t),a=e.length-1,r}var i,a;return r.domain=function(e){return arguments.length?(t=+e[0],n=+e[e.length-1],u()):[t,n]},r.range=function(t){return arguments.length?(e=t,u()):e},r.copy=function(){return ue(t,n,e)},u()}function ie(t,n){function e(e){return n[qi.bisect(t,e)]}return e.domain=function(n){return arguments.length?(t=n,e):t},e.range=function(t){return arguments.length?(n=t,e):n},e.copy=function(){return ie(t,n)},e}function ae(t){function n(t){return+t}return n.invert=n,n.domain=n.range=function(e){return arguments.length?(t=e.map(n),n):t},n.ticks=function(n){return Bn(t,n)},n.tickFormat=function(n){return $n(t,n)},n.copy=function(){return ae(t)},n}function oe(t){return t.innerRadius}function ce(t){return t.outerRadius}function le(t){return t.startAngle}function fe(t){return t.endAngle}function se(t){function n(n){function a(){f.push("M",i(t(s),l))}for(var o,f=[],s=[],h=-1,g=n.length,p=c(e),d=c(r);g>++h;)u.call(this,o=n[h],h)?s.push([+p.call(this,o,h),+d.call(this,o,h)]):s.length&&(a(),s=[]);return s.length&&a(),f.length?f.join(""):null}var e=he,r=ge,u=o,i=pe,a=i.key,l=.7;return n.x=function(t){return arguments.length?(e=t,n):e},n.y=function(t){return arguments.length?(r=t,n):r},n.defined=function(t){return arguments.length?(u=t,n):u},n.interpolate=function(t){return arguments.length?(a="function"==typeof t?i=t:(i=Oa.get(t)||pe).key,n):a},n.tension=function(t){return arguments.length?(l=t,n):l},n}function he(t){return t[0]}function ge(t){return t[1]}function pe(t){return t.join("L")}function de(t){return pe(t)+"Z"}function me(t){for(var n=0,e=t.length,r=t[0],u=[r[0],",",r[1]];e>++n;)u.push("V",(r=t[n])[1],"H",r[0]);return u.join("")}function ve(t){for(var n=0,e=t.length,r=t[0],u=[r[0],",",r[1]];e>++n;)u.push("H",(r=t[n])[0],"V",r[1]);return u.join("")}function ye(t,n){return 4>t.length?pe(t):t[1]+xe(t.slice(1,t.length-1),_e(t,n))}function Me(t,n){return 3>t.length?pe(t):t[0]+xe((t.push(t[0]),t),_e([t[t.length-2]].concat(t,[t[1]]),n))}function be(t,n){return 3>t.length?pe(t):t[0]+xe(t,_e(t,n))}function xe(t,n){if(1>n.length||t.length!=n.length&&t.length!=n.length+2)return pe(t);var e=t.length!=n.length,r="",u=t[0],i=t[1],a=n[0],o=a,c=1;if(e&&(r+="Q"+(i[0]-2*a[0]/3)+","+(i[1]-2*a[1]/3)+","+i[0]+","+i[1],u=t[1],c=2),n.length>1){o=n[1],i=t[c],c++,r+="C"+(u[0]+a[0])+","+(u[1]+a[1])+","+(i[0]-o[0])+","+(i[1]-o[1])+","+i[0]+","+i[1];for(var l=2;n.length>l;l++,c++)i=t[c],o=n[l],r+="S"+(i[0]-o[0])+","+(i[1]-o[1])+","+i[0]+","+i[1]}if(e){var f=t[c];r+="Q"+(i[0]+2*o[0]/3)+","+(i[1]+2*o[1]/3)+","+f[0]+","+f[1]}return r}function _e(t,n){for(var e,r=[],u=(1-n)/2,i=t[0],a=t[1],o=1,c=t.length;c>++o;)e=i,i=a,a=t[o],r.push([u*(a[0]-e[0]),u*(a[1]-e[1])]);return r}function we(t){if(3>t.length)return pe(t);var n=1,e=t.length,r=t[0],u=r[0],i=r[1],a=[u,u,u,(r=t[1])[0]],o=[i,i,i,r[1]],c=[u,",",i];for(Ne(c,a,o);e>++n;)r=t[n],a.shift(),a.push(r[0]),o.shift(),o.push(r[1]),Ne(c,a,o);for(n=-1;2>++n;)a.shift(),a.push(r[0]),o.shift(),o.push(r[1]),Ne(c,a,o);return c.join("")}function Se(t){if(4>t.length)return pe(t);for(var n,e=[],r=-1,u=t.length,i=[0],a=[0];3>++r;)n=t[r],i.push(n[0]),a.push(n[1]);for(e.push(Ae(Ia,i)+","+Ae(Ia,a)),--r;u>++r;)n=t[r],i.shift(),i.push(n[0]),a.shift(),a.push(n[1]),Ne(e,i,a);return e.join("")}function ke(t){for(var n,e,r=-1,u=t.length,i=u+4,a=[],o=[];4>++r;)e=t[r%u],a.push(e[0]),o.push(e[1]);for(n=[Ae(Ia,a),",",Ae(Ia,o)],--r;i>++r;)e=t[r%u],a.shift(),a.push(e[0]),o.shift(),o.push(e[1]),Ne(n,a,o);return n.join("")}function Ee(t,n){var e=t.length-1;if(e)for(var r,u,i=t[0][0],a=t[0][1],o=t[e][0]-i,c=t[e][1]-a,l=-1;e>=++l;)r=t[l],u=l/e,r[0]=n*r[0]+(1-n)*(i+u*o),r[1]=n*r[1]+(1-n)*(a+u*c);return we(t)}function Ae(t,n){return t[0]*n[0]+t[1]*n[1]+t[2]*n[2]+t[3]*n[3]}function Ne(t,n,e){t.push("C",Ae(Ya,n),",",Ae(Ya,e),",",Ae(Ua,n),",",Ae(Ua,e),",",Ae(Ia,n),",",Ae(Ia,e))}function Te(t,n){return(n[1]-t[1])/(n[0]-t[0])}function qe(t){for(var n=0,e=t.length-1,r=[],u=t[0],i=t[1],a=r[0]=Te(u,i);e>++n;)r[n]=(a+(a=Te(u=i,i=t[n+1])))/2;return r[n]=a,r}function Ce(t){for(var n,e,r,u,i=[],a=qe(t),o=-1,c=t.length-1;c>++o;)n=Te(t[o],t[o+1]),1e-6>Math.abs(n)?a[o]=a[o+1]=0:(e=a[o]/n,r=a[o+1]/n,u=e*e+r*r,u>9&&(u=3*n/Math.sqrt(u),a[o]=u*e,a[o+1]=u*r));for(o=-1;c>=++o;)u=(t[Math.min(c,o+1)][0]-t[Math.max(0,o-1)][0])/(6*(1+a[o]*a[o])),i.push([u||0,a[o]*u||0]);return i}function ze(t){return 3>t.length?pe(t):t[0]+xe(t,Ce(t))}function De(t){for(var n,e,r,u=-1,i=t.length;i>++u;)n=t[u],e=n[0],r=n[1]+Pa,n[0]=e*Math.cos(r),n[1]=e*Math.sin(r);return t}function Le(t){function n(n){function o(){m.push("M",l(t(y),g),h,s(t(v.reverse()),g),"Z")}for(var f,p,d,m=[],v=[],y=[],M=-1,b=n.length,x=c(e),_=c(u),w=e===r?function(){return p}:c(r),S=u===i?function(){return d}:c(i);b>++M;)a.call(this,f=n[M],M)?(v.push([p=+x.call(this,f,M),d=+_.call(this,f,M)]),y.push([+w.call(this,f,M),+S.call(this,f,M)])):v.length&&(o(),v=[],y=[]);return v.length&&o(),m.length?m.join(""):null}var e=he,r=he,u=0,i=ge,a=o,l=pe,f=l.key,s=l,h="L",g=.7;return n.x=function(t){return arguments.length?(e=r=t,n):r},n.x0=function(t){return arguments.length?(e=t,n):e},n.x1=function(t){return arguments.length?(r=t,n):r},n.y=function(t){return arguments.length?(u=i=t,n):i},n.y0=function(t){return arguments.length?(u=t,n):u},n.y1=function(t){return arguments.length?(i=t,n):i},n.defined=function(t){return arguments.length?(a=t,n):a},n.interpolate=function(t){return arguments.length?(f="function"==typeof t?l=t:(l=Oa.get(t)||pe).key,s=l.reverse||l,h=l.closed?"M":"L",n):f},n.tension=function(t){return arguments.length?(g=t,n):g},n}function Fe(t){return t.radius}function He(t){return[t.x,t.y]}function je(t){return function(){var n=t.apply(this,arguments),e=n[0],r=n[1]+Pa;return[e*Math.cos(r),e*Math.sin(r)]}}function Pe(){return 64}function Re(){return"circle"}function Oe(t){var n=Math.sqrt(t/Ni);return"M0,"+n+"A"+n+","+n+" 0 1,1 0,"+-n+"A"+n+","+n+" 0 1,1 0,"+n+"Z"}function Ye(t,n){t.attr("transform",function(t){return"translate("+n(t)+",0)"})}function Ue(t,n){t.attr("transform",function(t){return"translate(0,"+n(t)+")"})}function Ie(t,n,e){if(r=[],e&&n.length>1){for(var r,u,i,a=Rn(t.domain()),o=-1,c=n.length,l=(n[1]-n[0])/++e;c>++o;)for(u=e;--u>0;)(i=+n[o]-u*l)>=a[0]&&r.push(i);for(--o,u=0;e>++u&&(i=+n[o]+u*l)<a[1];)r.push(i)}return r}function Ve(t){for(var n=t.source,e=t.target,r=Ze(n,e),u=[n];n!==r;)n=n.parent,u.push(n);for(var i=u.length;e!==r;)u.splice(i,0,e),e=e.parent;return u}function Xe(t){for(var n=[],e=t.parent;null!=e;)n.push(t),t=e,e=e.parent;return n.push(t),n}function Ze(t,n){if(t===n)return t;for(var e=Xe(t),r=Xe(n),u=e.pop(),i=r.pop(),a=null;u===i;)a=u,u=e.pop(),i=r.pop();return a}function Be(t){t.fixed|=2}function $e(t){t.fixed&=-7}function Je(t){t.fixed|=4,t.px=t.x,t.py=t.y}function Ge(t){t.fixed&=-5}function Ke(t,n,e){var r=0,u=0;if(t.charge=0,!t.leaf)for(var i,a=t.nodes,o=a.length,c=-1;o>++c;)i=a[c],null!=i&&(Ke(i,n,e),t.charge+=i.charge,r+=i.charge*i.cx,u+=i.charge*i.cy);if(t.point){t.leaf||(t.point.x+=Math.random()-.5,t.point.y+=Math.random()-.5);var l=n*e[t.point.index];t.charge+=t.pointCharge=l,r+=l*t.point.x,u+=l*t.point.y}t.cx=r/t.charge,t.cy=u/t.charge}function We(t){return t.x}function Qe(t){return t.y}function tr(t,n,e){t.y0=n,t.y=e}function nr(t){return qi.range(t.length)}function er(t){for(var n=-1,e=t[0].length,r=[];e>++n;)r[n]=0;return r}function rr(t){for(var n,e=1,r=0,u=t[0][1],i=t.length;i>e;++e)(n=t[e][1])>u&&(r=e,u=n);return r}function ur(t){return t.reduce(ir,0)}function ir(t,n){return t+n[1]}function ar(t,n){return or(t,Math.ceil(Math.log(n.length)/Math.LN2+1))}function or(t,n){for(var e=-1,r=+t[0],u=(t[1]-r)/n,i=[];n>=++e;)i[e]=u*e+r;return i}function cr(t){return[qi.min(t),qi.max(t)]}function lr(t,n){return qi.rebind(t,n,"sort","children","value"),t.nodes=t,t.links=gr,t}function fr(t){return t.children}function sr(t){return t.value}function hr(t,n){return n.value-t.value}function gr(t){return qi.merge(t.map(function(t){return(t.children||[]).map(function(n){return{source:t,target:n}})}))}function pr(t,n){return t.value-n.value}function dr(t,n){var e=t._pack_next;t._pack_next=n,n._pack_prev=t,n._pack_next=e,e._pack_prev=n}function mr(t,n){t._pack_next=n,n._pack_prev=t}function vr(t,n){var e=n.x-t.x,r=n.y-t.y,u=t.r+n.r;return u*u-e*e-r*r>.001}function yr(t){function n(t){f=Math.min(t.x-t.r,f),s=Math.max(t.x+t.r,s),h=Math.min(t.y-t.r,h),g=Math.max(t.y+t.r,g)}if((e=t.children)&&(l=e.length)){var e,r,u,i,a,o,c,l,f=1/0,s=-1/0,h=1/0,g=-1/0;if(e.forEach(Mr),r=e[0],r.x=-r.r,r.y=0,n(r),l>1&&(u=e[1],u.x=u.r,u.y=0,n(u),l>2))for(i=e[2],_r(r,u,i),n(i),dr(r,i),r._pack_prev=i,dr(i,u),u=r._pack_next,a=3;l>a;a++){_r(r,u,i=e[a]);var p=0,d=1,m=1;for(o=u._pack_next;o!==u;o=o._pack_next,d++)if(vr(o,i)){p=1;break}if(1==p)for(c=r._pack_prev;c!==o._pack_prev&&!vr(c,i);c=c._pack_prev,m++);p?(m>d||d==m&&u.r<r.r?mr(r,u=o):mr(r=c,u),a--):(dr(r,i),u=i,n(i))}var v=(f+s)/2,y=(h+g)/2,M=0;for(a=0;l>a;a++)i=e[a],i.x-=v,i.y-=y,M=Math.max(M,i.r+Math.sqrt(i.x*i.x+i.y*i.y));t.r=M,e.forEach(br)}}function Mr(t){t._pack_next=t._pack_prev=t}function br(t){delete t._pack_next,delete t._pack_prev}function xr(t,n,e,r){var u=t.children;if(t.x=n+=r*t.x,t.y=e+=r*t.y,t.r*=r,u)for(var i=-1,a=u.length;a>++i;)xr(u[i],n,e,r)}function _r(t,n,e){var r=t.r+e.r,u=n.x-t.x,i=n.y-t.y;if(r&&(u||i)){var a=n.r+e.r,o=u*u+i*i;a*=a,r*=r;var c=.5+(r-a)/(2*o),l=Math.sqrt(Math.max(0,2*a*(r+o)-(r-=o)*r-a*a))/(2*o);e.x=t.x+c*u+l*i,e.y=t.y+c*i-l*u}else e.x=t.x+r,e.y=t.y}function wr(t){return 1+qi.max(t,function(t){return t.y})}function Sr(t){return t.reduce(function(t,n){return t+n.x},0)/t.length}function kr(t){var n=t.children;return n&&n.length?kr(n[0]):t}function Er(t){var n,e=t.children;return e&&(n=e.length)?Er(e[n-1]):t}function Ar(t,n){return t.parent==n.parent?1:2}function Nr(t){var n=t.children;return n&&n.length?n[0]:t._tree.thread}function Tr(t){var n,e=t.children;return e&&(n=e.length)?e[n-1]:t._tree.thread}function qr(t,n){var e=t.children;if(e&&(u=e.length))for(var r,u,i=-1;u>++i;)n(r=qr(e[i],n),t)>0&&(t=r);return t}function Cr(t,n){return t.x-n.x}function zr(t,n){return n.x-t.x}function Dr(t,n){return t.depth-n.depth}function Lr(t,n){function e(t,r){var u=t.children;if(u&&(a=u.length))for(var i,a,o=null,c=-1;a>++c;)i=u[c],e(i,o),o=i;n(t,r)}e(t,null)}function Fr(t){for(var n,e=0,r=0,u=t.children,i=u.length;--i>=0;)n=u[i]._tree,n.prelim+=e,n.mod+=e,e+=n.shift+(r+=n.change)}function Hr(t,n,e){t=t._tree,n=n._tree;var r=e/(n.number-t.number);t.change+=r,n.change-=r,n.shift+=e,n.prelim+=e,n.mod+=e}function jr(t,n,e){return t._tree.ancestor.parent==n.parent?t._tree.ancestor:e}function Pr(t){return{x:t.x,y:t.y,dx:t.dx,dy:t.dy}}function Rr(t,n){var e=t.x+n[3],r=t.y+n[0],u=t.dx-n[1]-n[3],i=t.dy-n[0]-n[2];return 0>u&&(e+=u/2,u=0),0>i&&(r+=i/2,i=0),{x:e,y:r,dx:u,dy:i}}function Or(t,n){function e(t,e){return qi.xhr(t,n,e).response(r)}function r(t){return e.parse(t.responseText)}function u(n){return n.map(i).join(t)}function i(t){return a.test(t)?'"'+t.replace(/\"/g,'""')+'"':t}var a=RegExp('["'+t+"\n]"),o=t.charCodeAt(0);return e.parse=function(t){var n;return e.parseRows(t,function(t){return n?n(t):(n=Function("d","return {"+t.map(function(t,n){return JSON.stringify(t)+": d["+n+"]"}).join(",")+"}"),void 0)})},e.parseRows=function(t,n){function e(){if(f>=l)return a;if(u)return u=!1,i;var n=f;if(34===t.charCodeAt(n)){for(var e=n;l>e++;)if(34===t.charCodeAt(e)){if(34!==t.charCodeAt(e+1))break;++e}f=e+2;var r=t.charCodeAt(e+1);return 13===r?(u=!0,10===t.charCodeAt(e+2)&&++f):10===r&&(u=!0),t.substring(n+1,e).replace(/""/g,'"')}for(;l>f;){var r=t.charCodeAt(f++),c=1;if(10===r)u=!0;else if(13===r)u=!0,10===t.charCodeAt(f)&&(++f,++c);else if(r!==o)continue;return t.substring(n,f-c)}return t.substring(n)}for(var r,u,i={},a={},c=[],l=t.length,f=0,s=0;(r=e())!==a;){for(var h=[];r!==i&&r!==a;)h.push(r),r=e();(!n||(h=n(h,s++)))&&c.push(h)}return c},e.format=function(t){return t.map(u).join("\n")},e}function Yr(t,n){ao.hasOwnProperty(t.type)&&ao[t.type](t,n)}function Ur(t,n,e){var r,u=-1,i=t.length-e;for(n.lineStart();i>++u;)r=t[u],n.point(r[0],r[1]);n.lineEnd()}function Ir(t,n){var e=-1,r=t.length;for(n.polygonStart();r>++e;)Ur(t[e],n,1);n.polygonEnd()}function Vr(t){return[Math.atan2(t[1],t[0]),Math.asin(Math.max(-1,Math.min(1,t[2])))]}function Xr(t,n){return Ti>Math.abs(t[0]-n[0])&&Ti>Math.abs(t[1]-n[1])}function Zr(t){var n=t[0],e=t[1],r=Math.cos(e);return[r*Math.cos(n),r*Math.sin(n),Math.sin(e)]}function Br(t,n){return t[0]*n[0]+t[1]*n[1]+t[2]*n[2]}function $r(t,n){return[t[1]*n[2]-t[2]*n[1],t[2]*n[0]-t[0]*n[2],t[0]*n[1]-t[1]*n[0]]}function Jr(t,n){t[0]+=n[0],t[1]+=n[1],t[2]+=n[2]}function Gr(t,n){return[t[0]*n,t[1]*n,t[2]*n]}function Kr(t){var n=Math.sqrt(t[0]*t[0]+t[1]*t[1]+t[2]*t[2]);t[0]/=n,t[1]/=n,t[2]/=n}function Wr(t){function n(n){function r(e,r){e=t(e,r),n.point(e[0],e[1])}function i(){f=0/0,d.point=a,n.lineStart()}function a(r,i){var a=Zr([r,i]),o=t(r,i);e(f,s,l,h,g,p,f=o[0],s=o[1],l=r,h=a[0],g=a[1],p=a[2],u,n),n.point(f,s)}function o(){d.point=r,n.lineEnd()}function c(){var t,r,c,m,v,y,M;i(),d.point=function(n,e){a(t=n,r=e),c=f,m=s,v=h,y=g,M=p,d.point=a},d.lineEnd=function(){e(f,s,l,h,g,p,c,m,t,v,y,M,u,n),d.lineEnd=o,o()}}var l,f,s,h,g,p,d={point:r,lineStart:i,lineEnd:o,polygonStart:function(){n.polygonStart(),d.lineStart=c},polygonEnd:function(){n.polygonEnd(),d.lineStart=i}};return d}function e(n,u,i,a,o,c,l,f,s,h,g,p,d,m){var v=l-n,y=f-u,M=v*v+y*y;if(M>4*r&&d--){var b=a+h,x=o+g,_=c+p,w=Math.sqrt(b*b+x*x+_*_),S=Math.asin(_/=w),k=Ti>Math.abs(Math.abs(_)-1)?(i+s)/2:Math.atan2(x,b),E=t(k,S),A=E[0],N=E[1],T=A-n,q=N-u,C=y*T-v*q;(C*C/M>r||Math.abs((v*T+y*q)/M-.5)>.3)&&(e(n,u,i,a,o,c,A,N,k,b/=w,x/=w,_,d,m),m.point(A,N),e(A,N,k,b,x,_,l,f,s,h,g,p,d,m))}}var r=.5,u=16;return n.precision=function(t){return arguments.length?(u=(r=t*t)>0&&16,n):Math.sqrt(r)},n}function Qr(t,n){function e(t,n){var e=Math.sqrt(i-2*u*Math.sin(n))/u;return[e*Math.sin(t*=u),a-e*Math.cos(t)]}var r=Math.sin(t),u=(r+Math.sin(n))/2,i=1+r*(2*u-r),a=Math.sqrt(i)/u;return e.invert=function(t,n){var e=a-n;return[Math.atan2(t,e)/u,Math.asin((i-(t*t+e*e)*u*u)/(2*u))]},e}function tu(t){function n(t,n){r>t&&(r=t),t>i&&(i=t),u>n&&(u=n),n>a&&(a=n)}function e(){o.point=o.lineEnd=Pn}var r,u,i,a,o={point:n,lineStart:Pn,lineEnd:Pn,polygonStart:function(){o.lineEnd=e},polygonEnd:function(){o.point=n}};return function(n){return a=i=-(r=u=1/0),qi.geo.stream(n,t(o)),[[r,u],[i,a]]}}function nu(t,n){if(!lo){++fo,t*=Ci;var e=Math.cos(n*=Ci);so+=(e*Math.cos(t)-so)/fo,ho+=(e*Math.sin(t)-ho)/fo,go+=(Math.sin(n)-go)/fo}}function eu(){var t,n;lo=1,ru(),lo=2;var e=po.point;po.point=function(r,u){e(t=r,n=u)},po.lineEnd=function(){po.point(t,n),uu(),po.lineEnd=uu}}function ru(){function t(t,u){t*=Ci;var i=Math.cos(u*=Ci),a=i*Math.cos(t),o=i*Math.sin(t),c=Math.sin(u),l=Math.atan2(Math.sqrt((l=e*c-r*o)*l+(l=r*a-n*c)*l+(l=n*o-e*a)*l),n*a+e*o+r*c);fo+=l,so+=l*(n+(n=a)),ho+=l*(e+(e=o)),go+=l*(r+(r=c))}var n,e,r;lo>1||(1>lo&&(lo=1,fo=so=ho=go=0),po.point=function(u,i){u*=Ci;var a=Math.cos(i*=Ci);n=a*Math.cos(u),e=a*Math.sin(u),r=Math.sin(i),po.point=t})}function uu(){po.point=nu}function iu(t,n){var e=Math.cos(t),r=Math.sin(t);return function(u,i,a,o){null!=u?(u=au(e,u),i=au(e,i),(a>0?i>u:u>i)&&(u+=2*a*Ni)):(u=t+2*a*Ni,i=t);for(var c,l=a*n,f=u;a>0?f>i:i>f;f-=l)o.point((c=Vr([e,-r*Math.cos(f),-r*Math.sin(f)]))[0],c[1])}}function au(t,n){var e=Zr(n);e[0]-=t,Kr(e);var r=Math.acos(Math.max(-1,Math.min(1,-e[1])));return((0>-e[2]?-r:r)+2*Math.PI-Ti)%(2*Math.PI)}function ou(t,n,e){return function(r){function u(n,e){t(n,e)&&r.point(n,e)}function i(t,n){m.point(t,n)}function a(){v.point=i,m.lineStart()}function o(){v.point=u,m.lineEnd()}function c(t,n){M.point(t,n),d.push([t,n])}function l(){M.lineStart(),d=[]}function f(){c(d[0][0],d[0][1]),M.lineEnd();var t,n=M.clean(),e=y.buffer(),u=e.length;if(!u)return p=!0,g+=gu(d,-1),d=null,void 0;if(d=null,1&n){t=e[0],h+=gu(t,1);var i,u=t.length-1,a=-1;for(r.lineStart();u>++a;)r.point((i=t[a])[0],i[1]);return r.lineEnd(),void 0}u>1&&2&n&&e.push(e.pop().concat(e.shift())),s.push(e.filter(su))}var s,h,g,p,d,m=n(r),v={point:u,lineStart:a,lineEnd:o,polygonStart:function(){v.point=c,v.lineStart=l,v.lineEnd=f,p=!1,g=h=0,s=[],r.polygonStart()},polygonEnd:function(){v.point=u,v.lineStart=a,v.lineEnd=o,s=qi.merge(s),s.length?cu(s,e,r):(-Ti>h||p&&-Ti>g)&&(r.lineStart(),e(null,null,1,r),r.lineEnd()),r.polygonEnd(),s=null},sphere:function(){r.polygonStart(),r.lineStart(),e(null,null,1,r),r.lineEnd(),r.polygonEnd()}},y=hu(),M=n(y);return v}}function cu(t,n,e){var r=[],u=[];if(t.forEach(function(t){var n=t.length;if(!(1>=n)){var e=t[0],i=t[n-1],a={point:e,points:t,other:null,visited:!1,entry:!0,subject:!0},o={point:e,points:[e],other:a,visited:!1,entry:!1,subject:!1};
a.other=o,r.push(a),u.push(o),a={point:i,points:[i],other:null,visited:!1,entry:!1,subject:!0},o={point:i,points:[i],other:a,visited:!1,entry:!0,subject:!1},a.other=o,r.push(a),u.push(o)}}),u.sort(fu),lu(r),lu(u),r.length)for(var i,a,o,c=r[0];;){for(i=c;i.visited;)if((i=i.next)===c)return;a=i.points,e.lineStart();do{if(i.visited=i.other.visited=!0,i.entry){if(i.subject)for(var l=0;a.length>l;l++)e.point((o=a[l])[0],o[1]);else n(i.point,i.next.point,1,e);i=i.next}else{if(i.subject){a=i.prev.points;for(var l=a.length;--l>=0;)e.point((o=a[l])[0],o[1])}else n(i.point,i.prev.point,-1,e);i=i.prev}i=i.other,a=i.points}while(!i.visited);e.lineEnd()}}function lu(t){if(n=t.length){for(var n,e,r=0,u=t[0];n>++r;)u.next=e=t[r],e.prev=u,u=e;u.next=e=t[0],e.prev=u}}function fu(t,n){return(0>(t=t.point)[0]?t[1]-Ni/2-Ti:Ni/2-t[1])-(0>(n=n.point)[0]?n[1]-Ni/2-Ti:Ni/2-n[1])}function su(t){return t.length>1}function hu(){var t,n=[];return{lineStart:function(){n.push(t=[])},point:function(n,e){t.push([n,e])},lineEnd:Pn,buffer:function(){var e=n;return n=[],t=null,e}}}function gu(t,n){if(!(e=t.length))return 0;for(var e,r,u,i=0,a=0,o=t[0],c=o[0],l=o[1],f=Math.cos(l),s=Math.atan2(n*Math.sin(c)*f,Math.sin(l)),h=1-n*Math.cos(c)*f,g=s;e>++i;)o=t[i],f=Math.cos(l=o[1]),r=Math.atan2(n*Math.sin(c=o[0])*f,Math.sin(l)),u=1-n*Math.cos(c)*f,Ti>Math.abs(h-2)&&Ti>Math.abs(u-2)||(Ti>Math.abs(u)||Ti>Math.abs(h)||(Ti>Math.abs(Math.abs(r-s)-Ni)?u+h>2&&(a+=4*(r-s)):a+=Ti>Math.abs(h-2)?4*(r-g):((3*Ni+r-s)%(2*Ni)-Ni)*(h+u)),g=s,s=r,h=u);return a}function pu(t){var n,e=0/0,r=0/0,u=0/0;return{lineStart:function(){t.lineStart(),n=1},point:function(i,a){var o=i>0?Ni:-Ni,c=Math.abs(i-e);Ti>Math.abs(c-Ni)?(t.point(e,r=(r+a)/2>0?Ni/2:-Ni/2),t.point(u,r),t.lineEnd(),t.lineStart(),t.point(o,r),t.point(i,r),n=0):u!==o&&c>=Ni&&(Ti>Math.abs(e-u)&&(e-=u*Ti),Ti>Math.abs(i-o)&&(i-=o*Ti),r=du(e,r,i,a),t.point(u,r),t.lineEnd(),t.lineStart(),t.point(o,r),n=0),t.point(e=i,r=a),u=o},lineEnd:function(){t.lineEnd(),e=r=0/0},clean:function(){return 2-n}}}function du(t,n,e,r){var u,i,a=Math.sin(t-e);return Math.abs(a)>Ti?Math.atan((Math.sin(n)*(i=Math.cos(r))*Math.sin(e)-Math.sin(r)*(u=Math.cos(n))*Math.sin(t))/(u*i*a)):(n+r)/2}function mu(t,n,e,r){var u;if(null==t)u=e*Ni/2,r.point(-Ni,u),r.point(0,u),r.point(Ni,u),r.point(Ni,0),r.point(Ni,-u),r.point(0,-u),r.point(-Ni,-u),r.point(-Ni,0),r.point(-Ni,u);else if(Math.abs(t[0]-n[0])>Ti){var i=(t[0]<n[0]?1:-1)*Ni;u=e*i/2,r.point(-i,u),r.point(0,u),r.point(i,u)}else r.point(n[0],n[1])}function vu(t){function n(t,n){return Math.cos(t)*Math.cos(n)>i}function e(t){var e,u,i,a;return{lineStart:function(){i=u=!1,a=1},point:function(o,c){var l,f=[o,c],s=n(o,c);!e&&(i=u=s)&&t.lineStart(),s!==u&&(l=r(e,f),(Xr(e,l)||Xr(f,l))&&(f[0]+=Ti,f[1]+=Ti,s=n(f[0],f[1]))),s!==u&&(a=0,(u=s)?(t.lineStart(),l=r(f,e),t.point(l[0],l[1])):(l=r(e,f),t.point(l[0],l[1]),t.lineEnd()),e=l),!s||e&&Xr(e,f)||t.point(f[0],f[1]),e=f},lineEnd:function(){u&&t.lineEnd(),e=null},clean:function(){return a|(i&&u)<<1}}}function r(t,n){var e=Zr(t,0),r=Zr(n,0),u=[1,0,0],a=$r(e,r),o=Br(a,a),c=a[0],l=o-c*c;if(!l)return t;var f=i*o/l,s=-i*c/l,h=$r(u,a),g=Gr(u,f),p=Gr(a,s);Jr(g,p);var d=h,m=Br(g,d),v=Br(d,d),y=Math.sqrt(m*m-v*(Br(g,g)-1)),M=Gr(d,(-m-y)/v);return Jr(M,g),Vr(M)}var u=t*Ci,i=Math.cos(u),a=iu(u,6*Ci);return ou(n,e,a)}function yu(t,n){function e(e,r){return e=t(e,r),n(e[0],e[1])}return t.invert&&n.invert&&(e.invert=function(e,r){return e=n.invert(e,r),e&&t.invert(e[0],e[1])}),e}function Mu(t,n){return[t,n]}function bu(t,n,e){var r=qi.range(t,n-Ti,e).concat(n);return function(t){return r.map(function(n){return[t,n]})}}function xu(t,n,e){var r=qi.range(t,n-Ti,e).concat(n);return function(t){return r.map(function(n){return[n,t]})}}function _u(t,n,e,r){function u(t){var n=Math.sin(t*=g)*p,e=Math.sin(g-t)*p,r=e*l+n*s,u=e*f+n*h,i=e*a+n*c;return[Math.atan2(u,r)/Ci,Math.atan2(i,Math.sqrt(r*r+u*u))/Ci]}var i=Math.cos(n),a=Math.sin(n),o=Math.cos(r),c=Math.sin(r),l=i*Math.cos(t),f=i*Math.sin(t),s=o*Math.cos(e),h=o*Math.sin(e),g=Math.acos(Math.max(-1,Math.min(1,a*c+i*o*Math.cos(e-t)))),p=1/Math.sin(g);return u.distance=g,u}function wu(t,n){return[t/(2*Ni),Math.max(-.5,Math.min(.5,Math.log(Math.tan(Ni/4+n/2))/(2*Ni)))]}function Su(t){return"m0,"+t+"a"+t+","+t+" 0 1,1 0,"+-2*t+"a"+t+","+t+" 0 1,1 0,"+2*t+"z"}function ku(t){var n=Wr(function(n,e){return t([n*zi,e*zi])});return function(t){return t=n(t),{point:function(n,e){t.point(n*Ci,e*Ci)},sphere:function(){t.sphere()},lineStart:function(){t.lineStart()},lineEnd:function(){t.lineEnd()},polygonStart:function(){t.polygonStart()},polygonEnd:function(){t.polygonEnd()}}}}function Eu(){function t(t,n){a.push("M",t,",",n,i)}function n(t,n){a.push("M",t,",",n),o.point=e}function e(t,n){a.push("L",t,",",n)}function r(){o.point=t}function u(){a.push("Z")}var i=Su(4.5),a=[],o={point:t,lineStart:function(){o.point=n},lineEnd:r,polygonStart:function(){o.lineEnd=u},polygonEnd:function(){o.lineEnd=r,o.point=t},pointRadius:function(t){return i=Su(t),o},result:function(){if(a.length){var t=a.join("");return a=[],t}}};return o}function Au(t){function n(n,e){t.moveTo(n,e),t.arc(n,e,a,0,2*Ni)}function e(n,e){t.moveTo(n,e),o.point=r}function r(n,e){t.lineTo(n,e)}function u(){o.point=n}function i(){t.closePath()}var a=4.5,o={point:n,lineStart:function(){o.point=e},lineEnd:u,polygonStart:function(){o.lineEnd=i},polygonEnd:function(){o.lineEnd=u,o.point=n},pointRadius:function(t){return a=t,o},result:Pn};return o}function Nu(){function t(t,n){bo+=u*t-r*n,r=t,u=n}var n,e,r,u;xo.point=function(i,a){xo.point=t,n=r=i,e=u=a},xo.lineEnd=function(){t(n,e)}}function Tu(t,n){lo||(so+=t,ho+=n,++go)}function qu(){function t(t,r){var u=t-n,i=r-e,a=Math.sqrt(u*u+i*i);so+=a*(n+t)/2,ho+=a*(e+r)/2,go+=a,n=t,e=r}var n,e;if(1!==lo){if(!(1>lo))return;lo=1,so=ho=go=0}_o.point=function(r,u){_o.point=t,n=r,e=u}}function Cu(){_o.point=Tu}function zu(){function t(t,n){var e=u*t-r*n;so+=e*(r+t),ho+=e*(u+n),go+=3*e,r=t,u=n}var n,e,r,u;2>lo&&(lo=2,so=ho=go=0),_o.point=function(i,a){_o.point=t,n=r=i,e=u=a},_o.lineEnd=function(){t(n,e)}}function Du(){function t(t,n){t*=Ci,n=n*Ci/2+Ni/4;var e=t-r,a=Math.cos(n),o=Math.sin(n),c=i*o,l=So,f=ko,s=u*a+c*Math.cos(e),h=c*Math.sin(e);So=l*s-f*h,ko=f*s+l*h,r=t,u=a,i=o}var n,e,r,u,i;Eo.point=function(a,o){Eo.point=t,r=(n=a)*Ci,u=Math.cos(o=(e=o)*Ci/2+Ni/4),i=Math.sin(o)},Eo.lineEnd=function(){t(n,e)}}function Lu(t){return Fu(function(){return t})()}function Fu(t){function n(t){return t=a(t[0]*Ci,t[1]*Ci),[t[0]*f+o,c-t[1]*f]}function e(t){return t=a.invert((t[0]-o)/f,(c-t[1])/f),t&&[t[0]*zi,t[1]*zi]}function r(){a=yu(i=ju(d,m,v),u);var t=u(g,p);return o=s-t[0]*f,c=h+t[1]*f,n}var u,i,a,o,c,l=Wr(function(t,n){return t=u(t,n),[t[0]*f+o,c-t[1]*f]}),f=150,s=480,h=250,g=0,p=0,d=0,m=0,v=0,y=mo,M=null;return n.stream=function(t){return Hu(i,y(l(t)))},n.clipAngle=function(t){return arguments.length?(y=null==t?(M=t,mo):vu(M=+t),n):M},n.scale=function(t){return arguments.length?(f=+t,r()):f},n.translate=function(t){return arguments.length?(s=+t[0],h=+t[1],r()):[s,h]},n.center=function(t){return arguments.length?(g=t[0]%360*Ci,p=t[1]%360*Ci,r()):[g*zi,p*zi]},n.rotate=function(t){return arguments.length?(d=t[0]%360*Ci,m=t[1]%360*Ci,v=t.length>2?t[2]%360*Ci:0,r()):[d*zi,m*zi,v*zi]},qi.rebind(n,l,"precision"),function(){return u=t.apply(this,arguments),n.invert=u.invert&&e,r()}}function Hu(t,n){return{point:function(e,r){r=t(e*Ci,r*Ci),e=r[0],n.point(e>Ni?e-2*Ni:-Ni>e?e+2*Ni:e,r[1])},sphere:function(){n.sphere()},lineStart:function(){n.lineStart()},lineEnd:function(){n.lineEnd()},polygonStart:function(){n.polygonStart()},polygonEnd:function(){n.polygonEnd()}}}function ju(t,n,e){return t?n||e?yu(Ru(t),Ou(n,e)):Ru(t):n||e?Ou(n,e):Mu}function Pu(t){return function(n,e){return n+=t,[n>Ni?n-2*Ni:-Ni>n?n+2*Ni:n,e]}}function Ru(t){var n=Pu(t);return n.invert=Pu(-t),n}function Ou(t,n){function e(t,n){var e=Math.cos(n),o=Math.cos(t)*e,c=Math.sin(t)*e,l=Math.sin(n),f=l*r+o*u;return[Math.atan2(c*i-f*a,o*r-l*u),Math.asin(Math.max(-1,Math.min(1,f*i+c*a)))]}var r=Math.cos(t),u=Math.sin(t),i=Math.cos(n),a=Math.sin(n);return e.invert=function(t,n){var e=Math.cos(n),o=Math.cos(t)*e,c=Math.sin(t)*e,l=Math.sin(n),f=l*i-c*a;return[Math.atan2(c*i+l*a,o*r+f*u),Math.asin(Math.max(-1,Math.min(1,f*r-o*u)))]},e}function Yu(t,n){function e(n,e){var r=Math.cos(n),u=Math.cos(e),i=t(r*u);return[i*u*Math.sin(n),i*Math.sin(e)]}return e.invert=function(t,e){var r=Math.sqrt(t*t+e*e),u=n(r),i=Math.sin(u),a=Math.cos(u);return[Math.atan2(t*i,r*a),Math.asin(r&&e*i/r)]},e}function Uu(t,n,e,r){var u,i,a,o,c,l,f;return u=r[t],i=u[0],a=u[1],u=r[n],o=u[0],c=u[1],u=r[e],l=u[0],f=u[1],(f-a)*(o-i)-(c-a)*(l-i)>0}function Iu(t,n,e){return(e[0]-n[0])*(t[1]-n[1])<(e[1]-n[1])*(t[0]-n[0])}function Vu(t,n,e,r){var u=t[0],i=e[0],a=n[0]-u,o=r[0]-i,c=t[1],l=e[1],f=n[1]-c,s=r[1]-l,h=(o*(c-l)-s*(u-i))/(s*a-o*f);return[u+h*a,c+h*f]}function Xu(t,n){var e={list:t.map(function(t,n){return{index:n,x:t[0],y:t[1]}}).sort(function(t,n){return t.y<n.y?-1:t.y>n.y?1:t.x<n.x?-1:t.x>n.x?1:0}),bottomSite:null},r={list:[],leftEnd:null,rightEnd:null,init:function(){r.leftEnd=r.createHalfEdge(null,"l"),r.rightEnd=r.createHalfEdge(null,"l"),r.leftEnd.r=r.rightEnd,r.rightEnd.l=r.leftEnd,r.list.unshift(r.leftEnd,r.rightEnd)},createHalfEdge:function(t,n){return{edge:t,side:n,vertex:null,l:null,r:null}},insert:function(t,n){n.l=t,n.r=t.r,t.r.l=n,t.r=n},leftBound:function(t){var n=r.leftEnd;do n=n.r;while(n!=r.rightEnd&&u.rightOf(n,t));return n=n.l},del:function(t){t.l.r=t.r,t.r.l=t.l,t.edge=null},right:function(t){return t.r},left:function(t){return t.l},leftRegion:function(t){return null==t.edge?e.bottomSite:t.edge.region[t.side]},rightRegion:function(t){return null==t.edge?e.bottomSite:t.edge.region[No[t.side]]}},u={bisect:function(t,n){var e={region:{l:t,r:n},ep:{l:null,r:null}},r=n.x-t.x,u=n.y-t.y,i=r>0?r:-r,a=u>0?u:-u;return e.c=t.x*r+t.y*u+.5*(r*r+u*u),i>a?(e.a=1,e.b=u/r,e.c/=r):(e.b=1,e.a=r/u,e.c/=u),e},intersect:function(t,n){var e=t.edge,r=n.edge;if(!e||!r||e.region.r==r.region.r)return null;var u=e.a*r.b-e.b*r.a;if(1e-10>Math.abs(u))return null;var i,a,o=(e.c*r.b-r.c*e.b)/u,c=(r.c*e.a-e.c*r.a)/u,l=e.region.r,f=r.region.r;l.y<f.y||l.y==f.y&&l.x<f.x?(i=t,a=e):(i=n,a=r);var s=o>=a.region.r.x;return s&&"l"===i.side||!s&&"r"===i.side?null:{x:o,y:c}},rightOf:function(t,n){var e=t.edge,r=e.region.r,u=n.x>r.x;if(u&&"l"===t.side)return 1;if(!u&&"r"===t.side)return 0;if(1===e.a){var i=n.y-r.y,a=n.x-r.x,o=0,c=0;if(!u&&0>e.b||u&&e.b>=0?c=o=i>=e.b*a:(c=n.x+n.y*e.b>e.c,0>e.b&&(c=!c),c||(o=1)),!o){var l=r.x-e.region.l.x;c=e.b*(a*a-i*i)<l*i*(1+2*a/l+e.b*e.b),0>e.b&&(c=!c)}}else{var f=e.c-e.a*n.x,s=n.y-f,h=n.x-r.x,g=f-r.y;c=s*s>h*h+g*g}return"l"===t.side?c:!c},endPoint:function(t,e,r){t.ep[e]=r,t.ep[No[e]]&&n(t)},distance:function(t,n){var e=t.x-n.x,r=t.y-n.y;return Math.sqrt(e*e+r*r)}},i={list:[],insert:function(t,n,e){t.vertex=n,t.ystar=n.y+e;for(var r=0,u=i.list,a=u.length;a>r;r++){var o=u[r];if(!(t.ystar>o.ystar||t.ystar==o.ystar&&n.x>o.vertex.x))break}u.splice(r,0,t)},del:function(t){for(var n=0,e=i.list,r=e.length;r>n&&e[n]!=t;++n);e.splice(n,1)},empty:function(){return 0===i.list.length},nextEvent:function(t){for(var n=0,e=i.list,r=e.length;r>n;++n)if(e[n]==t)return e[n+1];return null},min:function(){var t=i.list[0];return{x:t.vertex.x,y:t.ystar}},extractMin:function(){return i.list.shift()}};r.init(),e.bottomSite=e.list.shift();for(var a,o,c,l,f,s,h,g,p,d,m,v,y,M=e.list.shift();;)if(i.empty()||(a=i.min()),M&&(i.empty()||M.y<a.y||M.y==a.y&&M.x<a.x))o=r.leftBound(M),c=r.right(o),h=r.rightRegion(o),v=u.bisect(h,M),s=r.createHalfEdge(v,"l"),r.insert(o,s),d=u.intersect(o,s),d&&(i.del(o),i.insert(o,d,u.distance(d,M))),o=s,s=r.createHalfEdge(v,"r"),r.insert(o,s),d=u.intersect(s,c),d&&i.insert(s,d,u.distance(d,M)),M=e.list.shift();else{if(i.empty())break;o=i.extractMin(),l=r.left(o),c=r.right(o),f=r.right(c),h=r.leftRegion(o),g=r.rightRegion(c),m=o.vertex,u.endPoint(o.edge,o.side,m),u.endPoint(c.edge,c.side,m),r.del(o),i.del(c),r.del(c),y="l",h.y>g.y&&(p=h,h=g,g=p,y="r"),v=u.bisect(h,g),s=r.createHalfEdge(v,y),r.insert(l,s),u.endPoint(v,No[y],m),d=u.intersect(l,s),d&&(i.del(l),i.insert(l,d,u.distance(d,h))),d=u.intersect(s,f),d&&i.insert(s,d,u.distance(d,h))}for(o=r.right(r.leftEnd);o!=r.rightEnd;o=r.right(o))n(o.edge)}function Zu(){return{leaf:!0,nodes:[],point:null}}function Bu(t,n,e,r,u,i){if(!t(n,e,r,u,i)){var a=.5*(e+u),o=.5*(r+i),c=n.nodes;c[0]&&Bu(t,c[0],e,r,a,o),c[1]&&Bu(t,c[1],a,r,u,o),c[2]&&Bu(t,c[2],e,o,a,i),c[3]&&Bu(t,c[3],a,o,u,i)}}function $u(){this._=new Date(arguments.length>1?Date.UTC.apply(this,arguments):arguments[0])}function Ju(t,n,e,r){for(var u,i,a=0,o=n.length,c=e.length;o>a;){if(r>=c)return-1;if(u=n.charCodeAt(a++),37===u){if(i=Bo[n.charAt(a++)],!i||0>(r=i(t,e,r)))return-1}else if(u!=e.charCodeAt(r++))return-1}return r}function Gu(t){return RegExp("^(?:"+t.map(qi.requote).join("|")+")","i")}function Ku(t){for(var n=new i,e=-1,r=t.length;r>++e;)n.set(t[e].toLowerCase(),e);return n}function Wu(t,n,e){t+="";var r=t.length;return e>r?Array(e-r+1).join(n)+t:t}function Qu(t,n,e){Oo.lastIndex=0;var r=Oo.exec(n.substring(e));return r?e+=r[0].length:-1}function ti(t,n,e){Ro.lastIndex=0;var r=Ro.exec(n.substring(e));return r?e+=r[0].length:-1}function ni(t,n,e){Io.lastIndex=0;var r=Io.exec(n.substring(e));return r?(t.m=Vo.get(r[0].toLowerCase()),e+=r[0].length):-1}function ei(t,n,e){Yo.lastIndex=0;var r=Yo.exec(n.substring(e));return r?(t.m=Uo.get(r[0].toLowerCase()),e+=r[0].length):-1}function ri(t,n,e){return Ju(t,""+Zo.c,n,e)}function ui(t,n,e){return Ju(t,""+Zo.x,n,e)}function ii(t,n,e){return Ju(t,""+Zo.X,n,e)}function ai(t,n,e){$o.lastIndex=0;var r=$o.exec(n.substring(e,e+4));return r?(t.y=+r[0],e+=r[0].length):-1}function oi(t,n,e){$o.lastIndex=0;var r=$o.exec(n.substring(e,e+2));return r?(t.y=ci(+r[0]),e+=r[0].length):-1}function ci(t){return t+(t>68?1900:2e3)}function li(t,n,e){$o.lastIndex=0;var r=$o.exec(n.substring(e,e+2));return r?(t.m=r[0]-1,e+=r[0].length):-1}function fi(t,n,e){$o.lastIndex=0;var r=$o.exec(n.substring(e,e+2));return r?(t.d=+r[0],e+=r[0].length):-1}function si(t,n,e){$o.lastIndex=0;var r=$o.exec(n.substring(e,e+2));return r?(t.H=+r[0],e+=r[0].length):-1}function hi(t,n,e){$o.lastIndex=0;var r=$o.exec(n.substring(e,e+2));return r?(t.M=+r[0],e+=r[0].length):-1}function gi(t,n,e){$o.lastIndex=0;var r=$o.exec(n.substring(e,e+2));return r?(t.S=+r[0],e+=r[0].length):-1}function pi(t,n,e){$o.lastIndex=0;var r=$o.exec(n.substring(e,e+3));return r?(t.L=+r[0],e+=r[0].length):-1}function di(t,n,e){var r=Jo.get(n.substring(e,e+=2).toLowerCase());return null==r?-1:(t.p=r,e)}function mi(t){var n=t.getTimezoneOffset(),e=n>0?"-":"+",r=~~(Math.abs(n)/60),u=Math.abs(n)%60;return e+Wu(r,"0",2)+Wu(u,"0",2)}function vi(t){return t.toISOString()}function yi(t,n,e){function r(n){var e=t(n),r=i(e,1);return r-n>n-e?e:r}function u(e){return n(e=t(new To(e-1)),1),e}function i(t,e){return n(t=new To(+t),e),t}function a(t,r,i){var a=u(t),o=[];if(i>1)for(;r>a;)e(a)%i||o.push(new Date(+a)),n(a,1);else for(;r>a;)o.push(new Date(+a)),n(a,1);return o}function o(t,n,e){try{To=$u;var r=new $u;return r._=t,a(r,n,e)}finally{To=Date}}t.floor=t,t.round=r,t.ceil=u,t.offset=i,t.range=a;var c=t.utc=Mi(t);return c.floor=c,c.round=Mi(r),c.ceil=Mi(u),c.offset=Mi(i),c.range=o,t}function Mi(t){return function(n,e){try{To=$u;var r=new $u;return r._=n,t(r,e)._}finally{To=Date}}}function bi(t,n,e){function r(n){return t(n)}return r.invert=function(n){return _i(t.invert(n))},r.domain=function(n){return arguments.length?(t.domain(n),r):t.domain().map(_i)},r.nice=function(t){return r.domain(Yn(r.domain(),function(){return t}))},r.ticks=function(e,u){var i=xi(r.domain());if("function"!=typeof e){var a=i[1]-i[0],o=a/e,c=qi.bisect(Ko,o);if(c==Ko.length)return n.year(i,e);if(!c)return t.ticks(e).map(_i);Math.log(o/Ko[c-1])<Math.log(Ko[c]/o)&&--c,e=n[c],u=e[1],e=e[0].range}return e(i[0],new Date(+i[1]+1),u)},r.tickFormat=function(){return e},r.copy=function(){return bi(t.copy(),n,e)},qi.rebind(r,t,"range","rangeRound","interpolate","clamp")}function xi(t){var n=t[0],e=t[t.length-1];return e>n?[n,e]:[e,n]}function _i(t){return new Date(t)}function wi(t){return function(n){for(var e=t.length-1,r=t[e];!r[1](n);)r=t[--e];return r[0](n)}}function Si(t){var n=new Date(t,0,1);return n.setFullYear(t),n}function ki(t){var n=t.getFullYear(),e=Si(n),r=Si(n+1);return n+(t-e)/(r-e)}function Ei(t){var n=new Date(Date.UTC(t,0,1));return n.setUTCFullYear(t),n}function Ai(t){var n=t.getUTCFullYear(),e=Ei(n),r=Ei(n+1);return n+(t-e)/(r-e)}var Ni=Math.PI,Ti=1e-6,qi={version:"3.0.6"},Ci=Ni/180,zi=180/Ni,Di=document,Li=window,Fi=".",Hi=",",ji=[3,3];Date.now||(Date.now=function(){return+new Date});try{Di.createElement("div").style.setProperty("opacity",0,"")}catch(Pi){var Ri=Li.CSSStyleDeclaration.prototype,Oi=Ri.setProperty;Ri.setProperty=function(t,n,e){Oi.call(this,t,n+"",e)}}var Yi=u;try{Yi(Di.documentElement.childNodes)[0].nodeType}catch(Ui){Yi=r}var Ii=[].__proto__?function(t,n){t.__proto__=n}:function(t,n){for(var e in n)t[e]=n[e]};qi.map=function(t){var n=new i;for(var e in t)n.set(e,t[e]);return n},e(i,{has:function(t){return Vi+t in this},get:function(t){return this[Vi+t]},set:function(t,n){return this[Vi+t]=n},remove:function(t){return t=Vi+t,t in this&&delete this[t]},keys:function(){var t=[];return this.forEach(function(n){t.push(n)}),t},values:function(){var t=[];return this.forEach(function(n,e){t.push(e)}),t},entries:function(){var t=[];return this.forEach(function(n,e){t.push({key:n,value:e})}),t},forEach:function(t){for(var n in this)n.charCodeAt(0)===Xi&&t.call(this,n.substring(1),this[n])}});var Vi="\0",Xi=Vi.charCodeAt(0);qi.functor=c,qi.rebind=function(t,n){for(var e,r=1,u=arguments.length;u>++r;)t[e=arguments[r]]=l(t,n,n[e]);return t},qi.ascending=function(t,n){return n>t?-1:t>n?1:t>=n?0:0/0},qi.descending=function(t,n){return t>n?-1:n>t?1:n>=t?0:0/0},qi.mean=function(t,n){var e,r=t.length,u=0,i=-1,a=0;if(1===arguments.length)for(;r>++i;)f(e=t[i])&&(u+=(e-u)/++a);else for(;r>++i;)f(e=n.call(t,t[i],i))&&(u+=(e-u)/++a);return a?u:void 0},qi.median=function(t,n){return arguments.length>1&&(t=t.map(n)),t=t.filter(f),t.length?qi.quantile(t.sort(qi.ascending),.5):void 0},qi.min=function(t,n){var e,r,u=-1,i=t.length;if(1===arguments.length){for(;i>++u&&(null==(e=t[u])||e!=e);)e=void 0;for(;i>++u;)null!=(r=t[u])&&e>r&&(e=r)}else{for(;i>++u&&(null==(e=n.call(t,t[u],u))||e!=e);)e=void 0;for(;i>++u;)null!=(r=n.call(t,t[u],u))&&e>r&&(e=r)}return e},qi.max=function(t,n){var e,r,u=-1,i=t.length;if(1===arguments.length){for(;i>++u&&(null==(e=t[u])||e!=e);)e=void 0;for(;i>++u;)null!=(r=t[u])&&r>e&&(e=r)}else{for(;i>++u&&(null==(e=n.call(t,t[u],u))||e!=e);)e=void 0;for(;i>++u;)null!=(r=n.call(t,t[u],u))&&r>e&&(e=r)}return e},qi.extent=function(t,n){var e,r,u,i=-1,a=t.length;if(1===arguments.length){for(;a>++i&&(null==(e=u=t[i])||e!=e);)e=u=void 0;for(;a>++i;)null!=(r=t[i])&&(e>r&&(e=r),r>u&&(u=r))}else{for(;a>++i&&(null==(e=u=n.call(t,t[i],i))||e!=e);)e=void 0;for(;a>++i;)null!=(r=n.call(t,t[i],i))&&(e>r&&(e=r),r>u&&(u=r))}return[e,u]},qi.random={normal:function(t,n){var e=arguments.length;return 2>e&&(n=1),1>e&&(t=0),function(){var e,r,u;do e=2*Math.random()-1,r=2*Math.random()-1,u=e*e+r*r;while(!u||u>1);return t+n*e*Math.sqrt(-2*Math.log(u)/u)}},logNormal:function(){var t=qi.random.normal.apply(qi,arguments);return function(){return Math.exp(t())}},irwinHall:function(t){return function(){for(var n=0,e=0;t>e;e++)n+=Math.random();return n/t}}},qi.sum=function(t,n){var e,r=0,u=t.length,i=-1;if(1===arguments.length)for(;u>++i;)isNaN(e=+t[i])||(r+=e);else for(;u>++i;)isNaN(e=+n.call(t,t[i],i))||(r+=e);return r},qi.quantile=function(t,n){var e=(t.length-1)*n+1,r=Math.floor(e),u=+t[r-1],i=e-r;return i?u+i*(t[r]-u):u},qi.shuffle=function(t){for(var n,e,r=t.length;r;)e=0|Math.random()*r--,n=t[r],t[r]=t[e],t[e]=n;return t},qi.transpose=function(t){return qi.zip.apply(qi,t)},qi.zip=function(){if(!(r=arguments.length))return[];for(var t=-1,n=qi.min(arguments,s),e=Array(n);n>++t;)for(var r,u=-1,i=e[t]=Array(r);r>++u;)i[u]=arguments[u][t];return e},qi.bisector=function(t){return{left:function(n,e,r,u){for(3>arguments.length&&(r=0),4>arguments.length&&(u=n.length);u>r;){var i=r+u>>>1;e>t.call(n,n[i],i)?r=i+1:u=i}return r},right:function(n,e,r,u){for(3>arguments.length&&(r=0),4>arguments.length&&(u=n.length);u>r;){var i=r+u>>>1;t.call(n,n[i],i)>e?u=i:r=i+1}return r}}};var Zi=qi.bisector(function(t){return t});qi.bisectLeft=Zi.left,qi.bisect=qi.bisectRight=Zi.right,qi.nest=function(){function t(n,o){if(o>=a.length)return r?r.call(u,n):e?n.sort(e):n;for(var c,l,f,s=-1,h=n.length,g=a[o++],p=new i,d={};h>++s;)(f=p.get(c=g(l=n[s])))?f.push(l):p.set(c,[l]);return p.forEach(function(n,e){d[n]=t(e,o)}),d}function n(t,e){if(e>=a.length)return t;var r,u=[],i=o[e++];for(r in t)u.push({key:r,values:n(t[r],e)});return i&&u.sort(function(t,n){return i(t.key,n.key)}),u}var e,r,u={},a=[],o=[];return u.map=function(n){return t(n,0)},u.entries=function(e){return n(t(e,0),0)},u.key=function(t){return a.push(t),u},u.sortKeys=function(t){return o[a.length-1]=t,u},u.sortValues=function(t){return e=t,u},u.rollup=function(t){return r=t,u},u},qi.keys=function(t){var n=[];for(var e in t)n.push(e);return n},qi.values=function(t){var n=[];for(var e in t)n.push(t[e]);return n},qi.entries=function(t){var n=[];for(var e in t)n.push({key:e,value:t[e]});return n},qi.permute=function(t,n){for(var e=[],r=-1,u=n.length;u>++r;)e[r]=t[n[r]];return e},qi.merge=function(t){return Array.prototype.concat.apply([],t)},qi.range=function(t,n,e){if(3>arguments.length&&(e=1,2>arguments.length&&(n=t,t=0)),1/0===(n-t)/e)throw Error("infinite range");var r,u=[],i=g(Math.abs(e)),a=-1;if(t*=i,n*=i,e*=i,0>e)for(;(r=t+e*++a)>n;)u.push(r/i);else for(;n>(r=t+e*++a);)u.push(r/i);return u},qi.requote=function(t){return t.replace(Bi,"\\$&")};var Bi=/[\\\^\$\*\+\?\|\[\]\(\)\.\{\}]/g;qi.round=function(t,n){return n?Math.round(t*(n=Math.pow(10,n)))/n:Math.round(t)},qi.xhr=function(t,n,e){function r(){var t=l.status;!t&&l.responseText||t>=200&&300>t||304===t?i.load.call(u,c.call(u,l)):i.error.call(u,l)}var u={},i=qi.dispatch("progress","load","error"),o={},c=a,l=new(Li.XDomainRequest&&/^(http(s)?:)?\/\//.test(t)?XDomainRequest:XMLHttpRequest);return"onload"in l?l.onload=l.onerror=r:l.onreadystatechange=function(){l.readyState>3&&r()},l.onprogress=function(t){var n=qi.event;qi.event=t;try{i.progress.call(u,l)}finally{qi.event=n}},u.header=function(t,n){return t=(t+"").toLowerCase(),2>arguments.length?o[t]:(null==n?delete o[t]:o[t]=n+"",u)},u.mimeType=function(t){return arguments.length?(n=null==t?null:t+"",u):n},u.response=function(t){return c=t,u},["get","post"].forEach(function(t){u[t]=function(){return u.send.apply(u,[t].concat(Yi(arguments)))}}),u.send=function(e,r,i){if(2===arguments.length&&"function"==typeof r&&(i=r,r=null),l.open(e,t,!0),null==n||"accept"in o||(o.accept=n+",*/*"),l.setRequestHeader)for(var a in o)l.setRequestHeader(a,o[a]);return null!=n&&l.overrideMimeType&&l.overrideMimeType(n),null!=i&&u.on("error",i).on("load",function(t){i(null,t)}),l.send(null==r?null:r),u},u.abort=function(){return l.abort(),u},qi.rebind(u,i,"on"),2===arguments.length&&"function"==typeof n&&(e=n,n=null),null==e?u:u.get(p(e))},qi.text=function(){return qi.xhr.apply(qi,arguments).response(d)},qi.json=function(t,n){return qi.xhr(t,"application/json",n).response(m)},qi.html=function(t,n){return qi.xhr(t,"text/html",n).response(v)},qi.xml=function(){return qi.xhr.apply(qi,arguments).response(y)};var $i={svg:"http://www.w3.org/2000/svg",xhtml:"http://www.w3.org/1999/xhtml",xlink:"http://www.w3.org/1999/xlink",xml:"http://www.w3.org/XML/1998/namespace",xmlns:"http://www.w3.org/2000/xmlns/"};qi.ns={prefix:$i,qualify:function(t){var n=t.indexOf(":"),e=t;return n>=0&&(e=t.substring(0,n),t=t.substring(n+1)),$i.hasOwnProperty(e)?{space:$i[e],local:t}:t}},qi.dispatch=function(){for(var t=new M,n=-1,e=arguments.length;e>++n;)t[arguments[n]]=b(t);return t},M.prototype.on=function(t,n){var e=t.indexOf("."),r="";return e>0&&(r=t.substring(e+1),t=t.substring(0,e)),2>arguments.length?this[t].on(r):this[t].on(r,n)},qi.format=function(t){var n=Ji.exec(t),e=n[1]||" ",r=n[2]||">",u=n[3]||"",i=n[4]||"",a=n[5],o=+n[6],c=n[7],l=n[8],f=n[9],s=1,h="",g=!1;switch(l&&(l=+l.substring(1)),(a||"0"===e&&"="===r)&&(a=e="0",r="=",c&&(o-=Math.floor((o-1)/4))),f){case"n":c=!0,f="g";break;case"%":s=100,h="%",f="f";break;case"p":s=100,h="%",f="r";break;case"b":case"o":case"x":case"X":i&&(i="0"+f.toLowerCase());case"c":case"d":g=!0,l=0;break;case"s":s=-1,f="r"}"#"===i&&(i=""),"r"!=f||l||(f="g"),f=Gi.get(f)||_;var p=a&&c;return function(t){if(g&&t%1)return"";var n=0>t||0===t&&0>1/t?(t=-t,"-"):u;if(0>s){var d=qi.formatPrefix(t,l);t=d.scale(t),h=d.symbol}else t*=s;t=f(t,l),!a&&c&&(t=Ki(t));var m=i.length+t.length+(p?0:n.length),v=o>m?Array(m=o-m+1).join(e):"";return p&&(t=Ki(v+t)),Fi&&t.replace(".",Fi),n+=i,("<"===r?n+t+v:">"===r?v+n+t:"^"===r?v.substring(0,m>>=1)+n+t+v.substring(m):n+(p?t:v+t))+h}};var Ji=/(?:([^{])?([<>=^]))?([+\- ])?(#)?(0)?([0-9]+)?(,)?(\.[0-9]+)?([a-zA-Z%])?/,Gi=qi.map({b:function(t){return t.toString(2)},c:function(t){return String.fromCharCode(t)},o:function(t){return t.toString(8)},x:function(t){return t.toString(16)},X:function(t){return t.toString(16).toUpperCase()},g:function(t,n){return t.toPrecision(n)},e:function(t,n){return t.toExponential(n)},f:function(t,n){return t.toFixed(n)},r:function(t,n){return(t=qi.round(t,x(t,n))).toFixed(Math.max(0,Math.min(20,x(t*(1+1e-15),n))))}}),Ki=a;if(ji){var Wi=ji.length;Ki=function(t){for(var n=t.lastIndexOf("."),e=n>=0?"."+t.substring(n+1):(n=t.length,""),r=[],u=0,i=ji[0];n>0&&i>0;)r.push(t.substring(n-=i,n+i)),i=ji[u=(u+1)%Wi];return r.reverse().join(Hi||"")+e}}var Qi=["y","z","a","f","p","n","µ","m","","k","M","G","T","P","E","Z","Y"].map(w);qi.formatPrefix=function(t,n){var e=0;return t&&(0>t&&(t*=-1),n&&(t=qi.round(t,x(t,n))),e=1+Math.floor(1e-12+Math.log(t)/Math.LN10),e=Math.max(-24,Math.min(24,3*Math.floor((0>=e?e+1:e-1)/3)))),Qi[8+e/3]};var ta=function(){return a},na=qi.map({linear:ta,poly:q,quad:function(){return A},cubic:function(){return N},sin:function(){return C},exp:function(){return z},circle:function(){return D},elastic:L,back:F,bounce:function(){return H}}),ea=qi.map({"in":a,out:k,"in-out":E,"out-in":function(t){return E(k(t))}});qi.ease=function(t){var n=t.indexOf("-"),e=n>=0?t.substring(0,n):t,r=n>=0?t.substring(n+1):"in";return e=na.get(e)||ta,r=ea.get(r)||a,S(r(e.apply(null,Array.prototype.slice.call(arguments,1))))},qi.event=null,qi.transform=function(t){var n=Di.createElementNS(qi.ns.prefix.svg,"g");return(qi.transform=function(t){n.setAttribute("transform",t);var e=n.transform.baseVal.consolidate();return new O(e?e.matrix:ra)})(t)},O.prototype.toString=function(){return"translate("+this.translate+")rotate("+this.rotate+")skewX("+this.skew+")scale("+this.scale+")"};var ra={a:1,b:0,c:0,d:1,e:0,f:0};qi.interpolate=function(t,n){for(var e,r=qi.interpolators.length;--r>=0&&!(e=qi.interpolators[r](t,n)););return e},qi.interpolateNumber=function(t,n){return n-=t,function(e){return t+n*e}},qi.interpolateRound=function(t,n){return n-=t,function(e){return Math.round(t+n*e)}},qi.interpolateString=function(t,n){var e,r,u,i,a,o=0,c=0,l=[],f=[];for(ua.lastIndex=0,r=0;e=ua.exec(n);++r)e.index&&l.push(n.substring(o,c=e.index)),f.push({i:l.length,x:e[0]}),l.push(null),o=ua.lastIndex;for(n.length>o&&l.push(n.substring(o)),r=0,i=f.length;(e=ua.exec(t))&&i>r;++r)if(a=f[r],a.x==e[0]){if(a.i)if(null==l[a.i+1])for(l[a.i-1]+=a.x,l.splice(a.i,1),u=r+1;i>u;++u)f[u].i--;else for(l[a.i-1]+=a.x+l[a.i+1],l.splice(a.i,2),u=r+1;i>u;++u)f[u].i-=2;else if(null==l[a.i+1])l[a.i]=a.x;else for(l[a.i]=a.x+l[a.i+1],l.splice(a.i+1,1),u=r+1;i>u;++u)f[u].i--;f.splice(r,1),i--,r--}else a.x=qi.interpolateNumber(parseFloat(e[0]),parseFloat(a.x));for(;i>r;)a=f.pop(),null==l[a.i+1]?l[a.i]=a.x:(l[a.i]=a.x+l[a.i+1],l.splice(a.i+1,1)),i--;return 1===l.length?null==l[0]?f[0].x:function(){return n}:function(t){for(r=0;i>r;++r)l[(a=f[r]).i]=a.x(t);return l.join("")}},qi.interpolateTransform=function(t,n){var e,r=[],u=[],i=qi.transform(t),a=qi.transform(n),o=i.translate,c=a.translate,l=i.rotate,f=a.rotate,s=i.skew,h=a.skew,g=i.scale,p=a.scale;return o[0]!=c[0]||o[1]!=c[1]?(r.push("translate(",null,",",null,")"),u.push({i:1,x:qi.interpolateNumber(o[0],c[0])},{i:3,x:qi.interpolateNumber(o[1],c[1])})):c[0]||c[1]?r.push("translate("+c+")"):r.push(""),l!=f?(l-f>180?f+=360:f-l>180&&(l+=360),u.push({i:r.push(r.pop()+"rotate(",null,")")-2,x:qi.interpolateNumber(l,f)})):f&&r.push(r.pop()+"rotate("+f+")"),s!=h?u.push({i:r.push(r.pop()+"skewX(",null,")")-2,x:qi.interpolateNumber(s,h)}):h&&r.push(r.pop()+"skewX("+h+")"),g[0]!=p[0]||g[1]!=p[1]?(e=r.push(r.pop()+"scale(",null,",",null,")"),u.push({i:e-4,x:qi.interpolateNumber(g[0],p[0])},{i:e-2,x:qi.interpolateNumber(g[1],p[1])})):(1!=p[0]||1!=p[1])&&r.push(r.pop()+"scale("+p+")"),e=u.length,function(t){for(var n,i=-1;e>++i;)r[(n=u[i]).i]=n.x(t);return r.join("")}},qi.interpolateRgb=function(t,n){t=qi.rgb(t),n=qi.rgb(n);var e=t.r,r=t.g,u=t.b,i=n.r-e,a=n.g-r,o=n.b-u;return function(t){return"#"+G(Math.round(e+i*t))+G(Math.round(r+a*t))+G(Math.round(u+o*t))}},qi.interpolateHsl=function(t,n){t=qi.hsl(t),n=qi.hsl(n);var e=t.h,r=t.s,u=t.l,i=n.h-e,a=n.s-r,o=n.l-u;return i>180?i-=360:-180>i&&(i+=360),function(t){return un(e+i*t,r+a*t,u+o*t)+""}},qi.interpolateLab=function(t,n){t=qi.lab(t),n=qi.lab(n);var e=t.l,r=t.a,u=t.b,i=n.l-e,a=n.a-r,o=n.b-u;return function(t){return sn(e+i*t,r+a*t,u+o*t)+""}},qi.interpolateHcl=function(t,n){t=qi.hcl(t),n=qi.hcl(n);var e=t.h,r=t.c,u=t.l,i=n.h-e,a=n.c-r,o=n.l-u;return i>180?i-=360:-180>i&&(i+=360),function(t){return cn(e+i*t,r+a*t,u+o*t)+""}},qi.interpolateArray=function(t,n){var e,r=[],u=[],i=t.length,a=n.length,o=Math.min(t.length,n.length);for(e=0;o>e;++e)r.push(qi.interpolate(t[e],n[e]));for(;i>e;++e)u[e]=t[e];for(;a>e;++e)u[e]=n[e];return function(t){for(e=0;o>e;++e)u[e]=r[e](t);return u}},qi.interpolateObject=function(t,n){var e,r={},u={};for(e in t)e in n?r[e]=V(e)(t[e],n[e]):u[e]=t[e];for(e in n)e in t||(u[e]=n[e]);return function(t){for(e in r)u[e]=r[e](t);return u}};var ua=/[-+]?(?:\d+\.?\d*|\.?\d+)(?:[eE][-+]?\d+)?/g;qi.interpolators=[qi.interpolateObject,function(t,n){return n instanceof Array&&qi.interpolateArray(t,n)},function(t,n){return("string"==typeof t||"string"==typeof n)&&qi.interpolateString(t+"",n+"")},function(t,n){return("string"==typeof n?aa.has(n)||/^(#|rgb\(|hsl\()/.test(n):n instanceof B)&&qi.interpolateRgb(t,n)},function(t,n){return!isNaN(t=+t)&&!isNaN(n=+n)&&qi.interpolateNumber(t,n)}],B.prototype.toString=function(){return this.rgb()+""},qi.rgb=function(t,n,e){return 1===arguments.length?t instanceof J?$(t.r,t.g,t.b):K(""+t,$,un):$(~~t,~~n,~~e)};var ia=J.prototype=new B;ia.brighter=function(t){t=Math.pow(.7,arguments.length?t:1);var n=this.r,e=this.g,r=this.b,u=30;return n||e||r?(n&&u>n&&(n=u),e&&u>e&&(e=u),r&&u>r&&(r=u),$(Math.min(255,Math.floor(n/t)),Math.min(255,Math.floor(e/t)),Math.min(255,Math.floor(r/t)))):$(u,u,u)},ia.darker=function(t){return t=Math.pow(.7,arguments.length?t:1),$(Math.floor(t*this.r),Math.floor(t*this.g),Math.floor(t*this.b))},ia.hsl=function(){return W(this.r,this.g,this.b)},ia.toString=function(){return"#"+G(this.r)+G(this.g)+G(this.b)};var aa=qi.map({aliceblue:"#f0f8ff",antiquewhite:"#faebd7",aqua:"#00ffff",aquamarine:"#7fffd4",azure:"#f0ffff",beige:"#f5f5dc",bisque:"#ffe4c4",black:"#000000",blanchedalmond:"#ffebcd",blue:"#0000ff",blueviolet:"#8a2be2",brown:"#a52a2a",burlywood:"#deb887",cadetblue:"#5f9ea0",chartreuse:"#7fff00",chocolate:"#d2691e",coral:"#ff7f50",cornflowerblue:"#6495ed",cornsilk:"#fff8dc",crimson:"#dc143c",cyan:"#00ffff",darkblue:"#00008b",darkcyan:"#008b8b",darkgoldenrod:"#b8860b",darkgray:"#a9a9a9",darkgreen:"#006400",darkgrey:"#a9a9a9",darkkhaki:"#bdb76b",darkmagenta:"#8b008b",darkolivegreen:"#556b2f",darkorange:"#ff8c00",darkorchid:"#9932cc",darkred:"#8b0000",darksalmon:"#e9967a",darkseagreen:"#8fbc8f",darkslateblue:"#483d8b",darkslategray:"#2f4f4f",darkslategrey:"#2f4f4f",darkturquoise:"#00ced1",darkviolet:"#9400d3",deeppink:"#ff1493",deepskyblue:"#00bfff",dimgray:"#696969",dimgrey:"#696969",dodgerblue:"#1e90ff",firebrick:"#b22222",floralwhite:"#fffaf0",forestgreen:"#228b22",fuchsia:"#ff00ff",gainsboro:"#dcdcdc",ghostwhite:"#f8f8ff",gold:"#ffd700",goldenrod:"#daa520",gray:"#808080",green:"#008000",greenyellow:"#adff2f",grey:"#808080",honeydew:"#f0fff0",hotpink:"#ff69b4",indianred:"#cd5c5c",indigo:"#4b0082",ivory:"#fffff0",khaki:"#f0e68c",lavender:"#e6e6fa",lavenderblush:"#fff0f5",lawngreen:"#7cfc00",lemonchiffon:"#fffacd",lightblue:"#add8e6",lightcoral:"#f08080",lightcyan:"#e0ffff",lightgoldenrodyellow:"#fafad2",lightgray:"#d3d3d3",lightgreen:"#90ee90",lightgrey:"#d3d3d3",lightpink:"#ffb6c1",lightsalmon:"#ffa07a",lightseagreen:"#20b2aa",lightskyblue:"#87cefa",lightslategray:"#778899",lightslategrey:"#778899",lightsteelblue:"#b0c4de",lightyellow:"#ffffe0",lime:"#00ff00",limegreen:"#32cd32",linen:"#faf0e6",magenta:"#ff00ff",maroon:"#800000",mediumaquamarine:"#66cdaa",mediumblue:"#0000cd",mediumorchid:"#ba55d3",mediumpurple:"#9370db",mediumseagreen:"#3cb371",mediumslateblue:"#7b68ee",mediumspringgreen:"#00fa9a",mediumturquoise:"#48d1cc",mediumvioletred:"#c71585",midnightblue:"#191970",mintcream:"#f5fffa",mistyrose:"#ffe4e1",moccasin:"#ffe4b5",navajowhite:"#ffdead",navy:"#000080",oldlace:"#fdf5e6",olive:"#808000",olivedrab:"#6b8e23",orange:"#ffa500",orangered:"#ff4500",orchid:"#da70d6",palegoldenrod:"#eee8aa",palegreen:"#98fb98",paleturquoise:"#afeeee",palevioletred:"#db7093",papayawhip:"#ffefd5",peachpuff:"#ffdab9",peru:"#cd853f",pink:"#ffc0cb",plum:"#dda0dd",powderblue:"#b0e0e6",purple:"#800080",red:"#ff0000",rosybrown:"#bc8f8f",royalblue:"#4169e1",saddlebrown:"#8b4513",salmon:"#fa8072",sandybrown:"#f4a460",seagreen:"#2e8b57",seashell:"#fff5ee",sienna:"#a0522d",silver:"#c0c0c0",skyblue:"#87ceeb",slateblue:"#6a5acd",slategray:"#708090",slategrey:"#708090",snow:"#fffafa",springgreen:"#00ff7f",steelblue:"#4682b4",tan:"#d2b48c",teal:"#008080",thistle:"#d8bfd8",tomato:"#ff6347",turquoise:"#40e0d0",violet:"#ee82ee",wheat:"#f5deb3",white:"#ffffff",whitesmoke:"#f5f5f5",yellow:"#ffff00",yellowgreen:"#9acd32"});
aa.forEach(function(t,n){aa.set(t,K(n,$,un))}),qi.hsl=function(t,n,e){return 1===arguments.length?t instanceof rn?en(t.h,t.s,t.l):K(""+t,W,en):en(+t,+n,+e)};var oa=rn.prototype=new B;oa.brighter=function(t){return t=Math.pow(.7,arguments.length?t:1),en(this.h,this.s,this.l/t)},oa.darker=function(t){return t=Math.pow(.7,arguments.length?t:1),en(this.h,this.s,t*this.l)},oa.rgb=function(){return un(this.h,this.s,this.l)},qi.hcl=function(t,n,e){return 1===arguments.length?t instanceof on?an(t.h,t.c,t.l):t instanceof fn?hn(t.l,t.a,t.b):hn((t=Q((t=qi.rgb(t)).r,t.g,t.b)).l,t.a,t.b):an(+t,+n,+e)};var ca=on.prototype=new B;ca.brighter=function(t){return an(this.h,this.c,Math.min(100,this.l+la*(arguments.length?t:1)))},ca.darker=function(t){return an(this.h,this.c,Math.max(0,this.l-la*(arguments.length?t:1)))},ca.rgb=function(){return cn(this.h,this.c,this.l).rgb()},qi.lab=function(t,n,e){return 1===arguments.length?t instanceof fn?ln(t.l,t.a,t.b):t instanceof on?cn(t.l,t.c,t.h):Q((t=qi.rgb(t)).r,t.g,t.b):ln(+t,+n,+e)};var la=18,fa=.95047,sa=1,ha=1.08883,ga=fn.prototype=new B;ga.brighter=function(t){return ln(Math.min(100,this.l+la*(arguments.length?t:1)),this.a,this.b)},ga.darker=function(t){return ln(Math.max(0,this.l-la*(arguments.length?t:1)),this.a,this.b)},ga.rgb=function(){return sn(this.l,this.a,this.b)};var pa=function(t,n){return n.querySelector(t)},da=function(t,n){return n.querySelectorAll(t)},ma=Di.documentElement,va=ma.matchesSelector||ma.webkitMatchesSelector||ma.mozMatchesSelector||ma.msMatchesSelector||ma.oMatchesSelector,ya=function(t,n){return va.call(t,n)};"function"==typeof Sizzle&&(pa=function(t,n){return Sizzle(t,n)[0]||null},da=function(t,n){return Sizzle.uniqueSort(Sizzle(t,n))},ya=Sizzle.matchesSelector);var Ma=[];qi.selection=function(){return ba},qi.selection.prototype=Ma,Ma.select=function(t){var n,e,r,u,i=[];"function"!=typeof t&&(t=vn(t));for(var a=-1,o=this.length;o>++a;){i.push(n=[]),n.parentNode=(r=this[a]).parentNode;for(var c=-1,l=r.length;l>++c;)(u=r[c])?(n.push(e=t.call(u,u.__data__,c)),e&&"__data__"in u&&(e.__data__=u.__data__)):n.push(null)}return mn(i)},Ma.selectAll=function(t){var n,e,r=[];"function"!=typeof t&&(t=yn(t));for(var u=-1,i=this.length;i>++u;)for(var a=this[u],o=-1,c=a.length;c>++o;)(e=a[o])&&(r.push(n=Yi(t.call(e,e.__data__,o))),n.parentNode=e);return mn(r)},Ma.attr=function(t,n){if(2>arguments.length){if("string"==typeof t){var e=this.node();return t=qi.ns.qualify(t),t.local?e.getAttributeNS(t.space,t.local):e.getAttribute(t)}for(n in t)this.each(Mn(n,t[n]));return this}return this.each(Mn(t,n))},Ma.classed=function(t,n){if(2>arguments.length){if("string"==typeof t){var e=this.node(),r=(t=t.trim().split(/^|\s+/g)).length,u=-1;if(n=e.classList){for(;r>++u;)if(!n.contains(t[u]))return!1}else for(n=e.className,null!=n.baseVal&&(n=n.baseVal);r>++u;)if(!bn(t[u]).test(n))return!1;return!0}for(n in t)this.each(xn(n,t[n]));return this}return this.each(xn(t,n))},Ma.style=function(t,n,e){var r=arguments.length;if(3>r){if("string"!=typeof t){2>r&&(n="");for(e in t)this.each(wn(e,t[e],n));return this}if(2>r)return Li.getComputedStyle(this.node(),null).getPropertyValue(t);e=""}return this.each(wn(t,n,e))},Ma.property=function(t,n){if(2>arguments.length){if("string"==typeof t)return this.node()[t];for(n in t)this.each(Sn(n,t[n]));return this}return this.each(Sn(t,n))},Ma.text=function(t){return arguments.length?this.each("function"==typeof t?function(){var n=t.apply(this,arguments);this.textContent=null==n?"":n}:null==t?function(){this.textContent=""}:function(){this.textContent=t}):this.node().textContent},Ma.html=function(t){return arguments.length?this.each("function"==typeof t?function(){var n=t.apply(this,arguments);this.innerHTML=null==n?"":n}:null==t?function(){this.innerHTML=""}:function(){this.innerHTML=t}):this.node().innerHTML},Ma.append=function(t){function n(){return this.appendChild(Di.createElementNS(this.namespaceURI,t))}function e(){return this.appendChild(Di.createElementNS(t.space,t.local))}return t=qi.ns.qualify(t),this.select(t.local?e:n)},Ma.insert=function(t,n){function e(){return this.insertBefore(Di.createElementNS(this.namespaceURI,t),pa(n,this))}function r(){return this.insertBefore(Di.createElementNS(t.space,t.local),pa(n,this))}return t=qi.ns.qualify(t),this.select(t.local?r:e)},Ma.remove=function(){return this.each(function(){var t=this.parentNode;t&&t.removeChild(this)})},Ma.data=function(t,n){function e(t,e){var r,u,a,o=t.length,s=e.length,h=Math.min(o,s),g=Array(s),p=Array(s),d=Array(o);if(n){var m,v=new i,y=new i,M=[];for(r=-1;o>++r;)m=n.call(u=t[r],u.__data__,r),v.has(m)?d[r]=u:v.set(m,u),M.push(m);for(r=-1;s>++r;)m=n.call(e,a=e[r],r),(u=v.get(m))?(g[r]=u,u.__data__=a):y.has(m)||(p[r]=kn(a)),y.set(m,a),v.remove(m);for(r=-1;o>++r;)v.has(M[r])&&(d[r]=t[r])}else{for(r=-1;h>++r;)u=t[r],a=e[r],u?(u.__data__=a,g[r]=u):p[r]=kn(a);for(;s>r;++r)p[r]=kn(e[r]);for(;o>r;++r)d[r]=t[r]}p.update=g,p.parentNode=g.parentNode=d.parentNode=t.parentNode,c.push(p),l.push(g),f.push(d)}var r,u,a=-1,o=this.length;if(!arguments.length){for(t=Array(o=(r=this[0]).length);o>++a;)(u=r[a])&&(t[a]=u.__data__);return t}var c=qn([]),l=mn([]),f=mn([]);if("function"==typeof t)for(;o>++a;)e(r=this[a],t.call(r,r.parentNode.__data__,a));else for(;o>++a;)e(r=this[a],t);return l.enter=function(){return c},l.exit=function(){return f},l},Ma.datum=function(t){return arguments.length?this.property("__data__",t):this.property("__data__")},Ma.filter=function(t){var n,e,r,u=[];"function"!=typeof t&&(t=En(t));for(var i=0,a=this.length;a>i;i++){u.push(n=[]),n.parentNode=(e=this[i]).parentNode;for(var o=0,c=e.length;c>o;o++)(r=e[o])&&t.call(r,r.__data__,o)&&n.push(r)}return mn(u)},Ma.order=function(){for(var t=-1,n=this.length;n>++t;)for(var e,r=this[t],u=r.length-1,i=r[u];--u>=0;)(e=r[u])&&(i&&i!==e.nextSibling&&i.parentNode.insertBefore(e,i),i=e);return this},Ma.sort=function(t){t=An.apply(this,arguments);for(var n=-1,e=this.length;e>++n;)this[n].sort(t);return this.order()},Ma.on=function(t,n,e){var r=arguments.length;if(3>r){if("string"!=typeof t){2>r&&(n=!1);for(e in t)this.each(Nn(e,t[e],n));return this}if(2>r)return(r=this.node()["__on"+t])&&r._;e=!1}return this.each(Nn(t,n,e))},Ma.each=function(t){return Tn(this,function(n,e,r){t.call(n,n.__data__,e,r)})},Ma.call=function(t){var n=Yi(arguments);return t.apply(n[0]=this,n),this},Ma.empty=function(){return!this.node()},Ma.node=function(){for(var t=0,n=this.length;n>t;t++)for(var e=this[t],r=0,u=e.length;u>r;r++){var i=e[r];if(i)return i}return null},Ma.transition=function(){var t,n,e=_a||++Sa,r=[],u=Object.create(ka);u.time=Date.now();for(var i=-1,a=this.length;a>++i;){r.push(t=[]);for(var o=this[i],c=-1,l=o.length;l>++c;)(n=o[c])&&zn(n,c,e,u),t.push(n)}return Cn(r,e)};var ba=mn([[Di]]);ba[0].parentNode=ma,qi.select=function(t){return"string"==typeof t?ba.select(t):mn([[t]])},qi.selectAll=function(t){return"string"==typeof t?ba.selectAll(t):mn([Yi(t)])};var xa=[];qi.selection.enter=qn,qi.selection.enter.prototype=xa,xa.append=Ma.append,xa.insert=Ma.insert,xa.empty=Ma.empty,xa.node=Ma.node,xa.select=function(t){for(var n,e,r,u,i,a=[],o=-1,c=this.length;c>++o;){r=(u=this[o]).update,a.push(n=[]),n.parentNode=u.parentNode;for(var l=-1,f=u.length;f>++l;)(i=u[l])?(n.push(r[l]=e=t.call(u.parentNode,i.__data__,l)),e.__data__=i.__data__):n.push(null)}return mn(a)};var _a,wa=[],Sa=0,ka={ease:T,delay:0,duration:250};wa.call=Ma.call,wa.empty=Ma.empty,wa.node=Ma.node,qi.transition=function(t){return arguments.length?_a?t.transition():t:ba.transition()},qi.transition.prototype=wa,wa.select=function(t){var n,e,r,u=this.id,i=[];"function"!=typeof t&&(t=vn(t));for(var a=-1,o=this.length;o>++a;){i.push(n=[]);for(var c=this[a],l=-1,f=c.length;f>++l;)(r=c[l])&&(e=t.call(r,r.__data__,l))?("__data__"in r&&(e.__data__=r.__data__),zn(e,l,u,r.__transition__[u]),n.push(e)):n.push(null)}return Cn(i,u)},wa.selectAll=function(t){var n,e,r,u,i,a=this.id,o=[];"function"!=typeof t&&(t=yn(t));for(var c=-1,l=this.length;l>++c;)for(var f=this[c],s=-1,h=f.length;h>++s;)if(r=f[s]){i=r.__transition__[a],e=t.call(r,r.__data__,s),o.push(n=[]);for(var g=-1,p=e.length;p>++g;)zn(u=e[g],g,a,i),n.push(u)}return Cn(o,a)},wa.filter=function(t){var n,e,r,u=[];"function"!=typeof t&&(t=En(t));for(var i=0,a=this.length;a>i;i++){u.push(n=[]);for(var e=this[i],o=0,c=e.length;c>o;o++)(r=e[o])&&t.call(r,r.__data__,o)&&n.push(r)}return Cn(u,this.id,this.time).ease(this.ease())},wa.attr=function(t,n){function e(){this.removeAttribute(i)}function r(){this.removeAttributeNS(i.space,i.local)}if(2>arguments.length){for(n in t)this.attr(n,t[n]);return this}var u=V(t),i=qi.ns.qualify(t);return Ln(this,"attr."+t,n,function(t){function n(){var n,e=this.getAttribute(i);return e!==t&&(n=u(e,t),function(t){this.setAttribute(i,n(t))})}function a(){var n,e=this.getAttributeNS(i.space,i.local);return e!==t&&(n=u(e,t),function(t){this.setAttributeNS(i.space,i.local,n(t))})}return null==t?i.local?r:e:(t+="",i.local?a:n)})},wa.attrTween=function(t,n){function e(t,e){var r=n.call(this,t,e,this.getAttribute(u));return r&&function(t){this.setAttribute(u,r(t))}}function r(t,e){var r=n.call(this,t,e,this.getAttributeNS(u.space,u.local));return r&&function(t){this.setAttributeNS(u.space,u.local,r(t))}}var u=qi.ns.qualify(t);return this.tween("attr."+t,u.local?r:e)},wa.style=function(t,n,e){function r(){this.style.removeProperty(t)}var u=arguments.length;if(3>u){if("string"!=typeof t){2>u&&(n="");for(e in t)this.style(e,t[e],n);return this}e=""}var i=V(t);return Ln(this,"style."+t,n,function(n){function u(){var r,u=Li.getComputedStyle(this,null).getPropertyValue(t);return u!==n&&(r=i(u,n),function(n){this.style.setProperty(t,r(n),e)})}return null==n?r:(n+="",u)})},wa.styleTween=function(t,n,e){return 3>arguments.length&&(e=""),this.tween("style."+t,function(r,u){var i=n.call(this,r,u,Li.getComputedStyle(this,null).getPropertyValue(t));return i&&function(n){this.style.setProperty(t,i(n),e)}})},wa.text=function(t){return Ln(this,"text",t,Dn)},wa.remove=function(){return this.each("end.transition",function(){var t;!this.__transition__&&(t=this.parentNode)&&t.removeChild(this)})},wa.ease=function(t){var n=this.id;return 1>arguments.length?this.node().__transition__[n].ease:("function"!=typeof t&&(t=qi.ease.apply(qi,arguments)),Tn(this,function(e){e.__transition__[n].ease=t}))},wa.delay=function(t){var n=this.id;return Tn(this,"function"==typeof t?function(e,r,u){e.__transition__[n].delay=0|t.call(e,e.__data__,r,u)}:(t|=0,function(e){e.__transition__[n].delay=t}))},wa.duration=function(t){var n=this.id;return Tn(this,"function"==typeof t?function(e,r,u){e.__transition__[n].duration=Math.max(1,0|t.call(e,e.__data__,r,u))}:(t=Math.max(1,0|t),function(e){e.__transition__[n].duration=t}))},wa.each=function(t,n){var e=this.id;if(2>arguments.length){var r=ka,u=_a;_a=e,Tn(this,function(n,r,u){ka=n.__transition__[e],t.call(n,n.__data__,r,u)}),ka=r,_a=u}else Tn(this,function(r){r.__transition__[e].event.on(t,n)});return this},wa.transition=function(){for(var t,n,e,r,u=this.id,i=++Sa,a=[],o=0,c=this.length;c>o;o++){a.push(t=[]);for(var n=this[o],l=0,f=n.length;f>l;l++)(e=n[l])&&(r=Object.create(e.__transition__[u]),r.delay+=r.duration,zn(e,l,i,r)),t.push(e)}return Cn(a,i)},wa.tween=function(t,n){var e=this.id;return 2>arguments.length?this.node().__transition__[e].tween.get(t):Tn(this,null==n?function(n){n.__transition__[e].tween.remove(t)}:function(r){r.__transition__[e].tween.set(t,n)})};var Ea,Aa,Na=0,Ta={},qa=null;qi.timer=function(t,n,e){if(3>arguments.length){if(2>arguments.length)n=0;else if(!isFinite(n))return;e=Date.now()}var r=Ta[t.id];r&&r.callback===t?(r.then=e,r.delay=n):Ta[t.id=++Na]=qa={callback:t,then:e,delay:n,next:qa},Ea||(Aa=clearTimeout(Aa),Ea=1,Ca(Fn))},qi.timer.flush=function(){for(var t,n=Date.now(),e=qa;e;)t=n-e.then,e.delay||(e.flush=e.callback(t)),e=e.next;Hn()};var Ca=Li.requestAnimationFrame||Li.webkitRequestAnimationFrame||Li.mozRequestAnimationFrame||Li.oRequestAnimationFrame||Li.msRequestAnimationFrame||function(t){setTimeout(t,17)};qi.mouse=function(t){return jn(t,P())};var za=/WebKit/.test(Li.navigator.userAgent)?-1:0;qi.touches=function(t,n){return 2>arguments.length&&(n=P().touches),n?Yi(n).map(function(n){var e=jn(t,n);return e.identifier=n.identifier,e}):[]},qi.scale={},qi.scale.linear=function(){return In([0,1],[0,1],qi.interpolate,!1)},qi.scale.log=function(){return Kn(qi.scale.linear(),Wn)};var Da=qi.format(".0e");Wn.pow=function(t){return Math.pow(10,t)},Qn.pow=function(t){return-Math.pow(10,-t)},qi.scale.pow=function(){return te(qi.scale.linear(),1)},qi.scale.sqrt=function(){return qi.scale.pow().exponent(.5)},qi.scale.ordinal=function(){return ee([],{t:"range",a:[[]]})},qi.scale.category10=function(){return qi.scale.ordinal().range(La)},qi.scale.category20=function(){return qi.scale.ordinal().range(Fa)},qi.scale.category20b=function(){return qi.scale.ordinal().range(Ha)},qi.scale.category20c=function(){return qi.scale.ordinal().range(ja)};var La=["#1f77b4","#ff7f0e","#2ca02c","#d62728","#9467bd","#8c564b","#e377c2","#7f7f7f","#bcbd22","#17becf"],Fa=["#1f77b4","#aec7e8","#ff7f0e","#ffbb78","#2ca02c","#98df8a","#d62728","#ff9896","#9467bd","#c5b0d5","#8c564b","#c49c94","#e377c2","#f7b6d2","#7f7f7f","#c7c7c7","#bcbd22","#dbdb8d","#17becf","#9edae5"],Ha=["#393b79","#5254a3","#6b6ecf","#9c9ede","#637939","#8ca252","#b5cf6b","#cedb9c","#8c6d31","#bd9e39","#e7ba52","#e7cb94","#843c39","#ad494a","#d6616b","#e7969c","#7b4173","#a55194","#ce6dbd","#de9ed6"],ja=["#3182bd","#6baed6","#9ecae1","#c6dbef","#e6550d","#fd8d3c","#fdae6b","#fdd0a2","#31a354","#74c476","#a1d99b","#c7e9c0","#756bb1","#9e9ac8","#bcbddc","#dadaeb","#636363","#969696","#bdbdbd","#d9d9d9"];qi.scale.quantile=function(){return re([],[])},qi.scale.quantize=function(){return ue(0,1,[0,1])},qi.scale.threshold=function(){return ie([.5],[0,1])},qi.scale.identity=function(){return ae([0,1])},qi.svg={},qi.svg.arc=function(){function t(){var t=n.apply(this,arguments),i=e.apply(this,arguments),a=r.apply(this,arguments)+Pa,o=u.apply(this,arguments)+Pa,c=(a>o&&(c=a,a=o,o=c),o-a),l=Ni>c?"0":"1",f=Math.cos(a),s=Math.sin(a),h=Math.cos(o),g=Math.sin(o);return c>=Ra?t?"M0,"+i+"A"+i+","+i+" 0 1,1 0,"+-i+"A"+i+","+i+" 0 1,1 0,"+i+"M0,"+t+"A"+t+","+t+" 0 1,0 0,"+-t+"A"+t+","+t+" 0 1,0 0,"+t+"Z":"M0,"+i+"A"+i+","+i+" 0 1,1 0,"+-i+"A"+i+","+i+" 0 1,1 0,"+i+"Z":t?"M"+i*f+","+i*s+"A"+i+","+i+" 0 "+l+",1 "+i*h+","+i*g+"L"+t*h+","+t*g+"A"+t+","+t+" 0 "+l+",0 "+t*f+","+t*s+"Z":"M"+i*f+","+i*s+"A"+i+","+i+" 0 "+l+",1 "+i*h+","+i*g+"L0,0"+"Z"}var n=oe,e=ce,r=le,u=fe;return t.innerRadius=function(e){return arguments.length?(n=c(e),t):n},t.outerRadius=function(n){return arguments.length?(e=c(n),t):e},t.startAngle=function(n){return arguments.length?(r=c(n),t):r},t.endAngle=function(n){return arguments.length?(u=c(n),t):u},t.centroid=function(){var t=(n.apply(this,arguments)+e.apply(this,arguments))/2,i=(r.apply(this,arguments)+u.apply(this,arguments))/2+Pa;return[Math.cos(i)*t,Math.sin(i)*t]},t};var Pa=-Ni/2,Ra=2*Ni-1e-6;qi.svg.line=function(){return se(a)};var Oa=qi.map({linear:pe,"linear-closed":de,"step-before":me,"step-after":ve,basis:we,"basis-open":Se,"basis-closed":ke,bundle:Ee,cardinal:be,"cardinal-open":ye,"cardinal-closed":Me,monotone:ze});Oa.forEach(function(t,n){n.key=t,n.closed=/-closed$/.test(t)});var Ya=[0,2/3,1/3,0],Ua=[0,1/3,2/3,0],Ia=[0,1/6,2/3,1/6];qi.svg.line.radial=function(){var t=se(De);return t.radius=t.x,delete t.x,t.angle=t.y,delete t.y,t},me.reverse=ve,ve.reverse=me,qi.svg.area=function(){return Le(a)},qi.svg.area.radial=function(){var t=Le(De);return t.radius=t.x,delete t.x,t.innerRadius=t.x0,delete t.x0,t.outerRadius=t.x1,delete t.x1,t.angle=t.y,delete t.y,t.startAngle=t.y0,delete t.y0,t.endAngle=t.y1,delete t.y1,t},qi.svg.chord=function(){function e(t,n){var e=r(this,o,t,n),c=r(this,l,t,n);return"M"+e.p0+i(e.r,e.p1,e.a1-e.a0)+(u(e,c)?a(e.r,e.p1,e.r,e.p0):a(e.r,e.p1,c.r,c.p0)+i(c.r,c.p1,c.a1-c.a0)+a(c.r,c.p1,e.r,e.p0))+"Z"}function r(t,n,e,r){var u=n.call(t,e,r),i=f.call(t,u,r),a=s.call(t,u,r)+Pa,o=h.call(t,u,r)+Pa;return{r:i,a0:a,a1:o,p0:[i*Math.cos(a),i*Math.sin(a)],p1:[i*Math.cos(o),i*Math.sin(o)]}}function u(t,n){return t.a0==n.a0&&t.a1==n.a1}function i(t,n,e){return"A"+t+","+t+" 0 "+ +(e>Ni)+",1 "+n}function a(t,n,e,r){return"Q 0,0 "+r}var o=n,l=t,f=Fe,s=le,h=fe;return e.radius=function(t){return arguments.length?(f=c(t),e):f},e.source=function(t){return arguments.length?(o=c(t),e):o},e.target=function(t){return arguments.length?(l=c(t),e):l},e.startAngle=function(t){return arguments.length?(s=c(t),e):s},e.endAngle=function(t){return arguments.length?(h=c(t),e):h},e},qi.svg.diagonal=function(){function e(t,n){var e=r.call(this,t,n),a=u.call(this,t,n),o=(e.y+a.y)/2,c=[e,{x:e.x,y:o},{x:a.x,y:o},a];return c=c.map(i),"M"+c[0]+"C"+c[1]+" "+c[2]+" "+c[3]}var r=n,u=t,i=He;return e.source=function(t){return arguments.length?(r=c(t),e):r},e.target=function(t){return arguments.length?(u=c(t),e):u},e.projection=function(t){return arguments.length?(i=t,e):i},e},qi.svg.diagonal.radial=function(){var t=qi.svg.diagonal(),n=He,e=t.projection;return t.projection=function(t){return arguments.length?e(je(n=t)):n},t},qi.svg.symbol=function(){function t(t,r){return(Va.get(n.call(this,t,r))||Oe)(e.call(this,t,r))}var n=Re,e=Pe;return t.type=function(e){return arguments.length?(n=c(e),t):n},t.size=function(n){return arguments.length?(e=c(n),t):e},t};var Va=qi.map({circle:Oe,cross:function(t){var n=Math.sqrt(t/5)/2;return"M"+-3*n+","+-n+"H"+-n+"V"+-3*n+"H"+n+"V"+-n+"H"+3*n+"V"+n+"H"+n+"V"+3*n+"H"+-n+"V"+n+"H"+-3*n+"Z"},diamond:function(t){var n=Math.sqrt(t/(2*Za)),e=n*Za;return"M0,"+-n+"L"+e+",0"+" 0,"+n+" "+-e+",0"+"Z"},square:function(t){var n=Math.sqrt(t)/2;return"M"+-n+","+-n+"L"+n+","+-n+" "+n+","+n+" "+-n+","+n+"Z"},"triangle-down":function(t){var n=Math.sqrt(t/Xa),e=n*Xa/2;return"M0,"+e+"L"+n+","+-e+" "+-n+","+-e+"Z"},"triangle-up":function(t){var n=Math.sqrt(t/Xa),e=n*Xa/2;return"M0,"+-e+"L"+n+","+e+" "+-n+","+e+"Z"}});qi.svg.symbolTypes=Va.keys();var Xa=Math.sqrt(3),Za=Math.tan(30*Ci);qi.svg.axis=function(){function t(t){t.each(function(){var t,s=qi.select(this),h=null==l?e.ticks?e.ticks.apply(e,c):e.domain():l,g=null==n?e.tickFormat?e.tickFormat.apply(e,c):String:n,p=Ie(e,h,f),d=s.selectAll(".tick.minor").data(p,String),m=d.enter().insert("line",".tick").attr("class","tick minor").style("opacity",1e-6),v=qi.transition(d.exit()).style("opacity",1e-6).remove(),y=qi.transition(d).style("opacity",1),M=s.selectAll(".tick.major").data(h,String),b=M.enter().insert("g","path").attr("class","tick major").style("opacity",1e-6),x=qi.transition(M.exit()).style("opacity",1e-6).remove(),_=qi.transition(M).style("opacity",1),w=On(e),S=s.selectAll(".domain").data([0]),k=(S.enter().append("path").attr("class","domain"),qi.transition(S)),E=e.copy(),A=this.__chart__||E;this.__chart__=E,b.append("line"),b.append("text");var N=b.select("line"),T=_.select("line"),q=M.select("text").text(g),C=b.select("text"),z=_.select("text");switch(r){case"bottom":t=Ye,m.attr("y2",i),y.attr("x2",0).attr("y2",i),N.attr("y2",u),C.attr("y",Math.max(u,0)+o),T.attr("x2",0).attr("y2",u),z.attr("x",0).attr("y",Math.max(u,0)+o),q.attr("dy",".71em").style("text-anchor","middle"),k.attr("d","M"+w[0]+","+a+"V0H"+w[1]+"V"+a);break;case"top":t=Ye,m.attr("y2",-i),y.attr("x2",0).attr("y2",-i),N.attr("y2",-u),C.attr("y",-(Math.max(u,0)+o)),T.attr("x2",0).attr("y2",-u),z.attr("x",0).attr("y",-(Math.max(u,0)+o)),q.attr("dy","0em").style("text-anchor","middle"),k.attr("d","M"+w[0]+","+-a+"V0H"+w[1]+"V"+-a);break;case"left":t=Ue,m.attr("x2",-i),y.attr("x2",-i).attr("y2",0),N.attr("x2",-u),C.attr("x",-(Math.max(u,0)+o)),T.attr("x2",-u).attr("y2",0),z.attr("x",-(Math.max(u,0)+o)).attr("y",0),q.attr("dy",".32em").style("text-anchor","end"),k.attr("d","M"+-a+","+w[0]+"H0V"+w[1]+"H"+-a);break;case"right":t=Ue,m.attr("x2",i),y.attr("x2",i).attr("y2",0),N.attr("x2",u),C.attr("x",Math.max(u,0)+o),T.attr("x2",u).attr("y2",0),z.attr("x",Math.max(u,0)+o).attr("y",0),q.attr("dy",".32em").style("text-anchor","start"),k.attr("d","M"+a+","+w[0]+"H0V"+w[1]+"H"+a)}if(e.ticks)b.call(t,A),_.call(t,E),x.call(t,E),m.call(t,A),y.call(t,E),v.call(t,E);else{var D=E.rangeBand()/2,L=function(t){return E(t)+D};b.call(t,L),_.call(t,L)}})}var n,e=qi.scale.linear(),r=Ba,u=6,i=6,a=6,o=3,c=[10],l=null,f=0;return t.scale=function(n){return arguments.length?(e=n,t):e},t.orient=function(n){return arguments.length?(r=n in $a?n+"":Ba,t):r},t.ticks=function(){return arguments.length?(c=arguments,t):c},t.tickValues=function(n){return arguments.length?(l=n,t):l},t.tickFormat=function(e){return arguments.length?(n=e,t):n},t.tickSize=function(n,e){if(!arguments.length)return u;var r=arguments.length-1;return u=+n,i=r>1?+e:u,a=r>0?+arguments[r]:u,t},t.tickPadding=function(n){return arguments.length?(o=+n,t):o},t.tickSubdivide=function(n){return arguments.length?(f=+n,t):f},t};var Ba="bottom",$a={top:1,right:1,bottom:1,left:1};qi.svg.brush=function(){function t(a){a.each(function(){var a,o=qi.select(this),s=o.selectAll(".background").data([0]),h=o.selectAll(".extent").data([0]),g=o.selectAll(".resize").data(f,String);o.style("pointer-events","all").on("mousedown.brush",i).on("touchstart.brush",i).on("dblclick.brush",u),s.enter().append("rect").attr("class","background").style("visibility","hidden").style("cursor","crosshair"),h.enter().append("rect").attr("class","extent").style("cursor","move"),g.enter().append("g").attr("class",function(t){return"resize "+t}).style("cursor",function(t){return Ja[t]}).append("rect").attr("x",function(t){return/[ew]$/.test(t)?-3:null}).attr("y",function(t){return/^[ns]/.test(t)?-3:null}).attr("width",6).attr("height",6).style("visibility","hidden"),g.style("display",t.empty()?"none":null),g.exit().remove(),c&&(a=On(c),s.attr("x",a[0]).attr("width",a[1]-a[0]),e(o)),l&&(a=On(l),s.attr("y",a[0]).attr("height",a[1]-a[0]),r(o)),n(o)})}function n(t){t.selectAll(".resize").attr("transform",function(t){return"translate("+s[+/e$/.test(t)][0]+","+s[+/^s/.test(t)][1]+")"})}function e(t){t.select(".extent").attr("x",s[0][0]),t.selectAll(".extent,.n>rect,.s>rect").attr("width",s[1][0]-s[0][0])}function r(t){t.select(".extent").attr("y",s[0][1]),t.selectAll(".extent,.e>rect,.w>rect").attr("height",s[1][1]-s[0][1])}function u(){console.log("brush doubleclickd")}function i(){function u(){var t=qi.event.changedTouches;return t?qi.touches(v,t)[0]:qi.mouse(v)}function i(){32==qi.event.keyCode&&(S||(d=null,k[0]-=s[1][0],k[1]-=s[1][1],S=2),j())}function f(){32==qi.event.keyCode&&2==S&&(k[0]+=s[1][0],k[1]+=s[1][1],S=0,j())}function h(){var t=u(),i=!1;m&&(t[0]+=m[0],t[1]+=m[1]),S||(qi.event.altKey?(d||(d=[(s[0][0]+s[1][0])/2,(s[0][1]+s[1][1])/2]),k[0]=s[+(t[0]<d[0])][0],k[1]=s[+(t[1]<d[1])][1]):d=null),_&&g(t,c,0)&&(e(b),i=!0),w&&g(t,l,1)&&(r(b),i=!0),i&&(n(b),M({type:"brush",mode:S?"move":"resize"}))}function g(t,n,e){var r,u,i=On(n),o=i[0],c=i[1],l=k[e],f=s[1][e]-s[0][e];return S&&(o-=l,c-=f+l),r=Math.max(o,Math.min(c,t[e])),S?u=(r+=l)+f:(d&&(l=Math.max(o,Math.min(c,2*d[e]-r))),r>l?(u=r,r=l):u=l),s[0][e]!==r||s[1][e]!==u?(a=null,s[0][e]=r,s[1][e]=u,!0):void 0}function p(){h(),b.style("pointer-events","all").selectAll(".resize").style("display",t.empty()?"none":null),qi.select("body").style("cursor",null),E.on("mousemove.brush",null).on("mouseup.brush",null).on("touchmove.brush",null).on("touchend.brush",null).on("keydown.brush",null).on("keyup.brush",null),M({type:"brushend"})}var d,m,v=this,y=qi.select(qi.event.target),M=o.of(v,arguments),b=qi.select(v),x=y.datum(),_=!/^(n|s)$/.test(x)&&c,w=!/^(e|w)$/.test(x)&&l,S=y.classed("extent"),k=u(),E=qi.select(Li).on("mousemove.brush",h).on("mouseup.brush",p).on("touchmove.brush",h).on("touchend.brush",p).on("keydown.brush",i).on("keyup.brush",f);if(S)k[0]=s[0][0]-k[0],k[1]=s[0][1]-k[1];else if(x){var A=+/w$/.test(x),N=+/^n/.test(x);m=[s[1-A][0]-k[0],s[1-N][1]-k[1]],k[0]=s[A][0],k[1]=s[N][1]}else qi.event.altKey&&(d=k.slice());b.style("pointer-events","none").selectAll(".resize").style("display",null),qi.select("body").style("cursor",y.style("cursor")),M({type:"brushstart"}),h()}var a,o=R(t,"brushstart","brush","brushend"),c=null,l=null,f=Ga[0],s=[[0,0],[0,0]];return t.x=function(n){return arguments.length?(c=n,f=Ga[!c<<1|!l],t):c},t.y=function(n){return arguments.length?(l=n,f=Ga[!c<<1|!l],t):l},t.extent=function(n){var e,r,u,i,o;return arguments.length?(a=[[0,0],[0,0]],c&&(e=n[0],r=n[1],l&&(e=e[0],r=r[0]),a[0][0]=e,a[1][0]=r,c.invert&&(e=c(e),r=c(r)),e>r&&(o=e,e=r,r=o),s[0][0]=0|e,s[1][0]=0|r),l&&(u=n[0],i=n[1],c&&(u=u[1],i=i[1]),a[0][1]=u,a[1][1]=i,l.invert&&(u=l(u),i=l(i)),u>i&&(o=u,u=i,i=o),s[0][1]=0|u,s[1][1]=0|i),t):(n=a||s,c&&(e=n[0][0],r=n[1][0],a||(e=s[0][0],r=s[1][0],c.invert&&(e=c.invert(e),r=c.invert(r)),e>r&&(o=e,e=r,r=o))),l&&(u=n[0][1],i=n[1][1],a||(u=s[0][1],i=s[1][1],l.invert&&(u=l.invert(u),i=l.invert(i)),u>i&&(o=u,u=i,i=o))),c&&l?[[e,u],[r,i]]:c?[e,r]:l&&[u,i])},t.clear=function(){return a=null,s[0][0]=s[0][1]=s[1][0]=s[1][1]=0,t},t.empty=function(){return c&&s[0][0]===s[1][0]||l&&s[0][1]===s[1][1]},qi.rebind(t,o,"on")};var Ja={n:"ns-resize",e:"ew-resize",s:"ns-resize",w:"ew-resize",nw:"nwse-resize",ne:"nesw-resize",se:"nwse-resize",sw:"nesw-resize"},Ga=[["n","e","s","w","nw","ne","se","sw"],["e","w"],["n","s"],[]];qi.behavior={},qi.behavior.drag=function(){function t(){this.on("mousedown.drag",n).on("touchstart.drag",n)}function n(){function t(){var t=o.parentNode;return null!=f?qi.touches(t).filter(function(t){return t.identifier===f})[0]:qi.mouse(t)}function n(){if(!o.parentNode)return u();var n=t(),e=n[0]-s[0],r=n[1]-s[1];h|=e|r,s=n,j(),c({type:"drag",x:n[0]+a[0],y:n[1]+a[1],dx:e,dy:r})}function u(){c({type:"dragend"}),h&&(j(),qi.event.target===l&&g.on("click.drag",i,!0)),g.on(null!=f?"touchmove.drag-"+f:"mousemove.drag",null).on(null!=f?"touchend.drag-"+f:"mouseup.drag",null)}function i(){j(),g.on("click.drag",null)}var a,o=this,c=e.of(o,arguments),l=qi.event.target,f=qi.event.touches?qi.event.changedTouches[0].identifier:null,s=t(),h=0,g=qi.select(Li).on(null!=f?"touchmove.drag-"+f:"mousemove.drag",n).on(null!=f?"touchend.drag-"+f:"mouseup.drag",u,!0);r?(a=r.apply(o,arguments),a=[a.x-s[0],a.y-s[1]]):a=[0,0],null==f&&j(),c({type:"dragstart"})}var e=R(t,"drag","dragstart","dragend"),r=null;return t.origin=function(n){return arguments.length?(r=n,t):r},qi.rebind(t,e,"on")},qi.behavior.zoom=function(){function t(){this.on("mousedown.zoom",o).on("mousemove.zoom",l).on(Qa+".zoom",c).on("dblclick.zoom",f).on("touchstart.zoom",s).on("touchmove.zoom",h).on("touchend.zoom",s)}function n(t){return[(t[0]-b[0])/x,(t[1]-b[1])/x]}function e(t){return[t[0]*x+b[0],t[1]*x+b[1]]}function r(t){x=Math.max(_[0],Math.min(_[1],t))}function u(t,n){n=e(n),b[0]+=t[0]-n[0],b[1]+=t[1]-n[1]}function i(){m&&m.domain(d.range().map(function(t){return(t-b[0])/x}).map(d.invert)),y&&y.domain(v.range().map(function(t){return(t-b[1])/x}).map(v.invert))}function a(t){i(),qi.event.preventDefault(),t({type:"zoom",scale:x,translate:b})}function o(){function t(){l=1,u(qi.mouse(i),s),a(o)}function e(){l&&j(),f.on("mousemove.zoom",null).on("mouseup.zoom",null),l&&qi.event.target===c&&f.on("click.zoom",r,!0)}function r(){j(),f.on("click.zoom",null)}var i=this,o=w.of(i,arguments),c=qi.event.target,l=0,f=qi.select(Li).on("mousemove.zoom",t).on("mouseup.zoom",e),s=n(qi.mouse(i));Li.focus(),j()}function c(){g||(g=n(qi.mouse(this))),r(Math.pow(2,.002*Ka())*x),u(qi.mouse(this),g),a(w.of(this,arguments))}function l(){g=null}function f(){var t=qi.mouse(this),e=n(t),i=Math.log(x)/Math.LN2;r(Math.pow(2,qi.event.shiftKey?Math.ceil(i)-1:Math.floor(i)+1)),u(t,e),a(w.of(this,arguments))}function s(){var t=qi.touches(this),e=Date.now();if(p=x,g={},t.forEach(function(t){g[t.identifier]=n(t)}),j(),1===t.length){if(500>e-M){var i=t[0],o=n(t[0]);r(2*x),u(i,o),a(w.of(this,arguments))}M=e}}function h(){var t=qi.touches(this),n=t[0],e=g[n.identifier];if(i=t[1]){var i,o=g[i.identifier];n=[(n[0]+i[0])/2,(n[1]+i[1])/2],e=[(e[0]+o[0])/2,(e[1]+o[1])/2],r(qi.event.scale*p)}u(n,e),M=null,a(w.of(this,arguments))}var g,p,d,m,v,y,M,b=[0,0],x=1,_=Wa,w=R(t,"zoom");return t.translate=function(n){return arguments.length?(b=n.map(Number),i(),t):b},t.scale=function(n){return arguments.length?(x=+n,i(),t):x},t.scaleExtent=function(n){return arguments.length?(_=null==n?Wa:n.map(Number),t):_},t.x=function(n){return arguments.length?(m=n,d=n.copy(),b=[0,0],x=1,t):m},t.y=function(n){return arguments.length?(y=n,v=n.copy(),b=[0,0],x=1,t):y},qi.rebind(t,w,"on")};var Ka,Wa=[0,1/0],Qa="onwheel"in document?(Ka=function(){return-qi.event.deltaY*(qi.event.deltaMode?120:1)},"wheel"):"onmousewheel"in document?(Ka=function(){return qi.event.wheelDelta},"mousewheel"):(Ka=function(){return-qi.event.detail},"MozMousePixelScroll");qi.layout={},qi.layout.bundle=function(){return function(t){for(var n=[],e=-1,r=t.length;r>++e;)n.push(Ve(t[e]));return n}},qi.layout.chord=function(){function t(){var t,l,s,h,g,p={},d=[],m=qi.range(i),v=[];for(e=[],r=[],t=0,h=-1;i>++h;){for(l=0,g=-1;i>++g;)l+=u[h][g];d.push(l),v.push(qi.range(i)),t+=l}for(a&&m.sort(function(t,n){return a(d[t],d[n])}),o&&v.forEach(function(t,n){t.sort(function(t,e){return o(u[n][t],u[n][e])})}),t=(2*Ni-f*i)/t,l=0,h=-1;i>++h;){for(s=l,g=-1;i>++g;){var y=m[h],M=v[y][g],b=u[y][M],x=l,_=l+=b*t;p[y+"-"+M]={index:y,subindex:M,startAngle:x,endAngle:_,value:b}}r[y]={index:y,startAngle:s,endAngle:l,value:(l-s)/t},l+=f}for(h=-1;i>++h;)for(g=h-1;i>++g;){var w=p[h+"-"+g],S=p[g+"-"+h];(w.value||S.value)&&e.push(w.value<S.value?{source:S,target:w}:{source:w,target:S})}c&&n()}function n(){e.sort(function(t,n){return c((t.source.value+t.target.value)/2,(n.source.value+n.target.value)/2)})}var e,r,u,i,a,o,c,l={},f=0;return l.matrix=function(t){return arguments.length?(i=(u=t)&&u.length,e=r=null,l):u},l.padding=function(t){return arguments.length?(f=t,e=r=null,l):f},l.sortGroups=function(t){return arguments.length?(a=t,e=r=null,l):a},l.sortSubgroups=function(t){return arguments.length?(o=t,e=null,l):o},l.sortChords=function(t){return arguments.length?(c=t,e&&n(),l):c},l.chords=function(){return e||t(),e},l.groups=function(){return r||t(),r},l},qi.layout.force=function(){function t(t){return function(n,e,r,u){if(n.point!==t){var i=n.cx-t.x,a=n.cy-t.y,o=1/Math.sqrt(i*i+a*a);if(m>(u-e)*o){var c=n.charge*o*o;return t.px-=i*c,t.py-=a*c,!0}if(n.point&&isFinite(o)){var c=n.pointCharge*o*o;t.px-=i*c,t.py-=a*c}}return!n.charge}}function n(t){t.px=qi.event.x,t.py=qi.event.y,c.resume()}var e,r,u,i,o,c={},l=qi.dispatch("start","tick","end"),f=[1,1],s=.9,h=to,g=no,p=-30,d=.1,m=.8,v=[],y=[];return c.tick=function(){if(.005>(r*=.99))return l.end({type:"end",alpha:r=0}),!0;var n,e,a,c,h,g,m,M,b,x=v.length,_=y.length;for(e=0;_>e;++e)a=y[e],c=a.source,h=a.target,M=h.x-c.x,b=h.y-c.y,(g=M*M+b*b)&&(g=r*i[e]*((g=Math.sqrt(g))-u[e])/g,M*=g,b*=g,h.x-=M*(m=c.weight/(h.weight+c.weight)),h.y-=b*m,c.x+=M*(m=1-m),c.y+=b*m);if((m=r*d)&&(M=f[0]/2,b=f[1]/2,e=-1,m))for(;x>++e;)a=v[e],a.x+=(M-a.x)*m,a.y+=(b-a.y)*m;if(p)for(Ke(n=qi.geom.quadtree(v),r,o),e=-1;x>++e;)(a=v[e]).fixed||n.visit(t(a));for(e=-1;x>++e;)a=v[e],a.fixed?(a.x=a.px,a.y=a.py):(a.x-=(a.px-(a.px=a.x))*s,a.y-=(a.py-(a.py=a.y))*s);l.tick({type:"tick",alpha:r})},c.nodes=function(t){return arguments.length?(v=t,c):v},c.links=function(t){return arguments.length?(y=t,c):y},c.size=function(t){return arguments.length?(f=t,c):f},c.linkDistance=function(t){return arguments.length?(h="function"==typeof t?t:+t,c):h},c.distance=c.linkDistance,c.linkStrength=function(t){return arguments.length?(g="function"==typeof t?t:+t,c):g},c.friction=function(t){return arguments.length?(s=+t,c):s},c.charge=function(t){return arguments.length?(p="function"==typeof t?t:+t,c):p},c.gravity=function(t){return arguments.length?(d=+t,c):d},c.theta=function(t){return arguments.length?(m=+t,c):m},c.alpha=function(t){return arguments.length?(t=+t,r?r=t>0?t:0:t>0&&(l.start({type:"start",alpha:r=t}),qi.timer(c.tick)),c):r
},c.start=function(){function t(t,r){for(var u,i=n(e),a=-1,o=i.length;o>++a;)if(!isNaN(u=i[a][t]))return u;return Math.random()*r}function n(){if(!a){for(a=[],r=0;s>r;++r)a[r]=[];for(r=0;d>r;++r){var t=y[r];a[t.source.index].push(t.target),a[t.target.index].push(t.source)}}return a[e]}var e,r,a,l,s=v.length,d=y.length,m=f[0],M=f[1];for(e=0;s>e;++e)(l=v[e]).index=e,l.weight=0;for(e=0;d>e;++e)l=y[e],"number"==typeof l.source&&(l.source=v[l.source]),"number"==typeof l.target&&(l.target=v[l.target]),++l.source.weight,++l.target.weight;for(e=0;s>e;++e)l=v[e],isNaN(l.x)&&(l.x=t("x",m)),isNaN(l.y)&&(l.y=t("y",M)),isNaN(l.px)&&(l.px=l.x),isNaN(l.py)&&(l.py=l.y);if(u=[],"function"==typeof h)for(e=0;d>e;++e)u[e]=+h.call(this,y[e],e);else for(e=0;d>e;++e)u[e]=h;if(i=[],"function"==typeof g)for(e=0;d>e;++e)i[e]=+g.call(this,y[e],e);else for(e=0;d>e;++e)i[e]=g;if(o=[],"function"==typeof p)for(e=0;s>e;++e)o[e]=+p.call(this,v[e],e);else for(e=0;s>e;++e)o[e]=p;return c.resume()},c.resume=function(){return c.alpha(.1)},c.stop=function(){return c.alpha(0)},c.drag=function(){return e||(e=qi.behavior.drag().origin(a).on("dragstart.force",Be).on("drag.force",n).on("dragend.force",$e)),arguments.length?(this.on("mouseover.force",Je).on("mouseout.force",Ge).call(e),void 0):e},qi.rebind(c,l,"on")};var to=20,no=1;qi.layout.partition=function(){function t(n,e,r,u){var i=n.children;if(n.x=e,n.y=n.depth*u,n.dx=r,n.dy=u,i&&(a=i.length)){var a,o,c,l=-1;for(r=n.value?r/n.value:0;a>++l;)t(o=i[l],e,c=o.value*r,u),e+=c}}function n(t){var e=t.children,r=0;if(e&&(u=e.length))for(var u,i=-1;u>++i;)r=Math.max(r,n(e[i]));return 1+r}function e(e,i){var a=r.call(this,e,i);return t(a[0],0,u[0],u[1]/n(a[0])),a}var r=qi.layout.hierarchy(),u=[1,1];return e.size=function(t){return arguments.length?(u=t,e):u},lr(e,r)},qi.layout.pie=function(){function t(i){var a=i.map(function(e,r){return+n.call(t,e,r)}),o=+("function"==typeof r?r.apply(this,arguments):r),c=(("function"==typeof u?u.apply(this,arguments):u)-r)/qi.sum(a),l=qi.range(i.length);null!=e&&l.sort(e===eo?function(t,n){return a[n]-a[t]}:function(t,n){return e(i[t],i[n])});var f=[];return l.forEach(function(t){var n;f[t]={data:i[t],value:n=a[t],startAngle:o,endAngle:o+=n*c}}),f}var n=Number,e=eo,r=0,u=2*Ni;return t.value=function(e){return arguments.length?(n=e,t):n},t.sort=function(n){return arguments.length?(e=n,t):e},t.startAngle=function(n){return arguments.length?(r=n,t):r},t.endAngle=function(n){return arguments.length?(u=n,t):u},t};var eo={};qi.layout.stack=function(){function t(a,c){var l=a.map(function(e,r){return n.call(t,e,r)}),f=l.map(function(n){return n.map(function(n,e){return[i.call(t,n,e),o.call(t,n,e)]})}),s=e.call(t,f,c);l=qi.permute(l,s),f=qi.permute(f,s);var h,g,p,d=r.call(t,f,c),m=l.length,v=l[0].length;for(g=0;v>g;++g)for(u.call(t,l[0][g],p=d[g],f[0][g][1]),h=1;m>h;++h)u.call(t,l[h][g],p+=f[h-1][g][1],f[h][g][1]);return a}var n=a,e=nr,r=er,u=tr,i=We,o=Qe;return t.values=function(e){return arguments.length?(n=e,t):n},t.order=function(n){return arguments.length?(e="function"==typeof n?n:ro.get(n)||nr,t):e},t.offset=function(n){return arguments.length?(r="function"==typeof n?n:uo.get(n)||er,t):r},t.x=function(n){return arguments.length?(i=n,t):i},t.y=function(n){return arguments.length?(o=n,t):o},t.out=function(n){return arguments.length?(u=n,t):u},t};var ro=qi.map({"inside-out":function(t){var n,e,r=t.length,u=t.map(rr),i=t.map(ur),a=qi.range(r).sort(function(t,n){return u[t]-u[n]}),o=0,c=0,l=[],f=[];for(n=0;r>n;++n)e=a[n],c>o?(o+=i[e],l.push(e)):(c+=i[e],f.push(e));return f.reverse().concat(l)},reverse:function(t){return qi.range(t.length).reverse()},"default":nr}),uo=qi.map({silhouette:function(t){var n,e,r,u=t.length,i=t[0].length,a=[],o=0,c=[];for(e=0;i>e;++e){for(n=0,r=0;u>n;n++)r+=t[n][e][1];r>o&&(o=r),a.push(r)}for(e=0;i>e;++e)c[e]=(o-a[e])/2;return c},wiggle:function(t){var n,e,r,u,i,a,o,c,l,f=t.length,s=t[0],h=s.length,g=[];for(g[0]=c=l=0,e=1;h>e;++e){for(n=0,u=0;f>n;++n)u+=t[n][e][1];for(n=0,i=0,o=s[e][0]-s[e-1][0];f>n;++n){for(r=0,a=(t[n][e][1]-t[n][e-1][1])/(2*o);n>r;++r)a+=(t[r][e][1]-t[r][e-1][1])/o;i+=a*t[n][e][1]}g[e]=c-=u?i/u*o:0,l>c&&(l=c)}for(e=0;h>e;++e)g[e]-=l;return g},expand:function(t){var n,e,r,u=t.length,i=t[0].length,a=1/u,o=[];for(e=0;i>e;++e){for(n=0,r=0;u>n;n++)r+=t[n][e][1];if(r)for(n=0;u>n;n++)t[n][e][1]/=r;else for(n=0;u>n;n++)t[n][e][1]=a}for(e=0;i>e;++e)o[e]=0;return o},zero:er});qi.layout.histogram=function(){function t(t,i){for(var a,o,c=[],l=t.map(e,this),f=r.call(this,l,i),s=u.call(this,f,l,i),i=-1,h=l.length,g=s.length-1,p=n?1:1/h;g>++i;)a=c[i]=[],a.dx=s[i+1]-(a.x=s[i]),a.y=0;if(g>0)for(i=-1;h>++i;)o=l[i],o>=f[0]&&f[1]>=o&&(a=c[qi.bisect(s,o,1,g)-1],a.y+=p,a.push(t[i]));return c}var n=!0,e=Number,r=cr,u=ar;return t.value=function(n){return arguments.length?(e=n,t):e},t.range=function(n){return arguments.length?(r=c(n),t):r},t.bins=function(n){return arguments.length?(u="number"==typeof n?function(t){return or(t,n)}:c(n),t):u},t.frequency=function(e){return arguments.length?(n=!!e,t):n},t},qi.layout.hierarchy=function(){function t(n,a,o){var c=u.call(e,n,a);if(n.depth=a,o.push(n),c&&(l=c.length)){for(var l,f,s=-1,h=n.children=[],g=0,p=a+1;l>++s;)f=t(c[s],p,o),f.parent=n,h.push(f),g+=f.value;r&&h.sort(r),i&&(n.value=g)}else i&&(n.value=+i.call(e,n,a)||0);return n}function n(t,r){var u=t.children,a=0;if(u&&(o=u.length))for(var o,c=-1,l=r+1;o>++c;)a+=n(u[c],l);else i&&(a=+i.call(e,t,r)||0);return i&&(t.value=a),a}function e(n){var e=[];return t(n,0,e),e}var r=hr,u=fr,i=sr;return e.sort=function(t){return arguments.length?(r=t,e):r},e.children=function(t){return arguments.length?(u=t,e):u},e.value=function(t){return arguments.length?(i=t,e):i},e.revalue=function(t){return n(t,0),t},e},qi.layout.pack=function(){function t(t,u){var i=n.call(this,t,u),a=i[0];a.x=0,a.y=0,Lr(a,function(t){t.r=Math.sqrt(t.value)}),Lr(a,yr);var o=r[0],c=r[1],l=Math.max(2*a.r/o,2*a.r/c);if(e>0){var f=e*l/2;Lr(a,function(t){t.r+=f}),Lr(a,yr),Lr(a,function(t){t.r-=f}),l=Math.max(2*a.r/o,2*a.r/c)}return xr(a,o/2,c/2,1/l),i}var n=qi.layout.hierarchy().sort(pr),e=0,r=[1,1];return t.size=function(n){return arguments.length?(r=n,t):r},t.padding=function(n){return arguments.length?(e=+n,t):e},lr(t,n)},qi.layout.cluster=function(){function t(t,u){var i,a=n.call(this,t,u),o=a[0],c=0;Lr(o,function(t){var n=t.children;n&&n.length?(t.x=Sr(n),t.y=wr(n)):(t.x=i?c+=e(t,i):0,t.y=0,i=t)});var l=kr(o),f=Er(o),s=l.x-e(l,f)/2,h=f.x+e(f,l)/2;return Lr(o,function(t){t.x=(t.x-s)/(h-s)*r[0],t.y=(1-(o.y?t.y/o.y:1))*r[1]}),a}var n=qi.layout.hierarchy().sort(null).value(null),e=Ar,r=[1,1];return t.separation=function(n){return arguments.length?(e=n,t):e},t.size=function(n){return arguments.length?(r=n,t):r},lr(t,n)},qi.layout.tree=function(){function t(t,u){function i(t,n){var r=t.children,u=t._tree;if(r&&(a=r.length)){for(var a,c,l,f=r[0],s=f,h=-1;a>++h;)l=r[h],i(l,c),s=o(l,c,s),c=l;Fr(t);var g=.5*(f._tree.prelim+l._tree.prelim);n?(u.prelim=n._tree.prelim+e(t,n),u.mod=u.prelim-g):u.prelim=g}else n&&(u.prelim=n._tree.prelim+e(t,n))}function a(t,n){t.x=t._tree.prelim+n;var e=t.children;if(e&&(r=e.length)){var r,u=-1;for(n+=t._tree.mod;r>++u;)a(e[u],n)}}function o(t,n,r){if(n){for(var u,i=t,a=t,o=n,c=t.parent.children[0],l=i._tree.mod,f=a._tree.mod,s=o._tree.mod,h=c._tree.mod;o=Tr(o),i=Nr(i),o&&i;)c=Nr(c),a=Tr(a),a._tree.ancestor=t,u=o._tree.prelim+s-i._tree.prelim-l+e(o,i),u>0&&(Hr(jr(o,t,r),t,u),l+=u,f+=u),s+=o._tree.mod,l+=i._tree.mod,h+=c._tree.mod,f+=a._tree.mod;o&&!Tr(a)&&(a._tree.thread=o,a._tree.mod+=s-f),i&&!Nr(c)&&(c._tree.thread=i,c._tree.mod+=l-h,r=t)}return r}var c=n.call(this,t,u),l=c[0];Lr(l,function(t,n){t._tree={ancestor:t,prelim:0,mod:0,change:0,shift:0,number:n?n._tree.number+1:0}}),i(l),a(l,-l._tree.prelim);var f=qr(l,zr),s=qr(l,Cr),h=qr(l,Dr),g=f.x-e(f,s)/2,p=s.x+e(s,f)/2,d=h.depth||1;return Lr(l,function(t){t.x=(t.x-g)/(p-g)*r[0],t.y=t.depth/d*r[1],delete t._tree}),c}var n=qi.layout.hierarchy().sort(null).value(null),e=Ar,r=[1,1];return t.separation=function(n){return arguments.length?(e=n,t):e},t.size=function(n){return arguments.length?(r=n,t):r},lr(t,n)},qi.layout.treemap=function(){function t(t,n){for(var e,r,u=-1,i=t.length;i>++u;)r=(e=t[u]).value*(0>n?0:n),e.area=isNaN(r)||0>=r?0:r}function n(e){var i=e.children;if(i&&i.length){var a,o,c,l=s(e),f=[],h=i.slice(),p=1/0,d="slice"===g?l.dx:"dice"===g?l.dy:"slice-dice"===g?1&e.depth?l.dy:l.dx:Math.min(l.dx,l.dy);for(t(h,l.dx*l.dy/e.value),f.area=0;(c=h.length)>0;)f.push(a=h[c-1]),f.area+=a.area,"squarify"!==g||p>=(o=r(f,d))?(h.pop(),p=o):(f.area-=f.pop().area,u(f,d,l,!1),d=Math.min(l.dx,l.dy),f.length=f.area=0,p=1/0);f.length&&(u(f,d,l,!0),f.length=f.area=0),i.forEach(n)}}function e(n){var r=n.children;if(r&&r.length){var i,a=s(n),o=r.slice(),c=[];for(t(o,a.dx*a.dy/n.value),c.area=0;i=o.pop();)c.push(i),c.area+=i.area,null!=i.z&&(u(c,i.z?a.dx:a.dy,a,!o.length),c.length=c.area=0);r.forEach(e)}}function r(t,n){for(var e,r=t.area,u=0,i=1/0,a=-1,o=t.length;o>++a;)(e=t[a].area)&&(i>e&&(i=e),e>u&&(u=e));return r*=r,n*=n,r?Math.max(n*u*p/r,r/(n*i*p)):1/0}function u(t,n,e,r){var u,i=-1,a=t.length,o=e.x,l=e.y,f=n?c(t.area/n):0;if(n==e.dx){for((r||f>e.dy)&&(f=e.dy);a>++i;)u=t[i],u.x=o,u.y=l,u.dy=f,o+=u.dx=Math.min(e.x+e.dx-o,f?c(u.area/f):0);u.z=!0,u.dx+=e.x+e.dx-o,e.y+=f,e.dy-=f}else{for((r||f>e.dx)&&(f=e.dx);a>++i;)u=t[i],u.x=o,u.y=l,u.dx=f,l+=u.dy=Math.min(e.y+e.dy-l,f?c(u.area/f):0);u.z=!1,u.dy+=e.y+e.dy-l,e.x+=f,e.dx-=f}}function i(r){var u=a||o(r),i=u[0];return i.x=0,i.y=0,i.dx=l[0],i.dy=l[1],a&&o.revalue(i),t([i],i.dx*i.dy/i.value),(a?e:n)(i),h&&(a=u),u}var a,o=qi.layout.hierarchy(),c=Math.round,l=[1,1],f=null,s=Pr,h=!1,g="squarify",p=.5*(1+Math.sqrt(5));return i.size=function(t){return arguments.length?(l=t,i):l},i.padding=function(t){function n(n){var e=t.call(i,n,n.depth);return null==e?Pr(n):Rr(n,"number"==typeof e?[e,e,e,e]:e)}function e(n){return Rr(n,t)}if(!arguments.length)return f;var r;return s=null==(f=t)?Pr:"function"==(r=typeof t)?n:"number"===r?(t=[t,t,t,t],e):e,i},i.round=function(t){return arguments.length?(c=t?Math.round:Number,i):c!=Number},i.sticky=function(t){return arguments.length?(h=t,a=null,i):h},i.ratio=function(t){return arguments.length?(p=t,i):p},i.mode=function(t){return arguments.length?(g=t+"",i):g},lr(i,o)},qi.csv=Or(",","text/csv"),qi.tsv=Or("	","text/tab-separated-values"),qi.geo={},qi.geo.stream=function(t,n){io.hasOwnProperty(t.type)?io[t.type](t,n):Yr(t,n)};var io={Feature:function(t,n){Yr(t.geometry,n)},FeatureCollection:function(t,n){for(var e=t.features,r=-1,u=e.length;u>++r;)Yr(e[r].geometry,n)}},ao={Sphere:function(t,n){n.sphere()},Point:function(t,n){var e=t.coordinates;n.point(e[0],e[1])},MultiPoint:function(t,n){for(var e,r=t.coordinates,u=-1,i=r.length;i>++u;)e=r[u],n.point(e[0],e[1])},LineString:function(t,n){Ur(t.coordinates,n,0)},MultiLineString:function(t,n){for(var e=t.coordinates,r=-1,u=e.length;u>++r;)Ur(e[r],n,0)},Polygon:function(t,n){Ir(t.coordinates,n)},MultiPolygon:function(t,n){for(var e=t.coordinates,r=-1,u=e.length;u>++r;)Ir(e[r],n)},GeometryCollection:function(t,n){for(var e=t.geometries,r=-1,u=e.length;u>++r;)Yr(e[r],n)}};qi.geo.albersUsa=function(){function t(t){return n(t)(t)}function n(t){var n=t[0],a=t[1];return a>50?r:-140>n?u:21>a?i:e}var e=qi.geo.albers(),r=qi.geo.albers().rotate([160,0]).center([0,60]).parallels([55,65]),u=qi.geo.albers().rotate([160,0]).center([0,20]).parallels([8,18]),i=qi.geo.albers().rotate([60,0]).center([0,10]).parallels([8,18]);return t.scale=function(n){return arguments.length?(e.scale(n),r.scale(.6*n),u.scale(n),i.scale(1.5*n),t.translate(e.translate())):e.scale()},t.translate=function(n){if(!arguments.length)return e.translate();var a=e.scale(),o=n[0],c=n[1];return e.translate(n),r.translate([o-.4*a,c+.17*a]),u.translate([o-.19*a,c+.2*a]),i.translate([o+.58*a,c+.43*a]),t},t.scale(e.scale())},(qi.geo.albers=function(){var t=29.5*Ci,n=45.5*Ci,e=Fu(Qr),r=e(t,n);return r.parallels=function(r){return arguments.length?e(t=r[0]*Ci,n=r[1]*Ci):[t*zi,n*zi]},r.rotate([98,0]).center([0,38]).scale(1e3)}).raw=Qr;var oo=Yu(function(t){return Math.sqrt(2/(1+t))},function(t){return 2*Math.asin(t/2)});(qi.geo.azimuthalEqualArea=function(){return Lu(oo)}).raw=oo;var co=Yu(function(t){var n=Math.acos(t);return n&&n/Math.sin(n)},a);(qi.geo.azimuthalEquidistant=function(){return Lu(co)}).raw=co,qi.geo.bounds=tu(a),qi.geo.centroid=function(t){lo=fo=so=ho=go=0,qi.geo.stream(t,po);var n;return fo&&Math.abs(n=Math.sqrt(so*so+ho*ho+go*go))>Ti?[Math.atan2(ho,so)*zi,Math.asin(Math.max(-1,Math.min(1,go/n)))*zi]:void 0};var lo,fo,so,ho,go,po={sphere:function(){2>lo&&(lo=2,fo=so=ho=go=0)},point:nu,lineStart:ru,lineEnd:uu,polygonStart:function(){2>lo&&(lo=2,fo=so=ho=go=0),po.lineStart=eu},polygonEnd:function(){po.lineStart=ru}};qi.geo.circle=function(){function t(){var t="function"==typeof r?r.apply(this,arguments):r,n=ju(-t[0]*Ci,-t[1]*Ci,0).invert,u=[];return e(null,null,1,{point:function(t,e){u.push(t=n(t,e)),t[0]*=zi,t[1]*=zi}}),{type:"Polygon",coordinates:[u]}}var n,e,r=[0,0],u=6;return t.origin=function(n){return arguments.length?(r=n,t):r},t.angle=function(r){return arguments.length?(e=iu((n=+r)*Ci,u*Ci),t):n},t.precision=function(r){return arguments.length?(e=iu(n*Ci,(u=+r)*Ci),t):u},t.angle(90)};var mo=ou(o,pu,mu);(qi.geo.equirectangular=function(){return Lu(Mu).scale(250/Ni)}).raw=Mu.invert=Mu;var vo=Yu(function(t){return 1/t},Math.atan);(qi.geo.gnomonic=function(){return Lu(vo)}).raw=vo,qi.geo.graticule=function(){function t(){return{type:"MultiLineString",coordinates:n()}}function n(){return qi.range(Math.ceil(r/c)*c,e,c).map(a).concat(qi.range(Math.ceil(i/l)*l,u,l).map(o))}var e,r,u,i,a,o,c=22.5,l=c,f=2.5;return t.lines=function(){return n().map(function(t){return{type:"LineString",coordinates:t}})},t.outline=function(){return{type:"Polygon",coordinates:[a(r).concat(o(u).slice(1),a(e).reverse().slice(1),o(i).reverse().slice(1))]}},t.extent=function(n){return arguments.length?(r=+n[0][0],e=+n[1][0],i=+n[0][1],u=+n[1][1],r>e&&(n=r,r=e,e=n),i>u&&(n=i,i=u,u=n),t.precision(f)):[[r,i],[e,u]]},t.step=function(n){return arguments.length?(c=+n[0],l=+n[1],t):[c,l]},t.precision=function(n){return arguments.length?(f=+n,a=bu(i,u,f),o=xu(r,e,f),t):f},t.extent([[-180+Ti,-90+Ti],[180-Ti,90-Ti]])},qi.geo.interpolate=function(t,n){return _u(t[0]*Ci,t[1]*Ci,n[0]*Ci,n[1]*Ci)},qi.geo.greatArc=function(){function e(){for(var t=r||a.apply(this,arguments),n=u||o.apply(this,arguments),e=i||qi.geo.interpolate(t,n),l=0,f=c/e.distance,s=[t];1>(l+=f);)s.push(e(l));return s.push(n),{type:"LineString",coordinates:s}}var r,u,i,a=n,o=t,c=6*Ci;return e.distance=function(){return(i||qi.geo.interpolate(r||a.apply(this,arguments),u||o.apply(this,arguments))).distance},e.source=function(t){return arguments.length?(a=t,r="function"==typeof t?null:t,i=r&&u?qi.geo.interpolate(r,u):null,e):a},e.target=function(t){return arguments.length?(o=t,u="function"==typeof t?null:t,i=r&&u?qi.geo.interpolate(r,u):null,e):o},e.precision=function(t){return arguments.length?(c=t*Ci,e):c/Ci},e},wu.invert=function(t,n){return[2*Ni*t,2*Math.atan(Math.exp(2*Ni*n))-Ni/2]},(qi.geo.mercator=function(){return Lu(wu).scale(500)}).raw=wu;var yo=Yu(function(){return 1},Math.asin);(qi.geo.orthographic=function(){return Lu(yo)}).raw=yo,qi.geo.path=function(){function t(t){return t&&qi.geo.stream(t,r(u.pointRadius("function"==typeof i?+i.apply(this,arguments):i))),u.result()}var n,e,r,u,i=4.5;return t.area=function(t){return Mo=0,qi.geo.stream(t,r(xo)),Mo},t.centroid=function(t){return lo=so=ho=go=0,qi.geo.stream(t,r(_o)),go?[so/go,ho/go]:void 0},t.bounds=function(t){return tu(r)(t)},t.projection=function(e){return arguments.length?(r=(n=e)?e.stream||ku(e):a,t):n},t.context=function(n){return arguments.length?(u=null==(e=n)?new Eu:new Au(n),t):e},t.pointRadius=function(n){return arguments.length?(i="function"==typeof n?n:+n,t):i},t.projection(qi.geo.albersUsa()).context(null)};var Mo,bo,xo={point:Pn,lineStart:Pn,lineEnd:Pn,polygonStart:function(){bo=0,xo.lineStart=Nu},polygonEnd:function(){xo.lineStart=xo.lineEnd=xo.point=Pn,Mo+=Math.abs(bo/2)}},_o={point:Tu,lineStart:qu,lineEnd:Cu,polygonStart:function(){_o.lineStart=zu},polygonEnd:function(){_o.point=Tu,_o.lineStart=qu,_o.lineEnd=Cu}};qi.geo.area=function(t){return wo=0,qi.geo.stream(t,Eo),wo};var wo,So,ko,Eo={sphere:function(){wo+=4*Ni},point:Pn,lineStart:Pn,lineEnd:Pn,polygonStart:function(){So=1,ko=0,Eo.lineStart=Du},polygonEnd:function(){var t=2*Math.atan2(ko,So);wo+=0>t?4*Ni+t:t,Eo.lineStart=Eo.lineEnd=Eo.point=Pn}};qi.geo.projection=Lu,qi.geo.projectionMutator=Fu;var Ao=Yu(function(t){return 1/(1+t)},function(t){return 2*Math.atan(t)});(qi.geo.stereographic=function(){return Lu(Ao)}).raw=Ao,qi.geom={},qi.geom.hull=function(t){if(3>t.length)return[];var n,e,r,u,i,a,o,c,l,f,s=t.length,h=s-1,g=[],p=[],d=0;for(n=1;s>n;++n)t[n][1]<t[d][1]?d=n:t[n][1]==t[d][1]&&(d=t[n][0]<t[d][0]?n:d);for(n=0;s>n;++n)n!==d&&(u=t[n][1]-t[d][1],r=t[n][0]-t[d][0],g.push({angle:Math.atan2(u,r),index:n}));for(g.sort(function(t,n){return t.angle-n.angle}),l=g[0].angle,c=g[0].index,o=0,n=1;h>n;++n)e=g[n].index,l==g[n].angle?(r=t[c][0]-t[d][0],u=t[c][1]-t[d][1],i=t[e][0]-t[d][0],a=t[e][1]-t[d][1],r*r+u*u>=i*i+a*a?g[n].index=-1:(g[o].index=-1,l=g[n].angle,o=n,c=e)):(l=g[n].angle,o=n,c=e);for(p.push(d),n=0,e=0;2>n;++e)-1!==g[e].index&&(p.push(g[e].index),n++);for(f=p.length;h>e;++e)if(-1!==g[e].index){for(;!Uu(p[f-2],p[f-1],g[e].index,t);)--f;p[f++]=g[e].index}var m=[];for(n=0;f>n;++n)m.push(t[p[n]]);return m},qi.geom.polygon=function(t){return t.area=function(){for(var n=0,e=t.length,r=t[e-1][1]*t[0][0]-t[e-1][0]*t[0][1];e>++n;)r+=t[n-1][1]*t[n][0]-t[n-1][0]*t[n][1];return.5*r},t.centroid=function(n){var e,r,u=-1,i=t.length,a=0,o=0,c=t[i-1];for(arguments.length||(n=-1/(6*t.area()));i>++u;)e=c,c=t[u],r=e[0]*c[1]-c[0]*e[1],a+=(e[0]+c[0])*r,o+=(e[1]+c[1])*r;return[a*n,o*n]},t.clip=function(n){for(var e,r,u,i,a,o,c=-1,l=t.length,f=t[l-1];l>++c;){for(e=n.slice(),n.length=0,i=t[c],a=e[(u=e.length)-1],r=-1;u>++r;)o=e[r],Iu(o,f,i)?(Iu(a,f,i)||n.push(Vu(a,o,f,i)),n.push(o)):Iu(a,f,i)&&n.push(Vu(a,o,f,i)),a=o;f=i}return n},t},qi.geom.voronoi=function(t){var n=t.map(function(){return[]}),e=1e6;return Xu(t,function(t){var r,u,i,a,o,c;1===t.a&&t.b>=0?(r=t.ep.r,u=t.ep.l):(r=t.ep.l,u=t.ep.r),1===t.a?(o=r?r.y:-e,i=t.c-t.b*o,c=u?u.y:e,a=t.c-t.b*c):(i=r?r.x:-e,o=t.c-t.a*i,a=u?u.x:e,c=t.c-t.a*a);var l=[i,o],f=[a,c];n[t.region.l.index].push(l,f),n[t.region.r.index].push(l,f)}),n=n.map(function(n,e){var r=t[e][0],u=t[e][1],i=n.map(function(t){return Math.atan2(t[0]-r,t[1]-u)}),a=qi.range(n.length).sort(function(t,n){return i[t]-i[n]});return a.filter(function(t,n){return!n||i[t]-i[a[n-1]]>Ti}).map(function(t){return n[t]})}),n.forEach(function(n,r){var u=n.length;if(!u)return n.push([-e,-e],[-e,e],[e,e],[e,-e]);if(!(u>2)){var i=t[r],a=n[0],o=n[1],c=i[0],l=i[1],f=a[0],s=a[1],h=o[0],g=o[1],p=Math.abs(h-f),d=g-s;if(Ti>Math.abs(d)){var m=s>l?-e:e;n.push([-e,m],[e,m])}else if(Ti>p){var v=f>c?-e:e;n.push([v,-e],[v,e])}else{var m=(f-c)*(g-s)>(h-f)*(s-l)?e:-e,y=Math.abs(d)-p;Ti>Math.abs(y)?n.push([0>d?m:-m,m]):(y>0&&(m*=-1),n.push([-e,m],[e,m]))}}}),n};var No={l:"r",r:"l"};qi.geom.delaunay=function(t){var n=t.map(function(){return[]}),e=[];return Xu(t,function(e){n[e.region.l.index].push(t[e.region.r.index])}),n.forEach(function(n,r){var u=t[r],i=u[0],a=u[1];n.forEach(function(t){t.angle=Math.atan2(t[0]-i,t[1]-a)}),n.sort(function(t,n){return t.angle-n.angle});for(var o=0,c=n.length-1;c>o;o++)e.push([u,n[o],n[o+1]])}),e},qi.geom.quadtree=function(t,n,e,r,u){function i(t,n,e,r,u,i){if(!isNaN(n.x)&&!isNaN(n.y))if(t.leaf){var o=t.point;o?.01>Math.abs(o.x-n.x)+Math.abs(o.y-n.y)?a(t,n,e,r,u,i):(t.point=null,a(t,o,e,r,u,i),a(t,n,e,r,u,i)):t.point=n}else a(t,n,e,r,u,i)}function a(t,n,e,r,u,a){var o=.5*(e+u),c=.5*(r+a),l=n.x>=o,f=n.y>=c,s=(f<<1)+l;t.leaf=!1,t=t.nodes[s]||(t.nodes[s]=Zu()),l?e=o:u=o,f?r=c:a=c,i(t,n,e,r,u,a)}var o,c=-1,l=t.length;if(5>arguments.length)if(3===arguments.length)u=e,r=n,e=n=0;else for(n=e=1/0,r=u=-1/0;l>++c;)o=t[c],n>o.x&&(n=o.x),e>o.y&&(e=o.y),o.x>r&&(r=o.x),o.y>u&&(u=o.y);var f=r-n,s=u-e;f>s?u=e+f:r=n+s;var h=Zu();return h.add=function(t){i(h,t,n,e,r,u)},h.visit=function(t){Bu(t,h,n,e,r,u)},t.forEach(h.add),h},qi.time={};var To=Date,qo=["Sunday","Monday","Tuesday","Wednesday","Thursday","Friday","Saturday"];$u.prototype={getDate:function(){return this._.getUTCDate()},getDay:function(){return this._.getUTCDay()},getFullYear:function(){return this._.getUTCFullYear()},getHours:function(){return this._.getUTCHours()},getMilliseconds:function(){return this._.getUTCMilliseconds()},getMinutes:function(){return this._.getUTCMinutes()},getMonth:function(){return this._.getUTCMonth()},getSeconds:function(){return this._.getUTCSeconds()},getTime:function(){return this._.getTime()},getTimezoneOffset:function(){return 0},valueOf:function(){return this._.valueOf()},setDate:function(){Co.setUTCDate.apply(this._,arguments)},setDay:function(){Co.setUTCDay.apply(this._,arguments)},setFullYear:function(){Co.setUTCFullYear.apply(this._,arguments)},setHours:function(){Co.setUTCHours.apply(this._,arguments)},setMilliseconds:function(){Co.setUTCMilliseconds.apply(this._,arguments)},setMinutes:function(){Co.setUTCMinutes.apply(this._,arguments)},setMonth:function(){Co.setUTCMonth.apply(this._,arguments)},setSeconds:function(){Co.setUTCSeconds.apply(this._,arguments)},setTime:function(){Co.setTime.apply(this._,arguments)}};var Co=Date.prototype,zo="%a %b %e %X %Y",Do="%m/%d/%Y",Lo="%H:%M:%S",Fo=["Sunday","Monday","Tuesday","Wednesday","Thursday","Friday","Saturday"],Ho=["Sun","Mon","Tue","Wed","Thu","Fri","Sat"],jo=["January","February","March","April","May","June","July","August","September","October","November","December"],Po=["Jan","Feb","Mar","Apr","May","Jun","Jul","Aug","Sep","Oct","Nov","Dec"];qi.time.format=function(t){function n(n){for(var r,u,i,a=[],o=-1,c=0;e>++o;)37===t.charCodeAt(o)&&(a.push(t.substring(c,o)),null!=(u=Xo[r=t.charAt(++o)])&&(r=t.charAt(++o)),(i=Zo[r])&&(r=i(n,null==u?"e"===r?" ":"0":u)),a.push(r),c=o+1);return a.push(t.substring(c,o)),a.join("")}var e=t.length;return n.parse=function(n){var e={y:1900,m:0,d:1,H:0,M:0,S:0,L:0},r=Ju(e,t,n,0);if(r!=n.length)return null;"p"in e&&(e.H=e.H%12+12*e.p);var u=new To;return u.setFullYear(e.y,e.m,e.d),u.setHours(e.H,e.M,e.S,e.L),u},n.toString=function(){return t},n};var Ro=Gu(Fo),Oo=Gu(Ho),Yo=Gu(jo),Uo=Ku(jo),Io=Gu(Po),Vo=Ku(Po),Xo={"-":"",_:" ",0:"0"},Zo={a:function(t){return Ho[t.getDay()]},A:function(t){return Fo[t.getDay()]},b:function(t){return Po[t.getMonth()]},B:function(t){return jo[t.getMonth()]},c:qi.time.format(zo),d:function(t,n){return Wu(t.getDate(),n,2)},e:function(t,n){return Wu(t.getDate(),n,2)},H:function(t,n){return Wu(t.getHours(),n,2)},I:function(t,n){return Wu(t.getHours()%12||12,n,2)},j:function(t,n){return Wu(1+qi.time.dayOfYear(t),n,3)},L:function(t,n){return Wu(t.getMilliseconds(),n,3)},m:function(t,n){return Wu(t.getMonth()+1,n,2)},M:function(t,n){return Wu(t.getMinutes(),n,2)},p:function(t){return t.getHours()>=12?"PM":"AM"},S:function(t,n){return Wu(t.getSeconds(),n,2)},U:function(t,n){return Wu(qi.time.sundayOfYear(t),n,2)},w:function(t){return t.getDay()},W:function(t,n){return Wu(qi.time.mondayOfYear(t),n,2)},x:qi.time.format(Do),X:qi.time.format(Lo),y:function(t,n){return Wu(t.getFullYear()%100,n,2)},Y:function(t,n){return Wu(t.getFullYear()%1e4,n,4)},Z:mi,"%":function(){return"%"}},Bo={a:Qu,A:ti,b:ni,B:ei,c:ri,d:fi,e:fi,H:si,I:si,L:pi,m:li,M:hi,p:di,S:gi,x:ui,X:ii,y:oi,Y:ai},$o=/^\s*\d+/,Jo=qi.map({am:0,pm:1});qi.time.format.utc=function(t){function n(t){try{To=$u;var n=new To;return n._=t,e(n)}finally{To=Date}}var e=qi.time.format(t);return n.parse=function(t){try{To=$u;var n=e.parse(t);return n&&n._}finally{To=Date}},n.toString=e.toString,n};var Go=qi.time.format.utc("%Y-%m-%dT%H:%M:%S.%LZ");qi.time.format.iso=Date.prototype.toISOString?vi:Go,vi.parse=function(t){var n=new Date(t);return isNaN(n)?null:n},vi.toString=Go.toString,qi.time.second=yi(function(t){return new To(1e3*Math.floor(t/1e3))},function(t,n){t.setTime(t.getTime()+1e3*Math.floor(n))},function(t){return t.getSeconds()}),qi.time.seconds=qi.time.second.range,qi.time.seconds.utc=qi.time.second.utc.range,qi.time.minute=yi(function(t){return new To(6e4*Math.floor(t/6e4))},function(t,n){t.setTime(t.getTime()+6e4*Math.floor(n))},function(t){return t.getMinutes()}),qi.time.minutes=qi.time.minute.range,qi.time.minutes.utc=qi.time.minute.utc.range,qi.time.hour=yi(function(t){var n=t.getTimezoneOffset()/60;return new To(36e5*(Math.floor(t/36e5-n)+n))},function(t,n){t.setTime(t.getTime()+36e5*Math.floor(n))},function(t){return t.getHours()}),qi.time.hours=qi.time.hour.range,qi.time.hours.utc=qi.time.hour.utc.range,qi.time.day=yi(function(t){var n=new To(1970,0);return n.setFullYear(t.getFullYear(),t.getMonth(),t.getDate()),n},function(t,n){t.setDate(t.getDate()+n)},function(t){return t.getDate()-1}),qi.time.days=qi.time.day.range,qi.time.days.utc=qi.time.day.utc.range,qi.time.dayOfYear=function(t){var n=qi.time.year(t);return Math.floor((t-n-6e4*(t.getTimezoneOffset()-n.getTimezoneOffset()))/864e5)},qo.forEach(function(t,n){t=t.toLowerCase(),n=7-n;var e=qi.time[t]=yi(function(t){return(t=qi.time.day(t)).setDate(t.getDate()-(t.getDay()+n)%7),t},function(t,n){t.setDate(t.getDate()+7*Math.floor(n))},function(t){var e=qi.time.year(t).getDay();return Math.floor((qi.time.dayOfYear(t)+(e+n)%7)/7)-(e!==n)});qi.time[t+"s"]=e.range,qi.time[t+"s"].utc=e.utc.range,qi.time[t+"OfYear"]=function(t){var e=qi.time.year(t).getDay();return Math.floor((qi.time.dayOfYear(t)+(e+n)%7)/7)}}),qi.time.week=qi.time.sunday,qi.time.weeks=qi.time.sunday.range,qi.time.weeks.utc=qi.time.sunday.utc.range,qi.time.weekOfYear=qi.time.sundayOfYear,qi.time.month=yi(function(t){return t=qi.time.day(t),t.setDate(1),t},function(t,n){t.setMonth(t.getMonth()+n)},function(t){return t.getMonth()}),qi.time.months=qi.time.month.range,qi.time.months.utc=qi.time.month.utc.range,qi.time.year=yi(function(t){return t=qi.time.day(t),t.setMonth(0,1),t},function(t,n){t.setFullYear(t.getFullYear()+n)},function(t){return t.getFullYear()}),qi.time.years=qi.time.year.range,qi.time.years.utc=qi.time.year.utc.range;var Ko=[1e3,5e3,15e3,3e4,6e4,3e5,9e5,18e5,36e5,108e5,216e5,432e5,864e5,1728e5,6048e5,2592e6,7776e6,31536e6],Wo=[[qi.time.second,1],[qi.time.second,5],[qi.time.second,15],[qi.time.second,30],[qi.time.minute,1],[qi.time.minute,5],[qi.time.minute,15],[qi.time.minute,30],[qi.time.hour,1],[qi.time.hour,3],[qi.time.hour,6],[qi.time.hour,12],[qi.time.day,1],[qi.time.day,2],[qi.time.week,1],[qi.time.month,1],[qi.time.month,3],[qi.time.year,1]],Qo=[[qi.time.format("%Y"),o],[qi.time.format("%B"),function(t){return t.getMonth()}],[qi.time.format("%b %d"),function(t){return 1!=t.getDate()}],[qi.time.format("%a %d"),function(t){return t.getDay()&&1!=t.getDate()}],[qi.time.format("%I %p"),function(t){return t.getHours()}],[qi.time.format("%I:%M"),function(t){return t.getMinutes()}],[qi.time.format(":%S"),function(t){return t.getSeconds()}],[qi.time.format(".%L"),function(t){return t.getMilliseconds()}]],tc=qi.scale.linear(),nc=wi(Qo);Wo.year=function(t,n){return tc.domain(t.map(ki)).ticks(n).map(Si)},qi.time.scale=function(){return bi(qi.scale.linear(),Wo,nc)};var ec=Wo.map(function(t){return[t[0].utc,t[1]]}),rc=[[qi.time.format.utc("%Y"),o],[qi.time.format.utc("%B"),function(t){return t.getUTCMonth()}],[qi.time.format.utc("%b %d"),function(t){return 1!=t.getUTCDate()}],[qi.time.format.utc("%a %d"),function(t){return t.getUTCDay()&&1!=t.getUTCDate()}],[qi.time.format.utc("%I %p"),function(t){return t.getUTCHours()}],[qi.time.format.utc("%I:%M"),function(t){return t.getUTCMinutes()}],[qi.time.format.utc(":%S"),function(t){return t.getUTCSeconds()}],[qi.time.format.utc(".%L"),function(t){return t.getUTCMilliseconds()}]],uc=wi(rc);return ec.year=function(t,n){return tc.domain(t.map(Ai)).ticks(n).map(Ei)},qi.time.scale.utc=function(){return bi(qi.scale.linear(),ec,uc)},qi}();
/*! jQuery v1.9.0 | (c) 2005, 2012 jQuery Foundation, Inc. | jquery.org/license */(function(e,t){"use strict";function n(e){var t=e.length,n=st.type(e);return st.isWindow(e)?!1:1===e.nodeType&&t?!0:"array"===n||"function"!==n&&(0===t||"number"==typeof t&&t>0&&t-1 in e)}function r(e){var t=Tt[e]={};return st.each(e.match(lt)||[],function(e,n){t[n]=!0}),t}function i(e,n,r,i){if(st.acceptData(e)){var o,a,s=st.expando,u="string"==typeof n,l=e.nodeType,c=l?st.cache:e,f=l?e[s]:e[s]&&s;if(f&&c[f]&&(i||c[f].data)||!u||r!==t)return f||(l?e[s]=f=K.pop()||st.guid++:f=s),c[f]||(c[f]={},l||(c[f].toJSON=st.noop)),("object"==typeof n||"function"==typeof n)&&(i?c[f]=st.extend(c[f],n):c[f].data=st.extend(c[f].data,n)),o=c[f],i||(o.data||(o.data={}),o=o.data),r!==t&&(o[st.camelCase(n)]=r),u?(a=o[n],null==a&&(a=o[st.camelCase(n)])):a=o,a}}function o(e,t,n){if(st.acceptData(e)){var r,i,o,a=e.nodeType,u=a?st.cache:e,l=a?e[st.expando]:st.expando;if(u[l]){if(t&&(r=n?u[l]:u[l].data)){st.isArray(t)?t=t.concat(st.map(t,st.camelCase)):t in r?t=[t]:(t=st.camelCase(t),t=t in r?[t]:t.split(" "));for(i=0,o=t.length;o>i;i++)delete r[t[i]];if(!(n?s:st.isEmptyObject)(r))return}(n||(delete u[l].data,s(u[l])))&&(a?st.cleanData([e],!0):st.support.deleteExpando||u!=u.window?delete u[l]:u[l]=null)}}}function a(e,n,r){if(r===t&&1===e.nodeType){var i="data-"+n.replace(Nt,"-$1").toLowerCase();if(r=e.getAttribute(i),"string"==typeof r){try{r="true"===r?!0:"false"===r?!1:"null"===r?null:+r+""===r?+r:wt.test(r)?st.parseJSON(r):r}catch(o){}st.data(e,n,r)}else r=t}return r}function s(e){var t;for(t in e)if(("data"!==t||!st.isEmptyObject(e[t]))&&"toJSON"!==t)return!1;return!0}function u(){return!0}function l(){return!1}function c(e,t){do e=e[t];while(e&&1!==e.nodeType);return e}function f(e,t,n){if(t=t||0,st.isFunction(t))return st.grep(e,function(e,r){var i=!!t.call(e,r,e);return i===n});if(t.nodeType)return st.grep(e,function(e){return e===t===n});if("string"==typeof t){var r=st.grep(e,function(e){return 1===e.nodeType});if(Wt.test(t))return st.filter(t,r,!n);t=st.filter(t,r)}return st.grep(e,function(e){return st.inArray(e,t)>=0===n})}function p(e){var t=zt.split("|"),n=e.createDocumentFragment();if(n.createElement)for(;t.length;)n.createElement(t.pop());return n}function d(e,t){return e.getElementsByTagName(t)[0]||e.appendChild(e.ownerDocument.createElement(t))}function h(e){var t=e.getAttributeNode("type");return e.type=(t&&t.specified)+"/"+e.type,e}function g(e){var t=nn.exec(e.type);return t?e.type=t[1]:e.removeAttribute("type"),e}function m(e,t){for(var n,r=0;null!=(n=e[r]);r++)st._data(n,"globalEval",!t||st._data(t[r],"globalEval"))}function y(e,t){if(1===t.nodeType&&st.hasData(e)){var n,r,i,o=st._data(e),a=st._data(t,o),s=o.events;if(s){delete a.handle,a.events={};for(n in s)for(r=0,i=s[n].length;i>r;r++)st.event.add(t,n,s[n][r])}a.data&&(a.data=st.extend({},a.data))}}function v(e,t){var n,r,i;if(1===t.nodeType){if(n=t.nodeName.toLowerCase(),!st.support.noCloneEvent&&t[st.expando]){r=st._data(t);for(i in r.events)st.removeEvent(t,i,r.handle);t.removeAttribute(st.expando)}"script"===n&&t.text!==e.text?(h(t).text=e.text,g(t)):"object"===n?(t.parentNode&&(t.outerHTML=e.outerHTML),st.support.html5Clone&&e.innerHTML&&!st.trim(t.innerHTML)&&(t.innerHTML=e.innerHTML)):"input"===n&&Zt.test(e.type)?(t.defaultChecked=t.checked=e.checked,t.value!==e.value&&(t.value=e.value)):"option"===n?t.defaultSelected=t.selected=e.defaultSelected:("input"===n||"textarea"===n)&&(t.defaultValue=e.defaultValue)}}function b(e,n){var r,i,o=0,a=e.getElementsByTagName!==t?e.getElementsByTagName(n||"*"):e.querySelectorAll!==t?e.querySelectorAll(n||"*"):t;if(!a)for(a=[],r=e.childNodes||e;null!=(i=r[o]);o++)!n||st.nodeName(i,n)?a.push(i):st.merge(a,b(i,n));return n===t||n&&st.nodeName(e,n)?st.merge([e],a):a}function x(e){Zt.test(e.type)&&(e.defaultChecked=e.checked)}function T(e,t){if(t in e)return t;for(var n=t.charAt(0).toUpperCase()+t.slice(1),r=t,i=Nn.length;i--;)if(t=Nn[i]+n,t in e)return t;return r}function w(e,t){return e=t||e,"none"===st.css(e,"display")||!st.contains(e.ownerDocument,e)}function N(e,t){for(var n,r=[],i=0,o=e.length;o>i;i++)n=e[i],n.style&&(r[i]=st._data(n,"olddisplay"),t?(r[i]||"none"!==n.style.display||(n.style.display=""),""===n.style.display&&w(n)&&(r[i]=st._data(n,"olddisplay",S(n.nodeName)))):r[i]||w(n)||st._data(n,"olddisplay",st.css(n,"display")));for(i=0;o>i;i++)n=e[i],n.style&&(t&&"none"!==n.style.display&&""!==n.style.display||(n.style.display=t?r[i]||"":"none"));return e}function C(e,t,n){var r=mn.exec(t);return r?Math.max(0,r[1]-(n||0))+(r[2]||"px"):t}function k(e,t,n,r,i){for(var o=n===(r?"border":"content")?4:"width"===t?1:0,a=0;4>o;o+=2)"margin"===n&&(a+=st.css(e,n+wn[o],!0,i)),r?("content"===n&&(a-=st.css(e,"padding"+wn[o],!0,i)),"margin"!==n&&(a-=st.css(e,"border"+wn[o]+"Width",!0,i))):(a+=st.css(e,"padding"+wn[o],!0,i),"padding"!==n&&(a+=st.css(e,"border"+wn[o]+"Width",!0,i)));return a}function E(e,t,n){var r=!0,i="width"===t?e.offsetWidth:e.offsetHeight,o=ln(e),a=st.support.boxSizing&&"border-box"===st.css(e,"boxSizing",!1,o);if(0>=i||null==i){if(i=un(e,t,o),(0>i||null==i)&&(i=e.style[t]),yn.test(i))return i;r=a&&(st.support.boxSizingReliable||i===e.style[t]),i=parseFloat(i)||0}return i+k(e,t,n||(a?"border":"content"),r,o)+"px"}function S(e){var t=V,n=bn[e];return n||(n=A(e,t),"none"!==n&&n||(cn=(cn||st("<iframe frameborder='0' width='0' height='0'/>").css("cssText","display:block !important")).appendTo(t.documentElement),t=(cn[0].contentWindow||cn[0].contentDocument).document,t.write("<!doctype html><html><body>"),t.close(),n=A(e,t),cn.detach()),bn[e]=n),n}function A(e,t){var n=st(t.createElement(e)).appendTo(t.body),r=st.css(n[0],"display");return n.remove(),r}function j(e,t,n,r){var i;if(st.isArray(t))st.each(t,function(t,i){n||kn.test(e)?r(e,i):j(e+"["+("object"==typeof i?t:"")+"]",i,n,r)});else if(n||"object"!==st.type(t))r(e,t);else for(i in t)j(e+"["+i+"]",t[i],n,r)}function D(e){return function(t,n){"string"!=typeof t&&(n=t,t="*");var r,i=0,o=t.toLowerCase().match(lt)||[];if(st.isFunction(n))for(;r=o[i++];)"+"===r[0]?(r=r.slice(1)||"*",(e[r]=e[r]||[]).unshift(n)):(e[r]=e[r]||[]).push(n)}}function L(e,n,r,i){function o(u){var l;return a[u]=!0,st.each(e[u]||[],function(e,u){var c=u(n,r,i);return"string"!=typeof c||s||a[c]?s?!(l=c):t:(n.dataTypes.unshift(c),o(c),!1)}),l}var a={},s=e===$n;return o(n.dataTypes[0])||!a["*"]&&o("*")}function H(e,n){var r,i,o=st.ajaxSettings.flatOptions||{};for(r in n)n[r]!==t&&((o[r]?e:i||(i={}))[r]=n[r]);return i&&st.extend(!0,e,i),e}function M(e,n,r){var i,o,a,s,u=e.contents,l=e.dataTypes,c=e.responseFields;for(o in c)o in r&&(n[c[o]]=r[o]);for(;"*"===l[0];)l.shift(),i===t&&(i=e.mimeType||n.getResponseHeader("Content-Type"));if(i)for(o in u)if(u[o]&&u[o].test(i)){l.unshift(o);break}if(l[0]in r)a=l[0];else{for(o in r){if(!l[0]||e.converters[o+" "+l[0]]){a=o;break}s||(s=o)}a=a||s}return a?(a!==l[0]&&l.unshift(a),r[a]):t}function q(e,t){var n,r,i,o,a={},s=0,u=e.dataTypes.slice(),l=u[0];if(e.dataFilter&&(t=e.dataFilter(t,e.dataType)),u[1])for(n in e.converters)a[n.toLowerCase()]=e.converters[n];for(;i=u[++s];)if("*"!==i){if("*"!==l&&l!==i){if(n=a[l+" "+i]||a["* "+i],!n)for(r in a)if(o=r.split(" "),o[1]===i&&(n=a[l+" "+o[0]]||a["* "+o[0]])){n===!0?n=a[r]:a[r]!==!0&&(i=o[0],u.splice(s--,0,i));break}if(n!==!0)if(n&&e["throws"])t=n(t);else try{t=n(t)}catch(c){return{state:"parsererror",error:n?c:"No conversion from "+l+" to "+i}}}l=i}return{state:"success",data:t}}function _(){try{return new e.XMLHttpRequest}catch(t){}}function F(){try{return new e.ActiveXObject("Microsoft.XMLHTTP")}catch(t){}}function O(){return setTimeout(function(){Qn=t}),Qn=st.now()}function B(e,t){st.each(t,function(t,n){for(var r=(rr[t]||[]).concat(rr["*"]),i=0,o=r.length;o>i;i++)if(r[i].call(e,t,n))return})}function P(e,t,n){var r,i,o=0,a=nr.length,s=st.Deferred().always(function(){delete u.elem}),u=function(){if(i)return!1;for(var t=Qn||O(),n=Math.max(0,l.startTime+l.duration-t),r=n/l.duration||0,o=1-r,a=0,u=l.tweens.length;u>a;a++)l.tweens[a].run(o);return s.notifyWith(e,[l,o,n]),1>o&&u?n:(s.resolveWith(e,[l]),!1)},l=s.promise({elem:e,props:st.extend({},t),opts:st.extend(!0,{specialEasing:{}},n),originalProperties:t,originalOptions:n,startTime:Qn||O(),duration:n.duration,tweens:[],createTween:function(t,n){var r=st.Tween(e,l.opts,t,n,l.opts.specialEasing[t]||l.opts.easing);return l.tweens.push(r),r},stop:function(t){var n=0,r=t?l.tweens.length:0;if(i)return this;for(i=!0;r>n;n++)l.tweens[n].run(1);return t?s.resolveWith(e,[l,t]):s.rejectWith(e,[l,t]),this}}),c=l.props;for(R(c,l.opts.specialEasing);a>o;o++)if(r=nr[o].call(l,e,c,l.opts))return r;return B(l,c),st.isFunction(l.opts.start)&&l.opts.start.call(e,l),st.fx.timer(st.extend(u,{elem:e,anim:l,queue:l.opts.queue})),l.progress(l.opts.progress).done(l.opts.done,l.opts.complete).fail(l.opts.fail).always(l.opts.always)}function R(e,t){var n,r,i,o,a;for(n in e)if(r=st.camelCase(n),i=t[r],o=e[n],st.isArray(o)&&(i=o[1],o=e[n]=o[0]),n!==r&&(e[r]=o,delete e[n]),a=st.cssHooks[r],a&&"expand"in a){o=a.expand(o),delete e[r];for(n in o)n in e||(e[n]=o[n],t[n]=i)}else t[r]=i}function W(e,t,n){var r,i,o,a,s,u,l,c,f,p=this,d=e.style,h={},g=[],m=e.nodeType&&w(e);n.queue||(c=st._queueHooks(e,"fx"),null==c.unqueued&&(c.unqueued=0,f=c.empty.fire,c.empty.fire=function(){c.unqueued||f()}),c.unqueued++,p.always(function(){p.always(function(){c.unqueued--,st.queue(e,"fx").length||c.empty.fire()})})),1===e.nodeType&&("height"in t||"width"in t)&&(n.overflow=[d.overflow,d.overflowX,d.overflowY],"inline"===st.css(e,"display")&&"none"===st.css(e,"float")&&(st.support.inlineBlockNeedsLayout&&"inline"!==S(e.nodeName)?d.zoom=1:d.display="inline-block")),n.overflow&&(d.overflow="hidden",st.support.shrinkWrapBlocks||p.done(function(){d.overflow=n.overflow[0],d.overflowX=n.overflow[1],d.overflowY=n.overflow[2]}));for(r in t)if(o=t[r],Zn.exec(o)){if(delete t[r],u=u||"toggle"===o,o===(m?"hide":"show"))continue;g.push(r)}if(a=g.length){s=st._data(e,"fxshow")||st._data(e,"fxshow",{}),"hidden"in s&&(m=s.hidden),u&&(s.hidden=!m),m?st(e).show():p.done(function(){st(e).hide()}),p.done(function(){var t;st._removeData(e,"fxshow");for(t in h)st.style(e,t,h[t])});for(r=0;a>r;r++)i=g[r],l=p.createTween(i,m?s[i]:0),h[i]=s[i]||st.style(e,i),i in s||(s[i]=l.start,m&&(l.end=l.start,l.start="width"===i||"height"===i?1:0))}}function $(e,t,n,r,i){return new $.prototype.init(e,t,n,r,i)}function I(e,t){var n,r={height:e},i=0;for(t=t?1:0;4>i;i+=2-t)n=wn[i],r["margin"+n]=r["padding"+n]=e;return t&&(r.opacity=r.width=e),r}function z(e){return st.isWindow(e)?e:9===e.nodeType?e.defaultView||e.parentWindow:!1}var X,U,V=e.document,Y=e.location,J=e.jQuery,G=e.$,Q={},K=[],Z="1.9.0",et=K.concat,tt=K.push,nt=K.slice,rt=K.indexOf,it=Q.toString,ot=Q.hasOwnProperty,at=Z.trim,st=function(e,t){return new st.fn.init(e,t,X)},ut=/[+-]?(?:\d*\.|)\d+(?:[eE][+-]?\d+|)/.source,lt=/\S+/g,ct=/^[\s\uFEFF\xA0]+|[\s\uFEFF\xA0]+$/g,ft=/^(?:(<[\w\W]+>)[^>]*|#([\w-]*))$/,pt=/^<(\w+)\s*\/?>(?:<\/\1>|)$/,dt=/^[\],:{}\s]*$/,ht=/(?:^|:|,)(?:\s*\[)+/g,gt=/\\(?:["\\\/bfnrt]|u[\da-fA-F]{4})/g,mt=/"[^"\\\r\n]*"|true|false|null|-?(?:\d+\.|)\d+(?:[eE][+-]?\d+|)/g,yt=/^-ms-/,vt=/-([\da-z])/gi,bt=function(e,t){return t.toUpperCase()},xt=function(){V.addEventListener?(V.removeEventListener("DOMContentLoaded",xt,!1),st.ready()):"complete"===V.readyState&&(V.detachEvent("onreadystatechange",xt),st.ready())};st.fn=st.prototype={jquery:Z,constructor:st,init:function(e,n,r){var i,o;if(!e)return this;if("string"==typeof e){if(i="<"===e.charAt(0)&&">"===e.charAt(e.length-1)&&e.length>=3?[null,e,null]:ft.exec(e),!i||!i[1]&&n)return!n||n.jquery?(n||r).find(e):this.constructor(n).find(e);if(i[1]){if(n=n instanceof st?n[0]:n,st.merge(this,st.parseHTML(i[1],n&&n.nodeType?n.ownerDocument||n:V,!0)),pt.test(i[1])&&st.isPlainObject(n))for(i in n)st.isFunction(this[i])?this[i](n[i]):this.attr(i,n[i]);return this}if(o=V.getElementById(i[2]),o&&o.parentNode){if(o.id!==i[2])return r.find(e);this.length=1,this[0]=o}return this.context=V,this.selector=e,this}return e.nodeType?(this.context=this[0]=e,this.length=1,this):st.isFunction(e)?r.ready(e):(e.selector!==t&&(this.selector=e.selector,this.context=e.context),st.makeArray(e,this))},selector:"",length:0,size:function(){return this.length},toArray:function(){return nt.call(this)},get:function(e){return null==e?this.toArray():0>e?this[this.length+e]:this[e]},pushStack:function(e){var t=st.merge(this.constructor(),e);return t.prevObject=this,t.context=this.context,t},each:function(e,t){return st.each(this,e,t)},ready:function(e){return st.ready.promise().done(e),this},slice:function(){return this.pushStack(nt.apply(this,arguments))},first:function(){return this.eq(0)},last:function(){return this.eq(-1)},eq:function(e){var t=this.length,n=+e+(0>e?t:0);return this.pushStack(n>=0&&t>n?[this[n]]:[])},map:function(e){return this.pushStack(st.map(this,function(t,n){return e.call(t,n,t)}))},end:function(){return this.prevObject||this.constructor(null)},push:tt,sort:[].sort,splice:[].splice},st.fn.init.prototype=st.fn,st.extend=st.fn.extend=function(){var e,n,r,i,o,a,s=arguments[0]||{},u=1,l=arguments.length,c=!1;for("boolean"==typeof s&&(c=s,s=arguments[1]||{},u=2),"object"==typeof s||st.isFunction(s)||(s={}),l===u&&(s=this,--u);l>u;u++)if(null!=(e=arguments[u]))for(n in e)r=s[n],i=e[n],s!==i&&(c&&i&&(st.isPlainObject(i)||(o=st.isArray(i)))?(o?(o=!1,a=r&&st.isArray(r)?r:[]):a=r&&st.isPlainObject(r)?r:{},s[n]=st.extend(c,a,i)):i!==t&&(s[n]=i));return s},st.extend({noConflict:function(t){return e.$===st&&(e.$=G),t&&e.jQuery===st&&(e.jQuery=J),st},isReady:!1,readyWait:1,holdReady:function(e){e?st.readyWait++:st.ready(!0)},ready:function(e){if(e===!0?!--st.readyWait:!st.isReady){if(!V.body)return setTimeout(st.ready);st.isReady=!0,e!==!0&&--st.readyWait>0||(U.resolveWith(V,[st]),st.fn.trigger&&st(V).trigger("ready").off("ready"))}},isFunction:function(e){return"function"===st.type(e)},isArray:Array.isArray||function(e){return"array"===st.type(e)},isWindow:function(e){return null!=e&&e==e.window},isNumeric:function(e){return!isNaN(parseFloat(e))&&isFinite(e)},type:function(e){return null==e?e+"":"object"==typeof e||"function"==typeof e?Q[it.call(e)]||"object":typeof e},isPlainObject:function(e){if(!e||"object"!==st.type(e)||e.nodeType||st.isWindow(e))return!1;try{if(e.constructor&&!ot.call(e,"constructor")&&!ot.call(e.constructor.prototype,"isPrototypeOf"))return!1}catch(n){return!1}var r;for(r in e);return r===t||ot.call(e,r)},isEmptyObject:function(e){var t;for(t in e)return!1;return!0},error:function(e){throw Error(e)},parseHTML:function(e,t,n){if(!e||"string"!=typeof e)return null;"boolean"==typeof t&&(n=t,t=!1),t=t||V;var r=pt.exec(e),i=!n&&[];return r?[t.createElement(r[1])]:(r=st.buildFragment([e],t,i),i&&st(i).remove(),st.merge([],r.childNodes))},parseJSON:function(n){return e.JSON&&e.JSON.parse?e.JSON.parse(n):null===n?n:"string"==typeof n&&(n=st.trim(n),n&&dt.test(n.replace(gt,"@").replace(mt,"]").replace(ht,"")))?Function("return "+n)():(st.error("Invalid JSON: "+n),t)},parseXML:function(n){var r,i;if(!n||"string"!=typeof n)return null;try{e.DOMParser?(i=new DOMParser,r=i.parseFromString(n,"text/xml")):(r=new ActiveXObject("Microsoft.XMLDOM"),r.async="false",r.loadXML(n))}catch(o){r=t}return r&&r.documentElement&&!r.getElementsByTagName("parsererror").length||st.error("Invalid XML: "+n),r},noop:function(){},globalEval:function(t){t&&st.trim(t)&&(e.execScript||function(t){e.eval.call(e,t)})(t)},camelCase:function(e){return e.replace(yt,"ms-").replace(vt,bt)},nodeName:function(e,t){return e.nodeName&&e.nodeName.toLowerCase()===t.toLowerCase()},each:function(e,t,r){var i,o=0,a=e.length,s=n(e);if(r){if(s)for(;a>o&&(i=t.apply(e[o],r),i!==!1);o++);else for(o in e)if(i=t.apply(e[o],r),i===!1)break}else if(s)for(;a>o&&(i=t.call(e[o],o,e[o]),i!==!1);o++);else for(o in e)if(i=t.call(e[o],o,e[o]),i===!1)break;return e},trim:at&&!at.call("\ufeff\u00a0")?function(e){return null==e?"":at.call(e)}:function(e){return null==e?"":(e+"").replace(ct,"")},makeArray:function(e,t){var r=t||[];return null!=e&&(n(Object(e))?st.merge(r,"string"==typeof e?[e]:e):tt.call(r,e)),r},inArray:function(e,t,n){var r;if(t){if(rt)return rt.call(t,e,n);for(r=t.length,n=n?0>n?Math.max(0,r+n):n:0;r>n;n++)if(n in t&&t[n]===e)return n}return-1},merge:function(e,n){var r=n.length,i=e.length,o=0;if("number"==typeof r)for(;r>o;o++)e[i++]=n[o];else for(;n[o]!==t;)e[i++]=n[o++];return e.length=i,e},grep:function(e,t,n){var r,i=[],o=0,a=e.length;for(n=!!n;a>o;o++)r=!!t(e[o],o),n!==r&&i.push(e[o]);return i},map:function(e,t,r){var i,o=0,a=e.length,s=n(e),u=[];if(s)for(;a>o;o++)i=t(e[o],o,r),null!=i&&(u[u.length]=i);else for(o in e)i=t(e[o],o,r),null!=i&&(u[u.length]=i);return et.apply([],u)},guid:1,proxy:function(e,n){var r,i,o;return"string"==typeof n&&(r=e[n],n=e,e=r),st.isFunction(e)?(i=nt.call(arguments,2),o=function(){return e.apply(n||this,i.concat(nt.call(arguments)))},o.guid=e.guid=e.guid||st.guid++,o):t},access:function(e,n,r,i,o,a,s){var u=0,l=e.length,c=null==r;if("object"===st.type(r)){o=!0;for(u in r)st.access(e,n,u,r[u],!0,a,s)}else if(i!==t&&(o=!0,st.isFunction(i)||(s=!0),c&&(s?(n.call(e,i),n=null):(c=n,n=function(e,t,n){return c.call(st(e),n)})),n))for(;l>u;u++)n(e[u],r,s?i:i.call(e[u],u,n(e[u],r)));return o?e:c?n.call(e):l?n(e[0],r):a},now:function(){return(new Date).getTime()}}),st.ready.promise=function(t){if(!U)if(U=st.Deferred(),"complete"===V.readyState)setTimeout(st.ready);else if(V.addEventListener)V.addEventListener("DOMContentLoaded",xt,!1),e.addEventListener("load",st.ready,!1);else{V.attachEvent("onreadystatechange",xt),e.attachEvent("onload",st.ready);var n=!1;try{n=null==e.frameElement&&V.documentElement}catch(r){}n&&n.doScroll&&function i(){if(!st.isReady){try{n.doScroll("left")}catch(e){return setTimeout(i,50)}st.ready()}}()}return U.promise(t)},st.each("Boolean Number String Function Array Date RegExp Object Error".split(" "),function(e,t){Q["[object "+t+"]"]=t.toLowerCase()}),X=st(V);var Tt={};st.Callbacks=function(e){e="string"==typeof e?Tt[e]||r(e):st.extend({},e);var n,i,o,a,s,u,l=[],c=!e.once&&[],f=function(t){for(n=e.memory&&t,i=!0,u=a||0,a=0,s=l.length,o=!0;l&&s>u;u++)if(l[u].apply(t[0],t[1])===!1&&e.stopOnFalse){n=!1;break}o=!1,l&&(c?c.length&&f(c.shift()):n?l=[]:p.disable())},p={add:function(){if(l){var t=l.length;(function r(t){st.each(t,function(t,n){var i=st.type(n);"function"===i?e.unique&&p.has(n)||l.push(n):n&&n.length&&"string"!==i&&r(n)})})(arguments),o?s=l.length:n&&(a=t,f(n))}return this},remove:function(){return l&&st.each(arguments,function(e,t){for(var n;(n=st.inArray(t,l,n))>-1;)l.splice(n,1),o&&(s>=n&&s--,u>=n&&u--)}),this},has:function(e){return st.inArray(e,l)>-1},empty:function(){return l=[],this},disable:function(){return l=c=n=t,this},disabled:function(){return!l},lock:function(){return c=t,n||p.disable(),this},locked:function(){return!c},fireWith:function(e,t){return t=t||[],t=[e,t.slice?t.slice():t],!l||i&&!c||(o?c.push(t):f(t)),this},fire:function(){return p.fireWith(this,arguments),this},fired:function(){return!!i}};return p},st.extend({Deferred:function(e){var t=[["resolve","done",st.Callbacks("once memory"),"resolved"],["reject","fail",st.Callbacks("once memory"),"rejected"],["notify","progress",st.Callbacks("memory")]],n="pending",r={state:function(){return n},always:function(){return i.done(arguments).fail(arguments),this},then:function(){var e=arguments;return st.Deferred(function(n){st.each(t,function(t,o){var a=o[0],s=st.isFunction(e[t])&&e[t];i[o[1]](function(){var e=s&&s.apply(this,arguments);e&&st.isFunction(e.promise)?e.promise().done(n.resolve).fail(n.reject).progress(n.notify):n[a+"With"](this===r?n.promise():this,s?[e]:arguments)})}),e=null}).promise()},promise:function(e){return null!=e?st.extend(e,r):r}},i={};return r.pipe=r.then,st.each(t,function(e,o){var a=o[2],s=o[3];r[o[1]]=a.add,s&&a.add(function(){n=s},t[1^e][2].disable,t[2][2].lock),i[o[0]]=function(){return i[o[0]+"With"](this===i?r:this,arguments),this},i[o[0]+"With"]=a.fireWith}),r.promise(i),e&&e.call(i,i),i},when:function(e){var t,n,r,i=0,o=nt.call(arguments),a=o.length,s=1!==a||e&&st.isFunction(e.promise)?a:0,u=1===s?e:st.Deferred(),l=function(e,n,r){return function(i){n[e]=this,r[e]=arguments.length>1?nt.call(arguments):i,r===t?u.notifyWith(n,r):--s||u.resolveWith(n,r)}};if(a>1)for(t=Array(a),n=Array(a),r=Array(a);a>i;i++)o[i]&&st.isFunction(o[i].promise)?o[i].promise().done(l(i,r,o)).fail(u.reject).progress(l(i,n,t)):--s;return s||u.resolveWith(r,o),u.promise()}}),st.support=function(){var n,r,i,o,a,s,u,l,c,f,p=V.createElement("div");if(p.setAttribute("className","t"),p.innerHTML="  <link/><table></table><a href='/a'>a</a><input type='checkbox'/>",r=p.getElementsByTagName("*"),i=p.getElementsByTagName("a")[0],!r||!i||!r.length)return{};o=V.createElement("select"),a=o.appendChild(V.createElement("option")),s=p.getElementsByTagName("input")[0],i.style.cssText="top:1px;float:left;opacity:.5",n={getSetAttribute:"t"!==p.className,leadingWhitespace:3===p.firstChild.nodeType,tbody:!p.getElementsByTagName("tbody").length,htmlSerialize:!!p.getElementsByTagName("link").length,style:/top/.test(i.getAttribute("style")),hrefNormalized:"/a"===i.getAttribute("href"),opacity:/^0.5/.test(i.style.opacity),cssFloat:!!i.style.cssFloat,checkOn:!!s.value,optSelected:a.selected,enctype:!!V.createElement("form").enctype,html5Clone:"<:nav></:nav>"!==V.createElement("nav").cloneNode(!0).outerHTML,boxModel:"CSS1Compat"===V.compatMode,deleteExpando:!0,noCloneEvent:!0,inlineBlockNeedsLayout:!1,shrinkWrapBlocks:!1,reliableMarginRight:!0,boxSizingReliable:!0,pixelPosition:!1},s.checked=!0,n.noCloneChecked=s.cloneNode(!0).checked,o.disabled=!0,n.optDisabled=!a.disabled;try{delete p.test}catch(d){n.deleteExpando=!1}s=V.createElement("input"),s.setAttribute("value",""),n.input=""===s.getAttribute("value"),s.value="t",s.setAttribute("type","radio"),n.radioValue="t"===s.value,s.setAttribute("checked","t"),s.setAttribute("name","t"),u=V.createDocumentFragment(),u.appendChild(s),n.appendChecked=s.checked,n.checkClone=u.cloneNode(!0).cloneNode(!0).lastChild.checked,p.attachEvent&&(p.attachEvent("onclick",function(){n.noCloneEvent=!1}),p.cloneNode(!0).click());for(f in{submit:!0,change:!0,focusin:!0})p.setAttribute(l="on"+f,"t"),n[f+"Bubbles"]=l in e||p.attributes[l].expando===!1;return p.style.backgroundClip="content-box",p.cloneNode(!0).style.backgroundClip="",n.clearCloneStyle="content-box"===p.style.backgroundClip,st(function(){var r,i,o,a="padding:0;margin:0;border:0;display:block;box-sizing:content-box;-moz-box-sizing:content-box;-webkit-box-sizing:content-box;",s=V.getElementsByTagName("body")[0];s&&(r=V.createElement("div"),r.style.cssText="border:0;width:0;height:0;position:absolute;top:0;left:-9999px;margin-top:1px",s.appendChild(r).appendChild(p),p.innerHTML="<table><tr><td></td><td>t</td></tr></table>",o=p.getElementsByTagName("td"),o[0].style.cssText="padding:0;margin:0;border:0;display:none",c=0===o[0].offsetHeight,o[0].style.display="",o[1].style.display="none",n.reliableHiddenOffsets=c&&0===o[0].offsetHeight,p.innerHTML="",p.style.cssText="box-sizing:border-box;-moz-box-sizing:border-box;-webkit-box-sizing:border-box;padding:1px;border:1px;display:block;width:4px;margin-top:1%;position:absolute;top:1%;",n.boxSizing=4===p.offsetWidth,n.doesNotIncludeMarginInBodyOffset=1!==s.offsetTop,e.getComputedStyle&&(n.pixelPosition="1%"!==(e.getComputedStyle(p,null)||{}).top,n.boxSizingReliable="4px"===(e.getComputedStyle(p,null)||{width:"4px"}).width,i=p.appendChild(V.createElement("div")),i.style.cssText=p.style.cssText=a,i.style.marginRight=i.style.width="0",p.style.width="1px",n.reliableMarginRight=!parseFloat((e.getComputedStyle(i,null)||{}).marginRight)),p.style.zoom!==t&&(p.innerHTML="",p.style.cssText=a+"width:1px;padding:1px;display:inline;zoom:1",n.inlineBlockNeedsLayout=3===p.offsetWidth,p.style.display="block",p.innerHTML="<div></div>",p.firstChild.style.width="5px",n.shrinkWrapBlocks=3!==p.offsetWidth,s.style.zoom=1),s.removeChild(r),r=p=o=i=null)}),r=o=u=a=i=s=null,n}();var wt=/(?:\{[\s\S]*\}|\[[\s\S]*\])$/,Nt=/([A-Z])/g;st.extend({cache:{},expando:"jQuery"+(Z+Math.random()).replace(/\D/g,""),noData:{embed:!0,object:"clsid:D27CDB6E-AE6D-11cf-96B8-444553540000",applet:!0},hasData:function(e){return e=e.nodeType?st.cache[e[st.expando]]:e[st.expando],!!e&&!s(e)},data:function(e,t,n){return i(e,t,n,!1)},removeData:function(e,t){return o(e,t,!1)},_data:function(e,t,n){return i(e,t,n,!0)},_removeData:function(e,t){return o(e,t,!0)},acceptData:function(e){var t=e.nodeName&&st.noData[e.nodeName.toLowerCase()];return!t||t!==!0&&e.getAttribute("classid")===t}}),st.fn.extend({data:function(e,n){var r,i,o=this[0],s=0,u=null;if(e===t){if(this.length&&(u=st.data(o),1===o.nodeType&&!st._data(o,"parsedAttrs"))){for(r=o.attributes;r.length>s;s++)i=r[s].name,i.indexOf("data-")||(i=st.camelCase(i.substring(5)),a(o,i,u[i]));st._data(o,"parsedAttrs",!0)}return u}return"object"==typeof e?this.each(function(){st.data(this,e)}):st.access(this,function(n){return n===t?o?a(o,e,st.data(o,e)):null:(this.each(function(){st.data(this,e,n)}),t)},null,n,arguments.length>1,null,!0)},removeData:function(e){return this.each(function(){st.removeData(this,e)})}}),st.extend({queue:function(e,n,r){var i;return e?(n=(n||"fx")+"queue",i=st._data(e,n),r&&(!i||st.isArray(r)?i=st._data(e,n,st.makeArray(r)):i.push(r)),i||[]):t},dequeue:function(e,t){t=t||"fx";var n=st.queue(e,t),r=n.length,i=n.shift(),o=st._queueHooks(e,t),a=function(){st.dequeue(e,t)};"inprogress"===i&&(i=n.shift(),r--),o.cur=i,i&&("fx"===t&&n.unshift("inprogress"),delete o.stop,i.call(e,a,o)),!r&&o&&o.empty.fire()},_queueHooks:function(e,t){var n=t+"queueHooks";return st._data(e,n)||st._data(e,n,{empty:st.Callbacks("once memory").add(function(){st._removeData(e,t+"queue"),st._removeData(e,n)})})}}),st.fn.extend({queue:function(e,n){var r=2;return"string"!=typeof e&&(n=e,e="fx",r--),r>arguments.length?st.queue(this[0],e):n===t?this:this.each(function(){var t=st.queue(this,e,n);st._queueHooks(this,e),"fx"===e&&"inprogress"!==t[0]&&st.dequeue(this,e)})},dequeue:function(e){return this.each(function(){st.dequeue(this,e)})},delay:function(e,t){return e=st.fx?st.fx.speeds[e]||e:e,t=t||"fx",this.queue(t,function(t,n){var r=setTimeout(t,e);n.stop=function(){clearTimeout(r)}})},clearQueue:function(e){return this.queue(e||"fx",[])},promise:function(e,n){var r,i=1,o=st.Deferred(),a=this,s=this.length,u=function(){--i||o.resolveWith(a,[a])};for("string"!=typeof e&&(n=e,e=t),e=e||"fx";s--;)r=st._data(a[s],e+"queueHooks"),r&&r.empty&&(i++,r.empty.add(u));return u(),o.promise(n)}});var Ct,kt,Et=/[\t\r\n]/g,St=/\r/g,At=/^(?:input|select|textarea|button|object)$/i,jt=/^(?:a|area)$/i,Dt=/^(?:checked|selected|autofocus|autoplay|async|controls|defer|disabled|hidden|loop|multiple|open|readonly|required|scoped)$/i,Lt=/^(?:checked|selected)$/i,Ht=st.support.getSetAttribute,Mt=st.support.input;st.fn.extend({attr:function(e,t){return st.access(this,st.attr,e,t,arguments.length>1)},removeAttr:function(e){return this.each(function(){st.removeAttr(this,e)})},prop:function(e,t){return st.access(this,st.prop,e,t,arguments.length>1)},removeProp:function(e){return e=st.propFix[e]||e,this.each(function(){try{this[e]=t,delete this[e]}catch(n){}})},addClass:function(e){var t,n,r,i,o,a=0,s=this.length,u="string"==typeof e&&e;if(st.isFunction(e))return this.each(function(t){st(this).addClass(e.call(this,t,this.className))});if(u)for(t=(e||"").match(lt)||[];s>a;a++)if(n=this[a],r=1===n.nodeType&&(n.className?(" "+n.className+" ").replace(Et," "):" ")){for(o=0;i=t[o++];)0>r.indexOf(" "+i+" ")&&(r+=i+" ");n.className=st.trim(r)}return this},removeClass:function(e){var t,n,r,i,o,a=0,s=this.length,u=0===arguments.length||"string"==typeof e&&e;if(st.isFunction(e))return this.each(function(t){st(this).removeClass(e.call(this,t,this.className))});if(u)for(t=(e||"").match(lt)||[];s>a;a++)if(n=this[a],r=1===n.nodeType&&(n.className?(" "+n.className+" ").replace(Et," "):"")){for(o=0;i=t[o++];)for(;r.indexOf(" "+i+" ")>=0;)r=r.replace(" "+i+" "," ");n.className=e?st.trim(r):""}return this},toggleClass:function(e,t){var n=typeof e,r="boolean"==typeof t;return st.isFunction(e)?this.each(function(n){st(this).toggleClass(e.call(this,n,this.className,t),t)}):this.each(function(){if("string"===n)for(var i,o=0,a=st(this),s=t,u=e.match(lt)||[];i=u[o++];)s=r?s:!a.hasClass(i),a[s?"addClass":"removeClass"](i);else("undefined"===n||"boolean"===n)&&(this.className&&st._data(this,"__className__",this.className),this.className=this.className||e===!1?"":st._data(this,"__className__")||"")})},hasClass:function(e){for(var t=" "+e+" ",n=0,r=this.length;r>n;n++)if(1===this[n].nodeType&&(" "+this[n].className+" ").replace(Et," ").indexOf(t)>=0)return!0;return!1},val:function(e){var n,r,i,o=this[0];{if(arguments.length)return i=st.isFunction(e),this.each(function(r){var o,a=st(this);1===this.nodeType&&(o=i?e.call(this,r,a.val()):e,null==o?o="":"number"==typeof o?o+="":st.isArray(o)&&(o=st.map(o,function(e){return null==e?"":e+""})),n=st.valHooks[this.type]||st.valHooks[this.nodeName.toLowerCase()],n&&"set"in n&&n.set(this,o,"value")!==t||(this.value=o))});if(o)return n=st.valHooks[o.type]||st.valHooks[o.nodeName.toLowerCase()],n&&"get"in n&&(r=n.get(o,"value"))!==t?r:(r=o.value,"string"==typeof r?r.replace(St,""):null==r?"":r)}}}),st.extend({valHooks:{option:{get:function(e){var t=e.attributes.value;return!t||t.specified?e.value:e.text}},select:{get:function(e){for(var t,n,r=e.options,i=e.selectedIndex,o="select-one"===e.type||0>i,a=o?null:[],s=o?i+1:r.length,u=0>i?s:o?i:0;s>u;u++)if(n=r[u],!(!n.selected&&u!==i||(st.support.optDisabled?n.disabled:null!==n.getAttribute("disabled"))||n.parentNode.disabled&&st.nodeName(n.parentNode,"optgroup"))){if(t=st(n).val(),o)return t;a.push(t)}return a},set:function(e,t){var n=st.makeArray(t);return st(e).find("option").each(function(){this.selected=st.inArray(st(this).val(),n)>=0}),n.length||(e.selectedIndex=-1),n}}},attr:function(e,n,r){var i,o,a,s=e.nodeType;if(e&&3!==s&&8!==s&&2!==s)return e.getAttribute===t?st.prop(e,n,r):(a=1!==s||!st.isXMLDoc(e),a&&(n=n.toLowerCase(),o=st.attrHooks[n]||(Dt.test(n)?kt:Ct)),r===t?o&&a&&"get"in o&&null!==(i=o.get(e,n))?i:(e.getAttribute!==t&&(i=e.getAttribute(n)),null==i?t:i):null!==r?o&&a&&"set"in o&&(i=o.set(e,r,n))!==t?i:(e.setAttribute(n,r+""),r):(st.removeAttr(e,n),t))},removeAttr:function(e,t){var n,r,i=0,o=t&&t.match(lt);if(o&&1===e.nodeType)for(;n=o[i++];)r=st.propFix[n]||n,Dt.test(n)?!Ht&&Lt.test(n)?e[st.camelCase("default-"+n)]=e[r]=!1:e[r]=!1:st.attr(e,n,""),e.removeAttribute(Ht?n:r)},attrHooks:{type:{set:function(e,t){if(!st.support.radioValue&&"radio"===t&&st.nodeName(e,"input")){var n=e.value;return e.setAttribute("type",t),n&&(e.value=n),t}}}},propFix:{tabindex:"tabIndex",readonly:"readOnly","for":"htmlFor","class":"className",maxlength:"maxLength",cellspacing:"cellSpacing",cellpadding:"cellPadding",rowspan:"rowSpan",colspan:"colSpan",usemap:"useMap",frameborder:"frameBorder",contenteditable:"contentEditable"},prop:function(e,n,r){var i,o,a,s=e.nodeType;if(e&&3!==s&&8!==s&&2!==s)return a=1!==s||!st.isXMLDoc(e),a&&(n=st.propFix[n]||n,o=st.propHooks[n]),r!==t?o&&"set"in o&&(i=o.set(e,r,n))!==t?i:e[n]=r:o&&"get"in o&&null!==(i=o.get(e,n))?i:e[n]},propHooks:{tabIndex:{get:function(e){var n=e.getAttributeNode("tabindex");return n&&n.specified?parseInt(n.value,10):At.test(e.nodeName)||jt.test(e.nodeName)&&e.href?0:t}}}}),kt={get:function(e,n){var r=st.prop(e,n),i="boolean"==typeof r&&e.getAttribute(n),o="boolean"==typeof r?Mt&&Ht?null!=i:Lt.test(n)?e[st.camelCase("default-"+n)]:!!i:e.getAttributeNode(n);return o&&o.value!==!1?n.toLowerCase():t},set:function(e,t,n){return t===!1?st.removeAttr(e,n):Mt&&Ht||!Lt.test(n)?e.setAttribute(!Ht&&st.propFix[n]||n,n):e[st.camelCase("default-"+n)]=e[n]=!0,n}},Mt&&Ht||(st.attrHooks.value={get:function(e,n){var r=e.getAttributeNode(n);return st.nodeName(e,"input")?e.defaultValue:r&&r.specified?r.value:t
},set:function(e,n,r){return st.nodeName(e,"input")?(e.defaultValue=n,t):Ct&&Ct.set(e,n,r)}}),Ht||(Ct=st.valHooks.button={get:function(e,n){var r=e.getAttributeNode(n);return r&&("id"===n||"name"===n||"coords"===n?""!==r.value:r.specified)?r.value:t},set:function(e,n,r){var i=e.getAttributeNode(r);return i||e.setAttributeNode(i=e.ownerDocument.createAttribute(r)),i.value=n+="","value"===r||n===e.getAttribute(r)?n:t}},st.attrHooks.contenteditable={get:Ct.get,set:function(e,t,n){Ct.set(e,""===t?!1:t,n)}},st.each(["width","height"],function(e,n){st.attrHooks[n]=st.extend(st.attrHooks[n],{set:function(e,r){return""===r?(e.setAttribute(n,"auto"),r):t}})})),st.support.hrefNormalized||(st.each(["href","src","width","height"],function(e,n){st.attrHooks[n]=st.extend(st.attrHooks[n],{get:function(e){var r=e.getAttribute(n,2);return null==r?t:r}})}),st.each(["href","src"],function(e,t){st.propHooks[t]={get:function(e){return e.getAttribute(t,4)}}})),st.support.style||(st.attrHooks.style={get:function(e){return e.style.cssText||t},set:function(e,t){return e.style.cssText=t+""}}),st.support.optSelected||(st.propHooks.selected=st.extend(st.propHooks.selected,{get:function(e){var t=e.parentNode;return t&&(t.selectedIndex,t.parentNode&&t.parentNode.selectedIndex),null}})),st.support.enctype||(st.propFix.enctype="encoding"),st.support.checkOn||st.each(["radio","checkbox"],function(){st.valHooks[this]={get:function(e){return null===e.getAttribute("value")?"on":e.value}}}),st.each(["radio","checkbox"],function(){st.valHooks[this]=st.extend(st.valHooks[this],{set:function(e,n){return st.isArray(n)?e.checked=st.inArray(st(e).val(),n)>=0:t}})});var qt=/^(?:input|select|textarea)$/i,_t=/^key/,Ft=/^(?:mouse|contextmenu)|click/,Ot=/^(?:focusinfocus|focusoutblur)$/,Bt=/^([^.]*)(?:\.(.+)|)$/;st.event={global:{},add:function(e,n,r,i,o){var a,s,u,l,c,f,p,d,h,g,m,y=3!==e.nodeType&&8!==e.nodeType&&st._data(e);if(y){for(r.handler&&(a=r,r=a.handler,o=a.selector),r.guid||(r.guid=st.guid++),(l=y.events)||(l=y.events={}),(s=y.handle)||(s=y.handle=function(e){return st===t||e&&st.event.triggered===e.type?t:st.event.dispatch.apply(s.elem,arguments)},s.elem=e),n=(n||"").match(lt)||[""],c=n.length;c--;)u=Bt.exec(n[c])||[],h=m=u[1],g=(u[2]||"").split(".").sort(),p=st.event.special[h]||{},h=(o?p.delegateType:p.bindType)||h,p=st.event.special[h]||{},f=st.extend({type:h,origType:m,data:i,handler:r,guid:r.guid,selector:o,needsContext:o&&st.expr.match.needsContext.test(o),namespace:g.join(".")},a),(d=l[h])||(d=l[h]=[],d.delegateCount=0,p.setup&&p.setup.call(e,i,g,s)!==!1||(e.addEventListener?e.addEventListener(h,s,!1):e.attachEvent&&e.attachEvent("on"+h,s))),p.add&&(p.add.call(e,f),f.handler.guid||(f.handler.guid=r.guid)),o?d.splice(d.delegateCount++,0,f):d.push(f),st.event.global[h]=!0;e=null}},remove:function(e,t,n,r,i){var o,a,s,u,l,c,f,p,d,h,g,m=st.hasData(e)&&st._data(e);if(m&&(u=m.events)){for(t=(t||"").match(lt)||[""],l=t.length;l--;)if(s=Bt.exec(t[l])||[],d=g=s[1],h=(s[2]||"").split(".").sort(),d){for(f=st.event.special[d]||{},d=(r?f.delegateType:f.bindType)||d,p=u[d]||[],s=s[2]&&RegExp("(^|\\.)"+h.join("\\.(?:.*\\.|)")+"(\\.|$)"),a=o=p.length;o--;)c=p[o],!i&&g!==c.origType||n&&n.guid!==c.guid||s&&!s.test(c.namespace)||r&&r!==c.selector&&("**"!==r||!c.selector)||(p.splice(o,1),c.selector&&p.delegateCount--,f.remove&&f.remove.call(e,c));a&&!p.length&&(f.teardown&&f.teardown.call(e,h,m.handle)!==!1||st.removeEvent(e,d,m.handle),delete u[d])}else for(d in u)st.event.remove(e,d+t[l],n,r,!0);st.isEmptyObject(u)&&(delete m.handle,st._removeData(e,"events"))}},trigger:function(n,r,i,o){var a,s,u,l,c,f,p,d=[i||V],h=n.type||n,g=n.namespace?n.namespace.split("."):[];if(s=u=i=i||V,3!==i.nodeType&&8!==i.nodeType&&!Ot.test(h+st.event.triggered)&&(h.indexOf(".")>=0&&(g=h.split("."),h=g.shift(),g.sort()),c=0>h.indexOf(":")&&"on"+h,n=n[st.expando]?n:new st.Event(h,"object"==typeof n&&n),n.isTrigger=!0,n.namespace=g.join("."),n.namespace_re=n.namespace?RegExp("(^|\\.)"+g.join("\\.(?:.*\\.|)")+"(\\.|$)"):null,n.result=t,n.target||(n.target=i),r=null==r?[n]:st.makeArray(r,[n]),p=st.event.special[h]||{},o||!p.trigger||p.trigger.apply(i,r)!==!1)){if(!o&&!p.noBubble&&!st.isWindow(i)){for(l=p.delegateType||h,Ot.test(l+h)||(s=s.parentNode);s;s=s.parentNode)d.push(s),u=s;u===(i.ownerDocument||V)&&d.push(u.defaultView||u.parentWindow||e)}for(a=0;(s=d[a++])&&!n.isPropagationStopped();)n.type=a>1?l:p.bindType||h,f=(st._data(s,"events")||{})[n.type]&&st._data(s,"handle"),f&&f.apply(s,r),f=c&&s[c],f&&st.acceptData(s)&&f.apply&&f.apply(s,r)===!1&&n.preventDefault();if(n.type=h,!(o||n.isDefaultPrevented()||p._default&&p._default.apply(i.ownerDocument,r)!==!1||"click"===h&&st.nodeName(i,"a")||!st.acceptData(i)||!c||!i[h]||st.isWindow(i))){u=i[c],u&&(i[c]=null),st.event.triggered=h;try{i[h]()}catch(m){}st.event.triggered=t,u&&(i[c]=u)}return n.result}},dispatch:function(e){e=st.event.fix(e);var n,r,i,o,a,s=[],u=nt.call(arguments),l=(st._data(this,"events")||{})[e.type]||[],c=st.event.special[e.type]||{};if(u[0]=e,e.delegateTarget=this,!c.preDispatch||c.preDispatch.call(this,e)!==!1){for(s=st.event.handlers.call(this,e,l),n=0;(o=s[n++])&&!e.isPropagationStopped();)for(e.currentTarget=o.elem,r=0;(a=o.handlers[r++])&&!e.isImmediatePropagationStopped();)(!e.namespace_re||e.namespace_re.test(a.namespace))&&(e.handleObj=a,e.data=a.data,i=((st.event.special[a.origType]||{}).handle||a.handler).apply(o.elem,u),i!==t&&(e.result=i)===!1&&(e.preventDefault(),e.stopPropagation()));return c.postDispatch&&c.postDispatch.call(this,e),e.result}},handlers:function(e,n){var r,i,o,a,s=[],u=n.delegateCount,l=e.target;if(u&&l.nodeType&&(!e.button||"click"!==e.type))for(;l!=this;l=l.parentNode||this)if(l.disabled!==!0||"click"!==e.type){for(i=[],r=0;u>r;r++)a=n[r],o=a.selector+" ",i[o]===t&&(i[o]=a.needsContext?st(o,this).index(l)>=0:st.find(o,this,null,[l]).length),i[o]&&i.push(a);i.length&&s.push({elem:l,handlers:i})}return n.length>u&&s.push({elem:this,handlers:n.slice(u)}),s},fix:function(e){if(e[st.expando])return e;var t,n,r=e,i=st.event.fixHooks[e.type]||{},o=i.props?this.props.concat(i.props):this.props;for(e=new st.Event(r),t=o.length;t--;)n=o[t],e[n]=r[n];return e.target||(e.target=r.srcElement||V),3===e.target.nodeType&&(e.target=e.target.parentNode),e.metaKey=!!e.metaKey,i.filter?i.filter(e,r):e},props:"altKey bubbles cancelable ctrlKey currentTarget eventPhase metaKey relatedTarget shiftKey target timeStamp view which".split(" "),fixHooks:{},keyHooks:{props:"char charCode key keyCode".split(" "),filter:function(e,t){return null==e.which&&(e.which=null!=t.charCode?t.charCode:t.keyCode),e}},mouseHooks:{props:"button buttons clientX clientY fromElement offsetX offsetY pageX pageY screenX screenY toElement".split(" "),filter:function(e,n){var r,i,o,a=n.button,s=n.fromElement;return null==e.pageX&&null!=n.clientX&&(r=e.target.ownerDocument||V,i=r.documentElement,o=r.body,e.pageX=n.clientX+(i&&i.scrollLeft||o&&o.scrollLeft||0)-(i&&i.clientLeft||o&&o.clientLeft||0),e.pageY=n.clientY+(i&&i.scrollTop||o&&o.scrollTop||0)-(i&&i.clientTop||o&&o.clientTop||0)),!e.relatedTarget&&s&&(e.relatedTarget=s===e.target?n.toElement:s),e.which||a===t||(e.which=1&a?1:2&a?3:4&a?2:0),e}},special:{load:{noBubble:!0},click:{trigger:function(){return st.nodeName(this,"input")&&"checkbox"===this.type&&this.click?(this.click(),!1):t}},focus:{trigger:function(){if(this!==V.activeElement&&this.focus)try{return this.focus(),!1}catch(e){}},delegateType:"focusin"},blur:{trigger:function(){return this===V.activeElement&&this.blur?(this.blur(),!1):t},delegateType:"focusout"},beforeunload:{postDispatch:function(e){e.result!==t&&(e.originalEvent.returnValue=e.result)}}},simulate:function(e,t,n,r){var i=st.extend(new st.Event,n,{type:e,isSimulated:!0,originalEvent:{}});r?st.event.trigger(i,null,t):st.event.dispatch.call(t,i),i.isDefaultPrevented()&&n.preventDefault()}},st.removeEvent=V.removeEventListener?function(e,t,n){e.removeEventListener&&e.removeEventListener(t,n,!1)}:function(e,n,r){var i="on"+n;e.detachEvent&&(e[i]===t&&(e[i]=null),e.detachEvent(i,r))},st.Event=function(e,n){return this instanceof st.Event?(e&&e.type?(this.originalEvent=e,this.type=e.type,this.isDefaultPrevented=e.defaultPrevented||e.returnValue===!1||e.getPreventDefault&&e.getPreventDefault()?u:l):this.type=e,n&&st.extend(this,n),this.timeStamp=e&&e.timeStamp||st.now(),this[st.expando]=!0,t):new st.Event(e,n)},st.Event.prototype={isDefaultPrevented:l,isPropagationStopped:l,isImmediatePropagationStopped:l,preventDefault:function(){var e=this.originalEvent;this.isDefaultPrevented=u,e&&(e.preventDefault?e.preventDefault():e.returnValue=!1)},stopPropagation:function(){var e=this.originalEvent;this.isPropagationStopped=u,e&&(e.stopPropagation&&e.stopPropagation(),e.cancelBubble=!0)},stopImmediatePropagation:function(){this.isImmediatePropagationStopped=u,this.stopPropagation()}},st.each({mouseenter:"mouseover",mouseleave:"mouseout"},function(e,t){st.event.special[e]={delegateType:t,bindType:t,handle:function(e){var n,r=this,i=e.relatedTarget,o=e.handleObj;return(!i||i!==r&&!st.contains(r,i))&&(e.type=o.origType,n=o.handler.apply(this,arguments),e.type=t),n}}}),st.support.submitBubbles||(st.event.special.submit={setup:function(){return st.nodeName(this,"form")?!1:(st.event.add(this,"click._submit keypress._submit",function(e){var n=e.target,r=st.nodeName(n,"input")||st.nodeName(n,"button")?n.form:t;r&&!st._data(r,"submitBubbles")&&(st.event.add(r,"submit._submit",function(e){e._submit_bubble=!0}),st._data(r,"submitBubbles",!0))}),t)},postDispatch:function(e){e._submit_bubble&&(delete e._submit_bubble,this.parentNode&&!e.isTrigger&&st.event.simulate("submit",this.parentNode,e,!0))},teardown:function(){return st.nodeName(this,"form")?!1:(st.event.remove(this,"._submit"),t)}}),st.support.changeBubbles||(st.event.special.change={setup:function(){return qt.test(this.nodeName)?(("checkbox"===this.type||"radio"===this.type)&&(st.event.add(this,"propertychange._change",function(e){"checked"===e.originalEvent.propertyName&&(this._just_changed=!0)}),st.event.add(this,"click._change",function(e){this._just_changed&&!e.isTrigger&&(this._just_changed=!1),st.event.simulate("change",this,e,!0)})),!1):(st.event.add(this,"beforeactivate._change",function(e){var t=e.target;qt.test(t.nodeName)&&!st._data(t,"changeBubbles")&&(st.event.add(t,"change._change",function(e){!this.parentNode||e.isSimulated||e.isTrigger||st.event.simulate("change",this.parentNode,e,!0)}),st._data(t,"changeBubbles",!0))}),t)},handle:function(e){var n=e.target;return this!==n||e.isSimulated||e.isTrigger||"radio"!==n.type&&"checkbox"!==n.type?e.handleObj.handler.apply(this,arguments):t},teardown:function(){return st.event.remove(this,"._change"),!qt.test(this.nodeName)}}),st.support.focusinBubbles||st.each({focus:"focusin",blur:"focusout"},function(e,t){var n=0,r=function(e){st.event.simulate(t,e.target,st.event.fix(e),!0)};st.event.special[t]={setup:function(){0===n++&&V.addEventListener(e,r,!0)},teardown:function(){0===--n&&V.removeEventListener(e,r,!0)}}}),st.fn.extend({on:function(e,n,r,i,o){var a,s;if("object"==typeof e){"string"!=typeof n&&(r=r||n,n=t);for(s in e)this.on(s,n,r,e[s],o);return this}if(null==r&&null==i?(i=n,r=n=t):null==i&&("string"==typeof n?(i=r,r=t):(i=r,r=n,n=t)),i===!1)i=l;else if(!i)return this;return 1===o&&(a=i,i=function(e){return st().off(e),a.apply(this,arguments)},i.guid=a.guid||(a.guid=st.guid++)),this.each(function(){st.event.add(this,e,i,r,n)})},one:function(e,t,n,r){return this.on(e,t,n,r,1)},off:function(e,n,r){var i,o;if(e&&e.preventDefault&&e.handleObj)return i=e.handleObj,st(e.delegateTarget).off(i.namespace?i.origType+"."+i.namespace:i.origType,i.selector,i.handler),this;if("object"==typeof e){for(o in e)this.off(o,n,e[o]);return this}return(n===!1||"function"==typeof n)&&(r=n,n=t),r===!1&&(r=l),this.each(function(){st.event.remove(this,e,r,n)})},bind:function(e,t,n){return this.on(e,null,t,n)},unbind:function(e,t){return this.off(e,null,t)},delegate:function(e,t,n,r){return this.on(t,e,n,r)},undelegate:function(e,t,n){return 1===arguments.length?this.off(e,"**"):this.off(t,e||"**",n)},trigger:function(e,t){return this.each(function(){st.event.trigger(e,t,this)})},triggerHandler:function(e,n){var r=this[0];return r?st.event.trigger(e,n,r,!0):t},hover:function(e,t){return this.mouseenter(e).mouseleave(t||e)}}),st.each("blur focus focusin focusout load resize scroll unload click dblclick mousedown mouseup mousemove mouseover mouseout mouseenter mouseleave change select submit keydown keypress keyup error contextmenu".split(" "),function(e,t){st.fn[t]=function(e,n){return arguments.length>0?this.on(t,null,e,n):this.trigger(t)},_t.test(t)&&(st.event.fixHooks[t]=st.event.keyHooks),Ft.test(t)&&(st.event.fixHooks[t]=st.event.mouseHooks)}),function(e,t){function n(e){return ht.test(e+"")}function r(){var e,t=[];return e=function(n,r){return t.push(n+=" ")>C.cacheLength&&delete e[t.shift()],e[n]=r}}function i(e){return e[P]=!0,e}function o(e){var t=L.createElement("div");try{return e(t)}catch(n){return!1}finally{t=null}}function a(e,t,n,r){var i,o,a,s,u,l,c,d,h,g;if((t?t.ownerDocument||t:R)!==L&&D(t),t=t||L,n=n||[],!e||"string"!=typeof e)return n;if(1!==(s=t.nodeType)&&9!==s)return[];if(!M&&!r){if(i=gt.exec(e))if(a=i[1]){if(9===s){if(o=t.getElementById(a),!o||!o.parentNode)return n;if(o.id===a)return n.push(o),n}else if(t.ownerDocument&&(o=t.ownerDocument.getElementById(a))&&O(t,o)&&o.id===a)return n.push(o),n}else{if(i[2])return Q.apply(n,K.call(t.getElementsByTagName(e),0)),n;if((a=i[3])&&W.getByClassName&&t.getElementsByClassName)return Q.apply(n,K.call(t.getElementsByClassName(a),0)),n}if(W.qsa&&!q.test(e)){if(c=!0,d=P,h=t,g=9===s&&e,1===s&&"object"!==t.nodeName.toLowerCase()){for(l=f(e),(c=t.getAttribute("id"))?d=c.replace(vt,"\\$&"):t.setAttribute("id",d),d="[id='"+d+"'] ",u=l.length;u--;)l[u]=d+p(l[u]);h=dt.test(e)&&t.parentNode||t,g=l.join(",")}if(g)try{return Q.apply(n,K.call(h.querySelectorAll(g),0)),n}catch(m){}finally{c||t.removeAttribute("id")}}}return x(e.replace(at,"$1"),t,n,r)}function s(e,t){for(var n=e&&t&&e.nextSibling;n;n=n.nextSibling)if(n===t)return-1;return e?1:-1}function u(e){return function(t){var n=t.nodeName.toLowerCase();return"input"===n&&t.type===e}}function l(e){return function(t){var n=t.nodeName.toLowerCase();return("input"===n||"button"===n)&&t.type===e}}function c(e){return i(function(t){return t=+t,i(function(n,r){for(var i,o=e([],n.length,t),a=o.length;a--;)n[i=o[a]]&&(n[i]=!(r[i]=n[i]))})})}function f(e,t){var n,r,i,o,s,u,l,c=X[e+" "];if(c)return t?0:c.slice(0);for(s=e,u=[],l=C.preFilter;s;){(!n||(r=ut.exec(s)))&&(r&&(s=s.slice(r[0].length)||s),u.push(i=[])),n=!1,(r=lt.exec(s))&&(n=r.shift(),i.push({value:n,type:r[0].replace(at," ")}),s=s.slice(n.length));for(o in C.filter)!(r=pt[o].exec(s))||l[o]&&!(r=l[o](r))||(n=r.shift(),i.push({value:n,type:o,matches:r}),s=s.slice(n.length));if(!n)break}return t?s.length:s?a.error(e):X(e,u).slice(0)}function p(e){for(var t=0,n=e.length,r="";n>t;t++)r+=e[t].value;return r}function d(e,t,n){var r=t.dir,i=n&&"parentNode"===t.dir,o=I++;return t.first?function(t,n,o){for(;t=t[r];)if(1===t.nodeType||i)return e(t,n,o)}:function(t,n,a){var s,u,l,c=$+" "+o;if(a){for(;t=t[r];)if((1===t.nodeType||i)&&e(t,n,a))return!0}else for(;t=t[r];)if(1===t.nodeType||i)if(l=t[P]||(t[P]={}),(u=l[r])&&u[0]===c){if((s=u[1])===!0||s===N)return s===!0}else if(u=l[r]=[c],u[1]=e(t,n,a)||N,u[1]===!0)return!0}}function h(e){return e.length>1?function(t,n,r){for(var i=e.length;i--;)if(!e[i](t,n,r))return!1;return!0}:e[0]}function g(e,t,n,r,i){for(var o,a=[],s=0,u=e.length,l=null!=t;u>s;s++)(o=e[s])&&(!n||n(o,r,i))&&(a.push(o),l&&t.push(s));return a}function m(e,t,n,r,o,a){return r&&!r[P]&&(r=m(r)),o&&!o[P]&&(o=m(o,a)),i(function(i,a,s,u){var l,c,f,p=[],d=[],h=a.length,m=i||b(t||"*",s.nodeType?[s]:s,[]),y=!e||!i&&t?m:g(m,p,e,s,u),v=n?o||(i?e:h||r)?[]:a:y;if(n&&n(y,v,s,u),r)for(l=g(v,d),r(l,[],s,u),c=l.length;c--;)(f=l[c])&&(v[d[c]]=!(y[d[c]]=f));if(i){if(o||e){if(o){for(l=[],c=v.length;c--;)(f=v[c])&&l.push(y[c]=f);o(null,v=[],l,u)}for(c=v.length;c--;)(f=v[c])&&(l=o?Z.call(i,f):p[c])>-1&&(i[l]=!(a[l]=f))}}else v=g(v===a?v.splice(h,v.length):v),o?o(null,a,v,u):Q.apply(a,v)})}function y(e){for(var t,n,r,i=e.length,o=C.relative[e[0].type],a=o||C.relative[" "],s=o?1:0,u=d(function(e){return e===t},a,!0),l=d(function(e){return Z.call(t,e)>-1},a,!0),c=[function(e,n,r){return!o&&(r||n!==j)||((t=n).nodeType?u(e,n,r):l(e,n,r))}];i>s;s++)if(n=C.relative[e[s].type])c=[d(h(c),n)];else{if(n=C.filter[e[s].type].apply(null,e[s].matches),n[P]){for(r=++s;i>r&&!C.relative[e[r].type];r++);return m(s>1&&h(c),s>1&&p(e.slice(0,s-1)).replace(at,"$1"),n,r>s&&y(e.slice(s,r)),i>r&&y(e=e.slice(r)),i>r&&p(e))}c.push(n)}return h(c)}function v(e,t){var n=0,r=t.length>0,o=e.length>0,s=function(i,s,u,l,c){var f,p,d,h=[],m=0,y="0",v=i&&[],b=null!=c,x=j,T=i||o&&C.find.TAG("*",c&&s.parentNode||s),w=$+=null==x?1:Math.E;for(b&&(j=s!==L&&s,N=n);null!=(f=T[y]);y++){if(o&&f){for(p=0;d=e[p];p++)if(d(f,s,u)){l.push(f);break}b&&($=w,N=++n)}r&&((f=!d&&f)&&m--,i&&v.push(f))}if(m+=y,r&&y!==m){for(p=0;d=t[p];p++)d(v,h,s,u);if(i){if(m>0)for(;y--;)v[y]||h[y]||(h[y]=G.call(l));h=g(h)}Q.apply(l,h),b&&!i&&h.length>0&&m+t.length>1&&a.uniqueSort(l)}return b&&($=w,j=x),v};return r?i(s):s}function b(e,t,n){for(var r=0,i=t.length;i>r;r++)a(e,t[r],n);return n}function x(e,t,n,r){var i,o,a,s,u,l=f(e);if(!r&&1===l.length){if(o=l[0]=l[0].slice(0),o.length>2&&"ID"===(a=o[0]).type&&9===t.nodeType&&!M&&C.relative[o[1].type]){if(t=C.find.ID(a.matches[0].replace(xt,Tt),t)[0],!t)return n;e=e.slice(o.shift().value.length)}for(i=pt.needsContext.test(e)?-1:o.length-1;i>=0&&(a=o[i],!C.relative[s=a.type]);i--)if((u=C.find[s])&&(r=u(a.matches[0].replace(xt,Tt),dt.test(o[0].type)&&t.parentNode||t))){if(o.splice(i,1),e=r.length&&p(o),!e)return Q.apply(n,K.call(r,0)),n;break}}return S(e,l)(r,t,M,n,dt.test(e)),n}function T(){}var w,N,C,k,E,S,A,j,D,L,H,M,q,_,F,O,B,P="sizzle"+-new Date,R=e.document,W={},$=0,I=0,z=r(),X=r(),U=r(),V=typeof t,Y=1<<31,J=[],G=J.pop,Q=J.push,K=J.slice,Z=J.indexOf||function(e){for(var t=0,n=this.length;n>t;t++)if(this[t]===e)return t;return-1},et="[\\x20\\t\\r\\n\\f]",tt="(?:\\\\.|[\\w-]|[^\\x00-\\xa0])+",nt=tt.replace("w","w#"),rt="([*^$|!~]?=)",it="\\["+et+"*("+tt+")"+et+"*(?:"+rt+et+"*(?:(['\"])((?:\\\\.|[^\\\\])*?)\\3|("+nt+")|)|)"+et+"*\\]",ot=":("+tt+")(?:\\(((['\"])((?:\\\\.|[^\\\\])*?)\\3|((?:\\\\.|[^\\\\()[\\]]|"+it.replace(3,8)+")*)|.*)\\)|)",at=RegExp("^"+et+"+|((?:^|[^\\\\])(?:\\\\.)*)"+et+"+$","g"),ut=RegExp("^"+et+"*,"+et+"*"),lt=RegExp("^"+et+"*([\\x20\\t\\r\\n\\f>+~])"+et+"*"),ct=RegExp(ot),ft=RegExp("^"+nt+"$"),pt={ID:RegExp("^#("+tt+")"),CLASS:RegExp("^\\.("+tt+")"),NAME:RegExp("^\\[name=['\"]?("+tt+")['\"]?\\]"),TAG:RegExp("^("+tt.replace("w","w*")+")"),ATTR:RegExp("^"+it),PSEUDO:RegExp("^"+ot),CHILD:RegExp("^:(only|first|last|nth|nth-last)-(child|of-type)(?:\\("+et+"*(even|odd|(([+-]|)(\\d*)n|)"+et+"*(?:([+-]|)"+et+"*(\\d+)|))"+et+"*\\)|)","i"),needsContext:RegExp("^"+et+"*[>+~]|:(even|odd|eq|gt|lt|nth|first|last)(?:\\("+et+"*((?:-\\d)?\\d*)"+et+"*\\)|)(?=[^-]|$)","i")},dt=/[\x20\t\r\n\f]*[+~]/,ht=/\{\s*\[native code\]\s*\}/,gt=/^(?:#([\w-]+)|(\w+)|\.([\w-]+))$/,mt=/^(?:input|select|textarea|button)$/i,yt=/^h\d$/i,vt=/'|\\/g,bt=/\=[\x20\t\r\n\f]*([^'"\]]*)[\x20\t\r\n\f]*\]/g,xt=/\\([\da-fA-F]{1,6}[\x20\t\r\n\f]?|.)/g,Tt=function(e,t){var n="0x"+t-65536;return n!==n?t:0>n?String.fromCharCode(n+65536):String.fromCharCode(55296|n>>10,56320|1023&n)};try{K.call(H.childNodes,0)[0].nodeType}catch(wt){K=function(e){for(var t,n=[];t=this[e];e++)n.push(t);return n}}E=a.isXML=function(e){var t=e&&(e.ownerDocument||e).documentElement;return t?"HTML"!==t.nodeName:!1},D=a.setDocument=function(e){var r=e?e.ownerDocument||e:R;return r!==L&&9===r.nodeType&&r.documentElement?(L=r,H=r.documentElement,M=E(r),W.tagNameNoComments=o(function(e){return e.appendChild(r.createComment("")),!e.getElementsByTagName("*").length}),W.attributes=o(function(e){e.innerHTML="<select></select>";var t=typeof e.lastChild.getAttribute("multiple");return"boolean"!==t&&"string"!==t}),W.getByClassName=o(function(e){return e.innerHTML="<div class='hidden e'></div><div class='hidden'></div>",e.getElementsByClassName&&e.getElementsByClassName("e").length?(e.lastChild.className="e",2===e.getElementsByClassName("e").length):!1}),W.getByName=o(function(e){e.id=P+0,e.innerHTML="<a name='"+P+"'></a><div name='"+P+"'></div>",H.insertBefore(e,H.firstChild);var t=r.getElementsByName&&r.getElementsByName(P).length===2+r.getElementsByName(P+0).length;return W.getIdNotName=!r.getElementById(P),H.removeChild(e),t}),C.attrHandle=o(function(e){return e.innerHTML="<a href='#'></a>",e.firstChild&&typeof e.firstChild.getAttribute!==V&&"#"===e.firstChild.getAttribute("href")})?{}:{href:function(e){return e.getAttribute("href",2)},type:function(e){return e.getAttribute("type")}},W.getIdNotName?(C.find.ID=function(e,t){if(typeof t.getElementById!==V&&!M){var n=t.getElementById(e);return n&&n.parentNode?[n]:[]}},C.filter.ID=function(e){var t=e.replace(xt,Tt);return function(e){return e.getAttribute("id")===t}}):(C.find.ID=function(e,n){if(typeof n.getElementById!==V&&!M){var r=n.getElementById(e);return r?r.id===e||typeof r.getAttributeNode!==V&&r.getAttributeNode("id").value===e?[r]:t:[]}},C.filter.ID=function(e){var t=e.replace(xt,Tt);return function(e){var n=typeof e.getAttributeNode!==V&&e.getAttributeNode("id");return n&&n.value===t}}),C.find.TAG=W.tagNameNoComments?function(e,n){return typeof n.getElementsByTagName!==V?n.getElementsByTagName(e):t}:function(e,t){var n,r=[],i=0,o=t.getElementsByTagName(e);if("*"===e){for(;n=o[i];i++)1===n.nodeType&&r.push(n);return r}return o},C.find.NAME=W.getByName&&function(e,n){return typeof n.getElementsByName!==V?n.getElementsByName(name):t},C.find.CLASS=W.getByClassName&&function(e,n){return typeof n.getElementsByClassName===V||M?t:n.getElementsByClassName(e)},_=[],q=[":focus"],(W.qsa=n(r.querySelectorAll))&&(o(function(e){e.innerHTML="<select><option selected=''></option></select>",e.querySelectorAll("[selected]").length||q.push("\\["+et+"*(?:checked|disabled|ismap|multiple|readonly|selected|value)"),e.querySelectorAll(":checked").length||q.push(":checked")}),o(function(e){e.innerHTML="<input type='hidden' i=''/>",e.querySelectorAll("[i^='']").length&&q.push("[*^$]="+et+"*(?:\"\"|'')"),e.querySelectorAll(":enabled").length||q.push(":enabled",":disabled"),e.querySelectorAll("*,:x"),q.push(",.*:")})),(W.matchesSelector=n(F=H.matchesSelector||H.mozMatchesSelector||H.webkitMatchesSelector||H.oMatchesSelector||H.msMatchesSelector))&&o(function(e){W.disconnectedMatch=F.call(e,"div"),F.call(e,"[s!='']:x"),_.push("!=",ot)}),q=RegExp(q.join("|")),_=RegExp(_.join("|")),O=n(H.contains)||H.compareDocumentPosition?function(e,t){var n=9===e.nodeType?e.documentElement:e,r=t&&t.parentNode;return e===r||!(!r||1!==r.nodeType||!(n.contains?n.contains(r):e.compareDocumentPosition&&16&e.compareDocumentPosition(r)))}:function(e,t){if(t)for(;t=t.parentNode;)if(t===e)return!0;return!1},B=H.compareDocumentPosition?function(e,t){var n;return e===t?(A=!0,0):(n=t.compareDocumentPosition&&e.compareDocumentPosition&&e.compareDocumentPosition(t))?1&n||e.parentNode&&11===e.parentNode.nodeType?e===r||O(R,e)?-1:t===r||O(R,t)?1:0:4&n?-1:1:e.compareDocumentPosition?-1:1}:function(e,t){var n,i=0,o=e.parentNode,a=t.parentNode,u=[e],l=[t];if(e===t)return A=!0,0;if(e.sourceIndex&&t.sourceIndex)return(~t.sourceIndex||Y)-(O(R,e)&&~e.sourceIndex||Y);if(!o||!a)return e===r?-1:t===r?1:o?-1:a?1:0;if(o===a)return s(e,t);for(n=e;n=n.parentNode;)u.unshift(n);for(n=t;n=n.parentNode;)l.unshift(n);for(;u[i]===l[i];)i++;return i?s(u[i],l[i]):u[i]===R?-1:l[i]===R?1:0},A=!1,[0,0].sort(B),W.detectDuplicates=A,L):L},a.matches=function(e,t){return a(e,null,null,t)},a.matchesSelector=function(e,t){if((e.ownerDocument||e)!==L&&D(e),t=t.replace(bt,"='$1']"),!(!W.matchesSelector||M||_&&_.test(t)||q.test(t)))try{var n=F.call(e,t);if(n||W.disconnectedMatch||e.document&&11!==e.document.nodeType)return n}catch(r){}return a(t,L,null,[e]).length>0},a.contains=function(e,t){return(e.ownerDocument||e)!==L&&D(e),O(e,t)},a.attr=function(e,t){var n;return(e.ownerDocument||e)!==L&&D(e),M||(t=t.toLowerCase()),(n=C.attrHandle[t])?n(e):M||W.attributes?e.getAttribute(t):((n=e.getAttributeNode(t))||e.getAttribute(t))&&e[t]===!0?t:n&&n.specified?n.value:null},a.error=function(e){throw Error("Syntax error, unrecognized expression: "+e)},a.uniqueSort=function(e){var t,n=[],r=1,i=0;if(A=!W.detectDuplicates,e.sort(B),A){for(;t=e[r];r++)t===e[r-1]&&(i=n.push(r));for(;i--;)e.splice(n[i],1)}return e},k=a.getText=function(e){var t,n="",r=0,i=e.nodeType;if(i){if(1===i||9===i||11===i){if("string"==typeof e.textContent)return e.textContent;for(e=e.firstChild;e;e=e.nextSibling)n+=k(e)}else if(3===i||4===i)return e.nodeValue}else for(;t=e[r];r++)n+=k(t);return n},C=a.selectors={cacheLength:50,createPseudo:i,match:pt,find:{},relative:{">":{dir:"parentNode",first:!0}," ":{dir:"parentNode"},"+":{dir:"previousSibling",first:!0},"~":{dir:"previousSibling"}},preFilter:{ATTR:function(e){return e[1]=e[1].replace(xt,Tt),e[3]=(e[4]||e[5]||"").replace(xt,Tt),"~="===e[2]&&(e[3]=" "+e[3]+" "),e.slice(0,4)},CHILD:function(e){return e[1]=e[1].toLowerCase(),"nth"===e[1].slice(0,3)?(e[3]||a.error(e[0]),e[4]=+(e[4]?e[5]+(e[6]||1):2*("even"===e[3]||"odd"===e[3])),e[5]=+(e[7]+e[8]||"odd"===e[3])):e[3]&&a.error(e[0]),e},PSEUDO:function(e){var t,n=!e[5]&&e[2];return pt.CHILD.test(e[0])?null:(e[4]?e[2]=e[4]:n&&ct.test(n)&&(t=f(n,!0))&&(t=n.indexOf(")",n.length-t)-n.length)&&(e[0]=e[0].slice(0,t),e[2]=n.slice(0,t)),e.slice(0,3))}},filter:{TAG:function(e){return"*"===e?function(){return!0}:(e=e.replace(xt,Tt).toLowerCase(),function(t){return t.nodeName&&t.nodeName.toLowerCase()===e})},CLASS:function(e){var t=z[e+" "];return t||(t=RegExp("(^|"+et+")"+e+"("+et+"|$)"))&&z(e,function(e){return t.test(e.className||typeof e.getAttribute!==V&&e.getAttribute("class")||"")})},ATTR:function(e,t,n){return function(r){var i=a.attr(r,e);return null==i?"!="===t:t?(i+="","="===t?i===n:"!="===t?i!==n:"^="===t?n&&0===i.indexOf(n):"*="===t?n&&i.indexOf(n)>-1:"$="===t?n&&i.substr(i.length-n.length)===n:"~="===t?(" "+i+" ").indexOf(n)>-1:"|="===t?i===n||i.substr(0,n.length+1)===n+"-":!1):!0}},CHILD:function(e,t,n,r,i){var o="nth"!==e.slice(0,3),a="last"!==e.slice(-4),s="of-type"===t;return 1===r&&0===i?function(e){return!!e.parentNode}:function(t,n,u){var l,c,f,p,d,h,g=o!==a?"nextSibling":"previousSibling",m=t.parentNode,y=s&&t.nodeName.toLowerCase(),v=!u&&!s;if(m){if(o){for(;g;){for(f=t;f=f[g];)if(s?f.nodeName.toLowerCase()===y:1===f.nodeType)return!1;h=g="only"===e&&!h&&"nextSibling"}return!0}if(h=[a?m.firstChild:m.lastChild],a&&v){for(c=m[P]||(m[P]={}),l=c[e]||[],d=l[0]===$&&l[1],p=l[0]===$&&l[2],f=d&&m.childNodes[d];f=++d&&f&&f[g]||(p=d=0)||h.pop();)if(1===f.nodeType&&++p&&f===t){c[e]=[$,d,p];break}}else if(v&&(l=(t[P]||(t[P]={}))[e])&&l[0]===$)p=l[1];else for(;(f=++d&&f&&f[g]||(p=d=0)||h.pop())&&((s?f.nodeName.toLowerCase()!==y:1!==f.nodeType)||!++p||(v&&((f[P]||(f[P]={}))[e]=[$,p]),f!==t)););return p-=i,p===r||0===p%r&&p/r>=0}}},PSEUDO:function(e,t){var n,r=C.pseudos[e]||C.setFilters[e.toLowerCase()]||a.error("unsupported pseudo: "+e);return r[P]?r(t):r.length>1?(n=[e,e,"",t],C.setFilters.hasOwnProperty(e.toLowerCase())?i(function(e,n){for(var i,o=r(e,t),a=o.length;a--;)i=Z.call(e,o[a]),e[i]=!(n[i]=o[a])}):function(e){return r(e,0,n)}):r}},pseudos:{not:i(function(e){var t=[],n=[],r=S(e.replace(at,"$1"));return r[P]?i(function(e,t,n,i){for(var o,a=r(e,null,i,[]),s=e.length;s--;)(o=a[s])&&(e[s]=!(t[s]=o))}):function(e,i,o){return t[0]=e,r(t,null,o,n),!n.pop()}}),has:i(function(e){return function(t){return a(e,t).length>0}}),contains:i(function(e){return function(t){return(t.textContent||t.innerText||k(t)).indexOf(e)>-1}}),lang:i(function(e){return ft.test(e||"")||a.error("unsupported lang: "+e),e=e.replace(xt,Tt).toLowerCase(),function(t){var n;do if(n=M?t.getAttribute("xml:lang")||t.getAttribute("lang"):t.lang)return n=n.toLowerCase(),n===e||0===n.indexOf(e+"-");while((t=t.parentNode)&&1===t.nodeType);return!1}}),target:function(t){var n=e.location&&e.location.hash;return n&&n.slice(1)===t.id},root:function(e){return e===H},focus:function(e){return e===L.activeElement&&(!L.hasFocus||L.hasFocus())&&!!(e.type||e.href||~e.tabIndex)},enabled:function(e){return e.disabled===!1},disabled:function(e){return e.disabled===!0},checked:function(e){var t=e.nodeName.toLowerCase();return"input"===t&&!!e.checked||"option"===t&&!!e.selected},selected:function(e){return e.parentNode&&e.parentNode.selectedIndex,e.selected===!0},empty:function(e){for(e=e.firstChild;e;e=e.nextSibling)if(e.nodeName>"@"||3===e.nodeType||4===e.nodeType)return!1;return!0},parent:function(e){return!C.pseudos.empty(e)},header:function(e){return yt.test(e.nodeName)},input:function(e){return mt.test(e.nodeName)},button:function(e){var t=e.nodeName.toLowerCase();return"input"===t&&"button"===e.type||"button"===t},text:function(e){var t;return"input"===e.nodeName.toLowerCase()&&"text"===e.type&&(null==(t=e.getAttribute("type"))||t.toLowerCase()===e.type)},first:c(function(){return[0]}),last:c(function(e,t){return[t-1]}),eq:c(function(e,t,n){return[0>n?n+t:n]}),even:c(function(e,t){for(var n=0;t>n;n+=2)e.push(n);return e}),odd:c(function(e,t){for(var n=1;t>n;n+=2)e.push(n);return e}),lt:c(function(e,t,n){for(var r=0>n?n+t:n;--r>=0;)e.push(r);return e}),gt:c(function(e,t,n){for(var r=0>n?n+t:n;t>++r;)e.push(r);return e})}};for(w in{radio:!0,checkbox:!0,file:!0,password:!0,image:!0})C.pseudos[w]=u(w);for(w in{submit:!0,reset:!0})C.pseudos[w]=l(w);S=a.compile=function(e,t){var n,r=[],i=[],o=U[e+" "];if(!o){for(t||(t=f(e)),n=t.length;n--;)o=y(t[n]),o[P]?r.push(o):i.push(o);o=U(e,v(i,r))}return o},C.pseudos.nth=C.pseudos.eq,C.filters=T.prototype=C.pseudos,C.setFilters=new T,D(),a.attr=st.attr,st.find=a,st.expr=a.selectors,st.expr[":"]=st.expr.pseudos,st.unique=a.uniqueSort,st.text=a.getText,st.isXMLDoc=a.isXML,st.contains=a.contains}(e);var Pt=/Until$/,Rt=/^(?:parents|prev(?:Until|All))/,Wt=/^.[^:#\[\.,]*$/,$t=st.expr.match.needsContext,It={children:!0,contents:!0,next:!0,prev:!0};st.fn.extend({find:function(e){var t,n,r;if("string"!=typeof e)return r=this,this.pushStack(st(e).filter(function(){for(t=0;r.length>t;t++)if(st.contains(r[t],this))return!0}));for(n=[],t=0;this.length>t;t++)st.find(e,this[t],n);return n=this.pushStack(st.unique(n)),n.selector=(this.selector?this.selector+" ":"")+e,n},has:function(e){var t,n=st(e,this),r=n.length;return this.filter(function(){for(t=0;r>t;t++)if(st.contains(this,n[t]))return!0})},not:function(e){return this.pushStack(f(this,e,!1))},filter:function(e){return this.pushStack(f(this,e,!0))},is:function(e){return!!e&&("string"==typeof e?$t.test(e)?st(e,this.context).index(this[0])>=0:st.filter(e,this).length>0:this.filter(e).length>0)},closest:function(e,t){for(var n,r=0,i=this.length,o=[],a=$t.test(e)||"string"!=typeof e?st(e,t||this.context):0;i>r;r++)for(n=this[r];n&&n.ownerDocument&&n!==t&&11!==n.nodeType;){if(a?a.index(n)>-1:st.find.matchesSelector(n,e)){o.push(n);break}n=n.parentNode}return this.pushStack(o.length>1?st.unique(o):o)},index:function(e){return e?"string"==typeof e?st.inArray(this[0],st(e)):st.inArray(e.jquery?e[0]:e,this):this[0]&&this[0].parentNode?this.first().prevAll().length:-1},add:function(e,t){var n="string"==typeof e?st(e,t):st.makeArray(e&&e.nodeType?[e]:e),r=st.merge(this.get(),n);return this.pushStack(st.unique(r))},addBack:function(e){return this.add(null==e?this.prevObject:this.prevObject.filter(e))}}),st.fn.andSelf=st.fn.addBack,st.each({parent:function(e){var t=e.parentNode;return t&&11!==t.nodeType?t:null},parents:function(e){return st.dir(e,"parentNode")},parentsUntil:function(e,t,n){return st.dir(e,"parentNode",n)},next:function(e){return c(e,"nextSibling")},prev:function(e){return c(e,"previousSibling")
},nextAll:function(e){return st.dir(e,"nextSibling")},prevAll:function(e){return st.dir(e,"previousSibling")},nextUntil:function(e,t,n){return st.dir(e,"nextSibling",n)},prevUntil:function(e,t,n){return st.dir(e,"previousSibling",n)},siblings:function(e){return st.sibling((e.parentNode||{}).firstChild,e)},children:function(e){return st.sibling(e.firstChild)},contents:function(e){return st.nodeName(e,"iframe")?e.contentDocument||e.contentWindow.document:st.merge([],e.childNodes)}},function(e,t){st.fn[e]=function(n,r){var i=st.map(this,t,n);return Pt.test(e)||(r=n),r&&"string"==typeof r&&(i=st.filter(r,i)),i=this.length>1&&!It[e]?st.unique(i):i,this.length>1&&Rt.test(e)&&(i=i.reverse()),this.pushStack(i)}}),st.extend({filter:function(e,t,n){return n&&(e=":not("+e+")"),1===t.length?st.find.matchesSelector(t[0],e)?[t[0]]:[]:st.find.matches(e,t)},dir:function(e,n,r){for(var i=[],o=e[n];o&&9!==o.nodeType&&(r===t||1!==o.nodeType||!st(o).is(r));)1===o.nodeType&&i.push(o),o=o[n];return i},sibling:function(e,t){for(var n=[];e;e=e.nextSibling)1===e.nodeType&&e!==t&&n.push(e);return n}});var zt="abbr|article|aside|audio|bdi|canvas|data|datalist|details|figcaption|figure|footer|header|hgroup|mark|meter|nav|output|progress|section|summary|time|video",Xt=/ jQuery\d+="(?:null|\d+)"/g,Ut=RegExp("<(?:"+zt+")[\\s/>]","i"),Vt=/^\s+/,Yt=/<(?!area|br|col|embed|hr|img|input|link|meta|param)(([\w:]+)[^>]*)\/>/gi,Jt=/<([\w:]+)/,Gt=/<tbody/i,Qt=/<|&#?\w+;/,Kt=/<(?:script|style|link)/i,Zt=/^(?:checkbox|radio)$/i,en=/checked\s*(?:[^=]|=\s*.checked.)/i,tn=/^$|\/(?:java|ecma)script/i,nn=/^true\/(.*)/,rn=/^\s*<!(?:\[CDATA\[|--)|(?:\]\]|--)>\s*$/g,on={option:[1,"<select multiple='multiple'>","</select>"],legend:[1,"<fieldset>","</fieldset>"],area:[1,"<map>","</map>"],param:[1,"<object>","</object>"],thead:[1,"<table>","</table>"],tr:[2,"<table><tbody>","</tbody></table>"],col:[2,"<table><tbody></tbody><colgroup>","</colgroup></table>"],td:[3,"<table><tbody><tr>","</tr></tbody></table>"],_default:st.support.htmlSerialize?[0,"",""]:[1,"X<div>","</div>"]},an=p(V),sn=an.appendChild(V.createElement("div"));on.optgroup=on.option,on.tbody=on.tfoot=on.colgroup=on.caption=on.thead,on.th=on.td,st.fn.extend({text:function(e){return st.access(this,function(e){return e===t?st.text(this):this.empty().append((this[0]&&this[0].ownerDocument||V).createTextNode(e))},null,e,arguments.length)},wrapAll:function(e){if(st.isFunction(e))return this.each(function(t){st(this).wrapAll(e.call(this,t))});if(this[0]){var t=st(e,this[0].ownerDocument).eq(0).clone(!0);this[0].parentNode&&t.insertBefore(this[0]),t.map(function(){for(var e=this;e.firstChild&&1===e.firstChild.nodeType;)e=e.firstChild;return e}).append(this)}return this},wrapInner:function(e){return st.isFunction(e)?this.each(function(t){st(this).wrapInner(e.call(this,t))}):this.each(function(){var t=st(this),n=t.contents();n.length?n.wrapAll(e):t.append(e)})},wrap:function(e){var t=st.isFunction(e);return this.each(function(n){st(this).wrapAll(t?e.call(this,n):e)})},unwrap:function(){return this.parent().each(function(){st.nodeName(this,"body")||st(this).replaceWith(this.childNodes)}).end()},append:function(){return this.domManip(arguments,!0,function(e){(1===this.nodeType||11===this.nodeType||9===this.nodeType)&&this.appendChild(e)})},prepend:function(){return this.domManip(arguments,!0,function(e){(1===this.nodeType||11===this.nodeType||9===this.nodeType)&&this.insertBefore(e,this.firstChild)})},before:function(){return this.domManip(arguments,!1,function(e){this.parentNode&&this.parentNode.insertBefore(e,this)})},after:function(){return this.domManip(arguments,!1,function(e){this.parentNode&&this.parentNode.insertBefore(e,this.nextSibling)})},remove:function(e,t){for(var n,r=0;null!=(n=this[r]);r++)(!e||st.filter(e,[n]).length>0)&&(t||1!==n.nodeType||st.cleanData(b(n)),n.parentNode&&(t&&st.contains(n.ownerDocument,n)&&m(b(n,"script")),n.parentNode.removeChild(n)));return this},empty:function(){for(var e,t=0;null!=(e=this[t]);t++){for(1===e.nodeType&&st.cleanData(b(e,!1));e.firstChild;)e.removeChild(e.firstChild);e.options&&st.nodeName(e,"select")&&(e.options.length=0)}return this},clone:function(e,t){return e=null==e?!1:e,t=null==t?e:t,this.map(function(){return st.clone(this,e,t)})},html:function(e){return st.access(this,function(e){var n=this[0]||{},r=0,i=this.length;if(e===t)return 1===n.nodeType?n.innerHTML.replace(Xt,""):t;if(!("string"!=typeof e||Kt.test(e)||!st.support.htmlSerialize&&Ut.test(e)||!st.support.leadingWhitespace&&Vt.test(e)||on[(Jt.exec(e)||["",""])[1].toLowerCase()])){e=e.replace(Yt,"<$1></$2>");try{for(;i>r;r++)n=this[r]||{},1===n.nodeType&&(st.cleanData(b(n,!1)),n.innerHTML=e);n=0}catch(o){}}n&&this.empty().append(e)},null,e,arguments.length)},replaceWith:function(e){var t=st.isFunction(e);return t||"string"==typeof e||(e=st(e).not(this).detach()),this.domManip([e],!0,function(e){var t=this.nextSibling,n=this.parentNode;(n&&1===this.nodeType||11===this.nodeType)&&(st(this).remove(),t?t.parentNode.insertBefore(e,t):n.appendChild(e))})},detach:function(e){return this.remove(e,!0)},domManip:function(e,n,r){e=et.apply([],e);var i,o,a,s,u,l,c=0,f=this.length,p=this,m=f-1,y=e[0],v=st.isFunction(y);if(v||!(1>=f||"string"!=typeof y||st.support.checkClone)&&en.test(y))return this.each(function(i){var o=p.eq(i);v&&(e[0]=y.call(this,i,n?o.html():t)),o.domManip(e,n,r)});if(f&&(i=st.buildFragment(e,this[0].ownerDocument,!1,this),o=i.firstChild,1===i.childNodes.length&&(i=o),o)){for(n=n&&st.nodeName(o,"tr"),a=st.map(b(i,"script"),h),s=a.length;f>c;c++)u=i,c!==m&&(u=st.clone(u,!0,!0),s&&st.merge(a,b(u,"script"))),r.call(n&&st.nodeName(this[c],"table")?d(this[c],"tbody"):this[c],u,c);if(s)for(l=a[a.length-1].ownerDocument,st.map(a,g),c=0;s>c;c++)u=a[c],tn.test(u.type||"")&&!st._data(u,"globalEval")&&st.contains(l,u)&&(u.src?st.ajax({url:u.src,type:"GET",dataType:"script",async:!1,global:!1,"throws":!0}):st.globalEval((u.text||u.textContent||u.innerHTML||"").replace(rn,"")));i=o=null}return this}}),st.each({appendTo:"append",prependTo:"prepend",insertBefore:"before",insertAfter:"after",replaceAll:"replaceWith"},function(e,t){st.fn[e]=function(e){for(var n,r=0,i=[],o=st(e),a=o.length-1;a>=r;r++)n=r===a?this:this.clone(!0),st(o[r])[t](n),tt.apply(i,n.get());return this.pushStack(i)}}),st.extend({clone:function(e,t,n){var r,i,o,a,s,u=st.contains(e.ownerDocument,e);if(st.support.html5Clone||st.isXMLDoc(e)||!Ut.test("<"+e.nodeName+">")?s=e.cloneNode(!0):(sn.innerHTML=e.outerHTML,sn.removeChild(s=sn.firstChild)),!(st.support.noCloneEvent&&st.support.noCloneChecked||1!==e.nodeType&&11!==e.nodeType||st.isXMLDoc(e)))for(r=b(s),i=b(e),a=0;null!=(o=i[a]);++a)r[a]&&v(o,r[a]);if(t)if(n)for(i=i||b(e),r=r||b(s),a=0;null!=(o=i[a]);a++)y(o,r[a]);else y(e,s);return r=b(s,"script"),r.length>0&&m(r,!u&&b(e,"script")),r=i=o=null,s},buildFragment:function(e,t,n,r){for(var i,o,a,s,u,l,c,f=e.length,d=p(t),h=[],g=0;f>g;g++)if(o=e[g],o||0===o)if("object"===st.type(o))st.merge(h,o.nodeType?[o]:o);else if(Qt.test(o)){for(s=s||d.appendChild(t.createElement("div")),a=(Jt.exec(o)||["",""])[1].toLowerCase(),u=on[a]||on._default,s.innerHTML=u[1]+o.replace(Yt,"<$1></$2>")+u[2],c=u[0];c--;)s=s.lastChild;if(!st.support.leadingWhitespace&&Vt.test(o)&&h.push(t.createTextNode(Vt.exec(o)[0])),!st.support.tbody)for(o="table"!==a||Gt.test(o)?"<table>"!==u[1]||Gt.test(o)?0:s:s.firstChild,c=o&&o.childNodes.length;c--;)st.nodeName(l=o.childNodes[c],"tbody")&&!l.childNodes.length&&o.removeChild(l);for(st.merge(h,s.childNodes),s.textContent="";s.firstChild;)s.removeChild(s.firstChild);s=d.lastChild}else h.push(t.createTextNode(o));for(s&&d.removeChild(s),st.support.appendChecked||st.grep(b(h,"input"),x),g=0;o=h[g++];)if((!r||-1===st.inArray(o,r))&&(i=st.contains(o.ownerDocument,o),s=b(d.appendChild(o),"script"),i&&m(s),n))for(c=0;o=s[c++];)tn.test(o.type||"")&&n.push(o);return s=null,d},cleanData:function(e,n){for(var r,i,o,a,s=0,u=st.expando,l=st.cache,c=st.support.deleteExpando,f=st.event.special;null!=(o=e[s]);s++)if((n||st.acceptData(o))&&(i=o[u],r=i&&l[i])){if(r.events)for(a in r.events)f[a]?st.event.remove(o,a):st.removeEvent(o,a,r.handle);l[i]&&(delete l[i],c?delete o[u]:o.removeAttribute!==t?o.removeAttribute(u):o[u]=null,K.push(i))}}});var un,ln,cn,fn=/alpha\([^)]*\)/i,pn=/opacity\s*=\s*([^)]*)/,dn=/^(top|right|bottom|left)$/,hn=/^(none|table(?!-c[ea]).+)/,gn=/^margin/,mn=RegExp("^("+ut+")(.*)$","i"),yn=RegExp("^("+ut+")(?!px)[a-z%]+$","i"),vn=RegExp("^([+-])=("+ut+")","i"),bn={BODY:"block"},xn={position:"absolute",visibility:"hidden",display:"block"},Tn={letterSpacing:0,fontWeight:400},wn=["Top","Right","Bottom","Left"],Nn=["Webkit","O","Moz","ms"];st.fn.extend({css:function(e,n){return st.access(this,function(e,n,r){var i,o,a={},s=0;if(st.isArray(n)){for(i=ln(e),o=n.length;o>s;s++)a[n[s]]=st.css(e,n[s],!1,i);return a}return r!==t?st.style(e,n,r):st.css(e,n)},e,n,arguments.length>1)},show:function(){return N(this,!0)},hide:function(){return N(this)},toggle:function(e){var t="boolean"==typeof e;return this.each(function(){(t?e:w(this))?st(this).show():st(this).hide()})}}),st.extend({cssHooks:{opacity:{get:function(e,t){if(t){var n=un(e,"opacity");return""===n?"1":n}}}},cssNumber:{columnCount:!0,fillOpacity:!0,fontWeight:!0,lineHeight:!0,opacity:!0,orphans:!0,widows:!0,zIndex:!0,zoom:!0},cssProps:{"float":st.support.cssFloat?"cssFloat":"styleFloat"},style:function(e,n,r,i){if(e&&3!==e.nodeType&&8!==e.nodeType&&e.style){var o,a,s,u=st.camelCase(n),l=e.style;if(n=st.cssProps[u]||(st.cssProps[u]=T(l,u)),s=st.cssHooks[n]||st.cssHooks[u],r===t)return s&&"get"in s&&(o=s.get(e,!1,i))!==t?o:l[n];if(a=typeof r,"string"===a&&(o=vn.exec(r))&&(r=(o[1]+1)*o[2]+parseFloat(st.css(e,n)),a="number"),!(null==r||"number"===a&&isNaN(r)||("number"!==a||st.cssNumber[u]||(r+="px"),st.support.clearCloneStyle||""!==r||0!==n.indexOf("background")||(l[n]="inherit"),s&&"set"in s&&(r=s.set(e,r,i))===t)))try{l[n]=r}catch(c){}}},css:function(e,n,r,i){var o,a,s,u=st.camelCase(n);return n=st.cssProps[u]||(st.cssProps[u]=T(e.style,u)),s=st.cssHooks[n]||st.cssHooks[u],s&&"get"in s&&(o=s.get(e,!0,r)),o===t&&(o=un(e,n,i)),"normal"===o&&n in Tn&&(o=Tn[n]),r?(a=parseFloat(o),r===!0||st.isNumeric(a)?a||0:o):o},swap:function(e,t,n,r){var i,o,a={};for(o in t)a[o]=e.style[o],e.style[o]=t[o];i=n.apply(e,r||[]);for(o in t)e.style[o]=a[o];return i}}),e.getComputedStyle?(ln=function(t){return e.getComputedStyle(t,null)},un=function(e,n,r){var i,o,a,s=r||ln(e),u=s?s.getPropertyValue(n)||s[n]:t,l=e.style;return s&&(""!==u||st.contains(e.ownerDocument,e)||(u=st.style(e,n)),yn.test(u)&&gn.test(n)&&(i=l.width,o=l.minWidth,a=l.maxWidth,l.minWidth=l.maxWidth=l.width=u,u=s.width,l.width=i,l.minWidth=o,l.maxWidth=a)),u}):V.documentElement.currentStyle&&(ln=function(e){return e.currentStyle},un=function(e,n,r){var i,o,a,s=r||ln(e),u=s?s[n]:t,l=e.style;return null==u&&l&&l[n]&&(u=l[n]),yn.test(u)&&!dn.test(n)&&(i=l.left,o=e.runtimeStyle,a=o&&o.left,a&&(o.left=e.currentStyle.left),l.left="fontSize"===n?"1em":u,u=l.pixelLeft+"px",l.left=i,a&&(o.left=a)),""===u?"auto":u}),st.each(["height","width"],function(e,n){st.cssHooks[n]={get:function(e,r,i){return r?0===e.offsetWidth&&hn.test(st.css(e,"display"))?st.swap(e,xn,function(){return E(e,n,i)}):E(e,n,i):t},set:function(e,t,r){var i=r&&ln(e);return C(e,t,r?k(e,n,r,st.support.boxSizing&&"border-box"===st.css(e,"boxSizing",!1,i),i):0)}}}),st.support.opacity||(st.cssHooks.opacity={get:function(e,t){return pn.test((t&&e.currentStyle?e.currentStyle.filter:e.style.filter)||"")?.01*parseFloat(RegExp.$1)+"":t?"1":""},set:function(e,t){var n=e.style,r=e.currentStyle,i=st.isNumeric(t)?"alpha(opacity="+100*t+")":"",o=r&&r.filter||n.filter||"";n.zoom=1,(t>=1||""===t)&&""===st.trim(o.replace(fn,""))&&n.removeAttribute&&(n.removeAttribute("filter"),""===t||r&&!r.filter)||(n.filter=fn.test(o)?o.replace(fn,i):o+" "+i)}}),st(function(){st.support.reliableMarginRight||(st.cssHooks.marginRight={get:function(e,n){return n?st.swap(e,{display:"inline-block"},un,[e,"marginRight"]):t}}),!st.support.pixelPosition&&st.fn.position&&st.each(["top","left"],function(e,n){st.cssHooks[n]={get:function(e,r){return r?(r=un(e,n),yn.test(r)?st(e).position()[n]+"px":r):t}}})}),st.expr&&st.expr.filters&&(st.expr.filters.hidden=function(e){return 0===e.offsetWidth&&0===e.offsetHeight||!st.support.reliableHiddenOffsets&&"none"===(e.style&&e.style.display||st.css(e,"display"))},st.expr.filters.visible=function(e){return!st.expr.filters.hidden(e)}),st.each({margin:"",padding:"",border:"Width"},function(e,t){st.cssHooks[e+t]={expand:function(n){for(var r=0,i={},o="string"==typeof n?n.split(" "):[n];4>r;r++)i[e+wn[r]+t]=o[r]||o[r-2]||o[0];return i}},gn.test(e)||(st.cssHooks[e+t].set=C)});var Cn=/%20/g,kn=/\[\]$/,En=/\r?\n/g,Sn=/^(?:submit|button|image|reset)$/i,An=/^(?:input|select|textarea|keygen)/i;st.fn.extend({serialize:function(){return st.param(this.serializeArray())},serializeArray:function(){return this.map(function(){var e=st.prop(this,"elements");return e?st.makeArray(e):this}).filter(function(){var e=this.type;return this.name&&!st(this).is(":disabled")&&An.test(this.nodeName)&&!Sn.test(e)&&(this.checked||!Zt.test(e))}).map(function(e,t){var n=st(this).val();return null==n?null:st.isArray(n)?st.map(n,function(e){return{name:t.name,value:e.replace(En,"\r\n")}}):{name:t.name,value:n.replace(En,"\r\n")}}).get()}}),st.param=function(e,n){var r,i=[],o=function(e,t){t=st.isFunction(t)?t():null==t?"":t,i[i.length]=encodeURIComponent(e)+"="+encodeURIComponent(t)};if(n===t&&(n=st.ajaxSettings&&st.ajaxSettings.traditional),st.isArray(e)||e.jquery&&!st.isPlainObject(e))st.each(e,function(){o(this.name,this.value)});else for(r in e)j(r,e[r],n,o);return i.join("&").replace(Cn,"+")};var jn,Dn,Ln=st.now(),Hn=/\?/,Mn=/#.*$/,qn=/([?&])_=[^&]*/,_n=/^(.*?):[ \t]*([^\r\n]*)\r?$/gm,Fn=/^(?:about|app|app-storage|.+-extension|file|res|widget):$/,On=/^(?:GET|HEAD)$/,Bn=/^\/\//,Pn=/^([\w.+-]+:)(?:\/\/([^\/?#:]*)(?::(\d+)|)|)/,Rn=st.fn.load,Wn={},$n={},In="*/".concat("*");try{Dn=Y.href}catch(zn){Dn=V.createElement("a"),Dn.href="",Dn=Dn.href}jn=Pn.exec(Dn.toLowerCase())||[],st.fn.load=function(e,n,r){if("string"!=typeof e&&Rn)return Rn.apply(this,arguments);var i,o,a,s=this,u=e.indexOf(" ");return u>=0&&(i=e.slice(u,e.length),e=e.slice(0,u)),st.isFunction(n)?(r=n,n=t):n&&"object"==typeof n&&(o="POST"),s.length>0&&st.ajax({url:e,type:o,dataType:"html",data:n}).done(function(e){a=arguments,s.html(i?st("<div>").append(st.parseHTML(e)).find(i):e)}).complete(r&&function(e,t){s.each(r,a||[e.responseText,t,e])}),this},st.each(["ajaxStart","ajaxStop","ajaxComplete","ajaxError","ajaxSuccess","ajaxSend"],function(e,t){st.fn[t]=function(e){return this.on(t,e)}}),st.each(["get","post"],function(e,n){st[n]=function(e,r,i,o){return st.isFunction(r)&&(o=o||i,i=r,r=t),st.ajax({url:e,type:n,dataType:o,data:r,success:i})}}),st.extend({active:0,lastModified:{},etag:{},ajaxSettings:{url:Dn,type:"GET",isLocal:Fn.test(jn[1]),global:!0,processData:!0,async:!0,contentType:"application/x-www-form-urlencoded; charset=UTF-8",accepts:{"*":In,text:"text/plain",html:"text/html",xml:"application/xml, text/xml",json:"application/json, text/javascript"},contents:{xml:/xml/,html:/html/,json:/json/},responseFields:{xml:"responseXML",text:"responseText"},converters:{"* text":e.String,"text html":!0,"text json":st.parseJSON,"text xml":st.parseXML},flatOptions:{url:!0,context:!0}},ajaxSetup:function(e,t){return t?H(H(e,st.ajaxSettings),t):H(st.ajaxSettings,e)},ajaxPrefilter:D(Wn),ajaxTransport:D($n),ajax:function(e,n){function r(e,n,r,s){var l,f,v,b,T,N=n;2!==x&&(x=2,u&&clearTimeout(u),i=t,a=s||"",w.readyState=e>0?4:0,r&&(b=M(p,w,r)),e>=200&&300>e||304===e?(p.ifModified&&(T=w.getResponseHeader("Last-Modified"),T&&(st.lastModified[o]=T),T=w.getResponseHeader("etag"),T&&(st.etag[o]=T)),304===e?(l=!0,N="notmodified"):(l=q(p,b),N=l.state,f=l.data,v=l.error,l=!v)):(v=N,(e||!N)&&(N="error",0>e&&(e=0))),w.status=e,w.statusText=(n||N)+"",l?g.resolveWith(d,[f,N,w]):g.rejectWith(d,[w,N,v]),w.statusCode(y),y=t,c&&h.trigger(l?"ajaxSuccess":"ajaxError",[w,p,l?f:v]),m.fireWith(d,[w,N]),c&&(h.trigger("ajaxComplete",[w,p]),--st.active||st.event.trigger("ajaxStop")))}"object"==typeof e&&(n=e,e=t),n=n||{};var i,o,a,s,u,l,c,f,p=st.ajaxSetup({},n),d=p.context||p,h=p.context&&(d.nodeType||d.jquery)?st(d):st.event,g=st.Deferred(),m=st.Callbacks("once memory"),y=p.statusCode||{},v={},b={},x=0,T="canceled",w={readyState:0,getResponseHeader:function(e){var t;if(2===x){if(!s)for(s={};t=_n.exec(a);)s[t[1].toLowerCase()]=t[2];t=s[e.toLowerCase()]}return null==t?null:t},getAllResponseHeaders:function(){return 2===x?a:null},setRequestHeader:function(e,t){var n=e.toLowerCase();return x||(e=b[n]=b[n]||e,v[e]=t),this},overrideMimeType:function(e){return x||(p.mimeType=e),this},statusCode:function(e){var t;if(e)if(2>x)for(t in e)y[t]=[y[t],e[t]];else w.always(e[w.status]);return this},abort:function(e){var t=e||T;return i&&i.abort(t),r(0,t),this}};if(g.promise(w).complete=m.add,w.success=w.done,w.error=w.fail,p.url=((e||p.url||Dn)+"").replace(Mn,"").replace(Bn,jn[1]+"//"),p.type=n.method||n.type||p.method||p.type,p.dataTypes=st.trim(p.dataType||"*").toLowerCase().match(lt)||[""],null==p.crossDomain&&(l=Pn.exec(p.url.toLowerCase()),p.crossDomain=!(!l||l[1]===jn[1]&&l[2]===jn[2]&&(l[3]||("http:"===l[1]?80:443))==(jn[3]||("http:"===jn[1]?80:443)))),p.data&&p.processData&&"string"!=typeof p.data&&(p.data=st.param(p.data,p.traditional)),L(Wn,p,n,w),2===x)return w;c=p.global,c&&0===st.active++&&st.event.trigger("ajaxStart"),p.type=p.type.toUpperCase(),p.hasContent=!On.test(p.type),o=p.url,p.hasContent||(p.data&&(o=p.url+=(Hn.test(o)?"&":"?")+p.data,delete p.data),p.cache===!1&&(p.url=qn.test(o)?o.replace(qn,"$1_="+Ln++):o+(Hn.test(o)?"&":"?")+"_="+Ln++)),p.ifModified&&(st.lastModified[o]&&w.setRequestHeader("If-Modified-Since",st.lastModified[o]),st.etag[o]&&w.setRequestHeader("If-None-Match",st.etag[o])),(p.data&&p.hasContent&&p.contentType!==!1||n.contentType)&&w.setRequestHeader("Content-Type",p.contentType),w.setRequestHeader("Accept",p.dataTypes[0]&&p.accepts[p.dataTypes[0]]?p.accepts[p.dataTypes[0]]+("*"!==p.dataTypes[0]?", "+In+"; q=0.01":""):p.accepts["*"]);for(f in p.headers)w.setRequestHeader(f,p.headers[f]);if(p.beforeSend&&(p.beforeSend.call(d,w,p)===!1||2===x))return w.abort();T="abort";for(f in{success:1,error:1,complete:1})w[f](p[f]);if(i=L($n,p,n,w)){w.readyState=1,c&&h.trigger("ajaxSend",[w,p]),p.async&&p.timeout>0&&(u=setTimeout(function(){w.abort("timeout")},p.timeout));try{x=1,i.send(v,r)}catch(N){if(!(2>x))throw N;r(-1,N)}}else r(-1,"No Transport");return w},getScript:function(e,n){return st.get(e,t,n,"script")},getJSON:function(e,t,n){return st.get(e,t,n,"json")}}),st.ajaxSetup({accepts:{script:"text/javascript, application/javascript, application/ecmascript, application/x-ecmascript"},contents:{script:/(?:java|ecma)script/},converters:{"text script":function(e){return st.globalEval(e),e}}}),st.ajaxPrefilter("script",function(e){e.cache===t&&(e.cache=!1),e.crossDomain&&(e.type="GET",e.global=!1)}),st.ajaxTransport("script",function(e){if(e.crossDomain){var n,r=V.head||st("head")[0]||V.documentElement;return{send:function(t,i){n=V.createElement("script"),n.async=!0,e.scriptCharset&&(n.charset=e.scriptCharset),n.src=e.url,n.onload=n.onreadystatechange=function(e,t){(t||!n.readyState||/loaded|complete/.test(n.readyState))&&(n.onload=n.onreadystatechange=null,n.parentNode&&n.parentNode.removeChild(n),n=null,t||i(200,"success"))},r.insertBefore(n,r.firstChild)},abort:function(){n&&n.onload(t,!0)}}}});var Xn=[],Un=/(=)\?(?=&|$)|\?\?/;st.ajaxSetup({jsonp:"callback",jsonpCallback:function(){var e=Xn.pop()||st.expando+"_"+Ln++;return this[e]=!0,e}}),st.ajaxPrefilter("json jsonp",function(n,r,i){var o,a,s,u=n.jsonp!==!1&&(Un.test(n.url)?"url":"string"==typeof n.data&&!(n.contentType||"").indexOf("application/x-www-form-urlencoded")&&Un.test(n.data)&&"data");return u||"jsonp"===n.dataTypes[0]?(o=n.jsonpCallback=st.isFunction(n.jsonpCallback)?n.jsonpCallback():n.jsonpCallback,u?n[u]=n[u].replace(Un,"$1"+o):n.jsonp!==!1&&(n.url+=(Hn.test(n.url)?"&":"?")+n.jsonp+"="+o),n.converters["script json"]=function(){return s||st.error(o+" was not called"),s[0]},n.dataTypes[0]="json",a=e[o],e[o]=function(){s=arguments},i.always(function(){e[o]=a,n[o]&&(n.jsonpCallback=r.jsonpCallback,Xn.push(o)),s&&st.isFunction(a)&&a(s[0]),s=a=t}),"script"):t});var Vn,Yn,Jn=0,Gn=e.ActiveXObject&&function(){var e;for(e in Vn)Vn[e](t,!0)};st.ajaxSettings.xhr=e.ActiveXObject?function(){return!this.isLocal&&_()||F()}:_,Yn=st.ajaxSettings.xhr(),st.support.cors=!!Yn&&"withCredentials"in Yn,Yn=st.support.ajax=!!Yn,Yn&&st.ajaxTransport(function(n){if(!n.crossDomain||st.support.cors){var r;return{send:function(i,o){var a,s,u=n.xhr();if(n.username?u.open(n.type,n.url,n.async,n.username,n.password):u.open(n.type,n.url,n.async),n.xhrFields)for(s in n.xhrFields)u[s]=n.xhrFields[s];n.mimeType&&u.overrideMimeType&&u.overrideMimeType(n.mimeType),n.crossDomain||i["X-Requested-With"]||(i["X-Requested-With"]="XMLHttpRequest");try{for(s in i)u.setRequestHeader(s,i[s])}catch(l){}u.send(n.hasContent&&n.data||null),r=function(e,i){var s,l,c,f,p;try{if(r&&(i||4===u.readyState))if(r=t,a&&(u.onreadystatechange=st.noop,Gn&&delete Vn[a]),i)4!==u.readyState&&u.abort();else{f={},s=u.status,p=u.responseXML,c=u.getAllResponseHeaders(),p&&p.documentElement&&(f.xml=p),"string"==typeof u.responseText&&(f.text=u.responseText);try{l=u.statusText}catch(d){l=""}s||!n.isLocal||n.crossDomain?1223===s&&(s=204):s=f.text?200:404}}catch(h){i||o(-1,h)}f&&o(s,l,f,c)},n.async?4===u.readyState?setTimeout(r):(a=++Jn,Gn&&(Vn||(Vn={},st(e).unload(Gn)),Vn[a]=r),u.onreadystatechange=r):r()},abort:function(){r&&r(t,!0)}}}});var Qn,Kn,Zn=/^(?:toggle|show|hide)$/,er=RegExp("^(?:([+-])=|)("+ut+")([a-z%]*)$","i"),tr=/queueHooks$/,nr=[W],rr={"*":[function(e,t){var n,r,i=this.createTween(e,t),o=er.exec(t),a=i.cur(),s=+a||0,u=1,l=20;if(o){if(n=+o[2],r=o[3]||(st.cssNumber[e]?"":"px"),"px"!==r&&s){s=st.css(i.elem,e,!0)||n||1;do u=u||".5",s/=u,st.style(i.elem,e,s+r);while(u!==(u=i.cur()/a)&&1!==u&&--l)}i.unit=r,i.start=s,i.end=o[1]?s+(o[1]+1)*n:n}return i}]};st.Animation=st.extend(P,{tweener:function(e,t){st.isFunction(e)?(t=e,e=["*"]):e=e.split(" ");for(var n,r=0,i=e.length;i>r;r++)n=e[r],rr[n]=rr[n]||[],rr[n].unshift(t)},prefilter:function(e,t){t?nr.unshift(e):nr.push(e)}}),st.Tween=$,$.prototype={constructor:$,init:function(e,t,n,r,i,o){this.elem=e,this.prop=n,this.easing=i||"swing",this.options=t,this.start=this.now=this.cur(),this.end=r,this.unit=o||(st.cssNumber[n]?"":"px")},cur:function(){var e=$.propHooks[this.prop];return e&&e.get?e.get(this):$.propHooks._default.get(this)},run:function(e){var t,n=$.propHooks[this.prop];return this.pos=t=this.options.duration?st.easing[this.easing](e,this.options.duration*e,0,1,this.options.duration):e,this.now=(this.end-this.start)*t+this.start,this.options.step&&this.options.step.call(this.elem,this.now,this),n&&n.set?n.set(this):$.propHooks._default.set(this),this}},$.prototype.init.prototype=$.prototype,$.propHooks={_default:{get:function(e){var t;return null==e.elem[e.prop]||e.elem.style&&null!=e.elem.style[e.prop]?(t=st.css(e.elem,e.prop,"auto"),t&&"auto"!==t?t:0):e.elem[e.prop]},set:function(e){st.fx.step[e.prop]?st.fx.step[e.prop](e):e.elem.style&&(null!=e.elem.style[st.cssProps[e.prop]]||st.cssHooks[e.prop])?st.style(e.elem,e.prop,e.now+e.unit):e.elem[e.prop]=e.now}}},$.propHooks.scrollTop=$.propHooks.scrollLeft={set:function(e){e.elem.nodeType&&e.elem.parentNode&&(e.elem[e.prop]=e.now)}},st.each(["toggle","show","hide"],function(e,t){var n=st.fn[t];st.fn[t]=function(e,r,i){return null==e||"boolean"==typeof e?n.apply(this,arguments):this.animate(I(t,!0),e,r,i)}}),st.fn.extend({fadeTo:function(e,t,n,r){return this.filter(w).css("opacity",0).show().end().animate({opacity:t},e,n,r)},animate:function(e,t,n,r){var i=st.isEmptyObject(e),o=st.speed(t,n,r),a=function(){var t=P(this,st.extend({},e),o);a.finish=function(){t.stop(!0)},(i||st._data(this,"finish"))&&t.stop(!0)};return a.finish=a,i||o.queue===!1?this.each(a):this.queue(o.queue,a)},stop:function(e,n,r){var i=function(e){var t=e.stop;delete e.stop,t(r)};return"string"!=typeof e&&(r=n,n=e,e=t),n&&e!==!1&&this.queue(e||"fx",[]),this.each(function(){var t=!0,n=null!=e&&e+"queueHooks",o=st.timers,a=st._data(this);if(n)a[n]&&a[n].stop&&i(a[n]);else for(n in a)a[n]&&a[n].stop&&tr.test(n)&&i(a[n]);for(n=o.length;n--;)o[n].elem!==this||null!=e&&o[n].queue!==e||(o[n].anim.stop(r),t=!1,o.splice(n,1));(t||!r)&&st.dequeue(this,e)})},finish:function(e){return e!==!1&&(e=e||"fx"),this.each(function(){var t,n=st._data(this),r=n[e+"queue"],i=n[e+"queueHooks"],o=st.timers,a=r?r.length:0;for(n.finish=!0,st.queue(this,e,[]),i&&i.cur&&i.cur.finish&&i.cur.finish.call(this),t=o.length;t--;)o[t].elem===this&&o[t].queue===e&&(o[t].anim.stop(!0),o.splice(t,1));for(t=0;a>t;t++)r[t]&&r[t].finish&&r[t].finish.call(this);delete n.finish})}}),st.each({slideDown:I("show"),slideUp:I("hide"),slideToggle:I("toggle"),fadeIn:{opacity:"show"},fadeOut:{opacity:"hide"},fadeToggle:{opacity:"toggle"}},function(e,t){st.fn[e]=function(e,n,r){return this.animate(t,e,n,r)}}),st.speed=function(e,t,n){var r=e&&"object"==typeof e?st.extend({},e):{complete:n||!n&&t||st.isFunction(e)&&e,duration:e,easing:n&&t||t&&!st.isFunction(t)&&t};return r.duration=st.fx.off?0:"number"==typeof r.duration?r.duration:r.duration in st.fx.speeds?st.fx.speeds[r.duration]:st.fx.speeds._default,(null==r.queue||r.queue===!0)&&(r.queue="fx"),r.old=r.complete,r.complete=function(){st.isFunction(r.old)&&r.old.call(this),r.queue&&st.dequeue(this,r.queue)},r},st.easing={linear:function(e){return e},swing:function(e){return.5-Math.cos(e*Math.PI)/2}},st.timers=[],st.fx=$.prototype.init,st.fx.tick=function(){var e,n=st.timers,r=0;for(Qn=st.now();n.length>r;r++)e=n[r],e()||n[r]!==e||n.splice(r--,1);n.length||st.fx.stop(),Qn=t},st.fx.timer=function(e){e()&&st.timers.push(e)&&st.fx.start()},st.fx.interval=13,st.fx.start=function(){Kn||(Kn=setInterval(st.fx.tick,st.fx.interval))},st.fx.stop=function(){clearInterval(Kn),Kn=null},st.fx.speeds={slow:600,fast:200,_default:400},st.fx.step={},st.expr&&st.expr.filters&&(st.expr.filters.animated=function(e){return st.grep(st.timers,function(t){return e===t.elem}).length}),st.fn.offset=function(e){if(arguments.length)return e===t?this:this.each(function(t){st.offset.setOffset(this,e,t)});var n,r,i={top:0,left:0},o=this[0],a=o&&o.ownerDocument;if(a)return n=a.documentElement,st.contains(n,o)?(o.getBoundingClientRect!==t&&(i=o.getBoundingClientRect()),r=z(a),{top:i.top+(r.pageYOffset||n.scrollTop)-(n.clientTop||0),left:i.left+(r.pageXOffset||n.scrollLeft)-(n.clientLeft||0)}):i},st.offset={setOffset:function(e,t,n){var r=st.css(e,"position");"static"===r&&(e.style.position="relative");var i,o,a=st(e),s=a.offset(),u=st.css(e,"top"),l=st.css(e,"left"),c=("absolute"===r||"fixed"===r)&&st.inArray("auto",[u,l])>-1,f={},p={};c?(p=a.position(),i=p.top,o=p.left):(i=parseFloat(u)||0,o=parseFloat(l)||0),st.isFunction(t)&&(t=t.call(e,n,s)),null!=t.top&&(f.top=t.top-s.top+i),null!=t.left&&(f.left=t.left-s.left+o),"using"in t?t.using.call(e,f):a.css(f)}},st.fn.extend({position:function(){if(this[0]){var e,t,n={top:0,left:0},r=this[0];return"fixed"===st.css(r,"position")?t=r.getBoundingClientRect():(e=this.offsetParent(),t=this.offset(),st.nodeName(e[0],"html")||(n=e.offset()),n.top+=st.css(e[0],"borderTopWidth",!0),n.left+=st.css(e[0],"borderLeftWidth",!0)),{top:t.top-n.top-st.css(r,"marginTop",!0),left:t.left-n.left-st.css(r,"marginLeft",!0)}}},offsetParent:function(){return this.map(function(){for(var e=this.offsetParent||V.documentElement;e&&!st.nodeName(e,"html")&&"static"===st.css(e,"position");)e=e.offsetParent;return e||V.documentElement})}}),st.each({scrollLeft:"pageXOffset",scrollTop:"pageYOffset"},function(e,n){var r=/Y/.test(n);st.fn[e]=function(i){return st.access(this,function(e,i,o){var a=z(e);return o===t?a?n in a?a[n]:a.document.documentElement[i]:e[i]:(a?a.scrollTo(r?st(a).scrollLeft():o,r?o:st(a).scrollTop()):e[i]=o,t)},e,i,arguments.length,null)}}),st.each({Height:"height",Width:"width"},function(e,n){st.each({padding:"inner"+e,content:n,"":"outer"+e},function(r,i){st.fn[i]=function(i,o){var a=arguments.length&&(r||"boolean"!=typeof i),s=r||(i===!0||o===!0?"margin":"border");return st.access(this,function(n,r,i){var o;return st.isWindow(n)?n.document.documentElement["client"+e]:9===n.nodeType?(o=n.documentElement,Math.max(n.body["scroll"+e],o["scroll"+e],n.body["offset"+e],o["offset"+e],o["client"+e])):i===t?st.css(n,r,s):st.style(n,r,i,s)},n,a?i:t,a,null)}})}),e.jQuery=e.$=st,"function"==typeof define&&define.amd&&define.amd.jQuery&&define("jquery",[],function(){return st})})(window);
//@ sourceMappingURL=jquery.min.map
/*
    json2.js
    2012-10-08

    Public Domain.

    NO WARRANTY EXPRESSED OR IMPLIED. USE AT YOUR OWN RISK.

    See http://www.JSON.org/js.html


    This code should be minified before deployment.
    See http://javascript.crockford.com/jsmin.html

    USE YOUR OWN COPY. IT IS EXTREMELY UNWISE TO LOAD CODE FROM SERVERS YOU DO
    NOT CONTROL.


    This file creates a global JSON object containing two methods: stringify
    and parse.

        JSON.stringify(value, replacer, space)
            value       any JavaScript value, usually an object or array.

            replacer    an optional parameter that determines how object
                        values are stringified for objects. It can be a
                        function or an array of strings.

            space       an optional parameter that specifies the indentation
                        of nested structures. If it is omitted, the text will
                        be packed without extra whitespace. If it is a number,
                        it will specify the number of spaces to indent at each
                        level. If it is a string (such as '\t' or '&nbsp;'),
                        it contains the characters used to indent at each level.

            This method produces a JSON text from a JavaScript value.

            When an object value is found, if the object contains a toJSON
            method, its toJSON method will be called and the result will be
            stringified. A toJSON method does not serialize: it returns the
            value represented by the name/value pair that should be serialized,
            or undefined if nothing should be serialized. The toJSON method
            will be passed the key associated with the value, and this will be
            bound to the value

            For example, this would serialize Dates as ISO strings.

                Date.prototype.toJSON = function (key) {
                    function f(n) {
                        // Format integers to have at least two digits.
                        return n < 10 ? '0' + n : n;
                    }

                    return this.getUTCFullYear()   + '-' +
                         f(this.getUTCMonth() + 1) + '-' +
                         f(this.getUTCDate())      + 'T' +
                         f(this.getUTCHours())     + ':' +
                         f(this.getUTCMinutes())   + ':' +
                         f(this.getUTCSeconds())   + 'Z';
                };

            You can provide an optional replacer method. It will be passed the
            key and value of each member, with this bound to the containing
            object. The value that is returned from your method will be
            serialized. If your method returns undefined, then the member will
            be excluded from the serialization.

            If the replacer parameter is an array of strings, then it will be
            used to select the members to be serialized. It filters the results
            such that only members with keys listed in the replacer array are
            stringified.

            Values that do not have JSON representations, such as undefined or
            functions, will not be serialized. Such values in objects will be
            dropped; in arrays they will be replaced with null. You can use
            a replacer function to replace those with JSON values.
            JSON.stringify(undefined) returns undefined.

            The optional space parameter produces a stringification of the
            value that is filled with line breaks and indentation to make it
            easier to read.

            If the space parameter is a non-empty string, then that string will
            be used for indentation. If the space parameter is a number, then
            the indentation will be that many spaces.

            Example:

            text = JSON.stringify(['e', {pluribus: 'unum'}]);
            // text is '["e",{"pluribus":"unum"}]'


            text = JSON.stringify(['e', {pluribus: 'unum'}], null, '\t');
            // text is '[\n\t"e",\n\t{\n\t\t"pluribus": "unum"\n\t}\n]'

            text = JSON.stringify([new Date()], function (key, value) {
                return this[key] instanceof Date ?
                    'Date(' + this[key] + ')' : value;
            });
            // text is '["Date(---current time---)"]'


        JSON.parse(text, reviver)
            This method parses a JSON text to produce an object or array.
            It can throw a SyntaxError exception.

            The optional reviver parameter is a function that can filter and
            transform the results. It receives each of the keys and values,
            and its return value is used instead of the original value.
            If it returns what it received, then the structure is not modified.
            If it returns undefined then the member is deleted.

            Example:

            // Parse the text. Values that look like ISO date strings will
            // be converted to Date objects.

            myData = JSON.parse(text, function (key, value) {
                var a;
                if (typeof value === 'string') {
                    a =
/^(\d{4})-(\d{2})-(\d{2})T(\d{2}):(\d{2}):(\d{2}(?:\.\d*)?)Z$/.exec(value);
                    if (a) {
                        return new Date(Date.UTC(+a[1], +a[2] - 1, +a[3], +a[4],
                            +a[5], +a[6]));
                    }
                }
                return value;
            });

            myData = JSON.parse('["Date(09/09/2001)"]', function (key, value) {
                var d;
                if (typeof value === 'string' &&
                        value.slice(0, 5) === 'Date(' &&
                        value.slice(-1) === ')') {
                    d = new Date(value.slice(5, -1));
                    if (d) {
                        return d;
                    }
                }
                return value;
            });


    This is a reference implementation. You are free to copy, modify, or
    redistribute.
*/

/*jslint evil: true, regexp: true */

/*members "", "\b", "\t", "\n", "\f", "\r", "\"", JSON, "\\", apply,
    call, charCodeAt, getUTCDate, getUTCFullYear, getUTCHours,
    getUTCMinutes, getUTCMonth, getUTCSeconds, hasOwnProperty, join,
    lastIndex, length, parse, prototype, push, replace, slice, stringify,
    test, toJSON, toString, valueOf
*/


// Create a JSON object only if one does not already exist. We create the
// methods in a closure to avoid creating global variables.

if (typeof JSON !== 'object') {
    JSON = {};
}

(function () {
    'use strict';

    function f(n) {
        // Format integers to have at least two digits.
        return n < 10 ? '0' + n : n;
    }

    if (typeof Date.prototype.toJSON !== 'function') {

        Date.prototype.toJSON = function (key) {

            return isFinite(this.valueOf())
                ? this.getUTCFullYear()     + '-' +
                    f(this.getUTCMonth() + 1) + '-' +
                    f(this.getUTCDate())      + 'T' +
                    f(this.getUTCHours())     + ':' +
                    f(this.getUTCMinutes())   + ':' +
                    f(this.getUTCSeconds())   + 'Z'
                : null;
        };

        String.prototype.toJSON      =
            Number.prototype.toJSON  =
            Boolean.prototype.toJSON = function (key) {
                return this.valueOf();
            };
    }

    var cx = /[\u0000\u00ad\u0600-\u0604\u070f\u17b4\u17b5\u200c-\u200f\u2028-\u202f\u2060-\u206f\ufeff\ufff0-\uffff]/g,
        escapable = /[\\\"\x00-\x1f\x7f-\x9f\u00ad\u0600-\u0604\u070f\u17b4\u17b5\u200c-\u200f\u2028-\u202f\u2060-\u206f\ufeff\ufff0-\uffff]/g,
        gap,
        indent,
        meta = {    // table of character substitutions
            '\b': '\\b',
            '\t': '\\t',
            '\n': '\\n',
            '\f': '\\f',
            '\r': '\\r',
            '"' : '\\"',
            '\\': '\\\\'
        },
        rep;


    function quote(string) {

// If the string contains no control characters, no quote characters, and no
// backslash characters, then we can safely slap some quotes around it.
// Otherwise we must also replace the offending characters with safe escape
// sequences.

        escapable.lastIndex = 0;
        return escapable.test(string) ? '"' + string.replace(escapable, function (a) {
            var c = meta[a];
            return typeof c === 'string'
                ? c
                : '\\u' + ('0000' + a.charCodeAt(0).toString(16)).slice(-4);
        }) + '"' : '"' + string + '"';
    }


    function str(key, holder) {

// Produce a string from holder[key].

        var i,          // The loop counter.
            k,          // The member key.
            v,          // The member value.
            length,
            mind = gap,
            partial,
            value = holder[key];

// If the value has a toJSON method, call it to obtain a replacement value.

        if (value && typeof value === 'object' &&
                typeof value.toJSON === 'function') {
            value = value.toJSON(key);
        }

// If we were called with a replacer function, then call the replacer to
// obtain a replacement value.

        if (typeof rep === 'function') {
            value = rep.call(holder, key, value);
        }

// What happens next depends on the value's type.

        switch (typeof value) {
        case 'string':
            return quote(value);

        case 'number':

// JSON numbers must be finite. Encode non-finite numbers as null.

            return isFinite(value) ? String(value) : 'null';

        case 'boolean':
        case 'null':

// If the value is a boolean or null, convert it to a string. Note:
// typeof null does not produce 'null'. The case is included here in
// the remote chance that this gets fixed someday.

            return String(value);

// If the type is 'object', we might be dealing with an object or an array or
// null.

        case 'object':

// Due to a specification blunder in ECMAScript, typeof null is 'object',
// so watch out for that case.

            if (!value) {
                return 'null';
            }

// Make an array to hold the partial results of stringifying this object value.

            gap += indent;
            partial = [];

// Is the value an array?

            if (Object.prototype.toString.apply(value) === '[object Array]') {

// The value is an array. Stringify every element. Use null as a placeholder
// for non-JSON values.

                length = value.length;
                for (i = 0; i < length; i += 1) {
                    partial[i] = str(i, value) || 'null';
                }

// Join all of the elements together, separated with commas, and wrap them in
// brackets.

                v = partial.length === 0
                    ? '[]'
                    : gap
                    ? '[\n' + gap + partial.join(',\n' + gap) + '\n' + mind + ']'
                    : '[' + partial.join(',') + ']';
                gap = mind;
                return v;
            }

// If the replacer is an array, use it to select the members to be stringified.

            if (rep && typeof rep === 'object') {
                length = rep.length;
                for (i = 0; i < length; i += 1) {
                    if (typeof rep[i] === 'string') {
                        k = rep[i];
                        v = str(k, value);
                        if (v) {
                            partial.push(quote(k) + (gap ? ': ' : ':') + v);
                        }
                    }
                }
            } else {

// Otherwise, iterate through all of the keys in the object.

                for (k in value) {
                    if (Object.prototype.hasOwnProperty.call(value, k)) {
                        v = str(k, value);
                        if (v) {
                            partial.push(quote(k) + (gap ? ': ' : ':') + v);
                        }
                    }
                }
            }

// Join all of the member texts together, separated with commas,
// and wrap them in braces.

            v = partial.length === 0
                ? '{}'
                : gap
                ? '{\n' + gap + partial.join(',\n' + gap) + '\n' + mind + '}'
                : '{' + partial.join(',') + '}';
            gap = mind;
            return v;
        }
    }

// If the JSON object does not yet have a stringify method, give it one.

    if (typeof JSON.stringify !== 'function') {
        JSON.stringify = function (value, replacer, space) {

// The stringify method takes a value and an optional replacer, and an optional
// space parameter, and returns a JSON text. The replacer can be a function
// that can replace values, or an array of strings that will select the keys.
// A default replacer method can be provided. Use of the space parameter can
// produce text that is more easily readable.

            var i;
            gap = '';
            indent = '';

// If the space parameter is a number, make an indent string containing that
// many spaces.

            if (typeof space === 'number') {
                for (i = 0; i < space; i += 1) {
                    indent += ' ';
                }

// If the space parameter is a string, it will be used as the indent string.

            } else if (typeof space === 'string') {
                indent = space;
            }

// If there is a replacer, it must be a function or an array.
// Otherwise, throw an error.

            rep = replacer;
            if (replacer && typeof replacer !== 'function' &&
                    (typeof replacer !== 'object' ||
                    typeof replacer.length !== 'number')) {
                throw new Error('JSON.stringify');
            }

// Make a fake root object containing our value under the key of ''.
// Return the result of stringifying the value.

            return str('', {'': value});
        };
    }


// If the JSON object does not yet have a parse method, give it one.

    if (typeof JSON.parse !== 'function') {
        JSON.parse = function (text, reviver) {

// The parse method takes a text and an optional reviver function, and returns
// a JavaScript value if the text is a valid JSON text.

            var j;

            function walk(holder, key) {

// The walk method is used to recursively walk the resulting structure so
// that modifications can be made.

                var k, v, value = holder[key];
                if (value && typeof value === 'object') {
                    for (k in value) {
                        if (Object.prototype.hasOwnProperty.call(value, k)) {
                            v = walk(value, k);
                            if (v !== undefined) {
                                value[k] = v;
                            } else {
                                delete value[k];
                            }
                        }
                    }
                }
                return reviver.call(holder, key, value);
            }


// Parsing happens in four stages. In the first stage, we replace certain
// Unicode characters with escape sequences. JavaScript handles many characters
// incorrectly, either silently deleting them, or treating them as line endings.

            text = String(text);
            cx.lastIndex = 0;
            if (cx.test(text)) {
                text = text.replace(cx, function (a) {
                    return '\\u' +
                        ('0000' + a.charCodeAt(0).toString(16)).slice(-4);
                });
            }

// In the second stage, we run the text against regular expressions that look
// for non-JSON patterns. We are especially concerned with '()' and 'new'
// because they can cause invocation, and '=' because it can cause mutation.
// But just to be safe, we want to reject all unexpected forms.

// We split the second stage into 4 regexp operations in order to work around
// crippling inefficiencies in IE's and Safari's regexp engines. First we
// replace the JSON backslash pairs with '@' (a non-JSON character). Second, we
// replace all simple value tokens with ']' characters. Third, we delete all
// open brackets that follow a colon or comma or that begin the text. Finally,
// we look to see that the remaining characters are only whitespace or ']' or
// ',' or ':' or '{' or '}'. If that is so, then the text is safe for eval.

            if (/^[\],:{}\s]*$/
                    .test(text.replace(/\\(?:["\\\/bfnrt]|u[0-9a-fA-F]{4})/g, '@')
                        .replace(/"[^"\\\n\r]*"|true|false|null|-?\d+(?:\.\d*)?(?:[eE][+\-]?\d+)?/g, ']')
                        .replace(/(?:^|:|,)(?:\s*\[)+/g, ''))) {

// In the third stage we use the eval function to compile the text into a
// JavaScript structure. The '{' operator is subject to a syntactic ambiguity
// in JavaScript: it can begin a block or an object literal. We wrap the text
// in parens to eliminate the ambiguity.

                j = eval('(' + text + ')');

// In the optional fourth stage, we recursively walk the new structure, passing
// each name/value pair to a reviver function for possible transformation.

                return typeof reviver === 'function'
                    ? walk({'': j}, '')
                    : j;
            }

// If the text is not JSON parseable, then a SyntaxError is thrown.

            throw new SyntaxError('JSON.parse');
        };
    }
}());

(function(){var n=this,t=n._,r={},e=Array.prototype,u=Object.prototype,i=Function.prototype,a=e.push,o=e.slice,c=e.concat,l=u.toString,f=u.hasOwnProperty,s=e.forEach,p=e.map,v=e.reduce,h=e.reduceRight,g=e.filter,d=e.every,m=e.some,y=e.indexOf,b=e.lastIndexOf,x=Array.isArray,_=Object.keys,j=i.bind,w=function(n){return n instanceof w?n:this instanceof w?(this._wrapped=n,void 0):new w(n)};"undefined"!=typeof exports?("undefined"!=typeof module&&module.exports&&(exports=module.exports=w),exports._=w):n._=w,w.VERSION="1.4.3";var A=w.each=w.forEach=function(n,t,e){if(null!=n)if(s&&n.forEach===s)n.forEach(t,e);else if(n.length===+n.length){for(var u=0,i=n.length;i>u;u++)if(t.call(e,n[u],u,n)===r)return}else for(var a in n)if(w.has(n,a)&&t.call(e,n[a],a,n)===r)return};w.map=w.collect=function(n,t,r){var e=[];return null==n?e:p&&n.map===p?n.map(t,r):(A(n,function(n,u,i){e[e.length]=t.call(r,n,u,i)}),e)};var O="Reduce of empty array with no initial value";w.reduce=w.foldl=w.inject=function(n,t,r,e){var u=arguments.length>2;if(null==n&&(n=[]),v&&n.reduce===v)return e&&(t=w.bind(t,e)),u?n.reduce(t,r):n.reduce(t);if(A(n,function(n,i,a){u?r=t.call(e,r,n,i,a):(r=n,u=!0)}),!u)throw new TypeError(O);return r},w.reduceRight=w.foldr=function(n,t,r,e){var u=arguments.length>2;if(null==n&&(n=[]),h&&n.reduceRight===h)return e&&(t=w.bind(t,e)),u?n.reduceRight(t,r):n.reduceRight(t);var i=n.length;if(i!==+i){var a=w.keys(n);i=a.length}if(A(n,function(o,c,l){c=a?a[--i]:--i,u?r=t.call(e,r,n[c],c,l):(r=n[c],u=!0)}),!u)throw new TypeError(O);return r},w.find=w.detect=function(n,t,r){var e;return E(n,function(n,u,i){return t.call(r,n,u,i)?(e=n,!0):void 0}),e},w.filter=w.select=function(n,t,r){var e=[];return null==n?e:g&&n.filter===g?n.filter(t,r):(A(n,function(n,u,i){t.call(r,n,u,i)&&(e[e.length]=n)}),e)},w.reject=function(n,t,r){return w.filter(n,function(n,e,u){return!t.call(r,n,e,u)},r)},w.every=w.all=function(n,t,e){t||(t=w.identity);var u=!0;return null==n?u:d&&n.every===d?n.every(t,e):(A(n,function(n,i,a){return(u=u&&t.call(e,n,i,a))?void 0:r}),!!u)};var E=w.some=w.any=function(n,t,e){t||(t=w.identity);var u=!1;return null==n?u:m&&n.some===m?n.some(t,e):(A(n,function(n,i,a){return u||(u=t.call(e,n,i,a))?r:void 0}),!!u)};w.contains=w.include=function(n,t){return null==n?!1:y&&n.indexOf===y?-1!=n.indexOf(t):E(n,function(n){return n===t})},w.invoke=function(n,t){var r=o.call(arguments,2);return w.map(n,function(n){return(w.isFunction(t)?t:n[t]).apply(n,r)})},w.pluck=function(n,t){return w.map(n,function(n){return n[t]})},w.where=function(n,t){return w.isEmpty(t)?[]:w.filter(n,function(n){for(var r in t)if(t[r]!==n[r])return!1;return!0})},w.max=function(n,t,r){if(!t&&w.isArray(n)&&n[0]===+n[0]&&65535>n.length)return Math.max.apply(Math,n);if(!t&&w.isEmpty(n))return-1/0;var e={computed:-1/0,value:-1/0};return A(n,function(n,u,i){var a=t?t.call(r,n,u,i):n;a>=e.computed&&(e={value:n,computed:a})}),e.value},w.min=function(n,t,r){if(!t&&w.isArray(n)&&n[0]===+n[0]&&65535>n.length)return Math.min.apply(Math,n);if(!t&&w.isEmpty(n))return 1/0;var e={computed:1/0,value:1/0};return A(n,function(n,u,i){var a=t?t.call(r,n,u,i):n;e.computed>a&&(e={value:n,computed:a})}),e.value},w.shuffle=function(n){var t,r=0,e=[];return A(n,function(n){t=w.random(r++),e[r-1]=e[t],e[t]=n}),e};var F=function(n){return w.isFunction(n)?n:function(t){return t[n]}};w.sortBy=function(n,t,r){var e=F(t);return w.pluck(w.map(n,function(n,t,u){return{value:n,index:t,criteria:e.call(r,n,t,u)}}).sort(function(n,t){var r=n.criteria,e=t.criteria;if(r!==e){if(r>e||void 0===r)return 1;if(e>r||void 0===e)return-1}return n.index<t.index?-1:1}),"value")};var k=function(n,t,r,e){var u={},i=F(t||w.identity);return A(n,function(t,a){var o=i.call(r,t,a,n);e(u,o,t)}),u};w.groupBy=function(n,t,r){return k(n,t,r,function(n,t,r){(w.has(n,t)?n[t]:n[t]=[]).push(r)})},w.countBy=function(n,t,r){return k(n,t,r,function(n,t){w.has(n,t)||(n[t]=0),n[t]++})},w.sortedIndex=function(n,t,r,e){r=null==r?w.identity:F(r);for(var u=r.call(e,t),i=0,a=n.length;a>i;){var o=i+a>>>1;u>r.call(e,n[o])?i=o+1:a=o}return i},w.toArray=function(n){return n?w.isArray(n)?o.call(n):n.length===+n.length?w.map(n,w.identity):w.values(n):[]},w.size=function(n){return null==n?0:n.length===+n.length?n.length:w.keys(n).length},w.first=w.head=w.take=function(n,t,r){return null==n?void 0:null==t||r?n[0]:o.call(n,0,t)},w.initial=function(n,t,r){return o.call(n,0,n.length-(null==t||r?1:t))},w.last=function(n,t,r){return null==n?void 0:null==t||r?n[n.length-1]:o.call(n,Math.max(n.length-t,0))},w.rest=w.tail=w.drop=function(n,t,r){return o.call(n,null==t||r?1:t)},w.compact=function(n){return w.filter(n,w.identity)};var R=function(n,t,r){return A(n,function(n){w.isArray(n)?t?a.apply(r,n):R(n,t,r):r.push(n)}),r};w.flatten=function(n,t){return R(n,t,[])},w.without=function(n){return w.difference(n,o.call(arguments,1))},w.uniq=w.unique=function(n,t,r,e){w.isFunction(t)&&(e=r,r=t,t=!1);var u=r?w.map(n,r,e):n,i=[],a=[];return A(u,function(r,e){(t?e&&a[a.length-1]===r:w.contains(a,r))||(a.push(r),i.push(n[e]))}),i},w.union=function(){return w.uniq(c.apply(e,arguments))},w.intersection=function(n){var t=o.call(arguments,1);return w.filter(w.uniq(n),function(n){return w.every(t,function(t){return w.indexOf(t,n)>=0})})},w.difference=function(n){var t=c.apply(e,o.call(arguments,1));return w.filter(n,function(n){return!w.contains(t,n)})},w.zip=function(){for(var n=o.call(arguments),t=w.max(w.pluck(n,"length")),r=Array(t),e=0;t>e;e++)r[e]=w.pluck(n,""+e);return r},w.object=function(n,t){if(null==n)return{};for(var r={},e=0,u=n.length;u>e;e++)t?r[n[e]]=t[e]:r[n[e][0]]=n[e][1];return r},w.indexOf=function(n,t,r){if(null==n)return-1;var e=0,u=n.length;if(r){if("number"!=typeof r)return e=w.sortedIndex(n,t),n[e]===t?e:-1;e=0>r?Math.max(0,u+r):r}if(y&&n.indexOf===y)return n.indexOf(t,r);for(;u>e;e++)if(n[e]===t)return e;return-1},w.lastIndexOf=function(n,t,r){if(null==n)return-1;var e=null!=r;if(b&&n.lastIndexOf===b)return e?n.lastIndexOf(t,r):n.lastIndexOf(t);for(var u=e?r:n.length;u--;)if(n[u]===t)return u;return-1},w.range=function(n,t,r){1>=arguments.length&&(t=n||0,n=0),r=arguments[2]||1;for(var e=Math.max(Math.ceil((t-n)/r),0),u=0,i=Array(e);e>u;)i[u++]=n,n+=r;return i};var I=function(){};w.bind=function(n,t){var r,e;if(n.bind===j&&j)return j.apply(n,o.call(arguments,1));if(!w.isFunction(n))throw new TypeError;return r=o.call(arguments,2),e=function(){if(!(this instanceof e))return n.apply(t,r.concat(o.call(arguments)));I.prototype=n.prototype;var u=new I;I.prototype=null;var i=n.apply(u,r.concat(o.call(arguments)));return Object(i)===i?i:u}},w.bindAll=function(n){var t=o.call(arguments,1);return 0==t.length&&(t=w.functions(n)),A(t,function(t){n[t]=w.bind(n[t],n)}),n},w.memoize=function(n,t){var r={};return t||(t=w.identity),function(){var e=t.apply(this,arguments);return w.has(r,e)?r[e]:r[e]=n.apply(this,arguments)}},w.delay=function(n,t){var r=o.call(arguments,2);return setTimeout(function(){return n.apply(null,r)},t)},w.defer=function(n){return w.delay.apply(w,[n,1].concat(o.call(arguments,1)))},w.throttle=function(n,t){var r,e,u,i,a=0,o=function(){a=new Date,u=null,i=n.apply(r,e)};return function(){var c=new Date,l=t-(c-a);return r=this,e=arguments,0>=l?(clearTimeout(u),u=null,a=c,i=n.apply(r,e)):u||(u=setTimeout(o,l)),i}},w.debounce=function(n,t,r){var e,u;return function(){var i=this,a=arguments,o=function(){e=null,r||(u=n.apply(i,a))},c=r&&!e;return clearTimeout(e),e=setTimeout(o,t),c&&(u=n.apply(i,a)),u}},w.once=function(n){var t,r=!1;return function(){return r?t:(r=!0,t=n.apply(this,arguments),n=null,t)}},w.wrap=function(n,t){return function(){var r=[n];return a.apply(r,arguments),t.apply(this,r)}},w.compose=function(){var n=arguments;return function(){for(var t=arguments,r=n.length-1;r>=0;r--)t=[n[r].apply(this,t)];return t[0]}},w.after=function(n,t){return 0>=n?t():function(){return 1>--n?t.apply(this,arguments):void 0}},w.keys=_||function(n){if(n!==Object(n))throw new TypeError("Invalid object");var t=[];for(var r in n)w.has(n,r)&&(t[t.length]=r);return t},w.values=function(n){var t=[];for(var r in n)w.has(n,r)&&t.push(n[r]);return t},w.pairs=function(n){var t=[];for(var r in n)w.has(n,r)&&t.push([r,n[r]]);return t},w.invert=function(n){var t={};for(var r in n)w.has(n,r)&&(t[n[r]]=r);return t},w.functions=w.methods=function(n){var t=[];for(var r in n)w.isFunction(n[r])&&t.push(r);return t.sort()},w.extend=function(n){return A(o.call(arguments,1),function(t){if(t)for(var r in t)n[r]=t[r]}),n},w.pick=function(n){var t={},r=c.apply(e,o.call(arguments,1));return A(r,function(r){r in n&&(t[r]=n[r])}),t},w.omit=function(n){var t={},r=c.apply(e,o.call(arguments,1));for(var u in n)w.contains(r,u)||(t[u]=n[u]);return t},w.defaults=function(n){return A(o.call(arguments,1),function(t){if(t)for(var r in t)null==n[r]&&(n[r]=t[r])}),n},w.clone=function(n){return w.isObject(n)?w.isArray(n)?n.slice():w.extend({},n):n},w.tap=function(n,t){return t(n),n};var S=function(n,t,r,e){if(n===t)return 0!==n||1/n==1/t;if(null==n||null==t)return n===t;n instanceof w&&(n=n._wrapped),t instanceof w&&(t=t._wrapped);var u=l.call(n);if(u!=l.call(t))return!1;switch(u){case"[object String]":return n==t+"";case"[object Number]":return n!=+n?t!=+t:0==n?1/n==1/t:n==+t;case"[object Date]":case"[object Boolean]":return+n==+t;case"[object RegExp]":return n.source==t.source&&n.global==t.global&&n.multiline==t.multiline&&n.ignoreCase==t.ignoreCase}if("object"!=typeof n||"object"!=typeof t)return!1;for(var i=r.length;i--;)if(r[i]==n)return e[i]==t;r.push(n),e.push(t);var a=0,o=!0;if("[object Array]"==u){if(a=n.length,o=a==t.length)for(;a--&&(o=S(n[a],t[a],r,e)););}else{var c=n.constructor,f=t.constructor;if(c!==f&&!(w.isFunction(c)&&c instanceof c&&w.isFunction(f)&&f instanceof f))return!1;for(var s in n)if(w.has(n,s)&&(a++,!(o=w.has(t,s)&&S(n[s],t[s],r,e))))break;if(o){for(s in t)if(w.has(t,s)&&!a--)break;o=!a}}return r.pop(),e.pop(),o};w.isEqual=function(n,t){return S(n,t,[],[])},w.isEmpty=function(n){if(null==n)return!0;if(w.isArray(n)||w.isString(n))return 0===n.length;for(var t in n)if(w.has(n,t))return!1;return!0},w.isElement=function(n){return!(!n||1!==n.nodeType)},w.isArray=x||function(n){return"[object Array]"==l.call(n)},w.isObject=function(n){return n===Object(n)},A(["Arguments","Function","String","Number","Date","RegExp"],function(n){w["is"+n]=function(t){return l.call(t)=="[object "+n+"]"}}),w.isArguments(arguments)||(w.isArguments=function(n){return!(!n||!w.has(n,"callee"))}),w.isFunction=function(n){return"function"==typeof n},w.isFinite=function(n){return isFinite(n)&&!isNaN(parseFloat(n))},w.isNaN=function(n){return w.isNumber(n)&&n!=+n},w.isBoolean=function(n){return n===!0||n===!1||"[object Boolean]"==l.call(n)},w.isNull=function(n){return null===n},w.isUndefined=function(n){return void 0===n},w.has=function(n,t){return f.call(n,t)},w.noConflict=function(){return n._=t,this},w.identity=function(n){return n},w.times=function(n,t,r){for(var e=Array(n),u=0;n>u;u++)e[u]=t.call(r,u);return e},w.random=function(n,t){return null==t&&(t=n,n=0),n+(0|Math.random()*(t-n+1))};var T={escape:{"&":"&amp;","<":"&lt;",">":"&gt;",'"':"&quot;","'":"&#x27;","/":"&#x2F;"}};T.unescape=w.invert(T.escape);var M={escape:RegExp("["+w.keys(T.escape).join("")+"]","g"),unescape:RegExp("("+w.keys(T.unescape).join("|")+")","g")};w.each(["escape","unescape"],function(n){w[n]=function(t){return null==t?"":(""+t).replace(M[n],function(t){return T[n][t]})}}),w.result=function(n,t){if(null==n)return null;var r=n[t];return w.isFunction(r)?r.call(n):r},w.mixin=function(n){A(w.functions(n),function(t){var r=w[t]=n[t];w.prototype[t]=function(){var n=[this._wrapped];return a.apply(n,arguments),z.call(this,r.apply(w,n))}})};var N=0;w.uniqueId=function(n){var t=""+ ++N;return n?n+t:t},w.templateSettings={evaluate:/<%([\s\S]+?)%>/g,interpolate:/<%=([\s\S]+?)%>/g,escape:/<%-([\s\S]+?)%>/g};var q=/(.)^/,B={"'":"'","\\":"\\","\r":"r","\n":"n","	":"t","\u2028":"u2028","\u2029":"u2029"},D=/\\|'|\r|\n|\t|\u2028|\u2029/g;w.template=function(n,t,r){r=w.defaults({},r,w.templateSettings);var e=RegExp([(r.escape||q).source,(r.interpolate||q).source,(r.evaluate||q).source].join("|")+"|$","g"),u=0,i="__p+='";n.replace(e,function(t,r,e,a,o){return i+=n.slice(u,o).replace(D,function(n){return"\\"+B[n]}),r&&(i+="'+\n((__t=("+r+"))==null?'':_.escape(__t))+\n'"),e&&(i+="'+\n((__t=("+e+"))==null?'':__t)+\n'"),a&&(i+="';\n"+a+"\n__p+='"),u=o+t.length,t}),i+="';\n",r.variable||(i="with(obj||{}){\n"+i+"}\n"),i="var __t,__p='',__j=Array.prototype.join,print=function(){__p+=__j.call(arguments,'');};\n"+i+"return __p;\n";try{var a=Function(r.variable||"obj","_",i)}catch(o){throw o.source=i,o}if(t)return a(t,w);var c=function(n){return a.call(this,n,w)};return c.source="function("+(r.variable||"obj")+"){\n"+i+"}",c},w.chain=function(n){return w(n).chain()};var z=function(n){return this._chain?w(n).chain():n};w.mixin(w),A(["pop","push","reverse","shift","sort","splice","unshift"],function(n){var t=e[n];w.prototype[n]=function(){var r=this._wrapped;return t.apply(r,arguments),"shift"!=n&&"splice"!=n||0!==r.length||delete r[0],z.call(this,r)}}),A(["concat","join","slice"],function(n){var t=e[n];w.prototype[n]=function(){return z.call(this,t.apply(this._wrapped,arguments))}}),w.extend(w.prototype,{chain:function(){return this._chain=!0,this},value:function(){return this._wrapped}})}).call(this);
// seedrandom.js version 2.1.
// Author: David Bau
// Date: 2013 Mar 16
//
// Defines a method Math.seedrandom() that, when called, substitutes
// an explicitly seeded RC4-based algorithm for Math.random().  Also
// supports automatic seeding from local or network sources of entropy.
//
// http://davidbau.com/encode/seedrandom.js
// http://davidbau.com/encode/seedrandom-min.js
//
// Usage:
//
//   <script src=http://davidbau.com/encode/seedrandom-min.js></script>
//
//   Math.seedrandom('yay.');  Sets Math.random to a function that is
//                             initialized using the given explicit seed.
//
//   Math.seedrandom();        Sets Math.random to a function that is
//                             seeded using the current time, dom state,
//                             and other accumulated local entropy.
//                             The generated seed string is returned.
//
//   Math.seedrandom('yowza.', true);
//                             Seeds using the given explicit seed mixed
//                             together with accumulated entropy.
//
//   <script src="https://jsonlib.appspot.com/urandom?callback=Math.seedrandom">
//   </script>                 Seeds using urandom bits from a server.
//
// More advanced examples:
//
//   Math.seedrandom("hello.");           // Use "hello." as the seed.
//   document.write(Math.random());       // Always 0.9282578795792454
//   document.write(Math.random());       // Always 0.3752569768646784
//   var rng1 = Math.random;              // Remember the current prng.
//
//   var autoseed = Math.seedrandom();    // New prng with an automatic seed.
//   document.write(Math.random());       // Pretty much unpredictable x.
//
//   Math.random = rng1;                  // Continue "hello." prng sequence.
//   document.write(Math.random());       // Always 0.7316977468919549
//
//   Math.seedrandom(autoseed);           // Restart at the previous seed.
//   document.write(Math.random());       // Repeat the 'unpredictable' x.
//
//   function reseed(event, count) {      // Define a custom entropy collector.
//     var t = [];
//     function w(e) {
//       t.push([e.pageX, e.pageY, +new Date]);
//       if (t.length < count) { return; }
//       document.removeEventListener(event, w);
//       Math.seedrandom(t, true);        // Mix in any previous entropy.
//     }
//     document.addEventListener(event, w);
//   }
//   reseed('mousemove', 100);            // Reseed after 100 mouse moves.
//
// Version notes:
//
// The random number sequence is the same as version 1.0 for string seeds.
// Version 2.0 changed the sequence for non-string seeds.
// Version 2.1 speeds seeding and uses window.crypto to autoseed if present.
//
// The standard ARC4 key scheduler cycles short keys, which means that
// seedrandom('ab') is equivalent to seedrandom('abab') and 'ababab'.
// Therefore it is a good idea to add a terminator to avoid trivial
// equivalences on short string seeds, e.g., Math.seedrandom(str + '\0').
// Starting with version 2.0, a terminator is added automatically for
// non-string seeds, so seeding with the number 111 is the same as seeding
// with '111\0'.
//
// When seedrandom() is called with zero args, it uses a seed
// drawn from the browser crypto object if present.  If there is no
// crypto support, seedrandom() uses the current time, the native rng,
// and a walk of several DOM objects to collect a few bits of entropy.
//
// Each time the one- or two-argument forms of seedrandom are called,
// entropy from the passed seed is accumulated in a pool to help generate
// future seeds for the zero- and two-argument forms of seedrandom.
//
// On speed - This javascript implementation of Math.random() is about
// 3-10x slower than the built-in Math.random() because it is not native
// code, but that is typically fast enough.  Some details (timings on
// Chrome 25 on a 2010 vintage macbook):
//
// seeded Math.random()          - avg less than 0.0002 milliseconds per call
// seedrandom('explicit.')       - avg less than 0.2 milliseconds per call
// seedrandom('explicit.', true) - avg less than 0.2 milliseconds per call
// seedrandom() with crypto      - avg less than 0.2 milliseconds per call
// seedrandom() without crypto   - avg about 12 milliseconds per call
//
// On a 2012 windows 7 1.5ghz i5 laptop, Chrome, Firefox 19, IE 10, and
// Opera have similarly fast timings.  Slowest numbers are on Opera, with
// about 0.0005 milliseconds per seeded Math.random() and 15 milliseconds
// for autoseeding.
//
// LICENSE (BSD):
//
// Copyright 2013 David Bau, all rights reserved.
//
// Redistribution and use in source and binary forms, with or without
// modification, are permitted provided that the following conditions are met:
//
//   1. Redistributions of source code must retain the above copyright
//      notice, this list of conditions and the following disclaimer.
//
//   2. Redistributions in binary form must reproduce the above copyright
//      notice, this list of conditions and the following disclaimer in the
//      documentation and/or other materials provided with the distribution.
//
//   3. Neither the name of this module nor the names of its contributors may
//      be used to endorse or promote products derived from this software
//      without specific prior written permission.
//
// THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS
// "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT
// LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR
// A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT
// OWNER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL,
// SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT
// LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE,
// DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY
// THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
// (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
// OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
//
/**
 * All code is in an anonymous closure to keep the global namespace clean.
 */
(function (
    global, pool, math, width, chunks, digits) {

//
// The following constants are related to IEEE 754 limits.
//
var startdenom = math.pow(width, chunks),
    significance = math.pow(2, digits),
    overflow = significance * 2,
    mask = width - 1;

//
// seedrandom()
// This is the seedrandom function described above.
//
math['seedrandom'] = function(seed, use_entropy) {
  var key = [];

  // Flatten the seed string or build one from local entropy if needed.
  var shortseed = mixkey(flatten(
    use_entropy ? [seed, tostring(pool)] :
    0 in arguments ? seed : autoseed(), 3), key);

  // Use the seed to initialize an ARC4 generator.
  var arc4 = new ARC4(key);

  // Mix the randomness into accumulated entropy.
  mixkey(tostring(arc4.S), pool);

  // Override Math.random

  // This function returns a random double in [0, 1) that contains
  // randomness in every bit of the mantissa of the IEEE 754 value.

  math['random'] = function() {         // Closure to return a random double:
    var n = arc4.g(chunks),             // Start with a numerator n < 2 ^ 48
        d = startdenom,                 //   and denominator d = 2 ^ 48.
        x = 0;                          //   and no 'extra last byte'.
    while (n < significance) {          // Fill up all significant digits by
      n = (n + x) * width;              //   shifting numerator and
      d *= width;                       //   denominator and generating a
      x = arc4.g(1);                    //   new least-significant-byte.
    }
    while (n >= overflow) {             // To avoid rounding up, before adding
      n /= 2;                           //   last byte, shift everything
      d /= 2;                           //   right using integer math until
      x >>>= 1;                         //   we have exactly the desired bits.
    }
    return (n + x) / d;                 // Form the number within [0, 1).
  };

  // Return the seed that was used
  return shortseed;
};

//
// ARC4
//
// An ARC4 implementation.  The constructor takes a key in the form of
// an array of at most (width) integers that should be 0 <= x < (width).
//
// The g(count) method returns a pseudorandom integer that concatenates
// the next (count) outputs from ARC4.  Its return value is a number x
// that is in the range 0 <= x < (width ^ count).
//
/** @constructor */
function ARC4(key) {
  var t, keylen = key.length,
      me = this, i = 0, j = me.i = me.j = 0, s = me.S = [];

  // The empty key [] is treated as [0].
  if (!keylen) { key = [keylen++]; }

  // Set up S using the standard key scheduling algorithm.
  while (i < width) {
    s[i] = i++;
  }
  for (i = 0; i < width; i++) {
    s[i] = s[j = mask & (j + key[i % keylen] + (t = s[i]))];
    s[j] = t;
  }

  // The "g" method returns the next (count) outputs as one number.
  (me.g = function(count) {
    // Using instance members instead of closure state nearly doubles speed.
    var t, r = 0,
        i = me.i, j = me.j, s = me.S;
    while (count--) {
      t = s[i = mask & (i + 1)];
      r = r * width + s[mask & ((s[i] = s[j = mask & (j + t)]) + (s[j] = t))];
    }
    me.i = i; me.j = j;
    return r;
    // For robust unpredictability discard an initial batch of values.
    // See http://www.rsa.com/rsalabs/node.asp?id=2009
  })(width);
}

//
// flatten()
// Converts an object tree to nested arrays of strings.
//
function flatten(obj, depth) {
  var result = [], typ = (typeof obj)[0], prop;
  if (depth && typ == 'o') {
    for (prop in obj) {
      if (obj.hasOwnProperty(prop)) {
        try { result.push(flatten(obj[prop], depth - 1)); } catch (e) {}
      }
    }
  }
  return (result.length ? result : typ == 's' ? obj : obj + '\0');
}

//
// mixkey()
// Mixes a string seed into a key that is an array of integers, and
// returns a shortened string seed that is equivalent to the result key.
//
function mixkey(seed, key) {
  var stringseed = seed + '', smear, j = 0;
  while (j < stringseed.length) {
    key[mask & j] =
      mask & ((smear ^= key[mask & j] * 19) + stringseed.charCodeAt(j++));
  }
  return tostring(key);
}

//
// autoseed()
// Returns an object for autoseeding, using window.crypto if available.
//
/** @param {Uint8Array=} seed */
function autoseed(seed) {
  try {
    global.crypto.getRandomValues(seed = new Uint8Array(width));
    return tostring(seed);
  } catch (e) {
    return [+new Date, global.document, global.history,
            global.navigator, global.screen, tostring(pool)];
  }
}

//
// tostring()
// Converts an array of charcodes to a string
//
function tostring(a) {
  return String.fromCharCode.apply(0, a);
}

//
// When seedrandom.js is loaded, we immediately mix a few bits
// from the built-in RNG into the entropy pool.  Because we do
// not want to intefere with determinstic PRNG state later,
// seedrandom will not call math.random on its own again after
// initialization.
//
mixkey(math.random(), pool);

// End anonymous scope, and pass initial values.
})(
  this,   // global window object
  [],     // pool: entropy pool starts empty
  Math,   // math: package containing random, pow, and seedrandom
  256,    // width: each RC4 output is 0 <= x < 256
  6,      // chunks: at least six RC4 outputs for each double
  52      // digits: there are 52 significant digits in a double
);

var gg = window.gg = {'wf':{}};

(function() {
  var events, exports, findGood, findGoodAttr, fromSpec, _,
    __slice = [].slice,
    __indexOf = [].indexOf || function(item) { for (var i = 0, l = this.length; i < l; i++) { if (i in this && this[i] === item) return i; } return -1; },
    __hasProp = {}.hasOwnProperty,
    __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

  _ = require('underscore');

  this.cross = function(arr1, arr2) {
    var ret;
    ret = [];
    _.map(arr1, function(a1, i) {
      return _.map(arr2, function(a2, j) {
        return ret.push({
          x: a1,
          y: a2,
          i: i,
          j: j
        });
      });
    });
    return ret;
  };

  this.attributeValue = function() {
    var aes, args, defaultVal, layer;
    layer = arguments[0], aes = arguments[1], defaultVal = arguments[2], args = 4 <= arguments.length ? __slice.call(arguments, 3) : [];
    if (aes in layer.mappings) {
      return function(d) {
        return layer.scaledValue.apply(layer, [d, aes].concat(__slice.call(args)));
      };
    } else {
      return function(d) {
        return defaultVal;
      };
    }
  };

  this.attrVal = this.attributeValue;

  this.groupData = function(data, groupBy) {
    if (!(groupBy != null)) {
      return [data];
    } else {
      return _.groupBy(data, groupBy);
    }
  };

  this.splitByGroups = function(data, group, variable) {
    var groups,
      _this = this;
    groups = {};
    if (group) {
      _.each(data, function(d) {
        var g;
        g = d[group];
        if (!(groups[g] != null)) {
          groups[g] = [];
        }
        return groups[g].push(d[variable]);
      });
    } else {
      groups['data'] = _.pluck(data, variable);
    }
    return groups;
  };

  gg.Util = (function() {

    function Util() {}

    Util.sum = function(arr) {
      return _.reduce(arr, (function(a, b) {
        return a + b;
      }), 0);
    };

    Util.findGood = function(list) {
      var ret;
      ret = _.find(list, function(v) {
        return v !== null && (v != null);
      });
      if (typeof ret === "undefined") {
        if (list.length) {
          return _.last(list);
        } else {
          return void 0;
        }
      } else {
        return ret;
      }
    };

    Util.findGoodAttr = function(obj, attrs, defaultVal) {
      var attr;
      if (defaultVal == null) {
        defaultVal = null;
      }
      if (obj == null) {
        return defaultVal;
      }
      attr = _.find(attrs, function(attr) {
        return obj[attr] !== null && (obj[attr] != null);
      });
      if (typeof attr === "undefined") {
        return defaultVal;
      } else {
        return obj[attr];
      }
    };

    Util.isSubclass = function(instance, partype) {
      var c;
      c = instance;
      while (c != null) {
        if (c.constructor.name === partype.name) {
          return true;
        }
        if (c.constructor.__super__ == null) {
          return false;
        }
        c = c.constructor.__super__;
      }
    };

    Util._exSizeCache = {};

    Util._defaultWidth = 19.23076923076923;

    Util._defaultHeights = (function() {
      var defaultHeights, fontSize, idx, pixels, _i, _len, _ref;
      defaultHeights = {};
      pixels = [1, 4, 5, 6, 7, 9, 10, 12, 14, 15, 17, 18, 20, 22, 23, 24, 27, 28, 29, 31, 32, 33, 36, 37, 38, 40, 42, 42, 44, 45, 47, 49, 50, 52, 55, 55, 56, 59, 60, 61, 64, 65, 66, 68, 69, 70, 72, 74, 75];
      _ref = _.range(1, 50);
      for (idx = _i = 0, _len = _ref.length; _i < _len; idx = ++_i) {
        fontSize = _ref[idx];
        defaultHeights["" + fontSize + "pt"] = pixels[idx];
      }
      return defaultHeights;
    })();

    Util.exDefault = function(fontSize) {
      return {
        width: gg.Util._defaultWidth,
        w: gg.Util._defaultWidth,
        height: gg.Util._defaultHeights[fontSize] || 18,
        h: gg.Util._defaultHeights[fontSize] || 18
      };
    };

    Util.textSize = function(text, opts) {
      var body, css, defaults, div, height, ret, width;
      try {
        body = document.getElementsByTagName("body")[0];
        div = document.createElement("span");
        div.textContent = text;
        css = {
          opacity: 0,
          "font-size": "12pt",
          "font-family": "arial",
          padding: 0,
          margin: 0
        };
        _.extend(css, opts);
        _.each(css, function(v, k) {
          return div.style[k] = v;
        });
        body.appendChild(div);
        width = $(div).width();
        height = $(div).height();
        body.removeChild(div);
        if (_.any([width, height], (function(v) {
          return _.isNaN(v) || v === 0;
        }))) {
          throw Error("exSize: width(" + width + "), height(" + height + ")");
        }
        ret = {
          width: width,
          height: height,
          w: width,
          h: height
        };
        return ret;
      } catch (error) {
        console.log("textSize returning defaults because of: " + error);
        defaults = gg.Util.exDefault(opts["font-size"]);
        defaults.width = defaults.w = defaults.width * text.length;
        return defaults;
      }
    };

    Util.exSize = function(opts) {
      var alphas, optsJson, ret;
      optsJson = JSON.stringify(opts);
      if (optsJson in gg.Util._exSizeCache) {
        return gg.Util._exSizeCache[optsJson];
      } else {
        alphas = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ";
        ret = gg.Util.textSize(alphas, opts);
        ret.width = ret.w = ret.w / alphas.length;
        gg.Util._exSizeCache[optsJson] = ret;
        return ret;
      }
    };

    Util.larger = function(div, size) {
      var sh, sw, _ref;
      div.style["font-size"] = "" + size + "pt";
      _ref = [div[0].scrollWidth, div[0].scrollHeight], sw = _ref[0], sh = _ref[1];
      return sw > div.clientWidth || sh > div.clientHeight;
    };

    Util.fontSize = function(text, width, height, font) {
      var body, div, n, size;
      if (font == null) {
        font = "arial";
      }
      body = document.getElementsByTagName("body")[0];
      div = document.createElement("div");
      _.extend(div.style, {
        width: width,
        height: height,
        position: "absolute",
        color: "white",
        opacity: 0,
        top: 0,
        left: 0,
        "font-family": font
      });
      div.textContent = text;
      body.appendChild(div);
      size = 100;
      n = 0;
      while (n < 100) {
        n += 1;
        if (gg.Util.larger(div, size)) {
          if (size > 50) {
            size /= 2;
          } else {
            size -= 1;
          }
        } else {
          if (gg.Util.larger(div, size + 1)) {
            break;
          }
          size += 5;
        }
      }
      body.removeChild(div);
      return size;
    };

    Util.subSvg = function(svg, opts, tag) {
      var el, left, top;
      if (tag == null) {
        tag = "g";
      }
      el = svg.append(tag);
      left = findGood([opts.left, 0]);
      top = findGood([opts.top, 0]);
      el.attr("transform", "translate(" + left + "," + top + ")");
      _.each(opts, function(val, attr) {
        if (attr !== 'left' && attr !== 'top') {
          return el.attr(attr, val);
        }
      });
      return el;
    };

    Util.repeat = function(n, val) {
      return _.times(n, (function() {
        return val;
      }));
    };

    return Util;

  })();

  findGood = gg.Util.findGood;

  findGoodAttr = gg.Util.findGoodAttr;

  _.mixin({
    sum: gg.Util.sum,
    findGood: gg.Util.findGood,
    findGoodAttr: gg.Util.findGoodAttr,
    isSubclass: gg.Util.isSubclass,
    cross: this.cross,
    textSize: gg.Util.textSize,
    exSize: gg.Util.exSize,
    fontsize: gg.Util.fontSize,
    subSvg: gg.Util.subSvg,
    repeat: gg.Util.repeat
  });

  gg.UniqQueue = (function() {

    function UniqQueue(args) {
      var _this = this;
      if (args == null) {
        args = [];
      }
      this.list = [];
      this.id2item = {};
      _.each(args, function(item) {
        return _this.push(item);
      });
    }

    UniqQueue.prototype.push = function(item) {
      var key;
      key = this.key(item);
      if (!(key in this.id2item)) {
        this.list.push(item);
        this.id2item[key] = true;
      }
      return this;
    };

    UniqQueue.prototype.pop = function() {
      var item, key;
      if (this.list.length === 0) {
        throw Error("list is empty");
      }
      item = this.list.shift();
      key = this.key(item);
      delete this.id2item[key];
      return item;
    };

    UniqQueue.prototype.length = function() {
      return this.list.length;
    };

    UniqQueue.prototype.empty = function() {
      return this.length() === 0;
    };

    UniqQueue.prototype.key = function(item) {
      if (item != null) {
        if (_.isObject(item)) {
          if ('id' in item) {
            return item.id;
          } else {
            return item.toString();
          }
        } else {
          return "" + item;
        }
      } else {
        return null;
      }
    };

    return UniqQueue;

  })();

  gg.Scale = (function() {

    Scale.aliases = "scale";

    Scale.prototype._id = 0;

    function Scale(spec) {
      this.spec = spec != null ? spec : {};
      this.domainSet = false;
      this.rangeSet = false;
      this.domainUpdated = false;
      this.id = gg.Scale.prototype._id += 1;
      this.center = null;
      this.parseSpec();
    }

    Scale.prototype.parseSpec = function() {
      var domain, _ref;
      this.aes = this.spec.aes;
      if (this.aes == null) {
        throw Error("Scale.fromSpec needs an aesthetic: " + (JSON.stringify(this.spec)));
      }
      if ((this.spec.range != null) && (_ref = this.aes, __indexOf.call(gg.Scale.xys, _ref) < 0)) {
        this.range(this.spec.range);
        this.rangeSet = true;
      }
      domain = findGoodAttr(this.spec, ['domain', 'limit', 'limits', 'lims', 'lim'], null);
      if (domain != null) {
        this.domain(domain);
        this.domainSet = true;
      }
      return this.center = findGood([this.spec.center, null]);
    };

    Scale.xs = ['x', 'x0', 'x1'];

    Scale.ys = ['y', 'y0', 'y1'];

    Scale.xys = Scale.xs.concat(Scale.ys);

    Scale.legendAess = ['size', 'group', 'color'];

    Scale.klasses = function() {
      var alias, klass, klasses, ret, _i, _j, _len, _len1, _ref;
      klasses = [gg.IdentityScale, gg.LinearScale, gg.TimeScale, gg.LogScale, gg.CategoricalScale, gg.ColorScale, gg.ShapeScale];
      ret = {};
      for (_i = 0, _len = klasses.length; _i < _len; _i++) {
        klass = klasses[_i];
        _ref = _.flatten([klass.aliases]);
        for (_j = 0, _len1 = _ref.length; _j < _len1; _j++) {
          alias = _ref[_j];
          ret[alias] = klass;
        }
      }
      return ret;
    };

    Scale.fromSpec = function(spec) {
      var aesAttrs, klass, klasses, s, type;
      if (spec == null) {
        spec = {};
      }
      type = spec.type;
      klasses = gg.Scale.klasses();
      klass = klasses[type] || gg.IdentityScale;
      aesAttrs = ['aesthetics', 'aesthetic', 'aes', 'var'];
      spec.aes = findGoodAttr(spec, aesAttrs, null);
      s = new klass(spec);
      return s;
    };

    Scale.defaultFor = function(aes) {
      var klass, s;
      klass = {
        x: gg.LinearScale,
        x0: gg.LinearScale,
        x1: gg.LinearScale,
        y: gg.LinearScale,
        y0: gg.LinearScale,
        y1: gg.LinearScale,
        color: gg.ColorScale,
        fill: gg.ColorScale,
        size: gg.LinearScale,
        text: gg.TextScale,
        shape: gg.ShapeScale
      }[aes] || gg.IdentityScale;
      s = new klass({
        aes: aes
      });
      return s;
    };

    Scale.prototype.clone = function() {
      var ret, spec;
      spec = _.clone(this.spec);
      spec.aes = this.aes;
      ret = gg.Scale.fromSpec(this.spec);
      if (this.d3Scale != null) {
        ret.d3Scale = this.d3Scale.copy();
      }
      return ret;
    };

    Scale.prototype.defaultDomain = function(col) {
      var extreme, interval;
      this.min = _.min(col);
      this.max = _.max(col);
      if (this.center != null) {
        extreme = Math.max(this.max - this.center, Math.abs(this.min - this.center));
        interval = [this.center - extreme, this.center + extreme];
      } else {
        interval = [this.min, this.max];
      }
      return interval;
    };

    Scale.prototype.mergeDomain = function(domain) {
      var md;
      md = this.domain();
      if (!this.domainSet) {
        if (this.domainUpdated && (md != null) && md.length === 2) {
          return this.domain([_.min([md[0], domain[0]]), _.max([md[1], domain[1]])]);
        } else {
          return this.domain(domain);
        }
      }
    };

    Scale.prototype.domain = function(interval) {
      if ((interval != null) && !this.domainSet) {
        this.domainUpdated = true;
        this.d3Scale.domain(interval);
      }
      return this.d3Scale.domain();
    };

    Scale.prototype.range = function(interval) {
      if ((interval != null) && !this.rangeSet) {
        this.d3Scale.range(interval);
      }
      return this.d3Scale.range();
    };

    Scale.prototype.d3 = function() {
      return this.d3Scale;
    };

    Scale.prototype.valid = function(v) {
      return true;
    };

    Scale.prototype.minDomain = function() {
      return this.domain()[0];
    };

    Scale.prototype.maxDomain = function() {
      return this.domain()[1];
    };

    Scale.prototype.minRange = function() {
      return this.range()[0];
    };

    Scale.prototype.maxRange = function() {
      return this.range()[1];
    };

    Scale.prototype.scale = function(v) {
      return this.d3Scale(v);
    };

    Scale.prototype.invert = function(v) {
      return this.d3Scale.invert(v);
    };

    return Scale;

  })();

  gg.IdentityScale = (function(_super) {

    __extends(IdentityScale, _super);

    IdentityScale.aliases = "identity";

    function IdentityScale() {
      this.d3Scale = d3.scale.linear();
      this.type = 'identity';
      IdentityScale.__super__.constructor.apply(this, arguments);
    }

    IdentityScale.prototype.scale = function(v) {
      return v;
    };

    IdentityScale.prototype.invert = function(v) {
      return v;
    };

    return IdentityScale;

  })(gg.Scale);

  gg.LinearScale = (function(_super) {

    __extends(LinearScale, _super);

    LinearScale.aliases = "linear";

    function LinearScale() {
      this.d3Scale = d3.scale.linear().clamp(true);
      this.type = 'continuous';
      LinearScale.__super__.constructor.apply(this, arguments);
    }

    return LinearScale;

  })(gg.Scale);

  gg.TimeScale = (function(_super) {

    __extends(TimeScale, _super);

    TimeScale.aliases = "time";

    function TimeScale() {
      this.d3Scale = d3.time.scale().clamp(true);
      this.type = 'time';
      TimeScale.__super__.constructor.apply(this, arguments);
    }

    return TimeScale;

  })(gg.Scale);

  gg.LogScale = (function(_super) {

    __extends(LogScale, _super);

    LogScale.aliases = "log";

    function LogScale() {
      this.d3Scale = d3.scale.log().clamp(true);
      this.type = 'continuous';
      LogScale.__super__.constructor.apply(this, arguments);
    }

    LogScale.prototype.valid = function(v) {
      return v > 0;
    };

    LogScale.prototype.defaultDomain = function(col) {
      var extreme, interval;
      col = _.filter(col, function(v) {
        return v > 0;
      });
      if (col.length === 0) {
        return [1, 10];
      }
      this.min = _.min(col);
      this.max = _.max(col);
      if (this.center != null) {
        extreme = Math.max(this.max - this.center, Math.abs(this.min - this.center));
        interval = [this.center - extreme, this.center + extreme];
      } else {
        interval = [this.min, this.max];
      }
      return interval;
    };

    LogScale.prototype.scale = function(v) {
      if (v === 0) {
        return -1;
      } else {
        return this.d3Scale(v);
      }
    };

    return LogScale;

  })(gg.Scale);

  gg.CategoricalScale = (function(_super) {

    __extends(CategoricalScale, _super);

    CategoricalScale.aliases = "categorical";

    function CategoricalScale(padding) {
      this.padding = padding != null ? padding : .05;
      this.type = 'ordinal';
      CategoricalScale.__super__.constructor.apply(this, arguments);
    }

    CategoricalScale.defaultDomain = function(col) {
      var vals;
      vals = _.uniq(_.flatten(col));
      vals.sort(function(a, b) {
        return a - b;
      });
      return vals;
    };

    CategoricalScale.prototype.clone = function() {
      var ret;
      ret = CategoricalScale.__super__.clone.apply(this, arguments);
      ret.invertScale = this.invertScale.copy();
      return ret;
    };

    CategoricalScale.prototype.defaultDomain = function(col) {
      return gg.CategoricalScale.defaultDomain(col);
    };

    CategoricalScale.prototype.mergeDomain = function(domain) {
      var newDomain;
      newDomain = _.uniq(_.union(domain, this.domain()));
      console.log("" + this.constructor.name + "-" + this.type + " merging " + newDomain);
      return this.domain(newDomain);
    };

    CategoricalScale.prototype.domain = function(interval) {
      if (interval != null) {
        this.invertScale.range(interval);
      }
      return CategoricalScale.__super__.domain.apply(this, arguments);
    };

    CategoricalScale.prototype.range = function(interval) {
      if ((interval != null) && !this.rangeSet) {
        this.d3Scale.rangeBands(interval, this.padding);
        this.invertScale.domain(this.d3Scale.range());
      }
      return this.d3Scale.range();
    };

    return CategoricalScale;

  })(gg.Scale);

  gg.ShapeScale = (function(_super) {

    __extends(ShapeScale, _super);

    ShapeScale.aliases = "shape";

    function ShapeScale(padding) {
      var customTypes;
      this.padding = padding != null ? padding : 1;
      customTypes = ['star', 'ex'];
      this.symbolTypes = d3.svg.symbolTypes.concat(customTypes);
      this.d3Scale = d3.scale.ordinal().range(this.symbolTypes);
      this.invertScale = d3.scale.ordinal().domain(this.d3Scale.range());
      this.symbScale = d3.svg.symbol();
      this.type = 'shape';
      ShapeScale.__super__.constructor.apply(this, arguments);
    }

    ShapeScale.prototype.range = function(interval) {};

    ShapeScale.prototype.scale = function() {
      var args, data, diag, r, size, tr, type, v;
      v = arguments[0], data = arguments[1], args = 3 <= arguments.length ? __slice.call(arguments, 2) : [];
      throw Error("shape scale not thought through yet");
      if ((args != null) && args.length) {
        size = args[0];
      }
      type = this.d3Scale(v);
      r = Math.sqrt(size / 5) / 2;
      diag = Math.sqrt(2) * r;
      switch (type) {
        case 'ex':
          return ("M" + (-diag) + "," + (-diag) + "L" + diag + "," + diag) + ("M" + diag + "," + (-diag) + "L" + (-diag) + "," + diag);
        case 'cross':
          return "M" + (-3 * r) + ",0H" + (3 * r) + "M0," + (3 * r) + "V" + (-3 * r);
        case 'star':
          tr = 3 * r;
          return ("M" + (-tr) + ",0H" + tr + "M0," + tr + "V" + (-tr)) + ("M" + (-tr) + "," + (-tr) + "L" + tr + "," + tr) + ("M" + tr + "," + (-tr) + "L" + (-tr) + "," + tr);
        default:
          return this.symbScale.size(size).type(this.d3Scale(v))();
      }
    };

    return ShapeScale;

  })(gg.CategoricalScale);

  gg.ColorScaleCont = (function(_super) {

    __extends(ColorScaleCont, _super);

    ColorScaleCont.aliases = "color_cont";

    function ColorScaleCont(spec) {
      this.spec = spec != null ? spec : {};
      this.d3Scale = d3.scale.linear().clamp(true);
      ColorScaleCont.__super__.constructor.apply(this, arguments);
    }

    ColorScaleCont.prototype.parseSpec = function() {
      ColorScaleCont.__super__.parseSpec.apply(this, arguments);
      this.startColor = this.spec.startColor || d3.rgb(255, 247, 251);
      this.endColor = this.spec.endColor || d3.rgb(2, 56, 88);
      return this.d3Scale.range([this.startColor, this.endColor]);
    };

    ColorScaleCont.prototype.range = function() {
      return this.d3Scale.range();
    };

    return ColorScaleCont;

  })(gg.Scale);

  gg.ColorScale = (function(_super) {

    __extends(ColorScale, _super);

    ColorScale.aliases = "color";

    function ColorScale(spec) {
      this.spec = spec != null ? spec : {};
      ColorScale.__super__.constructor.apply(this, arguments);
      this.d3Scale = d3.scale.category20();
      this.invertScale = d3.scale.ordinal();
      this.invertScale.domain(this.d3Scale.range()).range(this.d3Scale.domain());
      this.type = "color";
    }

    ColorScale.prototype.invert = function(v) {
      return this.invertScale(v);
    };

    return ColorScale;

  })(gg.CategoricalScale);

  gg.ColorScaleFuck = (function(_super) {

    __extends(ColorScaleFuck, _super);

    ColorScaleFuck.aliases = "color";

    function ColorScaleFuck(spec) {
      this.spec = spec != null ? spec : {};
      ColorScaleFuck.__super__.constructor.apply(this, arguments);
      this.isDiscrete = false;
      this.cScale = new gg.ColorScaleCont(this.spec);
      this.dScale = new gg.ColorScaleDisc(this.spec);
      this.type = 'color';
    }

    ColorScaleFuck.prototype.isNumeric = function(col) {
      return _.every(_.compact(col), _.isNumber);
    };

    ColorScaleFuck.prototype.myScale = function() {
      if (this.isDiscrete) {
        return this.dScale;
      } else {
        return this.cScale;
      }
    };

    ColorScaleFuck.prototype.d3 = function() {
      return this.myScale().d3();
    };

    ColorScaleFuck.prototype.invert = function(v) {
      return this.myScale().invert(v);
    };

    ColorScaleFuck.prototype.scale = function(v) {
      return this.myScale().scale(v);
    };

    ColorScaleFuck.prototype.domain = function(v) {
      return this.myScale().domain(v);
    };

    ColorScaleFuck.prototype.range = function(v) {
      return this.myScale().range(v);
    };

    ColorScaleFuck.prototype.minDomain = function() {
      return this.myScale().minDomain();
    };

    ColorScaleFuck.prototype.maxDomain = function() {
      return this.myScale().maxDomain();
    };

    ColorScaleFuck.prototype.minRange = function() {
      return this.myScale().minRange();
    };

    ColorScaleFuck.prototype.maxRange = function() {
      return this.myScale().maxRange();
    };

    ColorScaleFuck.prototype.clone = function() {
      var ret, spec;
      spec = _.clone(this.spec);
      ret = new gg.ColorScale(spec);
      ret.isDiscrete = this.isDiscrete;
      ret.cScale = this.cScale.clone();
      ret.dScale = this.dScale.clone();
      return ret;
    };

    ColorScaleFuck.prototype.mergeDomain = function(interval) {
      var domain, uniqs;
      console.log("scale.mergeDomain " + (this.isNumeric(interval)) + "  " + interval.length);
      uniqs = _.uniq(_.compact(interval));
      this.isDiscrete = !(this.isNumeric(uniqs) && uniqs.length > 20);
      domain = this.defaultDomain(interval);
      this.myScale().mergeDomain(domain);
      return this.domain();
    };

    ColorScaleFuck.prototype.defaultDomain = function(col) {
      return this.myScale().defaultDomain(col);
    };

    return ColorScaleFuck;

  })(gg.Scale);

  gg.TextScale = (function(_super) {

    __extends(TextScale, _super);

    TextScale.aliases = "text";

    function TextScale() {
      this.type = 'text';
      TextScale.__super__.constructor.apply(this, arguments);
    }

    TextScale.prototype.prepare = function(layer, newData, aes) {
      this.pattern = layer.mappings[aes];
      return this.data = newData;
    };

    TextScale.prototype.scale = function(v, data) {
      var format;
      format = function(match, key) {
        var it;
        it = data[key];
        if (typeof it === 'number') {
          it = it.toFixed(2);
        }
        return String(it);
      };
      return this.pattern.replace(/{(.*?)}/g, format);
    };

    TextScale.prototype.invert = function(v) {
      return null;
    };

    TextScale.prototype.mergeDomain = function() {};

    TextScale.prototype.domain = function() {};

    TextScale.prototype.range = function() {};

    return TextScale;

  })(gg.Scale);

  try {
    events = require('events');
  } catch (error) {
    console.log(error);
  }

  gg.wf.Node = (function(_super) {

    __extends(Node, _super);

    function Node(spec) {
      this.spec = spec != null ? spec : {};
      this.children = [null];
      this.parents = [];
      this.inputs = [null];
      this.wf = this.spec.wf || null;
      this.isInstance = findGood([this.spec.instance, false]);
      this._base = this.spec.base || null;
      this.id = gg.wf.Node.id();
      this.type = "node";
      this.name = findGood([this.spec.name, "node-" + this.id]);
    }

    Node.id = function() {
      return gg.wf.Node.prototype._id += 1;
    };

    Node.prototype._id = 0;

    Node.prototype.base = function() {
      if (this._base != null) {
        return this._base;
      } else {
        return this;
      }
    };

    Node.prototype.uniqChildren = function() {
      return _.compact(this.children);
    };

    Node.prototype.nChildren = function() {
      return this.uniqChildren().length;
    };

    Node.prototype.hasChildren = function() {
      return this.nChildren() > 0;
    };

    Node.prototype.toSpec = function() {
      var spec;
      spec = _.clone(this.spec);
      _.extend(spec, {
        instance: true,
        base: this.base(),
        wf: this.wf
      });
      return spec;
    };

    Node.prototype.clone = function(stop, klass) {
      var clone;
      if (klass == null) {
        klass = null;
      }
      this.log("clone");
      if (klass == null) {
        klass = this.constructor;
      }
      clone = new klass(this.toSpec());
      return [clone, clone.getAddInputCB(0)];
    };

    Node.prototype.cloneSubplan = function(stop) {
      var addInputCB, child, childInputCB, copy, _ref, _ref1;
      if (stop == null) {
        stop = null;
      }
      _ref = this.clone(stop), copy = _ref[0], addInputCB = _ref[1];
      if (this.children[0] != null) {
        _ref1 = this.children[0].cloneSubplan(stop), child = _ref1[0], childInputCB = _ref1[1];
        copy.addChild(child, childInputCB);
      }
      return [copy, addInputCB];
    };

    Node.prototype.getAddInputCB = function(idx) {
      var _this = this;
      if (idx >= this.inputs.length) {
        throw Error("input index " + idx + " >= " + this.inputs.length);
      }
      return function(node, data) {
        if (_.isSubclass(data, gg.Table)) {
          data = new gg.wf.Data(data);
        }
        if (_this.inputs[idx] != null) {
          throw Error("trying to add input to filled slot " + idx);
        } else {
          return _this.inputs[idx] = data;
        }
      };
    };

    Node.prototype.addInput = function(idx, node, data) {
      return this.getAddInputCB(idx)(node, data);
    };

    Node.prototype.log = function(text) {
      return console.log("" + this.name + "-" + this.id + "\t" + this.constructor.name + "\t" + text);
    };

    Node.prototype.ready = function() {
      return _.all(this.inputs, function(val) {
        return val != null;
      });
    };

    Node.prototype.addOutputHandler = function(outidx, cb) {
      if (outidx >= 0 && outidx < this.children.length) {
        return this.on(outidx, cb);
      }
    };

    Node.prototype.output = function(outidx, data) {
      this.log("outputing to port " + outidx);
      this.emit(outidx, this, data);
      return this.emit("output", this, data);
    };

    Node.prototype.addParent = function(node) {
      this.log("addParent " + node.name + "-" + node.id + " " + node.constructor.name);
      return this.parents.push(node);
    };

    Node.prototype.addChild = function(node, inputCb) {
      if (inputCb == null) {
        inputCb = null;
      }
      if (this.children[0] != null) {
        throw Error("" + this.name + ": Single Output node already has a child");
      }
      this.children[0] = node;
      if (inputCb != null) {
        this.addOutputHandler(0, inputCb);
      }
      return node.addParent(this);
    };

    Node.prototype.run = function() {
      throw Error("gg.wf.Node.run not implemented");
    };

    Node.prototype.walk = function(f, seen) {
      var child, _i, _len, _ref, _results;
      if (seen == null) {
        seen = null;
      }
      if (seen == null) {
        seen = {};
      }
      seen[this.id] = true;
      f(this);
      _ref = this.uniqChildren();
      _results = [];
      for (_i = 0, _len = _ref.length; _i < _len; _i++) {
        child = _ref[_i];
        if (child != null) {
          _results.push(child.walk(f, seen));
        } else {
          _results.push(void 0);
        }
      }
      return _results;
    };

    return Node;

  })(events.EventEmitter);

  gg.wf.Label = (function(_super) {

    __extends(Label, _super);

    function Label(spec) {
      this.spec = spec != null ? spec : {};
      Label.__super__.constructor.call(this, this.spec);
      this.key = this.spec.key;
      this.compute = findGood([this.spec.val, this.spec.value, this.spec.f, null]);
      this.type = "label";
      this.name = findGood([this.spec.name, "" + this.type + "-" + this.id]);
      if (this.key == null) {
        throw Error("" + this.name + ": Did not define a label key and value/value function)");
      }
    }

    Label.prototype.run = function() {
      var data, env, val;
      if (!this.ready()) {
        throw Error("" + this.name + ": node not ready");
      }
      data = this.inputs[0];
      if (_.isFunction(this.compute)) {
        val = this.compute(data.table, data.env, this);
      } else {
        val = this.compute;
      }
      console.log("" + this.name + ": adding label " + this.key + " -> " + val);
      env = data.env.clone();
      env.pushGroupPair(this.key, val);
      this.output(0, new gg.wf.Data(data.table, env));
      return data.table;
    };

    return Label;

  })(gg.wf.Node);

  gg.wf.Source = (function(_super) {

    __extends(Source, _super);

    function Source(spec) {
      this.spec = spec != null ? spec : {};
      Source.__super__.constructor.call(this, this.spec);
      this.compute = this.spec.f || this.compute;
      this.type = "source";
      this.name = findGood([this.spec.name, "" + this.type + "-" + this.id]);
    }

    Source.prototype.compute = function() {
      throw Error("" + this.name + ": Source not setup to generate tables");
    };

    Source.prototype.ready = function() {
      return true;
    };

    Source.prototype.run = function() {
      var table;
      table = this.compute();
      this.output(0, new gg.wf.Data(table, new gg.wf.Env));
      return table;
    };

    return Source;

  })(gg.wf.Node);

  gg.wf.Exec = (function(_super) {

    __extends(Exec, _super);

    function Exec(spec) {
      this.spec = spec != null ? spec : {};
      Exec.__super__.constructor.call(this, this.spec);
      this.compute = this.spec.f || this.compute;
      this.type = "exec";
      this.name = findGood([this.spec.name, "exec-" + this.id]);
    }

    Exec.prototype.compute = function(table, env, node) {
      return table;
    };

    Exec.prototype.run = function() {
      var data, output;
      if (!this.ready()) {
        throw Error("node not ready");
      }
      data = this.inputs[0];
      output = this.compute(data.table, data.env, this);
      this.output(0, new gg.wf.Data(output, data.env.clone()));
      return output;
    };

    return Exec;

  })(gg.wf.Node);

  gg.wf.Stdout = (function(_super) {

    __extends(Stdout, _super);

    function Stdout(spec) {
      this.spec = spec != null ? spec : {};
      Stdout.__super__.constructor.call(this, this.spec);
      this.type = "stdout";
      this.name = findGood([this.spec.name, "" + this.type + "-" + this.id]);
      this.n = findGood([this.spec.n, null]);
    }

    Stdout.prototype.compute = function(table, env, node) {
      var _this = this;
      table.each(function(row, idx) {
        if (_this.n === null || idx < _this.n) {
          return console.log(JSON.stringify(_.omit(row, ['get', 'ncols'])));
        }
      });
      return table;
    };

    return Stdout;

  })(gg.wf.Exec);

  gg.wf.Barrier = (function(_super) {

    __extends(Barrier, _super);

    function Barrier(spec) {
      this.spec = spec != null ? spec : {};
      Barrier.__super__.constructor.call(this, this.spec);
      this.compute = this.spec.f || this.compute;
      this.type = "barrier";
      this.name = findGood([this.spec.name, "barrier-" + this.id]);
      this.clonePtr = 0;
    }

    Barrier.prototype.compute = function(tables, env, node) {
      return tables;
    };

    Barrier.prototype.cloneSubplan = function(stop) {
      var child, childInputCB, idx, nChildren, _ref;
      nChildren = this.wf.children(this.base()).length;
      idx = this.clonePtr % nChildren;
      _ref = this.children[idx].cloneSubplan(stop), child = _ref[0], childInputCB = _ref[1];
      this.addChild(child, childInputCB);
      this.clonePtr = (this.clonePtr + 1) % nChildren;
      return [this, this.getAddInputCB(this.nChildren() - 1)];
    };

    Barrier.prototype.addChild = function(child, inputCb) {
      if (inputCb == null) {
        inputCb = null;
      }
      if (this.children[0] != null) {
        this.children.push(child);
        this.inputs.push(null);
      } else {
        this.children[0] = child;
      }
      if (inputCb != null) {
        this.addOutputHandler(this.nChildren() - 1, inputCb);
      }
      child.addParent(this);
      return this.log("addChild " + child.name + "-" + child.id + " to port " + (this.nChildren() - 1) + "\t " + this.inputs.length + " in " + (this.nChildren()) + " out");
    };

    Barrier.prototype.run = function() {
      var envs, idx, output, outputs, tables, _i, _len;
      if (!this.ready()) {
        throw Error("Node not ready");
      }
      tables = _.pluck(this.inputs, 'table');
      envs = _.pluck(this.inputs, 'env');
      outputs = this.compute(tables, envs, this);
      console.log("" + this.name + " barrier got " + tables.length);
      for (idx = _i = 0, _len = outputs.length; _i < _len; idx = ++_i) {
        output = outputs[idx];
        this.output(idx, new gg.wf.Data(output, envs[idx].clone()));
      }
      return outputs;
    };

    return Barrier;

  })(gg.wf.Node);

  gg.wf.Split = (function(_super) {

    __extends(Split, _super);

    function Split(spec) {
      this.spec = spec != null ? spec : {};
      Split.__super__.constructor.call(this, this.spec);
      this.type = "split";
      this.name = findGood([this.spec.name, "split-" + this.id]);
      this.gbkeyName = findGood([this.spec.key, this.name]);
      this.splitFunc = findGood([this.spec.f, this.splitFunc]);
    }

    Split.prototype.splitFunc = function(table, env, node) {
      return [];
    };

    Split.prototype.findMatchingJoin = function() {
      var n, ptr;
      ptr = this.children[0];
      n = 1;
      while (ptr != null) {
        if (ptr.type === 'split') {
          n += 1;
        }
        if (ptr.type === 'join') {
          n -= 1;
        }
        if (n === 0) {
          break;
        }
        ptr = ptr.hasChildren() ? ptr.children[0] : null;
      }
      return ptr;
    };

    Split.prototype.allocateChildren = function(n) {
      var child, childInputCB, idx, stop, _ref, _results;
      if (this.hasChildren()) {
        stop = this.findMatchingJoin();
        _results = [];
        while (this.children.length < n) {
          idx = this.children.length;
          _ref = this.children[0].cloneSubplan(stop), child = _ref[0], childInputCB = _ref[1];
          _results.push(this.addChild(child, childInputCB));
        }
        return _results;
      }
    };

    Split.prototype.addChild = function(child, inputCb) {
      if (inputCb == null) {
        inputCb = null;
      }
      if (this.children[0] != null) {
        this.children.push(child);
        if (inputCb != null) {
          this.addOutputHandler(this.children.length - 1, inputCb);
        }
      } else {
        this.children[0] = child;
        if (inputCb != null) {
          this.addOutputHandler(0, inputCb);
        }
      }
      return child.addParent(this);
    };

    Split.prototype.run = function() {
      var data, env, groups, idx, numDuplicates, table,
        _this = this;
      if (!this.ready()) {
        throw Error("Split not ready, expects " + this.inputs.length + " inputs");
      }
      data = this.inputs[0];
      table = data.table;
      env = data.env;
      groups = this.splitFunc(table, env, this);
      if (!((groups != null) && _.isArray(groups))) {
        throw Error("" + this.name + ": Non-array result from calling split function");
      }
      numDuplicates = groups.length;
      if (numDuplicates > 1000) {
        throw Error("I don't want to support more than 1000 groups!");
      }
      this.allocateChildren(numDuplicates);
      idx = 0;
      _.each(groups, function(group) {
        var key, newData, subtable;
        subtable = group.table;
        key = group.key;
        newData = new gg.wf.Data(subtable, data.env.clone());
        newData.env.pushGroupPair(_this.gbkeyName, key);
        _this.output(idx, newData);
        return idx += 1;
      });
      return groups;
    };

    return Split;

  })(gg.wf.Node);

  gg.wf.Partition = (function(_super) {

    __extends(Partition, _super);

    function Partition() {
      Partition.__super__.constructor.apply(this, arguments);
      this.name = findGood([this.spec.name, "partition-" + this.id]);
      this.gbfunc = this.spec.f || this.gbfunc;
      this.splitFunc = function(table) {
        return table.split(this.gbfunc);
      };
    }

    Partition.prototype.gbfunc = function() {
      return 1;
    };

    return Partition;

  })(gg.wf.Split);

  gg.wf.Join = (function(_super) {

    __extends(Join, _super);

    function Join(spec) {
      this.spec = spec != null ? spec : {};
      Join.__super__.constructor.call(this, this.spec);
      this.type = "join";
      this.name = findGood([this.spec.name, "join-" + this.id]);
    }

    Join.prototype.cloneSubplan = function(stop) {
      var addInputCB;
      if (this === stop) {
        this.inputs.push(null);
        addInputCB = this.getAddInputCB(this.inputs.length - 1);
        return [this, addInputCB];
      } else {
        return Join.__super__.cloneSubplan.call(this, stop);
      }
    };

    Join.prototype.ready = function() {
      return Join.__super__.ready.apply(this, arguments);
    };

    Join.prototype.run = function() {
      var env, output, tables,
        _this = this;
      if (!this.ready()) {
        throw Error("" + this.name + " not ready: " + this.inputs.length + " of " + (this.children().length) + " inputs");
      }
      tables = _.map(this.inputs, function(data) {
        var colName, colVal, groupPair, newCol, table;
        table = data.table;
        groupPair = data.env.popGroupPair();
        colName = groupPair.key;
        colVal = groupPair.val;
        newCol = _.times(table.nrows(), function() {
          return colVal;
        });
        table.addColumn(colName, newCol);
        return table;
      });
      env = this.inputs[0].env.clone();
      output = gg.Table.merge(_.values(tables));
      this.output(0, new gg.wf.Data(output, env));
      return output;
    };

    return Join;

  })(gg.wf.Node);

  gg.wf.Multicast = (function(_super) {

    __extends(Multicast, _super);

    function Multicast(spec) {
      this.spec = spec != null ? spec : {};
      Multicast.__super__.constructor.call(this, this.spec);
      this.type = "multicast";
      this.name = findGood([this.spec.name, "multicast-" + this.id]);
    }

    Multicast.prototype.cloneSubplan = function(stop) {
      var addInputCB, child, childCopy, childInputCB, clone, idx, _i, _len, _ref, _ref1, _ref2;
      _ref = this.clone(stop), clone = _ref[0], addInputCB = _ref[1];
      _ref1 = _.compact(this.children);
      for (idx = _i = 0, _len = _ref1.length; _i < _len; idx = ++_i) {
        child = _ref1[idx];
        _ref2 = child.cloneSubplan(stop), childCopy = _ref2[0], childInputCB = _ref2[1];
        clone.addChild(childCopy, childInputCB);
      }
      return [clone, addInputCB];
    };

    Multicast.prototype.addChild = function(node, inputCb) {
      if (inputCb == null) {
        inputCb = null;
      }
      if (this.children[0] == null) {
        this.children[0] = node;
      } else {
        this.children.push(node);
      }
      node.addParent(this);
      if (inputCb != null) {
        return this.addOutputHandler(this.children.length - 1, inputCb);
      }
    };

    Multicast.prototype.run = function() {
      var child, data, idx, newData, _i, _len, _ref;
      if (!this.ready()) {
        throw Error("Node not ready");
      }
      data = this.inputs[0];
      _ref = this.children;
      for (idx = _i = 0, _len = _ref.length; _i < _len; idx = ++_i) {
        child = _ref[idx];
        newData = data.clone();
        this.output(idx, newData);
      }
      return data.table;
    };

    return Multicast;

  })(gg.wf.Node);

  /*
  class gg.wf.Composite extends gg.wf.Node
  
      constructor: (@spec={}) ->
          super @spec
  
          @nodes = @spec.nodes
          @type = "composite"
          @name = findGood [@spec.name, "comp-#{@id}"]
  
      clone: (stop) ->
          nodes = []
  */


  gg.XForm = (function() {

    function XForm(g, spec) {
      this.g = g;
      this.spec = spec != null ? spec : {};
      if (!_.isSubclass(this.g, gg.Graphic)) {
        throw Error("Xform passed non-graphic as first argument");
      }
      this.params = {};
    }

    XForm.prototype.parseSpec = function() {
      var spec;
      console.log("XForm spec: " + (JSON.stringify(this.spec)));
      spec = _.clone(this.spec);
      this.inputSchema = this.extractAttr("inputSchema");
      this.defaults = this.extractAttr("defaults");
      this.compute = spec.f || this.compute;
      return this.spec = spec;
    };

    XForm.prototype.extractAttr = function(attr, spec) {
      var val;
      if (spec == null) {
        spec = {};
      }
      if (spec == null) {
        spec = this.spec;
      }
      val = findGood(spec, [attr], null);
      if (val != null) {
        if (!_.isFunction(val)) {
          return function(table, env) {
            return val;
          };
        } else {
          return val;
        }
      } else {
        return this[attr];
      }
    };

    XForm.prototype.facetGroups = function(table, env) {
      return {
        facetX: env.group(this.g.facets.facetXKey, ""),
        facetY: env.group(this.g.facets.facetYKey, "")
      };
    };

    XForm.prototype.layerIdx = function(table, env) {
      return {
        layer: env.group("layer", "")
      };
    };

    XForm.prototype.paneInfo = function(table, env) {
      var ret;
      ret = this.facetGroups(table, env);
      _.extend(ret, this.layerIdx(table, env));
      return ret;
    };

    XForm.prototype.scales = function(table, env) {
      var info;
      info = this.paneInfo(table, env);
      return this.g.scales.scales(info.facetX, info.facetY, info.layer);
    };

    XForm.prototype.param = function(table, env, attr, defaultVal) {
      var ret;
      if (defaultVal == null) {
        defaultVal = null;
      }
      if (attr in this.params) {
        ret = this.params[attr];
      } else {
        if (attr in this) {
          ret = this[attr];
        } else {
          return defaultVal;
        }
      }
      if (_.isFunction(ret)) {
        return ret(table, env);
      } else {
        return ret;
      }
    };

    XForm.prototype.defaults = function(table, env) {
      return {};
    };

    XForm.prototype.inputSchema = function(table, env) {
      return table.colNames();
    };

    XForm.prototype.validateInput = function(table, env) {
      var iSchema, missing, tableCols;
      tableCols = table.colNames();
      iSchema = this.param(table, env, "inputSchema");
      missing = _.reject(iSchema, function(attr) {
        return __indexOf.call(tableCols, attr) >= 0;
      });
      if (missing.length > 0) {
        throw Error("" + this.name + ": input schema did not contain " + (missing.join(",")));
      }
    };

    XForm.prototype.addDefaults = function(table, env) {
      var defaults;
      defaults = this.param(table, env, "defaults");
      console.log("adding defaults of " + (JSON.stringify(defaults)));
      console.log("                   " + (JSON.stringify(table.colNames())));
      return _.each(defaults, function(val, col) {
        if (__indexOf.call(table.colNames(), col) < 0) {
          return table.addConstColumn(col, val);
        }
      });
    };

    XForm.prototype.compute = function(table, env, node) {
      return table;
    };

    XForm.prototype.compile = function() {
      var spec, _compute,
        _this = this;
      spec = _.clone(this.spec);
      _compute = function(table, env, node) {
        _this.addDefaults(table, env);
        _this.validateInput(table, env);
        return _this.compute(table, env, node);
      };
      spec.f = _compute;
      return [new gg.wf.Exec(spec)];
    };

    XForm.fromSpec = function(spec) {
      var klass, xformName;
      xformName = findGood([spec.xform, "identity"]);
      return klass = {}[xformName] || gg.XForm;
    };

    XForm.prototype.log = function(text) {
      return console.log("" + this.spec.name + " " + this.constructor.name + ":\t" + text);
    };

    return XForm;

  })();

  gg.Scales = (function(_super) {

    __extends(Scales, _super);

    Scales.UNTRAINED = 0;

    Scales.PREGEOM = 1;

    Scales.PRERENDER = 2;

    Scales.POSTRENDER = 3;

    Scales.POSTFACET = 4;

    function Scales(g, spec) {
      var _this = this;
      this.g = g;
      this.spec = spec;
      Scales.__super__.constructor.apply(this, arguments);
      this.scalesFactory = null;
      this.mappings = {};
      this.scalesList = [];
      this.state = gg.Scales.UNTRAINED;
      this.parseSpec();
      this.prestatsNode = new gg.wf.Barrier({
        name: "scales:prestats",
        f: function() {
          var args;
          args = 1 <= arguments.length ? __slice.call(arguments, 0) : [];
          return _this.trainOnData.apply(_this, __slice.call(args).concat([gg.Scales.PREGEOM]));
        }
      });
      this.pregeomNode = new gg.wf.Barrier({
        name: "scales:poststats",
        f: function() {
          var args;
          args = 1 <= arguments.length ? __slice.call(arguments, 0) : [];
          return _this.trainOnData.apply(_this, __slice.call(args).concat([gg.Scales.PRERENDER]));
        }
      });
      this.prerenderNode = new gg.wf.Barrier({
        name: "scales:postgeom",
        f: function() {
          var args;
          args = 1 <= arguments.length ? __slice.call(arguments, 0) : [];
          return _this.trainOnPixels.apply(_this, __slice.call(args).concat([gg.Scales.POSTRENDER]));
        }
      });
      this.facetNode = new gg.wf.Barrier({
        name: "scales:facet",
        f: function() {
          var args;
          args = 1 <= arguments.length ? __slice.call(arguments, 0) : [];
          return _this.trainForFacets.apply(_this, __slice.call(args).concat([gg.Scales.POSTFACET]));
        }
      });
    }

    Scales.prototype.parseSpec = function() {
      return this.scalesFactory = new gg.ScaleFactory(this.spec);
    };

    Scales.prototype.trainOnData = function(tables, envs, node, nextState) {
      var _this = this;
      if (nextState == null) {
        nextState = null;
      }
      _.each(_.zip(tables, envs), function(_arg) {
        var aess, e, info, scales, t;
        t = _arg[0], e = _arg[1];
        info = _this.paneInfo(t, e);
        aess = _this.aesthetics(info.layer);
        scales = _this.scales(info.facetX, info.facetY, info.layer);
        t = t.filter(function(row) {
          return !(_.any(aess, function(aes) {
            return !scales.scale(aes).valid(row.get(aes));
          }));
        });
        return scales.train(t, aess);
      });
      if (nextState != null) {
        this.state = nextState;
      }
      this.g.facets.trainScales();
      return tables;
    };

    Scales.prototype.trainOnPixels = function(tables, envs, node, nextState) {
      var _this = this;
      if (nextState == null) {
        nextState = null;
      }
      _.each(_.zip(tables, envs), function(_arg) {
        var aess, e, info, inverted, scales, t, table;
        table = _arg[0], e = _arg[1];
        t = table.cloneDeep();
        info = _this.paneInfo(t, e);
        aess = _this.aesthetics(info.layer);
        scales = _this.scales(info.facetX, info.facetY, info.layer);
        inverted = scales.invert(t, aess);
        inverted = inverted.filter(function(row) {
          return !(_.any(aess, function(aes) {
            return !scales.scale(aes).valid(row.get(aes));
          }));
        });
        return scales.train(inverted, aess);
      });
      if (nextState != null) {
        this.state = nextState;
      }
      return tables;
    };

    Scales.prototype.trainForFacets = function(tables, envs, node, nextState) {
      if (this.state !== gg.Scales.POSTRENDER) {
        throw Error("gg.Scales.trainForFacets: state (" + this.state + ") != POSTRENDER");
      }
      this.g.facets.trainScales();
      return this.state = nextState;
    };

    Scales.prototype.layer = function(layerIdx) {
      return this.g.layers.getLayer(layerIdx);
    };

    Scales.prototype.aesthetics = function(layerIdx) {
      var aess, layerAess, scalesAess;
      scalesAess = this.scalesFactory.aesthetics();
      layerAess = this.layer(layerIdx).aesthetics();
      aess = _.compact(_.uniq(_.flatten([scalesAess, layerAess, ['y', 'x']])));
      return aess;
    };

    Scales.prototype.facetScales = function(facetX, facetY) {
      var mapping;
      try {
        mapping = this.mappings[facetX][facetY];
        return gg.ScalesSet.merge(_.values(mapping));
      } catch (error) {
        throw Error("gg.ScalesfacetScales: could not find scales\n\t" + error);
      }
    };

    Scales.prototype.scales = function(facetX, facetY, layerIdx) {
      var aess, map, newScalesSet;
      if (facetX == null) {
        facetX = null;
      }
      if (facetY == null) {
        facetY = null;
      }
      if (layerIdx == null) {
        layerIdx = null;
      }
      if (!(facetX in this.mappings)) {
        this.mappings[facetX] = {};
      }
      if (!(facetY in this.mappings[facetX])) {
        this.mappings[facetX][facetY] = {};
      }
      map = this.mappings[facetX][facetY];
      if (layerIdx != null) {
        if (!(layerIdx in map)) {
          aess = this.aesthetics(layerIdx);
          newScalesSet = this.scalesFactory.scales(aess);
          map[layerIdx] = newScalesSet;
          this.scalesList.push(newScalesSet);
        }
        return map[layerIdx];
      } else {
        return _.values(map);
      }
    };

    return Scales;

  })(gg.XForm);

  gg.ScaleFactory = (function() {

    function ScaleFactory(spec, layersSpecs) {
      this.spec = spec;
      this.layersSpecs = layersSpecs != null ? layersSpecs : [];
      this.paneDefaults = {};
      this.layerDefaults = {};
      this.setup();
    }

    ScaleFactory.prototype.setup = function() {
      var _this = this;
      _.each(this.spec, function(s, aes) {
        var scale;
        s = _.clone(s);
        s.aes = aes;
        scale = gg.Scale.fromSpec(s);
        return _this.paneDefaults[scale.aes] = scale;
      });
      if ((this.layerSpecs != null) && this.layerSpecs.length > 0) {
        return _.each(this.layerSpecs, function(lspec, idx) {
          if (lspec.scales != null) {
            return _.each(lspec.scales, function(s) {
              var key, scale;
              scale = gg.Scale.fromSpec(s);
              key = [idx, scale.aes];
              return _this.layerDefaults[key] = scale;
            });
          }
        });
      }
    };

    ScaleFactory.prototype.aesthetics = function() {
      return _.compact(_.keys(this.paneDefaults));
    };

    ScaleFactory.prototype.addLayerDefaults = function(layerIdx, lspec) {
      throw Error("gg.ScaleFactory: layer scales not implemented");
    };

    ScaleFactory.prototype.scale = function(aes, layerIdx) {
      var scale;
      if (layerIdx == null) {
        layerIdx = null;
      }
      scale = ((layerIdx != null) && [layerIdx, aes] in this.layerDefaults ? this.layerDefaults[[layerIdx, aes]].clone() : aes in this.paneDefaults ? this.paneDefaults[aes].clone() : gg.Scale.defaultFor(aes));
      return scale;
    };

    ScaleFactory.prototype.scales = function(aesthetics, layerIdx) {
      var scales,
        _this = this;
      if (layerIdx == null) {
        layerIdx = null;
      }
      scales = new gg.ScalesSet(this);
      _.each(aesthetics, function(aes) {
        scales.scale(_this.scale(aes, layerIdx));
        if (typeof aes === "undefined") {
          throw Error();
        }
      });
      return scales;
    };

    return ScaleFactory;

  })();

  gg.ScalesSet = (function() {

    function ScalesSet(factory) {
      this.factory = factory;
      this.scales = {};
      this.spec = {};
      this.id = gg.ScalesSet.prototype._id;
      gg.ScalesSet.prototype._id += 1;
    }

    ScalesSet.prototype._id = 0;

    ScalesSet.prototype.clone = function() {
      var ret;
      ret = new gg.ScalesSet(this.factory);
      ret.spec = _.clone(this.spec);
      ret.merge(this, true);
      return ret;
    };

    ScalesSet.prototype.keep = function(aesthetics) {
      var _this = this;
      _.each(_.keys(this.scales), function(aes) {
        if (__indexOf.call(aesthetics, aes) < 0) {
          return delete _this.scales[aes];
        }
      });
      return this;
    };

    ScalesSet.prototype.exclude = function(aesthetics) {
      var _this = this;
      _.each(aesthetics, function(aes) {
        if (aes in _this.scales) {
          return delete _this.scales[aes];
        }
      });
      return this;
    };

    ScalesSet.prototype.aesthetics = function() {
      var keys;
      keys = _.keys(this.scales);
      _.map(keys, function(key) {
        if (key in gg.Scale.xs) {
          return gg.Scale.xs;
        } else if (key in gg.Scale.ys) {
          return gg.Scale.ys;
        } else {
          return key;
        }
      });
      return _.uniq(_.compact(_.flatten(keys)));
    };

    ScalesSet.prototype.ensureScales = function(aess) {
      var _this = this;
      _.each(aess, function(aes) {
        if (!_this.scale(aes)) {
          return _this.scale(gg.Scale.defaultFor(aes));
        }
      });
      return this;
    };

    ScalesSet.prototype.contains = function(aes, type) {
      if (type == null) {
        type = null;
      }
      return aes in this.scales && (!type || type in this.scales[aes]);
    };

    ScalesSet.prototype.scale = function(aesOrScale, type) {
      var aes, scale, vals;
      if (type == null) {
        type = null;
      }
      if (_.isString(aesOrScale)) {
        aes = aesOrScale;
        if (__indexOf.call(gg.Scale.xs, aes) >= 0) {
          aes = 'x';
        }
        if (__indexOf.call(gg.Scale.ys, aes) >= 0) {
          aes = 'y';
        }
        if (!(aes in this.scales)) {
          this.scales[aes] = {};
        }
        if (type === null) {
          if (type in this.scales[aes]) {
            return this.scales[aes][type];
          } else {
            vals = _.values(this.scales[aes]);
            if (!((vals != null) && vals.length > 0)) {
              this.scales[aes][null] = this.factory.scale(aes);
            }
            return (_.values(this.scales[aes]))[0];
          }
        } else {
          if (!(type in this.scales[aes])) {
            this.scales[aes][type] = this.factory.scale(aes);
          }
          return this.scales[aes][type];
        }
      } else if (aesOrScale != null) {
        scale = aesOrScale;
        aes = scale.aes;
        if (!(aes in this.scales)) {
          this.scales[aes] = {};
        }
        this.scales[aes][scale.type] = scale;
        this.scales[aes][null] = scale;
        return scale;
      }
    };

    ScalesSet.merge = function(scalesArr) {
      var ret;
      if (scalesArr.length === 0) {
        return null;
      }
      ret = scalesArr[0].clone();
      _.each(_.rest(scalesArr), function(scales) {
        return ret.merge(scales);
      });
      return ret;
    };

    ScalesSet.prototype.merge = function(scales, insert) {
      var _this = this;
      if (insert == null) {
        insert = true;
      }
      _.each(scales.aesthetics(), function(aes) {
        if (aes === 'text') {
          return;
        }
        return _.each(scales.scales[aes], function(scale, type) {
          var mys;
          if (_this.contains(aes, type)) {
            mys = _this.scale(aes, type);
            _this.scale(aes, type).mergeDomain(scale.domain());
          } else if (insert) {
            _this.scale(scale.clone());
          }
          return mys = _this.scale(aes, type);
        });
      });
      return this;
    };

    ScalesSet.prototype.train = function(table, aess) {
      var _this = this;
      if (aess == null) {
        aess = null;
      }
      if (aess == null) {
        aess = _.uniq(_.keys(this.scales));
      }
      _.each(aess, function(aes) {
        var col, scale;
        scale = _this.scale(aes);
        col = table.getColumn(aes);
        if (col != null) {
          scale.mergeDomain(scale.defaultDomain(col));
          return console.log("scalesSet.train: " + aes + " has domain.length " + (scale.domain().length));
        }
      });
      return this;
    };

    ScalesSet.prototype.toString = function() {
      var arr,
        _this = this;
      arr = _.flatten(_.map(this.scales, function(map, aes) {
        return _.map(map, function(scale, type) {
          var d3Scale;
          d3Scale = scale.d3Scale;
          return _.flatten([aes, '->', type, d3Scale.domain(), d3Scale.range()]).join(' ');
        });
      }));
      return arr.join('\n');
    };

    ScalesSet.prototype.apply = function() {
      return null;
    };

    ScalesSet.prototype.invert = function(table, aess) {
      var _this = this;
      if (aess == null) {
        aess = null;
      }
      if (aess == null) {
        aess = _.keys(this.scales);
      }
      table = table.cloneShallow();
      table.each(function(row, idx) {
        return _.each(aess, function(aes) {
          if (aes in row) {
            return row[aes] = _this.scale(aes).invert(row[aes]);
          }
        });
      });
      return table;
    };

    ScalesSet.prototype.labelFor = function() {
      return null;
    };

    return ScalesSet;

  })();

  gg.ScalesApply = (function(_super) {

    __extends(ScalesApply, _super);

    function ScalesApply(layer, spec) {
      this.layer = layer;
      this.spec = spec;
      ScalesApply.__super__.constructor.call(this, this.layer.g, this.spec);
      this.parseSpec();
    }

    ScalesApply.prototype.compute = function(table, env) {
      var info, scalesSet,
        _this = this;
      info = this.paneInfo(table, env);
      scalesSet = this.scales(table, env);
      table = table.clone();
      this.log(":aesthetics: " + (scalesSet.aesthetics()));
      _.each(scalesSet.aesthetics(), function(aes) {
        var f, scale;
        scale = scalesSet.scale(aes);
        _this.log("" + aes + " scale is (" + (scale.domain()) + ") -> (" + (scale.range()) + ")");
        f = function(v) {
          return scale.scale(v);
        };
        if (table.contains(aes)) {
          return table.map(f, aes);
        }
      });
      return table;
    };

    return ScalesApply;

  })(gg.XForm);

  gg.GeomRender = (function(_super) {

    __extends(GeomRender, _super);

    function GeomRender(layer, spec) {
      this.layer = layer;
      this.spec = spec != null ? spec : {};
      this.spec.name = findGoodAttr(this.spec, ['name'], this.constructor.name);
      GeomRender.__super__.constructor.call(this, this.layer.g, this.spec);
      this.parseSpec();
    }

    GeomRender.prototype.parseSpec = function() {
      return GeomRender.__super__.parseSpec.apply(this, arguments);
    };

    GeomRender.prototype.svg = function(table, env, node) {
      var info;
      info = this.paneInfo(table, env);
      return this.g.facets.svgPane(info.facetX, info.facetY);
    };

    GeomRender.prototype.groups = function(g, klass, data) {
      return g.selectAll("g." + klass).data(data).enter().append('g').attr('class', "" + klass);
    };

    GeomRender.prototype.agroup = function(g, klass, data) {
      return g.append("g").attr("class", "" + klass).data(data);
    };

    GeomRender.prototype.applyAttrs = function(domEl, attrs) {
      return _.each(attrs, function(val, attr) {
        return domEl.attr(attr, val);
      });
    };

    GeomRender.prototype.compute = function(table, env, node) {
      return this.render(table, env, node);
    };

    GeomRender.prototype.render = function(table) {
      throw Error("" + this.name + ".render() not implemented");
    };

    GeomRender.klasses = function() {
      var klasses, ret;
      klasses = [gg.GeomRenderPointSvg, gg.GeomRenderLineSvg, gg.GeomRenderRectSvg];
      ret = {};
      _.each(klasses, function(klass) {
        if (_.isArray(klass.aliases)) {
          return _.each(klass.aliases, function(alias) {
            return ret[alias] = klass;
          });
        } else {
          return ret[klass.aliases] = klass;
        }
      });
      return ret;
    };

    GeomRender.fromSpec = function(layer, spec) {
      var klass, klasses, type;
      klasses = gg.GeomRender.klasses();
      if (_.isString(spec)) {
        type = spec;
        spec = {
          type: type
        };
      } else {
        type = findGoodAttr(spec, ['geom', 'type', 'shape'], 'point');
      }
      console.log(klasses);
      klass = klasses[type] || gg.GeomRenderPointSvg;
      console.log("geom-render klass " + type + " -> " + klass.name);
      return new klass(layer, spec);
    };

    return GeomRender;

  })(gg.XForm);

  gg.GeomRenderPointSvg = (function(_super) {

    __extends(GeomRenderPointSvg, _super);

    function GeomRenderPointSvg() {
      return GeomRenderPointSvg.__super__.constructor.apply(this, arguments);
    }

    GeomRenderPointSvg.aliases = ["point", "pt"];

    GeomRenderPointSvg.prototype.defaults = function(table, env) {
      return {
        r: 2,
        "fill-opacity": 0.5,
        fill: "steelblue",
        stroke: "steelblue",
        "stroke-width": 0,
        "stroke-opacity": 0.5,
        group: 1
      };
    };

    GeomRenderPointSvg.prototype.inputSchema = function(table, env) {
      return ['x', 'y'];
    };

    GeomRenderPointSvg.prototype.render = function(table, env, node) {
      var circles, data, enter, enterCircles, exit;
      data = table.asArray();
      circles = this.agroup(this.svg(table, env), "circles geoms", data).selectAll("circle").data(data);
      enter = circles.enter();
      exit = circles.exit();
      enterCircles = enter.append("circle");
      this.applyAttrs(enterCircles, {
        "class": "geom",
        cx: function(t) {
          return t.get('x');
        },
        cy: function(t) {
          return t.get('y');
        },
        "fill-opacity": function(t) {
          return t.get('fill-opacity');
        },
        "stroke-opacity": function(t) {
          return t.get("stroke-opacity");
        },
        fill: function(t) {
          return t.get('fill');
        },
        r: function(t) {
          return t.get('r');
        }
      });
      return exit.transition().duration(500).attr("fill-opacity", 0).attr("stroke-opacity", 0).transition().remove();
    };

    return GeomRenderPointSvg;

  })(gg.GeomRender);

  gg.GeomRenderLineSvg = (function(_super) {

    __extends(GeomRenderLineSvg, _super);

    function GeomRenderLineSvg() {
      return GeomRenderLineSvg.__super__.constructor.apply(this, arguments);
    }

    GeomRenderLineSvg.aliases = "line";

    GeomRenderLineSvg.prototype.defaults = function(table) {
      stroke - {
        width: 1
      };
      return {
        stroke: "black"
      };
    };

    GeomRenderLineSvg.prototype.inputSchema = function(table, env) {
      return ['x1', 'y1', 'x2', 'y2'];
    };

    GeomRenderLineSvg.prototype.render = function(table, env) {
      var enter, enterLines, exit, lines;
      lines = this.groups(this.svg(table, env), "lines geoms", table.asArray()).selectAll("line").data(Object);
      enter = lines.enter();
      exit = lines.exit();
      enterLines = enter.append("line");
      this.applyAttrs(enterLines, {
        "class": "geom",
        x1: function(t) {
          return t.get('x1');
        },
        x2: function(t) {
          return t.get('x2');
        },
        y1: function(t) {
          return t.get('y1');
        },
        y2: function(t) {
          return t.get('y2');
        },
        "stroke": function(t) {
          return t.get("stroke");
        },
        "stroke-width": function(t) {
          return t.get("stroke-width");
        },
        "stroke-opacity": function(t) {
          return t.get("stroke-opacity");
        }
      });
      return exit.remove();
    };

    return GeomRenderLineSvg;

  })(gg.GeomRender);

  gg.GeomRenderRectSvg = (function(_super) {

    __extends(GeomRenderRectSvg, _super);

    function GeomRenderRectSvg() {
      return GeomRenderRectSvg.__super__.constructor.apply(this, arguments);
    }

    GeomRenderRectSvg.aliases = "rect";

    GeomRenderRectSvg.prototype.defaults = function(table, env) {
      return {
        "fill-opacity": 0.5,
        fill: "steelblue",
        stroke: "steelblue",
        "stroke-width": 0,
        "stroke-opacity": 0.5,
        group: 1
      };
    };

    GeomRenderRectSvg.prototype.inputSchema = function(table, env) {
      return ['x0', 'x1', 'y0', 'y1'];
    };

    GeomRenderRectSvg.prototype.render = function(table, env, node) {
      var data, enter, enterRects, exit, rects;
      console.log('rendering rectangles!');
      data = table.asArray();
      rects = this.agroup(this.svg(table, env), "intervals geoms", data).selectAll("rect").data(data);
      enter = rects.enter();
      exit = rects.exit();
      enterRects = enter.append("rect");
      this.applyAttrs(enterRects, {
        "class": "geom",
        x: function(t) {
          return t.get('x0');
        },
        y: function(t) {
          return Math.min(t.get('y0'), t.get('y1'));
        },
        width: function(t) {
          return t.get('x1') - t.get('x0');
        },
        height: function(t) {
          return Math.abs(t.get('y1') - t.get('y0'));
        },
        "fill-opacity": function(t) {
          return t.get('fill-opacity');
        },
        "stroke-opacity": function(t) {
          return t.get("stroke-opacity");
        },
        fill: function(t) {
          return t.get('fill');
        }
      });
      return exit.transition().duration(500).attr("fill-opacity", 0).attr("stroke-opacity", 0).transition().remove();
    };

    return GeomRenderRectSvg;

  })(gg.GeomRender);

  gg.GeomRenderPath = (function(_super) {

    __extends(GeomRenderPath, _super);

    function GeomRenderPath() {
      return GeomRenderPath.__super__.constructor.apply(this, arguments);
    }

    return GeomRenderPath;

  })(gg.GeomRender);

  gg.GeomRenderPolygon = (function(_super) {

    __extends(GeomRenderPolygon, _super);

    function GeomRenderPolygon() {
      return GeomRenderPolygon.__super__.constructor.apply(this, arguments);
    }

    return GeomRenderPolygon;

  })(gg.GeomRender);

  gg.GeomRenderSchema = (function(_super) {

    __extends(GeomRenderSchema, _super);

    function GeomRenderSchema() {
      return GeomRenderSchema.__super__.constructor.apply(this, arguments);
    }

    return GeomRenderSchema;

  })(gg.GeomRender);

  gg.GeomRenderGlyph = (function(_super) {

    __extends(GeomRenderGlyph, _super);

    function GeomRenderGlyph() {
      return GeomRenderGlyph.__super__.constructor.apply(this, arguments);
    }

    return GeomRenderGlyph;

  })(gg.GeomRender);

  gg.Position = (function(_super) {

    __extends(Position, _super);

    function Position(layer, spec) {
      this.layer = layer;
      this.spec = spec != null ? spec : {};
      Position.__super__.constructor.call(this, this.layer.g, this.spec);
      this.parseSpec();
    }

    Position.klasses = function() {
      var klasses, ret;
      klasses = [gg.IdentityPosition, gg.ShiftPosition, gg.JitterPosition];
      ret = {};
      _.each(klasses, function(klass) {
        if (_.isArray(klass.aliases)) {
          return _.each(klass.aliases, function(alias) {
            return ret[alias] = klass;
          });
        } else {
          return ret[klass.aliases] = klass;
        }
      });
      return ret;
    };

    Position.fromSpec = function(layer, spec) {
      var klass, klasses, ret, type;
      klasses = gg.Position.klasses();
      if (_.isString(spec)) {
        type = spec;
        spec = {};
      } else {
        type = findGood([spec.type, spec.pos, "identity"]);
      }
      klass = klasses[type] || gg.IdentityPosition;
      ret = new klass(layer, spec);
      return ret;
    };

    return Position;

  })(gg.XForm);

  gg.IdentityPosition = (function(_super) {

    __extends(IdentityPosition, _super);

    function IdentityPosition() {
      return IdentityPosition.__super__.constructor.apply(this, arguments);
    }

    IdentityPosition.aliases = ["identity"];

    return IdentityPosition;

  })(gg.Position);

  gg.ShiftPosition = (function(_super) {

    __extends(ShiftPosition, _super);

    function ShiftPosition() {
      return ShiftPosition.__super__.constructor.apply(this, arguments);
    }

    ShiftPosition.aliases = ["shift"];

    ShiftPosition.prototype.parseSpec = function() {
      this.xShift = findGood([this.spec.x, 10]);
      this.yShift = findGood([this.spec.y, 10]);
      return ShiftPosition.__super__.parseSpec.apply(this, arguments);
    };

    ShiftPosition.prototype.compute = function(table, env) {
      var map, scale,
        _this = this;
      scale = Math.random();
      map = {
        x: function(v) {
          return v + _this.xShift;
        },
        y: function(v) {
          return v * scale;
        }
      };
      table.map(map);
      return table;
    };

    return ShiftPosition;

  })(gg.Position);

  gg.JitterPosition = (function(_super) {

    __extends(JitterPosition, _super);

    function JitterPosition() {
      return JitterPosition.__super__.constructor.apply(this, arguments);
    }

    JitterPosition.aliases = "jitter";

    JitterPosition.prototype.parseSpec = function() {
      this.scale = findGood([this.spec.scale, 0.2]);
      this.xScale = findGood([this.spec.xScale, this.spec.x, null]);
      this.yScale = findGood([this.spec.yScale, this.spec.y, null]);
      if ((this.xScale != null) || (this.yScale != null)) {
        this.xScale = this.xScale || 0;
        this.yScale = this.yScale || 0;
      } else {
        this.xScale = this.yScale = this.scale;
      }
      return JitterPosition.__super__.parseSpec.apply(this, arguments);
    };

    JitterPosition.prototype.compute = function(table, env) {
      var map, scales, xRange, xScale, yRange, yScale;
      scales = this.scales(table, env);
      xRange = scales.scale("x").range();
      yRange = scales.scale("y").range();
      xScale = (xRange[1] - xRange[0]) * this.xScale;
      yScale = (yRange[1] - yRange[0]) * this.yScale;
      map = {
        x: function(v) {
          return v + (0.5 - Math.random()) * xScale;
        },
        y: function(v) {
          return v + (0.5 - Math.random()) * yScale;
        }
      };
      table.map(map);
      return table;
    };

    return JitterPosition;

  })(gg.Position);

  gg.wf.Map = (function(_super) {

    __extends(Map, _super);

    function Map(spec) {
      this.spec = spec;
      this.mapping = findGood([this.spec.aes, this.spec.map, this.spec.mapping]);
    }

    Map.prototype.normalize = function() {
      var newmapping,
        _this = this;
      newmapping = {};
      return _.each(this.mapping, function(val, outkey) {
        if (typeof val in 'function') {
          return newmapping[outkey] = val;
        }
      });
    };

    return Map;

  })(gg.wf.Exec);

  gg.wf.Data = (function() {

    function Data(table, env) {
      this.table = table;
      this.env = env != null ? env : null;
      if (this.env == null) {
        this.env = new gg.wf.Env;
      }
    }

    Data.prototype.clone = function() {
      return new gg.wf.Data(this.table, this.env.clone());
    };

    Data.prototype.serialize = function() {
      return "";
    };

    return Data;

  })();

  gg.wf.Env = (function() {

    function Env(stack) {
      this.groupPairs = findGood([stack, []]);
    }

    Env.prototype.lastGroupPair = function() {
      if (this.groupPairs.length) {
        return _.last(this.groupPairs);
      } else {
        return null;
      }
    };

    Env.prototype.lastGroup = function() {
      if (this.groupPairs.length) {
        return _.last(this.groupPairs).val;
      } else {
        return null;
      }
    };

    Env.prototype.lastGroupName = function() {
      if (this.groupPairs.length) {
        return _.last(this.groupPairs).key;
      } else {
        return null;
      }
    };

    Env.prototype.popGroupPair = function() {
      return this.groupPairs.shift();
    };

    Env.prototype.pushGroupPair = function(key, val) {
      return this.groupPairs.push({
        key: key,
        val: val
      });
    };

    Env.prototype.group = function(key, defaultVal) {
      var idx, pair, _i, _len, _ref;
      if (defaultVal == null) {
        defaultVal = null;
      }
      _ref = _.range(this.groupPairs.length - 1, -1, -1);
      for (_i = 0, _len = _ref.length; _i < _len; _i++) {
        idx = _ref[_i];
        pair = this.groupPairs[idx];
        if (pair.key === key) {
          return pair.val;
        }
      }
      return defaultVal;
    };

    Env.prototype.clone = function() {
      return new gg.wf.Env(_.clone(this.groupPairs));
    };

    return Env;

  })();

  gg.wf.TableSource = (function(_super) {

    __extends(TableSource, _super);

    function TableSource(spec) {
      this.spec = spec;
      TableSource.__super__.constructor.call(this, this.spec);
      this.table = this.spec.table;
    }

    TableSource.prototype.compute = function() {
      return this.table;
    };

    return TableSource;

  })(gg.wf.Source);

  gg.Facets = (function() {

    function Facets(g, spec) {
      this.g = g;
      this.spec = spec != null ? spec : {};
      this.parseSpec();
      this.splitter = this.splitterNodes();
      this.panes = [];
      this.paneSvgMapper = {};
      this.xAxisSvgMapper = {};
      this.yAxisSvgMapper = {};
    }

    Facets.prototype.parseSpec = function() {
      this.x = findGood([
        this.spec.x, function() {
          return 1;
        }
      ]);
      this.y = findGood([
        this.spec.y, function() {
          return 1;
        }
      ]);
      this.scales = findGood([this.spec.scales, "fixed"]);
      this.type = findGood([this.spec.type, "grid"]);
      this.sizing = findGood([this.spec.sizing, this.spec.size, "fixed"]);
      this.facetXKey = "facetX";
      this.facetYKey = "facetY";
      this.margin = findGood([this.spec.margin, 10]);
      this.facetXLabel = findGoodAttr(this.spec, ['xlabel', 'xLabel', null]);
      this.facetYLabel = findGoodAttr(this.spec, ['ylabel', 'yLabel', null]);
      this.facetFontSize = findGood([this.spec.fontSize, this.spec['font-size'], "12pt"]);
      this.facetFontFamily = findGood([this.spec.fontFamily, this.spec['font-family'], "arial"]);
      this.facetPadding = findGood([this.spec.facetPadding, 5]);
      this.panePadding = findGood([this.spec.panePadding, 10]);
      return this.exSize = _.exSize({
        "font-size": this.facetFontSize,
        "font-family": this.facetFontFamily
      });
    };

    Facets.prototype.svgPane = function(facetX, facetY) {
      try {
        return this.paneSvgMapper[facetX][facetY];
      } catch (error) {
        throw error;
      }
    };

    Facets.prototype.createSplitterNode = function(facet, name) {
      var colnames, f,
        _this = this;
      if (_.isString(facet)) {
        return new gg.wf.Partition({
          f: (function(row) {
            return row.get(facet);
          }),
          name: name
        });
      } else if (_.isFunction(facet)) {
        return new gg.wf.Partition({
          f: facet,
          name: name
        });
      } else if (_.isArray(facet) && facet.length > 0) {
        if (_.isString(facet[0])) {
          colnames = facet;
          f = function(table) {
            return _.map(colnames, function(colname) {
              var newtable;
              newtable = table.clone();
              newtable.addColumn(name, table.getColumn(colname));
              return {
                key: colname,
                table: newtable
              };
            });
          };
          new gg.wf.Split({
            f: f,
            name: name
          });
        }
        return {
          "else": (function() {
            throw Error("Faceting by transformations not implemented yet");
          })()
        };
      }
    };

    Facets.prototype.splitterNodes = function() {
      var facetXNode, facetYNode;
      console.log("splitternode: " + this.facetXKey + ",  " + this.facetYKey);
      facetXNode = this.createSplitterNode(this.x, this.facetXKey);
      facetYNode = this.createSplitterNode(this.y, this.facetYKey);
      return [facetXNode, facetYNode];
    };

    Facets.prototype.labelerNodes = function() {
      var xjoin, xyjoin, yjoin,
        _this = this;
      xyjoin = new gg.wf.Barrier({
        name: "facetxy-join",
        f: function(ts, es, n) {
          var newts;
          newts = _.map(ts, function(t) {
            t = t.clone();
            t.addConstColumn(_this.facetXKey, e.group(_this.facetXKey, "1"));
            t.addConstColumn(_this.facetYKey, e.group(_this.facetYKey, "1"));
            return t;
          });
          return newts;
        }
      });
      xjoin = new gg.wf.Exec({
        name: "facetx-join",
        f: function(t, e, n) {
          t = t.clone();
          t.addConstColumn(_this.facetXKey, e.group(_this.facetXKey, "1"));
          return t;
        }
      });
      yjoin = new gg.wf.Exec({
        name: "facety-join",
        f: function(t, e, n) {
          t = t.clone();
          t.addConstColumn(_this.facetYKey, e.group(_this.facetYKey, "1"));
          return t;
        }
      });
      return [xjoin, yjoin];
    };

    Facets.prototype.collectXYs = function(tables, envs, node) {
      var _this = this;
      this.xs = {};
      this.ys = {};
      _.each(tables, function(table) {
        if (table.nrows() > 0) {
          _this.xs[table.get(0, _this.facetXKey)] = true;
          return _this.ys[table.get(0, _this.facetYKey)] = true;
        }
      });
      this.xs = _.uniq(_.keys(this.xs));
      this.ys = _.uniq(_.keys(this.ys));
      this.xs.sort();
      return this.ys.sort();
    };

    Facets.prototype.allocatePanesNode = function() {
      var _this = this;
      return new gg.wf.Barrier({
        f: function(tables, envs, node) {
          _this.collectXYs(tables, envs, node);
          _this.layoutFacets(tables, envs, node);
          _this.allocatePanes(tables, envs, node);
          return tables;
        }
      });
    };

    Facets.prototype.layoutFacets = function(tables, envs, node) {
      var facetTitleSize, h, hTitle, matrix, pDims, svgFacet, titleDims, w;
      w = this.g.wFacet;
      h = this.g.hFacet;
      svgFacet = this.g.svgFacet;
      _.subSvg(svgFacet, {
        "class": "plot-background",
        width: w,
        height: h
      }, "rect");
      facetTitleSize = "13pt";
      titleDims = _.exSize({
        "font-size": facetTitleSize,
        "font-family": "arial"
      });
      hTitle = titleDims.h + this.facetPadding;
      svgFacet.append("g").append("text").text(this.facetXLabel || this.x).attr("transform", "translate(" + hTitle + ", " + (this.facetPadding / 2) + ")").attr("dy", "1em").attr("dx", (w - 2 * hTitle) / 2).attr("text-anchor", "middle").attr("class", "facet-title").style("font-size", facetTitleSize).style("font-family", "arial");
      svgFacet.append("g").append("text").text(this.facetYLabel || this.y).attr("transform", "rotate(90)translate(" + (hTitle + (h - 2 * hTitle) / 2) + ",-" + (w - hTitle - this.facetPadding) + ")").attr("text-anchor", "middle").attr("class", "facet-title").style("font-size", facetTitleSize).style("fon-family", "arial");
      svgFacet.append("text").text("xaxis").attr("transform", "translate(" + hTitle + ", " + (h - hTitle - this.facetPadding) + ")").attr("dx", (w - 2 * hTitle) / 2).attr("text-anchor", "middle");
      svgFacet.append("text").text("yaxis").attr("transform", "rotate(-90)translate(" + (-(hTitle + (h - 2 * hTitle) / 2)) + "," + hTitle + ")").attr("text-anchor", "middle");
      pDims = {
        left: hTitle,
        top: hTitle,
        width: w - 2 * (hTitle - this.facetPadding),
        height: h - 2 * (hTitle - this.facetPadding),
        wRatio: (w - 2 * (hTitle - this.facetPadding)) / w,
        hRatio: (h - 2 * (hTitle - this.facetPadding)) / h
      };
      matrix = "" + pDims.wRatio + ",0,0," + pDims.hRatio + "," + pDims.left + "," + pDims.top;
      this.w = pDims.width;
      this.h = pDims.height;
      return this.svg = svgFacet.append('g').attr("class", "graphic-with-margin").attr("transform", "matrix(" + matrix + ")");
    };

    Facets.prototype.allocatePanes = function(tables, envs, node) {
      var dims, facetSize, formatter, maxVal, maxValF, paneHeight, paneOpts, paneWidth, rightFacetOpts, svg, svgL, svgPanes, svgRightLabels, svgTopLabels, topFacetOpts, xAxisOpts, xBand, xRange, yAxisOpts, yAxisWidth, yBand, yRange,
        _this = this;
      svg = this.svg;
      console.log("exSize: " + (JSON.stringify(this.exSize)));
      formatter = d3.format(",.0f");
      maxValF = function(s) {
        if (_.isNumber(s.scale('y').maxDomain())) {
          return s.scale('y').maxDomain();
        } else {
          return 0;
        }
      };
      maxVal = _.max(_.map(this.g.scales.scalesList, maxValF));
      dims = _.textSize(formatter(maxVal), {
        "font-size": "10pt",
        "font-family": "arial"
      });
      yAxisWidth = dims.w + 2 * this.facetPadding;
      facetSize = this.exSize.h + 2 * this.facetPadding;
      paneWidth = this.w - yAxisWidth - facetSize;
      paneHeight = this.h - 2 * facetSize;
      yAxisOpts = {
        left: 0,
        top: facetSize,
        width: yAxisWidth,
        height: this.h - facetSize,
        "class": "y-axis axis"
      };
      xAxisOpts = {
        left: yAxisWidth,
        top: this.h - facetSize,
        width: paneWidth,
        height: facetSize,
        "class": "x-axis axis"
      };
      topFacetOpts = {
        left: yAxisWidth,
        top: 0,
        width: paneWidth,
        height: facetSize
      };
      rightFacetOpts = {
        left: this.w - facetSize,
        top: facetSize,
        width: facetSize,
        height: paneHeight
      };
      paneOpts = {
        left: yAxisWidth,
        top: facetSize,
        width: paneWidth,
        height: paneHeight,
        "class": "facet-grid-container"
      };
      console.log(this.xs);
      console.log(this.ys);
      xRange = d3.scale.ordinal().domain(this.xs).rangeBands([0, paneWidth], 0.05, 0);
      yRange = d3.scale.ordinal().domain(this.ys).rangeBands([0, paneHeight], 0.05, 0);
      xBand = xRange.rangeBand();
      yBand = yRange.rangeBand();
      console.log("x/yBand: " + xBand + " / " + yBand + "\t" + paneWidth + " / " + paneHeight);
      this.setScalesRanges(xBand, yBand);
      console.log(topFacetOpts);
      svgL = _.subSvg(svg, {
        "class": "labels-container"
      });
      svgTopLabels = _.subSvg(svgL, topFacetOpts);
      this.renderTopLabels(svgTopLabels, xRange);
      svgRightLabels = _.subSvg(svgL, rightFacetOpts);
      this.renderRightLabels(svgRightLabels, yRange);
      svgPanes = _.subSvg(svg, paneOpts);
      return _.each(this.xs, function(x, xidx) {
        return _.each(_this.ys, function(y, yidx) {
          var left, svgBg, svgPane, top;
          left = xRange(x);
          top = yRange(y);
          svgPane = _.subSvg(svgPanes, {
            width: xBand,
            height: yBand,
            left: left,
            top: top,
            id: "facet-grid-" + xidx + "-" + yidx,
            "class": "facet-grid"
          });
          svgBg = svgPane.append('g');
          _.subSvg(svgBg, {
            width: xBand,
            height: yBand,
            "class": "facet-grid-background"
          }, "rect");
          _this.renderYAxis(svgBg, x, y, xRange, yRange);
          _this.renderXAxis(svgBg, x, y, xRange, yRange);
          if (!(x in _this.paneSvgMapper)) {
            _this.paneSvgMapper[x] = {};
          }
          return _this.paneSvgMapper[x][y] = svgPane;
        });
      });
    };

    Facets.prototype.renderYAxis = function(svg, x, y, xRange, yRange) {
      var left, scale, scales, top, xBand, yAxis;
      left = 0;
      top = 0;
      xBand = xRange.rangeBand();
      scales = this.g.scales.facetScales(x, y);
      scale = scales.scale('y');
      console.log("facet.renderYAxis\t" + (scale.domain()) + " -> " + (scale.range()));
      yAxis = d3.svg.axis().scale(scales.scale('y').d3()).ticks(5, d3.format(",.0f"), 5).tickSize(-xBand).orient('left');
      if (x !== this.xs[0]) {
        yAxis.tickFormat('');
      }
      return svg.append('g').attr('class', 'y axis').attr('transform', "translate(" + left + "," + top + ")").call(yAxis);
    };

    Facets.prototype.renderXAxis = function(svg, x, y, xRange, yRange) {
      var left, scales, top, xAxis, yBand;
      left = 0;
      top = 0;
      yBand = yRange.rangeBand();
      scales = this.g.scales.facetScales(x, y);
      xAxis = d3.svg.axis().scale(scales.scale('x').d3()).ticks(5).tickSize(-yBand).orient('bottom');
      if (y !== _.last(this.ys)) {
        xAxis.tickFormat('');
      }
      return svg.append('g').attr('class', 'x axis').attr('fill', 'none').attr('transform', "translate(0, " + yBand + ")").call(xAxis);
    };

    Facets.prototype.renderTopLabels = function(svg, xRange) {
      var enter, labels;
      labels = svg.selectAll("g").data(this.xs);
      enter = labels.enter().insert("g").attr("class", "facet-label x");
      enter.append("rect");
      enter.append("text");
      labels.select("text").text(String);
      enter.select("text").attr("x", function(d) {
        return xRange(d) + xRange.rangeBand() / 2;
      }).attr("y", this.facetPadding).attr("dy", "1em").style("font-size", this.facetFontSize).style("font-family", this.facetFontFamily);
      return enter.select("rect").attr("x", xRange).attr("y", 0).attr("width", xRange.rangeBand()).attr("height", svg.attr("height"));
    };

    Facets.prototype.renderRightLabels = function(svg, yRange) {
      var enter, labels;
      labels = svg.selectAll("g").data(this.ys);
      enter = labels.enter().insert("g").attr("class", "facet-label y");
      enter.append("rect");
      enter.append("text");
      labels.select("text").text(String);
      enter.select("text").attr("dx", ".5em").attr("y", function(d) {
        return yRange(d) + yRange.rangeBand() / 2;
      }).attr("rotate", 90).style("font-size", this.facetFontSize).style("font-family", this.facetFontFamily);
      return enter.select("rect").attr("x", 0).attr("y", yRange).attr("width", svg.attr("width")).attr("height", yRange.rangeBand());
    };

    Facets.prototype.expandDomains = function(scalesSet) {};

    Facets.prototype.trainScales = function() {
      var _this = this;
      this.masterScales = gg.ScalesSet.merge(this.g.scales.scalesList);
      this.expandDomains(this.masterScales);
      if (this.scales === "fixed") {
        return _.each(this.g.scales.scalesList, function(scalesSet) {
          return scalesSet.merge(_this.masterScales, false);
        });
      } else {
        return this.trainFreeScales();
      }
    };

    Facets.prototype.trainFreeScales = function() {
      var _this = this;
      this.xScales = _.map(this.xs, function(x) {
        return gg.ScalesSet.merge(_.map(_this.ys, function(y) {
          return _this.subFacets[x][y].scales;
        })).exclude(gg.Scale.ys);
      });
      this.yScales = _.map(this.ys, function(y) {
        return gg.ScalesSet.merge(_.map(_this.xs, function(x) {
          return _this.subFacets[x][y].scales;
        })).exclude(gg.Scale.xs);
      });
      return _.each(this.xs, function(x, xidx) {
        return _.each(_this.ys, function(y, yidx) {
          var layerScalesSets;
          layerScalesSets = _this.g.scales.scales(x, y);
          return _.each(layerScalesSets, function(ss) {
            ss.merge(_this.xScales[xidx], false);
            return ss.merge(_this.yScales[yidx], false);
          });
        });
      });
    };

    Facets.prototype.setScalesRanges = function(xBand, yBand) {
      var _this = this;
      return _.each(this.g.scales.scalesList, function(ss) {
        _.each(gg.Scale.xs, function(aes) {
          ss.scale(aes).range([0 + _this.panePadding, xBand - _this.panePadding]);
          return console.log("facet.setScalesRanges(" + aes + "):\t" + (ss.scale(aes).domain()) + " -> " + (ss.scale(aes).range()));
        });
        return _.each(gg.Scale.ys, function(aes) {
          ss.scale(aes).range([yBand - _this.panePadding, 0 + _this.panePadding]);
          return console.log("facet.setScalesRanges(" + aes + "):\t" + (ss.scale(aes).domain()) + " -> " + (ss.scale(aes).range()));
        });
      });
    };

    Facets.prototype.renderPanesFunc = function(tables, envs, barrier) {};

    Facets.prototype.renderPanes = function() {
      var _this = this;
      return new gg.wf.Barrier(function() {
        var args;
        args = 1 <= arguments.length ? __slice.call(arguments, 0) : [];
        return _this.renderPanesFunc.apply(_this, args);
      });
    };

    return Facets;

  })();

  gg.Layers = (function() {

    function Layers(g, spec) {
      this.g = g;
      this.spec = spec;
      this.layers = [];
      this.parseSpec();
    }

    Layers.prototype.parseSpec = function() {
      var _this = this;
      return _.each(this.spec, function(layerspec) {
        return _this.addLayer(layerspec);
      });
    };

    Layers.prototype.compile = function() {
      return _.map(this.layers, function(l) {
        return l.compile();
      });
    };

    Layers.prototype.getLayer = function(layerIdx) {
      if (layerIdx >= this.layers.length) {
        throw Error("Layer with idx " + layerIdx + " does not exist.          Max layer is " + this.layers.length);
      }
      return this.layers[layerIdx];
    };

    Layers.prototype.get = function(layerIdx) {
      return this.getLayer(layerIdx);
    };

    Layers.prototype.addLayer = function(layerOrSpec) {
      var layer, layerIdx, spec;
      layerIdx = this.layers.length;
      if (_.isSubclass(layerOrSpec, gg.Layer)) {
        layer = layerOrSpec;
      } else {
        spec = _.clone(layerOrSpec);
        spec.layerIdx = layerIdx;
        layer = gg.Layer.fromSpec(this.g, spec);
      }
      layer.layerIdx = layerIdx;
      return this.layers.push(layer);
    };

    return Layers;

  })();

  gg.Layer = (function() {

    function Layer(g, spec) {
      this.g = g;
      this.spec = spec != null ? spec : {};
      if (this.spec.layerIdx != null) {
        this.layerIdx = this.spec.layerIdx;
      }
      this.type = "layer";
      this.name = findGood([this.spec.name, "node-" + this.id]);
      this.parseSpec();
    }

    Layer.id = function() {
      return gg.wf.Node.prototype._id += 1;
    };

    Layer.prototype._id = 0;

    Layer.prototype.parseSpec = function() {
      return null;
    };

    Layer.fromSpec = function(g, spec) {
      if (_.isArray(spec)) {
        throw Error("layer currently only supports shorthand style");
      } else {
        return new gg.LayerShorthand(g, spec);
      }
    };

    return Layer;

  })();

  gg.LayerShorthand = (function(_super) {

    __extends(LayerShorthand, _super);

    function LayerShorthand(g, spec) {
      this.g = g;
      this.spec = spec != null ? spec : {};
      this.type = "layershort";
      LayerShorthand.__super__.constructor.apply(this, arguments);
    }

    LayerShorthand.prototype.aesthetics = function() {
      var aess, subSpecs;
      subSpecs = [this.mapSpec, this.geomSpec, this.statSpec, this.posSpec];
      aess = _.uniq(_.compact(_.union(_.map(subSpecs, function(s) {
        return _.keys(s.aes);
      }))));
      return aess;
    };

    LayerShorthand.prototype.parseSpec = function() {
      var mapSpec, spec;
      spec = this.spec;
      this.geomSpec = this.extractSpec("geom");
      this.statSpec = this.extractSpec("stat");
      this.posSpec = this.extractSpec("pos");
      mapSpec = findGoodAttr(spec, ['aes', 'aesthetic', 'mapping'], {});
      this.mapSpec = {
        aes: mapSpec,
        name: "map-shorthand"
      };
      this.labelSpec = {
        key: "layer",
        val: this.layerIdx
      };
      this.geom = gg.Geom.fromSpec(this, this.geomSpec);
      this.stat = gg.Stat.fromSpec(this, this.statSpec);
      this.pos = gg.Position.fromSpec(this, this.posSpec);
      this.map = new gg.Mapper(this.g, this.mapSpec);
      this.labelNode = new gg.wf.Label(this.labelSpec);
      return LayerShorthand.__super__.parseSpec.apply(this, arguments);
    };

    LayerShorthand.prototype.extractSpec = function(xform, spec) {
      var aliases, defaultType, subSpec, _ref;
      if (spec == null) {
        spec = null;
      }
      if (spec == null) {
        spec = this.spec;
      }
      _ref = (function() {
        switch (xform) {
          case "geom":
            return [['geom', 'geometry'], "point"];
          case "stat":
            return [['stat', 'stats', 'statistic'], "identity"];
          case "pos":
            return [["pos", "position"], "identity"];
          default:
            return [[], "identity"];
        }
      })(), aliases = _ref[0], defaultType = _ref[1];
      subSpec = findGoodAttr(spec, aliases, defaultType);
      if (_.isString(subSpec)) {
        subSpec = {
          type: subSpec,
          aes: {},
          param: {}
        };
      } else {
        if (subSpec.aes == null) {
          subSpec.aes = {};
        }
        if (subSpec.param == null) {
          subSpec.param = {};
        }
      }
      if (subSpec.name == null) {
        subSpec.name = "" + xform + "-shorthand";
      }
      return subSpec;
    };

    LayerShorthand.prototype.compile = function() {
      var nodes;
      console.log("layer.compile called");
      nodes = [];
      nodes.push(new gg.wf.Stdout({
        name: "initial data",
        n: 1
      }));
      nodes.push(this.labelNode);
      nodes.push(this.map);
      nodes.push(this.g.scales.prestatsNode);
      nodes.push(this.stat);
      nodes.push(this.g.facets.labelerNodes());
      nodes.push(new gg.wf.Stdout({
        name: "pre-geom",
        n: 1
      }));
      nodes.push(this.geom.map);
      nodes.push(this.g.scales.pregeomNode);
      nodes.push(new gg.wf.Stdout({
        name: "post-geom",
        n: 1
      }));
      nodes.push(this.g.layoutNode());
      nodes.push(this.g.facets.allocatePanesNode());
      nodes.push(new gg.wf.Stdout({
        name: "pre-pixel",
        n: 1
      }));
      nodes.push(this.geom.applyScales);
      nodes.push(this.geom.reparam);
      nodes.push(this.pos);
      nodes.push(new gg.wf.Stdout({
        name: "post:pixel",
        n: 1
      }));
      nodes.push(this.g.scales.prerenderNode);
      nodes.push(new gg.wf.Stdout({
        name: "position pixel",
        n: 1
      }));
      nodes.push(this.geom.render);
      nodes = this.compileNodes(nodes);
      console.log("returing nodes");
      return nodes;
    };

    LayerShorthand.prototype.compileNodes = function(nodes) {
      nodes = _.map(_.compact(nodes), function(node) {
        if (_.isSubclass(node, gg.XForm)) {
          return node.compile();
        } else {
          return node;
        }
      });
      return _.compact(_.flatten(nodes));
    };

    return LayerShorthand;

  })(gg.Layer);

  gg.LayerArray = (function() {

    function LayerArray() {}

    LayerArray.prototype.xformToString = function(xform) {
      if (_.isSubclass(xform, gg.Stat)) {
        return "S";
      } else if (_.isSubclass(xform, gg.Mapper)) {
        return "M";
      } else if (_.isSubclass(xform, gg.Position)) {
        return "P";
      } else if (_.isSubclass(xform, gg.GeomRender)) {
        return "R";
      } else if (_.isSubclass(xform, gg.Geom)) {
        return "G";
      }
    };

    LayerArray.prototype.parseArraySpec = function(spec) {
      var eidx, entireStr, geom, geomChars, klassStr, klasses, sidx, statChars, validregex, _ref, _ref1, _ref2,
        _this = this;
      this.xforms = _.map(spec, function(xformspec) {
        return gg.XForm.fromSpec(xformspec);
      });
      klasses = _.map(this.xforms, function(xform) {
        return _this.xformToString(xform);
      });
      klassStr = klasses.join("");
      validregex = /^([MS]*)(G|(?:M?P?R))$/;
      if (!regex.test(klassStr)) {
        throw Error("Layer: series of XForms not valid (" + klassStr + ")");
      }
      _ref = validregex.exec(klassStr), entireStr = _ref[0], statChars = _ref[1], geomChars = _ref[2];
      _ref1 = [s, statChars.length()], sidx = _ref1[0], eidx = _ref1[1];
      this.stats = this.xforms.slice(sidx, eidx);
      _ref2 = [eidx, eidx + geomChars.length()], sidx = _ref2[0], eidx = _ref2[1];
      throw Error("gg.Geom.parseArraySpec: not implemented. Needs to be thought through");
      this.geoms = this.xforms.slice(sidx, eidx);
      if (geomChars === "G") {
        geom = this.geoms[0];
        this.geoms = [geom.mappingXForm(), geom.positionXForm()];
        return this.renders = [geom.renderXForm()];
      } else {
        this.renders = [_.last(this.geoms)];
        return this.geoms = _.initial(this.geoms);
      }
    };

    return LayerArray;

  })();

  gg.Stat = (function(_super) {

    __extends(Stat, _super);

    function Stat(layer, spec) {
      this.layer = layer;
      this.spec = spec != null ? spec : {};
      Stat.__super__.constructor.call(this, this.layer.g, this.spec);
      this.parseSpec();
    }

    Stat.klasses = function() {
      var klasses, ret;
      klasses = [gg.IdentityStat, gg.Bin1DStat];
      ret = {};
      _.each(klasses, function(klass) {
        if (_.isArray(klass.aliases)) {
          return _.each(klass.aliases, function(alias) {
            return ret[alias] = klass;
          });
        } else {
          return ret[klass.aliases] = klass;
        }
      });
      return ret;
    };

    Stat.fromSpec = function(layer, spec) {
      var klass, klasses, ret, type;
      klasses = gg.Stat.klasses();
      console.log(klasses);
      if (_.isString(spec)) {
        type = spec;
        spec = {};
      } else {
        type = findGood([spec.type, spec.stat, "identity"]);
      }
      klass = klasses[type] || gg.IdentityStat;
      ret = new klass(layer, spec);
      return ret;
    };

    return Stat;

  })(gg.XForm);

  gg.IdentityStat = (function(_super) {

    __extends(IdentityStat, _super);

    function IdentityStat() {
      return IdentityStat.__super__.constructor.apply(this, arguments);
    }

    IdentityStat.aliases = ['identity'];

    return IdentityStat;

  })(gg.Stat);

  gg.Bin1DStat = (function(_super) {

    __extends(Bin1DStat, _super);

    function Bin1DStat() {
      return Bin1DStat.__super__.constructor.apply(this, arguments);
    }

    Bin1DStat.aliases = ['1dbin', 'bin', 'bin1d'];

    Bin1DStat.prototype.parseSpec = function() {
      this.nbins = findGood([this.spec.nbins, this.spec.bins, 30]);
      return Bin1DStat.__super__.parseSpec.apply(this, arguments);
    };

    Bin1DStat.prototype.inputSchema = function(table, env, node) {
      return ['x'];
    };

    Bin1DStat.prototype.outputSchema = function(table, env, node) {
      return ['x', 'y', 'bin', 'count', 'total'];
    };

    Bin1DStat.prototype.compute = function(table, env, node) {
      var binSize, domain, range, scales, stats;
      scales = this.scales(table, env);
      domain = scales.scale('x').domain();
      domain = scales.scale('x').defaultDomain(table.getColumn('x'));
      range = domain[1] - domain[0];
      binSize = Math.ceil(range / this.nbins);
      console.log("nbins: " + this.nbins + "\tscaleid: " + (scales.scale('x').id) + "\tscaledomain: " + (scales.scale('x').domain()) + "\tdomain: " + domain + "\tbinSize: " + binSize);
      stats = _.map(_.range(Math.ceil(range / binSize) + 1), function(binidx) {
        return {
          bin: binidx,
          count: 0,
          total: 0
        };
      });
      table.each(function(row) {
        var binidx, x, y;
        x = row.get('x');
        y = row.get('y');
        binidx = Math.floor((x - domain[0]) / binSize);
        try {
          stats[binidx].count += 1;
        } catch (error) {
          console.log("Bin1D.compute: " + error);
          console.log("fetch bin: val(" + x + "):  " + binidx + " of " + stats.length);
          return;
        }
        if (_.isNumber(y)) {
          return stats[binidx].total += y;
        } else {
          return stats[binidx].total += 1;
        }
      });
      _.each(stats, function(stat) {
        stat.bin = (stat.bin * binSize) + domain[0] + binSize / 2;
        stat.sum = stat.total;
        stat.x = stat.bin;
        return stat.y = stat.count;
      });
      return new gg.RowTable(stats);
    };

    return Bin1DStat;

  })(gg.Stat);

  gg.Geom = (function() {

    function Geom(layer, spec) {
      this.layer = layer;
      this.spec = spec;
      this.g = this.layer.g;
      this.render = null;
      this.applyScales = null;
      this.map = null;
      this.reparam = null;
      this.parseSpec();
    }

    Geom.prototype.parseSpec = function() {
      this.render = gg.GeomRender.fromSpec(this.layer, this.spec.type);
      this.applyScales = new gg.ScalesApply(this.layer, {
        name: "applyScales"
      });
      return this.map = new gg.Mapper(this.g, this.spec);
    };

    Geom.prototype.name = function() {
      return this.constructor.name.toLowerCase();
    };

    Geom.klasses = function() {
      var klasses, ret;
      klasses = [gg.Point, gg.Line, gg.Step, gg.Path, gg.Area, gg.Interval, gg.Rect, gg.Polygon, gg.Hex, gg.Schema, gg.Glyph, gg.Edge];
      ret = {};
      _.each(klasses, function(klass) {
        if (_.isArray(klass.aliases)) {
          return _.each(klass.aliases, function(alias) {
            return ret[alias] = klass;
          });
        } else {
          return ret[klass.aliases] = klass;
        }
      });
      return ret;
    };

    Geom.fromSpec = function(layer, spec) {
      var geom, klass, klasses;
      spec = _.clone(spec);
      klasses = gg.Geom.klasses();
      klass = klasses[spec.type] || gg.Point;
      if (spec.name == null) {
        spec.name = klass.name;
      }
      geom = new klass(layer, spec);
      console.log("geom.fromSpec\t" + (JSON.stringify(spec)));
      console.log("geom klass: " + spec.type + " -> " + klass.name);
      return geom;
    };

    return Geom;

  })();

  gg.Point = (function(_super) {

    __extends(Point, _super);

    function Point() {
      return Point.__super__.constructor.apply(this, arguments);
    }

    Point.aliases = ["point"];

    Point.prototype.parseSpec = function() {
      var reparamSpec;
      Point.__super__.parseSpec.apply(this, arguments);
      console.log("hello");
      reparamSpec = {
        name: "point-reparam",
        inputSchema: ['x', 'y'],
        map: {
          x: 'x',
          y: 'y',
          r: 'r',
          x0: 'x',
          x1: 'x',
          y0: 'y',
          y1: 'y'
        }
      };
      this.reparam = new gg.Mapper(this.g, reparamSpec);
      return this.render = new gg.GeomRenderPointSvg(this.layer, {});
    };

    return Point;

  })(gg.Geom);

  gg.Line = (function(_super) {

    __extends(Line, _super);

    function Line() {
      return Line.__super__.constructor.apply(this, arguments);
    }

    Line.aliases = "line";

    return Line;

  })(gg.Geom);

  gg.Step = (function(_super) {

    __extends(Step, _super);

    function Step() {
      return Step.__super__.constructor.apply(this, arguments);
    }

    Step.aliases = "step";

    return Step;

  })(gg.Geom);

  gg.Path = (function(_super) {

    __extends(Path, _super);

    function Path() {
      return Path.__super__.constructor.apply(this, arguments);
    }

    Path.aliases = "path";

    return Path;

  })(gg.Geom);

  gg.Area = (function(_super) {

    __extends(Area, _super);

    function Area() {
      return Area.__super__.constructor.apply(this, arguments);
    }

    Area.aliases = "area";

    return Area;

  })(gg.Geom);

  gg.Interval = (function(_super) {

    __extends(Interval, _super);

    function Interval() {
      return Interval.__super__.constructor.apply(this, arguments);
    }

    Interval.aliases = ["interval", "rect"];

    Interval.prototype.parseSpec = function() {
      Interval.__super__.parseSpec.apply(this, arguments);
      this.reparam = new gg.ReparamInterval(this.g, {
        name: "interval-reparam"
      });
      return this.render = new gg.GeomRenderRectSvg(this.layer, {});
    };

    return Interval;

  })(gg.Geom);

  gg.ReparamInterval = (function(_super) {

    __extends(ReparamInterval, _super);

    function ReparamInterval(g, spec) {
      this.g = g;
      this.spec = spec;
      ReparamInterval.__super__.constructor.apply(this, arguments);
      this.parseSpec();
    }

    ReparamInterval.prototype.parseSpec = function() {
      return ReparamInterval.__super__.parseSpec.apply(this, arguments);
    };

    ReparamInterval.prototype.inputSchema = function() {
      return ['x', 'y'];
    };

    ReparamInterval.prototype.compute = function(table, env, node) {
      var diffs, mindiff, scales, width, xs, yscale;
      scales = this.scales(table, env);
      yscale = scales.scale('y');
      xs = _.uniq(table.getColumn("x")).sort(function(a, b) {
        return a - b;
      });
      diffs = _.map(_.range(xs.length - 1), function(idx) {
        return xs[idx + 1] - xs[idx];
      });
      mindiff = _.min(diffs || 1);
      width = mindiff * 0.8;
      table.transform({
        x: 'x',
        y: 'y',
        r: 'r',
        x0: function(row) {
          return row.get('x') - width / 2.0;
        },
        x1: function(row) {
          return row.get('x') + width / 2.0;
        },
        y0: function(row) {
          return yscale.scale(Math.min(yscale.minDomain(), yscale.invert(row.get('y'))));
        },
        y1: function(row) {
          return yscale.scale(Math.max(yscale.minDomain(), yscale.invert(row.get('y'))));
        }
      }, true);
      return table;
    };

    return ReparamInterval;

  })(gg.XForm);

  gg.Rect = (function(_super) {

    __extends(Rect, _super);

    function Rect() {
      return Rect.__super__.constructor.apply(this, arguments);
    }

    Rect.aliases = "rect";

    return Rect;

  })(gg.Geom);

  gg.Polygon = (function(_super) {

    __extends(Polygon, _super);

    function Polygon() {
      return Polygon.__super__.constructor.apply(this, arguments);
    }

    Polygon.aliases = "polygon";

    return Polygon;

  })(gg.Geom);

  gg.Hex = (function(_super) {

    __extends(Hex, _super);

    function Hex() {
      return Hex.__super__.constructor.apply(this, arguments);
    }

    Hex.aliases = "hex";

    return Hex;

  })(gg.Geom);

  gg.Schema = (function(_super) {

    __extends(Schema, _super);

    function Schema() {
      return Schema.__super__.constructor.apply(this, arguments);
    }

    Schema.aliases = "schema";

    return Schema;

  })(gg.Geom);

  gg.Glyph = (function(_super) {

    __extends(Glyph, _super);

    function Glyph() {
      return Glyph.__super__.constructor.apply(this, arguments);
    }

    Glyph.aliases = "glyph";

    return Glyph;

  })(gg.Geom);

  gg.Edge = (function(_super) {

    __extends(Edge, _super);

    function Edge() {
      return Edge.__super__.constructor.apply(this, arguments);
    }

    Edge.aliases = "edge";

    return Edge;

  })(gg.Geom);

  events = require('events');

  gg.wf.Flow = (function(_super) {

    __extends(Flow, _super);

    function Flow(spec) {
      this.spec = spec != null ? spec : {};
      this.nodes = [];
      this.id2node = [];
      this.inId2outId = {};
      this.outId2inId = {};
      this.edgeWeights = {};
      this.g = this.spec.g;
    }

    Flow.prototype.add = function(node) {
      if (!(node.id in this.id2node)) {
        if (node.wf != null) {
          console.log("Caution: node already has a workflow");
        }
        node.wf = this;
        this.nodes.push(node);
        this.id2node[node.id] = node;
        this.inId2outId[node.id] = [];
        this.outId2inId[node.id] = [];
      }
      return this;
    };

    Flow.prototype.connect = function(from, to) {
      var edge;
      if (!(from.id in this.id2node)) {
        this.add(from);
      }
      if (!(to.id in this.id2node)) {
        this.add(to);
      }
      this.inId2outId[from.id].push(to.id);
      this.outId2inId[to.id].push(from.id);
      edge = JSON.stringify([from.id, to.id]);
      if (!(edge in this.edgeWeights)) {
        this.edgeWeights[edge] = 0;
      }
      this.edgeWeights[edge] += 1;
      console.log("connect " + from.name + "\t" + to.name);
      return this;
    };

    Flow.prototype.edgeWeight = function(from, to) {
      var edge;
      edge = JSON.stringify([from.id, to.id]);
      return this.edgeWeights[edge] || 0;
    };

    Flow.prototype.sources = function() {
      var _this = this;
      return _.filter(this.nodes, function(node) {
        return !(node.id in _this.outId2inId) || _.size(_this.outId2inId[node.id]) === 0;
      });
    };

    Flow.prototype.sinks = function() {
      var _this = this;
      return _.filter(this.nodes, function(node) {
        return !(node.id in _this.inId2outId) || _.size(_this.inId2outId[node.id]) === 0;
      });
    };

    Flow.prototype.children = function(node) {
      var id;
      return _.compact(_.flatten([
        (function() {
          var _i, _len, _ref, _results;
          _ref = this.inId2outId[node.id] || [];
          _results = [];
          for (_i = 0, _len = _ref.length; _i < _len; _i++) {
            id = _ref[_i];
            _results.push(this.id2node[id]);
          }
          return _results;
        }).call(this)
      ]));
    };

    Flow.prototype.parents = function(node) {
      var id;
      return _.compact(_.flatten([
        (function() {
          var _i, _len, _ref, _results;
          _ref = this.outId2inId[node.id] || [];
          _results = [];
          for (_i = 0, _len = _ref.length; _i < _len; _i++) {
            id = _ref[_i];
            _results.push(this.id2node[id]);
          }
          return _results;
        }).call(this)
      ]));
    };

    Flow.prototype.instantiate = function(node, barriercache) {
      var cb, child, childcb, childclone, clone, i, idx, root, sources, _i, _j, _len, _len1, _ref, _ref1, _ref2, _ref3, _ref4;
      if (node == null) {
        node = null;
      }
      if (barriercache == null) {
        barriercache = {};
      }
      if (node != null) {
        if (node.id in barriercache) {
          _ref = barriercache[node.id], clone = _ref[0], idx = _ref[1];
          barriercache[node.id] = [clone, idx + 1];
          console.log("" + node.name + "-" + node.id + "\tcache hit! port " + (idx + 1));
          return [clone, clone.getAddInputCB(idx + 1)];
        }
        _ref1 = node.clone(), clone = _ref1[0], cb = _ref1[1];
        _ref2 = this.children(node);
        for (_i = 0, _len = _ref2.length; _i < _len; _i++) {
          child = _ref2[_i];
          _ref3 = _.range(this.edgeWeight(node, child));
          for (_j = 0, _len1 = _ref3.length; _j < _len1; _j++) {
            i = _ref3[_j];
            console.log("instantiate child: " + node.name + "-" + node.id + "\t" + child.name + "-" + child.id + "\t" + (_.isSubclass(node, gg.wf.Barrier)));
            _ref4 = this.instantiate(child, barriercache), childclone = _ref4[0], childcb = _ref4[1];
            clone.addChild(childclone, childcb);
          }
        }
        if (_.isSubclass(node, gg.wf.Barrier)) {
          console.log("caching clone of " + node.name + "-" + node.id);
          barriercache[node.id] = [clone, 0];
        }
        return [clone, cb];
      } else {
        sources = this.sources();
        return root = (function() {
          var _this = this;
          switch (sources.length) {
            case 0:
              throw Error("not sources, cannot instantiate");
              break;
            case 1:
              return this.instantiate(sources[0]);
            default:
              root = new gg.wf.Multicast;
              _.each(sources, function(source) {
                var srccb, srcclone, _ref5;
                _ref5 = _this.instantiate(source, barriercache), srcclone = _ref5[0], srccb = _ref5[1];
                return root.addChild(srcclone, srccb);
              });
              return [root, root.getAddInputCB(0)];
          }
        }).call(this);
      }
    };

    Flow.prototype.run = function(table) {
      var root, rootcb, runner, source, _ref,
        _this = this;
      _ref = this.instantiate(), root = _ref[0], rootcb = _ref[1];
      if (table != null) {
        source = new gg.wf.TableSource({
          wf: this,
          table: table
        });
        source.addChild(root, rootcb);
        root = source;
      }
      runner = new gg.wf.Runner(root);
      runner.on("output", function(id, data) {
        return _this.emit("output", id, data);
      });
      return runner.run();
    };

    Flow.prototype.visitBFS = function(f) {
      var node, queue, seen, _results;
      queue = this.sources();
      seen = {};
      _results = [];
      while (_.size(queue)) {
        node = queue.shift();
        if (node.id in seen) {
          continue;
        }
        seen[node.id] = true;
        f(node);
        _results.push(_.each(this.children(node), function(child) {
          if ((child != null) && !(child.id in seen)) {
            return queue.push(child);
          }
        }));
      }
      return _results;
    };

    Flow.prototype.visitDFS = function(f, node, seen) {
      var _this = this;
      if (node == null) {
        node = null;
      }
      if (seen == null) {
        seen = null;
      }
      if (seen == null) {
        seen = {};
      }
      if (node != null) {
        if (node.id in seen) {
          return;
        }
        seen[node.id] = true;
        f(node);
        return _.each(this.children(node), function(child) {
          return _this.visitDFS(f, child, seen);
        });
      } else {
        return _.each(this.sources(), function(child) {
          return _this.visitDFS(f, child, seen);
        });
      }
    };

    Flow.prototype.toString = function() {
      var arr, f,
        _this = this;
      arr = [];
      f = function(node) {
        var childnames, cns;
        childnames = _.map(_this.children(node), function(c) {
          return c.name;
        });
        cns = childnames.join(', ') || "SINK";
        return arr.push("" + node.name + "\t->\t" + cns);
      };
      this.visitBFS(f);
      return arr.join("\n");
    };

    Flow.prototype.setChild = function(klass, specOrNode) {
      var node, prevNode;
      if (specOrNode == null) {
        specOrNode = {};
      }
      if (_.isSubclass(specOrNode, gg.wf.Node)) {
        node = specOrNode;
      } else if (_.isFunction(specOrNode)) {
        node = new klass({
          f: specOrNode
        });
      } else {
        node = new klass(specOrNode);
      }
      prevNode = _.last(this.nodes) || null;
      if (prevNode != null) {
        this.connect(prevNode, node);
      }
      this.add(node);
      return this;
    };

    Flow.prototype.isNode = function(specOrNode) {
      return !(specOrNode.constructor.name === 'Object');
    };

    Flow.prototype.node = function(node) {
      return this.setChild(null, node);
    };

    Flow.prototype.exec = function(specOrNode) {
      return this.setChild(gg.wf.Exec, specOrNode);
    };

    Flow.prototype.split = function(specOrNode) {
      return this.setChild(gg.wf.Split, specOrNode);
    };

    Flow.prototype.partition = function(specOrNode) {
      return this.setChild(gg.wf.Partition, specOrNode);
    };

    Flow.prototype.join = function(specOrNode) {
      return this.setChild(gg.wf.Join, specOrNode);
    };

    Flow.prototype.barrier = function(specOrNode) {
      return this.setChild(gg.wf.Barrier, specOrNode);
    };

    Flow.prototype.multicast = function(specOrNode) {
      return this.setChild(gg.wf.Multicast, specOrNode);
    };

    Flow.prototype.extend = function(nodes) {
      var _this = this;
      return _.each(nodes, function(node) {
        return _this.setChild(null, node);
      });
    };

    return Flow;

  })(events.EventEmitter);

  gg.wf.Rule = (function() {

    function Rule() {}

    return Rule;

  })();

  gg.wf.Optimizer = (function() {

    function Optimizer(rules) {
      this.rules = rules;
    }

    Optimizer.prototype.optimize = function(flow) {
      return flow;
    };

    return Optimizer;

  })();

  gg.wf.Runner = (function(_super) {

    __extends(Runner, _super);

    function Runner(root) {
      this.root = root;
    }

    Runner.prototype.run = function() {
      var cur, firstUnready, nextNode, nprocessed, queue, results, seen, _i, _len, _ref,
        _this = this;
      queue = new gg.UniqQueue([this.root]);
      seen = {};
      results = [];
      nprocessed = 0;
      firstUnready = null;
      while (!queue.empty()) {
        cur = queue.pop();
        if (cur == null) {
          continue;
        }
        if (cur.id in seen) {
          continue;
        }
        console.log("run " + cur.name + " id:" + cur.id + " with " + (cur.nChildren()) + " children");
        if (cur.ready()) {
          nprocessed += 1;
          if (!cur.nChildren()) {
            cur.addOutputHandler(0, function(id, result) {
              return _this.emit("output", id, result.table);
            });
          }
          cur.run();
          seen[cur.id] = true;
          _ref = _.compact(_.flatten(cur.children));
          for (_i = 0, _len = _ref.length; _i < _len; _i++) {
            nextNode = _ref[_i];
            if (!(nextNode in seen)) {
              queue.push(nextNode);
            }
          }
        } else {
          console.log("not ready " + cur.name + " id: " + cur.id + ".  " + cur.inputs.length + ", " + cur.children.length);
          if (firstUnready === cur) {
            console.log("" + cur.name + " inputs: " + cur.inputs.length);
            console.log("" + cur.name + " parents: " + (_.map(cur.parents, function(p) {
              return p.name;
            }).join(',')));
            console.log("" + cur.name + " children: " + (_.map(cur.children, function(p) {
              return p.name;
            }).join(',')));
            throw Error("could not make progress.  Stopping on " + cur.name);
          }
          if (firstUnready == null) {
            firstUnready = cur;
            nprocessed = 0;
          }
          queue.push(cur);
        }
      }
      return this.emit("done", true);
    };

    return Runner;

  })(events.EventEmitter);

  gg.Table = (function() {

    function Table() {}

    Table.reEvalJS = /^{.*}$/;

    Table.reVariable = /^[a-zA-Z]\w*$/;

    Table.prototype.type = function(colname) {
      var val;
      val = this.get(0, colname);
      if (val != null) {
        return typeof val;
      } else {
        return 'unknown';
      }
    };

    Table.prototype.nrows = function() {
      throw "not implemented";
    };

    Table.prototype.ncols = function() {
      throw "not implemented";
    };

    Table.prototype.colNames = function() {
      throw "not implemented";
    };

    Table.prototype.contains = function(colName) {
      return __indexOf.call(this.colNames(), colName) >= 0;
    };

    Table.merge = function(tables) {
      return gg.RowTable.merge(tables);
    };

    Table.prototype.each = function(f, n) {
      var _this = this;
      if (n == null) {
        n = null;
      }
      return _.each(_.range(n != null ? n : this.nrows()), function(i) {
        return f(_this.get(i), i);
      });
    };

    Table.prototype.map = function(fOrMap, colName) {
      if (colName == null) {
        colName = null;
      }
      throw Error("not implemented");
    };

    Table.prototype.clone = function() {
      return this.cloneShallow();
    };

    Table.prototype.cloneShallow = function() {
      throw "not implemented";
    };

    Table.prototype.cloneDeep = function() {
      throw "not implemented";
    };

    Table.prototype.merge = function(table) {
      throw "not implemented";
    };

    Table.prototype.split = function(gbfunc) {
      throw "not implemented";
    };

    Table.prototype.transform = function(colname, func) {
      throw "not implemented";
    };

    Table.prototype.filter = function(f) {
      throw Error("not implemented");
    };

    Table.prototype.addConstColumn = function(name, val, type) {
      if (type == null) {
        type = null;
      }
      throw "not implemented";
    };

    Table.prototype.addColumn = function(name, vals, type) {
      if (type == null) {
        type = null;
      }
      throw "not implemented";
    };

    Table.prototype.addRow = function(row) {
      throw "not implemented";
    };

    Table.prototype.get = function(row, col) {
      if (col == null) {
        col = null;
      }
      throw "not implemented";
    };

    Table.prototype.asArray = function() {
      throw "not implemented";
    };

    return Table;

  })();

  gg.RowTable = (function(_super) {

    __extends(RowTable, _super);

    function RowTable(rows) {
      var _this = this;
      if (rows == null) {
        rows = [];
      }
      this.rows = [];
      _.each(rows, function(row) {
        return _this.addRow(row);
      });
    }

    RowTable.toTuple = function(row) {
      row.get = function(attr, defaultVal) {
        var val;
        if (defaultVal == null) {
          defaultVal = null;
        }
        val = row[attr];
        if (_.isFunction(val)) {
          return val(row);
        } else {
          if (val != null) {
            return val;
          } else {
            return defaultVal;
          }
        }
      };
      row.ncols = function() {
        return _.size(row) - 2;
      };
      return row;
    };

    RowTable.prototype.nrows = function() {
      return this.rows.length;
    };

    RowTable.prototype.ncols = function() {
      if (this.nrows() > 0) {
        return this.rows[0].ncols();
      } else {
        return 0;
      }
    };

    RowTable.prototype.colNames = function() {
      if (this.nrows() === 0) {
        throw Error("no rows to extract schema from");
      } else {
        return _.keys(this.get(0));
      }
    };

    RowTable.prototype.cloneShallow = function() {
      return new gg.RowTable(this.rows.map(function(row) {
        return row;
      }));
    };

    RowTable.prototype.cloneDeep = function() {
      var _this = this;
      return new gg.RowTable(this.rows.map(function(row) {
        return gg.RowTable.toTuple(_.clone(row));
      }));
    };

    RowTable.prototype.merge = function(table) {
      if (this.constructor.name === "RowTable") {
        this.rows.push.apply(this.rows, table.rows);
      } else {
        throw Error("merge not implemented for " + this.constructor.name);
      }
      return this;
    };

    RowTable.merge = function(tables) {
      var idx, t, t2, _i, _len;
      if (tables.length === 0) {
        return new gg.RowTable([]);
      } else {
        t = tables[0].cloneShallow();
        for (idx = _i = 0, _len = tables.length; _i < _len; idx = ++_i) {
          t2 = tables[idx];
          if (idx > 0) {
            t.merge(t2);
          }
        }
        return t;
      }
    };

    RowTable.prototype.split = function(gbfunc) {
      var groups, ret;
      if (_.isString(gbfunc)) {
        gbfunc = (function(key) {
          return function(tuple) {
            return tuple.get(key);
          };
        })(gbfunc);
      }
      groups = {};
      this.rows.forEach(function(row) {
        var key;
        key = JSON.stringify(gbfunc(row));
        if (!(key in groups)) {
          groups[key] = new gg.RowTable();
        }
        return groups[key].addRow(row);
      });
      ret = [];
      _.each(groups, function(partition, key) {
        return ret.push({
          key: JSON.parse(key),
          table: partition
        });
      });
      return ret;
    };

    RowTable.prototype.transform = function(colname, funcOrUpdate, update) {
      var funcs, mapping, newrows, strings,
        _this = this;
      if (funcOrUpdate == null) {
        funcOrUpdate = true;
      }
      if (update == null) {
        update = true;
      }
      if (_.isObject(colname)) {
        mapping = colname;
        update = funcOrUpdate;
      } else {
        mapping = {};
        mapping[colname] = funcOrUpdate;
      }
      funcs = {};
      strings = {};
      if (update) {
        _.each(this.rows, function(row) {
          var newrow;
          newrow = _this.transformRow(row, mapping, funcs, strings);
          return _.extend(row, newrow);
        });
        return this;
      } else {
        newrows = _.map(this.rows, function(row) {
          return _this.transformRow(row, mapping, funcs, strings);
        });
        return new gg.RowTable(newrows);
      }
    };

    RowTable.prototype.transformRow = function(row, mapping, funcs, strings) {
      var map, ret,
        _this = this;
      if (funcs == null) {
        funcs = {};
      }
      if (strings == null) {
        strings = {};
      }
      ret = {};
      map = function(oldattr, newattr) {
        var cmd, cmds, fcmd, userCode, variableF;
        if (_.isFunction(oldattr)) {
          return oldattr(row);
        } else if (oldattr in row) {
          return row[oldattr];
        } else if (newattr in strings) {
          return strings[newattr];
        } else if (newattr !== 'text' && gg.Table.reEvalJS.test(oldattr)) {
          if (!(newattr in funcs)) {
            userCode = oldattr.slice(1, oldattr.length - 1);
            variableF = function(val, k) {
              if (gg.Table.reVariable.test(k)) {
                return "var " + k + " = row['" + k + "'];";
              } else {
                return null;
              }
            };
            cmds = _.compact(_.map(row, variableF));
            cmds.push("return " + userCode + ";");
            cmd = cmds.join('');
            fcmd = "var __func__ = function(row) {" + cmd + "}";
            console.log(fcmd);
            eval(fcmd);
            funcs[newattr] = __func__;
          }
          return funcs[newattr](row);
        } else {
          return oldattr;
        }
      };
      _.each(mapping, function(oldattr, newattr) {
        return ret[newattr] = (function() {
          try {
            return map(oldattr, newattr);
          } catch (error) {
            console.log(error);
            throw error;
          }
        })();
      });
      return ret;
    };

    RowTable.prototype.filter = function(f) {
      var newrows;
      newrows = [];
      this.each(function(row, idx) {
        if (f(row)) {
          return newrows.push(row);
        }
      });
      return new gg.RowTable(newrows);
    };

    RowTable.prototype.map = function(fOrMap, colName) {
      var f;
      if (colName == null) {
        colName = null;
      }
      if (_.isFunction(fOrMap)) {
        f = fOrMap;
        if (colName != null) {
          this.each(function(row, idx) {
            return row[colName] = f(row[colName]);
          });
        } else {
          throw Error("RowTable.map without a colname is not implemented");
        }
      } else if (_.isObject(fOrMap)) {
        this.each(function(row, idx) {
          return _.each(fOrMap, function(f, col) {
            return row[col] = f(row[col]);
          });
        });
      } else {
        throw Error("RowTable.map: invalid arguments: " + arguments);
      }
      return this;
    };

    RowTable.prototype.addConstColumn = function(name, val, type) {
      if (type == null) {
        type = null;
      }
      return this.addColumn(name, _.repeat(this.nrows(), val), type);
    };

    RowTable.prototype.addColumn = function(name, vals, type) {
      var _this = this;
      if (type == null) {
        type = null;
      }
      if (vals.length !== this.nrows()) {
        throw Error("column has " + vals.length + " values, table has " + this.rows.length + " rows");
      }
      this.rows.forEach(function(row, idx) {
        return row[name] = vals[idx];
      });
      return this;
    };

    RowTable.prototype.addRow = function(row) {
      this.rows.push(gg.RowTable.toTuple(row));
      return this;
    };

    RowTable.prototype.get = function(row, col) {
      if (col == null) {
        col = null;
      }
      if (row >= 0 && row < this.rows.length) {
        if (col != null) {
          return this.rows[row][col];
        } else {
          return this.rows[row];
        }
      } else {
        return null;
      }
    };

    RowTable.prototype.getCol = function(col) {
      var _this = this;
      if (this.nrows() > 0 && (this.get(1, col) != null)) {
        return _.times(this.nrows(), function(idx) {
          return _this.get(idx, col);
        });
      } else {
        return null;
      }
    };

    RowTable.prototype.getColumn = function(col) {
      return this.getCol(col);
    };

    RowTable.prototype.asArray = function() {
      return this.rows;
    };

    return RowTable;

  })(gg.Table);

  gg.ColTable = (function(_super) {

    __extends(ColTable, _super);

    function ColTable() {
      return ColTable.__super__.constructor.apply(this, arguments);
    }

    return ColTable;

  })(gg.Table);

  gg.Graphic = (function() {

    function Graphic(spec) {
      this.spec = spec;
      this.layerspec = findGood([this.spec.layers, []]);
      this.facetspec = findGood([this.spec.facets, {}]);
      this.scalespec = findGood([this.spec.scales, {}]);
      this.options = findGood([this.spec.opts, this.spec.options, {}]);
      this.layers = new gg.Layers(this, this.layerspec);
      this.facets = new gg.Facets(this, this.facetspec);
      this.scales = new gg.Scales(this, this.scalespec);
    }

    Graphic.prototype.svgPane = function(facetX, facetY, layer) {
      return this.facets.svgPane(facetX, facetY, layer);
    };

    Graphic.prototype.compile = function() {
      var multicast, wf;
      wf = this.workflow = new gg.wf.Flow({
        g: this
      });
      _.each(this.facets.splitter, function(node) {
        return wf.node(node);
      });
      multicast = new gg.wf.Multicast;
      wf.node(multicast);
      _.each(this.layers.compile(), function(nodes) {
        var prev;
        prev = multicast;
        return _.each(nodes, function(node) {
          wf.connect(prev, node);
          return prev = node;
        });
      });
      return wf;
    };

    Graphic.prototype.renderGuides = function() {
      return null;
    };

    Graphic.prototype.layoutNode = function() {
      var f,
        _this = this;
      f = function(tables, envs, node) {
        var hTitle, svgTitle, title;
        $(_this.svg[0]).empty();
        _this.svg = _this.svg.append("svg").attr("width", _this.w).attr("height", _this.h);
        _this.svg.append("rect").attr("class", "graphic-background").attr("width", "100%").attr("height", "100%");
        title = _this.options.title;
        hTitle = 0;
        if (title != null) {
          hTitle = _.exSize({
            "font-size": "30pt"
          }).h;
          svgTitle = _this.svg.append("g").append("text").text(title).attr("text-anchor", "middle").attr("class", "graphic-title").attr("style", "font-size: 30pt").attr("dx", _this.w / 2).attr("dy", "1em");
        }
        _this.wFacet = _this.w;
        _this.hFacet = _this.h - hTitle;
        _this.svgFacet = _this.svg.append("g").attr("transform", "translate(0, " + hTitle + ")").attr("width", _this.wFacet).attr("height", _this.hFacet);
        _this.renderGuides();
        return tables;
      };
      return new gg.wf.Barrier({
        name: "layoutNode",
        f: f
      });
    };

    Graphic.prototype.inputToTable = function(input, cb) {
      var table;
      if (_.isArray(input)) {
        table = new gg.RowTable(input);
      } else if (_.isSubclass(input, gg.Table)) {
        table = input;
      } else if (_.isString(input)) {
        null;
      }
      return cb(table);
    };

    Graphic.prototype.render = function(w, h, svg, input) {
      var _this = this;
      this.w = w;
      this.h = h;
      this.svg = svg;
      return this.inputToTable(input, function(table) {
        _this.compile();
        return _this.workflow.run(table);
      });
    };

    return Graphic;

  })();

  "use strict";


  /*
  # @param undef undefined variable
  ((exports,undef) ->
  
      _ = exports._
      d3 = exports.d3
  
      if !_ and !d3 and require?
          d3 = require 'd3'
          _ = require 'underscore'
  */


  console.log(require);

  events = require('events');

  _ = require('underscore');

  exports = module.exports = this;

  _.extend(this, gg);

  fromSpec = function(spec) {
    return new gg.Graphic(spec);
  };

  this.gg = fromSpec;

  _.extend(this.gg, gg);

  gg.Mapper = (function(_super) {

    __extends(Mapper, _super);

    function Mapper(g, spec) {
      this.g = g;
      this.spec = spec;
      Mapper.__super__.constructor.call(this, this.g, this.spec);
      this.parseSpec();
      this.type = "mapper";
      this.name = findGood([this.spec.name, "mapper-" + this.id]);
    }

    Mapper.prototype.parseSpec = function() {
      var _this = this;
      this.mapping = findGood([this.spec.mapping, this.spec.map, this.spec.aes, {}]);
      console.log("mapper spec: " + (JSON.stringify(this.mapping)));
      this.aes = this.aesthetics = _.keys(this.mapping);
      this.spec.aes = this.mapping;
      this.inverse = {};
      _.each(this.mapping, function(val, key) {
        return _this.inverse[val] = key;
      });
      return Mapper.__super__.parseSpec.apply(this, arguments);
    };

    Mapper.prototype.compute = function(table, env, node) {
      console.log("transform: " + (JSON.stringify(this.mapping)));
      console.log("table:     " + (JSON.stringify(table.colNames())));
      table = table.clone();
      table.transform(this.mapping, true);
      return table;
    };

    Mapper.prototype.invertColName = function(outColName) {
      return this.inverse[outColName];
    };

    return Mapper;

  })(gg.XForm);

  /*
  
  0-D
  
  Point: ( x, y, r, x0, x1, y0, y1, [all other variables…] )
  1-D
  
  Line: ( (x, y)*, [grouping keys] )
  Step: ( (x, y)*, [grouping keys] ) // renders step path
  Path: ( (x0, x1, y0, y1)* [grouping keys] )
  2-D
  
  Area -> ( (x,y)*, [grouping keys] )
  Interval -> ( x, y, width, x0=x, x1=x+width, y0=0, y1=y, [all other variables…] )
  Rect -> ( x, w, y, h, x0=x, x1=x+w, y0=y, y1=y+h, [all other variables…] )
  Polygon -> ( (x,y)*, [grouping keys] )
  difference from line/area is that the polygon is closed
  Hex -> ( x, y, r, [all other variables] )
  N-D
  
  Schema: ( x, q0, q1, q2, q3, [y]*, [all other variables…] )
  Glyph: ( x0, x1, y0, y1, glyphname, [glyph specific variables] )
  Glyph can be used to generate symbols
  Network
  
  edge: ( v1, v2, [weight], )
  */


}).call(this);

})(window)
},{"events":2,"underscore":4}],4:[function(require,module,exports){
(function(){//     Underscore.js 1.4.3
//     http://underscorejs.org
//     (c) 2009-2012 Jeremy Ashkenas, DocumentCloud Inc.
//     Underscore may be freely distributed under the MIT license.

(function() {

  // Baseline setup
  // --------------

  // Establish the root object, `window` in the browser, or `global` on the server.
  var root = this;

  // Save the previous value of the `_` variable.
  var previousUnderscore = root._;

  // Establish the object that gets returned to break out of a loop iteration.
  var breaker = {};

  // Save bytes in the minified (but not gzipped) version:
  var ArrayProto = Array.prototype, ObjProto = Object.prototype, FuncProto = Function.prototype;

  // Create quick reference variables for speed access to core prototypes.
  var push             = ArrayProto.push,
      slice            = ArrayProto.slice,
      concat           = ArrayProto.concat,
      toString         = ObjProto.toString,
      hasOwnProperty   = ObjProto.hasOwnProperty;

  // All **ECMAScript 5** native function implementations that we hope to use
  // are declared here.
  var
    nativeForEach      = ArrayProto.forEach,
    nativeMap          = ArrayProto.map,
    nativeReduce       = ArrayProto.reduce,
    nativeReduceRight  = ArrayProto.reduceRight,
    nativeFilter       = ArrayProto.filter,
    nativeEvery        = ArrayProto.every,
    nativeSome         = ArrayProto.some,
    nativeIndexOf      = ArrayProto.indexOf,
    nativeLastIndexOf  = ArrayProto.lastIndexOf,
    nativeIsArray      = Array.isArray,
    nativeKeys         = Object.keys,
    nativeBind         = FuncProto.bind;

  // Create a safe reference to the Underscore object for use below.
  var _ = function(obj) {
    if (obj instanceof _) return obj;
    if (!(this instanceof _)) return new _(obj);
    this._wrapped = obj;
  };

  // Export the Underscore object for **Node.js**, with
  // backwards-compatibility for the old `require()` API. If we're in
  // the browser, add `_` as a global object via a string identifier,
  // for Closure Compiler "advanced" mode.
  if (typeof exports !== 'undefined') {
    if (typeof module !== 'undefined' && module.exports) {
      exports = module.exports = _;
    }
    exports._ = _;
  } else {
    root._ = _;
  }

  // Current version.
  _.VERSION = '1.4.3';

  // Collection Functions
  // --------------------

  // The cornerstone, an `each` implementation, aka `forEach`.
  // Handles objects with the built-in `forEach`, arrays, and raw objects.
  // Delegates to **ECMAScript 5**'s native `forEach` if available.
  var each = _.each = _.forEach = function(obj, iterator, context) {
    if (obj == null) return;
    if (nativeForEach && obj.forEach === nativeForEach) {
      obj.forEach(iterator, context);
    } else if (obj.length === +obj.length) {
      for (var i = 0, l = obj.length; i < l; i++) {
        if (iterator.call(context, obj[i], i, obj) === breaker) return;
      }
    } else {
      for (var key in obj) {
        if (_.has(obj, key)) {
          if (iterator.call(context, obj[key], key, obj) === breaker) return;
        }
      }
    }
  };

  // Return the results of applying the iterator to each element.
  // Delegates to **ECMAScript 5**'s native `map` if available.
  _.map = _.collect = function(obj, iterator, context) {
    var results = [];
    if (obj == null) return results;
    if (nativeMap && obj.map === nativeMap) return obj.map(iterator, context);
    each(obj, function(value, index, list) {
      results[results.length] = iterator.call(context, value, index, list);
    });
    return results;
  };

  var reduceError = 'Reduce of empty array with no initial value';

  // **Reduce** builds up a single result from a list of values, aka `inject`,
  // or `foldl`. Delegates to **ECMAScript 5**'s native `reduce` if available.
  _.reduce = _.foldl = _.inject = function(obj, iterator, memo, context) {
    var initial = arguments.length > 2;
    if (obj == null) obj = [];
    if (nativeReduce && obj.reduce === nativeReduce) {
      if (context) iterator = _.bind(iterator, context);
      return initial ? obj.reduce(iterator, memo) : obj.reduce(iterator);
    }
    each(obj, function(value, index, list) {
      if (!initial) {
        memo = value;
        initial = true;
      } else {
        memo = iterator.call(context, memo, value, index, list);
      }
    });
    if (!initial) throw new TypeError(reduceError);
    return memo;
  };

  // The right-associative version of reduce, also known as `foldr`.
  // Delegates to **ECMAScript 5**'s native `reduceRight` if available.
  _.reduceRight = _.foldr = function(obj, iterator, memo, context) {
    var initial = arguments.length > 2;
    if (obj == null) obj = [];
    if (nativeReduceRight && obj.reduceRight === nativeReduceRight) {
      if (context) iterator = _.bind(iterator, context);
      return initial ? obj.reduceRight(iterator, memo) : obj.reduceRight(iterator);
    }
    var length = obj.length;
    if (length !== +length) {
      var keys = _.keys(obj);
      length = keys.length;
    }
    each(obj, function(value, index, list) {
      index = keys ? keys[--length] : --length;
      if (!initial) {
        memo = obj[index];
        initial = true;
      } else {
        memo = iterator.call(context, memo, obj[index], index, list);
      }
    });
    if (!initial) throw new TypeError(reduceError);
    return memo;
  };

  // Return the first value which passes a truth test. Aliased as `detect`.
  _.find = _.detect = function(obj, iterator, context) {
    var result;
    any(obj, function(value, index, list) {
      if (iterator.call(context, value, index, list)) {
        result = value;
        return true;
      }
    });
    return result;
  };

  // Return all the elements that pass a truth test.
  // Delegates to **ECMAScript 5**'s native `filter` if available.
  // Aliased as `select`.
  _.filter = _.select = function(obj, iterator, context) {
    var results = [];
    if (obj == null) return results;
    if (nativeFilter && obj.filter === nativeFilter) return obj.filter(iterator, context);
    each(obj, function(value, index, list) {
      if (iterator.call(context, value, index, list)) results[results.length] = value;
    });
    return results;
  };

  // Return all the elements for which a truth test fails.
  _.reject = function(obj, iterator, context) {
    return _.filter(obj, function(value, index, list) {
      return !iterator.call(context, value, index, list);
    }, context);
  };

  // Determine whether all of the elements match a truth test.
  // Delegates to **ECMAScript 5**'s native `every` if available.
  // Aliased as `all`.
  _.every = _.all = function(obj, iterator, context) {
    iterator || (iterator = _.identity);
    var result = true;
    if (obj == null) return result;
    if (nativeEvery && obj.every === nativeEvery) return obj.every(iterator, context);
    each(obj, function(value, index, list) {
      if (!(result = result && iterator.call(context, value, index, list))) return breaker;
    });
    return !!result;
  };

  // Determine if at least one element in the object matches a truth test.
  // Delegates to **ECMAScript 5**'s native `some` if available.
  // Aliased as `any`.
  var any = _.some = _.any = function(obj, iterator, context) {
    iterator || (iterator = _.identity);
    var result = false;
    if (obj == null) return result;
    if (nativeSome && obj.some === nativeSome) return obj.some(iterator, context);
    each(obj, function(value, index, list) {
      if (result || (result = iterator.call(context, value, index, list))) return breaker;
    });
    return !!result;
  };

  // Determine if the array or object contains a given value (using `===`).
  // Aliased as `include`.
  _.contains = _.include = function(obj, target) {
    if (obj == null) return false;
    if (nativeIndexOf && obj.indexOf === nativeIndexOf) return obj.indexOf(target) != -1;
    return any(obj, function(value) {
      return value === target;
    });
  };

  // Invoke a method (with arguments) on every item in a collection.
  _.invoke = function(obj, method) {
    var args = slice.call(arguments, 2);
    return _.map(obj, function(value) {
      return (_.isFunction(method) ? method : value[method]).apply(value, args);
    });
  };

  // Convenience version of a common use case of `map`: fetching a property.
  _.pluck = function(obj, key) {
    return _.map(obj, function(value){ return value[key]; });
  };

  // Convenience version of a common use case of `filter`: selecting only objects
  // with specific `key:value` pairs.
  _.where = function(obj, attrs) {
    if (_.isEmpty(attrs)) return [];
    return _.filter(obj, function(value) {
      for (var key in attrs) {
        if (attrs[key] !== value[key]) return false;
      }
      return true;
    });
  };

  // Return the maximum element or (element-based computation).
  // Can't optimize arrays of integers longer than 65,535 elements.
  // See: https://bugs.webkit.org/show_bug.cgi?id=80797
  _.max = function(obj, iterator, context) {
    if (!iterator && _.isArray(obj) && obj[0] === +obj[0] && obj.length < 65535) {
      return Math.max.apply(Math, obj);
    }
    if (!iterator && _.isEmpty(obj)) return -Infinity;
    var result = {computed : -Infinity, value: -Infinity};
    each(obj, function(value, index, list) {
      var computed = iterator ? iterator.call(context, value, index, list) : value;
      computed >= result.computed && (result = {value : value, computed : computed});
    });
    return result.value;
  };

  // Return the minimum element (or element-based computation).
  _.min = function(obj, iterator, context) {
    if (!iterator && _.isArray(obj) && obj[0] === +obj[0] && obj.length < 65535) {
      return Math.min.apply(Math, obj);
    }
    if (!iterator && _.isEmpty(obj)) return Infinity;
    var result = {computed : Infinity, value: Infinity};
    each(obj, function(value, index, list) {
      var computed = iterator ? iterator.call(context, value, index, list) : value;
      computed < result.computed && (result = {value : value, computed : computed});
    });
    return result.value;
  };

  // Shuffle an array.
  _.shuffle = function(obj) {
    var rand;
    var index = 0;
    var shuffled = [];
    each(obj, function(value) {
      rand = _.random(index++);
      shuffled[index - 1] = shuffled[rand];
      shuffled[rand] = value;
    });
    return shuffled;
  };

  // An internal function to generate lookup iterators.
  var lookupIterator = function(value) {
    return _.isFunction(value) ? value : function(obj){ return obj[value]; };
  };

  // Sort the object's values by a criterion produced by an iterator.
  _.sortBy = function(obj, value, context) {
    var iterator = lookupIterator(value);
    return _.pluck(_.map(obj, function(value, index, list) {
      return {
        value : value,
        index : index,
        criteria : iterator.call(context, value, index, list)
      };
    }).sort(function(left, right) {
      var a = left.criteria;
      var b = right.criteria;
      if (a !== b) {
        if (a > b || a === void 0) return 1;
        if (a < b || b === void 0) return -1;
      }
      return left.index < right.index ? -1 : 1;
    }), 'value');
  };

  // An internal function used for aggregate "group by" operations.
  var group = function(obj, value, context, behavior) {
    var result = {};
    var iterator = lookupIterator(value || _.identity);
    each(obj, function(value, index) {
      var key = iterator.call(context, value, index, obj);
      behavior(result, key, value);
    });
    return result;
  };

  // Groups the object's values by a criterion. Pass either a string attribute
  // to group by, or a function that returns the criterion.
  _.groupBy = function(obj, value, context) {
    return group(obj, value, context, function(result, key, value) {
      (_.has(result, key) ? result[key] : (result[key] = [])).push(value);
    });
  };

  // Counts instances of an object that group by a certain criterion. Pass
  // either a string attribute to count by, or a function that returns the
  // criterion.
  _.countBy = function(obj, value, context) {
    return group(obj, value, context, function(result, key) {
      if (!_.has(result, key)) result[key] = 0;
      result[key]++;
    });
  };

  // Use a comparator function to figure out the smallest index at which
  // an object should be inserted so as to maintain order. Uses binary search.
  _.sortedIndex = function(array, obj, iterator, context) {
    iterator = iterator == null ? _.identity : lookupIterator(iterator);
    var value = iterator.call(context, obj);
    var low = 0, high = array.length;
    while (low < high) {
      var mid = (low + high) >>> 1;
      iterator.call(context, array[mid]) < value ? low = mid + 1 : high = mid;
    }
    return low;
  };

  // Safely convert anything iterable into a real, live array.
  _.toArray = function(obj) {
    if (!obj) return [];
    if (_.isArray(obj)) return slice.call(obj);
    if (obj.length === +obj.length) return _.map(obj, _.identity);
    return _.values(obj);
  };

  // Return the number of elements in an object.
  _.size = function(obj) {
    if (obj == null) return 0;
    return (obj.length === +obj.length) ? obj.length : _.keys(obj).length;
  };

  // Array Functions
  // ---------------

  // Get the first element of an array. Passing **n** will return the first N
  // values in the array. Aliased as `head` and `take`. The **guard** check
  // allows it to work with `_.map`.
  _.first = _.head = _.take = function(array, n, guard) {
    if (array == null) return void 0;
    return (n != null) && !guard ? slice.call(array, 0, n) : array[0];
  };

  // Returns everything but the last entry of the array. Especially useful on
  // the arguments object. Passing **n** will return all the values in
  // the array, excluding the last N. The **guard** check allows it to work with
  // `_.map`.
  _.initial = function(array, n, guard) {
    return slice.call(array, 0, array.length - ((n == null) || guard ? 1 : n));
  };

  // Get the last element of an array. Passing **n** will return the last N
  // values in the array. The **guard** check allows it to work with `_.map`.
  _.last = function(array, n, guard) {
    if (array == null) return void 0;
    if ((n != null) && !guard) {
      return slice.call(array, Math.max(array.length - n, 0));
    } else {
      return array[array.length - 1];
    }
  };

  // Returns everything but the first entry of the array. Aliased as `tail` and `drop`.
  // Especially useful on the arguments object. Passing an **n** will return
  // the rest N values in the array. The **guard**
  // check allows it to work with `_.map`.
  _.rest = _.tail = _.drop = function(array, n, guard) {
    return slice.call(array, (n == null) || guard ? 1 : n);
  };

  // Trim out all falsy values from an array.
  _.compact = function(array) {
    return _.filter(array, _.identity);
  };

  // Internal implementation of a recursive `flatten` function.
  var flatten = function(input, shallow, output) {
    each(input, function(value) {
      if (_.isArray(value)) {
        shallow ? push.apply(output, value) : flatten(value, shallow, output);
      } else {
        output.push(value);
      }
    });
    return output;
  };

  // Return a completely flattened version of an array.
  _.flatten = function(array, shallow) {
    return flatten(array, shallow, []);
  };

  // Return a version of the array that does not contain the specified value(s).
  _.without = function(array) {
    return _.difference(array, slice.call(arguments, 1));
  };

  // Produce a duplicate-free version of the array. If the array has already
  // been sorted, you have the option of using a faster algorithm.
  // Aliased as `unique`.
  _.uniq = _.unique = function(array, isSorted, iterator, context) {
    if (_.isFunction(isSorted)) {
      context = iterator;
      iterator = isSorted;
      isSorted = false;
    }
    var initial = iterator ? _.map(array, iterator, context) : array;
    var results = [];
    var seen = [];
    each(initial, function(value, index) {
      if (isSorted ? (!index || seen[seen.length - 1] !== value) : !_.contains(seen, value)) {
        seen.push(value);
        results.push(array[index]);
      }
    });
    return results;
  };

  // Produce an array that contains the union: each distinct element from all of
  // the passed-in arrays.
  _.union = function() {
    return _.uniq(concat.apply(ArrayProto, arguments));
  };

  // Produce an array that contains every item shared between all the
  // passed-in arrays.
  _.intersection = function(array) {
    var rest = slice.call(arguments, 1);
    return _.filter(_.uniq(array), function(item) {
      return _.every(rest, function(other) {
        return _.indexOf(other, item) >= 0;
      });
    });
  };

  // Take the difference between one array and a number of other arrays.
  // Only the elements present in just the first array will remain.
  _.difference = function(array) {
    var rest = concat.apply(ArrayProto, slice.call(arguments, 1));
    return _.filter(array, function(value){ return !_.contains(rest, value); });
  };

  // Zip together multiple lists into a single array -- elements that share
  // an index go together.
  _.zip = function() {
    var args = slice.call(arguments);
    var length = _.max(_.pluck(args, 'length'));
    var results = new Array(length);
    for (var i = 0; i < length; i++) {
      results[i] = _.pluck(args, "" + i);
    }
    return results;
  };

  // Converts lists into objects. Pass either a single array of `[key, value]`
  // pairs, or two parallel arrays of the same length -- one of keys, and one of
  // the corresponding values.
  _.object = function(list, values) {
    if (list == null) return {};
    var result = {};
    for (var i = 0, l = list.length; i < l; i++) {
      if (values) {
        result[list[i]] = values[i];
      } else {
        result[list[i][0]] = list[i][1];
      }
    }
    return result;
  };

  // If the browser doesn't supply us with indexOf (I'm looking at you, **MSIE**),
  // we need this function. Return the position of the first occurrence of an
  // item in an array, or -1 if the item is not included in the array.
  // Delegates to **ECMAScript 5**'s native `indexOf` if available.
  // If the array is large and already in sort order, pass `true`
  // for **isSorted** to use binary search.
  _.indexOf = function(array, item, isSorted) {
    if (array == null) return -1;
    var i = 0, l = array.length;
    if (isSorted) {
      if (typeof isSorted == 'number') {
        i = (isSorted < 0 ? Math.max(0, l + isSorted) : isSorted);
      } else {
        i = _.sortedIndex(array, item);
        return array[i] === item ? i : -1;
      }
    }
    if (nativeIndexOf && array.indexOf === nativeIndexOf) return array.indexOf(item, isSorted);
    for (; i < l; i++) if (array[i] === item) return i;
    return -1;
  };

  // Delegates to **ECMAScript 5**'s native `lastIndexOf` if available.
  _.lastIndexOf = function(array, item, from) {
    if (array == null) return -1;
    var hasIndex = from != null;
    if (nativeLastIndexOf && array.lastIndexOf === nativeLastIndexOf) {
      return hasIndex ? array.lastIndexOf(item, from) : array.lastIndexOf(item);
    }
    var i = (hasIndex ? from : array.length);
    while (i--) if (array[i] === item) return i;
    return -1;
  };

  // Generate an integer Array containing an arithmetic progression. A port of
  // the native Python `range()` function. See
  // [the Python documentation](http://docs.python.org/library/functions.html#range).
  _.range = function(start, stop, step) {
    if (arguments.length <= 1) {
      stop = start || 0;
      start = 0;
    }
    step = arguments[2] || 1;

    var len = Math.max(Math.ceil((stop - start) / step), 0);
    var idx = 0;
    var range = new Array(len);

    while(idx < len) {
      range[idx++] = start;
      start += step;
    }

    return range;
  };

  // Function (ahem) Functions
  // ------------------

  // Reusable constructor function for prototype setting.
  var ctor = function(){};

  // Create a function bound to a given object (assigning `this`, and arguments,
  // optionally). Binding with arguments is also known as `curry`.
  // Delegates to **ECMAScript 5**'s native `Function.bind` if available.
  // We check for `func.bind` first, to fail fast when `func` is undefined.
  _.bind = function(func, context) {
    var args, bound;
    if (func.bind === nativeBind && nativeBind) return nativeBind.apply(func, slice.call(arguments, 1));
    if (!_.isFunction(func)) throw new TypeError;
    args = slice.call(arguments, 2);
    return bound = function() {
      if (!(this instanceof bound)) return func.apply(context, args.concat(slice.call(arguments)));
      ctor.prototype = func.prototype;
      var self = new ctor;
      ctor.prototype = null;
      var result = func.apply(self, args.concat(slice.call(arguments)));
      if (Object(result) === result) return result;
      return self;
    };
  };

  // Bind all of an object's methods to that object. Useful for ensuring that
  // all callbacks defined on an object belong to it.
  _.bindAll = function(obj) {
    var funcs = slice.call(arguments, 1);
    if (funcs.length == 0) funcs = _.functions(obj);
    each(funcs, function(f) { obj[f] = _.bind(obj[f], obj); });
    return obj;
  };

  // Memoize an expensive function by storing its results.
  _.memoize = function(func, hasher) {
    var memo = {};
    hasher || (hasher = _.identity);
    return function() {
      var key = hasher.apply(this, arguments);
      return _.has(memo, key) ? memo[key] : (memo[key] = func.apply(this, arguments));
    };
  };

  // Delays a function for the given number of milliseconds, and then calls
  // it with the arguments supplied.
  _.delay = function(func, wait) {
    var args = slice.call(arguments, 2);
    return setTimeout(function(){ return func.apply(null, args); }, wait);
  };

  // Defers a function, scheduling it to run after the current call stack has
  // cleared.
  _.defer = function(func) {
    return _.delay.apply(_, [func, 1].concat(slice.call(arguments, 1)));
  };

  // Returns a function, that, when invoked, will only be triggered at most once
  // during a given window of time.
  _.throttle = function(func, wait) {
    var context, args, timeout, result;
    var previous = 0;
    var later = function() {
      previous = new Date;
      timeout = null;
      result = func.apply(context, args);
    };
    return function() {
      var now = new Date;
      var remaining = wait - (now - previous);
      context = this;
      args = arguments;
      if (remaining <= 0) {
        clearTimeout(timeout);
        timeout = null;
        previous = now;
        result = func.apply(context, args);
      } else if (!timeout) {
        timeout = setTimeout(later, remaining);
      }
      return result;
    };
  };

  // Returns a function, that, as long as it continues to be invoked, will not
  // be triggered. The function will be called after it stops being called for
  // N milliseconds. If `immediate` is passed, trigger the function on the
  // leading edge, instead of the trailing.
  _.debounce = function(func, wait, immediate) {
    var timeout, result;
    return function() {
      var context = this, args = arguments;
      var later = function() {
        timeout = null;
        if (!immediate) result = func.apply(context, args);
      };
      var callNow = immediate && !timeout;
      clearTimeout(timeout);
      timeout = setTimeout(later, wait);
      if (callNow) result = func.apply(context, args);
      return result;
    };
  };

  // Returns a function that will be executed at most one time, no matter how
  // often you call it. Useful for lazy initialization.
  _.once = function(func) {
    var ran = false, memo;
    return function() {
      if (ran) return memo;
      ran = true;
      memo = func.apply(this, arguments);
      func = null;
      return memo;
    };
  };

  // Returns the first function passed as an argument to the second,
  // allowing you to adjust arguments, run code before and after, and
  // conditionally execute the original function.
  _.wrap = function(func, wrapper) {
    return function() {
      var args = [func];
      push.apply(args, arguments);
      return wrapper.apply(this, args);
    };
  };

  // Returns a function that is the composition of a list of functions, each
  // consuming the return value of the function that follows.
  _.compose = function() {
    var funcs = arguments;
    return function() {
      var args = arguments;
      for (var i = funcs.length - 1; i >= 0; i--) {
        args = [funcs[i].apply(this, args)];
      }
      return args[0];
    };
  };

  // Returns a function that will only be executed after being called N times.
  _.after = function(times, func) {
    if (times <= 0) return func();
    return function() {
      if (--times < 1) {
        return func.apply(this, arguments);
      }
    };
  };

  // Object Functions
  // ----------------

  // Retrieve the names of an object's properties.
  // Delegates to **ECMAScript 5**'s native `Object.keys`
  _.keys = nativeKeys || function(obj) {
    if (obj !== Object(obj)) throw new TypeError('Invalid object');
    var keys = [];
    for (var key in obj) if (_.has(obj, key)) keys[keys.length] = key;
    return keys;
  };

  // Retrieve the values of an object's properties.
  _.values = function(obj) {
    var values = [];
    for (var key in obj) if (_.has(obj, key)) values.push(obj[key]);
    return values;
  };

  // Convert an object into a list of `[key, value]` pairs.
  _.pairs = function(obj) {
    var pairs = [];
    for (var key in obj) if (_.has(obj, key)) pairs.push([key, obj[key]]);
    return pairs;
  };

  // Invert the keys and values of an object. The values must be serializable.
  _.invert = function(obj) {
    var result = {};
    for (var key in obj) if (_.has(obj, key)) result[obj[key]] = key;
    return result;
  };

  // Return a sorted list of the function names available on the object.
  // Aliased as `methods`
  _.functions = _.methods = function(obj) {
    var names = [];
    for (var key in obj) {
      if (_.isFunction(obj[key])) names.push(key);
    }
    return names.sort();
  };

  // Extend a given object with all the properties in passed-in object(s).
  _.extend = function(obj) {
    each(slice.call(arguments, 1), function(source) {
      if (source) {
        for (var prop in source) {
          obj[prop] = source[prop];
        }
      }
    });
    return obj;
  };

  // Return a copy of the object only containing the whitelisted properties.
  _.pick = function(obj) {
    var copy = {};
    var keys = concat.apply(ArrayProto, slice.call(arguments, 1));
    each(keys, function(key) {
      if (key in obj) copy[key] = obj[key];
    });
    return copy;
  };

   // Return a copy of the object without the blacklisted properties.
  _.omit = function(obj) {
    var copy = {};
    var keys = concat.apply(ArrayProto, slice.call(arguments, 1));
    for (var key in obj) {
      if (!_.contains(keys, key)) copy[key] = obj[key];
    }
    return copy;
  };

  // Fill in a given object with default properties.
  _.defaults = function(obj) {
    each(slice.call(arguments, 1), function(source) {
      if (source) {
        for (var prop in source) {
          if (obj[prop] == null) obj[prop] = source[prop];
        }
      }
    });
    return obj;
  };

  // Create a (shallow-cloned) duplicate of an object.
  _.clone = function(obj) {
    if (!_.isObject(obj)) return obj;
    return _.isArray(obj) ? obj.slice() : _.extend({}, obj);
  };

  // Invokes interceptor with the obj, and then returns obj.
  // The primary purpose of this method is to "tap into" a method chain, in
  // order to perform operations on intermediate results within the chain.
  _.tap = function(obj, interceptor) {
    interceptor(obj);
    return obj;
  };

  // Internal recursive comparison function for `isEqual`.
  var eq = function(a, b, aStack, bStack) {
    // Identical objects are equal. `0 === -0`, but they aren't identical.
    // See the Harmony `egal` proposal: http://wiki.ecmascript.org/doku.php?id=harmony:egal.
    if (a === b) return a !== 0 || 1 / a == 1 / b;
    // A strict comparison is necessary because `null == undefined`.
    if (a == null || b == null) return a === b;
    // Unwrap any wrapped objects.
    if (a instanceof _) a = a._wrapped;
    if (b instanceof _) b = b._wrapped;
    // Compare `[[Class]]` names.
    var className = toString.call(a);
    if (className != toString.call(b)) return false;
    switch (className) {
      // Strings, numbers, dates, and booleans are compared by value.
      case '[object String]':
        // Primitives and their corresponding object wrappers are equivalent; thus, `"5"` is
        // equivalent to `new String("5")`.
        return a == String(b);
      case '[object Number]':
        // `NaN`s are equivalent, but non-reflexive. An `egal` comparison is performed for
        // other numeric values.
        return a != +a ? b != +b : (a == 0 ? 1 / a == 1 / b : a == +b);
      case '[object Date]':
      case '[object Boolean]':
        // Coerce dates and booleans to numeric primitive values. Dates are compared by their
        // millisecond representations. Note that invalid dates with millisecond representations
        // of `NaN` are not equivalent.
        return +a == +b;
      // RegExps are compared by their source patterns and flags.
      case '[object RegExp]':
        return a.source == b.source &&
               a.global == b.global &&
               a.multiline == b.multiline &&
               a.ignoreCase == b.ignoreCase;
    }
    if (typeof a != 'object' || typeof b != 'object') return false;
    // Assume equality for cyclic structures. The algorithm for detecting cyclic
    // structures is adapted from ES 5.1 section 15.12.3, abstract operation `JO`.
    var length = aStack.length;
    while (length--) {
      // Linear search. Performance is inversely proportional to the number of
      // unique nested structures.
      if (aStack[length] == a) return bStack[length] == b;
    }
    // Add the first object to the stack of traversed objects.
    aStack.push(a);
    bStack.push(b);
    var size = 0, result = true;
    // Recursively compare objects and arrays.
    if (className == '[object Array]') {
      // Compare array lengths to determine if a deep comparison is necessary.
      size = a.length;
      result = size == b.length;
      if (result) {
        // Deep compare the contents, ignoring non-numeric properties.
        while (size--) {
          if (!(result = eq(a[size], b[size], aStack, bStack))) break;
        }
      }
    } else {
      // Objects with different constructors are not equivalent, but `Object`s
      // from different frames are.
      var aCtor = a.constructor, bCtor = b.constructor;
      if (aCtor !== bCtor && !(_.isFunction(aCtor) && (aCtor instanceof aCtor) &&
                               _.isFunction(bCtor) && (bCtor instanceof bCtor))) {
        return false;
      }
      // Deep compare objects.
      for (var key in a) {
        if (_.has(a, key)) {
          // Count the expected number of properties.
          size++;
          // Deep compare each member.
          if (!(result = _.has(b, key) && eq(a[key], b[key], aStack, bStack))) break;
        }
      }
      // Ensure that both objects contain the same number of properties.
      if (result) {
        for (key in b) {
          if (_.has(b, key) && !(size--)) break;
        }
        result = !size;
      }
    }
    // Remove the first object from the stack of traversed objects.
    aStack.pop();
    bStack.pop();
    return result;
  };

  // Perform a deep comparison to check if two objects are equal.
  _.isEqual = function(a, b) {
    return eq(a, b, [], []);
  };

  // Is a given array, string, or object empty?
  // An "empty" object has no enumerable own-properties.
  _.isEmpty = function(obj) {
    if (obj == null) return true;
    if (_.isArray(obj) || _.isString(obj)) return obj.length === 0;
    for (var key in obj) if (_.has(obj, key)) return false;
    return true;
  };

  // Is a given value a DOM element?
  _.isElement = function(obj) {
    return !!(obj && obj.nodeType === 1);
  };

  // Is a given value an array?
  // Delegates to ECMA5's native Array.isArray
  _.isArray = nativeIsArray || function(obj) {
    return toString.call(obj) == '[object Array]';
  };

  // Is a given variable an object?
  _.isObject = function(obj) {
    return obj === Object(obj);
  };

  // Add some isType methods: isArguments, isFunction, isString, isNumber, isDate, isRegExp.
  each(['Arguments', 'Function', 'String', 'Number', 'Date', 'RegExp'], function(name) {
    _['is' + name] = function(obj) {
      return toString.call(obj) == '[object ' + name + ']';
    };
  });

  // Define a fallback version of the method in browsers (ahem, IE), where
  // there isn't any inspectable "Arguments" type.
  if (!_.isArguments(arguments)) {
    _.isArguments = function(obj) {
      return !!(obj && _.has(obj, 'callee'));
    };
  }

  // Optimize `isFunction` if appropriate.
  if (typeof (/./) !== 'function') {
    _.isFunction = function(obj) {
      return typeof obj === 'function';
    };
  }

  // Is a given object a finite number?
  _.isFinite = function(obj) {
    return isFinite(obj) && !isNaN(parseFloat(obj));
  };

  // Is the given value `NaN`? (NaN is the only number which does not equal itself).
  _.isNaN = function(obj) {
    return _.isNumber(obj) && obj != +obj;
  };

  // Is a given value a boolean?
  _.isBoolean = function(obj) {
    return obj === true || obj === false || toString.call(obj) == '[object Boolean]';
  };

  // Is a given value equal to null?
  _.isNull = function(obj) {
    return obj === null;
  };

  // Is a given variable undefined?
  _.isUndefined = function(obj) {
    return obj === void 0;
  };

  // Shortcut function for checking if an object has a given property directly
  // on itself (in other words, not on a prototype).
  _.has = function(obj, key) {
    return hasOwnProperty.call(obj, key);
  };

  // Utility Functions
  // -----------------

  // Run Underscore.js in *noConflict* mode, returning the `_` variable to its
  // previous owner. Returns a reference to the Underscore object.
  _.noConflict = function() {
    root._ = previousUnderscore;
    return this;
  };

  // Keep the identity function around for default iterators.
  _.identity = function(value) {
    return value;
  };

  // Run a function **n** times.
  _.times = function(n, iterator, context) {
    var accum = Array(n);
    for (var i = 0; i < n; i++) accum[i] = iterator.call(context, i);
    return accum;
  };

  // Return a random integer between min and max (inclusive).
  _.random = function(min, max) {
    if (max == null) {
      max = min;
      min = 0;
    }
    return min + (0 | Math.random() * (max - min + 1));
  };

  // List of HTML entities for escaping.
  var entityMap = {
    escape: {
      '&': '&amp;',
      '<': '&lt;',
      '>': '&gt;',
      '"': '&quot;',
      "'": '&#x27;',
      '/': '&#x2F;'
    }
  };
  entityMap.unescape = _.invert(entityMap.escape);

  // Regexes containing the keys and values listed immediately above.
  var entityRegexes = {
    escape:   new RegExp('[' + _.keys(entityMap.escape).join('') + ']', 'g'),
    unescape: new RegExp('(' + _.keys(entityMap.unescape).join('|') + ')', 'g')
  };

  // Functions for escaping and unescaping strings to/from HTML interpolation.
  _.each(['escape', 'unescape'], function(method) {
    _[method] = function(string) {
      if (string == null) return '';
      return ('' + string).replace(entityRegexes[method], function(match) {
        return entityMap[method][match];
      });
    };
  });

  // If the value of the named property is a function then invoke it;
  // otherwise, return it.
  _.result = function(object, property) {
    if (object == null) return null;
    var value = object[property];
    return _.isFunction(value) ? value.call(object) : value;
  };

  // Add your own custom functions to the Underscore object.
  _.mixin = function(obj) {
    each(_.functions(obj), function(name){
      var func = _[name] = obj[name];
      _.prototype[name] = function() {
        var args = [this._wrapped];
        push.apply(args, arguments);
        return result.call(this, func.apply(_, args));
      };
    });
  };

  // Generate a unique integer id (unique within the entire client session).
  // Useful for temporary DOM ids.
  var idCounter = 0;
  _.uniqueId = function(prefix) {
    var id = '' + ++idCounter;
    return prefix ? prefix + id : id;
  };

  // By default, Underscore uses ERB-style template delimiters, change the
  // following template settings to use alternative delimiters.
  _.templateSettings = {
    evaluate    : /<%([\s\S]+?)%>/g,
    interpolate : /<%=([\s\S]+?)%>/g,
    escape      : /<%-([\s\S]+?)%>/g
  };

  // When customizing `templateSettings`, if you don't want to define an
  // interpolation, evaluation or escaping regex, we need one that is
  // guaranteed not to match.
  var noMatch = /(.)^/;

  // Certain characters need to be escaped so that they can be put into a
  // string literal.
  var escapes = {
    "'":      "'",
    '\\':     '\\',
    '\r':     'r',
    '\n':     'n',
    '\t':     't',
    '\u2028': 'u2028',
    '\u2029': 'u2029'
  };

  var escaper = /\\|'|\r|\n|\t|\u2028|\u2029/g;

  // JavaScript micro-templating, similar to John Resig's implementation.
  // Underscore templating handles arbitrary delimiters, preserves whitespace,
  // and correctly escapes quotes within interpolated code.
  _.template = function(text, data, settings) {
    settings = _.defaults({}, settings, _.templateSettings);

    // Combine delimiters into one regular expression via alternation.
    var matcher = new RegExp([
      (settings.escape || noMatch).source,
      (settings.interpolate || noMatch).source,
      (settings.evaluate || noMatch).source
    ].join('|') + '|$', 'g');

    // Compile the template source, escaping string literals appropriately.
    var index = 0;
    var source = "__p+='";
    text.replace(matcher, function(match, escape, interpolate, evaluate, offset) {
      source += text.slice(index, offset)
        .replace(escaper, function(match) { return '\\' + escapes[match]; });

      if (escape) {
        source += "'+\n((__t=(" + escape + "))==null?'':_.escape(__t))+\n'";
      }
      if (interpolate) {
        source += "'+\n((__t=(" + interpolate + "))==null?'':__t)+\n'";
      }
      if (evaluate) {
        source += "';\n" + evaluate + "\n__p+='";
      }
      index = offset + match.length;
      return match;
    });
    source += "';\n";

    // If a variable is not specified, place data values in local scope.
    if (!settings.variable) source = 'with(obj||{}){\n' + source + '}\n';

    source = "var __t,__p='',__j=Array.prototype.join," +
      "print=function(){__p+=__j.call(arguments,'');};\n" +
      source + "return __p;\n";

    try {
      var render = new Function(settings.variable || 'obj', '_', source);
    } catch (e) {
      e.source = source;
      throw e;
    }

    if (data) return render(data, _);
    var template = function(data) {
      return render.call(this, data, _);
    };

    // Provide the compiled function source as a convenience for precompilation.
    template.source = 'function(' + (settings.variable || 'obj') + '){\n' + source + '}';

    return template;
  };

  // Add a "chain" function, which will delegate to the wrapper.
  _.chain = function(obj) {
    return _(obj).chain();
  };

  // OOP
  // ---------------
  // If Underscore is called as a function, it returns a wrapped object that
  // can be used OO-style. This wrapper holds altered versions of all the
  // underscore functions. Wrapped objects may be chained.

  // Helper function to continue chaining intermediate results.
  var result = function(obj) {
    return this._chain ? _(obj).chain() : obj;
  };

  // Add all of the Underscore functions to the wrapper object.
  _.mixin(_);

  // Add all mutator Array functions to the wrapper.
  each(['pop', 'push', 'reverse', 'shift', 'sort', 'splice', 'unshift'], function(name) {
    var method = ArrayProto[name];
    _.prototype[name] = function() {
      var obj = this._wrapped;
      method.apply(obj, arguments);
      if ((name == 'shift' || name == 'splice') && obj.length === 0) delete obj[0];
      return result.call(this, obj);
    };
  });

  // Add all accessor Array functions to the wrapper.
  each(['concat', 'join', 'slice'], function(name) {
    var method = ArrayProto[name];
    _.prototype[name] = function() {
      return result.call(this, method.apply(this._wrapped, arguments));
    };
  });

  _.extend(_.prototype, {

    // Start chaining a wrapped Underscore object.
    chain: function() {
      this._chain = true;
      return this;
    },

    // Extracts the result from a wrapped and chained object.
    value: function() {
      return this._wrapped;
    }

  });

}).call(this);

})()
},{}]},{},[3])
;