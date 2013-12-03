d3=function(){function t(t){return t.target}function n(t){return t.source}function e(t,n){try{for(var e in n)Object.defineProperty(t.prototype,e,{value:n[e],enumerable:!1})}catch(r){t.prototype=n}}function r(t){for(var n=-1,e=t.length,r=[];e>++n;)r.push(t[n]);return r}function u(t){return Array.prototype.slice.call(t)}function i(){}function a(t){return t}function o(){return!0}function c(t){return"function"==typeof t?t:function(){return t}}function l(t,n,e){return function(){var r=e.apply(n,arguments);return arguments.length?t:r}}function f(t){return null!=t&&!isNaN(t)}function s(t){return t.length}function h(t){return t.trim().replace(/\s+/g," ")}function g(t){for(var n=1;t*n%1;)n*=10;return n}function p(t){return 1===t.length?function(n,e){t(null==n?e:null)}:t}function d(t){return t.responseText}function m(t){return JSON.parse(t.responseText)}function v(t){var n=Di.createRange();return n.selectNode(Di.body),n.createContextualFragment(t.responseText)}function y(t){return t.responseXML}function M(){}function b(t){function n(){for(var n,r=e,u=-1,i=r.length;i>++u;)(n=r[u].on)&&n.apply(this,arguments);return t}var e=[],r=new i;return n.on=function(n,u){var i,a=r.get(n);return 2>arguments.length?a&&a.on:(a&&(a.on=null,e=e.slice(0,i=e.indexOf(a)).concat(e.slice(i+1)),r.remove(n)),u&&e.push(r.set(n,{on:u})),t)},n}function x(t,n){return n-(t?Math.ceil(Math.log(t)/Math.LN10):1)}function _(t){return t+""}function w(t,n){var e=Math.pow(10,3*Math.abs(8-n));return{scale:n>8?function(t){return t/e}:function(t){return t*e},symbol:t}}function S(t){return function(n){return 0>=n?0:n>=1?1:t(n)}}function k(t){return function(n){return 1-t(1-n)}}function E(t){return function(n){return.5*(.5>n?t(2*n):2-t(2-2*n))}}function A(t){return t*t}function N(t){return t*t*t}function T(t){if(0>=t)return 0;if(t>=1)return 1;var n=t*t,e=n*t;return 4*(.5>t?e:3*(t-n)+e-.75)}function q(t){return function(n){return Math.pow(n,t)}}function C(t){return 1-Math.cos(t*Ni/2)}function z(t){return Math.pow(2,10*(t-1))}function D(t){return 1-Math.sqrt(1-t*t)}function L(t,n){var e;return 2>arguments.length&&(n=.45),arguments.length?e=n/(2*Ni)*Math.asin(1/t):(t=1,e=n/4),function(r){return 1+t*Math.pow(2,10*-r)*Math.sin(2*(r-e)*Ni/n)}}function F(t){return t||(t=1.70158),function(n){return n*n*((t+1)*n-t)}}function H(t){return 1/2.75>t?7.5625*t*t:2/2.75>t?7.5625*(t-=1.5/2.75)*t+.75:2.5/2.75>t?7.5625*(t-=2.25/2.75)*t+.9375:7.5625*(t-=2.625/2.75)*t+.984375}function j(){qi.event.stopPropagation(),qi.event.preventDefault()}function P(){for(var t,n=qi.event;t=n.sourceEvent;)n=t;return n}function R(t){for(var n=new M,e=0,r=arguments.length;r>++e;)n[arguments[e]]=b(n);return n.of=function(e,r){return function(u){try{var i=u.sourceEvent=qi.event;u.target=t,qi.event=u,n[u.type].apply(e,r)}finally{qi.event=i}}},n}function O(t){var n=[t.a,t.b],e=[t.c,t.d],r=U(n),u=Y(n,e),i=U(I(e,n,-u))||0;n[0]*e[1]<e[0]*n[1]&&(n[0]*=-1,n[1]*=-1,r*=-1,u*=-1),this.rotate=(r?Math.atan2(n[1],n[0]):Math.atan2(-e[0],e[1]))*zi,this.translate=[t.e,t.f],this.scale=[r,i],this.skew=i?Math.atan2(u,i)*zi:0}function Y(t,n){return t[0]*n[0]+t[1]*n[1]}function U(t){var n=Math.sqrt(Y(t,t));return n&&(t[0]/=n,t[1]/=n),n}function I(t,n,e){return t[0]+=e*n[0],t[1]+=e*n[1],t}function V(t){return"transform"==t?qi.interpolateTransform:qi.interpolate}function X(t,n){return n=n-(t=+t)?1/(n-t):0,function(e){return(e-t)*n}}function Z(t,n){return n=n-(t=+t)?1/(n-t):0,function(e){return Math.max(0,Math.min(1,(e-t)*n))}}function B(){}function $(t,n,e){return new J(t,n,e)}function J(t,n,e){this.r=t,this.g=n,this.b=e}function G(t){return 16>t?"0"+Math.max(0,t).toString(16):Math.min(255,t).toString(16)}function K(t,n,e){var r,u,i,a=0,o=0,c=0;if(r=/([a-z]+)\((.*)\)/i.exec(t))switch(u=r[2].split(","),r[1]){case"hsl":return e(parseFloat(u[0]),parseFloat(u[1])/100,parseFloat(u[2])/100);case"rgb":return n(nn(u[0]),nn(u[1]),nn(u[2]))}return(i=aa.get(t))?n(i.r,i.g,i.b):(null!=t&&"#"===t.charAt(0)&&(4===t.length?(a=t.charAt(1),a+=a,o=t.charAt(2),o+=o,c=t.charAt(3),c+=c):7===t.length&&(a=t.substring(1,3),o=t.substring(3,5),c=t.substring(5,7)),a=parseInt(a,16),o=parseInt(o,16),c=parseInt(c,16)),n(a,o,c))}function W(t,n,e){var r,u,i=Math.min(t/=255,n/=255,e/=255),a=Math.max(t,n,e),o=a-i,c=(a+i)/2;return o?(u=.5>c?o/(a+i):o/(2-a-i),r=t==a?(n-e)/o+(e>n?6:0):n==a?(e-t)/o+2:(t-n)/o+4,r*=60):u=r=0,en(r,u,c)}function Q(t,n,e){t=tn(t),n=tn(n),e=tn(e);var r=pn((.4124564*t+.3575761*n+.1804375*e)/fa),u=pn((.2126729*t+.7151522*n+.072175*e)/sa),i=pn((.0193339*t+.119192*n+.9503041*e)/ha);return ln(116*u-16,500*(r-u),200*(u-i))}function tn(t){return.04045>=(t/=255)?t/12.92:Math.pow((t+.055)/1.055,2.4)}function nn(t){var n=parseFloat(t);return"%"===t.charAt(t.length-1)?Math.round(2.55*n):n}function en(t,n,e){return new rn(t,n,e)}function rn(t,n,e){this.h=t,this.s=n,this.l=e}function un(t,n,e){function r(t){return t>360?t-=360:0>t&&(t+=360),60>t?i+(a-i)*t/60:180>t?a:240>t?i+(a-i)*(240-t)/60:i}function u(t){return Math.round(255*r(t))}var i,a;return t%=360,0>t&&(t+=360),n=0>n?0:n>1?1:n,e=0>e?0:e>1?1:e,a=.5>=e?e*(1+n):e+n-e*n,i=2*e-a,$(u(t+120),u(t),u(t-120))}function an(t,n,e){return new on(t,n,e)}function on(t,n,e){this.h=t,this.c=n,this.l=e}function cn(t,n,e){return ln(e,Math.cos(t*=Ci)*n,Math.sin(t)*n)}function ln(t,n,e){return new fn(t,n,e)}function fn(t,n,e){this.l=t,this.a=n,this.b=e}function sn(t,n,e){var r=(t+16)/116,u=r+n/500,i=r-e/200;return u=gn(u)*fa,r=gn(r)*sa,i=gn(i)*ha,$(dn(3.2404542*u-1.5371385*r-.4985314*i),dn(-.969266*u+1.8760108*r+.041556*i),dn(.0556434*u-.2040259*r+1.0572252*i))}function hn(t,n,e){return an(180*(Math.atan2(e,n)/Ni),Math.sqrt(n*n+e*e),t)}function gn(t){return t>.206893034?t*t*t:(t-4/29)/7.787037}function pn(t){return t>.008856?Math.pow(t,1/3):7.787037*t+4/29}function dn(t){return Math.round(255*(.00304>=t?12.92*t:1.055*Math.pow(t,1/2.4)-.055))}function mn(t){return Ii(t,Ma),t}function vn(t){return function(){return pa(t,this)}}function yn(t){return function(){return da(t,this)}}function Mn(t,n){function e(){this.removeAttribute(t)}function r(){this.removeAttributeNS(t.space,t.local)}function u(){this.setAttribute(t,n)}function i(){this.setAttributeNS(t.space,t.local,n)}function a(){var e=n.apply(this,arguments);null==e?this.removeAttribute(t):this.setAttribute(t,e)}function o(){var e=n.apply(this,arguments);null==e?this.removeAttributeNS(t.space,t.local):this.setAttributeNS(t.space,t.local,e)}return t=qi.ns.qualify(t),null==n?t.local?r:e:"function"==typeof n?t.local?o:a:t.local?i:u}function bn(t){return RegExp("(?:^|\\s+)"+qi.requote(t)+"(?:\\s+|$)","g")}function xn(t,n){function e(){for(var e=-1;u>++e;)t[e](this,n)}function r(){for(var e=-1,r=n.apply(this,arguments);u>++e;)t[e](this,r)}t=t.trim().split(/\s+/).map(_n);var u=t.length;return"function"==typeof n?r:e}function _n(t){var n=bn(t);return function(e,r){if(u=e.classList)return r?u.add(t):u.remove(t);var u=e.className,i=null!=u.baseVal,a=i?u.baseVal:u;r?(n.lastIndex=0,n.test(a)||(a=h(a+" "+t),i?u.baseVal=a:e.className=a)):a&&(a=h(a.replace(n," ")),i?u.baseVal=a:e.className=a)}}function wn(t,n,e){function r(){this.style.removeProperty(t)}function u(){this.style.setProperty(t,n,e)}function i(){var r=n.apply(this,arguments);null==r?this.style.removeProperty(t):this.style.setProperty(t,r,e)}return null==n?r:"function"==typeof n?i:u}function Sn(t,n){function e(){delete this[t]}function r(){this[t]=n}function u(){var e=n.apply(this,arguments);null==e?delete this[t]:this[t]=e}return null==n?e:"function"==typeof n?u:r}function kn(t){return{__data__:t}}function En(t){return function(){return ya(this,t)}}function An(t){return arguments.length||(t=qi.ascending),function(n,e){return!n-!e||t(n.__data__,e.__data__)}}function Nn(t,n,e){function r(){var n=this[i];n&&(this.removeEventListener(t,n,n.$),delete this[i])}function u(){function u(t){var e=qi.event;qi.event=t,o[0]=a.__data__;try{n.apply(a,o)}finally{qi.event=e}}var a=this,o=Yi(arguments);r.call(this),this.addEventListener(t,this[i]=u,u.$=e),u._=n}var i="__on"+t,a=t.indexOf(".");return a>0&&(t=t.substring(0,a)),n?u:r}function Tn(t,n){for(var e=0,r=t.length;r>e;e++)for(var u,i=t[e],a=0,o=i.length;o>a;a++)(u=i[a])&&n(u,a,e);return t}function qn(t){return Ii(t,xa),t}function Cn(t,n){return Ii(t,wa),t.id=n,t}function zn(t,n,e,r){var u=t.__transition__||(t.__transition__={active:0,count:0}),a=u[e];if(!a){var o=r.time;return a=u[e]={tween:new i,event:qi.dispatch("start","end"),time:o,ease:r.ease,delay:r.delay,duration:r.duration},++u.count,qi.timer(function(r){function i(r){return u.active>e?l():(u.active=e,h.start.call(t,f,n),a.tween.forEach(function(e,r){(r=r.call(t,f,n))&&d.push(r)}),c(r)||qi.timer(c,0,o),1)}function c(r){if(u.active!==e)return l();for(var i=(r-g)/p,a=s(i),o=d.length;o>0;)d[--o].call(t,a);return i>=1?(l(),h.end.call(t,f,n),1):void 0}function l(){return--u.count?delete u[e]:delete t.__transition__,1}var f=t.__data__,s=a.ease,h=a.event,g=a.delay,p=a.duration,d=[];return r>=g?i(r):qi.timer(i,g,o),1},0,o),a}}function Dn(t){return null==t&&(t=""),function(){this.textContent=t}}function Ln(t,n,e,r){var u=t.id;return Tn(t,"function"==typeof e?function(t,i,a){t.__transition__[u].tween.set(n,r(e.call(t,t.__data__,i,a)))}:(e=r(e),function(t){t.__transition__[u].tween.set(n,e)}))}function Fn(){for(var t,n=Date.now(),e=qa;e;)t=n-e.then,t>=e.delay&&(e.flush=e.callback(t)),e=e.next;var r=Hn()-n;r>24?(isFinite(r)&&(clearTimeout(Aa),Aa=setTimeout(Fn,r)),Ea=0):(Ea=1,Ca(Fn))}function Hn(){for(var t=null,n=qa,e=1/0;n;)n.flush?(delete Ta[n.callback.id],n=t?t.next=n.next:qa=n.next):(e=Math.min(e,n.then+n.delay),n=(t=n).next);return e}function jn(t,n){var e=t.ownerSVGElement||t;if(e.createSVGPoint){var r=e.createSVGPoint();if(0>za&&(Li.scrollX||Li.scrollY)){e=qi.select(Di.body).append("svg").style("position","absolute").style("top",0).style("left",0);var u=e[0][0].getScreenCTM();za=!(u.f||u.e),e.remove()}return za?(r.x=n.pageX,r.y=n.pageY):(r.x=n.clientX,r.y=n.clientY),r=r.matrixTransform(t.getScreenCTM().inverse()),[r.x,r.y]}var i=t.getBoundingClientRect();return[n.clientX-i.left-t.clientLeft,n.clientY-i.top-t.clientTop]}function Pn(){}function Rn(t){var n=t[0],e=t[t.length-1];return e>n?[n,e]:[e,n]}function On(t){return t.rangeExtent?t.rangeExtent():Rn(t.range())}function Yn(t,n){var e,r=0,u=t.length-1,i=t[r],a=t[u];return i>a&&(e=r,r=u,u=e,e=i,i=a,a=e),(n=n(a-i))&&(t[r]=n.floor(i),t[u]=n.ceil(a)),t}function Un(){return Math}function In(t,n,e,r){function u(){var u=Math.min(t.length,n.length)>2?Gn:Jn,c=r?Z:X;return a=u(t,n,c,e),o=u(n,t,c,qi.interpolate),i}function i(t){return a(t)}var a,o;return i.invert=function(t){return o(t)},i.domain=function(n){return arguments.length?(t=n.map(Number),u()):t},i.range=function(t){return arguments.length?(n=t,u()):n},i.rangeRound=function(t){return i.range(t).interpolate(qi.interpolateRound)},i.clamp=function(t){return arguments.length?(r=t,u()):r},i.interpolate=function(t){return arguments.length?(e=t,u()):e},i.ticks=function(n){return Bn(t,n)},i.tickFormat=function(n){return $n(t,n)},i.nice=function(){return Yn(t,Xn),u()},i.copy=function(){return In(t,n,e,r)},u()}function Vn(t,n){return qi.rebind(t,n,"range","rangeRound","interpolate","clamp")}function Xn(t){return t=Math.pow(10,Math.round(Math.log(t)/Math.LN10)-1),t&&{floor:function(n){return Math.floor(n/t)*t},ceil:function(n){return Math.ceil(n/t)*t}}}function Zn(t,n){var e=Rn(t),r=e[1]-e[0],u=Math.pow(10,Math.floor(Math.log(r/n)/Math.LN10)),i=n/r*u;return.15>=i?u*=10:.35>=i?u*=5:.75>=i&&(u*=2),e[0]=Math.ceil(e[0]/u)*u,e[1]=Math.floor(e[1]/u)*u+.5*u,e[2]=u,e}function Bn(t,n){return qi.range.apply(qi,Zn(t,n))}function $n(t,n){return qi.format(",."+Math.max(0,-Math.floor(Math.log(Zn(t,n)[2])/Math.LN10+.01))+"f")}function Jn(t,n,e,r){var u=e(t[0],t[1]),i=r(n[0],n[1]);return function(t){return i(u(t))}}function Gn(t,n,e,r){var u=[],i=[],a=0,o=Math.min(t.length,n.length)-1;for(t[o]<t[0]&&(t=t.slice().reverse(),n=n.slice().reverse());o>=++a;)u.push(e(t[a-1],t[a])),i.push(r(n[a-1],n[a]));return function(n){var e=qi.bisect(t,n,1,o)-1;return i[e](u[e](n))}}function Kn(t,n){function e(e){return t(n(e))}var r=n.pow;return e.invert=function(n){return r(t.invert(n))},e.domain=function(u){return arguments.length?(n=0>u[0]?Qn:Wn,r=n.pow,t.domain(u.map(n)),e):t.domain().map(r)},e.nice=function(){return t.domain(Yn(t.domain(),Un)),e},e.ticks=function(){var e=Rn(t.domain()),u=[];if(e.every(isFinite)){var i=Math.floor(e[0]),a=Math.ceil(e[1]),o=r(e[0]),c=r(e[1]);if(n===Qn)for(u.push(r(i));a>i++;)for(var l=9;l>0;l--)u.push(r(i)*l);else{for(;a>i;i++)for(var l=1;10>l;l++)u.push(r(i)*l);u.push(r(i))}for(i=0;o>u[i];i++);for(a=u.length;u[a-1]>c;a--);u=u.slice(i,a)}return u},e.tickFormat=function(t,u){if(2>arguments.length&&(u=Da),!arguments.length)return u;var i,a=Math.max(.1,t/e.ticks().length),o=n===Qn?(i=-1e-12,Math.floor):(i=1e-12,Math.ceil);return function(t){return a>=t/r(o(n(t)+i))?u(t):""}},e.copy=function(){return Kn(t.copy(),n)},Vn(e,t)}function Wn(t){return Math.log(0>t?0:t)/Math.LN10}function Qn(t){return-Math.log(t>0?0:-t)/Math.LN10}function te(t,n){function e(n){return t(r(n))}var r=ne(n),u=ne(1/n);return e.invert=function(n){return u(t.invert(n))},e.domain=function(n){return arguments.length?(t.domain(n.map(r)),e):t.domain().map(u)},e.ticks=function(t){return Bn(e.domain(),t)},e.tickFormat=function(t){return $n(e.domain(),t)},e.nice=function(){return e.domain(Yn(e.domain(),Xn))},e.exponent=function(t){if(!arguments.length)return n;var i=e.domain();return r=ne(n=t),u=ne(1/n),e.domain(i)},e.copy=function(){return te(t.copy(),n)},Vn(e,t)}function ne(t){return function(n){return 0>n?-Math.pow(-n,t):Math.pow(n,t)}}function ee(t,n){function e(n){return a[((u.get(n)||u.set(n,t.push(n)))-1)%a.length]}function r(n,e){return qi.range(t.length).map(function(t){return n+e*t})}var u,a,o;return e.domain=function(r){if(!arguments.length)return t;t=[],u=new i;for(var a,o=-1,c=r.length;c>++o;)u.has(a=r[o])||u.set(a,t.push(a));return e[n.t].apply(e,n.a)},e.range=function(t){return arguments.length?(a=t,o=0,n={t:"range",a:arguments},e):a},e.rangePoints=function(u,i){2>arguments.length&&(i=0);var c=u[0],l=u[1],f=(l-c)/(Math.max(1,t.length-1)+i);return a=r(2>t.length?(c+l)/2:c+f*i/2,f),o=0,n={t:"rangePoints",a:arguments},e},e.rangeBands=function(u,i,c){2>arguments.length&&(i=0),3>arguments.length&&(c=i);var l=u[1]<u[0],f=u[l-0],s=u[1-l],h=(s-f)/(t.length-i+2*c);return a=r(f+h*c,h),l&&a.reverse(),o=h*(1-i),n={t:"rangeBands",a:arguments},e},e.rangeRoundBands=function(u,i,c){2>arguments.length&&(i=0),3>arguments.length&&(c=i);var l=u[1]<u[0],f=u[l-0],s=u[1-l],h=Math.floor((s-f)/(t.length-i+2*c)),g=s-f-(t.length-i)*h;return a=r(f+Math.round(g/2),h),l&&a.reverse(),o=Math.round(h*(1-i)),n={t:"rangeRoundBands",a:arguments},e},e.rangeBand=function(){return o},e.rangeExtent=function(){return Rn(n.a[0])},e.copy=function(){return ee(t,n)},e.domain(t)}function re(t,n){function e(){var e=0,i=n.length;for(u=[];i>++e;)u[e-1]=qi.quantile(t,e/i);return r}function r(t){return isNaN(t=+t)?0/0:n[qi.bisect(u,t)]}var u;return r.domain=function(n){return arguments.length?(t=n.filter(function(t){return!isNaN(t)}).sort(qi.ascending),e()):t},r.range=function(t){return arguments.length?(n=t,e()):n},r.quantiles=function(){return u},r.copy=function(){return re(t,n)},e()}function ue(t,n,e){function r(n){return e[Math.max(0,Math.min(a,Math.floor(i*(n-t))))]}function u(){return i=e.length/(n-t),a=e.length-1,r}var i,a;return r.domain=function(e){return arguments.length?(t=+e[0],n=+e[e.length-1],u()):[t,n]},r.range=function(t){return arguments.length?(e=t,u()):e},r.copy=function(){return ue(t,n,e)},u()}function ie(t,n){function e(e){return n[qi.bisect(t,e)]}return e.domain=function(n){return arguments.length?(t=n,e):t},e.range=function(t){return arguments.length?(n=t,e):n},e.copy=function(){return ie(t,n)},e}function ae(t){function n(t){return+t}return n.invert=n,n.domain=n.range=function(e){return arguments.length?(t=e.map(n),n):t},n.ticks=function(n){return Bn(t,n)},n.tickFormat=function(n){return $n(t,n)},n.copy=function(){return ae(t)},n}function oe(t){return t.innerRadius}function ce(t){return t.outerRadius}function le(t){return t.startAngle}function fe(t){return t.endAngle}function se(t){function n(n){function a(){f.push("M",i(t(s),l))}for(var o,f=[],s=[],h=-1,g=n.length,p=c(e),d=c(r);g>++h;)u.call(this,o=n[h],h)?s.push([+p.call(this,o,h),+d.call(this,o,h)]):s.length&&(a(),s=[]);return s.length&&a(),f.length?f.join(""):null}var e=he,r=ge,u=o,i=pe,a=i.key,l=.7;return n.x=function(t){return arguments.length?(e=t,n):e},n.y=function(t){return arguments.length?(r=t,n):r},n.defined=function(t){return arguments.length?(u=t,n):u},n.interpolate=function(t){return arguments.length?(a="function"==typeof t?i=t:(i=Oa.get(t)||pe).key,n):a},n.tension=function(t){return arguments.length?(l=t,n):l},n}function he(t){return t[0]}function ge(t){return t[1]}function pe(t){return t.join("L")}function de(t){return pe(t)+"Z"}function me(t){for(var n=0,e=t.length,r=t[0],u=[r[0],",",r[1]];e>++n;)u.push("V",(r=t[n])[1],"H",r[0]);return u.join("")}function ve(t){for(var n=0,e=t.length,r=t[0],u=[r[0],",",r[1]];e>++n;)u.push("H",(r=t[n])[0],"V",r[1]);return u.join("")}function ye(t,n){return 4>t.length?pe(t):t[1]+xe(t.slice(1,t.length-1),_e(t,n))}function Me(t,n){return 3>t.length?pe(t):t[0]+xe((t.push(t[0]),t),_e([t[t.length-2]].concat(t,[t[1]]),n))}function be(t,n){return 3>t.length?pe(t):t[0]+xe(t,_e(t,n))}function xe(t,n){if(1>n.length||t.length!=n.length&&t.length!=n.length+2)return pe(t);var e=t.length!=n.length,r="",u=t[0],i=t[1],a=n[0],o=a,c=1;if(e&&(r+="Q"+(i[0]-2*a[0]/3)+","+(i[1]-2*a[1]/3)+","+i[0]+","+i[1],u=t[1],c=2),n.length>1){o=n[1],i=t[c],c++,r+="C"+(u[0]+a[0])+","+(u[1]+a[1])+","+(i[0]-o[0])+","+(i[1]-o[1])+","+i[0]+","+i[1];for(var l=2;n.length>l;l++,c++)i=t[c],o=n[l],r+="S"+(i[0]-o[0])+","+(i[1]-o[1])+","+i[0]+","+i[1]}if(e){var f=t[c];r+="Q"+(i[0]+2*o[0]/3)+","+(i[1]+2*o[1]/3)+","+f[0]+","+f[1]}return r}function _e(t,n){for(var e,r=[],u=(1-n)/2,i=t[0],a=t[1],o=1,c=t.length;c>++o;)e=i,i=a,a=t[o],r.push([u*(a[0]-e[0]),u*(a[1]-e[1])]);return r}function we(t){if(3>t.length)return pe(t);var n=1,e=t.length,r=t[0],u=r[0],i=r[1],a=[u,u,u,(r=t[1])[0]],o=[i,i,i,r[1]],c=[u,",",i];for(Ne(c,a,o);e>++n;)r=t[n],a.shift(),a.push(r[0]),o.shift(),o.push(r[1]),Ne(c,a,o);for(n=-1;2>++n;)a.shift(),a.push(r[0]),o.shift(),o.push(r[1]),Ne(c,a,o);return c.join("")}function Se(t){if(4>t.length)return pe(t);for(var n,e=[],r=-1,u=t.length,i=[0],a=[0];3>++r;)n=t[r],i.push(n[0]),a.push(n[1]);for(e.push(Ae(Ia,i)+","+Ae(Ia,a)),--r;u>++r;)n=t[r],i.shift(),i.push(n[0]),a.shift(),a.push(n[1]),Ne(e,i,a);return e.join("")}function ke(t){for(var n,e,r=-1,u=t.length,i=u+4,a=[],o=[];4>++r;)e=t[r%u],a.push(e[0]),o.push(e[1]);for(n=[Ae(Ia,a),",",Ae(Ia,o)],--r;i>++r;)e=t[r%u],a.shift(),a.push(e[0]),o.shift(),o.push(e[1]),Ne(n,a,o);return n.join("")}function Ee(t,n){var e=t.length-1;if(e)for(var r,u,i=t[0][0],a=t[0][1],o=t[e][0]-i,c=t[e][1]-a,l=-1;e>=++l;)r=t[l],u=l/e,r[0]=n*r[0]+(1-n)*(i+u*o),r[1]=n*r[1]+(1-n)*(a+u*c);return we(t)}function Ae(t,n){return t[0]*n[0]+t[1]*n[1]+t[2]*n[2]+t[3]*n[3]}function Ne(t,n,e){t.push("C",Ae(Ya,n),",",Ae(Ya,e),",",Ae(Ua,n),",",Ae(Ua,e),",",Ae(Ia,n),",",Ae(Ia,e))}function Te(t,n){return(n[1]-t[1])/(n[0]-t[0])}function qe(t){for(var n=0,e=t.length-1,r=[],u=t[0],i=t[1],a=r[0]=Te(u,i);e>++n;)r[n]=(a+(a=Te(u=i,i=t[n+1])))/2;return r[n]=a,r}function Ce(t){for(var n,e,r,u,i=[],a=qe(t),o=-1,c=t.length-1;c>++o;)n=Te(t[o],t[o+1]),1e-6>Math.abs(n)?a[o]=a[o+1]=0:(e=a[o]/n,r=a[o+1]/n,u=e*e+r*r,u>9&&(u=3*n/Math.sqrt(u),a[o]=u*e,a[o+1]=u*r));for(o=-1;c>=++o;)u=(t[Math.min(c,o+1)][0]-t[Math.max(0,o-1)][0])/(6*(1+a[o]*a[o])),i.push([u||0,a[o]*u||0]);return i}function ze(t){return 3>t.length?pe(t):t[0]+xe(t,Ce(t))}function De(t){for(var n,e,r,u=-1,i=t.length;i>++u;)n=t[u],e=n[0],r=n[1]+Pa,n[0]=e*Math.cos(r),n[1]=e*Math.sin(r);return t}function Le(t){function n(n){function o(){m.push("M",l(t(y),g),h,s(t(v.reverse()),g),"Z")}for(var f,p,d,m=[],v=[],y=[],M=-1,b=n.length,x=c(e),_=c(u),w=e===r?function(){return p}:c(r),S=u===i?function(){return d}:c(i);b>++M;)a.call(this,f=n[M],M)?(v.push([p=+x.call(this,f,M),d=+_.call(this,f,M)]),y.push([+w.call(this,f,M),+S.call(this,f,M)])):v.length&&(o(),v=[],y=[]);return v.length&&o(),m.length?m.join(""):null}var e=he,r=he,u=0,i=ge,a=o,l=pe,f=l.key,s=l,h="L",g=.7;return n.x=function(t){return arguments.length?(e=r=t,n):r},n.x0=function(t){return arguments.length?(e=t,n):e},n.x1=function(t){return arguments.length?(r=t,n):r},n.y=function(t){return arguments.length?(u=i=t,n):i},n.y0=function(t){return arguments.length?(u=t,n):u},n.y1=function(t){return arguments.length?(i=t,n):i},n.defined=function(t){return arguments.length?(a=t,n):a},n.interpolate=function(t){return arguments.length?(f="function"==typeof t?l=t:(l=Oa.get(t)||pe).key,s=l.reverse||l,h=l.closed?"M":"L",n):f},n.tension=function(t){return arguments.length?(g=t,n):g},n}function Fe(t){return t.radius}function He(t){return[t.x,t.y]}function je(t){return function(){var n=t.apply(this,arguments),e=n[0],r=n[1]+Pa;return[e*Math.cos(r),e*Math.sin(r)]}}function Pe(){return 64}function Re(){return"circle"}function Oe(t){var n=Math.sqrt(t/Ni);return"M0,"+n+"A"+n+","+n+" 0 1,1 0,"+-n+"A"+n+","+n+" 0 1,1 0,"+n+"Z"}function Ye(t,n){t.attr("transform",function(t){return"translate("+n(t)+",0)"})}function Ue(t,n){t.attr("transform",function(t){return"translate(0,"+n(t)+")"})}function Ie(t,n,e){if(r=[],e&&n.length>1){for(var r,u,i,a=Rn(t.domain()),o=-1,c=n.length,l=(n[1]-n[0])/++e;c>++o;)for(u=e;--u>0;)(i=+n[o]-u*l)>=a[0]&&r.push(i);for(--o,u=0;e>++u&&(i=+n[o]+u*l)<a[1];)r.push(i)}return r}function Ve(t){for(var n=t.source,e=t.target,r=Ze(n,e),u=[n];n!==r;)n=n.parent,u.push(n);for(var i=u.length;e!==r;)u.splice(i,0,e),e=e.parent;return u}function Xe(t){for(var n=[],e=t.parent;null!=e;)n.push(t),t=e,e=e.parent;return n.push(t),n}function Ze(t,n){if(t===n)return t;for(var e=Xe(t),r=Xe(n),u=e.pop(),i=r.pop(),a=null;u===i;)a=u,u=e.pop(),i=r.pop();return a}function Be(t){t.fixed|=2}function $e(t){t.fixed&=-7}function Je(t){t.fixed|=4,t.px=t.x,t.py=t.y}function Ge(t){t.fixed&=-5}function Ke(t,n,e){var r=0,u=0;if(t.charge=0,!t.leaf)for(var i,a=t.nodes,o=a.length,c=-1;o>++c;)i=a[c],null!=i&&(Ke(i,n,e),t.charge+=i.charge,r+=i.charge*i.cx,u+=i.charge*i.cy);if(t.point){t.leaf||(t.point.x+=Math.random()-.5,t.point.y+=Math.random()-.5);var l=n*e[t.point.index];t.charge+=t.pointCharge=l,r+=l*t.point.x,u+=l*t.point.y}t.cx=r/t.charge,t.cy=u/t.charge}function We(t){return t.x}function Qe(t){return t.y}function tr(t,n,e){t.y0=n,t.y=e}function nr(t){return qi.range(t.length)}function er(t){for(var n=-1,e=t[0].length,r=[];e>++n;)r[n]=0;return r}function rr(t){for(var n,e=1,r=0,u=t[0][1],i=t.length;i>e;++e)(n=t[e][1])>u&&(r=e,u=n);return r}function ur(t){return t.reduce(ir,0)}function ir(t,n){return t+n[1]}function ar(t,n){return or(t,Math.ceil(Math.log(n.length)/Math.LN2+1))}function or(t,n){for(var e=-1,r=+t[0],u=(t[1]-r)/n,i=[];n>=++e;)i[e]=u*e+r;return i}function cr(t){return[qi.min(t),qi.max(t)]}function lr(t,n){return qi.rebind(t,n,"sort","children","value"),t.nodes=t,t.links=gr,t}function fr(t){return t.children}function sr(t){return t.value}function hr(t,n){return n.value-t.value}function gr(t){return qi.merge(t.map(function(t){return(t.children||[]).map(function(n){return{source:t,target:n}})}))}function pr(t,n){return t.value-n.value}function dr(t,n){var e=t._pack_next;t._pack_next=n,n._pack_prev=t,n._pack_next=e,e._pack_prev=n}function mr(t,n){t._pack_next=n,n._pack_prev=t}function vr(t,n){var e=n.x-t.x,r=n.y-t.y,u=t.r+n.r;return u*u-e*e-r*r>.001}function yr(t){function n(t){f=Math.min(t.x-t.r,f),s=Math.max(t.x+t.r,s),h=Math.min(t.y-t.r,h),g=Math.max(t.y+t.r,g)}if((e=t.children)&&(l=e.length)){var e,r,u,i,a,o,c,l,f=1/0,s=-1/0,h=1/0,g=-1/0;if(e.forEach(Mr),r=e[0],r.x=-r.r,r.y=0,n(r),l>1&&(u=e[1],u.x=u.r,u.y=0,n(u),l>2))for(i=e[2],_r(r,u,i),n(i),dr(r,i),r._pack_prev=i,dr(i,u),u=r._pack_next,a=3;l>a;a++){_r(r,u,i=e[a]);var p=0,d=1,m=1;for(o=u._pack_next;o!==u;o=o._pack_next,d++)if(vr(o,i)){p=1;break}if(1==p)for(c=r._pack_prev;c!==o._pack_prev&&!vr(c,i);c=c._pack_prev,m++);p?(m>d||d==m&&u.r<r.r?mr(r,u=o):mr(r=c,u),a--):(dr(r,i),u=i,n(i))}var v=(f+s)/2,y=(h+g)/2,M=0;for(a=0;l>a;a++)i=e[a],i.x-=v,i.y-=y,M=Math.max(M,i.r+Math.sqrt(i.x*i.x+i.y*i.y));t.r=M,e.forEach(br)}}function Mr(t){t._pack_next=t._pack_prev=t}function br(t){delete t._pack_next,delete t._pack_prev}function xr(t,n,e,r){var u=t.children;if(t.x=n+=r*t.x,t.y=e+=r*t.y,t.r*=r,u)for(var i=-1,a=u.length;a>++i;)xr(u[i],n,e,r)}function _r(t,n,e){var r=t.r+e.r,u=n.x-t.x,i=n.y-t.y;if(r&&(u||i)){var a=n.r+e.r,o=u*u+i*i;a*=a,r*=r;var c=.5+(r-a)/(2*o),l=Math.sqrt(Math.max(0,2*a*(r+o)-(r-=o)*r-a*a))/(2*o);e.x=t.x+c*u+l*i,e.y=t.y+c*i-l*u}else e.x=t.x+r,e.y=t.y}function wr(t){return 1+qi.max(t,function(t){return t.y})}function Sr(t){return t.reduce(function(t,n){return t+n.x},0)/t.length}function kr(t){var n=t.children;return n&&n.length?kr(n[0]):t}function Er(t){var n,e=t.children;return e&&(n=e.length)?Er(e[n-1]):t}function Ar(t,n){return t.parent==n.parent?1:2}function Nr(t){var n=t.children;return n&&n.length?n[0]:t._tree.thread}function Tr(t){var n,e=t.children;return e&&(n=e.length)?e[n-1]:t._tree.thread}function qr(t,n){var e=t.children;if(e&&(u=e.length))for(var r,u,i=-1;u>++i;)n(r=qr(e[i],n),t)>0&&(t=r);return t}function Cr(t,n){return t.x-n.x}function zr(t,n){return n.x-t.x}function Dr(t,n){return t.depth-n.depth}function Lr(t,n){function e(t,r){var u=t.children;if(u&&(a=u.length))for(var i,a,o=null,c=-1;a>++c;)i=u[c],e(i,o),o=i;n(t,r)}e(t,null)}function Fr(t){for(var n,e=0,r=0,u=t.children,i=u.length;--i>=0;)n=u[i]._tree,n.prelim+=e,n.mod+=e,e+=n.shift+(r+=n.change)}function Hr(t,n,e){t=t._tree,n=n._tree;var r=e/(n.number-t.number);t.change+=r,n.change-=r,n.shift+=e,n.prelim+=e,n.mod+=e}function jr(t,n,e){return t._tree.ancestor.parent==n.parent?t._tree.ancestor:e}function Pr(t){return{x:t.x,y:t.y,dx:t.dx,dy:t.dy}}function Rr(t,n){var e=t.x+n[3],r=t.y+n[0],u=t.dx-n[1]-n[3],i=t.dy-n[0]-n[2];return 0>u&&(e+=u/2,u=0),0>i&&(r+=i/2,i=0),{x:e,y:r,dx:u,dy:i}}function Or(t,n){function e(t,e){return qi.xhr(t,n,e).response(r)}function r(t){return e.parse(t.responseText)}function u(n){return n.map(i).join(t)}function i(t){return a.test(t)?'"'+t.replace(/\"/g,'""')+'"':t}var a=RegExp('["'+t+"\n]"),o=t.charCodeAt(0);return e.parse=function(t){var n;return e.parseRows(t,function(t){return n?n(t):(n=Function("d","return {"+t.map(function(t,n){return JSON.stringify(t)+": d["+n+"]"}).join(",")+"}"),void 0)})},e.parseRows=function(t,n){function e(){if(f>=l)return a;if(u)return u=!1,i;var n=f;if(34===t.charCodeAt(n)){for(var e=n;l>e++;)if(34===t.charCodeAt(e)){if(34!==t.charCodeAt(e+1))break;++e}f=e+2;var r=t.charCodeAt(e+1);return 13===r?(u=!0,10===t.charCodeAt(e+2)&&++f):10===r&&(u=!0),t.substring(n+1,e).replace(/""/g,'"')}for(;l>f;){var r=t.charCodeAt(f++),c=1;if(10===r)u=!0;else if(13===r)u=!0,10===t.charCodeAt(f)&&(++f,++c);else if(r!==o)continue;return t.substring(n,f-c)}return t.substring(n)}for(var r,u,i={},a={},c=[],l=t.length,f=0,s=0;(r=e())!==a;){for(var h=[];r!==i&&r!==a;)h.push(r),r=e();(!n||(h=n(h,s++)))&&c.push(h)}return c},e.format=function(t){return t.map(u).join("\n")},e}function Yr(t,n){ao.hasOwnProperty(t.type)&&ao[t.type](t,n)}function Ur(t,n,e){var r,u=-1,i=t.length-e;for(n.lineStart();i>++u;)r=t[u],n.point(r[0],r[1]);n.lineEnd()}function Ir(t,n){var e=-1,r=t.length;for(n.polygonStart();r>++e;)Ur(t[e],n,1);n.polygonEnd()}function Vr(t){return[Math.atan2(t[1],t[0]),Math.asin(Math.max(-1,Math.min(1,t[2])))]}function Xr(t,n){return Ti>Math.abs(t[0]-n[0])&&Ti>Math.abs(t[1]-n[1])}function Zr(t){var n=t[0],e=t[1],r=Math.cos(e);return[r*Math.cos(n),r*Math.sin(n),Math.sin(e)]}function Br(t,n){return t[0]*n[0]+t[1]*n[1]+t[2]*n[2]}function $r(t,n){return[t[1]*n[2]-t[2]*n[1],t[2]*n[0]-t[0]*n[2],t[0]*n[1]-t[1]*n[0]]}function Jr(t,n){t[0]+=n[0],t[1]+=n[1],t[2]+=n[2]}function Gr(t,n){return[t[0]*n,t[1]*n,t[2]*n]}function Kr(t){var n=Math.sqrt(t[0]*t[0]+t[1]*t[1]+t[2]*t[2]);t[0]/=n,t[1]/=n,t[2]/=n}function Wr(t){function n(n){function r(e,r){e=t(e,r),n.point(e[0],e[1])}function i(){f=0/0,d.point=a,n.lineStart()}function a(r,i){var a=Zr([r,i]),o=t(r,i);e(f,s,l,h,g,p,f=o[0],s=o[1],l=r,h=a[0],g=a[1],p=a[2],u,n),n.point(f,s)}function o(){d.point=r,n.lineEnd()}function c(){var t,r,c,m,v,y,M;i(),d.point=function(n,e){a(t=n,r=e),c=f,m=s,v=h,y=g,M=p,d.point=a},d.lineEnd=function(){e(f,s,l,h,g,p,c,m,t,v,y,M,u,n),d.lineEnd=o,o()}}var l,f,s,h,g,p,d={point:r,lineStart:i,lineEnd:o,polygonStart:function(){n.polygonStart(),d.lineStart=c},polygonEnd:function(){n.polygonEnd(),d.lineStart=i}};return d}function e(n,u,i,a,o,c,l,f,s,h,g,p,d,m){var v=l-n,y=f-u,M=v*v+y*y;if(M>4*r&&d--){var b=a+h,x=o+g,_=c+p,w=Math.sqrt(b*b+x*x+_*_),S=Math.asin(_/=w),k=Ti>Math.abs(Math.abs(_)-1)?(i+s)/2:Math.atan2(x,b),E=t(k,S),A=E[0],N=E[1],T=A-n,q=N-u,C=y*T-v*q;(C*C/M>r||Math.abs((v*T+y*q)/M-.5)>.3)&&(e(n,u,i,a,o,c,A,N,k,b/=w,x/=w,_,d,m),m.point(A,N),e(A,N,k,b,x,_,l,f,s,h,g,p,d,m))}}var r=.5,u=16;return n.precision=function(t){return arguments.length?(u=(r=t*t)>0&&16,n):Math.sqrt(r)},n}function Qr(t,n){function e(t,n){var e=Math.sqrt(i-2*u*Math.sin(n))/u;return[e*Math.sin(t*=u),a-e*Math.cos(t)]}var r=Math.sin(t),u=(r+Math.sin(n))/2,i=1+r*(2*u-r),a=Math.sqrt(i)/u;return e.invert=function(t,n){var e=a-n;return[Math.atan2(t,e)/u,Math.asin((i-(t*t+e*e)*u*u)/(2*u))]},e}function tu(t){function n(t,n){r>t&&(r=t),t>i&&(i=t),u>n&&(u=n),n>a&&(a=n)}function e(){o.point=o.lineEnd=Pn}var r,u,i,a,o={point:n,lineStart:Pn,lineEnd:Pn,polygonStart:function(){o.lineEnd=e},polygonEnd:function(){o.point=n}};return function(n){return a=i=-(r=u=1/0),qi.geo.stream(n,t(o)),[[r,u],[i,a]]}}function nu(t,n){if(!lo){++fo,t*=Ci;var e=Math.cos(n*=Ci);so+=(e*Math.cos(t)-so)/fo,ho+=(e*Math.sin(t)-ho)/fo,go+=(Math.sin(n)-go)/fo}}function eu(){var t,n;lo=1,ru(),lo=2;var e=po.point;po.point=function(r,u){e(t=r,n=u)},po.lineEnd=function(){po.point(t,n),uu(),po.lineEnd=uu}}function ru(){function t(t,u){t*=Ci;var i=Math.cos(u*=Ci),a=i*Math.cos(t),o=i*Math.sin(t),c=Math.sin(u),l=Math.atan2(Math.sqrt((l=e*c-r*o)*l+(l=r*a-n*c)*l+(l=n*o-e*a)*l),n*a+e*o+r*c);fo+=l,so+=l*(n+(n=a)),ho+=l*(e+(e=o)),go+=l*(r+(r=c))}var n,e,r;lo>1||(1>lo&&(lo=1,fo=so=ho=go=0),po.point=function(u,i){u*=Ci;var a=Math.cos(i*=Ci);n=a*Math.cos(u),e=a*Math.sin(u),r=Math.sin(i),po.point=t})}function uu(){po.point=nu}function iu(t,n){var e=Math.cos(t),r=Math.sin(t);return function(u,i,a,o){null!=u?(u=au(e,u),i=au(e,i),(a>0?i>u:u>i)&&(u+=2*a*Ni)):(u=t+2*a*Ni,i=t);for(var c,l=a*n,f=u;a>0?f>i:i>f;f-=l)o.point((c=Vr([e,-r*Math.cos(f),-r*Math.sin(f)]))[0],c[1])}}function au(t,n){var e=Zr(n);e[0]-=t,Kr(e);var r=Math.acos(Math.max(-1,Math.min(1,-e[1])));return((0>-e[2]?-r:r)+2*Math.PI-Ti)%(2*Math.PI)}function ou(t,n,e){return function(r){function u(n,e){t(n,e)&&r.point(n,e)}function i(t,n){m.point(t,n)}function a(){v.point=i,m.lineStart()}function o(){v.point=u,m.lineEnd()}function c(t,n){M.point(t,n),d.push([t,n])}function l(){M.lineStart(),d=[]}function f(){c(d[0][0],d[0][1]),M.lineEnd();var t,n=M.clean(),e=y.buffer(),u=e.length;if(!u)return p=!0,g+=gu(d,-1),d=null,void 0;if(d=null,1&n){t=e[0],h+=gu(t,1);var i,u=t.length-1,a=-1;for(r.lineStart();u>++a;)r.point((i=t[a])[0],i[1]);return r.lineEnd(),void 0}u>1&&2&n&&e.push(e.pop().concat(e.shift())),s.push(e.filter(su))}var s,h,g,p,d,m=n(r),v={point:u,lineStart:a,lineEnd:o,polygonStart:function(){v.point=c,v.lineStart=l,v.lineEnd=f,p=!1,g=h=0,s=[],r.polygonStart()},polygonEnd:function(){v.point=u,v.lineStart=a,v.lineEnd=o,s=qi.merge(s),s.length?cu(s,e,r):(-Ti>h||p&&-Ti>g)&&(r.lineStart(),e(null,null,1,r),r.lineEnd()),r.polygonEnd(),s=null},sphere:function(){r.polygonStart(),r.lineStart(),e(null,null,1,r),r.lineEnd(),r.polygonEnd()}},y=hu(),M=n(y);return v}}function cu(t,n,e){var r=[],u=[];if(t.forEach(function(t){var n=t.length;if(!(1>=n)){var e=t[0],i=t[n-1],a={point:e,points:t,other:null,visited:!1,entry:!0,subject:!0},o={point:e,points:[e],other:a,visited:!1,entry:!1,subject:!1};
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

//     Underscore.js 1.5.1
//     http://underscorejs.org
//     (c) 2009-2013 Jeremy Ashkenas, DocumentCloud and Investigative Reporters & Editors
//     Underscore may be freely distributed under the MIT license.
!function(){var n=this,t=n._,r={},e=Array.prototype,u=Object.prototype,i=Function.prototype,a=e.push,o=e.slice,c=e.concat,l=u.toString,f=u.hasOwnProperty,s=e.forEach,p=e.map,v=e.reduce,h=e.reduceRight,d=e.filter,g=e.every,m=e.some,y=e.indexOf,b=e.lastIndexOf,x=Array.isArray,_=Object.keys,w=i.bind,j=function(n){return n instanceof j?n:this instanceof j?(this._wrapped=n,void 0):new j(n)};"undefined"!=typeof exports?("undefined"!=typeof module&&module.exports&&(exports=module.exports=j),exports._=j):n._=j,j.VERSION="1.5.1";var A=j.each=j.forEach=function(n,t,e){if(null!=n)if(s&&n.forEach===s)n.forEach(t,e);else if(n.length===+n.length){for(var u=0,i=n.length;i>u;u++)if(t.call(e,n[u],u,n)===r)return}else for(var a in n)if(j.has(n,a)&&t.call(e,n[a],a,n)===r)return};j.map=j.collect=function(n,t,r){var e=[];return null==n?e:p&&n.map===p?n.map(t,r):(A(n,function(n,u,i){e.push(t.call(r,n,u,i))}),e)};var E="Reduce of empty array with no initial value";j.reduce=j.foldl=j.inject=function(n,t,r,e){var u=arguments.length>2;if(null==n&&(n=[]),v&&n.reduce===v)return e&&(t=j.bind(t,e)),u?n.reduce(t,r):n.reduce(t);if(A(n,function(n,i,a){u?r=t.call(e,r,n,i,a):(r=n,u=!0)}),!u)throw new TypeError(E);return r},j.reduceRight=j.foldr=function(n,t,r,e){var u=arguments.length>2;if(null==n&&(n=[]),h&&n.reduceRight===h)return e&&(t=j.bind(t,e)),u?n.reduceRight(t,r):n.reduceRight(t);var i=n.length;if(i!==+i){var a=j.keys(n);i=a.length}if(A(n,function(o,c,l){c=a?a[--i]:--i,u?r=t.call(e,r,n[c],c,l):(r=n[c],u=!0)}),!u)throw new TypeError(E);return r},j.find=j.detect=function(n,t,r){var e;return O(n,function(n,u,i){return t.call(r,n,u,i)?(e=n,!0):void 0}),e},j.filter=j.select=function(n,t,r){var e=[];return null==n?e:d&&n.filter===d?n.filter(t,r):(A(n,function(n,u,i){t.call(r,n,u,i)&&e.push(n)}),e)},j.reject=function(n,t,r){return j.filter(n,function(n,e,u){return!t.call(r,n,e,u)},r)},j.every=j.all=function(n,t,e){t||(t=j.identity);var u=!0;return null==n?u:g&&n.every===g?n.every(t,e):(A(n,function(n,i,a){return(u=u&&t.call(e,n,i,a))?void 0:r}),!!u)};var O=j.some=j.any=function(n,t,e){t||(t=j.identity);var u=!1;return null==n?u:m&&n.some===m?n.some(t,e):(A(n,function(n,i,a){return u||(u=t.call(e,n,i,a))?r:void 0}),!!u)};j.contains=j.include=function(n,t){return null==n?!1:y&&n.indexOf===y?n.indexOf(t)!=-1:O(n,function(n){return n===t})},j.invoke=function(n,t){var r=o.call(arguments,2),e=j.isFunction(t);return j.map(n,function(n){return(e?t:n[t]).apply(n,r)})},j.pluck=function(n,t){return j.map(n,function(n){return n[t]})},j.where=function(n,t,r){return j.isEmpty(t)?r?void 0:[]:j[r?"find":"filter"](n,function(n){for(var r in t)if(t[r]!==n[r])return!1;return!0})},j.findWhere=function(n,t){return j.where(n,t,!0)},j.max=function(n,t,r){if(!t&&j.isArray(n)&&n[0]===+n[0]&&n.length<65535)return Math.max.apply(Math,n);if(!t&&j.isEmpty(n))return-1/0;var e={computed:-1/0,value:-1/0};return A(n,function(n,u,i){var a=t?t.call(r,n,u,i):n;a>e.computed&&(e={value:n,computed:a})}),e.value},j.min=function(n,t,r){if(!t&&j.isArray(n)&&n[0]===+n[0]&&n.length<65535)return Math.min.apply(Math,n);if(!t&&j.isEmpty(n))return 1/0;var e={computed:1/0,value:1/0};return A(n,function(n,u,i){var a=t?t.call(r,n,u,i):n;a<e.computed&&(e={value:n,computed:a})}),e.value},j.shuffle=function(n){var t,r=0,e=[];return A(n,function(n){t=j.random(r++),e[r-1]=e[t],e[t]=n}),e};var F=function(n){return j.isFunction(n)?n:function(t){return t[n]}};j.sortBy=function(n,t,r){var e=F(t);return j.pluck(j.map(n,function(n,t,u){return{value:n,index:t,criteria:e.call(r,n,t,u)}}).sort(function(n,t){var r=n.criteria,e=t.criteria;if(r!==e){if(r>e||r===void 0)return 1;if(e>r||e===void 0)return-1}return n.index<t.index?-1:1}),"value")};var k=function(n,t,r,e){var u={},i=F(null==t?j.identity:t);return A(n,function(t,a){var o=i.call(r,t,a,n);e(u,o,t)}),u};j.groupBy=function(n,t,r){return k(n,t,r,function(n,t,r){(j.has(n,t)?n[t]:n[t]=[]).push(r)})},j.countBy=function(n,t,r){return k(n,t,r,function(n,t){j.has(n,t)||(n[t]=0),n[t]++})},j.sortedIndex=function(n,t,r,e){r=null==r?j.identity:F(r);for(var u=r.call(e,t),i=0,a=n.length;a>i;){var o=i+a>>>1;r.call(e,n[o])<u?i=o+1:a=o}return i},j.toArray=function(n){return n?j.isArray(n)?o.call(n):n.length===+n.length?j.map(n,j.identity):j.values(n):[]},j.size=function(n){return null==n?0:n.length===+n.length?n.length:j.keys(n).length},j.first=j.head=j.take=function(n,t,r){return null==n?void 0:null==t||r?n[0]:o.call(n,0,t)},j.initial=function(n,t,r){return o.call(n,0,n.length-(null==t||r?1:t))},j.last=function(n,t,r){return null==n?void 0:null==t||r?n[n.length-1]:o.call(n,Math.max(n.length-t,0))},j.rest=j.tail=j.drop=function(n,t,r){return o.call(n,null==t||r?1:t)},j.compact=function(n){return j.filter(n,j.identity)};var R=function(n,t,r){return t&&j.every(n,j.isArray)?c.apply(r,n):(A(n,function(n){j.isArray(n)||j.isArguments(n)?t?a.apply(r,n):R(n,t,r):r.push(n)}),r)};j.flatten=function(n,t){return R(n,t,[])},j.without=function(n){return j.difference(n,o.call(arguments,1))},j.uniq=j.unique=function(n,t,r,e){j.isFunction(t)&&(e=r,r=t,t=!1);var u=r?j.map(n,r,e):n,i=[],a=[];return A(u,function(r,e){(t?e&&a[a.length-1]===r:j.contains(a,r))||(a.push(r),i.push(n[e]))}),i},j.union=function(){return j.uniq(j.flatten(arguments,!0))},j.intersection=function(n){var t=o.call(arguments,1);return j.filter(j.uniq(n),function(n){return j.every(t,function(t){return j.indexOf(t,n)>=0})})},j.difference=function(n){var t=c.apply(e,o.call(arguments,1));return j.filter(n,function(n){return!j.contains(t,n)})},j.zip=function(){for(var n=j.max(j.pluck(arguments,"length").concat(0)),t=new Array(n),r=0;n>r;r++)t[r]=j.pluck(arguments,""+r);return t},j.object=function(n,t){if(null==n)return{};for(var r={},e=0,u=n.length;u>e;e++)t?r[n[e]]=t[e]:r[n[e][0]]=n[e][1];return r},j.indexOf=function(n,t,r){if(null==n)return-1;var e=0,u=n.length;if(r){if("number"!=typeof r)return e=j.sortedIndex(n,t),n[e]===t?e:-1;e=0>r?Math.max(0,u+r):r}if(y&&n.indexOf===y)return n.indexOf(t,r);for(;u>e;e++)if(n[e]===t)return e;return-1},j.lastIndexOf=function(n,t,r){if(null==n)return-1;var e=null!=r;if(b&&n.lastIndexOf===b)return e?n.lastIndexOf(t,r):n.lastIndexOf(t);for(var u=e?r:n.length;u--;)if(n[u]===t)return u;return-1},j.range=function(n,t,r){arguments.length<=1&&(t=n||0,n=0),r=arguments[2]||1;for(var e=Math.max(Math.ceil((t-n)/r),0),u=0,i=new Array(e);e>u;)i[u++]=n,n+=r;return i};var M=function(){};j.bind=function(n,t){var r,e;if(w&&n.bind===w)return w.apply(n,o.call(arguments,1));if(!j.isFunction(n))throw new TypeError;return r=o.call(arguments,2),e=function(){if(!(this instanceof e))return n.apply(t,r.concat(o.call(arguments)));M.prototype=n.prototype;var u=new M;M.prototype=null;var i=n.apply(u,r.concat(o.call(arguments)));return Object(i)===i?i:u}},j.partial=function(n){var t=o.call(arguments,1);return function(){return n.apply(this,t.concat(o.call(arguments)))}},j.bindAll=function(n){var t=o.call(arguments,1);if(0===t.length)throw new Error("bindAll must be passed function names");return A(t,function(t){n[t]=j.bind(n[t],n)}),n},j.memoize=function(n,t){var r={};return t||(t=j.identity),function(){var e=t.apply(this,arguments);return j.has(r,e)?r[e]:r[e]=n.apply(this,arguments)}},j.delay=function(n,t){var r=o.call(arguments,2);return setTimeout(function(){return n.apply(null,r)},t)},j.defer=function(n){return j.delay.apply(j,[n,1].concat(o.call(arguments,1)))},j.throttle=function(n,t,r){var e,u,i,a=null,o=0;r||(r={});var c=function(){o=r.leading===!1?0:new Date,a=null,i=n.apply(e,u)};return function(){var l=new Date;o||r.leading!==!1||(o=l);var f=t-(l-o);return e=this,u=arguments,0>=f?(clearTimeout(a),a=null,o=l,i=n.apply(e,u)):a||r.trailing===!1||(a=setTimeout(c,f)),i}},j.debounce=function(n,t,r){var e,u=null;return function(){var i=this,a=arguments,o=function(){u=null,r||(e=n.apply(i,a))},c=r&&!u;return clearTimeout(u),u=setTimeout(o,t),c&&(e=n.apply(i,a)),e}},j.once=function(n){var t,r=!1;return function(){return r?t:(r=!0,t=n.apply(this,arguments),n=null,t)}},j.wrap=function(n,t){return function(){var r=[n];return a.apply(r,arguments),t.apply(this,r)}},j.compose=function(){var n=arguments;return function(){for(var t=arguments,r=n.length-1;r>=0;r--)t=[n[r].apply(this,t)];return t[0]}},j.after=function(n,t){return function(){return--n<1?t.apply(this,arguments):void 0}},j.keys=_||function(n){if(n!==Object(n))throw new TypeError("Invalid object");var t=[];for(var r in n)j.has(n,r)&&t.push(r);return t},j.values=function(n){var t=[];for(var r in n)j.has(n,r)&&t.push(n[r]);return t},j.pairs=function(n){var t=[];for(var r in n)j.has(n,r)&&t.push([r,n[r]]);return t},j.invert=function(n){var t={};for(var r in n)j.has(n,r)&&(t[n[r]]=r);return t},j.functions=j.methods=function(n){var t=[];for(var r in n)j.isFunction(n[r])&&t.push(r);return t.sort()},j.extend=function(n){return A(o.call(arguments,1),function(t){if(t)for(var r in t)n[r]=t[r]}),n},j.pick=function(n){var t={},r=c.apply(e,o.call(arguments,1));return A(r,function(r){r in n&&(t[r]=n[r])}),t},j.omit=function(n){var t={},r=c.apply(e,o.call(arguments,1));for(var u in n)j.contains(r,u)||(t[u]=n[u]);return t},j.defaults=function(n){return A(o.call(arguments,1),function(t){if(t)for(var r in t)n[r]===void 0&&(n[r]=t[r])}),n},j.clone=function(n){return j.isObject(n)?j.isArray(n)?n.slice():j.extend({},n):n},j.tap=function(n,t){return t(n),n};var S=function(n,t,r,e){if(n===t)return 0!==n||1/n==1/t;if(null==n||null==t)return n===t;n instanceof j&&(n=n._wrapped),t instanceof j&&(t=t._wrapped);var u=l.call(n);if(u!=l.call(t))return!1;switch(u){case"[object String]":return n==String(t);case"[object Number]":return n!=+n?t!=+t:0==n?1/n==1/t:n==+t;case"[object Date]":case"[object Boolean]":return+n==+t;case"[object RegExp]":return n.source==t.source&&n.global==t.global&&n.multiline==t.multiline&&n.ignoreCase==t.ignoreCase}if("object"!=typeof n||"object"!=typeof t)return!1;for(var i=r.length;i--;)if(r[i]==n)return e[i]==t;var a=n.constructor,o=t.constructor;if(a!==o&&!(j.isFunction(a)&&a instanceof a&&j.isFunction(o)&&o instanceof o))return!1;r.push(n),e.push(t);var c=0,f=!0;if("[object Array]"==u){if(c=n.length,f=c==t.length)for(;c--&&(f=S(n[c],t[c],r,e)););}else{for(var s in n)if(j.has(n,s)&&(c++,!(f=j.has(t,s)&&S(n[s],t[s],r,e))))break;if(f){for(s in t)if(j.has(t,s)&&!c--)break;f=!c}}return r.pop(),e.pop(),f};j.isEqual=function(n,t){return S(n,t,[],[])},j.isEmpty=function(n){if(null==n)return!0;if(j.isArray(n)||j.isString(n))return 0===n.length;for(var t in n)if(j.has(n,t))return!1;return!0},j.isElement=function(n){return!(!n||1!==n.nodeType)},j.isArray=x||function(n){return"[object Array]"==l.call(n)},j.isObject=function(n){return n===Object(n)},A(["Arguments","Function","String","Number","Date","RegExp"],function(n){j["is"+n]=function(t){return l.call(t)=="[object "+n+"]"}}),j.isArguments(arguments)||(j.isArguments=function(n){return!(!n||!j.has(n,"callee"))}),"function"!=typeof/./&&(j.isFunction=function(n){return"function"==typeof n}),j.isFinite=function(n){return isFinite(n)&&!isNaN(parseFloat(n))},j.isNaN=function(n){return j.isNumber(n)&&n!=+n},j.isBoolean=function(n){return n===!0||n===!1||"[object Boolean]"==l.call(n)},j.isNull=function(n){return null===n},j.isUndefined=function(n){return n===void 0},j.has=function(n,t){return f.call(n,t)},j.noConflict=function(){return n._=t,this},j.identity=function(n){return n},j.times=function(n,t,r){for(var e=Array(Math.max(0,n)),u=0;n>u;u++)e[u]=t.call(r,u);return e},j.random=function(n,t){return null==t&&(t=n,n=0),n+Math.floor(Math.random()*(t-n+1))};var I={escape:{"&":"&amp;","<":"&lt;",">":"&gt;",'"':"&quot;","'":"&#x27;","/":"&#x2F;"}};I.unescape=j.invert(I.escape);var T={escape:new RegExp("["+j.keys(I.escape).join("")+"]","g"),unescape:new RegExp("("+j.keys(I.unescape).join("|")+")","g")};j.each(["escape","unescape"],function(n){j[n]=function(t){return null==t?"":(""+t).replace(T[n],function(t){return I[n][t]})}}),j.result=function(n,t){if(null==n)return void 0;var r=n[t];return j.isFunction(r)?r.call(n):r},j.mixin=function(n){A(j.functions(n),function(t){var r=j[t]=n[t];j.prototype[t]=function(){var n=[this._wrapped];return a.apply(n,arguments),z.call(this,r.apply(j,n))}})};var N=0;j.uniqueId=function(n){var t=++N+"";return n?n+t:t},j.templateSettings={evaluate:/<%([\s\S]+?)%>/g,interpolate:/<%=([\s\S]+?)%>/g,escape:/<%-([\s\S]+?)%>/g};var q=/(.)^/,B={"'":"'","\\":"\\","\r":"r","\n":"n","	":"t","\u2028":"u2028","\u2029":"u2029"},D=/\\|'|\r|\n|\t|\u2028|\u2029/g;j.template=function(n,t,r){var e;r=j.defaults({},r,j.templateSettings);var u=new RegExp([(r.escape||q).source,(r.interpolate||q).source,(r.evaluate||q).source].join("|")+"|$","g"),i=0,a="__p+='";n.replace(u,function(t,r,e,u,o){return a+=n.slice(i,o).replace(D,function(n){return"\\"+B[n]}),r&&(a+="'+\n((__t=("+r+"))==null?'':_.escape(__t))+\n'"),e&&(a+="'+\n((__t=("+e+"))==null?'':__t)+\n'"),u&&(a+="';\n"+u+"\n__p+='"),i=o+t.length,t}),a+="';\n",r.variable||(a="with(obj||{}){\n"+a+"}\n"),a="var __t,__p='',__j=Array.prototype.join,"+"print=function(){__p+=__j.call(arguments,'');};\n"+a+"return __p;\n";try{e=new Function(r.variable||"obj","_",a)}catch(o){throw o.source=a,o}if(t)return e(t,j);var c=function(n){return e.call(this,n,j)};return c.source="function("+(r.variable||"obj")+"){\n"+a+"}",c},j.chain=function(n){return j(n).chain()};var z=function(n){return this._chain?j(n).chain():n};j.mixin(j),A(["pop","push","reverse","shift","sort","splice","unshift"],function(n){var t=e[n];j.prototype[n]=function(){var r=this._wrapped;return t.apply(r,arguments),"shift"!=n&&"splice"!=n||0!==r.length||delete r[0],z.call(this,r)}}),A(["concat","join","slice"],function(n){var t=e[n];j.prototype[n]=function(){return z.call(this,t.apply(this._wrapped,arguments))}}),j.extend(j.prototype,{chain:function(){return this._chain=!0,this},value:function(){return this._wrapped}})}.call(this);
//# sourceMappingURL=underscore-min.map
// seedrandom.js version 2.2.
// Author: David Bau
// Date: 2013 Jun 15
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
// Version 2.2 alters non-crypto autoseeding to sweep up entropy from plugins.
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
//
// Autoseeding without crypto is somewhat slower, about 20-30 milliseconds on
// a 2012 windows 7 1.5ghz i5 laptop, as seen on Firefox 19, IE 10, and Opera.
// Seeded rng calls themselves are fast across these browsers, with slowest
// numbers on Opera at about 0.0005 ms per seeded Math.random().
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
      try { result.push(flatten(obj[prop], depth - 1)); } catch (e) {}
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
    return [+new Date, global, global.navigator.plugins,
            global.screen, tostring(pool)];
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

(function(exports){
(function(exports){
science = {version: "1.9.1"}; // semver
science.ascending = function(a, b) {
  return a - b;
};
// Euler's constant.
science.EULER = .5772156649015329;
// Compute exp(x) - 1 accurately for small x.
science.expm1 = function(x) {
  return (x < 1e-5 && x > -1e-5) ? x + .5 * x * x : Math.exp(x) - 1;
};
science.functor = function(v) {
  return typeof v === "function" ? v : function() { return v; };
};
// Based on:
// http://www.johndcook.com/blog/2010/06/02/whats-so-hard-about-finding-a-hypotenuse/
science.hypot = function(x, y) {
  x = Math.abs(x);
  y = Math.abs(y);
  var max,
      min;
  if (x > y) { max = x; min = y; }
  else       { max = y; min = x; }
  var r = min / max;
  return max * Math.sqrt(1 + r * r);
};
science.quadratic = function() {
  var complex = false;

  function quadratic(a, b, c) {
    var d = b * b - 4 * a * c;
    if (d > 0) {
      d = Math.sqrt(d) / (2 * a);
      return complex
        ? [{r: -b - d, i: 0}, {r: -b + d, i: 0}]
        : [-b - d, -b + d];
    } else if (d === 0) {
      d = -b / (2 * a);
      return complex ? [{r: d, i: 0}] : [d];
    } else {
      if (complex) {
        d = Math.sqrt(-d) / (2 * a);
        return [
          {r: -b, i: -d},
          {r: -b, i: d}
        ];
      }
      return [];
    }
  }

  quadratic.complex = function(x) {
    if (!arguments.length) return complex;
    complex = x;
    return quadratic;
  };

  return quadratic;
};
// Constructs a multi-dimensional array filled with zeroes.
science.zeroes = function(n) {
  var i = -1,
      a = [];
  if (arguments.length === 1)
    while (++i < n)
      a[i] = 0;
  else
    while (++i < n)
      a[i] = science.zeroes.apply(
        this, Array.prototype.slice.call(arguments, 1));
  return a;
};
})(this);
(function(exports){
science.lin = {};
science.lin.decompose = function() {

  function decompose(A) {
    var n = A.length, // column dimension
        V = [],
        d = [],
        e = [];

    for (var i = 0; i < n; i++) {
      V[i] = [];
      d[i] = [];
      e[i] = [];
    }

    var symmetric = true;
    for (var j = 0; j < n; j++) {
      for (var i = 0; i < n; i++) {
        if (A[i][j] !== A[j][i]) {
          symmetric = false;
          break;
        }
      }
    }

    if (symmetric) {
      for (var i = 0; i < n; i++) V[i] = A[i].slice();

      // Tridiagonalize.
      science_lin_decomposeTred2(d, e, V);

      // Diagonalize.
      science_lin_decomposeTql2(d, e, V);
    } else {
      var H = [];
      for (var i = 0; i < n; i++) H[i] = A[i].slice();

      // Reduce to Hessenberg form.
      science_lin_decomposeOrthes(H, V);

      // Reduce Hessenberg to real Schur form.
      science_lin_decomposeHqr2(d, e, H, V);
    }

    var D = [];
    for (var i = 0; i < n; i++) {
      var row = D[i] = [];
      for (var j = 0; j < n; j++) row[j] = i === j ? d[i] : 0;
      D[i][e[i] > 0 ? i + 1 : i - 1] = e[i];
    }
    return {D: D, V: V};
  }

  return decompose;
};

// Symmetric Householder reduction to tridiagonal form.
function science_lin_decomposeTred2(d, e, V) {
  // This is derived from the Algol procedures tred2 by
  // Bowdler, Martin, Reinsch, and Wilkinson, Handbook for
  // Auto. Comp., Vol.ii-Linear Algebra, and the corresponding
  // Fortran subroutine in EISPACK.

  var n = V.length;

  for (var j = 0; j < n; j++) d[j] = V[n - 1][j];

  // Householder reduction to tridiagonal form.
  for (var i = n - 1; i > 0; i--) {
    // Scale to avoid under/overflow.

    var scale = 0,
        h = 0;
    for (var k = 0; k < i; k++) scale += Math.abs(d[k]);
    if (scale === 0) {
      e[i] = d[i - 1];
      for (var j = 0; j < i; j++) {
        d[j] = V[i - 1][j];
        V[i][j] = 0;
        V[j][i] = 0;
      }
    } else {
      // Generate Householder vector.
      for (var k = 0; k < i; k++) {
        d[k] /= scale;
        h += d[k] * d[k];
      }
      var f = d[i - 1];
      var g = Math.sqrt(h);
      if (f > 0) g = -g;
      e[i] = scale * g;
      h = h - f * g;
      d[i - 1] = f - g;
      for (var j = 0; j < i; j++) e[j] = 0;

      // Apply similarity transformation to remaining columns.

      for (var j = 0; j < i; j++) {
        f = d[j];
        V[j][i] = f;
        g = e[j] + V[j][j] * f;
        for (var k = j+1; k <= i - 1; k++) {
          g += V[k][j] * d[k];
          e[k] += V[k][j] * f;
        }
        e[j] = g;
      }
      f = 0;
      for (var j = 0; j < i; j++) {
        e[j] /= h;
        f += e[j] * d[j];
      }
      var hh = f / (h + h);
      for (var j = 0; j < i; j++) e[j] -= hh * d[j];
      for (var j = 0; j < i; j++) {
        f = d[j];
        g = e[j];
        for (var k = j; k <= i - 1; k++) V[k][j] -= (f * e[k] + g * d[k]);
        d[j] = V[i - 1][j];
        V[i][j] = 0;
      }
    }
    d[i] = h;
  }

  // Accumulate transformations.
  for (var i = 0; i < n - 1; i++) {
    V[n - 1][i] = V[i][i];
    V[i][i] = 1.0;
    var h = d[i + 1];
    if (h != 0) {
      for (var k = 0; k <= i; k++) d[k] = V[k][i + 1] / h;
      for (var j = 0; j <= i; j++) {
        var g = 0;
        for (var k = 0; k <= i; k++) g += V[k][i + 1] * V[k][j];
        for (var k = 0; k <= i; k++) V[k][j] -= g * d[k];
      }
    }
    for (var k = 0; k <= i; k++) V[k][i + 1] = 0;
  }
  for (var j = 0; j < n; j++) {
    d[j] = V[n - 1][j];
    V[n - 1][j] = 0;
  }
  V[n - 1][n - 1] = 1;
  e[0] = 0;
}

// Symmetric tridiagonal QL algorithm.
function science_lin_decomposeTql2(d, e, V) {
  // This is derived from the Algol procedures tql2, by
  // Bowdler, Martin, Reinsch, and Wilkinson, Handbook for
  // Auto. Comp., Vol.ii-Linear Algebra, and the corresponding
  // Fortran subroutine in EISPACK.

  var n = V.length;

  for (var i = 1; i < n; i++) e[i - 1] = e[i];
  e[n - 1] = 0;

  var f = 0;
  var tst1 = 0;
  var eps = 1e-12;
  for (var l = 0; l < n; l++) {
    // Find small subdiagonal element
    tst1 = Math.max(tst1, Math.abs(d[l]) + Math.abs(e[l]));
    var m = l;
    while (m < n) {
      if (Math.abs(e[m]) <= eps*tst1) { break; }
      m++;
    }

    // If m == l, d[l] is an eigenvalue,
    // otherwise, iterate.
    if (m > l) {
      var iter = 0;
      do {
        iter++;  // (Could check iteration count here.)

        // Compute implicit shift
        var g = d[l];
        var p = (d[l + 1] - g) / (2 * e[l]);
        var r = science.hypot(p, 1);
        if (p < 0) r = -r;
        d[l] = e[l] / (p + r);
        d[l + 1] = e[l] * (p + r);
        var dl1 = d[l + 1];
        var h = g - d[l];
        for (var i = l+2; i < n; i++) d[i] -= h;
        f += h;

        // Implicit QL transformation.
        p = d[m];
        var c = 1;
        var c2 = c;
        var c3 = c;
        var el1 = e[l + 1];
        var s = 0;
        var s2 = 0;
        for (var i = m - 1; i >= l; i--) {
          c3 = c2;
          c2 = c;
          s2 = s;
          g = c * e[i];
          h = c * p;
          r = science.hypot(p,e[i]);
          e[i + 1] = s * r;
          s = e[i] / r;
          c = p / r;
          p = c * d[i] - s * g;
          d[i + 1] = h + s * (c * g + s * d[i]);

          // Accumulate transformation.
          for (var k = 0; k < n; k++) {
            h = V[k][i + 1];
            V[k][i + 1] = s * V[k][i] + c * h;
            V[k][i] = c * V[k][i] - s * h;
          }
        }
        p = -s * s2 * c3 * el1 * e[l] / dl1;
        e[l] = s * p;
        d[l] = c * p;

        // Check for convergence.
      } while (Math.abs(e[l]) > eps*tst1);
    }
    d[l] = d[l] + f;
    e[l] = 0;
  }

  // Sort eigenvalues and corresponding vectors.
  for (var i = 0; i < n - 1; i++) {
    var k = i;
    var p = d[i];
    for (var j = i + 1; j < n; j++) {
      if (d[j] < p) {
        k = j;
        p = d[j];
      }
    }
    if (k != i) {
      d[k] = d[i];
      d[i] = p;
      for (var j = 0; j < n; j++) {
        p = V[j][i];
        V[j][i] = V[j][k];
        V[j][k] = p;
      }
    }
  }
}

// Nonsymmetric reduction to Hessenberg form.
function science_lin_decomposeOrthes(H, V) {
  // This is derived from the Algol procedures orthes and ortran,
  // by Martin and Wilkinson, Handbook for Auto. Comp.,
  // Vol.ii-Linear Algebra, and the corresponding
  // Fortran subroutines in EISPACK.

  var n = H.length;
  var ort = [];

  var low = 0;
  var high = n - 1;

  for (var m = low + 1; m < high; m++) {
    // Scale column.
    var scale = 0;
    for (var i = m; i <= high; i++) scale += Math.abs(H[i][m - 1]);

    if (scale !== 0) {
      // Compute Householder transformation.
      var h = 0;
      for (var i = high; i >= m; i--) {
        ort[i] = H[i][m - 1] / scale;
        h += ort[i] * ort[i];
      }
      var g = Math.sqrt(h);
      if (ort[m] > 0) g = -g;
      h = h - ort[m] * g;
      ort[m] = ort[m] - g;

      // Apply Householder similarity transformation
      // H = (I-u*u'/h)*H*(I-u*u')/h)
      for (var j = m; j < n; j++) {
        var f = 0;
        for (var i = high; i >= m; i--) f += ort[i] * H[i][j];
        f /= h;
        for (var i = m; i <= high; i++) H[i][j] -= f * ort[i];
      }

      for (var i = 0; i <= high; i++) {
        var f = 0;
        for (var j = high; j >= m; j--) f += ort[j] * H[i][j];
        f /= h;
        for (var j = m; j <= high; j++) H[i][j] -= f * ort[j];
      }
      ort[m] = scale * ort[m];
      H[m][m - 1] = scale * g;
    }
  }

  // Accumulate transformations (Algol's ortran).
  for (var i = 0; i < n; i++) {
    for (var j = 0; j < n; j++) V[i][j] = i === j ? 1 : 0;
  }

  for (var m = high-1; m >= low+1; m--) {
    if (H[m][m - 1] !== 0) {
      for (var i = m + 1; i <= high; i++) ort[i] = H[i][m - 1];
      for (var j = m; j <= high; j++) {
        var g = 0;
        for (var i = m; i <= high; i++) g += ort[i] * V[i][j];
        // Double division avoids possible underflow
        g = (g / ort[m]) / H[m][m - 1];
        for (var i = m; i <= high; i++) V[i][j] += g * ort[i];
      }
    }
  }
}

// Nonsymmetric reduction from Hessenberg to real Schur form.
function science_lin_decomposeHqr2(d, e, H, V) {
  // This is derived from the Algol procedure hqr2,
  // by Martin and Wilkinson, Handbook for Auto. Comp.,
  // Vol.ii-Linear Algebra, and the corresponding
  // Fortran subroutine in EISPACK.

  var nn = H.length,
      n = nn - 1,
      low = 0,
      high = nn - 1,
      eps = 1e-12,
      exshift = 0,
      p = 0,
      q = 0,
      r = 0,
      s = 0,
      z = 0,
      t,
      w,
      x,
      y;

  // Store roots isolated by balanc and compute matrix norm
  var norm = 0;
  for (var i = 0; i < nn; i++) {
    if (i < low || i > high) {
      d[i] = H[i][i];
      e[i] = 0;
    }
    for (var j = Math.max(i - 1, 0); j < nn; j++) norm += Math.abs(H[i][j]);
  }

  // Outer loop over eigenvalue index
  var iter = 0;
  while (n >= low) {
    // Look for single small sub-diagonal element
    var l = n;
    while (l > low) {
      s = Math.abs(H[l - 1][l - 1]) + Math.abs(H[l][l]);
      if (s === 0) s = norm;
      if (Math.abs(H[l][l - 1]) < eps * s) break;
      l--;
    }

    // Check for convergence
    // One root found
    if (l === n) {
      H[n][n] = H[n][n] + exshift;
      d[n] = H[n][n];
      e[n] = 0;
      n--;
      iter = 0;

    // Two roots found
    } else if (l === n - 1) {
      w = H[n][n - 1] * H[n - 1][n];
      p = (H[n - 1][n - 1] - H[n][n]) / 2;
      q = p * p + w;
      z = Math.sqrt(Math.abs(q));
      H[n][n] = H[n][n] + exshift;
      H[n - 1][n - 1] = H[n - 1][n - 1] + exshift;
      x = H[n][n];

      // Real pair
      if (q >= 0) {
        z = p + (p >= 0 ? z : -z);
        d[n - 1] = x + z;
        d[n] = d[n - 1];
        if (z !== 0) d[n] = x - w / z;
        e[n - 1] = 0;
        e[n] = 0;
        x = H[n][n - 1];
        s = Math.abs(x) + Math.abs(z);
        p = x / s;
        q = z / s;
        r = Math.sqrt(p * p+q * q);
        p /= r;
        q /= r;

        // Row modification
        for (var j = n - 1; j < nn; j++) {
          z = H[n - 1][j];
          H[n - 1][j] = q * z + p * H[n][j];
          H[n][j] = q * H[n][j] - p * z;
        }

        // Column modification
        for (var i = 0; i <= n; i++) {
          z = H[i][n - 1];
          H[i][n - 1] = q * z + p * H[i][n];
          H[i][n] = q * H[i][n] - p * z;
        }

        // Accumulate transformations
        for (var i = low; i <= high; i++) {
          z = V[i][n - 1];
          V[i][n - 1] = q * z + p * V[i][n];
          V[i][n] = q * V[i][n] - p * z;
        }

        // Complex pair
      } else {
        d[n - 1] = x + p;
        d[n] = x + p;
        e[n - 1] = z;
        e[n] = -z;
      }
      n = n - 2;
      iter = 0;

      // No convergence yet
    } else {

      // Form shift
      x = H[n][n];
      y = 0;
      w = 0;
      if (l < n) {
        y = H[n - 1][n - 1];
        w = H[n][n - 1] * H[n - 1][n];
      }

      // Wilkinson's original ad hoc shift
      if (iter == 10) {
        exshift += x;
        for (var i = low; i <= n; i++) {
          H[i][i] -= x;
        }
        s = Math.abs(H[n][n - 1]) + Math.abs(H[n - 1][n-2]);
        x = y = 0.75 * s;
        w = -0.4375 * s * s;
      }

      // MATLAB's new ad hoc shift
      if (iter == 30) {
        s = (y - x) / 2.0;
        s = s * s + w;
        if (s > 0) {
          s = Math.sqrt(s);
          if (y < x) {
            s = -s;
          }
          s = x - w / ((y - x) / 2.0 + s);
          for (var i = low; i <= n; i++) {
            H[i][i] -= s;
          }
          exshift += s;
          x = y = w = 0.964;
        }
      }

      iter++;   // (Could check iteration count here.)

      // Look for two consecutive small sub-diagonal elements
      var m = n-2;
      while (m >= l) {
        z = H[m][m];
        r = x - z;
        s = y - z;
        p = (r * s - w) / H[m + 1][m] + H[m][m + 1];
        q = H[m + 1][m + 1] - z - r - s;
        r = H[m+2][m + 1];
        s = Math.abs(p) + Math.abs(q) + Math.abs(r);
        p = p / s;
        q = q / s;
        r = r / s;
        if (m == l) break;
        if (Math.abs(H[m][m - 1]) * (Math.abs(q) + Math.abs(r)) <
          eps * (Math.abs(p) * (Math.abs(H[m - 1][m - 1]) + Math.abs(z) +
          Math.abs(H[m + 1][m + 1])))) {
            break;
        }
        m--;
      }

      for (var i = m+2; i <= n; i++) {
        H[i][i-2] = 0;
        if (i > m+2) H[i][i-3] = 0;
      }

      // Double QR step involving rows l:n and columns m:n
      for (var k = m; k <= n - 1; k++) {
        var notlast = (k != n - 1);
        if (k != m) {
          p = H[k][k - 1];
          q = H[k + 1][k - 1];
          r = (notlast ? H[k + 2][k - 1] : 0);
          x = Math.abs(p) + Math.abs(q) + Math.abs(r);
          if (x != 0) {
            p /= x;
            q /= x;
            r /= x;
          }
        }
        if (x == 0) break;
        s = Math.sqrt(p * p + q * q + r * r);
        if (p < 0) { s = -s; }
        if (s != 0) {
          if (k != m) H[k][k - 1] = -s * x;
          else if (l != m) H[k][k - 1] = -H[k][k - 1];
          p += s;
          x = p / s;
          y = q / s;
          z = r / s;
          q /= p;
          r /= p;

          // Row modification
          for (var j = k; j < nn; j++) {
            p = H[k][j] + q * H[k + 1][j];
            if (notlast) {
              p = p + r * H[k + 2][j];
              H[k + 2][j] = H[k + 2][j] - p * z;
            }
            H[k][j] = H[k][j] - p * x;
            H[k + 1][j] = H[k + 1][j] - p * y;
          }

          // Column modification
          for (var i = 0; i <= Math.min(n, k + 3); i++) {
            p = x * H[i][k] + y * H[i][k + 1];
            if (notlast) {
              p += z * H[i][k + 2];
              H[i][k + 2] = H[i][k + 2] - p * r;
            }
            H[i][k] = H[i][k] - p;
            H[i][k + 1] = H[i][k + 1] - p * q;
          }

          // Accumulate transformations
          for (var i = low; i <= high; i++) {
            p = x * V[i][k] + y * V[i][k + 1];
            if (notlast) {
              p = p + z * V[i][k + 2];
              V[i][k + 2] = V[i][k + 2] - p * r;
            }
            V[i][k] = V[i][k] - p;
            V[i][k + 1] = V[i][k + 1] - p * q;
          }
        }  // (s != 0)
      }  // k loop
    }  // check convergence
  }  // while (n >= low)

  // Backsubstitute to find vectors of upper triangular form
  if (norm == 0) { return; }

  for (n = nn - 1; n >= 0; n--) {
    p = d[n];
    q = e[n];

    // Real vector
    if (q == 0) {
      var l = n;
      H[n][n] = 1.0;
      for (var i = n - 1; i >= 0; i--) {
        w = H[i][i] - p;
        r = 0;
        for (var j = l; j <= n; j++) { r = r + H[i][j] * H[j][n]; }
        if (e[i] < 0) {
          z = w;
          s = r;
        } else {
          l = i;
          if (e[i] === 0) {
            H[i][n] = -r / (w !== 0 ? w : eps * norm);
          } else {
            // Solve real equations
            x = H[i][i + 1];
            y = H[i + 1][i];
            q = (d[i] - p) * (d[i] - p) + e[i] * e[i];
            t = (x * s - z * r) / q;
            H[i][n] = t;
            if (Math.abs(x) > Math.abs(z)) {
              H[i + 1][n] = (-r - w * t) / x;
            } else {
              H[i + 1][n] = (-s - y * t) / z;
            }
          }

          // Overflow control
          t = Math.abs(H[i][n]);
          if ((eps * t) * t > 1) {
            for (var j = i; j <= n; j++) H[j][n] = H[j][n] / t;
          }
        }
      }
    // Complex vector
    } else if (q < 0) {
      var l = n - 1;

      // Last vector component imaginary so matrix is triangular
      if (Math.abs(H[n][n - 1]) > Math.abs(H[n - 1][n])) {
        H[n - 1][n - 1] = q / H[n][n - 1];
        H[n - 1][n] = -(H[n][n] - p) / H[n][n - 1];
      } else {
        var zz = science_lin_decomposeCdiv(0, -H[n - 1][n], H[n - 1][n - 1] - p, q);
        H[n - 1][n - 1] = zz[0];
        H[n - 1][n] = zz[1];
      }
      H[n][n - 1] = 0;
      H[n][n] = 1;
      for (var i = n-2; i >= 0; i--) {
        var ra = 0,
            sa = 0,
            vr,
            vi;
        for (var j = l; j <= n; j++) {
          ra = ra + H[i][j] * H[j][n - 1];
          sa = sa + H[i][j] * H[j][n];
        }
        w = H[i][i] - p;

        if (e[i] < 0) {
          z = w;
          r = ra;
          s = sa;
        } else {
          l = i;
          if (e[i] == 0) {
            var zz = science_lin_decomposeCdiv(-ra,-sa,w,q);
            H[i][n - 1] = zz[0];
            H[i][n] = zz[1];
          } else {
            // Solve complex equations
            x = H[i][i + 1];
            y = H[i + 1][i];
            vr = (d[i] - p) * (d[i] - p) + e[i] * e[i] - q * q;
            vi = (d[i] - p) * 2.0 * q;
            if (vr == 0 & vi == 0) {
              vr = eps * norm * (Math.abs(w) + Math.abs(q) +
                Math.abs(x) + Math.abs(y) + Math.abs(z));
            }
            var zz = science_lin_decomposeCdiv(x*r-z*ra+q*sa,x*s-z*sa-q*ra,vr,vi);
            H[i][n - 1] = zz[0];
            H[i][n] = zz[1];
            if (Math.abs(x) > (Math.abs(z) + Math.abs(q))) {
              H[i + 1][n - 1] = (-ra - w * H[i][n - 1] + q * H[i][n]) / x;
              H[i + 1][n] = (-sa - w * H[i][n] - q * H[i][n - 1]) / x;
            } else {
              var zz = science_lin_decomposeCdiv(-r-y*H[i][n - 1],-s-y*H[i][n],z,q);
              H[i + 1][n - 1] = zz[0];
              H[i + 1][n] = zz[1];
            }
          }

          // Overflow control
          t = Math.max(Math.abs(H[i][n - 1]),Math.abs(H[i][n]));
          if ((eps * t) * t > 1) {
            for (var j = i; j <= n; j++) {
              H[j][n - 1] = H[j][n - 1] / t;
              H[j][n] = H[j][n] / t;
            }
          }
        }
      }
    }
  }

  // Vectors of isolated roots
  for (var i = 0; i < nn; i++) {
    if (i < low || i > high) {
      for (var j = i; j < nn; j++) V[i][j] = H[i][j];
    }
  }

  // Back transformation to get eigenvectors of original matrix
  for (var j = nn - 1; j >= low; j--) {
    for (var i = low; i <= high; i++) {
      z = 0;
      for (var k = low; k <= Math.min(j, high); k++) z += V[i][k] * H[k][j];
      V[i][j] = z;
    }
  }
}

// Complex scalar division.
function science_lin_decomposeCdiv(xr, xi, yr, yi) {
  if (Math.abs(yr) > Math.abs(yi)) {
    var r = yi / yr,
        d = yr + r * yi;
    return [(xr + r * xi) / d, (xi - r * xr) / d];
  } else {
    var r = yr / yi,
        d = yi + r * yr;
    return [(r * xr + xi) / d, (r * xi - xr) / d];
  }
}
science.lin.cross = function(a, b) {
  // TODO how to handle non-3D vectors?
  // TODO handle 7D vectors?
  return [
    a[1] * b[2] - a[2] * b[1],
    a[2] * b[0] - a[0] * b[2],
    a[0] * b[1] - a[1] * b[0]
  ];
};
science.lin.dot = function(a, b) {
  var s = 0,
      i = -1,
      n = Math.min(a.length, b.length);
  while (++i < n) s += a[i] * b[i];
  return s;
};
science.lin.length = function(p) {
  return Math.sqrt(science.lin.dot(p, p));
};
science.lin.normalize = function(p) {
  var length = science.lin.length(p);
  return p.map(function(d) { return d / length; });
};
// 4x4 matrix determinant.
science.lin.determinant = function(matrix) {
  var m = matrix[0].concat(matrix[1]).concat(matrix[2]).concat(matrix[3]);
  return (
    m[12] * m[9]  * m[6]  * m[3]  - m[8] * m[13] * m[6]  * m[3]  -
    m[12] * m[5]  * m[10] * m[3]  + m[4] * m[13] * m[10] * m[3]  +
    m[8]  * m[5]  * m[14] * m[3]  - m[4] * m[9]  * m[14] * m[3]  -
    m[12] * m[9]  * m[2]  * m[7]  + m[8] * m[13] * m[2]  * m[7]  +
    m[12] * m[1]  * m[10] * m[7]  - m[0] * m[13] * m[10] * m[7]  -
    m[8]  * m[1]  * m[14] * m[7]  + m[0] * m[9]  * m[14] * m[7]  +
    m[12] * m[5]  * m[2]  * m[11] - m[4] * m[13] * m[2]  * m[11] -
    m[12] * m[1]  * m[6]  * m[11] + m[0] * m[13] * m[6]  * m[11] +
    m[4]  * m[1]  * m[14] * m[11] - m[0] * m[5]  * m[14] * m[11] -
    m[8]  * m[5]  * m[2]  * m[15] + m[4] * m[9]  * m[2]  * m[15] +
    m[8]  * m[1]  * m[6]  * m[15] - m[0] * m[9]  * m[6]  * m[15] -
    m[4]  * m[1]  * m[10] * m[15] + m[0] * m[5]  * m[10] * m[15]);
};
// Performs in-place Gauss-Jordan elimination.
//
// Based on Jarno Elonen's Python version (public domain):
// http://elonen.iki.fi/code/misc-notes/python-gaussj/index.html
science.lin.gaussjordan = function(m, eps) {
  if (!eps) eps = 1e-10;

  var h = m.length,
      w = m[0].length,
      y = -1,
      y2,
      x;

  while (++y < h) {
    var maxrow = y;

    // Find max pivot.
    y2 = y; while (++y2 < h) {
      if (Math.abs(m[y2][y]) > Math.abs(m[maxrow][y]))
        maxrow = y2;
    }

    // Swap.
    var tmp = m[y];
    m[y] = m[maxrow];
    m[maxrow] = tmp;

    // Singular?
    if (Math.abs(m[y][y]) <= eps) return false;

    // Eliminate column y.
    y2 = y; while (++y2 < h) {
      var c = m[y2][y] / m[y][y];
      x = y - 1; while (++x < w) {
        m[y2][x] -= m[y][x] * c;
      }
    }
  }

  // Backsubstitute.
  y = h; while (--y >= 0) {
    var c = m[y][y];
    y2 = -1; while (++y2 < y) {
      x = w; while (--x >= y) {
        m[y2][x] -=  m[y][x] * m[y2][y] / c;
      }
    }
    m[y][y] /= c;
    // Normalize row y.
    x = h - 1; while (++x < w) {
      m[y][x] /= c;
    }
  }
  return true;
};
// Find matrix inverse using Gauss-Jordan.
science.lin.inverse = function(m) {
  var n = m.length,
      i = -1;

  // Check if the matrix is square.
  if (n !== m[0].length) return;

  // Augment with identity matrix I to get AI.
  m = m.map(function(row, i) {
    var identity = new Array(n),
        j = -1;
    while (++j < n) identity[j] = i === j ? 1 : 0;
    return row.concat(identity);
  });

  // Compute IA^-1.
  science.lin.gaussjordan(m);

  // Remove identity matrix I to get A^-1.
  while (++i < n) {
    m[i] = m[i].slice(n);
  }

  return m;
};
science.lin.multiply = function(a, b) {
  var m = a.length,
      n = b[0].length,
      p = b.length,
      i = -1,
      j,
      k;
  if (p !== a[0].length) throw {"error": "columns(a) != rows(b); " + a[0].length + " != " + p};
  var ab = new Array(m);
  while (++i < m) {
    ab[i] = new Array(n);
    j = -1; while(++j < n) {
      var s = 0;
      k = -1; while (++k < p) s += a[i][k] * b[k][j];
      ab[i][j] = s;
    }
  }
  return ab;
};
science.lin.transpose = function(a) {
  var m = a.length,
      n = a[0].length,
      i = -1,
      j,
      b = new Array(n);
  while (++i < n) {
    b[i] = new Array(m);
    j = -1; while (++j < m) b[i][j] = a[j][i];
  }
  return b;
};
/**
 * Solves tridiagonal systems of linear equations.
 *
 * Source: http://en.wikipedia.org/wiki/Tridiagonal_matrix_algorithm
 *
 * @param {number[]} a
 * @param {number[]} b
 * @param {number[]} c
 * @param {number[]} d
 * @param {number[]} x
 * @param {number} n
 */
science.lin.tridag = function(a, b, c, d, x, n) {
  var i,
      m;
  for (i = 1; i < n; i++) {
    m = a[i] / b[i - 1];
    b[i] -= m * c[i - 1];
    d[i] -= m * d[i - 1];
  }
  x[n - 1] = d[n - 1] / b[n - 1];
  for (i = n - 2; i >= 0; i--) {
    x[i] = (d[i] - c[i] * x[i + 1]) / b[i];
  }
};
})(this);
(function(exports){
science.stats = {};
// Bandwidth selectors for Gaussian kernels.
// Based on R's implementations in `stats.bw`.
science.stats.bandwidth = {

  // Silverman, B. W. (1986) Density Estimation. London: Chapman and Hall.
  nrd0: function(x) {
    var hi = Math.sqrt(science.stats.variance(x));
    if (!(lo = Math.min(hi, science.stats.iqr(x) / 1.34)))
      (lo = hi) || (lo = Math.abs(x[1])) || (lo = 1);
    return .9 * lo * Math.pow(x.length, -.2);
  },

  // Scott, D. W. (1992) Multivariate Density Estimation: Theory, Practice, and
  // Visualization. Wiley.
  nrd: function(x) {
    var h = science.stats.iqr(x) / 1.34;
    return 1.06 * Math.min(Math.sqrt(science.stats.variance(x)), h)
      * Math.pow(x.length, -1/5);
  }
};
science.stats.distance = {
  euclidean: function(a, b) {
    var n = a.length,
        i = -1,
        s = 0,
        x;
    while (++i < n) {
      x = a[i] - b[i];
      s += x * x;
    }
    return Math.sqrt(s);
  },
  manhattan: function(a, b) {
    var n = a.length,
        i = -1,
        s = 0;
    while (++i < n) s += Math.abs(a[i] - b[i]);
    return s;
  },
  minkowski: function(p) {
    return function(a, b) {
      var n = a.length,
          i = -1,
          s = 0;
      while (++i < n) s += Math.pow(Math.abs(a[i] - b[i]), p);
      return Math.pow(s, 1 / p);
    };
  },
  chebyshev: function(a, b) {
    var n = a.length,
        i = -1,
        max = 0,
        x;
    while (++i < n) {
      x = Math.abs(a[i] - b[i]);
      if (x > max) max = x;
    }
    return max;
  },
  hamming: function(a, b) {
    var n = a.length,
        i = -1,
        d = 0;
    while (++i < n) if (a[i] !== b[i]) d++;
    return d;
  },
  jaccard: function(a, b) {
    var n = a.length,
        i = -1,
        s = 0;
    while (++i < n) if (a[i] === b[i]) s++;
    return s / n;
  },
  braycurtis: function(a, b) {
    var n = a.length,
        i = -1,
        s0 = 0,
        s1 = 0,
        ai,
        bi;
    while (++i < n) {
      ai = a[i];
      bi = b[i];
      s0 += Math.abs(ai - bi);
      s1 += Math.abs(ai + bi);
    }
    return s0 / s1;
  }
};
// Based on implementation in http://picomath.org/.
science.stats.erf = function(x) {
  var a1 =  0.254829592,
      a2 = -0.284496736,
      a3 =  1.421413741,
      a4 = -1.453152027,
      a5 =  1.061405429,
      p  =  0.3275911;

  // Save the sign of x
  var sign = x < 0 ? -1 : 1;
  if (x < 0) {
    sign = -1;
    x = -x;
  }

  // A&S formula 7.1.26
  var t = 1 / (1 + p * x);
  return sign * (
    1 - (((((a5 * t + a4) * t) + a3) * t + a2) * t + a1)
    * t * Math.exp(-x * x));
};
science.stats.phi = function(x) {
  return .5 * (1 + science.stats.erf(x / Math.SQRT2));
};
// See <http://en.wikipedia.org/wiki/Kernel_(statistics)>.
science.stats.kernel = {
  uniform: function(u) {
    if (u <= 1 && u >= -1) return .5;
    return 0;
  },
  triangular: function(u) {
    if (u <= 1 && u >= -1) return 1 - Math.abs(u);
    return 0;
  },
  epanechnikov: function(u) {
    if (u <= 1 && u >= -1) return .75 * (1 - u * u);
    return 0;
  },
  quartic: function(u) {
    if (u <= 1 && u >= -1) {
      var tmp = 1 - u * u;
      return (15 / 16) * tmp * tmp;
    }
    return 0;
  },
  triweight: function(u) {
    if (u <= 1 && u >= -1) {
      var tmp = 1 - u * u;
      return (35 / 32) * tmp * tmp * tmp;
    }
    return 0;
  },
  gaussian: function(u) {
    return 1 / Math.sqrt(2 * Math.PI) * Math.exp(-.5 * u * u);
  },
  cosine: function(u) {
    if (u <= 1 && u >= -1) return Math.PI / 4 * Math.cos(Math.PI / 2 * u);
    return 0;
  }
};
// http://exploringdata.net/den_trac.htm
science.stats.kde = function() {
  var kernel = science.stats.kernel.gaussian,
      sample = [],
      bandwidth = science.stats.bandwidth.nrd;

  function kde(points, i) {
    var bw = bandwidth.call(this, sample);
    return points.map(function(x) {
      var i = -1,
          y = 0,
          n = sample.length;
      while (++i < n) {
        y += kernel((x - sample[i]) / bw);
      }
      return [x, y / bw / n];
    });
  }

  kde.kernel = function(x) {
    if (!arguments.length) return kernel;
    kernel = x;
    return kde;
  };

  kde.sample = function(x) {
    if (!arguments.length) return sample;
    sample = x;
    return kde;
  };

  kde.bandwidth = function(x) {
    if (!arguments.length) return bandwidth;
    bandwidth = science.functor(x);
    return kde;
  };

  return kde;
};
// Based on figue implementation by Jean-Yves Delort.
// http://code.google.com/p/figue/
science.stats.kmeans = function() {
  var distance = science.stats.distance.euclidean,
      maxIterations = 1000,
      k = 1;

  function kmeans(vectors) {
    var n = vectors.length,
        assignments = [],
        clusterSizes = [],
        repeat = 1,
        iterations = 0,
        centroids = science_stats_kmeansRandom(k, vectors),
        newCentroids,
        i,
        j,
        x,
        d,
        min,
        best;

    while (repeat && iterations < maxIterations) {
      // Assignment step.
      j = -1; while (++j < k) {
        clusterSizes[j] = 0;
      }

      i = -1; while (++i < n) {
        x = vectors[i];
        min = Infinity;
        j = -1; while (++j < k) {
          d = distance.call(this, centroids[j], x);
          if (d < min) {
            min = d;
            best = j;
          }
        }
        clusterSizes[assignments[i] = best]++;
      }

      // Update centroids step.
      newCentroids = [];
      i = -1; while (++i < n) {
        x = assignments[i];
        d = newCentroids[x];
        if (d == null) newCentroids[x] = vectors[i].slice();
        else {
          j = -1; while (++j < d.length) {
            d[j] += vectors[i][j];
          }
        }
      }
      j = -1; while (++j < k) {
        x = newCentroids[j];
        d = 1 / clusterSizes[j];
        i = -1; while (++i < x.length) x[i] *= d;
      }

      // Check convergence.
      repeat = 0;
      j = -1; while (++j < k) {
        if (!science_stats_kmeansCompare(newCentroids[j], centroids[j])) {
          repeat = 1;
          break;
        }
      }
      centroids = newCentroids;
      iterations++;
    }
    return {assignments: assignments, centroids: centroids};
  }

  kmeans.k = function(x) {
    if (!arguments.length) return k;
    k = x;
    return kmeans;
  };

  kmeans.distance = function(x) {
    if (!arguments.length) return distance;
    distance = x;
    return kmeans;
  };

  return kmeans;
};

function science_stats_kmeansCompare(a, b) {
  if (!a || !b || a.length !== b.length) return false;
  var n = a.length,
      i = -1;
  while (++i < n) if (a[i] !== b[i]) return false;
  return true;
}

// Returns an array of k distinct vectors randomly selected from the input
// array of vectors. Returns null if k > n or if there are less than k distinct
// objects in vectors.
function science_stats_kmeansRandom(k, vectors) {
  var n = vectors.length;
  if (k > n) return null;
  
  var selected_vectors = [];
  var selected_indices = [];
  var tested_indices = {};
  var tested = 0;
  var selected = 0;
  var i,
      vector,
      select;

  while (selected < k) {
    if (tested === n) return null;
    
    var random_index = Math.floor(Math.random() * n);
    if (random_index in tested_indices) continue;
    
    tested_indices[random_index] = 1;
    tested++;
    vector = vectors[random_index];
    select = true;
    for (i = 0; i < selected; i++) {
      if (science_stats_kmeansCompare(vector, selected_vectors[i])) {
        select = false;
        break;
      }
    }
    if (select) {
      selected_vectors[selected] = vector;
      selected_indices[selected] = random_index;
      selected++;
    }
  }
  return selected_vectors;
}
science.stats.hcluster = function() {
  var distance = science.stats.distance.euclidean,
      linkage = "simple"; // simple, complete or average

  function hcluster(vectors) {
    var n = vectors.length,
        dMin = [],
        cSize = [],
        distMatrix = [],
        clusters = [],
        c1,
        c2,
        c1Cluster,
        c2Cluster,
        p,
        root,
        i,
        j;

    // Initialise distance matrix and vector of closest clusters.
    i = -1; while (++i < n) {
      dMin[i] = 0;
      distMatrix[i] = [];
      j = -1; while (++j < n) {
        distMatrix[i][j] = i === j ? Infinity : distance(vectors[i] , vectors[j]);
        if (distMatrix[i][dMin[i]] > distMatrix[i][j]) dMin[i] = j;
      }
    }

    // create leaves of the tree
    i = -1; while (++i < n) {
      clusters[i] = [];
      clusters[i][0] = {
        left: null,
        right: null,
        dist: 0,
        centroid: vectors[i],
        size: 1,
        depth: 0
      };
      cSize[i] = 1;
    }

    // Main loop
    for (p = 0; p < n-1; p++) {
      // find the closest pair of clusters
      c1 = 0;
      for (i = 0; i < n; i++) {
        if (distMatrix[i][dMin[i]] < distMatrix[c1][dMin[c1]]) c1 = i;
      }
      c2 = dMin[c1];

      // create node to store cluster info 
      c1Cluster = clusters[c1][0];
      c2Cluster = clusters[c2][0];

      var newCluster = {
        left: c1Cluster,
        right: c2Cluster,
        dist: distMatrix[c1][c2],
        centroid: calculateCentroid(c1Cluster.size, c1Cluster.centroid,
          c2Cluster.size, c2Cluster.centroid),
        size: c1Cluster.size + c2Cluster.size,
        depth: 1 + Math.max(c1Cluster.depth, c2Cluster.depth)
      };
      clusters[c1].splice(0, 0, newCluster);
      cSize[c1] += cSize[c2];

      // overwrite row c1 with respect to the linkage type
      for (j = 0; j < n; j++) {
        switch (linkage) {
          case "single":
            if (distMatrix[c1][j] > distMatrix[c2][j])
              distMatrix[j][c1] = distMatrix[c1][j] = distMatrix[c2][j];
            break;
          case "complete":
            if (distMatrix[c1][j] < distMatrix[c2][j])
              distMatrix[j][c1] = distMatrix[c1][j] = distMatrix[c2][j];
            break;
          case "average":
            distMatrix[j][c1] = distMatrix[c1][j] = (cSize[c1] * distMatrix[c1][j] + cSize[c2] * distMatrix[c2][j]) / (cSize[c1] + cSize[j]);
            break;
        }
      }
      distMatrix[c1][c1] = Infinity;

      // infinity ­out old row c2 and column c2
      for (i = 0; i < n; i++)
        distMatrix[i][c2] = distMatrix[c2][i] = Infinity;

      // update dmin and replace ones that previous pointed to c2 to point to c1
      for (j = 0; j < n; j++) {
        if (dMin[j] == c2) dMin[j] = c1;
        if (distMatrix[c1][j] < distMatrix[c1][dMin[c1]]) dMin[c1] = j;
      }

      // keep track of the last added cluster
      root = newCluster;
    }

    return root;
  }

  hcluster.distance = function(x) {
    if (!arguments.length) return distance;
    distance = x;
    return hcluster;
  };

  return hcluster;
};

function calculateCentroid(c1Size, c1Centroid, c2Size, c2Centroid) {
  var newCentroid = [],
      newSize = c1Size + c2Size,
      n = c1Centroid.length,
      i = -1;
  while (++i < n) {
    newCentroid[i] = (c1Size * c1Centroid[i] + c2Size * c2Centroid[i]) / newSize;
  }
  return newCentroid;
}
science.stats.iqr = function(x) {
  var quartiles = science.stats.quantiles(x, [.25, .75]);
  return quartiles[1] - quartiles[0];
};
// Based on org.apache.commons.math.analysis.interpolation.LoessInterpolator
// from http://commons.apache.org/math/
science.stats.loess = function() {    
  var bandwidth = .3,
      robustnessIters = 2,
      accuracy = 1e-12;

  function smooth(xval, yval, weights) {
    var n = xval.length,
        i;

    if (n !== yval.length) throw {error: "Mismatched array lengths"};
    if (n == 0) throw {error: "At least one point required."};

    if (arguments.length < 3) {
      weights = [];
      i = -1; while (++i < n) weights[i] = 1;
    }

    science_stats_loessFiniteReal(xval);
    science_stats_loessFiniteReal(yval);
    science_stats_loessFiniteReal(weights);
    science_stats_loessStrictlyIncreasing(xval);

    if (n == 1) return [yval[0]];
    if (n == 2) return [yval[0], yval[1]];

    var bandwidthInPoints = Math.floor(bandwidth * n);

    if (bandwidthInPoints < 2) throw {error: "Bandwidth too small."};

    var res = [],
        residuals = [],
        robustnessWeights = [];

    // Do an initial fit and 'robustnessIters' robustness iterations.
    // This is equivalent to doing 'robustnessIters+1' robustness iterations
    // starting with all robustness weights set to 1.
    i = -1; while (++i < n) {
      res[i] = 0;
      residuals[i] = 0;
      robustnessWeights[i] = 1;
    }

    var iter = -1;
    while (++iter <= robustnessIters) {
      var bandwidthInterval = [0, bandwidthInPoints - 1];
      // At each x, compute a local weighted linear regression
      var x;
      i = -1; while (++i < n) {
        x = xval[i];

        // Find out the interval of source points on which
        // a regression is to be made.
        if (i > 0) {
          science_stats_loessUpdateBandwidthInterval(xval, weights, i, bandwidthInterval);
        }

        var ileft = bandwidthInterval[0],
            iright = bandwidthInterval[1];

        // Compute the point of the bandwidth interval that is
        // farthest from x
        var edge = (xval[i] - xval[ileft]) > (xval[iright] - xval[i]) ? ileft : iright;

        // Compute a least-squares linear fit weighted by
        // the product of robustness weights and the tricube
        // weight function.
        // See http://en.wikipedia.org/wiki/Linear_regression
        // (section "Univariate linear case")
        // and http://en.wikipedia.org/wiki/Weighted_least_squares
        // (section "Weighted least squares")
        var sumWeights = 0,
            sumX = 0,
            sumXSquared = 0,
            sumY = 0,
            sumXY = 0,
            denom = Math.abs(1 / (xval[edge] - x));

        for (var k = ileft; k <= iright; ++k) {
          var xk   = xval[k],
              yk   = yval[k],
              dist = k < i ? x - xk : xk - x,
              w    = science_stats_loessTricube(dist * denom) * robustnessWeights[k] * weights[k],
              xkw  = xk * w;
          sumWeights += w;
          sumX += xkw;
          sumXSquared += xk * xkw;
          sumY += yk * w;
          sumXY += yk * xkw;
        }

        var meanX = sumX / sumWeights,
            meanY = sumY / sumWeights,
            meanXY = sumXY / sumWeights,
            meanXSquared = sumXSquared / sumWeights;

        var beta = (Math.sqrt(Math.abs(meanXSquared - meanX * meanX)) < accuracy)
            ? 0 : ((meanXY - meanX * meanY) / (meanXSquared - meanX * meanX));

        var alpha = meanY - beta * meanX;

        res[i] = beta * x + alpha;
        residuals[i] = Math.abs(yval[i] - res[i]);
      }

      // No need to recompute the robustness weights at the last
      // iteration, they won't be needed anymore
      if (iter === robustnessIters) {
        break;
      }

      // Recompute the robustness weights.

      // Find the median residual.
      var sortedResiduals = residuals.slice();
      sortedResiduals.sort();
      var medianResidual = sortedResiduals[Math.floor(n / 2)];

      if (Math.abs(medianResidual) < accuracy)
        break;

      var arg,
          w;
      i = -1; while (++i < n) {
        arg = residuals[i] / (6 * medianResidual);
        robustnessWeights[i] = (arg >= 1) ? 0 : ((w = 1 - arg * arg) * w);
      }
    }

    return res;
  }

  smooth.bandwidth = function(x) {
    if (!arguments.length) return x;
    bandwidth = x;
    return smooth;
  };

  smooth.robustnessIterations = function(x) {
    if (!arguments.length) return x;
    robustnessIters = x;
    return smooth;
  };

  smooth.accuracy = function(x) {
    if (!arguments.length) return x;
    accuracy = x;
    return smooth;
  };

  return smooth;
};

function science_stats_loessFiniteReal(values) {
  var n = values.length,
      i = -1;

  while (++i < n) if (!isFinite(values[i])) return false;

  return true;
}

function science_stats_loessStrictlyIncreasing(xval) {
  var n = xval.length,
      i = 0;

  while (++i < n) if (xval[i - 1] >= xval[i]) return false;

  return true;
}

// Compute the tricube weight function.
// http://en.wikipedia.org/wiki/Local_regression#Weight_function
function science_stats_loessTricube(x) {
  return (x = 1 - x * x * x) * x * x;
}

// Given an index interval into xval that embraces a certain number of
// points closest to xval[i-1], update the interval so that it embraces
// the same number of points closest to xval[i], ignoring zero weights.
function science_stats_loessUpdateBandwidthInterval(
  xval, weights, i, bandwidthInterval) {

  var left = bandwidthInterval[0],
      right = bandwidthInterval[1];

  // The right edge should be adjusted if the next point to the right
  // is closer to xval[i] than the leftmost point of the current interval
  var nextRight = science_stats_loessNextNonzero(weights, right);
  if ((nextRight < xval.length) && (xval[nextRight] - xval[i]) < (xval[i] - xval[left])) {
    var nextLeft = science_stats_loessNextNonzero(weights, left);
    bandwidthInterval[0] = nextLeft;
    bandwidthInterval[1] = nextRight;
  }
}

function science_stats_loessNextNonzero(weights, i) {
  var j = i + 1;
  while (j < weights.length && weights[j] === 0) j++;
  return j;
}
// Welford's algorithm.
science.stats.mean = function(x) {
  var n = x.length;
  if (n === 0) return NaN;
  var m = 0,
      i = -1;
  while (++i < n) m += (x[i] - m) / (i + 1);
  return m;
};
science.stats.median = function(x) {
  return science.stats.quantiles(x, [.5])[0];
};
science.stats.mode = function(x) {
  var counts = {},
      mode = [],
      max = 0,
      n = x.length,
      i = -1,
      d,
      k;
  while (++i < n) {
    k = counts.hasOwnProperty(d = x[i]) ? ++counts[d] : counts[d] = 1;
    if (k === max) mode.push(d);
    else if (k > max) {
      max = k;
      mode = [d];
    }
  }
  if (mode.length === 1) return mode[0];
};
// Uses R's quantile algorithm type=7.
science.stats.quantiles = function(d, quantiles) {
  d = d.slice().sort(science.ascending);
  var n_1 = d.length - 1;
  return quantiles.map(function(q) {
    if (q === 0) return d[0];
    else if (q === 1) return d[n_1];

    var index = 1 + q * n_1,
        lo = Math.floor(index),
        h = index - lo,
        a = d[lo - 1];

    return h === 0 ? a : a + h * (d[lo] - a);
  });
};
// Unbiased estimate of a sample's variance.
// Also known as the sample variance, where the denominator is n - 1.
science.stats.variance = function(x) {
  var n = x.length;
  if (n < 1) return NaN;
  if (n === 1) return 0;
  var mean = science.stats.mean(x),
      i = -1,
      s = 0;
  while (++i < n) {
    var v = x[i] - mean;
    s += v * v;
  }
  return s / (n - 1);
};
science.stats.distribution = {
};
// From http://www.colingodsey.com/javascript-gaussian-random-number-generator/
// Uses the Box-Muller Transform.
science.stats.distribution.gaussian = function() {
  var random = Math.random,
      mean = 0,
      sigma = 1,
      variance = 1;

  function gaussian() {
    var x1,
        x2,
        rad,
        y1;

    do {
      x1 = 2 * random() - 1;
      x2 = 2 * random() - 1;
      rad = x1 * x1 + x2 * x2;
    } while (rad >= 1 || rad === 0);

    return mean + sigma * x1 * Math.sqrt(-2 * Math.log(rad) / rad);
  }

  gaussian.pdf = function(x) {
    x = (x - mean) / sigma;
    return science_stats_distribution_gaussianConstant * Math.exp(-.5 * x * x) / sigma;
  };

  gaussian.cdf = function(x) {
    x = (x - mean) / sigma;
    return .5 * (1 + science.stats.erf(x / Math.SQRT2));
  };

  gaussian.mean = function(x) {
    if (!arguments.length) return mean;
    mean = +x;
    return gaussian;
  };

  gaussian.variance = function(x) {
    if (!arguments.length) return variance;
    sigma = Math.sqrt(variance = +x);
    return gaussian;
  };

  gaussian.random = function(x) {
    if (!arguments.length) return random;
    random = x;
    return gaussian;
  };

  return gaussian;
};

science_stats_distribution_gaussianConstant = 1 / Math.sqrt(2 * Math.PI);
})(this);
})(this);

var gg = window.gg = {'coord':{},'core':{},'facet':{'base':{},'grid':{},'pane':{}},'geom':{'reparam':{},'svg':{}},'layer':{},'parse':{},'pos':{},'scale':{'train':{}},'stat':{},'util':{},'wf':{'rpc':{},'rule':{}},'xform':{}};

(function() {
  var async, data, events, exports, fromSpec, ggutil, io, pg, science, timer, _,
    __slice = [].slice,
    __indexOf = [].indexOf || function(item) { for (var i = 0, l = this.length; i < l; i++) { if (i in this && this[i] === item) return i; } return -1; },
    __hasProp = {}.hasOwnProperty,
    __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

  gg.util.Json = (function() {

    function Json() {}

    Json.toJSON = function(o, reject, path) {
      var ret;
      if (reject == null) {
        reject = (function() {
          return false;
        });
      }
      if (path == null) {
        path = [];
      }
      if (path.length >= 25) {
        console.log(o);
        throw Error("Max stack " + path + " hit");
      }
      if (!_.isFunction(reject)) {
        reject = function() {
          return false;
        };
      }
      if (reject(o)) {
        return {
          type: "rejected"
        };
      }
      if ((o != null) && 'ggpackage' in o.constructor) {
        ret = {
          type: 'gg',
          ggpackage: o.constructor.ggpackage
        };
        ret.val = o.toJSON();
      } else if (_.isFunction(o)) {
        ret = {
          type: "function",
          val: null,
          props: {}
        };
        ret.val = o.toString();
        _.each(_.keys(o), function(k) {
          path.push(k);
          ret.props[k] = gg.util.Json.toJSON(o[k], reject, path);
          return path.pop();
        });
      } else if (_.isArray(o)) {
        ret = {
          type: "array",
          val: [],
          props: {}
        };
        _.each(o, function(v, idx) {
          path.push(idx);
          ret.val.push(gg.util.Json.toJSON(v, reject, path));
          return path.pop();
        });
        _.each(_.reject(_.keys(o), _.isNumber), function(k) {
          path.push(k);
          ret.props[k] = gg.util.Json.toJSON(o[k], reject, path);
          return path.pop();
        });
      } else if (_.isDate(o)) {
        ret = {
          type: "date",
          val: JSON.stringify(o)
        };
      } else if (_.isObject(o)) {
        ret = {
          type: "object",
          val: {}
        };
        _.each(o, function(v, k) {
          path.push(k);
          ret.val[k] = gg.util.Json.toJSON(v, reject, path);
          return path.pop();
        });
      } else {
        if (_.isUndefined(o)) {
          o = null;
        }
        ret = {
          type: 'primitive',
          val: JSON.stringify(o)
        };
      }
      return ret;
    };

    Json.fromJSON = function(json) {
      var klass, ret, type;
      type = json.type;
      switch (json.type) {
        case 'gg':
          klass = _.ggklass(json.ggpackage);
          return klass.fromJSON(json.val);
        case 'array':
          ret = [];
          _.each(json.val, function(v) {
            return ret.push(gg.util.Json.fromJSON(v));
          });
          _.each(json.props, function(vjson, k) {
            return ret[k] = gg.util.Json.fromJSON(vjson);
          });
          return ret;
        case 'date':
          return ret = new Date(JSON.parse(json.val));
        case 'object':
          ret = {};
          _.each(json.val, function(v, k) {
            return ret[k] = gg.util.Json.fromJSON(v);
          });
          return ret;
        case 'function':
          try {
            ret = Function("return (" + json.val + ")")();
          } catch (err) {
            throw Error(json.val);
          }
          _.each(json.props, function(vjson, k) {
            return ret[k] = gg.util.Json.fromJSON(vjson);
          });
          return ret;
        case 'rejected':
          return null;
        case 'primitive':
          return JSON.parse(json.val);
        default:
          throw Error("unexpected json object: " + json);
      }
    };

    return Json;

  })();

  ggutil = require('ggutil');

  _ = require('underscore');

  gg.util.Util = (function() {

    function Util() {}

    Util.ggklass = function(ggpackage) {
      var cmd;
      cmd = "return ('gg' in window)? window." + ggpackage + " : " + ggpackage;
      return Function(cmd)();
    };

    return Util;

  })();

  _.mixin({
    ggklass: gg.util.Util.ggklass,
    toJSON: gg.util.Json.toJSON,
    fromJson: gg.util.Json.fromJSON
  });

  _.extend(gg.util, _.omit(ggutil, 'Util'));

  _.extend(gg.util.Util, ggutil.Util);

  gg.scale.Scale = (function() {

    Scale.ggpackage = 'gg.scale.Scale';

    Scale.log = gg.util.Log.logger(Scale.ggpackage, "scale");

    Scale.aliases = "scale";

    Scale.id = function() {
      return gg.scale.Scale.prototype._id += 1;
    };

    Scale.prototype._id = 0;

    Scale.xs = ['x', 'x0', 'x1'];

    Scale.ys = ['y', 'y0', 'y1', 'q1', 'median', 'q3', 'lower', 'upper', 'min', 'max'];

    Scale.xys = _.union(Scale.xs, Scale.ys);

    Scale.legendAess = ['size', 'group', 'color', 'fill', 'fill-opacity'];

    function Scale(spec) {
      var attrs, domain;
      this.spec = spec != null ? spec : {};
      this.aes = this.spec.aes;
      if (this.aes == null) {
        throw Error("Scale.fromSpec needs an aesthetic: " + (JSON.stringify(this.spec)));
      }
      this.rangeSet = false;
      this.domainSet = false;
      if (this.spec.range != null) {
        this.range(this.spec.range);
        this.rangeSet = true;
      }
      attrs = ['domain', 'limit', 'limits', 'lims', 'lim'];
      domain = gg.parse.Parser.attr(this.spec, attrs, null);
      if (domain != null) {
        this.domain(domain);
        this.domainSet = true;
      }
      this.domainUpdated = this.spec.domainUpdated || false;
      this.rangeUpdated = this.spec.rangeUpdated || false;
      this.center = this.spec.center;
      this.frozen = this.spec.frozen || false;
      this.log = gg.util.Log.logger(this.ggpackage, "Scale " + this.aes + "." + this.id + " (" + this.type + "," + this.constructor.name + ")");
      this.id = gg.scale.Scale.id();
    }

    Scale.klasses = function() {
      var alias, klass, klasses, ret, _i, _j, _len, _len1, _ref;
      klasses = [gg.scale.Identity, gg.scale.Linear, gg.scale.Time, gg.scale.Log, gg.scale.Ordinal, gg.scale.Color, gg.scale.Shape, gg.scale.ColorCont];
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
      var klass, klasses;
      if (spec == null) {
        spec = {};
      }
      klasses = gg.scale.Scale.klasses();
      klass = klasses[spec.type] || gg.scale.Linear;
      return new klass(spec);
    };

    Scale.defaultFor = function(aes, type) {
      var klass;
      klass = {
        x: gg.scale.Linear,
        x0: gg.scale.Linear,
        x1: gg.scale.Linear,
        y: gg.scale.Linear,
        y0: gg.scale.Linear,
        y1: gg.scale.Linear,
        color: gg.scale.Color,
        fill: gg.scale.Color,
        stroke: gg.scale.Color,
        "fill-opacity": gg.scale.Linear,
        "opacity": gg.scale.Linear,
        "stroke-opacity": gg.scale.Linear,
        size: gg.scale.Linear,
        text: gg.scale.Text,
        shape: gg.scale.Shape
      }[aes] || gg.scale.Identity;
      if (type != null) {
        if (klass === gg.scale.Color) {
          if (type !== data.Schema.ordinal) {
            klass = gg.scale.ColorCont;
          }
        } else if (klass === gg.scale.Linear) {
          if (type === data.Schema.ordinal) {
            klass = gg.scale.Ordinal;
          } else if (type === data.Schema.date) {
            klass = gg.scale.Time;
          }
        }
      }
      this.log("Scale: defaultFor(" + aes + ", " + type + ") -> " + klass.name);
      return new klass({
        aes: aes,
        type: type
      });
    };

    Scale.prototype.clone = function() {
      return gg.scale.Scale.fromJSON(this.toJSON());
    };

    Scale.prototype.toJSON = function() {
      var spec;
      spec = _.clone(this.spec);
      spec.aes = this.aes;
      spec.type = this.type;
      spec.domainUpdated = this.domainUpdated;
      spec.domainSet = this.domainSet;
      spec.rangeUpdated = this.rangeUpdated;
      spec.rangeSet = this.rangeSet;
      spec.center = this.center;
      spec.frozen = this.frozen;
      spec.ggpackage = this.constructor.ggpackage;
      spec.domain = _.clone(this.domain());
      spec.range = _.clone(this.range());
      return spec;
    };

    Scale.fromJSON = function(json) {
      var clone, klass;
      klass = _.ggklass(json.ggpackage);
      clone = new klass(json);
      if (clone.d3Scale != null) {
        clone.d3Scale.domain(json.domain);
        clone.d3Scale.range(json.range);
      } else {
        clone.domain(json.domain);
        clone.range(json.range);
      }
      clone.type = json.type;
      clone.domainUpdated = json.domainUpdated;
      clone.domainSet = json.domainSet;
      clone.rangeUpdated = json.rangeUpdated;
      clone.rangeSet = json.rangeSet;
      clone.center = json.center;
      clone.frozen = json.frozen;
      return clone;
    };

    Scale.prototype.defaultDomain = function(col) {
      var extreme, interval;
      this.min = _.mmin(col);
      this.max = _.mmax(col);
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
          if (_.isNaN(domain[0]) || _.isNaN(domain[1])) {
            throw Error("domain is invalid: " + domain);
          }
          return this.domain([Math.min(md[0], domain[0]), Math.max(md[1], domain[1])]);
        } else {
          return this.domain(domain);
        }
      }
    };

    Scale.prototype.domain = function(interval) {
      if (interval != null) {
        if (!this.domainSet) {
          this.domainUpdated = true;
          this.d3Scale.domain(interval);
        }
      }
      return this.d3Scale.domain();
    };

    Scale.prototype.range = function(interval) {
      if (interval != null) {
        if (!this.rangeSet) {
          this.rangeUpdated = true;
          this.d3Scale.range(interval);
        }
      }
      return this.d3Scale.range();
    };

    Scale.prototype.d3 = function() {
      return this.d3Scale;
    };

    Scale.prototype.valid = function(v) {
      if (this.domainUpdated || this.domainSet) {
        return this.minDomain() <= v && v <= this.maxDomain();
      } else {
        return v != null;
      }
    };

    Scale.prototype.minDomain = function() {
      return this.domain()[0];
    };

    Scale.prototype.maxDomain = function() {
      return this.domain()[1];
    };

    Scale.prototype.resetDomain = function() {
      this.domain([0, 1]);
      return this.domainUpdated = false;
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

    Scale.prototype.toString = function() {
      return "" + this.aes + "." + this.id + " (" + this.type + "," + this.constructor.name + "): \t" + (this.domain()) + " -> " + (this.range());
    };

    return Scale;

  })();

  gg.scale.Factory = (function() {

    Factory.ggpackage = 'gg.scale.Factory';

    function Factory(defaults) {
      this.defaults = defaults != null ? defaults : {};
    }

    Factory.fromSpec = function(defaults) {
      var sf;
      sf = new gg.scale.Factory(defaults);
      return sf;
    };

    Factory.prototype.type = function(aes) {
      if (aes in this.defaults) {
        return this.defaults[aes].type;
      } else {
        return data.Schema.unknown;
      }
    };

    Factory.prototype.scale = function(aes, type) {
      var scale;
      if (aes == null) {
        throw Error("Factory.scale(): aes was null");
      }
      if (type == null) {
        throw Error("Factery.scale(" + aes + "): type was null");
      }
      scale = aes in this.defaults ? this.defaults[aes].clone() : gg.scale.Scale.defaultFor(aes, type);
      if (_.isType(scale, gg.scale.Identity)) {
        scale.type = type;
      }
      return scale;
    };

    Factory.prototype.scales = function(layerIdx) {
      return new gg.scale.Set(this);
    };

    Factory.prototype.toString = function() {
      var arr;
      arr = _.map(this.defaults, function(scale, aes) {
        return "\t" + aes + " -> " + (scale.toString());
      });
      return arr.join("\n");
    };

    Factory.prototype.toJSON = function() {
      var json;
      json = {};
      _.each(this.defaults, function(scale, aes) {
        return json[aes] = scale.toJSON();
      });
      return json;
    };

    Factory.fromJSON = function(json) {
      var defaults;
      defaults = {};
      _.each(json, function(scaleJSON, aes) {
        return defaults[aes] = gg.scale.Scale.fromJSON(scaleJSON);
      });
      return new gg.scale.Factory(defaults);
    };

    return Factory;

  })();

  gg.util.Bound = (function() {

    Bound.ggpackage = 'gg.util.Bound';

    function Bound(x0, y0, x1, y1) {
      this.x0 = x0;
      this.y0 = y0;
      this.x1 = x1 != null ? x1 : null;
      this.y1 = y1 != null ? y1 : null;
      if (this.x0 == null) {
        this.x1 = this.x0;
      }
      if (this.y0 == null) {
        this.y1 = this.y0;
      }
    }

    Bound.empty = function() {
      return new gg.util.Bound(0, 0);
    };

    Bound.prototype.width = function() {
      return this.x1 - this.x0;
    };

    Bound.prototype.height = function() {
      return this.y1 - this.y0;
    };

    Bound.prototype.volume = function() {
      return this.w() * this.h();
    };

    Bound.prototype.w = function() {
      return this.width();
    };

    Bound.prototype.h = function() {
      return this.height();
    };

    Bound.prototype.v = function() {
      return this.volume();
    };

    Bound.prototype.clone = function() {
      return new gg.util.Bound(this.x0, this.y0, this.x1, this.y1);
    };

    Bound.prototype.clear = function() {
      this.x0 = Number.MAX_VALUE;
      this.y0 = Number.MAX_VALUE;
      this.x1 = -Number.MAX_VALUE;
      return this.y1 = -Number.MAX_VALUE;
    };

    Bound.prototype.add = function(x, y) {
      if (x < this.x0) {
        this.x0 = x;
      }
      if (x > this.x1) {
        this.x1 = x;
      }
      if (y < this.y0) {
        this.y0 = y;
      }
      if (y > this.y1) {
        return this.y1 = y;
      }
    };

    Bound.prototype.merge = function(b) {
      this.add(b.x0, b.y0);
      return this.add(b.x1, b.y1);
    };

    Bound.prototype.expand = function(dx, dy) {
      if (dy == null) {
        dy = null;
      }
      if (dy == null) {
        dy = dx;
      }
      this.x0 -= dx;
      this.y0 -= dy;
      this.x1 += dx;
      return this.y1 += dy;
    };

    Bound.prototype.shrink = function(dx, dy) {
      if (dy == null) {
        dy = null;
      }
      if (dy == null) {
        dy = dx;
      }
      return this.expand(-dx, -dy);
    };

    Bound.prototype.d = function(dx, dy) {
      if (dy == null) {
        dy = null;
      }
      if (dy == null) {
        dy = dx;
      }
      this.x0 += dx;
      this.x1 += dx;
      this.y0 += dy;
      return this.y1 += dy;
    };

    Bound.prototype.encloses = function(b) {
      return (b != null) && (this.x0 <= b.x0 && this.y0 <= b.y0 && this.x1 >= b.x1 && this.y1 >= b.y1);
    };

    Bound.prototype.intersects = function(b) {
      return (b != null) && !(this.x1 < b.x0 || this.x0 > b.x1 || this.y1 < b.y0 || this.y0 > b.y1);
    };

    Bound.prototype.contains = function(x, y) {
      return !(x < this.x0 || x > this.x1 || y < this.y0 || y > this.y1);
    };

    Bound.fromJSON = function(spec) {
      return new gg.util.Bound(spec.x0, spec.y0, spec.x1, spec.y1);
    };

    Bound.prototype.toJSON = function() {
      return {
        x0: this.x0,
        y0: this.y0,
        x1: this.x1,
        y1: this.y1
      };
    };

    Bound.prototype.toString = function() {
      return "d: " + this.x0 + ", " + this.y0 + ".  " + (this.w()) + "x" + (this.h());
    };

    return Bound;

  })();

  gg.util.Params = (function() {

    Params.ggpackage = 'gg.util.Params';

    function Params(data) {
      this.id = gg.util.Params.id();
      this.data = {};
      this.merge(data);
    }

    Params.id = function() {
      return gg.util.Params.prototype._id += 1;
    };

    Params.prototype._id = 0;

    Params.prototype.merge = function(data) {
      var _this = this;
      if (data == null) {
        data = {};
      }
      if (_.isSubclass(data, gg.util.Params)) {
        data = data.data;
      }
      _.each(data, function(v, k) {
        return _this.data[k] = v;
      });
      return this;
    };

    Params.prototype.put = function(key, val) {
      this.data[key] = val;
      return this;
    };

    Params.prototype.putAll = function(o) {
      var _this = this;
      _.each(o, function(v, k) {
        return _this.data[k] = v;
      });
      return this;
    };

    Params.prototype.ensure = function(key, altkeys, defaultVal) {
      var alt, _i, _len;
      if (defaultVal == null) {
        defaultVal = null;
      }
      if (key in this.data) {
        return this;
      }
      if (altkeys != null) {
        for (_i = 0, _len = altkeys.length; _i < _len; _i++) {
          alt = altkeys[_i];
          if (alt in this.data) {
            this.put(key, this.get(alt));
            return;
          }
        }
      }
      this.put(key, defaultVal);
      return this;
    };

    Params.prototype.require = function(key, errmsg) {
      if (!this.has(key)) {
        throw Error(errmsg);
      }
    };

    Params.prototype.ensureAll = function(o) {
      var _this = this;
      _.each(o, function(v, k) {
        if (_.isArray(v[0]) && v.length === 1) {
          v = [v[0], null];
        } else if (_.isString(v[0])) {
          v = [v, null];
        }
        return _this.ensure(k, v[0], v[1]);
      });
      return this;
    };

    Params.prototype.has = function(key) {
      return this.contains(key);
    };

    Params.prototype.contains = function(key) {
      return key in this.data;
    };

    Params.prototype.get = function() {
      var args, key, v;
      key = arguments[0], args = 2 <= arguments.length ? __slice.call(arguments, 1) : [];
      if (!(key in this.data)) {
        return null;
      }
      v = this.data[key];
      if (_.isFunction(v)) {
        if (args.length > 0) {
          return v.apply(null, args);
        }
      }
      return v;
    };

    Params.prototype.rm = function(key) {
      var val;
      val = this.data[key] || null;
      delete this.data[key];
      return val;
    };

    Params.prototype.clone = function() {
      var clone, json, removedEls,
        _this = this;
      removedEls = {
        svg: this.rm('svg'),
        event: this.rm('event'),
        pairs: _.clone(this.rm('pairs'))
      };
      _.each(_.keys(this.data), function(key) {
        if (_.isFunction(_this.data[key])) {
          return removedEls[key] = _this.rm(key);
        }
      });
      json = this.toJSON();
      clone = gg.util.Params.fromJSON(json);
      this.merge(removedEls);
      clone.merge(removedEls);
      return clone;
    };

    Params.prototype.toString = function() {
      return _.map(this.data, function(v, k) {
        return "" + k + " -> " + (JSON.stringify(v));
      }).join("\n");
    };

    Params.prototype.toJSON = function(reject) {
      return _.toJSON(this.data, reject);
    };

    Params.fromJSON = function(json) {
      var data;
      data = _.fromJSON(json);
      return new gg.util.Params(data);
    };

    return Params;

  })();

  gg.util.Aesmap = (function() {

    function Aesmap() {}

    Aesmap.log = gg.util.Log.logger("gg.util.Aesmap", "Aesmap");

    Aesmap.reEvalJS = /^{.*}$/;

    Aesmap.reVariable = /^[a-zA-Z]\w*$/;

    Aesmap.reNestedAttr = /^[a-zA-Z]+\.[a-zA-Z]+$/;

    Aesmap.isEvalJS = function(s) {
      return this.reEvalJS.test(s);
    };

    Aesmap.isVariable = function(s) {
      return this.reVariable.test(s);
    };

    Aesmap.isNestedAttr = function(s) {
      return this.reNestedAttr.test(s);
    };

    Aesmap.mappingToFunctions = function(table, mapping) {
      var key, newkey, ret, val, _i, _len, _ref;
      ret = [];
      for (key in mapping) {
        val = mapping[key];
        _ref = gg.core.Aes.resolve(key);
        for (_i = 0, _len = _ref.length; _i < _len; _i++) {
          newkey = _ref[_i];
          ret.push(_.mapToFunction(table, newkey, val));
        }
      }
      return ret;
    };

    Aesmap.mapToFunction = function(table, key, val) {
      var allcols, cmd, cmds, cols, f, funcs, type, userCode, varFunc;
      if (_.isFunction(val)) {
        f = function(row) {
          var ret;
          row = new gg.util.RowWrapper(row);
          ret = val(row);
          return ret;
        };
        return {
          alias: key,
          f: f,
          type: data.Schema.unknown,
          cols: '*'
        };
      } else if (table.has(val)) {
        f = function(v) {
          return v;
        };
        return {
          alias: key,
          f: f,
          type: table.schema.type(val),
          cols: val
        };
      } else if (_.isObject(val)) {
        if ('f' in val && ('cols' in val || 'args' in val)) {
          if ('args' in val && !('cols' in val)) {
            val.cols = val.args;
          }
          cols = val.cols;
          f = val.f;
          type = val.type;
          if (!(f.length > args.length)) {
            throw Error("f requires more arguments than specified: " + f.length + ">" + args.length);
          }
          if (!_.all(args, function(col) {
            return table.has(col);
          })) {
            throw Error("table doesn't contain all args");
          }
          return {
            alias: key,
            f: f,
            type: type,
            cols: args
          };
        } else {
          funcs = _.mappingToFunctions(table, val);
          funcs = data.ops.Project.normalizeMappings(funcs, table.schema);
          allcols = _.uniq(_.flatten(_.map(funcs, function(desc) {
            return desc.cols;
          })));
          if (__indexOf.call(allcols, '*') >= 0) {
            allcols = '*';
          }
          f = function(row) {
            var ret;
            ret = {};
            _.each(funcs, function(desc, subkey) {
              return ret[desc.alias] = desc.f(row);
            });
            return ret;
          };
          return {
            alias: key,
            f: f,
            cols: allcols
          };
        }
      } else if (key !== 'text' && gg.util.Aesmap.isEvalJS(val)) {
        userCode = val.slice(1, val.length - 1);
        varFunc = function(k) {
          if (data.Table.reVariable.test(k)) {
            return "var " + k + " = row.get('" + k + "');";
          }
        };
        cmds = _.compact(_.map(table.schema.cols, varFunc));
        cmds.push("return " + userCode + ";");
        cmd = cmds.join('');
        f = Function("row", cmd);
        return {
          alias: key,
          f: f,
          type: data.Schema.unknown,
          cols: '*'
        };
      } else {
        gg.util.Aesmap.log("mapToFunction: const:  f(" + key + ")->" + val);
        f = function(row) {
          return val;
        };
        return {
          alias: key,
          f: f,
          type: data.Schema.type(val),
          cols: []
        };
      }
    };

    return Aesmap;

  })();

  gg.util.RowWrapper = (function() {

    function RowWrapper(row) {
      this.row = row;
      this.accessed = {};
    }

    RowWrapper.prototype.get = function(attr) {
      this.accessed[attr] = true;
      return this.row.get(attr);
    };

    RowWrapper.prototype.has = function(col, type) {
      return this.row.has(col, type);
    };

    return RowWrapper;

  })();

  _.mixin({
    mapToFunction: gg.util.Aesmap.mapToFunction,
    mappingToFunctions: gg.util.Aesmap.mappingToFunctions
  });

  try {
    events = require('events');
  } catch (error) {
    console.log(error);
  }

  gg.wf.Node = (function(_super) {

    __extends(Node, _super);

    Node.ggpackage = "gg.wf.Node";

    Node.type = "node";

    Node.id = function() {
      return gg.wf.Node.prototype._id += 1;
    };

    Node.prototype._id = 0;

    function Node(spec) {
      var logname;
      this.spec = spec != null ? spec : {};
      this.flow = this.spec.flow || null;
      this.inputs = [];
      this.type = this.constructor.type;
      this.id = gg.wf.Node.id();
      this.nChildren = this.spec.nChildren || 0;
      this.nParents = this.spec.nParents || 0;
      this.location = this.spec.location || "client";
      this.name = this.spec.name || ("" + this.type + "-" + this.id);
      this.params = new gg.util.Params(this.spec.params);
      this.params.ensure("klassname", [], this.constructor.ggpackage);
      logname = "" + this.constructor.name + ": " + this.name + "-" + this.id;
      this.log = gg.util.Log.logger(this.constructor.ggpackage, logname);
      this.parseSpec();
    }

    Node.prototype.parseSpec = function() {
      this.params.ensure('keys', ['key'], null);
      return this.params.ensure('compute', ['f'], null);
    };

    Node.prototype.setup = function(nParents, nChildren) {
      this.nParents = nParents;
      this.nChildren = nChildren;
      return this.inputs = _.times(this.nParents, function() {
        return null;
      });
    };

    Node.prototype.ready = function() {
      return _.all(this.inputs, function(input) {
        return input != null;
      });
    };

    Node.prototype.nReady = function() {
      return _.compact(this.inputs).length;
    };

    Node.prototype.setInput = function(idx, input) {
      return this.inputs[idx] = input;
    };

    Node.prototype.output = function(outidx, tableset) {
      var listeners;
      this.emit(outidx, this.id, outidx, tableset);
      this.emit("output", this.id, outidx, tableset);
      listeners = this.listeners(outidx);
      this.log.info("output: port(" + outidx + "), sizes: " + (tableset.left().nrows()));
      return this.debugTSet(tableset);
    };

    Node.prototype.debugTSet = function(tableset) {
      var counter, md, pairs, table, total;
      table = tableset.left().cache();
      md = tableset.right().cache();
      table.name = "data-" + this.name;
      md.name = "md-" + this.name;
      counter = new ggutil.Counter();
      total = 0;
      table.dfs(function(n, path) {
        var key, name, _i, _len, _ref, _results;
        name = n.constructor.name;
        counter.inc("" + name + "-count");
        counter.inc("" + n.name + "-count");
        _ref = n.timer().names();
        _results = [];
        for (_i = 0, _len = _ref.length; _i < _len; _i++) {
          key = _ref[_i];
          counter.inc(key, n.timer().sum(key));
          _results.push(total += n.timer().sum(key));
        }
        return _results;
      });
      pairs = [];
      counter.each(function(v, k) {
        return pairs.push([k, v]);
      });
      pairs.sort(function(o1, o2) {
        return o2[1] - o1[1];
      });
      if (total > 1000) {
        console.log(">> " + this.name + "\t" + total);
        console.log(table.graph());
        _.each(pairs, function(pair) {
          return console.log("" + pair[0] + "\t" + pair[1]);
        });
        console.log("\n");
      }
      tableset.left(table.disconnect());
      tableset.right(md.disconnect());
      return tableset;
    };

    Node.prototype.error = function(err) {
      if (_.isString(err)) {
        err = Error(err);
      }
      return this.emit("error", err);
    };

    Node.prototype.pstore = function() {
      return gg.prov.PStore.get(this.flow, this);
    };

    Node.prototype.isBarrier = function() {
      var _ref;
      return (_ref = this.type) === "barrier" || _ref === 'block';
    };

    Node.prototype.run = function() {
      throw Error("gg.wf.Node.run not implemented");
    };

    Node.prototype.compile = function() {
      return [this];
    };

    Node.create = function(compute, params, name) {
      var Klass, ret;
      if (params == null) {
        params = {};
      }
      params = new gg.util.Params(params);
      params.put('compute', compute);
      Klass = (function(_super1) {

        __extends(Klass, _super1);

        function Klass() {
          return Klass.__super__.constructor.apply(this, arguments);
        }

        return Klass;

      })(this);
      ret = new Klass({
        name: name,
        params: params
      });
      return ret;
    };

    Node.fromJSON = function(json) {
      var klass, klassname, o, spec;
      klassname = json.klassname;
      klass = _.ggklass(klassname);
      spec = {
        name: json.name,
        nChildren: json.nChildren,
        nParents: json.nParents,
        location: json.location,
        params: gg.util.Params.fromJSON(json.params)
      };
      o = new klass(spec);
      if (json.id != null) {
        o.id = json.id;
      }
      return o;
    };

    Node.prototype.toJSON = function() {
      var reject;
      reject = function(o) {
        return (o != null) && ((o.ENTITY_NODE != null) || (o.jquery != null) || (o.selectAll != null));
      };
      return {
        klassname: this.constructor.ggpackage,
        id: this.id,
        name: this.name,
        nChildren: this.nChildren,
        nParents: this.nParents,
        location: this.location,
        params: this.params.toJSON(reject)
      };
    };

    Node.prototype.clone = function(keepid) {
      var o, spec;
      if (keepid == null) {
        keepid = false;
      }
      spec = {
        name: this.name,
        nChildren: this.nChildren,
        nParents: this.nParents,
        location: this.location,
        params: this.params.clone(),
        flow: this.flow
      };
      o = new this.constructor(spec);
      if (keepid) {
        o.id = this.id;
      }
      return o;
    };

    return Node;

  })(events.EventEmitter);

  gg.wf.Exec = (function(_super) {

    __extends(Exec, _super);

    function Exec() {
      return Exec.__super__.constructor.apply(this, arguments);
    }

    Exec.ggpackage = "gg.wf.Exec";

    Exec.type = "exec";

    Exec.prototype.compute = function(pairtable, params, cb) {
      return cb(null, pairtable);
    };

    Exec.setup = function(pairtable, params) {
      var keys, partitions;
      keys = params.get('keys');
      if (keys == null) {
        keys = pairtable.sharedCols();
      }
      keys = _.intersection(keys, pairtable.sharedCols());
      pairtable = pairtable.ensure(keys);
      partitions = pairtable.partition(keys);
      return [keys, partitions];
    };

    Exec.finalize = function(pairtables, keys) {
      return data.PairTable.union(pairtables);
    };

    Exec.prototype.run = function() {
      var compute, iterator, keys, params, partitions, _ref,
        _this = this;
      if (!this.ready()) {
        throw Error("node not ready");
      }
      params = this.params;
      compute = this.params.get('compute') || this.compute.bind(this);
      try {
        _ref = gg.wf.Exec.setup(this.inputs[0], this.params), keys = _ref[0], partitions = _ref[1];
        iterator = function(pt, cb) {
          pt.left(pt.left().cache());
          pt.right(pt.right().cache());
          try {
            return compute(pt, params, cb);
          } catch (err) {
            console.log(err.stack);
            return cb(err, null);
          }
        };
        return async.map(partitions, iterator, function(err, pairtables) {
          var result;
          if (err != null) {
            throw Error(err);
          }
          result = gg.wf.Exec.finalize(pairtables);
          return _this.output(0, result);
        });
      } catch (err) {
        console.log(err.stack);
        throw Error(err);
      }
    };

    return Exec;

  })(gg.wf.Node);

  gg.wf.SyncExec = (function(_super) {

    __extends(SyncExec, _super);

    function SyncExec() {
      return SyncExec.__super__.constructor.apply(this, arguments);
    }

    SyncExec.prototype.parseSpec = function() {
      var compute, f, name;
      SyncExec.__super__.parseSpec.apply(this, arguments);
      f = this.params.get('compute');
      if (f == null) {
        f = this.compute.bind(this);
      }
      name = this.name;
      compute = function(pairtable, params, cb) {
        var res;
        try {
          res = f(pairtable, params, function() {
            throw Error("SyncExec should not call callback");
          });
          return cb(null, res);
        } catch (err) {
          console.log("error in syncexec: " + name);
          console.log(err.stack);
          return cb(err, null);
        }
      };
      return this.params.put('compute', compute);
    };

    SyncExec.prototype.compute = function(pairtable, params, cb) {
      return pairtable;
    };

    return SyncExec;

  })(gg.wf.Exec);

  gg.core.XForm = (function(_super) {

    __extends(XForm, _super);

    XForm.ggpackage = 'gg.core.XForm';

    XForm.log = gg.util.Log.logger(XForm.ggpackage, XForm.ggpackage.substr(XForm.ggpackage.lastIndexOf(".") + 1));

    function XForm(spec) {
      this.spec = spec != null ? spec : {};
      this.premap = this.postmap = null;
      XForm.__super__.constructor.apply(this, arguments);
    }

    XForm.prototype.parseSpec = function() {
      var compute, log;
      this.params.putAll({
        inputSchema: this.extractAttr("inputSchema"),
        outputSchema: this.extractAttr("outputSchema"),
        defaults: this.extractAttr("defaults"),
        keys: ['facet-x', 'facet-y', 'layer']
      });
      this.params.ensure("klassname", [], this.constructor.ggpackage);
      compute = this.params.get('compute') || this.compute.bind(this);
      log = this.log.bind(this);
      this.compute = function(pt, params) {
        pt = gg.core.FormUtil.addDefaults(pt, params, log);
        gg.core.FormUtil.validateInput(pt, params, log);
        return compute(pt, params);
      };
      return XForm.__super__.parseSpec.apply(this, arguments);
    };

    XForm.prototype.extractAttr = function(attr) {
      var spec, val;
      spec = this.spec;
      val = _.findGoodAttr(spec, [attr], null);
      if (val == null) {
        val = this[attr];
      }
      if (_.isFunction(val)) {
        val.constructorname = this.constructor.ggpackage;
      }
      return val;
    };

    XForm.prototype.ensureScales = function(pairtable, params) {
      return gg.core.FormUtil.ensureScales(pairtable, params, this.log);
    };

    XForm.prototype.scales = function(pairtable, params) {
      return gg.core.FormUtil.scales(pairtable, params, this.log);
    };

    XForm.prototype.defaults = function(pt, params) {
      return {};
    };

    XForm.prototype.inputSchema = function(pt, params) {
      return [];
    };

    XForm.prototype.outputSchema = function(pt, params) {
      return pt.leftSchema();
    };

    XForm.prototype.compile = function() {
      var nodes;
      nodes = [];
      if (this.premap != null) {
        nodes.push(this.premap.compile());
      }
      nodes.push(XForm.__super__.compile.apply(this, arguments));
      if (this.postmap != null) {
        nodes.push(this.postmap.compile());
      }
      return _.compact(_.flatten(nodes));
    };

    return XForm;

  })(gg.wf.SyncExec);

  gg.xform.Quantize = (function(_super) {

    __extends(Quantize, _super);

    function Quantize() {
      return Quantize.__super__.constructor.apply(this, arguments);
    }

    Quantize.ggpackage = "gg.xform.Quantize";

    Quantize.prototype.parseSpec = function() {
      var cols, nBins;
      this.log(this.params);
      this.params.ensureAll({
        cols: [[], []],
        nBins: [['nBins', "nbins", "bin", "n", "nbin", "bins"], 20]
      });
      cols = this.params.get("cols");
      cols = _.compact(_.flatten([cols]));
      if (cols.length === 0) {
        throw Error("need >0 cols to group on");
      }
      nBins = this.params.get("nBins");
      if (_.isNumber(nBins)) {
        nBins = _.times(cols.length, function() {
          return nBins;
        });
      }
      if (nBins.length !== cols.length) {
        throw Error("nBins length " + nBins.length + " != cols length " + cols.length);
      }
      this.params.put("nBins", nBins);
      this.log("nBins now " + (JSON.stringify(nBins)));
      return Quantize.__super__.parseSpec.apply(this, arguments);
    };

    Quantize.prototype.compute = function(pairtable, params) {
      var cols, mapping, md, nBins, scales, schema, table;
      table = pairtable.left();
      md = pairtable.right();
      if (table.nrows() === 0) {
        return pairtable;
      }
      schema = table.schema;
      scales = md.any('scales');
      cols = params.get("cols");
      nBins = params.get("nBins");
      if (!(cols.length > 0)) {
        return pairtable;
      }
      this.log("scales: " + (scales.toString()));
      this.log("get mapping functions on " + cols + ", " + nBins);
      mapping = this.constructor.getQuantizers(cols, schema, nBins, scales);
      this.log(mapping);
      table = table.project(mapping, true);
      pairtable.left(table);
      return pairtable;
    };

    Quantize.getQuantizers = function(cols, schema, nBins, scales) {
      return _.map(cols, function(col, idx) {
        var domain, f, scale, type;
        type = schema.type(col);
        scale = scales.scale(col, type);
        domain = scale.domain();
        f = gg.xform.Quantize.quantizer(col, type, nBins[idx], domain);
        return {
          alias: col,
          f: f,
          type: type,
          cols: col
        };
      });
    };

    Quantize.quantizer = function(col, type, nbins, domain) {
      var binRange, binSize, maxD, minD, toKey, _ref, _ref1;
      toKey = _.identity;
      if (nbins === -1) {
        type = data.Schema.ordinal;
      }
      switch (type) {
        case data.Schema.ordinal:
          toKey = _.identity;
          break;
        case data.Schema.numeric:
          _ref = [domain[0], domain[1]], minD = _ref[0], maxD = _ref[1];
          binRange = (maxD - minD) * 1.0;
          binSize = binRange / nbins;
          toKey = function(v) {
            var idx;
            idx = Math.ceil((v - minD) / binSize - 1);
            idx = Math.max(0, idx);
            return (idx * binSize) + minD + (binSize / 2);
          };
          break;
        case data.Schema.date:
          domain = [domain[0].getTime(), domain[1].getTime()];
          _ref1 = [domain[0], domain[1]], minD = _ref1[0], maxD = _ref1[1];
          binRange = (maxD - minD) * 1.0;
          binSize = binRange / nbins;
          toKey = function(v) {
            var date, idx, time;
            time = v.getTime();
            idx = Math.ceil((time - minD) / binSize - 1);
            idx = Math.max(0, idx);
            date = Math.ceil(idx * binSize) + minD + binSize / 2;
            return new Date(date);
          };
          break;
        default:
          throw Error("I don't support binning on col type: " + type);
      }
      return toKey;
    };

    return Quantize;

  })(gg.core.XForm);

  gg.parse.Parser = (function() {

    function Parser() {}

    Parser.parse = function(spec) {
      var global, layers,
        _this = this;
      global = this.parseGlobal(spec);
      layers = spec.layers;
      layers = _.flatten([layers]);
      if (layers.length === 0) {
        layers = [{}];
      }
      layers = _.map(layers, function(l) {
        return _this.parseLayer(l, global);
      });
      return {
        layers: layers,
        facets: global.facets,
        data: global.data,
        debug: global.debug,
        options: global.options
      };
    };

    Parser.parseGlobal = function(spec) {
      return {
        facets: this.extractFacets(spec),
        aes: this.extractAes(spec),
        geom: this.extractGeom(spec),
        scales: this.extractScales(spec),
        coord: this.extractCoord(spec),
        stat: this.extractStat(spec),
        pos: this.extractPos(spec),
        debug: this.extractDebug(spec),
        options: this.extractOpts(spec),
        data: this.extractData(spec)
      };
    };

    Parser.parseLayer = function(spec, global) {
      var aes, scales;
      aes = _.clone(global.aes);
      _.extend(aes, this.extractAes(spec, {}));
      scales = _.clone(global.scales);
      _.extend(scales, this.extractScales(spec, {}));
      return {
        aes: aes,
        data: this.extractData(spec),
        geom: this.extractGeom(spec, global.geom),
        scales: scales,
        coord: this.extractCoord(spec, global.coord),
        stat: this.extractStat(spec, global.stat),
        pos: this.extractPos(spec, global.pos)
      };
    };

    Parser.extractData = function(spec) {
      var data;
      data = null;
      if (spec != null) {
        data = spec.data;
      }
      return data;
    };

    Parser.extractFacets = function(spec) {
      var facet, _ref, _ref1, _ref2;
      facet = this.attr(spec, ['facet', 'facets'], "none");
      facet = this.normalize(facet, "none");
      if ((_ref = facet.x) == null) {
        facet.x = null;
      }
      if ((_ref1 = facet.y) == null) {
        facet.y = null;
      }
      if ((facet.x != null) || (facet.y != null)) {
        if ((_ref2 = facet.type) !== 'grid' && _ref2 !== 'wrap') {
          facet.type = 'grid';
        }
      } else {
        facet.type = 'none';
      }
      return facet;
    };

    Parser.extractAes = function(spec, defaultval) {
      var aes;
      if (defaultval == null) {
        defaultval = {};
      }
      aes = this.attr(spec, ['aes', 'map', 'mapping', 'aesthetic', 'aesthetics'], {});
      if (!_.isObject(aes)) {
        throw Error("asethetic should be an object: " + (JSON.stringify(aes)));
      }
      return aes;
    };

    Parser.extractPos = function(spec, defaultval) {
      var pos;
      if (defaultval == null) {
        defaultval = 'identity';
      }
      pos = this.attr(spec, ['pos', 'position'], defaultval);
      pos = this.normalize(pos);
      return pos;
    };

    Parser.extractCoord = function(spec, defaultval) {
      var coord;
      if (defaultval == null) {
        defaultval = 'identity';
      }
      coord = this.attr(spec, ['coord', 'coordinates'], defaultval);
      return coord = this.normalize(coord);
    };

    Parser.extractGeom = function(spec, defaultval) {
      var geom;
      if (defaultval == null) {
        defaultval = 'point';
      }
      geom = this.attr(spec, ['geom', 'shape', 'geometry'], defaultval);
      geom = this.normalize(geom);
      return geom;
    };

    Parser.extractStat = function(spec, defaultval) {
      var stat;
      if (defaultval == null) {
        defaultval = 'identity';
      }
      stat = this.attr(spec, ['stat', 'statistics'], defaultval);
      stat = this.normalize(stat);
      return stat;
    };

    Parser.extractOpts = function(spec, defaultval) {
      var opts;
      if (defaultval == null) {
        defaultval = {};
      }
      opts = this.attr(spec, ['opts', 'options'], defaultval);
      if (!_.isObject(opts)) {
        throw Error("options should be an object: " + (JSON.stringify(opts)));
      }
      return opts;
    };

    Parser.extractDebug = function(spec, defaultval) {
      var debug;
      if (defaultval == null) {
        defaultval = {};
      }
      debug = this.attr(spec, ['debug'], defaultval);
      if (!_.isObject(debug)) {
        throw Error("debug should be an object: " + (JSON.stringify(debug)));
      }
      return debug;
    };

    Parser.extractScales = function(spec, defaultval) {
      var scales,
        _this = this;
      if (defaultval == null) {
        defaultval = {};
      }
      scales = this.attr(spec, ['scales', 'scale'], defaultval);
      if (!_.isObject(scales)) {
        throw Error("scales should be an object: " + (JSON.stringify(scales)));
      }
      scales = _.o2map(scales, function(subspec, col) {
        return [col, _this.normalize(subspec, 'linear')];
      });
      return scales;
    };

    Parser.normalize = function(spec, defaulttype) {
      var _this = this;
      if (defaulttype == null) {
        defaulttype = null;
      }
      if (_.isString(spec)) {
        return {
          type: spec,
          aes: {}
        };
      } else if (_.isArray(spec)) {
        return spec = _.map(spec, function(subspec) {
          return _this.normalize(subspec, defaulttype);
        });
      } else {
        if (spec.type == null) {
          if (defaulttype == null) {
            throw Error("spec doesn't have a type: " + (JSON.stringify(spec)));
          }
          spec.type = defaulttype;
        }
        spec.aes = this.extractAes(spec);
        return spec;
      }
    };

    Parser.attr = function(spec, attrs, defaultval) {
      var attr, _i, _len;
      if (defaultval == null) {
        defaultval = null;
      }
      for (_i = 0, _len = attrs.length; _i < _len; _i++) {
        attr = attrs[_i];
        if ((spec != null) && (spec[attr] != null)) {
          return spec[attr];
        }
      }
      return defaultval;
    };

    Parser.extractWithConfig = function(spec, config) {
      var defaultval, desc, key, name, names, o, _i, _len, _ref;
      o = {};
      for (key in config) {
        desc = config[key];
        if (_.isObject(desc)) {
          if ('default' in desc || 'names' in desc) {
            names = _.compact(_.flatten([key, desc.names]));
            defaultval = desc["default"] || null;
          } else {
            names = [key];
            defaultval = desc;
          }
        } else {
          names = [key];
          defaultval = desc;
        }
        for (_i = 0, _len = names.length; _i < _len; _i++) {
          name = names[_i];
          if (spec[name] != null) {
            o[name] = spec[name];
          }
        }
        if ((_ref = o[key]) == null) {
          o[key] = defaultval;
        }
      }
      return o;
    };

    return Parser;

  })();

  gg.xform.GroupBy = (function(_super) {

    __extends(GroupBy, _super);

    function GroupBy() {
      return GroupBy.__super__.constructor.apply(this, arguments);
    }

    GroupBy.ggpackage = "gg.xform.GroupBy";

    GroupBy.prototype.parseSpec = function() {
      var aggs;
      this.log(this.params);
      this.params.ensureAll({
        aggs: [["agg", "aggs"], {}]
      });
      this.annotate = new gg.xform.Quantize({
        name: "" + this.name + "-quantize",
        params: this.params
      });
      aggs = this.params.get('aggs');
      aggs = _.map(aggs, function(spec, name) {
        var args, col, type, _ref;
        if ((spec != null) && (spec.alias != null) && (spec.f != null) && _.isFunction(spec.f)) {
          return spec;
        }
        if (!_.isString(spec)) {
          type = spec.type;
        }
        if (_.isString(spec)) {
          type = spec;
        }
        col = spec.col;
        if (col == null) {
          col = 'y';
        }
        args = [];
        if (spec.args != null) {
          args = spec.args;
        }
        return (_ref = data.ops.Aggregate).agg.apply(_ref, [type, name, col].concat(__slice.call(args)));
      });
      this.params.put('aggs', aggs);
      return GroupBy.__super__.parseSpec.apply(this, arguments);
    };

    GroupBy.prototype.inputSchema = function(pairtable, params) {
      return params.get("cols");
    };

    GroupBy.prototype.outputSchema = function(pairtable, params) {
      var agg, aggName, aggs, cols, newSchema, schema, spec;
      cols = params.get("cols");
      aggs = params.get("aggs");
      schema = pairtable.leftSchema().clone();
      spec = {};
      for (aggName in aggFuncs) {
        agg = aggFuncs[aggName];
        spec[aggName] = data.Schema.numeric;
      }
      newSchema = data.Schema.fromJSON(spec);
      return schema.merge(newSchema);
    };

    GroupBy.prototype.compute = function(pairtable, params) {
      var aggs, cols, md, table;
      table = pairtable.left();
      md = pairtable.right();
      cols = params.get('cols');
      aggs = params.get('aggs');
      table = table.groupby(cols, aggs);
      table = table.flatten();
      pairtable.left(table);
      return pairtable;
    };

    GroupBy.prototype.compile = function() {
      var nodes;
      nodes = GroupBy.__super__.compile.apply(this, arguments);
      nodes.unshift(this.annotate.compile());
      return nodes;
    };

    return GroupBy;

  })(gg.core.XForm);

  gg.geom.reparam.Point = (function(_super) {

    __extends(Point, _super);

    function Point() {
      return Point.__super__.constructor.apply(this, arguments);
    }

    Point.ggpackage = "gg.geom.reparam.Point";

    Point.prototype.defaults = function() {
      return {
        r: 5,
        y: 0
      };
    };

    Point.prototype.inputSchema = function() {
      return ['x'];
    };

    Point.prototype.outputSchema = function(pairtable) {
      var col, schema, xtype, ytype, _i, _j, _len, _len1, _ref, _ref1;
      schema = pairtable.leftSchema().clone();
      xtype = schema.type('x');
      ytype = schema.type('y');
      _ref = ['x0', 'x1'];
      for (_i = 0, _len = _ref.length; _i < _len; _i++) {
        col = _ref[_i];
        if (!schema.contains(col)) {
          schema.addColumn(col, xtype);
        }
      }
      _ref1 = ['y0', 'y1'];
      for (_j = 0, _len1 = _ref1.length; _j < _len1; _j++) {
        col = _ref1[_j];
        if (!schema.contains(col)) {
          schema.addColumn(col, ytype);
        }
      }
      return schema;
    };

    Point.prototype.compute = function(pairtable, params) {
      var mapping, md, schema, table;
      table = pairtable.left();
      md = pairtable.right();
      schema = params.get('outputSchema')(pairtable);
      mapping = [
        {
          alias: 'y1',
          f: function(y1, y, r) {
            if (y1 != null) {
              return y1;
            } else {
              return y + r;
            }
          },
          type: data.Schema.numeric,
          cols: ['y1', 'y', 'r']
        }, {
          alias: 'y0',
          f: function(y0, y, r) {
            if (y0 != null) {
              return y0;
            } else {
              return y - r;
            }
          },
          type: data.Schema.numeric,
          cols: ['y0', 'y', 'r']
        }, {
          alias: 'x1',
          f: function(x1, x, r) {
            if (x1 != null) {
              return x1;
            } else {
              return x + r;
            }
          },
          type: data.Schema.numeric,
          cols: ['x1', 'x', 'r']
        }, {
          alias: 'x0',
          f: function(x0, x, r) {
            if (x0 != null) {
              return x0;
            } else {
              return x - r;
            }
          },
          type: data.Schema.numeric,
          cols: ['x0', 'x', 'r']
        }
      ];
      mapping = _.reject(mapping, function(desc) {
        return table.has(desc.alias);
      });
      table = table.project(mapping, true);
      pairtable.left(table);
      return pairtable;
    };

    return Point;

  })(gg.core.XForm);

  gg.geom.Render = (function(_super) {

    __extends(Render, _super);

    Render.ggpackage = "gg.geom.Render";

    function Render(spec) {
      this.spec = spec != null ? spec : {};
      this.spec.name = this.spec.name || ("render-" + this.constructor.name);
      Render.__super__.constructor.apply(this, arguments);
    }

    Render.prototype.parseSpec = function() {
      Render.__super__.parseSpec.apply(this, arguments);
      return this.params.put("location", "client");
    };

    Render.prototype.svg = function(md) {
      return md.any('svg').pane;
    };

    Render.prototype.groups = function(g, klass, rows) {
      return g.selectAll("g." + klass).data(rows).enter().append('g').classed(klass, true);
    };

    Render.prototype.agroup = function(g, klass, rows) {
      return g.append("g").classed(klass, true).data(rows);
    };

    Render.prototype.applyAttrs = function(domEl, attrs) {
      _.each(attrs, function(val, attr) {
        return domEl.attr(attr, val);
      });
      return domEl;
    };

    Render.prototype.compute = function(pairtable, params) {
      var md, svg, table;
      table = pairtable.left();
      md = pairtable.right();
      svg = this.svg(md);
      this.render(table, svg);
      this.renderDebug(md, svg);
      this.renderInteraction(md, svg);
      return pairtable;
    };

    Render.prototype.render = function(table, rows) {
      throw Error("" + this.name + ".render() not implemented");
    };

    Render.prototype.renderDebug = function(md, svg) {
      var write;
      if (this.log.level === gg.util.Log.DEBUG) {
        write = function(text, opts) {
          if (opts == null) {
            opts = {};
          }
          return _.subSvg(svg, opts, "text").text(text);
        };
        write(md.any('facet-x'), {
          dy: "1em"
        });
        write(md.any('facet-y'), {
          dy: "2em"
        });
        return write(md.any(table.nrows()), {
          dy: "3em"
        });
      }
    };

    Render.prototype.renderInteraction = function(md, svg) {
      var Facets, brushEventName, event, geoms, row;
      Facets = gg.facet.base.Facets;
      geoms = svg.selectAll(".geom");
      if (false) {
        geoms.on("mouseover", function() {}).on("mouseout", function() {});
      }
      if (false && (this.constructor.brush != null)) {
        row = md.any();
        brushEventName = "brush-" + (md.any('facet-x'));
        event = md.any("event");
        return event.on(brushEventName, this.constructor.brush(geoms));
      }
    };

    Render.klasses = function() {
      var klasses, ret;
      klasses = _.compact([gg.geom.svg.Point, gg.geom.svg.Line, gg.geom.svg.Rect, gg.geom.svg.Area, gg.geom.svg.Boxplot, gg.geom.svg.Text]);
      ret = {};
      _.each(klasses, function(klass) {
        var alias, _i, _len, _ref, _results;
        _ref = _.flatten([klass.aliases]);
        _results = [];
        for (_i = 0, _len = _ref.length; _i < _len; _i++) {
          alias = _ref[_i];
          _results.push(ret[alias] = klass);
        }
        return _results;
      });
      return ret;
    };

    Render.fromSpec = function(spec) {
      var klass, klasses;
      klasses = gg.geom.Render.klasses();
      klass = klasses[spec.type];
      if (klass == null) {
        return null;
      }
      return new klass(spec);
    };

    return Render;

  })(gg.core.XForm);

  gg.geom.GeomRenderPath = (function(_super) {

    __extends(GeomRenderPath, _super);

    function GeomRenderPath() {
      return GeomRenderPath.__super__.constructor.apply(this, arguments);
    }

    return GeomRenderPath;

  })(gg.geom.Render);

  gg.geom.GeomRenderPolygon = (function(_super) {

    __extends(GeomRenderPolygon, _super);

    function GeomRenderPolygon() {
      return GeomRenderPolygon.__super__.constructor.apply(this, arguments);
    }

    return GeomRenderPolygon;

  })(gg.geom.Render);

  gg.geom.GeomRenderGlyph = (function(_super) {

    __extends(GeomRenderGlyph, _super);

    function GeomRenderGlyph() {
      return GeomRenderGlyph.__super__.constructor.apply(this, arguments);
    }

    return GeomRenderGlyph;

  })(gg.geom.Render);

  gg.geom.svg.Line = (function(_super) {

    __extends(Line, _super);

    function Line() {
      return Line.__super__.constructor.apply(this, arguments);
    }

    Line.ggpackage = "gg.geom.svg.Line";

    Line.aliases = "line";

    Line.prototype.defaults = function() {
      return {
        "stroke-width": 1.5,
        "stroke-opacity": 0.7,
        stroke: "black",
        fill: "none"
      };
    };

    Line.prototype.inputSchema = function() {
      return ['x', 'y', 'y1'];
    };

    Line.linesCross = function(_arg, _arg1) {
      var d, ret, s, t, x0, x1, xp0, xp1, y0, y1, yp0, yp1;
      x0 = _arg[0], y0 = _arg[1], x1 = _arg[2], y1 = _arg[3];
      xp0 = _arg1[0], yp0 = _arg1[1], xp1 = _arg1[2], yp1 = _arg1[3];
      d = xp1 * y1 - x1 * yp1;
      if (d === 0) {
        return false;
      }
      s = (1 / d) * ((x0 - xp0) * y1 - (y0 - yp0) * x1);
      t = (1 / d) * -(-(x0 - xp0) * yp1 + (y0 - yp0) * xp1);
      ret = s > 0 && s < 1 && t > 0 && t < 1;
      return ret;
    };

    Line.withinBox = function(x, y, _arg) {
      var x0, x1, y0, y1;
      x0 = _arg[0], y0 = _arg[1], x1 = _arg[2], y1 = _arg[3];
      return x0 <= x && x <= x1 && y0 <= y && y <= y1;
    };

    Line.lineCrossBox = function(line, box) {
      var ret, x0, x1, xp0, xp1, y0, y1, yp0, yp1;
      x0 = line[0], y0 = line[1], x1 = line[2], y1 = line[3];
      xp0 = box[0], yp0 = box[1], xp1 = box[2], yp1 = box[3];
      ret = this.withinBox(x0, y0, box) || this.withinBox(x1, y1, box) || this.linesCross(line, [xp0, yp0, xp0, yp1]) || this.linesCross(line, [xp0, yp0, xp1, yp0]) || this.linesCross(line, [xp1, yp1, xp0, yp1]) || this.linesCross(line, [xp1, yp1, xp1, yp0]);
      return ret;
    };

    Line.brush = function(geoms) {
      return function(_arg) {
        var extent, maxx, maxy, minx, miny, _ref, _ref1;
        (_ref = _arg[0], minx = _ref[0], miny = _ref[1]), (_ref1 = _arg[1], maxx = _ref1[0], maxy = _ref1[1]);
        extent = [minx, miny, maxx, maxy];
        return geoms.attr('stroke', function(d, i) {
          var cur, l, line, prev, pts, row, _i, _len, _ref2;
          l = d3.select(this);
          row = l.data()[0];
          pts = row.get('pts');
          prev = _.first(pts);
          cur = null;
          _ref2 = _.rest(pts);
          for (_i = 0, _len = _ref2.length; _i < _len; _i++) {
            cur = _ref2[_i];
            line = [prev.x, prev.y1, cur.x, cur.y1];
            if (gg.geom.svg.Line.lineCrossBox(line, extent)) {
              return 'black';
            }
            prev = cur;
          }
          return row.get('stroke');
        });
      };
    };

    Line.prototype.render = function(table, svg) {
      var cssNormal, cssOver, enter, enterLines, exit, liner, lines, linetables, _this;
      linetables = table.partition('group', 'table').all('table');
      lines = this.groups(svg, 'line', linetables).selectAll('path').data(function(d) {
        return [d];
      });
      enter = lines.enter();
      enterLines = enter.append("path");
      exit = lines.exit();
      liner = d3.svg.line().x(function(d) {
        return d.get('x');
      }).y(function(d) {
        return d.get('y1');
      });
      this.log("stroke is " + (table.any("stroke")));
      cssNormal = {
        "stroke": function(g) {
          return g.any('stroke');
        },
        "stroke-width": function(g) {
          return g.any("stroke-width");
        },
        "stroke-opacity": function(g) {
          return g.any("stroke-opacity");
        },
        "fill": "none"
      };
      cssOver = {
        stroke: function(g) {
          return d3.rgb(g.any("fill")).darker(2);
        },
        "stroke-width": function(g) {
          return g.any('stroke-width') + 1;
        },
        "stroke-opacity": 1
      };
      this.applyAttrs(enterLines, {
        "class": "geom",
        d: function(d) {
          return liner(d.all());
        }
      });
      this.applyAttrs(enterLines, cssNormal);
      _this = this;
      lines.on("mouseover", function(d, idx) {
        return _this.applyAttrs(d3.select(this), cssOver);
      }).on("mouseout", function(d, idx) {
        return _this.applyAttrs(d3.select(this), cssNormal);
      });
      return exit.remove();
    };

    return Line;

  })(gg.geom.Render);

  gg.geom.reparam.Line = (function(_super) {

    __extends(Line, _super);

    function Line() {
      return Line.__super__.constructor.apply(this, arguments);
    }

    Line.ggpackage = "gg.geom.reparam.Line";

    Line.prototype.inputSchema = function() {
      return ['x', 'y'];
    };

    Line.prototype.outputSchema = function(pairtable) {
      var numeric, schema, xtype, ytype;
      schema = pairtable.leftSchema();
      numeric = data.Schema.numeric;
      xtype = schema.type('x');
      ytype = schema.type('y');
      return data.Schema.fromJSON({
        group: schema.type('group'),
        x: xtype,
        y: ytype,
        y0: ytype,
        y1: ytype
      });
    };

    Line.prototype.schemaMapping = function() {
      return {
        y0: 'y',
        y1: 'y'
      };
    };

    Line.prototype.compute = function(pairtable, params) {
      var mapping, scales, table, y0, y0f, y1f;
      table = pairtable.left();
      scales = pairtable.right().any('scales');
      y0 = scales.get('y').minRange();
      this.log("compute: y0 set to " + y0);
      y0f = function(y0) {
        if (y0 != null) {
          return y0;
        } else {
          return y0;
        }
      };
      y1f = function(y1, y) {
        if (y1 != null) {
          return y1;
        } else {
          return y;
        }
      };
      mapping = [];
      if (!table.has('y0')) {
        mapping.push({
          alias: 'y0',
          f: y0f,
          type: data.Schema.numeric,
          cols: ['y0']
        });
      }
      if (!table.has('y1')) {
        mapping.push({
          alias: 'y1',
          f: y1f,
          type: data.Schema.numeric,
          cols: ['y1', 'y']
        });
      }
      if (mapping.length > 0) {
        table = table.project(mapping, true);
      }
      pairtable.left(table);
      return pairtable;
    };

    return Line;

  })(gg.core.XForm);

  gg.geom.svg.Rect = (function(_super) {

    __extends(Rect, _super);

    function Rect() {
      return Rect.__super__.constructor.apply(this, arguments);
    }

    Rect.ggpackage = "gg.geom.svg.Rect";

    Rect.aliases = ["rect", 'box'];

    Rect.prototype.defaults = function() {
      return {
        "fill-opacity": 0.5,
        fill: "steelblue",
        stroke: "steelblue",
        "stroke-width": 1,
        "stroke-opacity": 0.5
      };
    };

    Rect.prototype.inputSchema = function() {
      return ['x0', 'x1', 'y0', 'y1'];
    };

    Rect.brush = function(geoms) {
      var height, width, x, y;
      x = function(t) {
        return t.get('x0');
      };
      y = function(t) {
        return Math.min(t.get('y0'), t.get('y1'));
      };
      height = function(t) {
        return Math.abs(t.get('y1') - t.get('y0'));
      };
      width = function(t) {
        return t.get('x1') - t.get('x0');
      };
      return function(_arg) {
        var maxx, maxy, minx, miny, _ref, _ref1;
        (_ref = _arg[0], minx = _ref[0], miny = _ref[1]), (_ref1 = _arg[1], maxx = _ref1[0], maxy = _ref1[1]);
        return geoms.attr('fill', function(d, i) {
          var h, r, row, valid, w, x0, x1, y0, y1, _ref2, _ref3;
          r = d3.select(this);
          row = r.datum();
          x0 = x(row);
          y0 = y(row);
          h = height(row);
          w = width(row);
          x1 = x0 + w;
          y1 = y0 + h;
          _ref2 = [Math.min(x0, x1), Math.max(x0, x1)], x0 = _ref2[0], x1 = _ref2[1];
          _ref3 = [Math.min(y0, y1), Math.max(y0, y1)], y0 = _ref3[0], y1 = _ref3[1];
          valid = !(x1 < minx || x0 > maxx || y1 < miny || y0 > maxy);
          if (valid) {
            return 'black';
          } else {
            return row.get('fill');
          }
        });
      };
    };

    Rect.prototype.render = function(table, svg) {
      var cssOut, cssOver, enter, enterRects, exit, height, rects, rows, width, x, y, _this;
      rows = table.all();
      rects = this.agroup(svg, "intervals geoms", rows).selectAll("rect").data(rows);
      enter = rects.enter();
      exit = rects.exit();
      enterRects = enter.append("rect");
      x = function(t) {
        return t.get('x0');
      };
      y = function(t) {
        return Math.min(t.get('y0'), t.get('y1'));
      };
      height = function(t) {
        return Math.abs(t.get('y1') - t.get('y0'));
      };
      width = function(t) {
        return t.get('x1') - t.get('x0');
      };
      this.applyAttrs(enterRects, {
        "class": "geom",
        x: x,
        y: y,
        width: width,
        height: height,
        stroke: function(t) {
          return t.get('stroke');
        },
        'stroke-width': function(t) {
          return t.get('stroke-width');
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
      cssOver = {
        fill: function(t) {
          return d3.rgb(t.get("fill")).darker(1);
        },
        "fill-opacity": 1
      };
      cssOut = {
        x: x,
        width: width,
        fill: function(t) {
          return t.get('fill');
        },
        "fill-opacity": function(t) {
          return t.get('fill-opacity');
        }
      };
      _this = this;
      rects.on("mouseover", function(d, idx) {
        return _this.applyAttrs(d3.select(this), cssOver);
      }).on("mouseout", function(d, idx) {
        return _this.applyAttrs(d3.select(this), cssOut);
      });
      return exit.transition().duration(500).attr("fill-opacity", 0).attr("stroke-opacity", 0).transition().remove();
    };

    return Rect;

  })(gg.geom.Render);

  gg.wf.Barrier = (function(_super) {

    __extends(Barrier, _super);

    function Barrier() {
      return Barrier.__super__.constructor.apply(this, arguments);
    }

    Barrier.ggpackage = "gg.wf.Barrier";

    Barrier.type = "barrier";

    Barrier.prototype.compute = function(pt, params, cb) {
      return cb(null, pt);
    };

    Barrier.setup = function(inputs) {
      var md, mds, table, tables;
      tables = _.map(inputs, function(pt, idx) {
        var t;
        t = pt.left();
        return t.setColVal('_barrier', idx);
      });
      mds = _.map(inputs, function(pt, idx) {
        var md;
        md = pt.right();
        return md.setColVal('_barrier', idx);
      });
      table = new data.ops.Union(tables);
      md = new data.ops.Union(mds);
      return new data.PairTable(table, md);
    };

    Barrier.finalize = function(tableset) {
      var md, pairtable, table,
        _this = this;
      table = tableset.left();
      md = tableset.right();
      table = table.partition('_barrier', 'table');
      md = md.partition('_barrier', 'md');
      pairtable = table.join(md, '_barrier');
      return pairtable.map(function(row) {
        var idx;
        table = row.get('table');
        md = row.get('md') || null;
        if (table != null) {
          table = table.exclude('_barrier');
        }
        if (md != null) {
          md = md.exclude('_barrier');
        }
        idx = row.get('_barrier');
        return {
          idx: idx,
          pairtable: new data.PairTable(table, md)
        };
      });
    };

    Barrier.prototype.run = function() {
      var compute, pairtable,
        _this = this;
      if (!this.ready()) {
        throw Error("Node not ready");
      }
      compute = this.params.get('compute') || this.compute.bind(this);
      try {
        pairtable = gg.wf.Barrier.setup(this.inputs);
        return compute(pairtable, this.params, function(err, tableset) {
          var idx, output, result, results, _i, _len, _results;
          if (err != null) {
            throw err;
          }
          results = gg.wf.Barrier.finalize(tableset);
          _results = [];
          for (_i = 0, _len = results.length; _i < _len; _i++) {
            result = results[_i];
            idx = result.idx;
            output = result.pairtable;
            _results.push(_this.output(idx, output));
          }
          return _results;
        });
      } catch (err) {
        console.log(err.stack);
        throw Error(err);
      }
    };

    return Barrier;

  })(gg.wf.Node);

  gg.wf.SyncBarrier = (function(_super) {

    __extends(SyncBarrier, _super);

    function SyncBarrier() {
      return SyncBarrier.__super__.constructor.apply(this, arguments);
    }

    SyncBarrier.prototype.parseSpec = function() {
      var f, makecompute, name;
      SyncBarrier.__super__.parseSpec.apply(this, arguments);
      f = this.params.get('compute');
      if (f == null) {
        f = this.compute.bind(this);
      }
      name = this.name;
      makecompute = function(f) {
        return function(pairtable, params, cb) {
          var res;
          try {
            res = f(pairtable, params, function() {
              throw Error("SyncBarrier should not call callback");
            });
            return cb(null, res);
          } catch (err) {
            console.log("err in SyncBarrier " + name);
            console.log(err.stack);
            return cb(err, null);
          }
        };
      };
      return this.params.put('compute', makecompute(f));
    };

    return SyncBarrier;

  })(gg.wf.Barrier);

  gg.core.BForm = (function(_super) {

    __extends(BForm, _super);

    function BForm() {
      return BForm.__super__.constructor.apply(this, arguments);
    }

    BForm.ggpackage = "gg.core.BForm";

    BForm.log = gg.util.Log.logger(BForm.ggpackage, BForm.ggpackage.substr(BForm.ggpackage.lastIndexOf(".") + 1));

    BForm.prototype.parseSpec = function() {
      var FormUtil, f, makecompute;
      this.log("XForm spec: " + (JSON.stringify(this.spec)));
      this.params.putAll({
        inputSchema: this.extractAttr("inputSchema"),
        outputSchema: this.extractAttr("outputSchema"),
        defaults: this.extractAttr("defaults"),
        keys: ['facet-x', 'facet-y', 'layer']
      });
      this.params.ensure("klassname", [], this.constructor.ggpackage);
      f = this.spec.f;
      if (f == null) {
        f = this.compute.bind(this);
      }
      FormUtil = gg.core.FormUtil;
      makecompute = function(log) {
        return function(pairtable, params) {
          pairtable = FormUtil.addDefaults(pairtable, params, log);
          FormUtil.validateInput(pairtable, params);
          return f(pairtable, params);
        };
      };
      this.params.put('compute', makecompute(this.log));
      return BForm.__super__.parseSpec.apply(this, arguments);
    };

    BForm.prototype.extractAttr = function(attr, spec) {
      var val;
      if (spec == null) {
        spec = null;
      }
      if (spec == null) {
        spec = this.spec;
      }
      val = _.findGoodAttr(spec, [attr], null);
      if (val == null) {
        val = this[attr];
      }
      if (_.isFunction(val)) {
        val.constructorname = this.constructor.ggpackage;
      }
      return val;
    };

    BForm.prototype.defaults = function(pairtable, params) {
      return {};
    };

    BForm.prototype.inputSchema = function(pairtable, params) {
      return [];
    };

    BForm.prototype.outputSchema = function(pairtable, params) {
      return pairtable.left().schema;
    };

    return BForm;

  })(gg.wf.SyncBarrier);

  gg.geom.reparam.Rect = (function(_super) {

    __extends(Rect, _super);

    function Rect() {
      return Rect.__super__.constructor.apply(this, arguments);
    }

    Rect.ggpackage = "gg.geom.reparam.Rect";

    Rect.prototype.parseSpec = function() {
      Rect.__super__.parseSpec.apply(this, arguments);
      return this.params.put('keys', ['layer']);
    };

    Rect.prototype.inputSchema = function() {
      return ['x', 'y'];
    };

    Rect.prototype.compute = function(pairtable, params) {
      var mapping, md, minY, padding, scales, table, width, xscale, yscale, _ref;
      table = pairtable.left();
      md = pairtable.right();
      scales = md.any('scales');
      yscale = scales.scale('y');
      xscale = scales.scale('x');
      padding = 1.0 - params.get('padding');
      if ((_ref = xscale.type) === data.Schema.ordinal || _ref === data.Schema.object) {
        width = xscale.range()[1] - xscale.range()[0];
      } else {
        width = this.getRectWidth(table, xscale, padding);
      }
      minY = yscale.scale(0);
      mapping = [
        {
          alias: 'width',
          f: function() {
            return width;
          },
          type: data.Schema.numeric,
          cols: []
        }, {
          alias: 'x0',
          f: function(x0, x) {
            if (x0 != null) {
              return x0;
            } else {
              return x - width / 2.0;
            }
          },
          type: data.Schema.numeric,
          cols: ['x0', 'x']
        }, {
          alias: 'x1',
          f: function(x1, x) {
            if (x1 != null) {
              return x1;
            } else {
              return x + width / 2.0;
            }
          },
          type: data.Schema.numeric,
          cols: ['x1', 'x']
        }, {
          alias: 'y0',
          f: function(y0, y) {
            if (y0 != null) {
              return y0;
            } else {
              return Math.min(minY, y);
            }
          },
          type: data.Schema.numeric,
          cols: ['y0', 'y']
        }, {
          alias: 'y1',
          f: function(y1, y) {
            if (y1 != null) {
              return y1;
            } else {
              return Math.max(minY, y);
            }
          },
          type: data.Schema.numeric,
          cols: ['y1', 'y']
        }
      ];
      table = table.project(mapping, true);
      pairtable.left(table);
      return pairtable;
    };

    Rect.prototype.getRectWidth = function(table, xscale, padding) {
      var groups, mindiff, width;
      if (padding == null) {
        padding = 0;
      }
      groups = table.partition(['facet-x', 'facet-y', 'group', 'layer']);
      width = xscale.range()[1] - xscale.range()[0];
      mindiff = null;
      groups.each(function(row) {
        var diffs, subwidth, xs;
        xs = row.get('table').all('x');
        xs = _.uniq(xs).sort((function(a, b) {
          return a - b;
        }));
        diffs = _.times(xs.length - 1, function(idx) {
          return xs[idx + 1] - xs[idx];
        });
        if (!(diffs.length > 0)) {
          return;
        }
        mindiff = _.mmin(diffs) || 1;
        mindiff *= padding;
        subwidth = Math.max(1, mindiff);
        if (width == null) {
          width = subwidth;
        }
        return width = Math.min(width, subwidth);
      });
      return width;
    };

    return Rect;

  })(gg.core.XForm);

  gg.facet.pane.Container = (function() {

    Container.ggpackage = 'gg.facet.pane.Container';

    function Container(c, xidx, yidx, x, y, bXFacet, bYFacet, bXAxis, bYAxis, opts) {
      this.c = c;
      this.xidx = xidx;
      this.yidx = yidx;
      this.x = x;
      this.y = y;
      this.bXFacet = bXFacet;
      this.bYFacet = bYFacet;
      this.bXAxis = bXAxis;
      this.bYAxis = bYAxis;
      this.opts = opts != null ? opts : {};
      this.labelHeight = this.opts.labelHeight || 15;
      this.yAxisW = this.opts.yAxisW || 20;
      this.xAxisW = this.opts.xAxisW || 20;
      this.padding = this.opts.padding || 5;
      this.lpad = this.rpad = this.upad = this.bpad = 0;
      if (!this.bYAxis) {
        this.lpad = this.padding;
      }
      if (!this.bYFacet) {
        this.rpad = this.padding;
      }
      if (!this.bXFacet) {
        this.upad = this.padding;
      }
    }

    Container.prototype.clone = function() {
      return gg.facet.pane.Container.fromJSON(this.toJSON());
    };

    Container.prototype.toJSON = function() {
      return {
        c: _.toJSON(this.c),
        xidx: _.toJSON(this.xidx),
        yidx: _.toJSON(this.yidx),
        x: _.toJSON(this.x),
        y: _.toJSON(this.y),
        bXFacet: this.bXFacet,
        bYFacet: this.bYFacet,
        bXAxis: this.bXAxis,
        bYAxis: this.bYAxis,
        labelHeight: this.labelHeight,
        yAxisW: this.yAxisW,
        xAxisW: this.xAxisW
      };
    };

    Container.fromJSON = function(json) {
      return new gg.facet.pane.Container(_.fromJSON(json.c), _.fromJSON(json.xidx), _.fromJSON(json.yidx), _.fromJSON(json.x), _.fromJSON(json.y), json.bXFacet, json.bYFacet, json.bXAxis, json.bYAxis, json.labelHeight, json.yAxisW, json.xAxisW);
    };

    Container.prototype.toString = function() {
      return JSON.stringify({
        xidx: this.xidx,
        yidx: this.yidx,
        c: this.c.toString()
      });
    };

    Container.prototype.w = function() {
      return this.c.w() + this.labelHeight * this.bYFacet + this.yAxisW * this.bYAxis;
    };

    Container.prototype.h = function() {
      return this.c.h() + this.labelHeight * (this.bXFacet + this.bXAxis);
    };

    Container.prototype.top = function() {
      return this.c.y0 - this.labelHeight * this.bXFacet;
    };

    Container.prototype.left = function() {
      return this.c.x0 - this.yAxisW * this.bYAxis;
    };

    Container.prototype.bound = function() {
      return new gg.util.Bound(this.left(), this.top(), this.left() + this.w(), this.top() + this.h());
    };

    Container.prototype.drawC = function() {
      var h, w, x0, y0;
      x0 = this.yAxisW * this.bYAxis + this.lpad;
      y0 = this.labelHeight * this.bXFacet + this.upad;
      w = this.c.w() - this.rpad - this.lpad;
      h = this.c.h() - this.bpad - this.upad;
      return new gg.util.Bound(x0, y0, x0 + w, y0 + h);
    };

    Container.prototype.xFacetC = function() {
      var h, w, x0, y0;
      x0 = this.yAxisW * this.bYAxis + this.lpad;
      y0 = 0;
      w = this.c.w() - this.rpad - this.lpad;
      h = this.labelHeight * this.bXFacet;
      return new gg.util.Bound(x0, y0, x0 + w, y0 + h);
    };

    Container.prototype.yFacetC = function() {
      var h, w, x0, y0;
      x0 = this.yAxisW * this.bYAxis + this.c.width();
      y0 = this.labelHeight * this.bXFacet + this.upad;
      w = this.labelHeight * this.bYFacet;
      h = this.c.h() - this.upad - this.bpad;
      return new gg.util.Bound(x0, y0, x0 + w, y0 + h);
    };

    Container.prototype.xAxisC = function() {
      var h, w, x0, y0;
      x0 = this.yAxisW * this.bYAxis + this.lpad;
      y0 = this.c.h() + this.labelHeight * this.bXFacet;
      w = this.c.w() - this.lpad - this.rpad;
      h = this.labelHeight * this.bXAxis;
      return new gg.util.Bound(x0, y0, x0 + w, y0 + h);
    };

    Container.prototype.yAxisC = function() {
      var h, w, x0, y0;
      x0 = 0;
      y0 = this.labelHeight * this.bXFacet + this.upad;
      w = this.yAxisW * this.bYAxis;
      h = this.c.h() - this.upad - this.bpad;
      return new gg.util.Bound(x0, y0, x0 + w, y0 + h);
    };

    return Container;

  })();

  gg.geom.reparam.Bin2D = (function(_super) {

    __extends(Bin2D, _super);

    function Bin2D() {
      return Bin2D.__super__.constructor.apply(this, arguments);
    }

    Bin2D.ggpackage = "gg.geom.reparam.Bin2d";

    Bin2D.prototype.inputSchema = function() {
      return ['x', 'y'];
    };

    Bin2D.prototype.compute = function(pairtable, params) {
      var h, mapping, md, padding, scales, table, w, xscale, yscale, _ref, _ref1;
      table = pairtable.left();
      md = pairtable.right();
      scales = md.any('scales');
      yscale = scales.scale('y');
      xscale = scales.scale('x');
      padding = 1.0 - params.get('padding');
      if ((_ref = xscale.type) === data.Schema.ordinal || _ref === data.Schema.object) {
        w = xscale.range()[1] - xscale.range()[0];
      } else {
        w = this.getRectDiff(table, xscale, 'x', padding);
      }
      if ((_ref1 = yscale.type) === data.Schema.ordinal || _ref1 === data.Schema.object) {
        h = yscale.range()[1] - yscale.range()[0];
      } else {
        h = this.getRectDiff(table, yscale, 'y', padding);
      }
      mapping = [
        {
          alias: 'x0',
          f: function(x0, x) {
            if (x0 != null) {
              return x0;
            } else {
              return x - w / 2.0;
            }
          },
          type: data.Schema.numeric,
          cols: ['x0', 'x']
        }, {
          alias: 'x1',
          f: function(x1, x) {
            if (x1 != null) {
              return x1;
            } else {
              return x + w / 2.0;
            }
          },
          type: data.Schema.numeric,
          cols: ['x1', 'x']
        }, {
          alias: 'y0',
          f: function(y0, y) {
            if (y0 != null) {
              return y0;
            } else {
              return y - h / 2.0;
            }
          },
          type: data.Schema.numeric,
          cols: ['y0', 'y']
        }, {
          alias: 'y1',
          f: function(y1, y) {
            if (y1 != null) {
              return y1;
            } else {
              return y + h / 2.0;
            }
          },
          type: data.Schema.numeric,
          cols: ['y1', 'y']
        }, {
          alias: 'fill',
          f: function(z, fill) {
            if (fill != null) {
              return fill;
            } else {
              return z;
            }
          },
          cols: ['z', 'fill'],
          type: data.Schema.numeric
        }
      ];
      table = table.project(mapping, true);
      pairtable.left(table);
      return pairtable;
    };

    Bin2D.prototype.getRectDiff = function(table, scale, col, padding) {
      var diff, groups;
      if (padding == null) {
        padding = 1;
      }
      groups = table.partition(['facet-x', 'facet-y', 'group', 'layer']);
      diff = scale.range()[1] - scale.range()[0];
      groups.each(function(row) {
        var curdiff, diffs, mindiff, vals;
        vals = row.get('table').all(col);
        vals = _.uniq(vals).sort(d3.ascending);
        diffs = _.times(vals.length - 1, function(idx) {
          return vals[idx + 1] - vals[idx];
        });
        if (!(diffs.length > 0)) {
          return;
        }
        mindiff = _.mmin(diffs) || 1;
        mindiff *= padding;
        curdiff = Math.max(1, mindiff);
        if (diff == null) {
          diff = curdiff;
        }
        return diff = Math.min(diff, curdiff);
      });
      return diff;
    };

    return Bin2D;

  })(gg.geom.reparam.Rect);

  gg.facet.grid.PaneGrid = (function() {

    function PaneGrid(xs, ys, opts) {
      var labelHeight, nxs, nys, padding, showXAxis, showXFacet, showYAxis, showYFacet, xAxisW, yAxisW,
        _this = this;
      this.xs = xs;
      this.ys = ys;
      showXFacet = opts.showXFacet;
      showYFacet = opts.showYFacet;
      showXAxis = opts.showXAxis;
      showYAxis = opts.showYAxis;
      labelHeight = opts.labelHeight;
      yAxisW = opts.yAxisW;
      xAxisW = opts.xAxisW;
      padding = opts.padding;
      nxs = this.xs.length;
      nys = this.ys.length;
      opts = {
        labelHeight: labelHeight,
        yAxisW: yAxisW,
        xAxisW: xAxisW,
        padding: padding
      };
      this.grid = _.map(this.xs, function(x, xidx) {
        return _.map(_this.ys, function(y, yidx) {
          var bXAxis, bXFacet, bYAxis, bYFacet;
          bXFacet = showXFacet && yidx === 0;
          bYFacet = showYFacet && xidx >= nxs - 1;
          bXAxis = showXAxis && yidx >= nys - 1;
          bYAxis = showYAxis && xidx === 0;
          return new gg.facet.pane.Container(gg.util.Bound.empty(), xidx, yidx, x, y, bXFacet, bYFacet, bXAxis, bYAxis, opts);
        });
      });
    }

    PaneGrid.prototype.getByIdx = function(xidx, yidx) {
      return this.grid[xidx][yidx];
    };

    PaneGrid.prototype.getByVal = function(x, y) {
      var xidx, yidx;
      xidx = _.indexOf(this.xs, x);
      yidx = _.indexOf(this.ys, y);
      return this.getByIdx(xidx, yidx);
    };

    PaneGrid.prototype.xPrefix = function(xidx, yidx) {
      var _this = this;
      return _.times(xidx, function(i) {
        return _this.grid[i][yidx];
      });
    };

    PaneGrid.prototype.yPrefix = function(xidx, yidx) {
      var _this = this;
      return _.times(yidx, function(i) {
        return _this.grid[xidx][i];
      });
    };

    PaneGrid.prototype.each = function(f) {
      var ret,
        _this = this;
      ret = _.map(this.grid, function(o, xidx) {
        return _.map(o, function(pane, yidx) {
          return f(pane, xidx, yidx, _this.xs[xidx], _this.ys[yidx]);
        });
      });
      return _.flatten(ret);
    };

    PaneGrid.prototype.layout = function(w, h) {
      var nonPaneH, nonPaneHs, nonPaneW, nonPaneWs, paneH, paneW,
        _this = this;
      nonPaneWs = _.times(this.ys.length, function() {
        return 0;
      });
      nonPaneHs = _.times(this.xs.length, function() {
        return 0;
      });
      this.each(function(pane, xidx, yidx, x, y) {
        var dx, dy;
        dx = pane.labelHeight * pane.bYFacet + pane.yAxisW * pane.bYAxis;
        dy = pane.labelHeight * (pane.bXFacet + pane.bXAxis);
        nonPaneWs[yidx] += dx;
        return nonPaneHs[xidx] += dy;
      });
      nonPaneW = _.mmax(nonPaneWs);
      nonPaneH = _.mmax(nonPaneHs);
      this.paneH = paneH = (h - nonPaneH) / this.ys.length;
      this.paneW = paneW = (w - nonPaneW) / this.xs.length;
      return this.each(function(pane, xidx, yidx, x, y) {
        var dx, dy;
        pane.c.x1 = paneW;
        pane.c.y1 = paneH;
        dx = _.sum(_.map(_this.xPrefix(xidx, yidx), function(pane) {
          return pane.w();
        }));
        dy = _.sum(_.map(_this.yPrefix(xidx, yidx), function(pane) {
          return pane.h();
        }));
        pane.c.d(dx, dy);
        return pane.c.d(pane.yAxisC().w(), pane.xFacetC().h());
      });
    };

    return PaneGrid;

  })();

  gg.scale.train.Pixel = (function(_super) {

    __extends(Pixel, _super);

    function Pixel() {
      return Pixel.__super__.constructor.apply(this, arguments);
    }

    Pixel.ggpackage = "gg.scale.train.Pixel";

    Pixel.prototype.compute = function(pairtable, params) {
      return gg.scale.train.Pixel.train(pairtable, params, this.log);
    };

    Pixel.train = function(pairtable, params, log) {
      var col, cols, d, getrange, getscale, left, md, p, partitions, posMapping, range, ranges, s, scales, set, vals, xycol, _i, _j, _len, _len1;
      partitions = pairtable.fullPartition();
      scales = {};
      ranges = {};
      getscale = function(col, scale) {
        var type;
        type = scale.type;
        if (!(col in scales)) {
          scales[col] = {};
        }
        if (!(type in scales[col])) {
          scales[col][type] = scale.clone();
          scales[col][type].resetDomain();
        }
        return scales[col][type];
      };
      getrange = function(col, type) {
        if (!(col in ranges)) {
          ranges[col] = {};
        }
        if (!(type in ranges[col])) {
          ranges[col][type] = [Infinity, -Infinity];
        }
        return ranges[col][type];
      };
      for (_i = 0, _len = partitions.length; _i < _len; _i++) {
        p = partitions[_i];
        left = p.left();
        md = p.right();
        posMapping = md.any('posMapping');
        set = md.any('scales');
        cols = _.filter(left.cols(), function(col) {
          var _ref;
          return _ref = posMapping[col] || col, __indexOf.call(gg.scale.Scale.xys, _ref) >= 0;
        });
        console.log("colprov x1 = " + (left.colProv('x1')));
        for (_j = 0, _len1 = cols.length; _j < _len1; _j++) {
          col = cols[_j];
          s = set.get(col, null, posMapping);
          if (s.frozen) {
            continue;
          }
          xycol = posMapping[col] || col;
          switch (s.type) {
            case data.Schema.ordinal:
            case data.Schema.object:
              vals = left.all(col);
              range = getrange(xycol, s.type);
              range[0] = Math.min(range[0], _.mmin(vals));
              range[1] = Math.max(range[1], _.mmax(vals));
              break;
            case data.Schema.numeric:
            case data.Schema.date:
              vals = left.all(col);
              console.log(s.defaultDomain(vals));
              d = _.map(s.defaultDomain(vals), function(v) {
                if (_.isValid(v)) {
                  return s.invert(v);
                } else {
                  return null;
                }
              });
              if (_.all(d, _.isValid)) {
                getscale(xycol, s).mergeDomain(d);
              }
          }
        }
      }
      partitions = _.map(partitions, function(p) {
        var mappings, oldset, right;
        left = p.left();
        right = p.right();
        posMapping = right.any('posMapping');
        set = right.any('scales');
        oldset = set.clone();
        cols = _.filter(left.cols(), function(col) {
          var _ref;
          return _ref = posMapping[col] || col, __indexOf.call(gg.scale.Scale.xys, _ref) >= 0;
        });
        mappings = _.map(cols, function(col) {
          var f, newrange, newsize, oldrange, oldscale, oldsize, ratio, resize;
          s = set.get(col, null, posMapping);
          oldscale = oldset.get(col, null, posMapping);
          if (s.frozen) {
            console.log("skipping " + col + " in layer " + (right.any('layer')) + " because its frozen");
            return;
          }
          xycol = posMapping[col] || col;
          f = (function() {
            switch (s.type) {
              case data.Schema.ordinal:
              case data.Schema.object:
                newrange = getrange(xycol, s.type);
                oldrange = [_.mmin(oldscale.range()), _.mmax(oldscale.range())];
                newsize = newrange[1] - newrange[0];
                oldsize = oldrange[1] - oldrange[0];
                if (newsize > oldsize) {
                  ratio = oldsize / newsize;
                  resize = (oldsize - oldsize * ratio) / 2;
                  newrange = [oldrange[0] + resize, oldrange[1] - resize];
                  return (function(col, s, ratio, resize) {
                    return function(v) {
                      return v;
                    };
                  })(col, s, ratio, resize);
                }
                break;
              case data.Schema.numeric:
              case data.Schema.date:
                s.domain(getscale(xycol, s).domain());
                return (function(col, s, oldscale) {
                  return function(v) {
                    return s.scale(oldscale.invert(v));
                  };
                })(col, s, oldscale);
            }
          })();
          if (f != null) {
            return {
              alias: col,
              cols: col,
              f: f,
              type: s.type
            };
          }
        });
        left = left.project(mappings, true);
        p.left(left);
        return p;
      });
      return data.PairTable.union(partitions);
    };

    return Pixel;

  })(gg.core.BForm);

  gg.scale.train.Master = (function(_super) {

    __extends(Master, _super);

    function Master() {
      return Master.__super__.constructor.apply(this, arguments);
    }

    Master.ggpackage = "gg.scale.train.Master";

    Master.prototype.parseSpec = function() {
      Master.__super__.parseSpec.apply(this, arguments);
      return this.params.ensure('scalesTrain', [], 'fixed');
    };

    Master.prototype.compute = function(pairtable, params) {
      return gg.scale.train.Master.train(pairtable, params);
    };

    Master.train = function(pairtable, params) {
      var masterSet, md, scalesTrain, set, sets, table, _i, _len;
      scalesTrain = params.get('scalesTrain') || 'fixed';
      table = pairtable.left();
      md = pairtable.right();
      if (scalesTrain === 'fixed') {
        sets = _.uniq(md.all('scales'));
        masterSet = new gg.scale.MergedSet(sets);
        for (_i = 0, _len = sets.length; _i < _len; _i++) {
          set = sets[_i];
          set.merge(masterSet);
        }
      } else {
        md = this.trainFreeScales(md);
      }
      pairtable.right(md);
      return pairtable;
    };

    Master.trainFreeScales = function(md, xs, ys) {
      var xFacet, xscalesList, yFacet, yscalesList;
      xFacet = 'facet-x';
      yFacet = 'facet-y';
      xscalesList = {};
      md.partition(xFacet).each(function(p) {
        var key, scales;
        key = p.get(xFacet);
        scales = new gg.scale.MergedSet(p.get('table').all('scales'));
        return xscalesList[key] = scales.exclude(gg.scale.Scale.ys);
      });
      yscalesList = {};
      md.partition(yFacet).each(function(p) {
        var key, scales;
        key = p.get(yFacet);
        scales = new gg.scale.MergedSet(p.get('table').all('scales'));
        return yscalesList[key] = scales.exclude(gg.scale.Scale.xs);
      });
      md.distinct(xFacet, yFacet).each(function(row) {
        var set, x, y, _i, _len, _ref, _results;
        x = row.get(xFacet);
        y = row.get(yFacet);
        _ref = row.get('scales');
        _results = [];
        for (_i = 0, _len = _ref.length; _i < _len; _i++) {
          set = _ref[_i];
          set.merge(xscalesList[x]);
          _results.push(set.merge(yscalesList[y]));
        }
        return _results;
      });
      return md;
    };

    Master.prototype.expandDomains = function(scalesSet) {
      var _this = this;
      return scalesSet;
      return _.each(scalesSet.scalesList(), function(scale) {
        var extra, maxd, mind, _ref;
        if (scale.type !== data.Schema.numeric) {
          return;
        }
        _ref = scale.domain(), mind = _ref[0], maxd = _ref[1];
        extra = mind === maxd ? 1 : Math.abs(maxd - mind) * 0.05;
        mind = mind - extra;
        maxd = maxd + extra;
        return scale.domain([mind, maxd]);
      });
    };

    return Master;

  })(gg.core.BForm);

  gg.scale.train.Data = (function(_super) {

    __extends(Data, _super);

    function Data() {
      return Data.__super__.constructor.apply(this, arguments);
    }

    Data.ggpackage = "gg.scale.train.Data";

    Data.prototype.compute = function(pairtable, params) {
      return gg.scale.train.Data.train(pairtable, params, this.log);
    };

    Data.train = function(pairtable, params, log) {
      var md, p, partitions, table, _i, _len;
      if (log == null) {
        log = console.log;
      }
      partitions = pairtable.partition(['facet-x', 'facet-y', 'layer']);
      for (_i = 0, _len = partitions.length; _i < _len; _i++) {
        p = partitions[_i];
        table = p.left();
        md = p.right();
        md.each(function(row) {
          return row.get('scales').train(table, row.get('posMapping'));
        });
      }
      pairtable = data.PairTable.union(partitions);
      pairtable = gg.scale.train.Master.train(pairtable, params);
      return pairtable;
    };

    return Data;

  })(gg.core.BForm);

  gg.scale.Scales = (function() {

    Scales.ggpackage = "gg.scale.Scales";

    function Scales(g) {
      this.g = g;
      this.scalesConfig = gg.scale.Config.fromSpec({});
      this.mappings = {};
      this.scalesList = [];
      this.prestats = new gg.scale.train.Data({
        name: 'scales-prestats',
        params: {
          config: this.scalesConfig
        }
      }).compile();
      this.postgeommap = new gg.scale.train.Data({
        name: 'scales-postgeommap',
        params: {
          config: this.scalesConfig
        }
      }).compile();
      this.facets = new gg.scale.train.Master({
        name: 'scales-facet'
      }).compile();
      this.pixel = new gg.scale.train.Pixel({
        name: 'scales-pixel',
        params: {
          scaleTrain: this.g.facets.scales,
          config: this.scalesConfig
        }
      }).compile();
      this.log = gg.util.Log.logger(this.ggpackage, "scales");
      this.log.level = gg.util.Log.DEBUG;
    }

    Scales.prototype.scales = function(facetX, facetY, layerIdx) {
      if (facetX == null) {
        facetX = null;
      }
      if (facetY == null) {
        facetY = null;
      }
      if (layerIdx == null) {
        layerIdx = null;
      }
      throw Error("scales.scales not implemented");
    };

    return Scales;

  })();

  gg.pos.Position = (function() {

    function Position() {}

    Position.ggpackage = "gg.pos.Position";

    Position.klasses = function() {
      var klasses, ret;
      klasses = _.compact([gg.pos.Identity, gg.pos.Shift, gg.pos.Jitter, gg.pos.Stack, gg.pos.Dodge, gg.pos.Text, gg.pos.Bin2D, gg.pos.DotPlot]);
      ret = {};
      _.each(klasses, function(klass) {
        var alias, _i, _len, _ref, _results;
        _ref = _.flatten([klass.aliases]);
        _results = [];
        for (_i = 0, _len = _ref.length; _i < _len; _i++) {
          alias = _ref[_i];
          _results.push(ret[alias] = klass);
        }
        return _results;
      });
      return ret;
    };

    Position.fromSpec = function(spec) {
      var klass, klasses, o;
      klasses = gg.pos.Position.klasses();
      klass = klasses[spec.type];
      o = new klass(spec);
      if (_.isType(o, gg.pos.Identity)) {
        return null;
      }
      return o;
    };

    return Position;

  })();

  gg.layer.Layer = (function() {

    Layer.ggpackage = "gg.layer.Layer";

    Layer.id = function() {
      return gg.wf.Node.prototype._id += 1;
    };

    Layer.prototype._id = 0;

    function Layer(g, spec) {
      this.g = g;
      this.spec = spec != null ? spec : {};
      if (this.spec.layerIdx != null) {
        this.layerIdx = this.spec.layerIdx;
      }
      this.log = gg.util.Log.logger(this.constructor.ggpackage, "Layer-" + this.layerIdx);
      this.parseSpec();
    }

    Layer.prototype.parseSpec = function() {};

    Layer.fromSpec = function(g, spec) {
      if (_.isArray(spec)) {
        throw Error("layer currently only supports shorthand style");
        return new gg.layer.Array(g, spec);
      } else {
        return new gg.layer.Shorthand(g, spec);
      }
    };

    return Layer;

  })();

  gg.layer.Shorthand = (function(_super) {

    __extends(Shorthand, _super);

    Shorthand.ggpackage = "gg.layer.Shorthand";

    function Shorthand(g, spec) {
      this.g = g;
      this.spec = spec != null ? spec : {};
      Shorthand.__super__.constructor.apply(this, arguments);
      this.type = "layershort";
      this.log = gg.util.Log.logger(this.constructor.ggpackage, "Layer-" + this.layerIdx);
    }

    Shorthand.prototype.parseSpec = function() {
      this.setupGeom();
      this.setupStats();
      this.setupPos();
      this.setupMap();
      this.setupCoord();
      return Shorthand.__super__.parseSpec.apply(this, arguments);
    };

    Shorthand.prototype.setupGeom = function() {
      this.geomSpec = this.spec.geom;
      this.geomSpec.name = "" + this.geomSpec.name + "-" + this.layerIdx;
      return this.geom = gg.geom.Geom.fromSpec(this, this.geomSpec);
    };

    Shorthand.prototype.setupStats = function() {
      var _this = this;
      this.statSpec = this.spec.stat;
      this.statSpec = _.flatten([this.statSpec]);
      this.stats = _.map(this.statSpec, function(subSpec, idx) {
        subSpec.name = "stat-" + subSpec.type + "-" + _this.layerIdx;
        return gg.stat.Stat.fromSpec(subSpec);
      });
      return this.stats;
    };

    Shorthand.prototype.setupPos = function() {
      var _this = this;
      this.posSpec = this.spec.pos;
      this.posSpec = _.flatten([this.posSpec]);
      this.pos = _.map(this.posSpec, function(subSpec) {
        subSpec.name = "pos-" + subSpec.type + "-" + _this.layerIdx;
        return gg.pos.Position.fromSpec(subSpec);
      });
      return this.pos;
    };

    Shorthand.prototype.setupMap = function() {
      var aes;
      console.log(this.spec);
      aes = this.spec.aes;
      this.group = gg.xform.Mapper.groupSpec(aes);
      if (!('group' in aes)) {
        aes.group = this.group.group;
      }
      this.detectscales = new gg.xform.DetectScales({
        name: "detectscales",
        params: {
          aes: aes
        }
      });
      this.mapSpec = {
        aes: aes,
        name: "map-shorthand-" + this.layerIdx
      };
      return this.map = gg.xform.Mapper.fromSpec(this.mapSpec);
    };

    Shorthand.prototype.setupCoord = function() {
      this.coordSpec = this.spec.coord;
      this.coordSpec.name = "coord-" + this.layerIdx;
      return this.coord = gg.coord.Coordinate.fromSpec(this.coordSpec);
    };

    Shorthand.prototype.makeStdOut = function(name, params) {
      var arg;
      arg = _.clone(params);
      params = {
        n: 5,
        cols: ['layer', 'group', 'fill', 'x', 'y']
      };
      _.extend(params, arg);
      return new gg.wf.Stdout({
        name: "" + name + "-" + this.layerIdx,
        params: params
      });
    };

    Shorthand.prototype.makeScalesOut = function(name) {
      return new gg.wf.Scales({
        name: "" + name + "-" + this.layerIdx
      });
    };

    Shorthand.prototype.makeEnvSetup = function() {
      return gg.wf.SyncBlock.create((function(pt, params) {
        var layerIdx, md, posMapping, t, _ref;
        _ref = [pt.left(), pt.right()], t = _ref[0], md = _ref[1];
        layerIdx = params.get('layer');
        posMapping = params.get('posMapping');
        t = t.setColVal('layer', layerIdx);
        md = md.setColVal('layer', layerIdx);
        md = md.setColVal('posMapping', posMapping);
        return new data.PairTable(t, md);
      }), {
        layer: this.layerIdx,
        posMapping: this.geom.posMapping()
      }, 'layer-labeler');
    };

    Shorthand.prototype.compile = function() {
      var nodes;
      this.log("compile()");
      nodes = [];
      nodes.push(this.compileSetup());
      nodes.push(this.compileStats());
      nodes.push(this.compileGeomMap());
      nodes.push(new gg.xform.ScalesValidate({
        name: 'scales-validate'
      }));
      nodes.push(this.compileInitialLayout());
      nodes.push(this.compileGeomReparam());
      nodes.push(this.compileGeomPos());
      nodes.push(this.compileCoord());
      nodes.push(this.compileRender());
      nodes = this.compileNodes(nodes);
      return nodes;
    };

    Shorthand.prototype.compileSetup = function() {
      return [
        this.makeEnvSetup(), this.map, this.detectscales, new gg.xform.ScalesSchema({
          name: "scales-schema-" + this.layerIdx,
          params: {
            config: this.g.scales.scalesConfig
          }
        }), this.g.facets.labeler
      ];
    };

    Shorthand.prototype.compileStats = function() {
      return [
        this.g.scales.prestats, new gg.xform.ScalesFilter({
          name: "scalesfilter-" + this.layerIdx,
          params: {
            posMapping: this.geom.posMapping(),
            config: this.g.scales.scalesConfig
          }
        }), this.makeStdOut("post-scalefilter-" + this.layerIdx), this.makeScalesOut("pre-stat-" + this.layerIdx), this.stats
      ];
    };

    Shorthand.prototype.compileGeomMap = function() {
      return [this.geom.map, this.g.scales.postgeommap, this.makeStdOut("post-geommaptrain"), this.makeScalesOut("post-geommaptrain")];
    };

    Shorthand.prototype.compileInitialLayout = function() {
      return [
        this.g.layoutNode, this.g.facets.layout1, this.g.facets.trainer, this.makeScalesOut("pre-scaleapply"), new gg.xform.ScalesApply({
          name: "scalesapply-" + this.layerIdx,
          params: {
            posMapping: this.geom.posMapping()
          }
        }), this.makeStdOut("post-scaleapply")
      ];
    };

    Shorthand.prototype.compileGeomReparam = function() {
      return [this.geom.reparam, this.makeStdOut("post-reparam")];
    };

    Shorthand.prototype.compileGeomPos = function() {
      var nodes;
      nodes = [];
      if (this.pos.length > 0) {
        nodes = nodes.concat([this.pos, this.makeStdOut("post-position")]);
      }
      nodes = nodes.concat([this.g.scales.pixel, this.makeStdOut("post-pixeltrain")]);
      return nodes;
    };

    Shorthand.prototype.compileCoord = function() {
      return [this.makeScalesOut("pre-coord"), this.coord, this.makeStdOut("post-coord")];
    };

    Shorthand.prototype.compileRender = function() {
      return [
        this.g.renderNode, this.g.facets.render, this.g.facets.renderPanes(), this.makeStdOut("pre-render", {
          location: "client"
        }), this.geom.render
      ];
    };

    Shorthand.prototype.compileNodes = function(nodes) {
      nodes = _.map(_.compact(_.flatten(nodes)), function(node) {
        if (node.compile != null) {
          return node.compile();
        } else {
          return node;
        }
      });
      return _.compact(_.flatten(nodes));
    };

    return Shorthand;

  })(gg.layer.Layer);

  gg.wf.rule.Rule = (function() {

    Rule.ggpackage = "gg.wf.rule.Rule";

    function Rule(spec) {
      if (spec == null) {
        spec = {};
      }
      this.params = spec.params || {};
      this.params = new gg.util.Params(this.params);
      this.log = gg.util.Log.logger(this.constructor.ggpackage, "rule");
    }

    Rule.prototype.run = function(flow) {
      return flow;
    };

    Rule.validateReplacement = function(orig, news) {
      var origClass, typeToClass;
      if (!(news.length > 0)) {
        return true;
      }
      typeToClass = function(type) {
        switch (type) {
          case "barrier":
            return "barrier";
          case "multicast":
            return "multicast";
          default:
            return "normal";
        }
      };
      origClass = typeToClass(orig);
      return _.all(news, function(n) {
        return typeToClass(n) === origClass;
      });
    };

    Rule.replace = function(flow, node, replacements) {
      var bcs, bps, cs, cur, lastnonbarrier, pre, prev, ps, _i, _j, _len, _len1,
        _this = this;
      replacements = _.compact(_.flatten([replacements]));
      if (!this.validateReplacement(node, replacements)) {
        throw Error("Rule replacement types don't match.        Expected " + node.type + ", got " + (_.map(replacements(function(r) {
          return r.type;
        }))));
      }
      if (replacements.length === 1 && replacements[0] === node) {
        return;
      }
      cs = flow.children(node);
      bcs = flow.bridgedChildren(node);
      ps = flow.parents(node);
      bps = flow.bridgedParents(node);
      flow.rm(node);
      cur = prev = null;
      lastnonbarrier = null;
      for (_i = 0, _len = replacements.length; _i < _len; _i++) {
        cur = replacements[_i];
        if (prev != null) {
          flow.connect(prev, cur);
        } else {
          _.each(ps, function(p) {
            return flow.connect(p, cur);
          });
          _.each(bps, function(p) {
            return flow.connectBridge(p, cur);
          });
        }
        if (cur.type !== "barrier") {
          lastnonbarrier = cur;
        }
        prev = cur;
      }
      if (lastnonbarrier != null) {
        _.each(cs, function(c) {
          return flow.connect(cur, c);
        });
        _.each(bcs, function(c) {
          return flow.connectBridge(cur, c);
        });
      }
      prev = null;
      for (_j = 0, _len1 = replacements.length; _j < _len1; _j++) {
        cur = replacements[_j];
        if (cur.type !== "barrier") {
          if (prev != null) {
            flow.connectBridge(prev, cur);
          }
          pre = cur;
        }
      }
      return flow;
    };

    return Rule;

  })();

  gg.core.Options = (function() {

    function Options(spec) {
      this.spec = spec != null ? spec : {};
      this.width = _.findGood([this.spec.width, this.spec.w, 800]);
      this.height = _.findGood([this.spec.height, this.spec.h, 600]);
      this.w = this.width;
      this.h = this.height;
      this.title = _.findGood([this.spec.title, null]);
      this.xaxis = _.findGood([this.spec.xaxis, this.spec.x, "xaxis"]);
      this.yaxis = _.findGood([this.spec.yaxis, this.spec.y, "yaxis"]);
      this.minimal = _.findGood([this.spec.minimal, false]);
      this.optimize = _.findGood([this.spec.optimize, true]);
      this.guid = _.findGood([this.spec.guid, this.spec.name, null]);
      this.serverURI = _.findGood([this.spec.server, this.spec.uri, "http://localhost:8001"]);
    }

    Options.prototype.clone = function() {
      return new gg.core.Options(_.clone(this.spec));
    };

    return Options;

  })();

  gg.wf.Block = (function(_super) {

    __extends(Block, _super);

    function Block() {
      return Block.__super__.constructor.apply(this, arguments);
    }

    Block.ggpackage = "gg.wf.Block";

    Block.type = "block";

    Block.prototype.compute = function(pairtable, params, cb) {
      return cb(null, pairtable);
    };

    Block.prototype.run = function() {
      var compute, params,
        _this = this;
      if (!this.ready()) {
        throw Error("node not ready");
      }
      params = this.params;
      compute = this.params.get('compute') || this.compute.bind(this);
      return compute(this.inputs[0], params, function(err, pairtable) {
        if (err != null) {
          throw Error(err);
        }
        return _this.output(0, pairtable);
      });
    };

    return Block;

  })(gg.wf.Node);

  gg.wf.SyncBlock = (function(_super) {

    __extends(SyncBlock, _super);

    function SyncBlock() {
      return SyncBlock.__super__.constructor.apply(this, arguments);
    }

    SyncBlock.prototype.parseSpec = function() {
      var compute, f, name;
      SyncBlock.__super__.parseSpec.apply(this, arguments);
      name = this.name;
      f = this.params.get('compute');
      if (f == null) {
        f = this.compute.bind(this);
      }
      compute = function(pairtable, params, cb) {
        var res;
        try {
          res = f(pairtable, params, function() {
            throw Error("SyncBlock should not call callcack");
          });
          return cb(null, res);
        } catch (err) {
          console.log("error in syncblock " + name);
          console.log(err.stack);
          return cb(err, null);
        }
      };
      return this.params.put('compute', compute);
    };

    SyncBlock.prototype.compute = function(pairtable, params, cb) {
      return pairtable;
    };

    return SyncBlock;

  })(gg.wf.Block);

  gg.wf.Cache = (function(_super) {

    __extends(Cache, _super);

    function Cache() {
      return Cache.__super__.constructor.apply(this, arguments);
    }

    Cache.ggpackage = "gg.wf.Cache";

    Cache.prototype.parseSpec = function() {
      Cache.__super__.parseSpec.apply(this, arguments);
      if (!this.params.has("guid")) {
        throw Error("cacher requires a guid!");
      }
    };

    Cache.getDB = function() {
      if (typeof window === "undefined" || window === null) {
        return null;
      }
      if (window.localStorage == null) {
        return null;
      }
      return window.localStorage;
    };

    Cache.prototype.run = function() {
      var db, guid, idx, pairtable, _i, _j, _len, _len1, _ref, _ref1, _results;
      if (!this.ready()) {
        throw Error("node not ready");
      }
      guid = this.params.get('guid');
      db = gg.wf.Cache.getDB();
      if (db == null) {
        throw Error("Cache cannot run without a DB");
      }
      try {
        this.trySave(guid);
      } catch (err) {
        this.log.warn("error storing. try clear db and save again: " + err.message);
        try {
          db.clear();
          this.trySave(guid);
          this.log.warn("success!");
        } catch (err) {
          this.log.warn("save failed second time. aborting " + err.message);
          _ref = this.inputs;
          for (idx = _i = 0, _len = _ref.length; _i < _len; idx = ++_i) {
            pairtable = _ref[idx];
            delete db["" + guid + "-" + idx + "-table"];
            delete db["" + guid + "-" + idx + "-md"];
          }
          delete db[guid];
          this.log.warn("done aborting");
        }
      }
      _ref1 = this.inputs;
      _results = [];
      for (idx = _j = 0, _len1 = _ref1.length; _j < _len1; idx = ++_j) {
        pairtable = _ref1[idx];
        _results.push(this.output(idx, pairtable));
      }
      return _results;
    };

    Cache.prototype.trySave = function(guid) {
      var db, idx, key, md, mdstr, pairtable, t, tstr, _i, _len, _ref, _ref1, _results;
      db = gg.wf.Cache.getDB();
      db[guid] = this.inputs.length;
      _ref = this.inputs;
      _results = [];
      for (idx = _i = 0, _len = _ref.length; _i < _len; idx = ++_i) {
        pairtable = _ref[idx];
        key = "" + guid + "-" + idx;
        _ref1 = [pairtable.left(), pairtable.right()], t = _ref1[0], md = _ref1[1];
        tstr = t.serialize();
        md = md.clone();
        if (md.has('svg')) {
          md.rmColumn('svg');
        }
        mdstr = md.serialize();
        db["" + key + "-table"] = tstr;
        _results.push(db["" + key + "-md"] = mdstr);
      }
      return _results;
    };

    return Cache;

  })(gg.wf.Node);

  gg.wf.ClearingHouse = (function(_super) {

    __extends(ClearingHouse, _super);

    ClearingHouse.ggpackage = "gg.wf.ClearingHouse";

    function ClearingHouse(runner, xferControl) {
      this.runner = runner;
      this.xferControl = xferControl;
      this.flow = this.runner.flow;
      this.log = gg.util.Log.logger(this.constructor.ggpackage, "clearhouse");
      if (this.xferControl == null) {
        this.xferControl = this.routeNodeResult.bind(this);
      }
    }

    ClearingHouse.prototype.push = function(nodeid, outport, outputs) {
      var node;
      this.runner.setDone(nodeid);
      node = this.flow.nodeFromId(nodeid);
      this.log("push: " + node.name + " " + nodeid + "(" + outport + ")");
      if (this.isSink(nodeid)) {
        this.log("sink node: " + node.name + " " + nodeid);
        return this.emit("output", nodeid, outport, outputs);
      } else if (this.clientToServer(nodeid, outport)) {
        return this.xferControl(nodeid, outport, outputs);
      } else if (this.serverToClient(nodeid, outport)) {
        return this.xferControl(nodeid, outport, outputs);
      } else {
        return this.routeNodeResult(nodeid, outport, outputs);
      }
    };

    ClearingHouse.prototype.clientToServer = function(nodeid, outport) {
      var child, children, inport, node, o;
      node = this.flow.nodeFromId(nodeid);
      this.log("clienttoserver: " + [node.name, nodeid, outport, node.location]);
      if (node.location !== "client") {
        return false;
      }
      children = this.flow.portGraph.children({
        n: node,
        p: outport
      });
      if (children.length === 0) {
        throw Error("node " + nodeid + " with port " + outport + " has no children in Port Graph");
      }
      o = children[0];
      child = o.n;
      inport = o.p;
      this.log("clienttoserver: child: " + child.name + " " + child.location);
      return child.location === "server";
    };

    ClearingHouse.prototype.serverToClient = function(nodeid, outport) {
      var child, children, inport, node, o;
      node = this.flow.nodeFromId(nodeid);
      this.log("servertoclient: " + [node.name, nodeid, outport, node.location]);
      if (node.location !== "server") {
        return false;
      }
      children = this.flow.portGraph.children({
        n: node,
        p: outport
      });
      o = children[0];
      child = o.n;
      inport = o.p;
      this.log("servertoclient: " + [node.name, nodeid, outport, node.location]);
      this.log("servertoclient: child: " + child.name + " " + child.location);
      return child.location === "client";
    };

    ClearingHouse.prototype.isSink = function(nodeid) {
      return __indexOf.call(_.map(this.flow.sinks(), function(sink) {
        return sink.id;
      }), nodeid) >= 0;
    };

    ClearingHouse.prototype.routeNodeResult = function(nodeid, outport, input) {
      var child, children, inport, node, o;
      node = this.flow.nodeFromId(nodeid);
      children = this.flow.portGraph.children({
        n: node,
        p: outport
      });
      if (children.length !== 1) {
        throw Error("children should only be 1");
      }
      o = children[0];
      child = o.n;
      inport = o.p;
      this.log("setInput " + node.name + ":" + outport + " ->          " + child.name + ":" + inport + " " + child.location);
      child.setInput(inport, input);
      if (child.ready()) {
        this.log("\t" + child.name + " adding");
        return this.runner.tryRun(child);
      } else {
        return this.log("\t" + child.name + " not ready        " + (child.nReady()) + " of " + child.nParents + " ready");
      }
    };

    return ClearingHouse;

  })(events.EventEmitter);

  gg.wf.Multicast = (function(_super) {

    __extends(Multicast, _super);

    function Multicast() {
      return Multicast.__super__.constructor.apply(this, arguments);
    }

    Multicast.ggpackage = "gg.wf.Multicast";

    Multicast.type = "multicast";

    Multicast.prototype.run = function() {
      var idx, pairtable, _i, _ref, _results;
      if (!this.ready()) {
        throw Error("Node not ready");
      }
      pairtable = this.inputs[0];
      _results = [];
      for (idx = _i = 0, _ref = this.nChildren; 0 <= _ref ? _i < _ref : _i > _ref; idx = 0 <= _ref ? ++_i : --_i) {
        _results.push(this.output(idx, new data.PairTable(pairtable.left(), pairtable.right())));
      }
      return _results;
    };

    return Multicast;

  })(gg.wf.Node);

  gg.wf.NoCopyMulticast = (function(_super) {

    __extends(NoCopyMulticast, _super);

    function NoCopyMulticast() {
      return NoCopyMulticast.__super__.constructor.apply(this, arguments);
    }

    NoCopyMulticast.ggpackage = "gg.wf.NoCopyMulticast";

    NoCopyMulticast.type = "nc-multicast";

    NoCopyMulticast.prototype.run = function() {
      var idx, pairtable, _i, _ref, _results;
      if (!this.ready()) {
        throw Error("Node not ready");
      }
      pairtable = this.inputs[0];
      _results = [];
      for (idx = _i = 0, _ref = this.nChildren; 0 <= _ref ? _i < _ref : _i > _ref; idx = 0 <= _ref ? ++_i : --_i) {
        _results.push(this.output(idx, pairtable));
      }
      return _results;
    };

    return NoCopyMulticast;

  })(gg.wf.Node);

  gg.wf.Stdout = (function(_super) {

    __extends(Stdout, _super);

    Stdout.ggpackage = "gg.wf.Stdout";

    Stdout.type = "stdout";

    function Stdout(spec) {
      this.spec = spec;
      Stdout.__super__.constructor.apply(this, arguments);
      this.log = gg.util.Log.logger(this.constructor.ggpackage, "StdOut: " + this.name + "-" + this.id);
    }

    Stdout.prototype.parseSpec = function() {
      Stdout.__super__.parseSpec.apply(this, arguments);
      return this.params.ensureAll({
        key: [[], _.flatten([gg.facet.base.Facets.facetKeys, 'layer'])],
        n: [[], null],
        cols: [['aess'], null]
      });
    };

    Stdout.prototype.compute = function(pairtable, params) {
      var mdcols;
      mdcols = ['layer', 'facet-x', 'facet-y', 'group', 'lc'];
      gg.wf.Stdout.print(pairtable.left(), params.get('cols'), params.get('n'), this.log);
      gg.wf.Stdout.print(pairtable.right(), mdcols, params.get('n'), this.log);
      return pairtable;
    };

    Stdout.print = function(table, cols, n, log) {
      var blockSize, idx, schema;
      if (log == null) {
        log = null;
      }
      if (_.isArray(table)) {
        _.each(table, function(t) {
          return gg.wf.Stdout.print(t, cols, n, log);
        });
      }
      idx = 0;
      n = n != null ? n : table.nrows();
      blockSize = Math.max(Math.floor(table.nrows() / n), 1);
      schema = table.schema;
      if (cols == null) {
        cols = schema.cols;
      }
      if (log == null) {
        log = gg.util.Log.logger(gg.wf.Stdout.ggpackage, "stdout");
      }
      log("# rows: " + (table.nrows()));
      log("Schema: " + (schema.toString()));
      return table.each(function(row, idx) {
        var pairs;
        if ((idx % blockSize) === 0) {
          pairs = _.map(cols, function(col) {
            return [col, row.get(col)];
          });
          return log(JSON.stringify(pairs));
        }
      });
    };

    Stdout.printTables = function() {
      var args;
      args = 1 <= arguments.length ? __slice.call(arguments, 0) : [];
      return this.print.apply(this, args);
    };

    return Stdout;

  })(gg.wf.SyncBlock);

  gg.wf.Scales = (function(_super) {

    __extends(Scales, _super);

    Scales.ggpackage = "gg.wf.Scales";

    Scales.type = "scaleout";

    Scales.log = gg.util.Log.logger(Scales.ggpackage, "scalesout");

    function Scales(spec) {
      this.spec = spec;
      Scales.__super__.constructor.apply(this, arguments);
      this.log = gg.util.Log.logger(this.constructor.ggpackage, "Scales: " + this.name + "-" + this.id);
    }

    Scales.prototype.parseSpec = function() {
      Scales.__super__.parseSpec.apply(this, arguments);
      return this.params.ensureAll({
        key: [[], _.flatten([gg.facet.base.Facets.facetKeys, 'layer'])]
      });
    };

    Scales.prototype.compute = function(pairtable, params) {
      var md,
        _this = this;
      md = pairtable.right();
      md.each(function(row) {
        var layer, scale;
        layer = row.get('layer');
        scale = row.get('scales');
        return gg.wf.Scales.print(scale, layer, _this.log);
      });
      return pairtable;
    };

    Scales.print = function(scaleset, layerIdx, log) {
      if (log == null) {
        log = null;
      }
      if (log == null) {
        log = this.log;
      }
      log("scaleset " + scaleset.id + ", " + scaleset.scales);
      return _.each(scaleset.all(), function(scale) {
        return log("" + scaleset.id + " l(" + layerIdx + ") t(" + scale.type + ")\t" + (scale.toString()));
      });
    };

    return Scales;

  })(gg.wf.SyncBlock);

  gg.wf.Optimizer = (function() {

    function Optimizer(rules) {
      this.rules = rules;
      if (!_.isArray(this.rules)) {
        this.rules = [this.rules];
      }
    }

    Optimizer.prototype.run = function(flow) {
      var rule, _i, _len, _ref;
      _ref = this.rules;
      for (_i = 0, _len = _ref.length; _i < _len; _i++) {
        rule = _ref[_i];
        flow = rule.run(flow);
      }
      return flow;
    };

    return Optimizer;

  })();

  gg.wf.rpc.Util = (function() {

    function Util() {}

    Util.serialize = function(pairtable, params) {
      var clientCols, md, paramsJSON, payload, removedEls;
      md = pairtable.right();
      clientCols = ['svg', 'event'];
      removedEls = _.o2map(clientCols, function(col) {
        if (md.has(col)) {
          return [col, md.all(col)];
        }
      });
      if (clientCols.length > 0) {
        md = md.exclude(clientCols);
      }
      paramsJSON = params != null ? params.toJSON() : null;
      payload = {
        table: pairtable.left().toJSON(),
        md: pairtable.right().toJSON(),
        params: paramsJSON
      };
      return [payload, removedEls];
    };

    Util.deserialize = function(respData, removedEls) {
      var col, colData, md, table;
      if (removedEls == null) {
        removedEls = {};
      }
      table = data.Table.fromJSON(respData.table);
      md = data.Table.fromJSON(respData.md);
      for (col in removedEls) {
        colData = removedEls[col];
        if (colData.length !== md.nrows()) {
          throw Error("rpc.deserialize: data len (" + (md.nrows()) + ") !=          removedEls len (" + colData.length + ") on col " + col);
        }
        md = md.setCol(col, colData);
      }
      return new data.PairTable(table, md);
    };

    return Util;

  })();

  /*
  Send
    payload: payload
    inputSchema:
    outputSchema
    defaults
    compute
    nodewfmetadata
  */


  gg.wf.RPC = (function(_super) {

    __extends(RPC, _super);

    RPC.ggpackage = "gg.wf.Flow";

    RPC.log = gg.util.Log.logger(RPC.ggpackage, "rpc");

    RPC.id = function() {
      return gg.wf.RPC.prototype._id += 1;
    };

    RPC.prototype._id = 0;

    RPC.checkConnection = function(uri, cb, errcb) {
      var connected, onConnect, onFail, responded, socket,
        _this = this;
      responded = false;
      socket = io.connect(uri);
      connected = socket.socket.connected;
      onConnect = function() {
        if (!responded) {
          responded = true;
          cb();
        }
        _this.log("onConnect triggered: removing listeners");
        socket.removeListener("connect", onConnect);
        return socket.removeListener("error", onFail);
      };
      onFail = function() {
        if (!responded) {
          responded = true;
          errcb();
        }
        _this.log("onFail triggered: removing listeners");
        socket.removeListener("connect", onConnect);
        return socket.removeListener("error", onFail);
      };
      socket.on("connect", onConnect);
      socket.on("error", onFail);
      if (connected) {
        return onConnect();
      } else {
        return socket.socket.connect();
      }
    };

    function RPC(spec) {
      this.spec = spec;
      this.id = gg.wf.RPC.id();
      this.callid = 0;
      this.ready = false;
      this.nonce2cb = {};
      this.buffer = [];
      this.params = new gg.util.Params(this.spec.params);
      this.log = gg.util.Log.logger(this.constructor.ggpackage, "rpc");
      this.setup();
    }

    RPC.prototype.setup = function() {
      var callback, uri,
        _this = this;
      uri = this.params.get("uri") || "http://localhost:8000";
      this.socket = io.connect(uri);
      this.ready = this.socket.socket.connected;
      this.socket.on("connect", function() {
        _this.ready = true;
        return _this.flushBuffer();
      });
      this.socket.on("disconnect", function() {
        return _this.ready = false;
      });
      callback = function(respData) {
        var cb, nonce;
        _this.log("recieved response for nonce " + respData.nonce);
        nonce = respData.nonce;
        if ((nonce != null) && nonce in _this.nonce2cb) {
          cb = _this.nonce2cb[nonce];
          delete _this.nonce2cb[nonce];
          return cb(respData);
        }
      };
      this.socket.on("register", callback);
      this.socket.on("deregister", callback);
      return this.socket.on("runflow", callback);
    };

    RPC.prototype.flushBuffer = function() {
      var cb, command, nonce, payload, _ref, _results;
      _results = [];
      while (this.buffer.length > 0) {
        if (!this.ready) {
          break;
        }
        _ref = this.buffer.shift(), command = _ref[0], payload = _ref[1], cb = _ref[2];
        nonce = this.callid;
        this.callid += 1;
        if (payload == null) {
          payload = {};
        }
        payload.nonce = nonce;
        if (_.isFunction(cb)) {
          this.nonce2cb[nonce] = cb;
        }
        this.log("sending " + command + " nonce: " + nonce);
        _results.push(this.socket.emit(command, payload));
      }
      return _results;
    };

    RPC.prototype.send = function(command, payload, cb) {
      this.buffer.push([command, payload, cb]);
      return this.flushBuffer();
    };

    RPC.prototype.register = function(flow, cb) {
      var payload,
        _this = this;
      payload = {
        flow: flow.toJSON(),
        flowid: flow.id
      };
      return this.send("register", payload, function(respData) {
        if (respData.status !== "OK") {
          _this.log("warning: flow registration failed");
        }
        if (_.isFunction(cb)) {
          cb(respData.status);
        }
        return _this.emit("register", respData.status);
      });
    };

    RPC.prototype.deregister = function(flow, cb) {
      var payload,
        _this = this;
      payload = {
        flowid: flow.id
      };
      return this.send("deregister", payload, function(respData) {
        if (respData.status !== "OK") {
          _this.log("warning: flow deregistration failed");
        }
        if (_.isFunction(cb)) {
          cb(respData.status);
        }
        return _this.emit("deregister", respData.status);
      });
    };

    RPC.prototype.run = function(flowid, nodeid, outport, inputs, cb) {
      var inputsJson, payload, removedEls, _ref,
        _this = this;
      _ref = gg.wf.rpc.Util.serialize(inputs), inputsJson = _ref[0], removedEls = _ref[1];
      payload = {
        flowid: flowid,
        nodeid: nodeid,
        outport: outport,
        inputs: inputsJson
      };
      return this.send("runflow", payload, function(respData) {
        var outputs;
        nodeid = respData.nodeid;
        outport = respData.outport;
        outputs = gg.wf.rpc.Util.deserialize(respData.outputs, removedEls);
        if (_.isFunction(cb)) {
          cb(nodeid, outport, outputs);
        }
        return _this.emit("runflow", nodeid, outport, outputs);
      });
    };

    return RPC;

  })(events.EventEmitter);

  gg.wf.rule.EnvPut = (function(_super) {

    __extends(EnvPut, _super);

    EnvPut.ggpackage = "gg.wf.rule.EnvPut";

    function EnvPut(spec) {
      EnvPut.__super__.constructor.apply(this, arguments);
    }

    EnvPut.prototype.run = function(flow) {
      var child, children, envput, node, pairs, puts, source, sources, _i, _j, _len, _len1, _ref;
      return flow;
      pairs = {};
      puts = [];
      _ref = flow.nodes();
      for (_i = 0, _len = _ref.length; _i < _len; _i++) {
        node = _ref[_i];
        if (node.type === "envput") {
          _.extend(pairs, node.params.get("pairs"));
          flow.rm(node);
          this.log("removed " + node.name);
        }
      }
      this.log(pairs);
      envput = new gg.xform.EnvPut({
        name: "envput",
        params: {
          pairs: pairs
        }
      });
      sources = flow.sources();
      for (_j = 0, _len1 = sources.length; _j < _len1; _j++) {
        source = sources[_j];
        children = flow.children(source);
        if (children.length > 1) {
          throw Error();
        }
        if (children.length === 0) {
          continue;
        }
        child = children[0];
        flow.insert(envput, source, child);
        this.log("inserted new envput between " + source.name + " and " + child.name);
      }
      return flow;
    };

    return EnvPut;

  })(gg.wf.rule.Rule);

  gg.wf.rule.MergeBarrier = (function(_super) {

    __extends(MergeBarrier, _super);

    function MergeBarrier() {
      return MergeBarrier.__super__.constructor.apply(this, arguments);
    }

    MergeBarrier.ggpackage = "gg.wf.rule.MergeBarrier";

    MergeBarrier.prototype.run = function(flow) {
      var barrier, barriers, c, child, childparents, children, first, firstps, last, lastcs, md, newnode, node, p, parchildren, parent, parents, path, seen, tomerge, totalWeight, _i, _j, _k, _l, _len, _len1, _len2, _len3;
      console.log("mergebarrier");
      console.log(flow.toDot());
      barriers = flow.find(function(n) {
        return n.isBarrier();
      });
      seen = {};
      tomerge = [];
      for (_i = 0, _len = barriers.length; _i < _len; _i++) {
        barrier = barriers[_i];
        if (barrier.id in seen) {
          continue;
        }
        path = [barrier];
        node = barrier;
        while (true) {
          seen[node.id] = true;
          children = flow.children(node);
          if (!(children.length === 1 && children[0].isBarrier())) {
            break;
          }
          child = children[0];
          childparents = flow.parents(child);
          if (childparents.length !== 1) {
            break;
          }
          path.push(child);
          node = child;
        }
        node = barrier;
        while (true) {
          seen[node.id] = true;
          parents = flow.parents(node);
          if (!(parents.length === 1 && parents[0].isBarrier())) {
            break;
          }
          parent = parents[0];
          parchildren = flow.children(parent);
          if (parchildren.length !== 1) {
            break;
          }
          path.unshift(parent);
          node = parent;
        }
        if (path.length > 1) {
          tomerge.push(path);
        }
      }
      console.log(tomerge);
      for (_j = 0, _len1 = tomerge.length; _j < _len1; _j++) {
        path = tomerge[_j];
        newnode = this.mergeNodes(path);
        first = path[0];
        last = _.last(path);
        firstps = flow.parents(first);
        lastcs = flow.children(last);
        if (firstps.length > 0) {
          totalWeight = _.sum(firstps, function(p) {
            return flow.edgeWeight(p, first);
          });
          for (_k = 0, _len2 = firstps.length; _k < _len2; _k++) {
            p = firstps[_k];
            md = flow.disconnect(p, first, "normal");
            flow.connect(p, newnode, "normal", md);
          }
        }
        if (lastcs.length > 0) {
          totalWeight = _.sum(lastcs, function(c) {
            return flow.edgeWeight(last, c);
          });
          for (_l = 0, _len3 = lastcs.length; _l < _len3; _l++) {
            c = lastcs[_l];
            md = flow.disconnect(last, c, "normal");
            flow.connect(newnode, c, "normal", md);
          }
        }
        _.each(path, flow.graph.rm.bind(flow.graph));
      }
      this.log(flow.toDot());
      return flow;
    };

    MergeBarrier.prototype.mergeNodes = function(path) {
      var computes, f, names;
      names = _.map(path, function(n) {
        return n.name;
      });
      computes = _.map(path, function(n) {
        var f;
        f = n.params.get("compute");
        if (f == null) {
          f = n.compute.bind(n);
        }
        return (function(n) {
          return function(tableset, cb) {
            return f(tableset, n.params, cb);
          };
        })(n);
      });
      f = (function(computes) {
        return function(tableset, params, finalcb) {
          var _computes;
          _computes = _.clone(computes);
          _computes.unshift(function(cb) {
            return cb(null, tableset);
          });
          return async.waterfall(_computes, function(err, result) {
            return finalcb(null, result);
          });
        };
      })(computes);
      return new gg.wf.Barrier({
        name: "merged-" + (names.join('_')),
        params: {
          compute: f
        }
      });
    };

    return MergeBarrier;

  })(gg.wf.rule.Rule);

  gg.wf.rule.MergeExec = (function(_super) {

    __extends(MergeExec, _super);

    function MergeExec() {
      return MergeExec.__super__.constructor.apply(this, arguments);
    }

    MergeExec.ggpackage = "gg.wf.rule.MergeExec";

    MergeExec.prototype.run = function(flow) {
      var bc, bp, c, child, children, exec, execs, first, firstbps, firstps, getKeys, isEqual, isExec, last, lastbcs, lastcs, md, newnode, node, p, parent, parents, path, seen, tomerge, _i, _j, _k, _l, _len, _len1, _len2, _len3, _len4, _len5, _m, _n;
      getKeys = function(n) {
        return n.params.get('keys');
      };
      isExec = function(n) {
        return _.isType(n, gg.wf.Exec);
      };
      isEqual = function(k1, k2) {
        if (!((k1 != null) && (k2 != null))) {
          if (k1 != null) {
            return false;
          }
          if (k2 != null) {
            return false;
          }
        }
        return _.intersection(k1, k2).length === k1.length && k1.length === k2.length;
      };
      execs = flow.find(isExec);
      seen = {};
      tomerge = [];
      for (_i = 0, _len = execs.length; _i < _len; _i++) {
        exec = execs[_i];
        if (exec.id in seen) {
          continue;
        }
        path = [exec];
        node = exec;
        while (true) {
          seen[node.id] = true;
          children = flow.children(node);
          if (!(children.length === 1 && isExec(children[0]))) {
            break;
          }
          child = children[0];
          if (!isEqual(getKeys(node), getKeys(child))) {
            this.log("keys of " + node.name + " vs " + child.name + " not the same " + (getKeys(node)) + " vs " + (getKeys(child)));
            break;
          }
          path.push(child);
          node = child;
        }
        node = exec;
        while (true) {
          seen[node.id] = true;
          parents = flow.parents(node);
          if (!(parents.length === 1 && isExec(parents[0]))) {
            break;
          }
          parent = parents[0];
          if (!isEqual(getKeys(node), getKeys(parent))) {
            this.log("keys of " + node.name + " vs " + parent.name + " not the same " + (getKeys(node)) + " vs " + (getKeys(parent)));
            break;
          }
          path.unshift(parent);
          node = parent;
        }
        if (path.length > 1) {
          tomerge.push(path);
        }
      }
      this.log(tomerge);
      for (_j = 0, _len1 = tomerge.length; _j < _len1; _j++) {
        path = tomerge[_j];
        newnode = this.mergeNodes(path);
        first = path[0];
        last = _.last(path);
        firstbps = flow.bridgedParents(first);
        firstps = flow.parents(first);
        lastbcs = flow.bridgedChildren(last);
        lastcs = flow.children(last);
        if (firstps.length > 0) {
          for (_k = 0, _len2 = firstps.length; _k < _len2; _k++) {
            p = firstps[_k];
            md = flow.disconnect(p, first, "normal");
            flow.connect(p, newnode, "normal", md);
          }
        }
        if (firstbps.length > 0) {
          for (_l = 0, _len3 = firstbps.length; _l < _len3; _l++) {
            bp = firstbps[_l];
            md = flow.disconnect(bp, first, "bridge");
            flow.connect(bp, newnode, 'bridge', md);
          }
        }
        if (lastcs.length > 0) {
          for (_m = 0, _len4 = lastcs.length; _m < _len4; _m++) {
            c = lastcs[_m];
            md = flow.disconnect(last, c, "normal");
            flow.connect(newnode, c, "normal", md);
          }
        }
        if (lastbcs.length > 0) {
          for (_n = 0, _len5 = lastbcs.length; _n < _len5; _n++) {
            bc = lastbcs[_n];
            md = flow.disconnect(last, bc, "bridge");
            flow.connect(newnode, bc, "bridge", md);
          }
        }
        _.each(path, flow.graph.rm.bind(flow.graph));
      }
      this.log(flow.toDot());
      return flow;
    };

    MergeExec.prototype.mergeNodes = function(path) {
      var computes, f, names;
      names = _.map(path, function(n) {
        return n.name;
      });
      computes = _.map(path, function(n) {
        var f;
        f = n.params.get("compute");
        if (f == null) {
          f = n.compute.bind(n);
        }
        return (function(n) {
          return function(tableset, cb) {
            return f(tableset, n.params, cb);
          };
        })(n);
      });
      f = (function(computes) {
        return function(tableset, params, finalcb) {
          var _computes;
          _computes = _.clone(computes);
          _computes.unshift(function(cb) {
            return cb(null, tableset);
          });
          return async.waterfall(_computes, function(err, result) {
            return finalcb(null, result);
          });
        };
      })(computes);
      return new gg.wf.Exec({
        name: "merged-" + (names.join('_')),
        params: {
          keys: path[0].params.get('keys'),
          compute: f
        }
      });
    };

    return MergeExec;

  })(gg.wf.rule.Rule);

  gg.wf.rule.Node = (function(_super) {

    __extends(Node, _super);

    function Node(spec) {
      if (spec == null) {
        spec = {};
      }
      Node.__super__.constructor.apply(this, arguments);
    }

    Node.prototype.compute = function(node) {
      return node;
    };

    Node.prototype.run = function(flow) {
      var _this = this;
      _.each(flow.nodes(), function(node) {
        var replacements;
        replacements = _this.compute(node);
        replacements = _.flatten([replacements]);
        replacements = _.compact(replacements);
        return gg.wf.rule.Rule.replace(flow, node, replacements);
      });
      return flow;
    };

    return Node;

  })(gg.wf.rule.Rule);

  gg.wf.rule.RmDebug = (function(_super) {

    __extends(RmDebug, _super);

    function RmDebug() {
      return RmDebug.__super__.constructor.apply(this, arguments);
    }

    RmDebug.prototype.compute = function(node) {
      if (_.isType(node, gg.wf.Stdout) || _.isType(node, gg.wf.Scales)) {
        return null;
      } else {
        return node;
      }
    };

    return RmDebug;

  })(gg.wf.rule.Node);

  gg.wf.rule.RPCify = (function(_super) {

    __extends(RPCify, _super);

    function RPCify() {
      return RPCify.__super__.constructor.apply(this, arguments);
    }

    RPCify.prototype.compute = function(node) {
      var canRpcify, mustRpcify;
      canRpcify = function(node) {
        return !_.any([
          node.params.get('location') === "client", /layout/.test(node.constructor.name.toLowerCase()), _.any(node.params, function(v, k) {
            return _.isFunction(v);
          })
        ]);
      };
      mustRpcify = function(node) {
        return _.all([node.params.get("location") === "server"]);
      };
      if (!/RPC/.test(node.constructor.name)) {
        if (mustRpcify(node)) {
          node.location = "server";
        } else if (canRpcify(node)) {
          null;
        }
      }
      return node;
    };

    return RPCify;

  })(gg.wf.rule.Node);

  gg.wf.rule.Cache = (function(_super) {

    __extends(Cache, _super);

    function Cache() {
      return Cache.__super__.constructor.apply(this, arguments);
    }

    Cache.ggpackage = "gg.wf.rule.Cache";

    Cache.prototype.run = function(flow) {
      var guid;
      guid = this.params.get('guid');
      if (this.canCache()) {
        if (this.isCached(guid)) {
          return this.useCachers(flow, guid);
        } else {
          return this.addCachers(flow, guid);
        }
      }
    };

    Cache.prototype.canCache = function() {
      return this.getDB() != null;
    };

    Cache.prototype.getDB = function() {
      if (typeof window === "undefined" || window === null) {
        return null;
      }
      if (window.localStorage == null) {
        return null;
      }
      return window.localStorage;
    };

    Cache.prototype.isCached = function(guid) {
      var db, idx, ntables, _i;
      db = this.getDB();
      ntables = db[guid];
      if (ntables == null) {
        return false;
      }
      for (idx = _i = 0; 0 <= ntables ? _i < ntables : _i > ntables; idx = 0 <= ntables ? ++_i : --_i) {
        if (db["" + guid + "-" + idx + "-table"] == null) {
          return false;
        }
        if (db["" + guid + "-" + idx + "-md"] == null) {
          return false;
        }
      }
      return true;
    };

    Cache.prototype.getCacherSource = function(guid) {
      return new gg.wf.CacheSource({
        name: "" + guid + "-cacheSource",
        params: {
          guid: guid
        }
      });
    };

    Cache.prototype.getCacher = function(guid) {
      return new gg.wf.Cache({
        name: "" + guid + "-cacher",
        params: {
          guid: guid
        }
      });
    };

    Cache.prototype.addCachers = function(flow, guid) {
      var p, renderer, renderers, _i, _len, _ref;
      this.log("addCachers with guid: " + guid);
      renderers = flow.find(function(n) {
        return n.name === 'core-render';
      });
      renderer = renderers[0];
      this.log("adding cacher before " + renderer.name);
      flow.insertBefore(this.getCacher(guid), renderer);
      this.log("insert completed");
      _ref = flow.parents(renderer);
      for (_i = 0, _len = _ref.length; _i < _len; _i++) {
        p = _ref[_i];
        this.log("" + renderer.name + " parents: " + p.name);
      }
      return flow;
    };

    Cache.prototype.useCachers = function(flow, guid) {
      var corerender, facetrender, geomrenders, gr, layers, multi, n, nodes, panerender, prev, setup, source, start, wf, _i, _j, _k, _len, _len1, _len2;
      this.log("useCachers with guid: " + guid);
      source = this.getCacherSource(guid);
      start = flow.findOne(function(n) {
        return _.isType(n, gg.wf.Start);
      });
      setup = flow.findOne(function(n) {
        return n.name === 'graphic-setupenv';
      });
      multi = new gg.wf.NoCopyMulticast({
        name: 'nc-multicast'
      });
      corerender = flow.findOne(function(n) {
        return n.name === 'core-render';
      });
      facetrender = flow.findOne(function(n) {
        return n.name === 'facet-render';
      });
      panerender = flow.findOne(function(n) {
        return n.name === 'render-panes';
      });
      geomrenders = flow.find(function(n) {
        return n.constructor.ggpackage.search("^gg.geom.svg") >= 0;
      });
      nodes = _.compact([start, source, setup, multi]);
      layers = [corerender, facetrender, panerender];
      wf = new gg.wf.Flow;
      prev = null;
      for (_i = 0, _len = nodes.length; _i < _len; _i++) {
        n = nodes[_i];
        if (prev != null) {
          wf.connect(prev, n);
          wf.connectBridge(prev, n);
        }
        prev = n;
      }
      for (_j = 0, _len1 = geomrenders.length; _j < _len1; _j++) {
        gr = geomrenders[_j];
        prev = multi;
        for (_k = 0, _len2 = layers.length; _k < _len2; _k++) {
          n = layers[_k];
          wf.connect(prev, n);
          prev = n;
        }
        wf.connect(prev, gr);
        wf.connectBridge(multi, gr);
      }
      return wf;
    };

    return Cache;

  })(gg.wf.rule.Rule);

  try {
    timer = performance;
  } catch (err) {
    timer = Date;
  }

  gg.wf.Runner = (function(_super) {

    __extends(Runner, _super);

    Runner.ggpackage = "gg.wf.Runner";

    function Runner(flow, xferControl) {
      var _this = this;
      this.flow = flow;
      this.log = gg.util.Log.logger(this.constructor.ggpackage, "Runner");
      this.done = {};
      this.seen = {};
      this.setupQueue();
      this.ch = new gg.wf.ClearingHouse(this, null);
      this.ch.on("output", function() {
        var args;
        args = 1 <= arguments.length ? __slice.call(arguments, 0) : [];
        return _this.emit.apply(_this, ["output"].concat(__slice.call(args)));
      });
      if (xferControl != null) {
        this.ch.xferControl = xferControl;
      }
      this.flow.graph.bfs(function(node) {
        return node.on("output", function() {
          var args, o, _ref;
          args = 1 <= arguments.length ? __slice.call(arguments, 0) : [];
          if (node.id in _this.debug) {
            o = _this.debug[node.id];
            o['end'] = timer.now();
            o['cost'] = o['end'] - o['start'];
          }
          return (_ref = _this.ch).push.apply(_ref, args);
        });
      });
      this.debug = {};
    }

    Runner.prototype.setupQueue = function() {
      var ondrain, qworker,
        _this = this;
      qworker = function(node, cb) {
        if (!_this.nodeCanRun(node)) {
          cb();
          return;
        }
        _this.seen[node.id] = true;
        _this.runNode(node);
        return cb();
      };
      ondrain = function() {
        if (_.all(_this.flow.sinks(), function(s) {
          return _this.done[s.id];
        })) {
          _this.log("done! can you believe it?");
          return _this.emit('done', _this.debug);
        }
      };
      this.queue = new async.queue(qworker, 1);
      return this.queue.drain = ondrain;
    };

    Runner.prototype.runNode = function(node) {
      this.log("runNode: " + node.name + " in(" + node.inputs.length + ")          out(" + node.nChildren + ") running");
      this.debug[node.id] = {
        start: timer.now(),
        name: node.name,
        id: node.id
      };
      return node.run();
    };

    Runner.prototype.nodeCanRun = function(node) {
      if (node.id in this.seen) {
        this.log("\t" + node.name + " seen. skipping");
        return false;
      }
      if (!node.ready()) {
        this.log("\t" + node.name + " skip:            " + (node.nReady()) + " of " + node.nParents + " inputs ready");
        return false;
      }
      return true;
    };

    Runner.prototype.setDone = function(nodeid) {
      if (nodeid != null) {
        return this.done[nodeid] = true;
      }
    };

    Runner.prototype.tryRun = function(node) {
      return this.queue.push(node);
    };

    Runner.prototype.run = function() {
      var _this = this;
      return _.each(this.flow.sources(), function(source) {
        _this.log("adding source " + source.name);
        return _this.queue.push(source);
      });
    };

    return Runner;

  })(events.EventEmitter);

  gg.wf.Source = (function(_super) {

    __extends(Source, _super);

    function Source() {
      return Source.__super__.constructor.apply(this, arguments);
    }

    Source.ggpackage = "gg.wf.Source";

    Source.type = "source";

    Source.prototype.parseSpec = function() {
      Source.__super__.parseSpec.apply(this, arguments);
      this.params.ensure("tabletype", [], "row");
      return this.params.ensure('compute', ['f'], null);
    };

    Source.prototype.compute = function(pairtable, params, cb) {
      throw Error("Source not setup to generate tables");
    };

    Source.prototype.run = function() {
      var compute, params, pt,
        _this = this;
      if (!this.ready()) {
        throw Error("node not ready");
      }
      params = this.params;
      compute = this.params.get('compute') || this.compute.bind(this);
      pt = this.inputs[0];
      return compute(pt, params, function(err, pairtable) {
        if (err != null) {
          _this.error(err);
        }
        pairtable = pairtable.ensure([]);
        return _this.output(0, pairtable);
      });
    };

    return Source;

  })(gg.wf.Node);

  gg.wf.TableSource = (function(_super) {

    __extends(TableSource, _super);

    TableSource.ggpackage = "gg.wf.TableSource";

    function TableSource() {
      TableSource.__super__.constructor.apply(this, arguments);
      this.name = this.spec.name || "tablesource";
    }

    TableSource.prototype.parseSpec = function() {
      TableSource.__super__.parseSpec.apply(this, arguments);
      if (!this.params.contains('table')) {
        if ('table' in this.spec) {
          return this.params.put('table', this.spec.table);
        } else {
          throw Error("TableSource needs a table as parameter");
        }
      }
    };

    TableSource.prototype.compute = function(pt, params, cb) {
      pt = new data.PairTable(params.get('table'), pt.right());
      return cb(null, pt);
    };

    return TableSource;

  })(gg.wf.Source);

  gg.wf.RowSource = (function(_super) {

    __extends(RowSource, _super);

    RowSource.ggpackage = "gg.wf.RowSource";

    function RowSource() {
      RowSource.__super__.constructor.apply(this, arguments);
      this.name = this.spec.name || "rowsource";
    }

    RowSource.prototype.parseSpec = function() {
      RowSource.__super__.parseSpec.apply(this, arguments);
      this.params.ensure("rows", ["array", "row"], null);
      this.params.require("rows", "RowSource needs a table as parameter");
      if (this.params.get('rows') == null) {
        throw Error("RowSource needs a table as parameter");
      }
    };

    RowSource.prototype.compute = function(pt, params, cb) {
      var table;
      table = data.Table.fromArray(params.get('rows'), null, params.get('tabletype'));
      pt = new data.PairTable(table, pt.right());
      return cb(null, pt);
    };

    return RowSource;

  })(gg.wf.Source);

  gg.wf.CsvSource = (function(_super) {

    __extends(CsvSource, _super);

    CsvSource.ggpackage = "gg.wf.CsvSource";

    function CsvSource(spec) {
      this.spec = spec;
      CsvSource.__super__.constructor.apply(this, arguments);
      this.name = "CSVSource";
    }

    CsvSource.prototype.parseSpec = function() {
      CsvSource.__super__.parseSpec.apply(this, arguments);
      return this.params.require('url', 'CsvSource needs a URL');
    };

    CsvSource.prototype.compute = function(pt, params, cb) {
      var tabletype, url;
      url = params.get('url');
      tabletype = params.get('tabletype');
      return d3.csv(url, function(err, arr) {
        var table;
        table = data.Table.fromArray(arr, null, tabletype);
        pt = new data.PairTable(table, pt.right());
        return cb(null, pt);
      });
    };

    return CsvSource;

  })(gg.wf.Source);

  gg.wf.SQLSource = (function(_super) {

    __extends(SQLSource, _super);

    SQLSource.ggpackage = "gg.wf.SQLSource";

    function SQLSource(spec) {
      this.spec = spec;
      SQLSource.__super__.constructor.apply(this, arguments);
      this.name = "SQLSource";
    }

    SQLSource.prototype.parseSpec = function() {
      SQLSource.__super__.parseSpec.apply(this, arguments);
      this.params.put("location", "server");
      this.params.ensure("uri", ["conn", "connection", "url"], null);
      this.params.ensure("query", ["q"], null);
      this.params.require('uri', "SQLSource needs a connection URI: params.put 'uri', <URI>");
      return this.params.require('query', "SQLSource needs a query string");
    };

    SQLSource.prototype.compute = function(pt, params, cb) {
      var client, query, tabletype, uri;
      if (typeof pg === "undefined" || pg === null) {
        throw Error("pg is not allowed on the client side");
      }
      uri = params.get("uri");
      query = params.get("q");
      tabletype = params.get('tabletype');
      this.log("uri: " + uri);
      this.log("query: " + query);
      client = new pg.Client(uri);
      return client.connect(function(err) {
        if (err != null) {
          cb(err, null);
          throw Error(err);
        }
        return client.query(query, function(err, result) {
          var rows, table;
          if (err != null) {
            cb(err, null);
            throw Error(err);
          }
          rows = result.rows;
          client.end();
          table = data.Table.fromArray(rows, null, tabletype);
          pt = new data.PairTable(table, pt.right());
          return cb(null, pt);
        });
      });
    };

    return SQLSource;

  })(gg.wf.Source);

  gg.wf.CacheSource = (function(_super) {

    __extends(CacheSource, _super);

    function CacheSource() {
      return CacheSource.__super__.constructor.apply(this, arguments);
    }

    CacheSource.ggpackage = "gg.wf.CacheSource";

    CacheSource.prototype.construtor = function() {
      CacheSource.__super__.construtor.apply(this, arguments);
      return this.name = "CacheSource";
    };

    CacheSource.prototype.parseSpec = function() {
      CacheSource.__super__.parseSpec.apply(this, arguments);
      if (!this.params.has('guid')) {
        throw Error("can't run cache source without a guid key");
      }
    };

    CacheSource.prototype.compute = function(pt, params, cb) {
      var db, guid, idx, keyprefix, md, mdkey, ntables, partitions, t, tkey, _i;
      guid = params.get('guid');
      db = gg.wf.Cache.getDB();
      ntables = parseInt(db[guid]);
      partitions = [];
      for (idx = _i = 0; 0 <= ntables ? _i < ntables : _i > ntables; idx = 0 <= ntables ? ++_i : --_i) {
        keyprefix = "" + guid + "-" + idx;
        tkey = "" + keyprefix + "-table";
        mdkey = "" + keyprefix + "-md";
        t = data.Table.deserialize(db[tkey]);
        md = data.Table.deserialize(db[mdkey]);
        partitions.push(new data.PairTable(t, md));
      }
      if (partitions.length === 1) {
        return cb(null, partitions[0]);
      } else {
        return cb(null, new data.TableSet(partitions));
      }
    };

    return CacheSource;

  })(gg.wf.Source);

  gg.stat.Stat = (function() {

    function Stat() {}

    Stat.klasses = [];

    Stat.addKlass = function(klass) {
      return this.klasses.push(klass);
    };

    Stat.getKlasses = function() {
      var klasses, ret;
      klasses = _.compact(this.klasses.concat([gg.stat.Identity, gg.stat.Bin1D, gg.stat.Boxplot, gg.stat.Loess, gg.stat.Sort, gg.stat.CDF, gg.stat.Bin2D]));
      ret = {};
      _.each(klasses, function(klass) {
        var alias, _i, _len, _ref, _results;
        _ref = _.flatten([klass.aliases]);
        _results = [];
        for (_i = 0, _len = _ref.length; _i < _len; _i++) {
          alias = _ref[_i];
          _results.push(ret[alias] = klass);
        }
        return _results;
      });
      return ret;
    };

    Stat.fromSpec = function(spec) {
      var klass, klasses;
      klasses = this.getKlasses();
      klass = klasses[spec.type];
      if (klass != null) {
        return new klass(spec);
      }
    };

    return Stat;

  })();

  gg.geom.Geom = (function() {

    Geom.ggpackage = "gg.geom.Geom";

    Geom.log = gg.util.Log.logger(Geom.ggpackage, "Geom");

    function Geom(layer, spec) {
      this.layer = layer;
      this.spec = spec;
      this.g = this.layer.g;
      this.render = null;
      this.map = null;
      this.reparam = null;
      this.parseSpec();
    }

    Geom.prototype.parseSpec = function() {
      this.render = gg.geom.Render.fromSpec(this.spec);
      return this.map = gg.xform.Mapper.fromSpec(this.spec);
    };

    Geom.prototype.posMapping = function() {
      return {};
    };

    Geom.fromSpec = function(layer, spec) {
      var klass, klasses;
      spec = _.clone(spec);
      klasses = this.getKlasses();
      if (!(spec.type in klasses)) {
        throw Error("geom " + spec.type + " not found");
      }
      klass = klasses[spec.type];
      if (spec.name == null) {
        spec.name = klass.name;
      }
      return new klass(layer, spec);
    };

    Geom.klasses = [];

    Geom.addKlass = function(klass) {
      return this.klasses.push(klass);
    };

    Geom.getKlasses = function() {
      var klasses, ret;
      klasses = _.compact(this.klasses.concat([gg.geom.Point, gg.geom.Line, gg.geom.Path, gg.geom.Area, gg.geom.Rect, gg.geom.Polygon, gg.geom.Hex, gg.geom.Boxplot, gg.geom.Glyph, gg.geom.Edge, gg.geom.Text, gg.geom.Bin2D]));
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

    return Geom;

  })();

  gg.geom.Step = (function(_super) {

    __extends(Step, _super);

    function Step() {
      return Step.__super__.constructor.apply(this, arguments);
    }

    Step.aliases = "step";

    return Step;

  })(gg.geom.Geom);

  gg.geom.Path = (function(_super) {

    __extends(Path, _super);

    function Path() {
      return Path.__super__.constructor.apply(this, arguments);
    }

    Path.aliases = "path";

    return Path;

  })(gg.geom.Geom);

  gg.geom.Polygon = (function(_super) {

    __extends(Polygon, _super);

    function Polygon() {
      return Polygon.__super__.constructor.apply(this, arguments);
    }

    Polygon.aliases = "polygon";

    return Polygon;

  })(gg.geom.Geom);

  gg.geom.Hex = (function(_super) {

    __extends(Hex, _super);

    function Hex() {
      return Hex.__super__.constructor.apply(this, arguments);
    }

    Hex.aliases = "hex";

    return Hex;

  })(gg.geom.Geom);

  gg.geom.Glyph = (function(_super) {

    __extends(Glyph, _super);

    function Glyph() {
      return Glyph.__super__.constructor.apply(this, arguments);
    }

    Glyph.aliases = "glyph";

    return Glyph;

  })(gg.geom.Geom);

  gg.geom.Edge = (function(_super) {

    __extends(Edge, _super);

    function Edge() {
      return Edge.__super__.constructor.apply(this, arguments);
    }

    Edge.aliases = "edge";

    return Edge;

  })(gg.geom.Geom);

  gg.wf.Start = (function(_super) {

    __extends(Start, _super);

    function Start() {
      return Start.__super__.constructor.apply(this, arguments);
    }

    Start.ggpackage = "gg.wf.Start";

    Start.type = "start";

    Start.prototype.ready = function() {
      return true;
    };

    Start.prototype.run = function() {
      var result;
      result = new data.PairTable;
      return this.output(0, result);
    };

    return Start;

  })(gg.wf.Node);

  events = require('events');

  gg.wf.Flow = (function(_super) {

    __extends(Flow, _super);

    Flow.ggpackage = "gg.wf.Flow";

    Flow.id = function() {
      return gg.wf.Flow.prototype._id += 1;
    };

    Flow.prototype._id = 0;

    function Flow(spec) {
      this.spec = spec != null ? spec : {};
      this.id = gg.wf.Flow.id();
      this.graph = new gg.util.Graph(function(node) {
        return node.id;
      });
      this.log = gg.util.Log.logger(this.constructor.ggpackage, "flow");
      this.portGraph = null;
      this.debug = {};
    }

    Flow.prototype.instantiate = function() {
      var connectPath, f, from, inportsMap, outportsMap, path, to, type, weight, weightid, _i, _j, _len, _ref, _ref1,
        _this = this;
      f = function(node) {
        var childWeights, nChildren, nParents, parentWeights;
        parentWeights = _.map(_this.parents(node), function(parent) {
          return _this.edgeWeight(parent, node);
        });
        childWeights = _.map(_this.children(node), function(child) {
          return _this.edgeWeight(node, child);
        });
        nParents = _.sum(parentWeights);
        nChildren = _.sum(childWeights);
        node.flow = _this;
        return node.setup(nParents, nChildren);
      };
      this.graph.bfs(f);
      inportsMap = _.o2map(this.nodes(), function(node) {
        return [node.id, 0];
      });
      outportsMap = _.o2map(this.nodes(), function(node) {
        return [node.id, 0];
      });
      this.portGraph = new gg.util.Graph(function(o) {
        return "" + o.n.id + "-" + o.p;
      });
      connectPath = function(path) {
        var from, inport, outport, t, to, _i, _len, _results;
        from = null;
        _results = [];
        for (_i = 0, _len = path.length; _i < _len; _i++) {
          to = path[_i];
          if (from != null) {
            outport = outportsMap[from.id];
            inport = inportsMap[to.id];
            f = {
              n: from,
              p: outport
            };
            t = {
              n: to,
              p: inport
            };
            _this.portGraph.connect(f, t);
            outportsMap[from.id] += 1;
            inportsMap[to.id] += 1;
          }
          _results.push(from = to);
        }
        return _results;
      };
      _ref = this.graph.edges("bridge");
      for (_i = 0, _len = _ref.length; _i < _len; _i++) {
        _ref1 = _ref[_i], from = _ref1[0], to = _ref1[1], type = _ref1[2], weight = _ref1[3];
        path = this.findPath(from, to);
        for (weightid = _j = 0; 0 <= weight ? _j < weight : _j > weight; weightid = 0 <= weight ? ++_j : --_j) {
          connectPath(path);
        }
      }
      return this;
    };

    Flow.prototype.nodes2str = function(nodes, sep) {
      if (sep == null) {
        sep = "  ";
      }
      return nodes.map(function(n) {
        return n.name;
      }).join(sep);
    };

    Flow.prototype.toString = function() {
      var arr, f,
        _this = this;
      arr = [];
      f = function(node) {
        var childnames, cns;
        childnames = _.map(_this.children(node), function(c) {
          return "" + c.name + "(" + (_this.edgeWeight(node, c)) + ")";
        });
        cns = childnames.join(', ') || "SINK";
        return arr.push("" + node.name + "@" + node.location + "\t->\t" + cns);
      };
      this.graph.bfs(f);
      return arr.join("\n");
    };

    Flow.prototype.toJSON = function() {
      var edge2json, id2idx, node2json;
      id2idx = _.o2map(this.nodes(), function(node, idx) {
        return [node.id, idx];
      });
      node2json = function(node) {
        return node.toJSON();
      };
      edge2json = function(from, to, type, md) {
        return {
          source: id2idx[from.id],
          target: id2idx[to.id],
          type: type,
          weight: md
        };
      };
      return {
        id: this.id,
        graph: this.graph.toJSON(node2json, edge2json),
        spec: _.toJSON(this.spec)
      };
    };

    Flow.fromJSON = function(json) {
      var flow, graph, json2edge, json2node, spec;
      json2edge = function(link, nodes) {
        return [nodes[link.source], nodes[link.target], link.type, link.weight];
      };
      json2node = gg.wf.Node.fromJSON;
      graph = gg.util.Graph.fromJSON(json.graph, json2node, json2edge);
      spec = _.fromJSON(json.spec);
      flow = new gg.wf.Flow(spec);
      flow.graph = graph;
      flow.id = json.id;
      return flow;
    };

    Flow.prototype.clone = function() {
      return gg.wf.Flow.fromJSON(this.toJSON());
    };

    Flow.prototype.toJSONTree = function() {
      var id2node, root,
        _this = this;
      root = {
        name: "root",
        id: -1,
        "children": []
      };
      id2node = {
        "-1": root
      };
      this.graph.bfs(function(node) {
        var id, parents;
        id = node.id;
        id2node[id] = {
          name: node.name,
          id: node.id,
          node: node,
          "children": []
        };
        parents = _this.parents(node);
        if (!(parents.length > 0)) {
          parents = [root];
        }
        return _.each(parents, function(par) {
          return id2node[par.id].children.push(id2node[id]);
        });
      });
      return root;
    };

    Flow.prototype.toDot = function(rankdir) {
      var text,
        _this = this;
      if (rankdir == null) {
        rankdir = 'TD';
      }
      text = [];
      text.push("digraph G {");
      text.push("graph [rankdir=" + rankdir + "]");
      _.each(this.graph.edges(), function(edge) {
        var color, n1, n2, type, weight;
        n1 = edge[0], n2 = edge[1], type = edge[2], weight = edge[3];
        color = type === "normal" ? "black" : "green";
        return text.push("\"" + n1.name + ":" + n1.id + "\" -> \"" + n2.name + ":" + n2.id + "\" [color=\"" + color + "\", label=\"" + type + ":" + weight + "\"];");
      });
      text.push("}");
      return text.join("\n");
    };

    Flow.prototype.add = function(node) {
      node.wf = this;
      return this.graph.add(node);
    };

    Flow.prototype.rm = function(node) {
      var bc, bcs, bmd, bp, bps, c, cs, md, p, ps;
      ps = this.parents(node);
      cs = this.children(node);
      if (this.parents(node).length > 1) {
        this.log.err(this.parents(node));
        throw Error("don't support removing multi-parent node " + node.name);
      }
      if (this.children(node).length > 1) {
        this.log.err(this.children(node));
        throw Error("don't support removing multi-child node " + node.name);
      }
      c = p = null;
      if (ps.length > 0) {
        p = ps[0];
        md = this.edgeWeight(p, node, "normal");
      }
      if (cs.length > 0) {
        c = cs[0];
        md = this.edgeWeight(node, c, "normal");
      }
      if (node.isBarrier()) {
        this.graph.rm(node);
        if ((p != null) && (c != null)) {
          return this.connect(p, c);
        }
      } else {
        if (!((p != null) && (c != null))) {
          return this.graph.rm(node);
        } else {
          bps = this.bridgedParents(node);
          bcs = this.bridgedChildren(node);
          if (bps.length > 1 || bcs.length > 1) {
            throw Error();
          }
          bmd = bp = bc = null;
          if (bps.length > 0) {
            bp = bps[0];
            bmd = this.edgeWeight(bp, node, "bridge");
          }
          if (bcs.length > 0) {
            bc = bcs[0];
            bmd = this.edgeWeight(node, bc, "bridge");
          }
          this.graph.rm(node);
          if ((p != null) && (c != null)) {
            this.connect(p, c, "normal", md);
          }
          if ((bp != null) && (bc != null)) {
            return this.connect(bp, bc, "bridge", bmd);
          }
        }
      }
    };

    Flow.prototype.insertAfter = function(node, parent, checkChildren) {
      var b2str, child, _i, _len, _ref;
      if (checkChildren == null) {
        checkChildren = true;
      }
      if (this.children(parent).length > 0 && checkChildren) {
        _ref = this.children(parent);
        for (_i = 0, _len = _ref.length; _i < _len; _i++) {
          child = _ref[_i];
          if (child != null) {
            this.log("insertAfter calling insert: " + node.name + ", " + parent.name + ", " + child.name);
            this.insert(node, parent, child);
          }
        }
        return;
      }
      if (node.isBarrier() === parent.isBarrier()) {
        this.connect(parent, node, 'normal');
        if (!node.isBarrier()) {
          return this.connect(parent, node, 'bridge');
        }
      } else {
        b2str = function(b) {
          if (b) {
            return "barrier";
          } else {
            return "nonbarrier";
          }
        };
        throw Error("Can't insert " + (b2str(node.isBarrier())) + "                    after " + (b2str(parent.isBarrier())));
      }
    };

    Flow.prototype.insertBefore = function(node, child, checkParents) {
      var b2str, p, _i, _len, _ref;
      if (checkParents == null) {
        checkParents = true;
      }
      if (this.parents(child).length > 0 && checkParents) {
        this.log("insertBefore " + child.name + " has parents");
        _ref = this.parents(child);
        for (_i = 0, _len = _ref.length; _i < _len; _i++) {
          p = _ref[_i];
          if (p != null) {
            this.log("insertBefore calling insert: " + node.name + ", " + p.name + ", " + child.name);
            this.insert(node, p, child);
          }
        }
        return;
      }
      if (node.isBarrier() === child.isBarrier()) {
        this.connect(node, child, 'normal');
        if (!node.isBarrier()) {
          return this.connect(node, child, 'bridge');
        }
      } else {
        b2str = function(b) {
          if (b) {
            return "barrier";
          } else {
            return "nonbarrier";
          }
        };
        throw Error("Can't insert " + (b2str(node.isBarrier())) + "                    before " + (b2str(child.isBarrier())));
      }
    };

    Flow.prototype.insert = function(node, parent, child) {
      var bc, bp, md, totalWeight, _i, _j, _k, _l, _len, _len1, _len2, _len3, _ref, _ref1, _ref2, _ref3,
        _this = this;
      if (!_.any(this.children(parent), (function(pc) {
        return pc.id === child.id;
      }))) {
        throw Error("parent not parent of child: " + (parent.toString()) + "\t" + (child.toString()));
      }
      if ((parent != null) && !(child != null)) {
        this.insertAfter(node, parent, false);
        return;
      }
      if ((child != null) && !(parent != null)) {
        this.insertBefore(node, child, false);
        return;
      }
      if (parent.isBarrier() && child.isBarrier()) {
        if (node.isBarrier()) {
          md = this.disconnect(parent, child, "normal");
          this.connect(parent, node, "normal", md);
          this.connect(node, child, "normal", md);
        } else {
          throw Error("Can't insert a nonbarrier between two barriers");
        }
      }
      if (parent.isBarrier() && !child.isBarrier()) {
        if (node.isBarrier()) {
          totalWeight = _.sum(this.children(parent), function(c) {
            return _this.edgeWeight(parent, c);
          });
          _ref = this.children(parent);
          for (_i = 0, _len = _ref.length; _i < _len; _i++) {
            bc = _ref[_i];
            md = this.disconnect(parent, node, "normal");
            this.connect(node, bc, "normal", md);
          }
          this.connect(parent, node, "normal", totalWeight);
        } else {
          md = this.disconnect(parent, child, "normal");
          this.connect(parent, node, "normal", md);
          this.connect(node, child, "normal", md);
          _ref1 = this.bridgedParents(child);
          for (_j = 0, _len1 = _ref1.length; _j < _len1; _j++) {
            bp = _ref1[_j];
            md = this.disconnect(bp, child, "bridge");
            this.connect(bp, node, "bridge");
          }
        }
      }
      if (!parent.isBarrier() && child.isBarrier()) {
        if (node.isBarrier()) {
          totalWeight = _.sum(this.parents(child), function(p) {
            return _this.edgeWeight(p, child);
          });
          _ref2 = this.parents(child);
          for (_k = 0, _len2 = _ref2.length; _k < _len2; _k++) {
            bp = _ref2[_k];
            md = this.disconnect(bp, child, "normal");
            this.connect(bp, node, "normal", md);
          }
          this.connect(node, child, "normal", totalWeight);
        } else {
          md = this.graph.disconnect(parent, child, "normal");
          this.connect(node, child, "normal", md);
          this.connect(parent, node, "normal", md);
          _ref3 = this.bridgedChildren(parent);
          for (_l = 0, _len3 = _ref3.length; _l < _len3; _l++) {
            bc = _ref3[_l];
            md = this.disconnect(parent, bc, "bridge");
            this.connect(node, bc, "bridge", md);
          }
          this.connect(parent, node, "bridge", md);
        }
      }
      if (!parent.isBarrier() && !child.isBarrier()) {
        if (node.isBarrier()) {
          throw Error("Can't insert a barrier between two non-barriers");
        } else {
          md = this.disconnect(parent, child, "normal");
          this.connect(parent, node, "normal", md);
          this.connect(node, child, "normal", md);
          md = this.disconnect(parent, child, "bridge");
          this.connect(parent, node, "bridge", md);
          return this.connect(node, child, "bridge", md);
        }
      }
    };

    Flow.prototype.findByClass = function(klass) {
      return this.find(function(n) {
        return _.isType(n, klass);
      });
    };

    Flow.prototype.findOne = function(f) {
      return this.find(f)[0];
    };

    Flow.prototype.find = function(f) {
      var ret;
      ret = [];
      this.graph.dfs(function(node) {
        if (f(node)) {
          return ret.push(node);
        }
      });
      return ret;
    };

    Flow.prototype.nodeFromId = function(id) {
      var nodes;
      nodes = this.graph.nodes(function(node) {
        return node.id === id;
      });
      if (nodes.length) {
        return nodes[0];
      } else {
        return null;
      }
    };

    Flow.prototype.nodes = function() {
      return this.graph.nodes();
    };

    Flow.prototype.edges = function() {
      var args, _ref;
      args = 1 <= arguments.length ? __slice.call(arguments, 0) : [];
      return (_ref = this.graph).edges.apply(_ref, args);
    };

    Flow.prototype.connect = function(from, to, type, weight) {
      if (type == null) {
        type = "normal";
      }
      if (weight == null) {
        weight = null;
      }
      if (weight == null) {
        if (this.graph.edgeExists(from, to, type)) {
          weight = 1 + this.graph.metadata(from, to, type);
        } else {
          weight = 1;
        }
      }
      this.graph.connect(from, to, type, weight);
      this.log("connected " + from.name + " -> " + to.name + " type " + type);
      return this;
    };

    Flow.prototype.connectBridge = function(from, to) {
      if (from.isBarrier()) {
        throw Error();
      }
      if (to.isBarrier()) {
        throw Error();
      }
      this.connect(from, to, "bridge");
      return this;
    };

    Flow.prototype.disconnect = function(from, to, type) {
      if (type == null) {
        type = "normal";
      }
      this.log("disconnected " + from.name + " -> " + to.name + " type " + type);
      return this.graph.disconnect(from, to, type);
    };

    Flow.prototype.edgeWeight = function(from, to, type) {
      if (type == null) {
        type = "normal";
      }
      return this.graph.metadata(from, to, type) || 0;
    };

    Flow.prototype.children = function(node) {
      return this.graph.children(node, "normal");
    };

    Flow.prototype.bridgedChildren = function(node) {
      return this.graph.children(node, "bridge");
    };

    Flow.prototype.parents = function(node) {
      return this.graph.parents(node, "normal");
    };

    Flow.prototype.bridgedParents = function(node) {
      return this.graph.parents(node, "bridge");
    };

    Flow.prototype.isAncestor = function(anc, desc) {
      var f, found;
      if (anc === desc) {
        return false;
      }
      found = false;
      f = function(n) {
        if (n === desc) {
          return found = true;
        }
      };
      this.graph.dfs(f, anc);
      return found;
    };

    Flow.prototype.inputPorts = function(parent, node) {
      var idxs, pids,
        _this = this;
      pids = _.map(this.parents(node), function(p) {
        var weight;
        weight = _this.edgeWeight(p, node);
        return _.times(weight, function() {
          return p.id;
        });
      });
      pids = _.flatten(pids);
      idxs = [];
      _.each(pids, function(pid, idx) {
        if (pid === parent.id) {
          return idxs.push(idx);
        }
      });
      return idxs;
    };

    Flow.prototype.outputPorts = function(node, child) {
      var cids, idxs,
        _this = this;
      if (child == null) {
        child = null;
      }
      cids = _.map(this.children(node), function(c) {
        var weight;
        weight = _this.edgeWeight(node, c);
        return _.times(weight, function() {
          return c.id;
        });
      });
      cids = _.flatten(cids);
      idxs = [];
      _.each(cids, function(cid, idx) {
        if (!(child != null) || cid === child.id) {
          return idxs.push(idx);
        }
      });
      return idxs;
    };

    Flow.prototype.sources = function() {
      return this.graph.sources();
    };

    Flow.prototype.sinks = function() {
      return this.graph.sinks();
    };

    Flow.prototype.findPath = function(from, to) {
      var path, search,
        _this = this;
      search = function(node, path) {
        var child, result, _i, _len, _ref;
        if (path == null) {
          path = [];
        }
        path.push(node);
        if (node.id === to.id) {
          return path;
        }
        _ref = _this.children(node);
        for (_i = 0, _len = _ref.length; _i < _len; _i++) {
          child = _ref[_i];
          result = search(child, path);
          if (result != null) {
            return result;
          }
        }
        path.pop();
        return null;
      };
      path = search(from);
      return path;
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

    Flow.prototype.merge = function(specOrNode) {
      return this.setChild(gg.wf.Merge, specOrNode);
    };

    Flow.prototype.barrier = function(specOrNode) {
      return this.setChild(gg.wf.Barrier, specOrNode);
    };

    Flow.prototype.multicast = function(specOrNode) {
      return this.setChild(gg.wf.Multicast, specOrNode);
    };

    Flow.prototype.extend = function(nodes) {
      var _this = this;
      return _.each(_.compact(nodes), function(node) {
        return _this.setChild(null, node);
      });
    };

    Flow.prototype.setChild = function(klass, specOrNode) {
      var node, parents, prevNode, prevNonBarrierNode, sinks;
      if (specOrNode == null) {
        specOrNode = {};
      }
      if (_.isType(specOrNode, gg.wf.Node)) {
        node = specOrNode;
      } else if (_.isFunction(specOrNode)) {
        node = new klass({
          params: {
            compute: specOrNode
          }
        });
      } else {
        node = new klass(specOrNode);
      }
      this.log("setChild: " + node.name + " " + node.id);
      sinks = this.sinks();
      if (sinks.length > 1) {
        throw Error("setChild only works for non-forking flows");
      }
      if (sinks.length > 0) {
        prevNode = prevNonBarrierNode = sinks[0];
      }
      if (prevNode != null) {
        while (prevNonBarrierNode.isBarrier()) {
          parents = this.parents(prevNonBarrierNode);
          if (parents.length !== 1) {
            throw Error("");
          }
          prevNonBarrierNode = parents[0];
        }
        this.connect(prevNode, node);
        this.connectBridge(prevNonBarrierNode, node);
      }
      this.add(node);
      return this;
    };

    Flow.prototype.prepend = function(node) {
      var _this = this;
      return _.each(this.sources(), function(source) {
        _this.connect(node, source);
        return _this.connectBridge(node, source);
      });
    };

    Flow.prototype.setupRPC = function(runner, uri) {
      var rpc,
        _this = this;
      rpc = new gg.wf.RPC({
        params: {
          uri: uri
        }
      });
      rpc.on("register", function(status) {
        _this.log("flow registered!");
        return runner.run();
      });
      rpc.on("runflow", function(nodeid, outport, outputs) {
        var node;
        node = _this.nodeFromId(nodeid);
        if (node != null) {
          _this.log.warn("runflow result: " + [node.name, nodeid, outport, node.location]);
        }
        _this.log(outputs);
        return runner.ch.routeNodeResult(nodeid, outport, outputs);
      });
      runner.ch.xferControl = function(nodeid, outport, outputs) {
        return rpc.run(_this.id, nodeid, outport, outputs);
      };
      runner.on("done", function() {
        return rpc.deregister(_this);
      });
      return rpc.register(this);
    };

    Flow.prototype.run = function(graphicOpts) {
      var json, onConnect, onErr, runner, start, uri,
        _this = this;
      if (graphicOpts == null) {
        graphicOpts = new gg.core.Options;
      }
      if (!_.all(this.sources(), function(s) {
        return s.type === 'start';
      })) {
        start = new gg.wf.Start;
        this.prepend(start);
      }
      if (this.sources().length !== 1) {
        throw Error();
      }
      this.instantiate();
      if (this.log.level <= gg.util.Log.DEBUG) {
        json = this.portGraph.toJSON(null, function(fr, to, type, md) {
          return "\t" + fr.n.name + "(" + fr.p + ") -> " + to.n.name + "(" + to.p + ")";
        });
        this.log("Flow Graph:");
        this.log(this.toString());
        this.log("Port Graph:");
        this.log(json.links.join("\n"));
      }
      runner = new gg.wf.Runner(this, null);
      runner.on("output", function(nodeid, outport, data) {
        return _this.emit("output", outport, data);
      });
      runner.on("done", function(debug) {
        _this.debug = debug;
        return _this.emit("done", debug);
      });
      this.log("created runner");
      uri = graphicOpts.serverURI;
      onConnect = function() {
        _this.log.warn("connected to server at " + uri);
        return _this.setupRPC(runner, uri);
      };
      onErr = function() {
        _this.log.warn("error connecting to server at " + uri);
        return runner.run();
      };
      this.log("checking rpc connection");
      return gg.wf.RPC.checkConnection(uri, onConnect, onErr);
    };

    return Flow;

  })(events.EventEmitter);

  gg.facet.base.Facets = (function() {

    Facets.ggpackage = "gg.facet.base.Facets";

    Facets.row2facetId = function(row) {
      return "facet-" + (row.get('facet-x')) + "-" + (row.get('facet-y'));
    };

    Facets.getFacetId = function(x, y) {
      return "facet-" + x + "-" + y;
    };

    function Facets(g, spec) {
      var layoutParams;
      this.g = g;
      this.spec = spec != null ? spec : {};
      this.log = gg.util.Log.logger(this.ggpackage, "Facets");
      this.parseSpec();
      this.labeler = this.labelerNodes();
      this.trainer = new gg.scale.train.Master({
        name: 'facet_train'
      }).compile();
      layoutParams = this.layoutParams.clone();
      layoutParams.put('klassname', 'gg.facet.grid.Layout');
      this.layout1 = new gg.facet.base.Layout({
        name: 'facet-layout1',
        params: this.layoutParams
      }).compile();
      this.layout2 = new gg.facet.base.Layout({
        name: 'facet-layout2',
        params: this.layoutParams
      }).compile();
      this.render = new gg.facet.base.Render({
        name: 'facet-render',
        params: this.renderParams
      }).compile();
    }

    Facets.prototype.parseSpec = function() {
      var layoutConfig, renderConfig, splitConfig;
      splitConfig = {
        x: null,
        y: null,
        scales: 'fixed',
        type: 'grid',
        sizing: 'fixed',
        options: this.g.options
      };
      layoutConfig = {
        showXAxis: {
          names: ['showx'],
          "default": true
        },
        showYAxis: {
          names: 'showy',
          "default": true
        },
        ncol: null,
        nrow: null,
        paddingPane: {
          name: 'padding',
          "default": 5
        },
        margin: 1,
        options: this.g.options
      };
      renderConfig = {
        fXLabel: {
          names: ['xlabel'],
          "default": 'x facets'
        },
        fYLabel: {
          names: ['ylabel'],
          "default": 'y facets'
        },
        cssClass: {
          names: ['facetclass', 'class'],
          "default": ''
        },
        showXTicks: true,
        showYTicks: true,
        options: this.g.options,
        location: "client"
      };
      this.splitParams = new gg.util.Params(gg.parse.Parser.extractWithConfig(this.spec, splitConfig));
      this.layoutParams = new gg.util.Params(gg.parse.Parser.extractWithConfig(this.spec, layoutConfig));
      return this.renderParams = new gg.util.Params(gg.parse.Parser.extractWithConfig(this.spec, renderConfig));
    };

    Facets.prototype.labelerNodes = function() {
      var f, log;
      log = this.log;
      f = function(pairtable, params) {
        var mapping, md, t, xcol, ycol;
        t = pairtable.left();
        md = pairtable.right();
        xcol = params.get('x');
        ycol = params.get('y');
        mapping = [
          {
            alias: ['facet-x', 'facet-y'],
            f: function(xfacet, yfacet) {
              return {
                'facet-x': xfacet,
                'facet-y': yfacet
              };
            },
            type: data.Schema.ordinal,
            cols: [xcol, ycol]
          }
        ];
        t = t.project(mapping, true);
        pairtable.left(t);
        pairtable = pairtable.ensure(['facet-x', 'facet-y']);
        return pairtable;
      };
      return gg.wf.SyncBarrier.create(f, this.splitParams, 'facet-labeler');
    };

    Facets.fromSpec = function(g, spec) {
      var klass;
      klass = (function() {
        switch (spec.type) {
          case "grid":
            return gg.facet.grid.Facets;
          default:
            return gg.facet.grid.Facets;
        }
      })();
      return new klass(g, spec);
    };

    return Facets;

  })();

  gg.layer.Layers = (function() {

    Layers.ggpackage = "gg.layer.Layers";

    function Layers(g, spec) {
      this.g = g;
      this.spec = spec;
      this.layers = [];
      this.log = gg.util.Log.logger(this.constructor.ggpackage, "Layers");
      this.parseSpec();
    }

    Layers.prototype.parseSpec = function() {
      var _this = this;
      return _.each(this.spec, function(layerspec) {
        return _this.addLayer(layerspec);
      });
    };

    Layers.prototype.compile = function() {
      var _this = this;
      return _.map(this.layers, function(l) {
        var nodes;
        nodes = l.compile();
        return nodes;
      });
    };

    Layers.prototype.getLayer = function(layerIdx) {
      if (layerIdx >= this.layers.length) {
        throw Error("Layer with idx " + layerIdx + " does not exist.        Max layer is " + this.layers.length);
      }
      return this.layers[layerIdx];
    };

    Layers.prototype.get = function(layerIdx) {
      return this.getLayer(layerIdx);
    };

    Layers.prototype.addLayer = function(layerOrSpec) {
      var layer, layerIdx, spec;
      layerIdx = this.layers.length;
      if (_.isType(layerOrSpec, gg.layer.Layer)) {
        layer = layerOrSpec;
      } else {
        spec = _.clone(layerOrSpec);
        spec.layerIdx = layerIdx;
        layer = gg.layer.Layer.fromSpec(this.g, spec);
      }
      layer.layerIdx = layerIdx;
      return this.layers.push(layer);
    };

    return Layers;

  })();

  gg.coord.Coordinate = (function(_super) {

    __extends(Coordinate, _super);

    function Coordinate() {
      return Coordinate.__super__.constructor.apply(this, arguments);
    }

    Coordinate.ggpackage = "gg.coord.Coordinate";

    Coordinate.log = gg.util.Log.logger(Coordinate.ggpackage);

    Coordinate.prototype.compute = function(pairtable, params) {
      throw Error("" + this.name + ".compute() not implemented");
    };

    Coordinate.klasses = function() {
      var klasses, ret;
      klasses = [gg.coord.Identity, gg.coord.YFlip, gg.coord.XFlip, gg.coord.Flip, gg.coord.Swap];
      ret = {};
      _.each(klasses, function(klass) {
        var alias, _i, _len, _ref, _results;
        _ref = _.flatten([klass.aliases]);
        _results = [];
        for (_i = 0, _len = _ref.length; _i < _len; _i++) {
          alias = _ref[_i];
          _results.push(ret[alias] = klass);
        }
        return _results;
      });
      return ret;
    };

    Coordinate.fromSpec = function(spec) {
      var klass, klasses;
      klasses = gg.coord.Coordinate.klasses();
      klass = klasses[spec.type];
      this.log("fromSpec: " + klass.name + "\tspec: " + (JSON.stringify(spec)));
      return new klass(spec);
    };

    return Coordinate;

  })(gg.core.XForm);

  gg.coord.YFlip = (function(_super) {

    __extends(YFlip, _super);

    function YFlip() {
      return YFlip.__super__.constructor.apply(this, arguments);
    }

    YFlip.ggpackage = "gg.coord.YFlip";

    YFlip.aliases = ["yflip"];

    YFlip.prototype.compute = function(pt) {
      this.log("map: noop");
      return pt;
    };

    return YFlip;

  })(gg.coord.Coordinate);

  gg.coord.XFlip = (function(_super) {

    __extends(XFlip, _super);

    function XFlip() {
      return XFlip.__super__.constructor.apply(this, arguments);
    }

    XFlip.ggpackage = "gg.coord.XFlip";

    XFlip.aliases = ["xflip"];

    XFlip.prototype.compute = function(pt, params) {
      var inverted, scales, table, xRange, xScale, xtype, yRange, yScale, ytype;
      table = pt.left();
      scales = this.scales(pt, params);
      inverted = scales.invert(table, gg.scale.Scale.xys);
      xtype = ytype = data.Schema.unknown;
      if (table.has('x')) {
        xtype = table.schema.type('x');
      }
      if (table.has('y')) {
        ytype = table.schema.type('y');
      }
      xScale = scales.scale('x', xtype);
      xRange = xScale.range();
      xRange = [xRange[1], xRange[0]];
      xScale.range(xRange);
      yScale = scales.scale('y', ytype);
      yRange = yScale.range();
      yRange = [yRange[1], yRange[0]];
      yScale.range(yRange);
      this.log("map: xrange: " + xRange + "\tyrange: " + yRange);
      table = scales.apply(inverted, gg.scale.Scale.xys);
      if (table.has('x0') && table.has('x1')) {
        table = table.project([
          {
            alias: 'x0',
            f: Math.min,
            type: data.Schema.numeric,
            cols: ['x0', 'x1']
          }, {
            alias: 'x1',
            f: Math.max,
            type: data.Schema.numeric,
            cols: ['x0', 'x1']
          }
        ], true);
      }
      pt.left(table);
      return pt;
    };

    return XFlip;

  })(gg.coord.Coordinate);

  gg.coord.Flip = (function(_super) {

    __extends(Flip, _super);

    function Flip() {
      return Flip.__super__.constructor.apply(this, arguments);
    }

    Flip.ggpackage = "gg.coord.Flip";

    Flip.aliases = ["flip", 'xyflip'];

    Flip.prototype.compute = function(pt, params) {
      var inverted, md, scales, table, type, xRange, xscale;
      table = pt.left();
      md = pt.right();
      scales = this.scales(pt, params);
      inverted = scales.invert(table, gg.scale.Scale.xs);
      type = table.schema.type('x');
      xscale = scales.scale('x', type);
      xRange = xscale.range();
      xscale.range([xRange[1], xRange[0]]);
      this.log("map: xrange: " + xRange);
      table = scales.apply(inverted, gg.scale.Scale.xs);
      if (table.has('x0') && table.has('x1')) {
        table = table.project([
          {
            alias: 'x0',
            f: Math.min,
            type: data.Schema.numeric,
            cols: ['x0', 'x1']
          }, {
            alias: 'x1',
            f: Math.max,
            type: data.Schema.numeric,
            cols: ['x0', 'x1']
          }
        ], true);
      }
      pt.left(table);
      return pt;
    };

    return Flip;

  })(gg.coord.Coordinate);

  gg.coord.Identity = (function(_super) {

    __extends(Identity, _super);

    function Identity() {
      return Identity.__super__.constructor.apply(this, arguments);
    }

    Identity.ggpackage = "gg.coord.Identity";

    Identity.aliases = ["identity"];

    Identity.prototype.compute = function(pt, params) {
      var mapping, md, origscale, scales, schema, table, transform, yRange, yaess, yscale;
      table = pt.left();
      md = pt.right();
      schema = table.schema;
      scales = md.any('scales');
      yscale = scales.get('y');
      origscale = yscale.clone();
      yRange = origscale.range();
      yRange = [yRange[1], yRange[0]];
      yscale.range(yRange);
      transform = function(v) {
        return yscale.scale(origscale.invert(v));
      };
      this.log(origscale.toString());
      this.log(yscale.toString());
      this.log("test transform: 500 -> " + (origscale.invert(500)) + " -> " + (transform(500)));
      yaess = _.filter(gg.scale.Scale.ys, function(aes) {
        return schema.has(aes);
      });
      mapping = _.map(yaess, function(col) {
        return {
          alias: col,
          f: transform,
          type: data.Schema.numeric,
          cols: col
        };
      });
      table = table.project(mapping, true);
      pt.left(table);
      return pt;
    };

    return Identity;

  })(gg.coord.Coordinate);

  gg.coord.Swap = (function(_super) {

    __extends(Swap, _super);

    function Swap() {
      return Swap.__super__.constructor.apply(this, arguments);
    }

    Swap.ggpackage = "gg.coord.Swap";

    Swap.aliases = ["swap"];

    Swap.prototype.compute = function(pt, params) {
      var colData, inverted, newcol, scales, table, x, xRange, xScale, xcols, xtype, y, yRange, yScale, ycols, ytype;
      table = pt.left();
      scales = this.scales(pt, params);
      xtype = ytype = data.Schema.unknown;
      if (table.has('x')) {
        xtype = table.schema.type('x');
      }
      if (table.has('y')) {
        ytype = table.schema.type('y');
      }
      xScale = scales.scale('x', xtype);
      xRange = xScale.range();
      yScale = scales.scale('y', ytype);
      yRange = yScale.range();
      inverted = scales.invert(table, gg.scale.Scale.xys);
      xcols = _.o2map(gg.scale.Scale.xs, function(x) {
        if (inverted.has(x)) {
          return [x, inverted.all(x)];
        }
      });
      ycols = _.o2map(gg.scale.Scale.ys, function(y) {
        if (inverted.has(y)) {
          return [y, inverted.all(y)];
        }
      });
      for (x in xcols) {
        colData = xcols[x];
        if (x.search('^x') >= 0) {
          newcol = "y" + (x.substr(1));
          inverted = inverted.setCol(newcol, colData, xtype, true);
        }
      }
      for (y in ycols) {
        colData = ycols[y];
        if (y.search('^y') >= 0) {
          newcol = "x" + (y.substr(1));
          inverted = inverted.setCol(newcol, colData, ytype, true);
        }
      }
      xScale.range([yRange[1], yRange[0]]);
      yScale.range(xRange);
      xScale.aes = 'y';
      yScale.aes = 'x';
      scales.set(xScale);
      scales.set(yScale);
      table = scales.apply(inverted, gg.scale.Scale.xys);
      pt.left(table);
      return pt;
    };

    return Swap;

  })(gg.coord.Coordinate);

  gg.core.Aes = (function() {

    function Aes() {}

    Aes.groupcols = ['fill', 'stroke', 'stroke-width', 'stroke-opacity', 'group', 'opacity', 'r', 'radius'];

    Aes.aliases = {
      color: ['fill', 'stroke'],
      thickness: ['stroke-width'],
      size: ['r'],
      radius: ['r'],
      opacity: ['fill-opacity', 'stroke-opacity']
    };

    Aes.resolve = function(aes) {
      if (aes in this.aliases) {
        return this.aliases[aes];
      } else {
        return [aes];
      }
    };

    Aes.groupable = function(aes) {
      return _.any(gg.core.Aes.resolve(aes), function(col) {
        return __indexOf.call(gg.core.Aes.groupcols, col) >= 0;
      });
    };

    return Aes;

  })();

  gg.core.Data = (function() {

    Data.ggpackage = "gg.core.Data";

    Data.log = gg.util.Log.logger(Data.ggpackage, "dataspec");

    function Data(defaults, layerDefaults, specs) {
      this.defaults = defaults;
      this.layerDefaults = layerDefaults;
      this.specs = specs != null ? specs : {};
      this.log = gg.util.Log.logger(gg.core.Data.ggpackage, "dataspec");
    }

    Data.fromSpec = function(spec, layerSpecs) {
      var defaults, lDefaults, specs,
        _this = this;
      if (spec == null) {
        spec = {};
      }
      if (layerSpecs == null) {
        layerSpecs = {};
      }
      defaults = this.loadSpec(spec);
      lDefaults = _.o2map(layerSpecs, function(lSpec, layerIdx) {
        return [layerIdx, _this.loadSpec(lSpec.data)];
      });
      specs = {
        spec: _.clone(spec),
        layerSpecs: _.clone(layerSpecs)
      };
      return new gg.core.Data(defaults, lDefaults, specs);
    };

    Data.loadSpec = function(spec) {
      if (spec == null) {
        return {};
      }
      if (_.isType(spec, data.Table)) {
        spec = {
          type: "table",
          val: spec
        };
      } else if (_.isArray(spec)) {
        spec = {
          type: "rows",
          val: spec
        };
      } else if (gg.core.Data.isJDBCString(spec)) {
        spec = {
          type: "jdbc",
          val: spec
        };
      } else if (gg.core.Data.isCsvString(spec)) {
        spec = {
          type: "csv",
          val: spec
        };
      } else if (_.isFunction(spec)) {
        spec = {
          type: "function",
          val: spec
        };
      } else if (!_.isObject(spec)) {
        spec = {};
      }
      spec.name = spec.name || "";
      return spec;
    };

    Data.spec2Node = function(spec) {
      var node;
      node = (function() {
        switch (spec.type) {
          case "table":
            return new gg.wf.TableSource({
              params: {
                table: spec.val
              }
            });
          case "rows":
            return new gg.wf.RowSource({
              params: {
                rows: spec.val
              }
            });
          case "csv":
            return new gg.wf.CsvSource({
              params: {
                url: spec.val
              }
            });
          case "jdbc":
          case "sql":
          case "query":
          case "db":
          case "database":
          case "postgres":
            return new gg.wf.SQLSource({
              params: spec
            });
          case "function":
            return null;
          default:
            return null;
        }
      })();
      return node;
    };

    Data.isCsvString = function(o) {
      return _.all([
        function() {
          return _.isString(o);
        }, function() {
          return /\.csv$/.test(o.toLowerCase());
        }
      ], (function(f) {
        return f();
      }));
    };

    Data.isJDBCString = function(o) {
      return _.all([
        function() {
          return _.isString(o);
        }, function() {
          return /^(postgres|mysql):\/\//.test(o.toLowerCase());
        }
      ], (function(f) {
        return f();
      }));
    };

    Data.prototype.setDefault = function(spec) {
      return this.defaults = gg.core.Data.loadSpec(spec);
    };

    Data.prototype.addLayer = function(layer) {
      var dataSpec, lIdx;
      lIdx = layer.layerIdx;
      dataSpec = layer.spec.data;
      this.layerDefaults[lIdx] = gg.core.Data.loadSpec(dataSpec);
      this.specs.layerSpecs[lIdx] = layer.spec;
      return this.log("addLayer: " + layer.spec);
    };

    Data.prototype.data = function(layerIdx) {
      var spec;
      spec = layerIdx != null ? this.layerDefaults[layerIdx] || this.defaults : this.defaults;
      this.log(spec);
      if (spec == null) {
        this.log.warn("no data defined");
        return null;
      }
      if (spec.type == null) {
        this.log.warn("spec.type not defined");
        this.log.warn(spec);
        return null;
      }
      return this.constructor.spec2Node(spec);
    };

    return Data;

  })();

  try {
    events = require('events');
  } catch (error) {
    console.log(error);
  }

  gg.core.Graphic = (function(_super) {

    __extends(Graphic, _super);

    Graphic.ggpackage = "gg.core.Graphic";

    Graphic.envKeys = ['layer', 'scales', 'scalesconfig', 'lc'];

    function Graphic(spec) {
      if (spec == null) {
        spec = null;
      }
      spec = gg.parse.Parser.parse(spec);
      this.spec(spec);
    }

    Graphic.prototype.spec = function(spec) {
      var _this = this;
      if (spec == null) {
        return this.spec;
      }
      this.spec = spec;
      gg.util.Log.reset();
      gg.util.Log.setDefaults(this.spec.debug);
      this.options = new gg.core.Options(this.spec.options);
      this.facets = gg.facet.base.Facets.fromSpec(this, this.spec.facets);
      this.layers = new gg.layer.Layers(this, this.spec.layers);
      this.scales = new gg.scale.Scales(this);
      this.datas = gg.core.Data.fromSpec(this.spec.data);
      _.each(this.layers.layers, function(layer) {
        _this.scales.scalesConfig.addLayer(layer);
        return _this.datas.addLayer(layer);
      });
      this.svg = this.options.svg || this.svg;
      this.params = new gg.util.Params({
        options: this.options
      });
      this.eventCoordinator = new events.EventEmitter;
      return this.log = gg.util.Log.logger(this.constructor.ggpackage, "core");
    };

    Graphic.prototype.pstore = function() {
      if (this.workflow != null) {
        return gg.prov.PStore.get(this.workflow);
      } else {
        this.log.warn("plot has not been compiled.  no prov store found");
        return null;
      }
    };

    Graphic.prototype.compile = function() {
      var multicast, node, preMulticastNodes, prev, wf, _i, _len;
      this.workflow = new gg.wf.Flow;
      wf = this.workflow;
      this.layoutNode = new gg.core.Layout({
        name: 'core-layout',
        params: this.params
      }).compile();
      this.renderNode = new gg.core.Render({
        name: 'core-render',
        params: this.params
      }).compile();
      preMulticastNodes = [];
      preMulticastNodes.push(this.datas.data());
      preMulticastNodes.push(this.setupEnvNode());
      preMulticastNodes = _.compact(preMulticastNodes);
      prev = null;
      for (_i = 0, _len = preMulticastNodes.length; _i < _len; _i++) {
        node = preMulticastNodes[_i];
        wf.node(node);
        if (prev != null) {
          wf.connectBridge(prev, node);
        }
        prev = node;
      }
      multicast = new gg.wf.Multicast({
        params: {
          location: "client"
        }
      });
      wf.node(multicast);
      if (prev != null) {
        wf.connectBridge(prev, multicast);
      }
      _.each(this.layers.compile(), function(nodes) {
        var _j, _k, _len1, _len2, _results;
        prev = multicast;
        for (_j = 0, _len1 = nodes.length; _j < _len1; _j++) {
          node = nodes[_j];
          wf.connect(prev, node);
          prev = node;
        }
        prev = multicast;
        _results = [];
        for (_k = 0, _len2 = nodes.length; _k < _len2; _k++) {
          node = nodes[_k];
          if (!node.isBarrier()) {
            wf.connectBridge(prev, node);
            _results.push(prev = node);
          } else {
            _results.push(void 0);
          }
        }
        return _results;
      });
      return wf;
    };

    Graphic.prototype.setupEnvNode = function() {
      return new gg.xform.EnvPut({
        name: "graphic-setupenv",
        params: {
          pairs: {
            scalesconfig: this.scales.scalesConfig,
            svg: {
              base: this.svg
            },
            event: this.eventCoordinator,
            options: this.options
          },
          location: 'client'
        }
      });
    };

    Graphic.prototype.optimize = function() {
      var optimizer;
      if (!this.options.optimize) {
        return;
      }
      optimizer = new gg.wf.Optimizer([new gg.wf.rule.RPCify, new gg.wf.rule.RmDebug, new gg.wf.rule.MergeBarrier]);
      if (this.options.guid != null) {
        optimizer.rules.push(new gg.wf.rule.Cache({
          params: {
            guid: this.options.guid
          }
        }));
      }
      return this.workflow = optimizer.run(this.workflow);
    };

    Graphic.prototype.render = function(svg, input) {
      var dataNode,
        _this = this;
      this.log("running graphic.render");
      this.log(input);
      if (svg != null) {
        this.svg = svg;
      }
      $(this.svg[0]).empty();
      this.svg = this.svg.append('svg');
      this.compile();
      if (input) {
        this.log("prepending data node");
        this.datas.setDefault(input);
        dataNode = this.datas.data();
        this.workflow.prepend(dataNode);
      }
      this.optimize();
      this.log("running workflow");
      this.workflow.on("done", function(debug) {
        return _this.emit("done", debug);
      });
      return this.workflow.run(this.options);
    };

    return Graphic;

  })(events.EventEmitter);

  gg.core.Layout = (function(_super) {

    __extends(Layout, _super);

    function Layout() {
      return Layout.__super__.constructor.apply(this, arguments);
    }

    Layout.ggpackage = "gg.core.Layout";

    Layout.prototype.compute = function(pt, params) {
      var c, facetC, fh, fw, h, lc, md, options, textSize, title, titleC, titleH, w, _ref;
      options = params.get('options');
      c = new gg.util.Bound(0, 0, options.w, options.h);
      _ref = [c.w(), c.h()], w = _ref[0], h = _ref[1];
      fw = w;
      fh = h;
      titleH = 0;
      titleC = null;
      facetC = new gg.util.Bound(0, 0, w, h);
      this.log(options);
      if (!options.minimal) {
        title = options.title;
        if (title != null) {
          textSize = _.textSize(title, {
            "class": "graphic-title",
            padding: 2
          });
          titleH = textSize.h * 1.1;
          titleC = new gg.util.Bound(w / 2, 0, w / 2, titleH);
          facetC.y0 += titleH;
        }
      }
      md = pt.right();
      lc = {};
      if (md.has('lc')) {
        lc = md.any('lc');
      }
      lc.titleC = titleC;
      lc.facetC = facetC;
      lc.baseC = c;
      md = md.setColVal('lc', lc);
      pt.right(md);
      return pt;
    };

    return Layout;

  })(gg.core.BForm);

  gg.core.Render = (function(_super) {

    __extends(Render, _super);

    function Render() {
      return Render.__super__.constructor.apply(this, arguments);
    }

    Render.ggpackage = "gg.core.Render";

    Render.prototype.parseSpec = function() {
      Render.__super__.parseSpec.apply(this, arguments);
      return this.params.put("location", 'client');
    };

    Render.prototype.compute = function(pairtable, params) {
      var c, f, facetC, facetsSvg, guideC, lc, md, options, row, svg, text, titleC;
      md = pairtable.right();
      row = md.any();
      svg = row.get('svg').base;
      lc = row.get('lc');
      if (lc == null) {
        throw Error();
      }
      c = lc.baseC;
      options = params.get('options');
      svg.attr('width', c.w()).attr('height', c.h());
      _.subSvg(svg, {
        "class": 'graphic-background',
        width: '100%',
        height: '100%'
      }, 'rect');
      titleC = lc.titleC;
      if (titleC) {
        text = _.subSvg(svg, {
          'text-anchor': 'middle',
          "class": 'graphic-title',
          dx: titleC.x0,
          dy: '1em'
        }, 'text');
        text.text(options.title);
      }
      facetC = lc.facetC;
      facetsSvg = _.subSvg(svg, {
        transform: "translate(" + facetC.x0 + "," + facetC.y0 + ")",
        width: facetC.w(),
        height: facetC.h()
      });
      guideC = lc.guideC;
      f = function(svg) {
        svg.facets = facetsSvg;
        return svg;
      };
      md = md.project([
        {
          alias: 'svg',
          cols: 'svg',
          f: f
        }
      ]);
      pairtable.right(md);
      return pairtable;
    };

    return Render;

  })(gg.core.BForm);

  gg.core.FormUtil = (function() {

    function FormUtil() {}

    FormUtil.validateInput = function(pt, params, log) {
      var iSchema, missing, table;
      table = pt.left();
      if (!(table.nrows() > 0)) {
        return true;
      }
      iSchema = params.get("inputSchema", pt, params);
      if (iSchema == null) {
        return;
      }
      missing = _.reject(iSchema, function(col) {
        return table.has(col);
      });
      if (missing.length > 0) {
        if (log != null) {
          log("" + (params.get('name')) + ": input schema did not contain " + (missing.join(",")));
          log(log.logname);
          gg.wf.Stdout.print(table, null, 5, log);
        }
        throw Error("" + (params.get('name')) + ": input schema did not contain " + (missing.join(",")));
      }
      return true;
    };

    FormUtil.addDefaults = function(pt, params, log) {
      var defaults, mapping, table;
      table = pt.left();
      defaults = params.get("defaults", pt, params);
      if (log != null) {
        log("table schema: " + (table.schema.toString()));
        log("expected:     " + (JSON.stringify(defaults)));
      }
      mapping = _.map(defaults, function(v, k) {
        var f;
        if (k === 'group') {
          if (!_.isObject(v)) {
            throw Error("group default value should be object: " + v);
          }
          log("adding:  " + k + " -> " + v);
          f = function(group, idx) {
            var newv;
            newv = _.clone(v);
            if (group != null) {
              _.extend(newv, group);
            }
            return newv;
          };
          return {
            alias: k,
            f: f,
            cols: 'group'
          };
        }
        if (table.has(k)) {
          return null;
        } else {
          log("adding:  " + k + " -> " + v);
          return _.mapToFunction(table, k, v);
        }
      });
      mapping = _.compact(mapping);
      table = table.project(mapping, true);
      pt.left(table);
      return pt;
    };

    FormUtil.ensureScales = function(pt, params, log) {
      var f, md;
      md = pt.right();
      if (!(md.nrows() <= 1)) {
        log("@scales called with multiple rows: " + (md.nrows()));
      }
      if (md.nrows() === 0) {
        log("@scales called with no md rows");
        log(pt.left().raw());
        throw Error("@scales called with no md rows");
      }
      if (!md.has('scalesconfig')) {
        md = md.setColVal('scalesconfig', gg.scale.Config.fromSpec({}));
      }
      if (!md.has('scales')) {
        f = function(row) {
          var config, layer;
          if (row.get('scales') != null) {
            return row.get('scales');
          }
          layer = row.get('layer');
          config = row.get('scalesconfig');
          return config.scales(layer);
        };
        md = md.project([
          {
            alias: 'scales',
            f: f,
            type: data.Schema.object
          }
        ], true);
        pt.right(md);
        return pt;
      } else {
        return pt;
      }
    };

    FormUtil.scales = function(pt, params, log) {
      var config, layer, md, row, scaleset;
      md = pt.right();
      if (!(md.nrows() <= 1)) {
        log.warn("@scales called with multiple rows: " + (md.raw()));
      }
      if (md.nrows() === 0) {
        throw Error("@scales called with no md rows");
      }
      if (md.has('scales')) {
        return md.any('scales');
      } else {
        row = md.any();
        layer = row.get('layer');
        config = row.get('scalesconfig');
        scaleset = config.scales(layer);
        md = md.setColVal('scales', scaleset);
        pt.right(md);
        return scaleset;
      }
    };

    return FormUtil;

  })();

  gg.facet.base.Layout = (function(_super) {

    __extends(Layout, _super);

    function Layout() {
      return Layout.__super__.constructor.apply(this, arguments);
    }

    Layout.ggpackage = "gg.facet.base.Layout";

    Layout.prototype.parseSpec = function() {
      Layout.__super__.parseSpec.apply(this, arguments);
      return this.params.ensureAll({
        showXAxis: [[], true],
        showYAxis: [[], true],
        paddingPane: [[], 5],
        margin: [[], 1],
        options: [[], {}]
      });
    };

    Layout.prototype.getTitleHeight = function(params, css) {
      if (css == null) {
        css = {};
      }
      return _.exSize(css).h;
    };

    Layout.prototype.getMaxText = function(sets, aes) {
      var formatter, scale, set, text, v, _i, _j, _len, _len1, _ref, _text;
      text = '100';
      formatter = d3.format(',.0f');
      for (_i = 0, _len = sets.length; _i < _len; _i++) {
        set = sets[_i];
        scale = set.scale(aes, data.Schema.unknown);
        if (scale.type === data.Schema.numeric) {
          _ref = scale.domain();
          for (_j = 0, _len1 = _ref.length; _j < _len1; _j++) {
            v = _ref[_j];
            if (_.isNumber(v)) {
              _text = formatter(v);
            } else {
              _text = String(v);
            }
            if ((_text != null) && _text.length > text.length) {
              text = _text;
            }
          }
        }
      }
      return text;
    };

    Layout.prototype.layoutLabels = function(md, params, lc) {
      var Bound, container, em, h, nxs, nys, options, paddingPane, plotC, plotH, plotW, showXAxis, showXFacet, showYAxis, showYFacet, titleH, toffset, w, xAxisLabelC, xFacetLabelC, xFacetlabelC, xs, yAxisLabelC, yFacetLabelC, yFacetlabelC, yoffset, ys, _ref, _ref1;
      options = params.get('options');
      container = lc.facetC;
      _ref = [container.w(), container.h()], w = _ref[0], h = _ref[1];
      Bound = gg.util.Bound;
      _ref1 = md.all(['facet-x', 'facet-y']), xs = _ref1[0], ys = _ref1[1];
      xs = _.uniq(xs);
      ys = _.uniq(ys);
      nxs = xs.length;
      nys = ys.length;
      showXFacet = !(xs.length === 1 && !(xs[0] != null));
      showYFacet = !(ys.length === 1 && !(ys[0] != null));
      showXAxis = params.get('showXAxis');
      showYAxis = params.get('showYAxis');
      paddingPane = params.get('paddingPane');
      if (!options.minimal) {
        titleH = this.getTitleHeight(params);
        em = _.textSize("fl", {
          padding: 3
        }).h;
        this.log("title size: " + titleH);
        this.log("em size: " + em);
        plotW = w;
        if (showYAxis) {
          plotW -= paddingPane + titleH;
        }
        if (showYFacet) {
          plotW -= paddingPane + titleH;
        }
        plotH = h;
        if (showXAxis) {
          plotH -= paddingPane + titleH;
        }
        if (showXFacet) {
          plotH -= paddingPane + titleH;
        }
        toffset = 0;
        if (showXFacet) {
          toffset += paddingPane + titleH;
        }
        yoffset = 0;
        if (showYAxis) {
          yoffset += paddingPane + titleH;
        }
        plotC = new Bound(0, 0, plotW, plotH);
        plotC.d(yoffset, toffset);
        container = new gg.facet.pane.Container(plotC, 0, 0, "", "", showXFacet, showYFacet, showXAxis, showYAxis, {
          labelHeight: em,
          padding: 3
        });
        xFacetLabelC = container.xFacetC();
        xFacetLabelC.d((w - 2 * titleH) / 2, 0);
        yFacetLabelC = container.yFacetC();
        yFacetLabelC = new Bound(yFacetLabelC.x0, plotH / 2 + (paddingPane + titleH), yFacetLabelC.x0 + yFacetLabelC.w(), (plotH / 2 + (paddingPane + titleH)) + yFacetLabelC.h());
        yFacetLabelC.d(-em / 2, 0);
        xAxisLabelC = container.xAxisC();
        xAxisLabelC.d((w - 2 * titleH) / 2, em / 2);
        yAxisLabelC = container.yAxisC();
        yAxisLabelC = new Bound(yAxisLabelC.x0, plotH / 2 + (paddingPane + titleH), yAxisLabelC.x0 + yAxisLabelC.w(), (plotH / 2 + (paddingPane + titleH)) + yAxisLabelC.h());
        this.log("yAxisLabelC: " + (yAxisLabelC.toString()));
        if (!showXFacet) {
          xFacetlabelC = null;
        }
        if (!showYFacet) {
          yFacetlabelC = null;
        }
        if (!showXAxis) {
          xAxisLabelC = null;
        }
        if (!showYAxis) {
          yAxisLabelC = null;
        }
        plotC = container.drawC();
      } else {
        xFacetLabelC = null;
        yFacetLabelC = null;
        xAxisLabelC = null;
        yAxisLabelC = null;
        plotC = new Bound(0, 0, w, h);
      }
      lc.background = container.clone();
      lc.xFacetLabelC = xFacetLabelC;
      lc.yFacetLabelC = yFacetLabelC;
      lc.xAxisLabelC = xAxisLabelC;
      lc.yAxisLabelC = yAxisLabelC;
      lc.plotC = plotC;
      this.log("background: " + (container.toString()));
      this.log("plot area: " + (plotC.toString()));
      return md;
    };

    Layout.prototype.compute = function(pairtable, params) {
      var lc, md;
      pairtable = pairtable.ensure(['facet-x', 'facet-y']);
      md = pairtable.right();
      lc = md.any('lc');
      md = this.layoutLabels(md, params, lc);
      md = this.layoutPanes(md, params, lc);
      pairtable.right(md);
      return pairtable;
    };

    return Layout;

  })(gg.core.BForm);

  gg.facet.base.Render = (function(_super) {

    __extends(Render, _super);

    function Render() {
      return Render.__super__.constructor.apply(this, arguments);
    }

    Render.ggpackage = "gg.facet.base.Render";

    Render.prototype.parseSpec = function() {
      Render.__super__.parseSpec.apply(this, arguments);
      this.params.ensureAll({
        'svg': [[], this.spec.svg],
        'fXLabel': [[], 'x facet'],
        'fYLabel': [[], 'y facet']
      });
      return this.params.put("location", "client");
    };

    Render.prototype.renderLabels = function(md, params, lc) {
      var b2translate, bgC, c, fXLabel, fYLabel, hRatio, matrix, options, plotC, plotSvg, svg, transform, wRatio, xalC, xflC, yalC, yalSvg, yflC, _i, _len, _ref;
      options = params.get('options');
      fXLabel = params.get('fXLabel');
      fYLabel = params.get('fYLabel');
      svg = md.any('svg').facets;
      bgC = lc.background;
      xflC = lc.xFacetLabelC;
      yflC = lc.yFacetLabelC;
      xalC = lc.xAxisLabelC;
      yalC = lc.yAxisLabelC;
      plotC = lc.plotC;
      b2translate = function(b) {
        return "transform(" + b.x0 + "," + b.y0 + ")";
      };
      if (yalC != null) {
        this.log("yalC " + (yalC.toString()));
      }
      if (xalC != null) {
        this.log("xalC " + (xalC.toString()));
      }
      _.subSvg(svg, {
        "class": 'plot-background',
        width: bgC.w(),
        height: bgC.h()
      }, 'rect');
      wRatio = plotC.w() / bgC.w();
      hRatio = plotC.h() / bgC.h();
      transform = "" + (b2translate(plotC)) + "scale(" + wRatio + "," + hRatio + ")";
      matrix = "" + wRatio + ",0,0," + hRatio + "," + plotC.x0 + "," + plotC.y0;
      plotSvg = _.subSvg(svg, {
        transform: "matrix(" + matrix + ")",
        "class": 'graphic-with-margin',
        container: plotC.toString()
      });
      if ((xflC != null) && xflC.v()) {
        _.subSvg(svg, {
          transform: "translate(" + xflC.x0 + ", " + xflC.y0 + ")",
          "class": 'facet-title x-facet-title'
        }).append('text').text(fXLabel).attr("dy", "1em").attr('text-anchor', 'middle');
      }
      if ((yflC != null) && yflC.v()) {
        c = _.subSvg(svg, {
          transform: "translate(" + yflC.x0 + ", " + yflC.y0 + ")",
          "class": 'facet-title y-facet-title',
          container: yflC.toString()
        });
        _.subSvg(c, {
          "text-anchor": "middle",
          transform: "rotate(90)",
          y: 0,
          dy: ".5em"
        }, 'text').text(fYLabel);
      }
      if ((xalC != null) && xalC.v()) {
        _.subSvg(svg, {
          transform: "translate(" + xalC.x0 + "," + xalC.y0 + ")",
          "class": "x-axis-container"
        }).append('text').text(options.xaxis).attr('text-anchor', 'middle').attr("dy", "-1em");
      }
      if ((yalC != null) && yalC.v()) {
        yalSvg = _.subSvg(svg, {
          transform: "translate(" + yalC.x0 + "," + yalC.y0 + ")",
          "class": "y-axis-container",
          container: yalC.toString()
        });
        _.subSvg(yalSvg, {
          transform: "rotate(-90)",
          'text-anchor': 'middle',
          y: 0,
          dy: "1em"
        }, 'text').text(options.yaxis);
      }
      _ref = md.all('svg');
      for (_i = 0, _len = _ref.length; _i < _len; _i++) {
        svg = _ref[_i];
        svg.plot = plotSvg;
      }
      return md;
    };

    Render.prototype.compute = function(pairtable, params) {
      var lc, md;
      md = pairtable.right();
      lc = md.any('lc');
      md = this.renderLabels(md, params, lc);
      md = md.setColVal('lc', lc);
      pairtable.right(md);
      return pairtable;
    };

    Render.fromSpec = function(spec) {
      return new gg.facet.grid.Render(spec);
    };

    return Render;

  })(gg.core.BForm);

  gg.facet.grid.Facets = (function(_super) {

    __extends(Facets, _super);

    Facets.ggpackage = "gg.facet.grid.Facets";

    function Facets() {
      Facets.__super__.constructor.apply(this, arguments);
      this.layout1 = new gg.facet.grid.Layout({
        name: 'facet-layout1',
        params: this.layoutParams
      }).compile();
      this.layout2 = new gg.facet.grid.Layout({
        name: 'facet-layout2',
        params: this.layoutParams
      }).compile();
      this._renderpanes = new gg.facet.pane.Svg({
        name: 'render-panes'
      }).compile();
    }

    Facets.prototype.renderPanes = function() {
      return this._renderpanes;
    };

    return Facets;

  })(gg.facet.base.Facets);

  gg.facet.grid.Layout = (function(_super) {

    __extends(Layout, _super);

    function Layout() {
      return Layout.__super__.constructor.apply(this, arguments);
    }

    Layout.ggpackage = "gg.facet.grid.Layout";

    Layout.prototype.layoutPanes = function(md, params, lc) {
      var container, css, facetKeys, grid, h, labelHeight, log, mapping, nxs, nys, paddingPane, sets, showXAxis, showXFacet, showYAxis, showYFacet, tmp, w, xAxisW, xFacet, xdims, xs, xytable, yAxisW, yFacet, ydims, ys, _ref, _ref1;
      xFacet = 'facet-x';
      yFacet = 'facet-y';
      facetKeys = [xFacet, yFacet];
      paddingPane = params.get('paddingPane');
      showXAxis = params.get('showXAxis');
      showYAxis = params.get('showYAxis');
      log = this.log;
      container = lc.plotC;
      _ref = [container.w(), container.h()], w = _ref[0], h = _ref[1];
      _ref1 = md.all([xFacet, yFacet, 'scales']), xs = _ref1[0], ys = _ref1[1], sets = _ref1[2];
      xs = _.uniq(xs);
      ys = _.uniq(ys);
      sets = _.uniq(sets, function(set) {
        return set.id;
      });
      nxs = xs.length;
      nys = ys.length;
      xytable = data.ops.Util.cross({
        'facet-x': xs,
        'facet-y': ys
      });
      css = {
        'font-size': '10pt'
      };
      labelHeight = _.exSize().h;
      showXFacet = xs.length > 1 && (xs[0] != null);
      showYFacet = ys.length > 1 && (ys[0] != null);
      xdims = _.textSize(this.getMaxText(sets, 'x'), css);
      ydims = _.textSize(this.getMaxText(sets, 'y'), css);
      yAxisW = ydims.w + paddingPane;
      xAxisW = xdims.w + paddingPane;
      log("paddingpane: " + paddingPane);
      log("facetxs:     " + xs);
      log("facetys:     " + ys);
      log("labelHeight: " + labelHeight);
      grid = new gg.facet.grid.PaneGrid(xs, ys, {
        showXFacet: showXFacet,
        showYFacet: showYFacet,
        showXAxis: showXAxis,
        showYAxis: showYAxis,
        labelHeight: labelHeight,
        yAxisW: yAxisW,
        xAxisW: xAxisW
      });
      grid.layout(w, h);
      tmp = new data.PairTable(xytable, md);
      tmp = tmp.ensure(facetKeys);
      md = tmp.right();
      mapping = [
        {
          alias: ['paneC', 'xfacettext-opts', 'yfacettext-opts'],
          cols: [xFacet, yFacet, 'scales'],
          f: function(x, y, set) {
            var drawC, paneC, s, xTextF, xfc, xopts, xrange, xscales, yTextF, yfc, yopts, yrange, yscales, _i, _j, _len, _len1;
            paneC = grid.getByVal(x, y);
            drawC = paneC.drawC();
            if (set != null) {
              xrange = [paddingPane, drawC.w() - 2 * paddingPane];
              yrange = [paddingPane, drawC.h() - 2 * paddingPane];
              xscales = _.compact(_.uniq(_.map(gg.scale.Scale.xs, function(col) {
                return set.get(col);
              })));
              yscales = _.compact(_.uniq(_.map(gg.scale.Scale.ys, function(col) {
                return set.get(col);
              })));
              for (_i = 0, _len = xscales.length; _i < _len; _i++) {
                s = xscales[_i];
                s.range(xrange);
              }
              for (_j = 0, _len1 = yscales.length; _j < _len1; _j++) {
                s = yscales[_j];
                s.range(yrange);
              }
            } else {
              console.log("[W] facet " + x + ", " + y + " has no scaleset");
            }
            xopts = {
              text: x,
              size: 8
            };
            yopts = {
              text: y,
              size: 8
            };
            xfc = paneC.xFacetC();
            yfc = paneC.yFacetC();
            xTextF = gg.util.Textsize.fitMany(xs, xfc.w(), xfc.h(), 8, {
              padding: 2
            });
            yTextF = gg.util.Textsize.fitMany(ys, yfc.w(), labelHeight, 8, {
              padding: 2
            });
            xopts = xTextF(x);
            yopts = yTextF(y);
            return {
              'paneC': paneC,
              'xfacettext-opts': xopts,
              'yfacettext-opts': yopts
            };
          }
        }
      ];
      md = md.project(mapping, true);
      return md;
    };

    return Layout;

  })(gg.facet.base.Layout);

  gg.facet.pane.Svg = (function(_super) {

    __extends(Svg, _super);

    function Svg() {
      return Svg.__super__.constructor.apply(this, arguments);
    }

    Svg.ggpackage = "gg.facet.pane.Svg";

    Svg.prototype.parseSpec = function() {
      Svg.__super__.parseSpec.apply(this, arguments);
      return this.params.put("location", "client");
    };

    Svg.b2translate = function(b) {
      return "translate(" + b.x0 + "," + b.y0 + ")";
    };

    Svg.prototype.b2translate = function(b) {
      return this.constructor.b2translate(b);
    };

    Svg.prototype.renderFacetPane = function(md, params) {
      var dataPaneSvg, dc, el, eventCoordinator, eventName, facetId, layerIdx, paneC, row, scaleSet, svg, xac, xfc, xscale, yac, yfc, yscale;
      row = md.any();
      svg = row.get('svg').plot;
      paneC = row.get('paneC');
      eventCoordinator = row.get('event');
      facetId = gg.facet.base.Facets.row2facetId(row);
      if (paneC == null) {
        return null;
      }
      layerIdx = row.get('layer');
      scaleSet = row.get('scales');
      dc = paneC.drawC();
      xfc = paneC.xFacetC();
      yfc = paneC.yFacetC();
      xac = paneC.xAxisC();
      yac = paneC.yAxisC();
      xscale = scaleSet.scale('x', data.Schema.unknown);
      yscale = scaleSet.scale('y', data.Schema.unknown);
      this.log("panec: " + (paneC.toString()));
      this.log("bound: " + (paneC.bound().toString()));
      this.log("drawC: " + (paneC.drawC().toString()));
      this.log("xaxis: " + (paneC.xAxisC().toString()));
      if (yfc != null) {
        this.log("yFacet:" + (yfc.toString()));
      }
      this.log("layer: " + layerIdx);
      el = _.subSvg(svg, {
        "class": "pane-container layer-" + layerIdx,
        'z-index': "" + (layerIdx + 1),
        transform: this.b2translate(paneC.bound()),
        container: paneC.bound().toString()
      });
      this.renderBg(el, dc);
      this.renderXAxis(el, dc, xac, xscale, {
        show: paneC.bXAxis
      });
      this.renderYAxis(el, dc, yac, yscale, {
        show: paneC.bYAxis
      });
      dataPaneSvg = _.subSvg(el, {
        "class": 'data-pane facet-grid',
        transform: this.b2translate(dc),
        width: dc.w(),
        height: dc.h(),
        id: "facet-grid-" + paneC.xidx + "-" + paneC.yidx
      });
      eventName = "brush-" + facetId;
      this.renderBrushes(dataPaneSvg, xscale, yscale, eventCoordinator, eventName);
      if (paneC.bXFacet) {
        this.renderXFacet(el, xfc, md);
      }
      if (paneC.bYFacet) {
        this.renderYFacet(el, yfc, md);
      }
      return el;
    };

    Svg.prototype.renderBg = function(el, container) {
      var bg;
      bg = el.insert('rect', ':first-child');
      bg.attr({
        width: container.w(),
        height: container.h(),
        transform: this.b2translate(container),
        'z-index': 0,
        "class": 'pane-background facet-grid-background'
      });
      return bg;
    };

    Svg.prototype.renderXFacet = function(el, container, md) {
      var opts, size, text, xfel;
      opts = md.any('xfacettext-opts');
      text = opts.text;
      size = opts.size;
      xfel = el.append('g');
      xfel.attr({
        "class": "facet-label x",
        transform: this.b2translate(container)
      });
      _.subSvg(xfel, {
        width: container.w(),
        height: container.h()
      }, "rect");
      return _.subSvg(xfel, {
        x: container.w() / 2,
        y: container.h(),
        dy: "-.25em",
        "text-anchor": "middle"
      }, "text").text(text).style("font-size", "" + size + "pt");
    };

    Svg.prototype.renderYFacet = function(el, container, md) {
      var opts, size, text, yfel, yftext;
      opts = md.any('yfacettext-opts');
      text = opts.text;
      size = opts.size;
      yfel = el.append('g');
      yfel.attr({
        "class": "facet-label y",
        transform: this.b2translate(container),
        container: container.toString()
      });
      _.subSvg(yfel, {
        width: container.w(),
        height: container.h()
      }, 'rect');
      return yftext = _.subSvg(yfel, {
        y: "-.25em",
        x: container.h() / 2,
        "text-anchor": "middle",
        transform: "rotate(90)"
      }, "text").text(text).style("font-size", "" + size + "pt");
    };

    Svg.prototype.renderXAxis = function(el, dc, container, xscale, tickOpts) {
      var axis, blocksize, d3scale, domain, fmtr, n, nblocks, nticks, show, tickSize, ticks, ticksizes, widthAtTick, xac2, xael, _i, _j, _len, _len1, _ref, _ref1, _ref2;
      if (tickOpts == null) {
        tickOpts = {};
      }
      xac2 = container.clone();
      xael = el.append('g');
      xael.attr({
        "class": 'axis x',
        transform: this.b2translate(xac2)
      });
      show = tickOpts.show != null ? tickOpts.show : true;
      tickSize = dc.h();
      axis = d3.svg.axis().scale(xscale.d3()).orient('bottom');
      axis.tickSize(-tickSize);
      if (!show) {
        axis.tickFormat('');
      }
      nticks = 5;
      d3scale = xscale.d3();
      domain = d3scale.domain();
      if ((_ref = xscale.type) === data.Schema.numeric || _ref === (xscale.type === data.Schema.date)) {
        fmtr = axis.tickFormat || d3scale.tickFormat;
        if ((fmtr != null) && _.isFunction(fmtr)) {
          fmtr = fmtr();
        } else {
          fmtr = String;
        }
        this.log("autotuning x axis ticks");
        this.log("tickFormat is function: " + (_.isFunction(fmtr)));
        if ((d3scale.ticks != null) && _.isFunction(fmtr)) {
          nticks = 2;
          _ref1 = _.range(1, 10);
          for (_i = 0, _len = _ref1.length; _i < _len; _i++) {
            n = _ref1[_i];
            ticks = _.map(d3scale.ticks(n), fmtr);
            ticksizes = _.map(ticks, function(tick) {
              return gg.util.Textsize.textSize(tick, {
                "class": "axis x"
              }, xael[0][0]).width;
            });
            widthAtTick = _.sum(ticksizes);
            this.log("ticks: " + (JSON.stringify(ticks)));
            this.log("sizes: " + (JSON.stringify(ticksizes)));
            this.log("width: " + widthAtTick);
            if (widthAtTick < dc.w()) {
              axis.ticks(nticks);
            } else {
              break;
            }
          }
        }
      } else if (xscale.type === data.Schema.ordinal) {
        _ref2 = _.range(1, 20);
        for (_j = 0, _len1 = _ref2.length; _j < _len1; _j++) {
          n = _ref2[_j];
          blocksize = Math.ceil(domain.length / n);
          nblocks = Math.floor(domain.length / blocksize);
          ticks = _.times(nblocks, function(block) {
            return String(domain[block * blocksize]);
          });
          ticksizes = _.map(ticks, function(tick) {
            return gg.util.Textsize.textSize(tick, {
              "class": "axis x",
              padding: 3
            }, xael[0][0]).width;
          });
          widthAtTick = _.sum(ticksizes);
          this.log("ticks: " + (JSON.stringify(ticks)));
          this.log("sizes: " + (JSON.stringify(ticksizes)));
          this.log("width: " + widthAtTick);
          if (widthAtTick < dc.w()) {
            axis.ticks(n);
            axis.tickValues(ticks);
          } else {
            break;
          }
        }
        this.log("final nticks: " + nticks);
      }
      return xael.call(axis);
    };

    Svg.prototype.renderYAxis = function(el, dc, container, yscale, tickOpts) {
      var axis, em, nticks, show, tickSize, yac2, yael;
      if (tickOpts == null) {
        tickOpts = {};
      }
      yac2 = container.clone();
      yac2.d(container.w(), 0);
      yael = el.append('g');
      yael.attr({
        "class": 'axis y',
        transform: this.b2translate(yac2)
      });
      show = tickOpts.show != null ? tickOpts.show : true;
      axis = d3.svg.axis().scale(yscale.d3()).orient('left');
      tickSize = dc.w();
      axis.tickSize(-tickSize);
      if (!show) {
        axis.tickFormat('');
      }
      this.log("yaxis type: " + yscale.type);
      this.log(yscale.toString());
      if (yscale.type === data.Schema.numeric) {
        em = _.textSize("m", {
          padding: 2,
          "class": "axis y"
        }, yael[0][0]);
        nticks = Math.min(5, Math.ceil(dc.h() / em.h));
        axis.ticks(nticks, d3.format(',.0f'), 5);
        this.log("yaxis nticks " + nticks);
      }
      return yael.call(axis);
    };

    Svg.prototype.renderBrushes = function(el, xscale, yscale, eventCoordinator, eventName) {
      var brush, brushf;
      brushf = function() {
        var bigger, maxx, maxy, minx, miny, pixelExtent, ylim, _ref, _ref1, _ref2;
        _ref = brush.extent(), (_ref1 = _ref[0], minx = _ref1[0], miny = _ref1[1]), (_ref2 = _ref[1], maxx = _ref2[0], maxy = _ref2[1]);
        minx = xscale.scale(minx);
        maxx = xscale.scale(maxx);
        ylim = Math.max(yscale.range()[0], yscale.range()[1]);
        miny = yscale.scale(miny);
        maxy = yscale.scale(maxy);
        bigger = Math.max(miny, maxy);
        miny = Math.min(miny, maxy);
        maxy = bigger;
        pixelExtent = [[minx, miny], [maxx, maxy]];
        return eventCoordinator.emit(eventName, pixelExtent);
      };
      brush = d3.svg.brush().on('brush', brushf).x(xscale.d3()).y(yscale.d3());
      return el.append('g').attr('class', 'brush').call(brush);
    };

    Svg.prototype.compute = function(pairtable, params) {
      var els, f, md, partitions, start,
        _this = this;
      md = pairtable.right();
      els = {};
      partitions = md.partition(['facet-x', 'facet-y']).all('table');
      els = _.o2map(partitions, function(p) {
        var facetId, row, svg;
        row = p.any();
        facetId = gg.facet.base.Facets.row2facetId(row);
        svg = _this.renderFacetPane(p, params);
        if (svg != null) {
          return [facetId, svg];
        }
      });
      start = Date.now();
      console.log(md.raw());
      console.log("cost = " + (Date.now() - start));
      f = function(paneC, facetx, facety, layerIdx, svg) {
        var dc, el, facetId, paneSvg;
        dc = paneC.drawC();
        facetId = gg.facet.base.Facets.getFacetId(facetx, facety);
        el = els[facetId];
        paneSvg = el.select('.data-pane').insert('g', ':last-child');
        paneSvg.attr({
          "class": 'layer-pane facet-layer-grid',
          width: dc.w(),
          height: dc.h(),
          id: "facet-grid-" + paneC.xidx + "-" + paneC.yidx + "-" + layerIdx,
          container: gg.facet.pane.Svg.b2translate(paneC.bound())
        });
        svg = _.o2map(svg, function(v, k) {
          return [k, v];
        });
        svg.pane = paneSvg;
        return svg;
      };
      md = md.project([
        {
          alias: 'svg',
          cols: ['paneC', 'facet-x', 'facet-y', 'layer', 'svg'],
          f: f,
          type: data.Schema.object
        }
      ]);
      pairtable.right(md);
      return pairtable;
    };

    return Svg;

  })(gg.core.BForm);

  gg.geom.Bin2D = (function(_super) {

    __extends(Bin2D, _super);

    function Bin2D() {
      return Bin2D.__super__.constructor.apply(this, arguments);
    }

    Bin2D.aliases = ["bin2d"];

    Bin2D.prototype.parseSpec = function() {
      var padding;
      Bin2D.__super__.parseSpec.apply(this, arguments);
      padding = +this.spec.padding || 0.0;
      this.reparam = new gg.geom.reparam.Bin2D({
        name: "bin2d-reparam",
        params: {
          padding: padding
        }
      });
      return this.render = new gg.geom.svg.Rect({});
    };

    Bin2D.prototype.posMapping = function() {
      return {
        y0: 'y',
        y1: 'y',
        x0: 'x',
        x1: 'x',
        width: 'x'
      };
    };

    return Bin2D;

  })(gg.geom.Geom);

  gg.geom.Line = (function(_super) {

    __extends(Line, _super);

    function Line() {
      return Line.__super__.constructor.apply(this, arguments);
    }

    Line.aliases = "line";

    Line.prototype.parseSpec = function() {
      Line.__super__.parseSpec.apply(this, arguments);
      this.reparam = new gg.geom.reparam.Line({
        name: "line-reparam"
      });
      return this.render = new gg.geom.svg.Line({
        name: "line-render"
      });
    };

    Line.prototype.posMapping = function() {
      return {
        y0: 'y',
        y1: 'y',
        x0: 'x',
        x1: 'x',
        width: 'x'
      };
    };

    return Line;

  })(gg.geom.Geom);

  gg.geom.Point = (function(_super) {

    __extends(Point, _super);

    function Point() {
      return Point.__super__.constructor.apply(this, arguments);
    }

    Point.aliases = ["point"];

    Point.prototype.parseSpec = function() {
      Point.__super__.parseSpec.apply(this, arguments);
      this.reparam = new gg.geom.reparam.Point({
        name: "point-reparam:" + this.layer.layerIdx
      });
      return this.render = new gg.geom.svg.Point({});
    };

    Point.prototype.posMapping = function() {
      return {
        y0: 'y',
        y1: 'y',
        x0: 'x',
        x1: 'x'
      };
    };

    return Point;

  })(gg.geom.Geom);

  gg.geom.Rect = (function(_super) {

    __extends(Rect, _super);

    function Rect() {
      return Rect.__super__.constructor.apply(this, arguments);
    }

    Rect.aliases = ["interval", "rect", 'rectangle', 'box'];

    Rect.prototype.parseSpec = function() {
      var spec;
      Rect.__super__.parseSpec.apply(this, arguments);
      spec = _.clone(this.spec);
      spec.name = "rect-reparam";
      this.reparam = new gg.geom.reparam.Rect(spec);
      return this.render = new gg.geom.svg.Rect({});
    };

    Rect.prototype.posMapping = function() {
      return {
        y0: 'y',
        y1: 'y',
        x0: 'x',
        x1: 'x',
        width: 'x'
      };
    };

    return Rect;

  })(gg.geom.Geom);

  gg.geom.svg.Point = (function(_super) {

    __extends(Point, _super);

    function Point() {
      return Point.__super__.constructor.apply(this, arguments);
    }

    Point.ggpackage = "gg.geom.svg.Point";

    Point.aliases = ["point", "pt"];

    Point.prototype.defaults = function() {
      return {
        r: 2,
        "fill-opacity": "0.5",
        fill: "steelblue",
        stroke: "steelblue",
        "stroke-width": 0,
        "stroke-opacity": 0.5
      };
    };

    Point.prototype.inputSchema = function() {
      return ['x', 'y'];
    };

    Point.brush = function(geoms) {
      return function(extent) {
        var maxx, maxy, minx, miny, _ref, _ref1;
        (_ref = extent[0], minx = _ref[0], miny = _ref[1]), (_ref1 = extent[1], maxx = _ref1[0], maxy = _ref1[1]);
        return geoms.attr('fill', function(d, i) {
          var c, fill, row, valid, x, y;
          c = d3.select(this);
          row = c.datum();
          fill = row.get('fill');
          x = row.get('x');
          y = row.get('y');
          valid = minx <= x && maxx >= x && miny <= y && maxy >= y;
          if (valid) {
            return 'black';
          } else {
            return row.get('fill');
          }
        });
      };
    };

    Point.prototype.render = function(table, svg) {
      var circles, cssOut, cssOver, enter, enterCircles, exit, rows, _this;
      rows = table.all();
      circles = svg.append('g').classed('circles geoms', true).selectAll("circle").data(rows);
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
      cssOver = {
        fill: function(t) {
          return d3.rgb(t.get("fill")).darker(2);
        },
        "fill-opacity": 1,
        r: function(t) {
          return t.get('r') + 2;
        }
      };
      cssOut = {
        fill: function(t) {
          return t.get('fill');
        },
        "fill-opacity": function(t) {
          return t.get('fill-opacity');
        },
        r: function(t) {
          return t.get('r');
        }
      };
      _this = this;
      circles.on("mouseover", function(d, idx) {
        return _this.applyAttrs(d3.select(this), cssOver);
      }).on("mouseout", function(d, idx) {
        return _this.applyAttrs(d3.select(this), cssOut);
      });
      return exit.transition().duration(500).attr("fill-opacity", 0).attr("stroke-opacity", 0).transition().remove();
    };

    return Point;

  })(gg.geom.Render);

  "use strict";


  data = require('ggdata');

  ggutil = require('ggutil');

  events = require('events');

  _ = require('underscore');

  io = require('socket.io-client');

  async = require('async');

  try {
    pg = require("pg");
  } catch (err) {
    pg = null;
  }

  exports = module.exports = this;

  _.extend(this, gg);

  fromSpec = function(spec) {
    return new gg.core.Graphic(spec);
  };

  this.gg = fromSpec;

  _.extend(this.gg, gg);

  this.gg.data = data;

  this.gg.io = io;

  gg.pos.Bin2D = (function(_super) {

    __extends(Bin2D, _super);

    function Bin2D() {
      return Bin2D.__super__.constructor.apply(this, arguments);
    }

    Bin2D.ggpackage = "gg.pos.Bin2D";

    Bin2D.aliases = ['2dbin', 'bin2d'];

    Bin2D.prototype.parseSpec = function() {
      var defaults;
      defaults = {
        nBins: 20,
        cols: ['x', 'y'],
        aggs: {
          count: {
            type: 'count',
            col: 'z'
          },
          sum: {
            type: 'sum',
            col: 'z'
          },
          r: {
            type: 'count',
            col: 'z'
          },
          total: {
            type: 'sum',
            col: 'z'
          }
        }
      };
      defaults = new gg.util.Params(defaults);
      defaults.merge(this.params);
      this.params = defaults;
      return Bin2D.__super__.parseSpec.apply(this, arguments);
    };

    return Bin2D;

  })(gg.xform.GroupBy);

  gg.pos.Dodge = (function(_super) {

    __extends(Dodge, _super);

    function Dodge() {
      return Dodge.__super__.constructor.apply(this, arguments);
    }

    Dodge.ggpackage = "gg.pos.Dodge";

    Dodge.aliases = ["dodge"];

    Dodge.prototype.defaults = function() {
      return {
        x0: 'x',
        x1: 'x'
      };
    };

    Dodge.prototype.parseSpec = function() {
      Dodge.__super__.parseSpec.apply(this, arguments);
      this.params.put('keys', ['facet-x', 'facet-y', 'layer']);
      return this.params.put("padding", _.findGoodAttr(this.spec, ['pad', 'padding'], 0.05));
    };

    Dodge.prototype.inputSchema = function() {
      return ['x', 'x0', 'x1', 'group'];
    };

    Dodge.prototype.compute = function(pairtable, params) {
      var counts, groups, maxGroup, ngroups, nrows, padding, table;
      table = pairtable.left();
      counts = table.groupby(['x0', 'x1'], data.ops.Aggregate.count('count'));
      nrows = counts.all('count');
      maxGroup = _.max(nrows);
      groups = table.partition('group');
      ngroups = groups.nrows();
      padding = params.get('padding');
      groups = groups.map(function(row, idx) {
        var group, mapping, neww, newx;
        group = row.get('table');
        neww = function(x1, x0) {
          return (x1 - x0) / ngroups;
        };
        newx = function(x1, x0, x) {
          var newWidth, width;
          width = x1 - x0;
          newWidth = width / ngroups;
          return x - width / 2 + idx * newWidth + newWidth / 2;
        };
        mapping = [
          {
            alias: 'x',
            f: newx,
            type: data.Schema.numeric,
            cols: ['x1', 'x0', 'x']
          }, {
            alias: 'x0',
            f: function(x1, x0, x) {
              return newx(x1, x0, x) - (1.0 - padding) * neww(x1, x0) / 2;
            },
            type: data.Schema.numeric,
            cols: ['x1', 'x0', 'x']
          }, {
            alias: 'x1',
            f: function(x1, x0, x) {
              return newx(x1, x0, x) + (1.0 - padding) * neww(x1, x0) / 2;
            },
            type: data.Schema.numeric,
            cols: ['x1', 'x0', 'x']
          }
        ];
        return group.project(mapping, true);
      });
      table = new data.ops.Union(groups);
      pairtable.left(table);
      return pairtable;
    };

    return Dodge;

  })(gg.core.XForm);

  gg.pos.DotPlot = (function(_super) {

    __extends(DotPlot, _super);

    function DotPlot() {
      return DotPlot.__super__.constructor.apply(this, arguments);
    }

    DotPlot.ggpackage = 'gg.pos.DotPlot';

    DotPlot.aliases = ['dot', 'dotplot'];

    DotPlot.prototype.parseSpec = function() {
      var r;
      DotPlot.__super__.parseSpec.apply(this, arguments);
      r = _.findGood([this.spec.r, this.spec.radius, this.spec.size, 3]);
      this.params.put('r', r);
      return this.params.put('keys', ['facet-x', 'facet-y', 'layer']);
    };

    DotPlot.prototype.inputSchema = function() {
      return ['x'];
    };

    DotPlot.prototype.outputSchema = function(pairtable, params) {
      var newSchema, schema;
      schema = pairtable.leftSchema().clone();
      newSchema = data.Schema.fromJSON({
        y: data.Schema.numeric,
        r: data.Schema.numeric
      });
      return schema.merge(newSchema);
    };

    DotPlot.prototype.compute = function(pairtable, params) {
      var cmp, domain, md, miny, prevx, r, s, set, sets, stacked, t, x0s, x1s, xs, y0s, y1s, ys, yscale, _i, _len;
      t = pairtable.left();
      md = pairtable.right();
      r = params.get('r');
      if (!t.has('r')) {
        t = t.setColVal('r', r);
      }
      yscale = md.any('scales').get('y', data.Schema.numeric);
      miny = yscale.range()[0];
      cmp = function(r1, r2) {
        return r1.get('x') - r2.get('x');
      };
      t = t.orderby('x');
      xs = [];
      ys = [];
      prevx = null;
      stacked = false;
      t.each(function(row) {
        var curx;
        curx = row.get('x');
        if (!_.isValid(curx)) {
          xs.push(curx);
          ys.push(null);
          return;
        }
        if (prevx === null || curx - prevx >= r * 2) {
          prevx = curx;
          xs.push(prevx);
          ys.push(r + miny);
          return stacked = false;
        } else if (curx !== prevx) {
          xs.push(prevx + (r / 2.0));
          if (stacked) {
            return ys.push(ys[ys.length - 1] + r * 2);
          } else {
            ys.push(r + miny);
            return stacked = true;
          }
        } else {
          xs.push(curx);
          ys.push(ys[ys.length - 1] + r * 2);
          return stacked = true;
        }
      });
      y0s = _.map(ys, function(y) {
        return y - r;
      });
      y1s = _.map(ys, function(y) {
        return y + r;
      });
      x0s = _.map(xs, function(x) {
        return x - r;
      });
      x1s = _.map(xs, function(x) {
        return x + r;
      });
      t = t.setCol('x', xs, data.Schema.numeric, true);
      t = t.setCol('x0', x0s, data.Schema.numeric, true);
      t = t.setCol('x1', x1s, data.Schema.numeric, true);
      t = t.setCol('y', ys, data.Schema.numeric, true);
      t = t.setCol('y0', y0s, data.Schema.numeric, true);
      t = t.setCol('y1', y1s, data.Schema.numeric, true);
      domain = [_.min(y0s), _.max(y1s)];
      sets = _.uniq(pairtable.right().all('scales'));
      for (_i = 0, _len = sets.length; _i < _len; _i++) {
        set = sets[_i];
        s = set.get('y');
        s.frozen = true;
      }
      pairtable.left(t);
      return pairtable;
    };

    return DotPlot;

  })(gg.core.XForm);

  gg.pos.Identity = (function(_super) {

    __extends(Identity, _super);

    function Identity() {
      return Identity.__super__.constructor.apply(this, arguments);
    }

    Identity.ggpackage = "gg.pos.Identity";

    Identity.aliases = ["identity"];

    Identity.prototype.compute = function(pairtable, params) {
      return pairtable;
    };

    Identity.compile = function() {
      return [];
    };

    return Identity;

  })(gg.core.XForm);

  gg.pos.Interpolate = (function(_super) {

    __extends(Interpolate, _super);

    Interpolate.ggpackage = "gg.pos.Interpolate";

    Interpolate.aliases = ["interpolate"];

    function Interpolate() {
      Interpolate.__super__.constructor.apply(this, arguments);
      this.log.level = gg.util.Log.DEBUG;
    }

    Interpolate.prototype.defaults = function() {
      return {
        y0: 0,
        x0: 'x',
        x1: 'x'
      };
    };

    Interpolate.prototype.inputSchema = function() {
      return ['x', 'y'];
    };

    Interpolate.prototype.outputSchema = function(pt, env) {
      return pt.leftSchema().clone();
    };

    Interpolate.interpolate = function(xs, pts) {
      var cur, idx, maxx, minx, perc, prev, ptsidx, ret, x, y, _i, _len;
      if (pts.length === 0) {
        return pts;
      }
      minx = _.first(pts).x;
      maxx = _.last(pts).x;
      ptsidx = 0;
      ret = [];
      for (idx = _i = 0, _len = xs.length; _i < _len; idx = ++_i) {
        x = xs[idx];
        if (x < minx || x > maxx) {
          ret.push({
            x: x,
            y: 0
          });
          continue;
        }
        while (ptsidx + 1 <= pts.length && pts[ptsidx].x < x) {
          ptsidx += 1;
        }
        if (x === pts[ptsidx].x) {
          ret.push({
            x: x,
            y: pts[ptsidx].y
          });
        } else {
          prev = pts[ptsidx - 1];
          cur = pts[ptsidx];
          perc = (x - prev.x) / (cur.x - prev.x);
          y = perc * (cur.y - prev.y) + prev.y;
          ret.push({
            x: x,
            y: y
          });
        }
      }
      return ret;
    };

    return Interpolate;

  })(gg.core.XForm);

  gg.pos.Jitter = (function(_super) {

    __extends(Jitter, _super);

    function Jitter() {
      return Jitter.__super__.constructor.apply(this, arguments);
    }

    Jitter.ggpackage = "gg.pos.Jitter";

    Jitter.aliases = "jitter";

    Jitter.prototype.inputSchema = function() {
      return ['x', 'y'];
    };

    Jitter.prototype.parseSpec = function() {
      var scale, xScale, yScale;
      Jitter.__super__.parseSpec.apply(this, arguments);
      scale = _.findGood([this.spec.scale, 0.2]);
      xScale = _.findGood([this.spec.xScale, this.spec.x, null]);
      yScale = _.findGood([this.spec.yScale, this.spec.y, null]);
      if ((xScale != null) || (yScale != null)) {
        xScale = xScale || 0;
        yScale = yScale || 0;
      } else {
        xScale = yScale = scale;
      }
      return this.params.putAll({
        xScale: xScale,
        yScale: yScale
      });
    };

    Jitter.prototype.compute = function(pairtable, params) {
      var Schema, map, md, scales, schema, table, xRange, xScale, xcols, yRange, yScale, ycols;
      table = pairtable.left();
      md = pairtable.right();
      scales = md.any('scales');
      schema = table.schema;
      xcols = _.filter(gg.scale.Scale.xs, function(col) {
        return table.has(col);
      });
      ycols = _.filter(gg.scale.Scale.ys, function(col) {
        return table.has(col);
      });
      map = [];
      Schema = data.Schema;
      xRange = scales.scale("x").range();
      xScale = (xRange[1] - xRange[0]) * params.get('xScale');
      map.push({
        alias: xcols,
        cols: xcols,
        f: function() {
          var args, col, idx, o, rand, _i, _len;
          args = 1 <= arguments.length ? __slice.call(arguments, 0) : [];
          rand = (0.5 - Math.random()) * xScale;
          o = {};
          for (idx = _i = 0, _len = xcols.length; _i < _len; idx = ++_i) {
            col = xcols[idx];
            o[col] = args[idx] + rand;
          }
          return o;
        }
      });
      yRange = scales.scale("y").range();
      yScale = (yRange[1] - yRange[0]) * params.get('yScale');
      map.push({
        alias: ycols,
        cols: ycols,
        f: function() {
          var args, col, idx, o, rand, _i, _len;
          args = 1 <= arguments.length ? __slice.call(arguments, 0) : [];
          rand = (0.5 - Math.random()) * yScale;
          o = {};
          for (idx = _i = 0, _len = ycols.length; _i < _len; idx = ++_i) {
            col = ycols[idx];
            o[col] = args[idx] + rand;
          }
          return o;
        }
      });
      table = table.project(map, true);
      pairtable.left(table);
      return pairtable;
    };

    return Jitter;

  })(gg.core.XForm);

  gg.pos.Shift = (function(_super) {

    __extends(Shift, _super);

    function Shift() {
      return Shift.__super__.constructor.apply(this, arguments);
    }

    Shift.ggpackage = "gg.pos.Shift";

    Shift.aliases = ["shift"];

    Shift.prototype.inputSchema = function() {
      return ['x', 'y'];
    };

    Shift.prototype.parseSpec = function() {
      Shift.__super__.parseSpec.apply(this, arguments);
      return this.params.putAll({
        xShift: _.findGood([this.spec.x, this.spec.amount, 10]),
        yShift: _.findGood([this.spec.y, this.spec.amount, 10])
      });
    };

    Shift.prototype.compute = function(pairtable, params) {
      var map, table, xcols, xshift, ycols, yshift;
      table = pairtable.left();
      xshift = params.get('xShift');
      yshift = params.get('yShift');
      xcols = _.filter(gg.scale.Scale.xs, function(col) {
        return table.has(col);
      });
      ycols = _.filter(gg.scale.Scale.ys, function(col) {
        return table.has(col);
      });
      map = [];
      map = map.concat(_.map(xcols, function(col) {
        return {
          alias: col,
          f: function(v) {
            return v + xshift;
          }
        };
      }));
      map = map.concat(_.map(ycols, function(col) {
        return {
          alias: col,
          f: function(v) {
            return v + yshift;
          }
        };
      }));
      table = pairtable.left().project(map, true);
      pairtable.left(table);
      return pairtable;
    };

    return Shift;

  })(gg.core.XForm);

  gg.pos.Stack = (function(_super) {

    __extends(Stack, _super);

    function Stack() {
      return Stack.__super__.constructor.apply(this, arguments);
    }

    Stack.ggpackage = "gg.pos.Stack";

    Stack.aliases = ["stack", "stacked"];

    Stack.prototype.parseSpec = function() {
      Stack.__super__.parseSpec.apply(this, arguments);
      this.params.put('keys', ['facet-x', 'facet-y', 'layer']);
      return this.params.put("padding", _.findGoodAttr(this.spec, ['pad', 'padding'], 0.05));
    };

    Stack.prototype.defaults = function() {
      return {
        y0: 0,
        y1: 'y',
        x0: 'x',
        x1: 'x'
      };
    };

    Stack.prototype.inputSchema = function() {
      return ['x', 'y'];
    };

    Stack.prototype.outputSchema = function(pairtable) {
      return pairtable.leftSchema().clone();
    };

    Stack.prototype.baselines = function(table) {
      var baselines, xs, y0s;
      baselines = {};
      xs = table.all('x');
      if (table.has('y0')) {
        y0s = table.all('y0');
        _.times(xs.length, function(idx) {
          return baselines[xs[idx]] = y0s[idx];
        });
        this.log("y0s: " + y0s.slice(0, 11));
      }
      xs = _.uniq(xs);
      xs.sort(function(a, b) {
        return a - b;
      });
      this.log("nxs: " + xs.length);
      return [baselines, xs];
    };

    Stack.prototype.compute = function(pairtable, params) {
      var baselines, groups, layers, newrows, schema, stack, stackedLayers, table, values, xs, _ref;
      table = pairtable.left();
      _ref = this.baselines(table), baselines = _ref[0], xs = _ref[1];
      layers = [];
      groups = table.partition("group").all('table');
      console.log(groups);
      values = function(group, groupidx) {
        var rows, x2row;
        x2row = {};
        group.each(function(row) {
          return x2row[row.get('x')] = {
            x: row.get('x'),
            y: row.get('y1') - (row.get('y0') || 0),
            y0: 0
          };
        });
        rows = _.map(xs, function(x) {
          if (x in x2row) {
            return x2row[x];
          } else {
            return {
              x: x,
              y: 0,
              y0: 0
            };
          }
        });
        return rows;
      };
      layers = _.map(groups, values);
      stack = d3.layout.stack();
      stackedLayers = stack(layers);
      newrows = [];
      _.each(groups, function(group, idx) {
        var layer, x2row;
        layer = stackedLayers[idx];
        x2row = {};
        group.each(function(row) {
          return x2row[row.get('x')] = row.clone();
        });
        return _.each(layer, function(pos) {
          var row, x;
          x = pos.x;
          if (x in x2row) {
            row = x2row[x];
            row.set('y0', pos.y0 + (baselines[x] || 0));
            row.set('y1', row.get('y0') + pos.y);
            row.set('y', row.get('y1'));
            if (row.has('x1')) {
              row.set('x1', row.get('x1') - row.get('x') + x);
            }
            if (row.has('x0')) {
              row.set('x0', row.get('x0') - row.get('x') + x);
            }
            row.set('x', x);
            return newrows.push(row);
          }
        });
      });
      schema = params.get('outputSchema')(pairtable, params);
      table = data.Table.fromArray(newrows, schema);
      gg.wf.Stdout.print(table, null, 5, this.log);
      pairtable.left(table);
      return pairtable;
    };

    return Stack;

  })(gg.core.XForm);

  gg.pos.Text = (function(_super) {

    __extends(Text, _super);

    function Text() {
      return Text.__super__.constructor.apply(this, arguments);
    }

    Text.ggpackage = "gg.pos.Text";

    Text.aliases = ["text"];

    Text.prototype.parseSpec = function() {
      var bFast, innerLoop, tempAttrs, temperature;
      Text.__super__.parseSpec.apply(this, arguments);
      tempAttrs = ['T', 't', 'temp', 'temperature'];
      return this.params.putAll(bFast = -_.findGood([this.spec.fast, false]), innerLoop = _.findGood([this.spec.innerLoop, 15]), temperature = _.findGoodAttr(this.spec, tempAttrs, 2.466303));
    };

    Text.prototype.inputSchema = function() {
      return ['x', 'y', 'text'];
    };

    Text.prototype.compute = function(pairtable, params) {
      var Schema, attrs, bFast, boxes, innerLoop, mapping, md, start, table, temperature;
      table = pairtable.left();
      md = pairtable.right();
      attrs = ['x', 'y', 'text'];
      boxes = table.each(function(row) {
        return [[row.get('x0'), row.get('x1')], [row.get('y0'), row.get('y1')], [row.get('x0'), row.get('y0')]];
      });
      start = Date.now();
      bFast = params.get('bFast');
      innerLoop = params.get('innerLoop');
      temperature = params.get('temperature');
      boxes = gg.pos.Text.anneal(boxes, bFast, innerLoop, temperature);
      this.log.debug("got " + boxes.length + " boxes from annealing");
      this.log.debug("took " + (Date.now() - start) + " ms");
      Schema = data.Schema;
      mapping = [
        [
          'x0', (function(x0, x1, y0, y1, idx) {
            return boxes[idx][0][0];
          })
        ], [
          'x1', (function(x0, x1, y0, y1, idx) {
            return boxes[idx][0][1];
          })
        ], [
          'y0', (function(x0, x1, y0, y1, idx) {
            return boxes[idx][1][0];
          })
        ], [
          'y1', (function(x0, x1, y0, y1, idx) {
            return boxes[idx][1][1];
          })
        ]
      ];
      mapping = _.map(mapping, function(map) {
        return {
          alias: map[0],
          f: map[1],
          type: Schema.numeric,
          cols: ['x0', 'x1', 'y0', 'y1']
        };
      });
      table = table.project(mapping, true);
      pairtable.left(table);
      return pairtable;
    };

    Text.anneal = function(boxes, bFast, innerLoop, T) {
      var bAccept, box, box2, boxIdx, cost, curOvBoxes, curOverlap, curScore, delta, findTicket, gridBounds, i, index, keyf, level, minImprovement, n, nAnneal, nImproved, newOvBoxes, newOverlap, optimalScore, overlapArr, pos2box, posIdx, positions, startScore, ticket, valf, _i, _j, _k, _len, _posIdx, _ref, _ref1, _ref2;
      if (innerLoop == null) {
        innerLoop = 10;
      }
      if (T == null) {
        T = 2.4;
      }
      for (_i = 0, _len = boxes.length; _i < _len; _i++) {
        box = boxes[_i];
        if (_.any(_.union(box[0], box[1]), _.isNaN)) {
          console.log("box is invalid: " + box);
          throw Error();
        }
        if (box.length === 2) {
          box.push([box[0][0], box[1][0]]);
        }
      }
      n = boxes.length;
      keyf = function(box) {
        return box.box;
      };
      valf = function(box) {
        return box.idx;
      };
      boxes = _.map(boxes, function(box, idx) {
        var h, w;
        w = box[0][1] - box[0][0];
        h = box[1][1] - box[1][0];
        return {
          box: box,
          idx: idx,
          pos: 0,
          bound: [[box[0][0] - w, box[0][1]], [box[1][0] - h, box[1][1]]]
        };
      });
      gridBounds = this.bounds(_.map(boxes, function(box) {
        return box.bound;
      }));
      index = new gg.util.SpatialIndex(keyf, valf).gridBounds(gridBounds).load(boxes);
      _ref = this.genPositions(), pos2box = _ref[0], positions = _ref[1];
      level = this.log.level;
      this.log.level = gg.util.Log.DEBUG;
      findTicket = function(overlaps, ticket) {
        var idx, o, _j, _len1;
        for (idx = _j = 0, _len1 = overlaps.length; _j < _len1; idx = ++_j) {
          o = overlaps[idx];
          ticket -= o;
          if (ticket <= 0) {
            return idx;
          }
        }
        throw Error();
      };
      minImprovement = 0;
      optimalScore = 0;
      for (nAnneal = _j = 0; _j < 10; nAnneal = ++_j) {
        nImproved = 0;
        overlapArr = _.map(boxes, function(box) {
          return index.get(box.box).length;
        });
        startScore = -_.sum(overlapArr) + boxes.length;
        for (i = _k = 0, _ref1 = boxes.length * innerLoop; 0 <= _ref1 ? _k < _ref1 : _k > _ref1; i = 0 <= _ref1 ? ++_k : --_k) {
          _posIdx = Math.floor(Math.random() * positions.length);
          _ref2 = positions[_posIdx], posIdx = _ref2[0], cost = _ref2[1];
          if (bFast) {
            ticket = Math.floor(Math.random() * _.sum(overlapArr));
            boxIdx = findTicket(overlapArr, ticket);
          } else {
            boxIdx = Math.floor(Math.random() * n);
          }
          box = boxes[boxIdx];
          box2 = pos2box(box, posIdx);
          curOvBoxes = index.get(box.box);
          curOverlap = curOvBoxes.length;
          newOvBoxes = index.get(box2.box);
          newOverlap = newOvBoxes.length;
          if (__indexOf.call(newOvBoxes, box2) < 0) {
            newOverlap += 1;
          }
          delta = curOverlap - newOverlap;
          if (delta > 0) {
            nImproved += 1;
          }
          bAccept = delta > 0 || Math.random() <= 1 - Math.exp(-delta / T);
          if (bAccept) {
            boxes[boxIdx] = box2;
            _.each(curOvBoxes, function(b) {
              return overlapArr[b.idx] -= 1;
            });
            _.each(curOverlap, function(b) {
              return overlapArr[b.idx] += 1;
            });
            overlapArr[box2.idx] = newOverlap;
            index.rm(box);
            index.add(box2);
          }
          if (nImproved >= n * 5) {
            this.log("nImproved " + nImproved + " >= n*5 " + (n * 5));
            break;
          }
        }
        curScore = -_.sum(_.map(boxes, function(box) {
          return index.get(box.box).length - 1;
        }));
        if (nImproved === 0) {
          this.log("n:" + nAnneal + ": nImproved: 0");
          break;
        }
        if (!(curScore > startScore + minImprovement)) {
          this.log("n:" + nAnneal + ": " + curScore + " < " + startScore);
          break;
        }
        if (curScore >= optimalScore) {
          this.log("n:" + nAnneal + ": optimal score");
          break;
        }
        this.log("n" + nAnneal + ": nImproved: " + nImproved + " score: " + startScore + " to " + curScore);
        T *= 0.9;
      }
      this.log("n:" + nAnneal + " score: " + curScore);
      this.log.level = level;
      return _.map(boxes, function(box) {
        return box.box;
      });
    };

    Text.bOverlap = function(b1, b2) {
      var maxs, mins, ret;
      mins = [b1[0][0], b1[1][0], b2[0][0], b2[1][0]];
      maxs = [b2[0][1], b2[1][1], b1[0][1], b1[1][1]];
      ret = !(_.any(_.zip(mins, maxs), (function(_arg) {
        var max, min;
        min = _arg[0], max = _arg[1];
        return min >= max;
      })));
      return ret;
    };

    Text.genPositions = function() {
      var maxCost, pos2box, posCosts, positions;
      posCosts = {
        0: 1,
        1: 1,
        2: 1,
        3: 1,
        4: 2,
        5: 2,
        6: 2,
        7: 2,
        8: 3,
        9: 3,
        10: 3,
        11: 3,
        12: 3,
        13: 3,
        14: 3,
        15: 3
      };
      maxCost = 1 + _.mmax(_.values(posCosts));
      positions = [];
      _.each(_.values(posCosts), function(cost, pos) {
        return _.times(maxCost - cost, function() {
          return positions.push([pos, cost]);
        });
      });
      pos2box = function(box, position) {
        var h, pt, w, x, y;
        x = box.box[2][0];
        y = box.box[2][1];
        w = box.box[0][1] - box.box[0][0];
        h = box.box[1][1] - box.box[1][0];
        pt = (function() {
          switch (position) {
            case 0:
              return [x, y];
            case 1:
              return [x, y - h];
            case 2:
              return [x - w, y - h];
            case 3:
              return [x - w, y];
            case 4:
              return [x - w / 2, y];
            case 5:
              return [x - w / 2, y - h];
            case 6:
              return [x, y - h / 2];
            case 7:
              return [x - w, y - h / 2];
            case 8:
              return [x - w / 4, y];
            case 9:
              return [x - w / 4, y - h];
            case 10:
              return [x, y - h / 4];
            case 11:
              return [x - w, y - h / 4];
            case 12:
              return [x - w * 3 / 4, y];
            case 13:
              return [x - w * 3 / 4, y - h];
            case 14:
              return [x, y - h * 3 / 4];
            case 15:
              return [x - w, y - h * 3 / 4];
            default:
              throw Error("position " + position + " is invalid");
          }
        })();
        return {
          box: [[pt[0], pt[0] + w], [pt[1], pt[1] + h], box.box[2]],
          idx: box.idx,
          pos: position,
          bound: box.bound
        };
      };
      return [pos2box, positions];
    };

    Text.bounds = function(boxes) {
      var f;
      f = function(memo, box) {
        memo[0][0] = Math.min(memo[0][0], box[0][0]);
        memo[0][1] = Math.max(memo[0][1], box[0][1]);
        memo[1][0] = Math.min(memo[1][0], box[1][0]);
        memo[1][1] = Math.max(memo[1][1], box[1][1]);
        return memo;
      };
      return _.reduce(boxes, f, [[Infinity, -Infinity], [Infinity, -Infinity]]);
    };

    return Text;

  })(gg.core.XForm);

  gg.scale.BaseCategorical = (function(_super) {

    __extends(BaseCategorical, _super);

    BaseCategorical.ggpackage = 'gg.scale.BaseCategorical';

    function BaseCategorical(spec) {
      this.spec = spec;
      this.type = data.Schema.ordinal;
      this.d3Scale = d3.scale.ordinal();
      this.invertScale = d3.scale.ordinal();
      this.isInterval = false;
      BaseCategorical.__super__.constructor.apply(this, arguments);
    }

    BaseCategorical.defaultDomain = function(col) {
      var vals;
      vals = _.uniq(_.flatten(col));
      return vals;
    };

    BaseCategorical.prototype.clone = function() {
      var ret;
      ret = BaseCategorical.__super__.clone.apply(this, arguments);
      ret.d3Scale = this.d3Scale.copy();
      ret.isInterval = this.isInterval;
      ret.invertScale = this.invertScale.copy();
      return ret;
    };

    BaseCategorical.prototype.defaultDomain = function(col) {
      return gg.scale.BaseCategorical.defaultDomain(col);
    };

    BaseCategorical.prototype.mergeDomain = function(domain) {
      var newDomain;
      if (domain == null) {
        domain = [];
      }
      newDomain = _.uniq(domain.concat(this.domain()));
      return this.domain(newDomain);
    };

    BaseCategorical.prototype.domain = function(interval) {
      if (interval != null) {
        this.invertScale.range(interval);
      }
      return BaseCategorical.__super__.domain.apply(this, arguments);
    };

    BaseCategorical.prototype.d3Range = function() {
      var range, rangeBand;
      range = this.d3Scale.range();
      if (this.type === data.Schema.numeric) {
        rangeBand = this.d3Scale.rangeBand();
        range = _.map(range, function(v) {
          return v + rangeBand / 2.0;
        });
      }
      return range;
    };

    BaseCategorical.prototype.range = function(interval) {
      if ((interval != null) && interval.length > 0 && !this.rangeSet) {
        if (_.isString(interval[0])) {
          this.isInterval = false;
          this.d3Scale.range(interval);
        } else if (data.Schema.type(interval[0]) === data.Schema.numeric) {
          this.isInterval = true;
          this.d3Scale.rangeBands(interval);
        } else {
          this.isInterval = true;
          this.d3Scale.rangePoints(interval);
          this.d3Scale.rangeBands(interval);
        }
        this.invertScale.domain(this.d3Range());
      }
      return this.d3Range();
    };

    BaseCategorical.prototype.resetDomain = function() {
      this.domainUpdated = false;
      if (!this.domainSet) {
        this.domain([]);
      }
      if (!this.domainSet) {
        return this.invertScale.domain([]);
      }
    };

    BaseCategorical.prototype.invert = function(v) {
      return this.invertScale(v);
    };

    BaseCategorical.prototype.valid = function(v) {
      return __indexOf.call(this.domain(), v) >= 0;
    };

    return BaseCategorical;

  })(gg.scale.Scale);

  gg.scale.ColorCont = (function(_super) {

    __extends(ColorCont, _super);

    ColorCont.ggpackage = 'gg.scale.ColorCont';

    ColorCont.aliases = ["color_cont", "colorcont"];

    function ColorCont(spec) {
      var range;
      this.spec = spec != null ? spec : {};
      this.d3Scale = d3.scale.linear();
      this.type = data.Schema.numeric;
      range = [d3.rgb(255, 255, 255), d3.rgb(2, 56, 88)];
      if (this.spec.range != null) {
        range = this.spec.range;
      }
      this.d3Scale.range(range);
      ColorCont.__super__.constructor.apply(this, arguments);
    }

    ColorCont.prototype.range = function() {
      return this.d3Scale.range();
    };

    return ColorCont;

  })(gg.scale.Scale);

  gg.scale.Color = (function(_super) {

    __extends(Color, _super);

    Color.ggpackage = 'gg.scale.Color';

    Color.aliases = "color";

    function Color(spec) {
      this.spec = spec != null ? spec : {};
      Color.__super__.constructor.apply(this, arguments);
      if (!this.rangeSet) {
        this.d3Scale = d3.scale.category10();
      }
      this.invertScale = d3.scale.ordinal();
      this.invertScale.domain(this.d3Scale.range()).range(this.d3Scale.domain());
      this.type = data.Schema.ordinal;
    }

    Color.prototype.invert = function(v) {
      return this.invertScale(v);
    };

    Color.prototype.scale = function(v) {
      return this.d3Scale(v);
    };

    return Color;

  })(gg.scale.BaseCategorical);

  gg.scale.Config = (function() {

    Config.ggpackage = 'gg.scale.Config';

    Config.log = gg.util.Log.logger(Config.ggpackage, "scaleConfig");

    function Config(defaults, layerDefaults, specs) {
      this.defaults = defaults != null ? defaults : {};
      this.layerDefaults = layerDefaults != null ? layerDefaults : {};
      this.specs = specs != null ? specs : {};
      if (!this.specs.spec) {
        this.specs.spec = {};
      }
      if (!this.specs.layerSpecs) {
        this.specs.layerSpecs = {};
      }
      this.log = gg.util.Log.logger(this.constructor.ggpackage, "scaleConfig");
    }

    Config.fromSpec = function(spec, layerSpecs) {
      var defaults, layerDefaults, specs,
        _this = this;
      if (layerSpecs == null) {
        layerSpecs = {};
      }
      this.log("spec:      " + (JSON.stringify(spec)));
      this.log("layerSpec: " + (JSON.stringify(layerSpecs)));
      defaults = gg.scale.Config.loadSpec(spec);
      layerDefaults = {};
      _.each(layerSpecs, function(layerSpec, layerIdx) {
        var layerConfig, scalesSpec;
        scalesSpec = layerSpec.scales;
        layerConfig = gg.scale.Config.loadSpec(scalesSpec);
        return layerDefaults[layerIdx] = layerConfig;
      });
      specs = {
        spec: _.clone(spec),
        layerSpecs: _.clone(layerSpecs)
      };
      return new gg.scale.Config(defaults, layerDefaults, specs);
    };

    Config.prototype.toJSON = function() {
      return this.specs;
    };

    Config.fromJSON = function(json) {
      return this.fromSpec(json.spec, json.layerSpecs);
    };

    Config.loadSpec = function(spec) {
      var ret,
        _this = this;
      ret = {};
      if (spec != null) {
        _.each(spec, function(scaleSpec, aes) {
          if (_.isString(scaleSpec)) {
            scaleSpec = {
              type: scaleSpec
            };
          }
          scaleSpec = _.clone(scaleSpec);
          return _.each(gg.core.Aes.resolve(aes), function(trueaes) {
            var scale;
            scaleSpec.aes = trueaes;
            scale = gg.scale.Scale.fromSpec(scaleSpec);
            return ret[trueaes] = scale;
          });
        });
      }
      return ret;
    };

    Config.prototype.addLayer = function(layer) {
      var config, layerIdx, layerSpec;
      layerIdx = layer.layerIdx;
      layerSpec = layer.spec;
      config = gg.scale.Config.loadSpec(layerSpec.scales);
      this.layerDefaults[layerIdx] = config;
      this.specs.layerSpecs[layerIdx] = layerSpec;
      return this.log("addLayer: " + (JSON.stringify(layerSpec.scales)));
    };

    Config.prototype.layerSpec = function(layerIdx) {
      return this.layerDefaults[layerIdx];
    };

    Config.prototype.factoryFor = function(layerIdx) {
      var defaults, factory, ldefaults, lspec;
      defaults = _.clone(this.defaults);
      ldefaults = this.layerDefaults[layerIdx] || {};
      _.extend(defaults, ldefaults);
      lspec = this.specs.layerSpecs[layerIdx];
      factory = gg.scale.Factory.fromSpec(defaults, lspec);
      gg.scale.Config.log(factory);
      return factory;
    };

    Config.prototype.scale = function(aes, type) {
      return this.factoryFor().scale(aes, type);
    };

    Config.prototype.scales = function(layerIdx) {
      return new gg.scale.Set(this.factoryFor(layerIdx));
    };

    return Config;

  })();

  gg.scale.Identity = (function(_super) {

    __extends(Identity, _super);

    Identity.ggpackage = 'gg.scale.Identity';

    Identity.aliases = "identity";

    function Identity() {
      this.d3Scale = null;
      this.type = data.Schema.unknown;
      Identity.__super__.constructor.apply(this, arguments);
      this.log.level = gg.util.Log.ERROR;
    }

    Identity.prototype.clone = function() {
      return this;
    };

    Identity.prototype.valid = function() {
      return true;
    };

    Identity.prototype.defaultDomain = function() {
      return this.log.warn("IdentityScale has no domain");
    };

    Identity.prototype.mergeDomain = function() {
      return this.log.warn("IdentityScale has no domain");
    };

    Identity.prototype.domain = function() {
      return this.log.warn("IdentityScale has no domain");
    };

    Identity.prototype.minDomain = function() {
      return this.log.warn("IdentityScale has no domain");
    };

    Identity.prototype.maxDomain = function() {
      return this.log.warn("IdentityScale has no domain");
    };

    Identity.prototype.resetDomain = function() {};

    Identity.prototype.range = function() {
      return this.log.warn("IdentityScale has no range");
    };

    Identity.prototype.minRange = function() {
      return this.log.warn("IdentityScale has no range");
    };

    Identity.prototype.maxRange = function() {
      return this.log.warn("IdentityScale has no range");
    };

    Identity.prototype.scale = function(v) {
      return v;
    };

    Identity.prototype.invert = function(v) {
      return v;
    };

    Identity.prototype.toString = function() {
      return "" + this.aes + "." + this.id + " (" + this.type + "): identity";
    };

    return Identity;

  })(gg.scale.Scale);

  gg.scale.MergedSet = (function() {

    MergedSet.ggpackage = 'gg.scale.MergedSet';

    function MergedSet(sets) {
      if (sets == null) {
        sets = [];
      }
      this.mapping = {};
      this.setup(sets);
    }

    MergedSet.prototype.key = function(col, type, klassName) {
      return JSON.stringify([col, String(type), klassName]);
    };

    MergedSet.prototype.setup = function(sets) {
      var key, mapping, s, set, _i, _j, _len, _len1, _ref;
      mapping = {};
      for (_i = 0, _len = sets.length; _i < _len; _i++) {
        set = sets[_i];
        _ref = set.scalesList();
        for (_j = 0, _len1 = _ref.length; _j < _len1; _j++) {
          s = _ref[_j];
          key = this.key(s.aes, s.type, s.constructor.name);
          if (s != null) {
            if (!(key in mapping)) {
              mapping[key] = [];
            }
            mapping[key].push(s);
          }
        }
      }
      return this.mapping = _.o2map(mapping, function(ss, key) {
        var other, _k, _len2, _ref1;
        s = ss[0].clone();
        _ref1 = _.rest(ss);
        for (_k = 0, _len2 = _ref1.length; _k < _len2; _k++) {
          other = _ref1[_k];
          s.mergeDomain(other.domain());
        }
        return [key, s];
      });
    };

    MergedSet.prototype.exclude = function(aess) {
      var mapping, ret;
      aess = _.flatten([aess]);
      mapping = {};
      _.each(this.mapping, function(v, key) {
        var c, klassname, t, _ref;
        _ref = JSON.parse(key), c = _ref[0], t = _ref[1], klassname = _ref[2];
        if (__indexOf.call(aess, c) < 0) {
          return mapping[key] = v;
        }
      });
      ret = new gg.scale.MergedSet([]);
      ret.mapping = mapping;
      return ret;
    };

    MergedSet.prototype.contains = function(aes, type, klassName) {
      return this.key(aes, type, klassName) in this.mapping;
    };

    MergedSet.prototype.get = function(aes, type, klassName) {
      return this.mapping[this.key(aes, type, klassName)];
    };

    MergedSet.prototype.toString = function() {
      var ss;
      ss = _.map(this.mapping, function(s, k) {
        return k + "\t->\t" + s.toString();
      });
      return ss.join('\n');
    };

    return MergedSet;

  })();

  gg.scale.Linear = (function(_super) {

    __extends(Linear, _super);

    Linear.ggpackage = 'gg.scale.Linear';

    Linear.aliases = "linear";

    function Linear(spec) {
      this.spec = spec;
      this.d3Scale = d3.scale.linear();
      this.type = data.Schema.numeric;
      Linear.__super__.constructor.apply(this, arguments);
    }

    return Linear;

  })(gg.scale.Scale);

  gg.scale.Time = (function(_super) {

    __extends(Time, _super);

    Time.ggpackage = 'gg.scale.Time';

    Time.aliases = "time";

    function Time(spec) {
      this.spec = spec;
      this.d3Scale = d3.time.scale();
      this.type = data.Schema.date;
      Time.__super__.constructor.apply(this, arguments);
    }

    return Time;

  })(gg.scale.Scale);

  gg.scale.Log = (function(_super) {

    __extends(Log, _super);

    Log.ggpackage = 'gg.scale.Log';

    Log.aliases = "log";

    function Log(spec) {
      this.spec = spec;
      this.d3Scale = d3.scale.log();
      this.type = data.Schema.numeric;
      Log.__super__.constructor.apply(this, arguments);
    }

    Log.prototype.valid = function(v) {
      return v !== 0 && Log.__super__.valid.call(this, v);
    };

    Log.prototype.defaultDomain = function(col) {
      var extreme, interval;
      col = _.filter(col, function(v) {
        return v > 0;
      });
      if (col.length === 0) {
        return [1, 10];
      }
      this.min = _.mmin(col);
      this.max = _.mmax(col);
      if (this.center != null) {
        extreme = Math.max(this.max - this.center, Math.abs(this.min - this.center));
        interval = [this.center - extreme, this.center + extreme];
      } else {
        interval = [this.min, this.max];
      }
      return interval;
    };

    Log.prototype.mergeDomain = function(domain) {
      var md, newDomain;
      md = this.domain();
      if (!this.domainSet) {
        if (this.domainUpdated && (md != null) && md.length === 2) {
          if (_.isNaN(domain[0]) || _.isNaN(domain[1])) {
            throw Error("domain is invalid: " + domain);
          }
          newDomain = [Math.min(md[0], domain[0]), Math.max(md[1], domain[1])];
          if (newDomain[0] < 0 && newDomain[1] > 0) {
            this.log.warn("domain maximum (" + newDomain + ") truncated to 0");
          }
          return this.domain(newDomain);
        } else {
          return this.domain(domain);
        }
      }
    };

    Log.prototype.scale = function(v) {
      if (v === 0) {
        return -1;
      } else {
        return this.d3Scale(v);
      }
    };

    return Log;

  })(gg.scale.Scale);

  gg.scale.Ordinal = (function(_super) {

    __extends(Ordinal, _super);

    function Ordinal() {
      return Ordinal.__super__.constructor.apply(this, arguments);
    }

    Ordinal.ggpackage = 'gg.scale.Ordinal';

    Ordinal.aliases = ['ordinal', 'categorical'];

    Ordinal.prototype.scale = function(v) {
      var res;
      res = Ordinal.__super__.scale.apply(this, arguments);
      return res + this.d3Scale.rangeBand() / 2.0;
    };

    return Ordinal;

  })(gg.scale.BaseCategorical);

  gg.scale.Set = (function() {

    Set.ggpackage = 'gg.scale.Set';

    function Set(factory) {
      var _ref;
      this.factory = factory != null ? factory : null;
      if ((_ref = this.factory) == null) {
        this.factory = new gg.scale.Factory;
      }
      this.scales = {};
      this.id = gg.scale.Set.prototype._id;
      gg.scale.Set.prototype._id += 1;
      this.log = gg.util.Log.logger(this.constructor.ggpackage, "ScaleSet-" + this.id);
    }

    Set.prototype._id = 0;

    Set.prototype.clone = function() {
      var ret, s, _i, _len, _ref;
      ret = new gg.scale.Set(this.factory);
      _ref = this.scalesList();
      for (_i = 0, _len = _ref.length; _i < _len; _i++) {
        s = _ref[_i];
        ret.set(s.clone());
      }
      return ret;
    };

    Set.prototype.toJSON = function() {
      return {
        factory: _.toJSON(this.factory),
        scales: _.toJSON(this.scales)
      };
    };

    Set.fromJSON = function(json) {
      var factory, set;
      factory = _.fromJSON(json.factory);
      set = new gg.scale.Set(factory);
      set.scales = _.fromJSON(json.scales);
      set.spec = _.fromJSON(json.spec);
      return set;
    };

    Set.prototype.cols = function() {
      return _.keys(this.scales);
    };

    Set.prototype.all = function() {
      return _.values(this.scales);
    };

    Set.prototype.contains = function(aes, type, posMapping) {
      if (type == null) {
        type = null;
      }
      if (posMapping == null) {
        posMapping = {};
      }
      aes = posMapping[aes] || aes;
      return aes in this.scales;
    };

    Set.prototype.has = function(aes, type, posMapping) {
      return this.contains(aes, type, posMapping);
    };

    Set.prototype.type = function(aes, posMapping) {
      if (posMapping == null) {
        posMapping = {};
      }
      aes = posMapping[aes] || aes;
      if (aes in this.scales) {
        return this.scales[aes].type;
      } else {
        return [];
      }
    };

    Set.prototype.userdefinedType = function(aes) {
      return this.factory.type(aes);
    };

    Set.prototype.scale = function(aesOrScale, type, posMapping) {
      if (posMapping == null) {
        posMapping = {};
      }
      if (_.isString(aesOrScale)) {
        return this.get(aesOrScale, type, posMapping);
      } else if (aesOrScale != null) {
        return this.set(aesOrScale);
      }
    };

    Set.prototype.set = function(scale) {
      if (scale.type === data.Schema.unknown && !_.isType(scale, gg.scale.Identity)) {
        throw Error("Storing scale type unknown: " + (scale.toString()));
      }
      this.scales[scale.aes] = scale;
      return scale;
    };

    Set.prototype.get = function(aes, type, posMapping) {
      var udt;
      if (posMapping == null) {
        posMapping = {};
      }
      if (__indexOf.call(gg.scale.Scale.xs, aes) >= 0) {
        aes = 'x';
      }
      if (__indexOf.call(gg.scale.Scale.ys, aes) >= 0) {
        aes = 'y';
      }
      aes = posMapping[aes] || aes;
      if (!(aes in this.scales)) {
        udt = this.userdefinedType(aes);
        if ((udt != null) && udt !== data.Schema.unknown) {
          type = udt;
        }
        this.scales[aes] = this.factory.scale(aes, type);
      }
      return this.scales[aes];
    };

    Set.prototype.scalesList = function() {
      return _.values(this.scales);
    };

    Set.prototype.merge = function(scales) {
      var col, d, other, s, _ref;
      _ref = this.scales;
      for (col in _ref) {
        s = _ref[col];
        if (col === 'text') {
          continue;
        }
        if (!scales.contains(col, s.type, s.constructor.name)) {
          continue;
        }
        if (_.isType(s, gg.scale.Identity)) {
          continue;
        }
        other = scales.get(col, s.type, s.constructor.name);
        d = s.domain();
        s.mergeDomain(other.domain());
        this.log("merge: " + s.domainUpdated + " " + col + "." + s.id + ":" + s.type + ": " + d + " + " + (other.domain()) + " -> " + (s.domain()));
      }
      return this;
    };

    Set.prototype.useScales = function(table, posMapping, f) {
      var col, scale, tabletype, _i, _len, _ref;
      if (posMapping == null) {
        posMapping = {};
      }
      _ref = table.cols();
      for (_i = 0, _len = _ref.length; _i < _len; _i++) {
        col = _ref[_i];
        if (this.has(col, null, posMapping)) {
          scale = this.scale(col, null, posMapping);
        } else {
          tabletype = table.schema.type(col);
          this.log("scaleset doesn't contain " + col + " creating using type " + tabletype);
          scale = this.scale(col, tabletype, posMapping);
        }
        this.log("col " + col + " depends on " + (table.colProv(col)));
        this.log(scale.toString());
        table = f(table, scale, col);
      }
      return table;
    };

    Set.prototype.train = function(table, posMapping) {
      var f,
        _this = this;
      if (posMapping == null) {
        posMapping = {};
      }
      f = function(table, scale, col) {
        var colData, maxval, minval, newDomain, oldDomain;
        if (!table.has(col)) {
          _this.log("col " + col + " not in table");
          return table;
        }
        if (_.isType(scale, gg.scale.Identity)) {
          _this.log("scale is identity.");
          return table;
        }
        colData = table.all(col);
        if (colData == null) {
          throw Error("Set.train: attr " + col + " does not exist in table");
        }
        colData = colData.filter(_.isValid);
        if (colData.length < table.nrows()) {
          _this.log("filtered out " + (table.nrows() - colData.length) + " col values");
        }
        _this.log("col " + col + " has " + colData.length + " elements");
        if ((colData != null) && colData.length > 0) {
          newDomain = scale.defaultDomain(colData);
          oldDomain = scale.domain();
          minval = _.mmin([oldDomain[0], newDomain[0]]);
          maxval = _.mmax([oldDomain[1], newDomain[1]]);
          _this.log("domains: " + (scale.toString()) + " " + oldDomain + " + " + newDomain + " = [" + minval + ", " + maxval + "]");
          if (newDomain == null) {
            throw Error();
          }
          if (_.isNaN(newDomain[0])) {
            throw Error();
          }
          scale.mergeDomain(newDomain);
          if (scale.type === data.Schema.numeric) {
            _this.log("train: " + col + "(" + scale.id + ")\t" + oldDomain + " merged with " + newDomain + " to " + (scale.domain()));
          } else {
            _this.log("train: " + col + "(" + scale.id + ")\t" + scale);
          }
        }
        return table;
      };
      this.useScales(table, posMapping, f);
      return this;
    };

    Set.prototype.apply = function(table, posMapping) {
      var f,
        _this = this;
      if (posMapping == null) {
        posMapping = {};
      }
      f = function(table, scale, col) {
        var mapping, str;
        if (!table.has(col)) {
          return table;
        }
        mapping = [
          {
            alias: col,
            f: function(v) {
              return scale.scale(v);
            },
            cols: col,
            type: data.Schema.unknown
          }
        ];
        table = table.project(mapping, true);
        str = scale.toString();
        _this.log("apply: " + col + "(" + scale.id + "):\t" + str + "\t" + (table.nrows()) + " rows");
        return table;
      };
      this.log("apply: table has " + (table.nrows()) + " rows");
      table = this.useScales(table, posMapping, f);
      return table;
    };

    Set.prototype.filter = function(table, posMapping) {
      var f, filterFuncs, g, nRejected,
        _this = this;
      if (posMapping == null) {
        posMapping = {};
      }
      filterFuncs = [];
      f = function(table, scale, col) {
        var g;
        g = function(row) {
          var checks, v;
          v = row.get(col);
          checks = [_.isNaN, _.isUndefined, _.isNull];
          if (!_.any(checks, function(f) {
            return f(v);
          })) {
            return scale.valid(v);
          } else {
            return true;
          }
        };
        g.col = col;
        _this.log("filter: " + (scale.toString()));
        if (table.has(col)) {
          filterFuncs.push(g);
        }
        return table;
      };
      this.useScales(table, posMapping, f);
      nRejected = 0;
      g = function(row) {
        var _i, _len;
        for (_i = 0, _len = filterFuncs.length; _i < _len; _i++) {
          f = filterFuncs[_i];
          if (!f(row)) {
            nRejected += 1;
            _this.log("Row rejected on attr " + f.col + " w val: " + (row.get(f.col)));
            return false;
          }
        }
        return true;
      };
      table = table.filter(g);
      this.log("filter: removed " + nRejected + ".  " + (table.nrows()) + " rows left");
      return table;
    };

    Set.prototype.invert = function(table, posMapping) {
      var f,
        _this = this;
      if (posMapping == null) {
        posMapping = {};
      }
      f = function(table, scale, col) {
        var mapping;
        if (!table.has(col)) {
          return table;
        }
        mapping = [
          {
            alias: col,
            cols: col,
            f: function(v) {
              if (v != null) {
                return scale.invert(v);
              } else {
                return null;
              }
            },
            type: data.Schema.unknown
          }
        ];
        table = table.project(mapping, true);
        return table;
      };
      table = this.useScales(table, posMapping, f);
      return table;
    };

    Set.prototype.labelFor = function() {
      return null;
    };

    Set.prototype.toString = function(prefix) {
      var arr;
      if (prefix == null) {
        prefix = "";
      }
      arr = _.map(this.scales, function(s, col) {
        return "" + prefix + col + ": " + (s.toString());
      });
      return arr.join('\n');
    };

    return Set;

  })();

  gg.scale.Shape = (function(_super) {

    __extends(Shape, _super);

    Shape.ggpackage = 'gg.scale.Shape';

    Shape.aliases = "shape";

    function Shape(padding) {
      var customTypes;
      this.padding = padding != null ? padding : 1;
      customTypes = ['star', 'ex'];
      this.symbolTypes = d3.svg.symbolTypes.concat(customTypes);
      this.d3Scale = d3.scale.ordinal().range(this.symbolTypes);
      this.invertScale = d3.scale.ordinal().domain(this.d3Scale.range());
      this.symbScale = d3.svg.symbol();
      this.type = data.Schema.ordinal;
      Shape.__super__.constructor.apply(this, arguments);
    }

    Shape.prototype.range = function(interval) {};

    Shape.prototype.scale = function(v) {
      var diag, r, size, tr, type;
      throw Error("shape scale not thought through yet");
      if ((typeof args !== "undefined" && args !== null) && args.length) {
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

    return Shape;

  })(gg.scale.BaseCategorical);

  gg.scale.Text = (function(_super) {

    __extends(Text, _super);

    Text.ggpackage = 'gg.scale.Text';

    Text.aliases = "text";

    function Text() {
      this.type = data.Schema.ordinal;
      Text.__super__.constructor.apply(this, arguments);
    }

    Text.prototype.scale = function(v) {
      return String(v);
    };

    Text.prototype.invert = function(v) {
      return String(v);
    };

    Text.defaultDomain = function(col) {
      return [null, null];
    };

    Text.prototype.mergeDomain = function() {};

    Text.prototype.domain = function() {
      return [null, null];
    };

    Text.prototype.range = function() {
      return [null, null];
    };

    return Text;

  })(gg.scale.Scale);

  gg.stat.Bin1D = (function(_super) {

    __extends(Bin1D, _super);

    function Bin1D() {
      return Bin1D.__super__.constructor.apply(this, arguments);
    }

    Bin1D.ggpackage = "gg.stat.Bin1D";

    Bin1D.aliases = ['1dbin', 'bin', 'bin1d'];

    Bin1D.prototype.parseSpec = function() {
      var defaults, params;
      defaults = {
        cols: ['x'],
        aggs: {
          count: 'count',
          sum: 'sum',
          y: 'sum',
          total: 'sum',
          avg: 'avg'
        }
      };
      params = new gg.util.Params(this.spec);
      params.merge(new gg.util.Params(defaults));
      params.merge(this.params);
      this.params = params;
      this.params.ensure('nBins', ['n', 'bins', 'nbins'], 20);
      return Bin1D.__super__.parseSpec.apply(this, arguments);
    };

    return Bin1D;

  })(gg.xform.GroupBy);

  gg.stat.Bin2D = (function(_super) {

    __extends(Bin2D, _super);

    function Bin2D() {
      return Bin2D.__super__.constructor.apply(this, arguments);
    }

    Bin2D.ggpackage = "gg.stat.Bin2D";

    Bin2D.aliases = ['2dbin', 'bin2d'];

    Bin2D.prototype.parseSpec = function() {
      var defaults, params;
      defaults = {
        cols: ['x', 'y'],
        aggs: {
          z: {
            type: 'count',
            col: 'z'
          },
          count: {
            type: 'count',
            col: 'z'
          },
          sum: {
            type: 'sum',
            col: 'z'
          },
          total: {
            type: 'sum',
            col: 'z'
          }
        }
      };
      params = new gg.util.Params(this.spec);
      params.merge(new gg.util.Params(defaults));
      params.merge(this.params);
      this.params = params;
      return Bin2D.__super__.parseSpec.apply(this, arguments);
    };

    Bin2D.prototype.compute = function(pairtable, params) {
      var aggs, canonicalRow, cols, f, md, nBins, set, table, xschema, xtable, xvals, xytable, yschema, ytable, yvals;
      table = pairtable.left();
      md = pairtable.right();
      set = md.any('scales');
      cols = params.get('cols');
      aggs = params.get('aggs');
      nBins = this.annotate.params.get('nBins');
      xvals = this.allVals(set.get('x'), nBins[0]);
      yvals = this.allVals(set.get('y'), nBins[1]);
      xschema = new data.Schema(['x'], [data.Schema.numeric]);
      yschema = new data.Schema(['y'], [data.Schema.numeric]);
      xtable = new data.ColTable(xschema, [xvals]);
      ytable = new data.ColTable(yschema, [yvals]);
      xytable = xtable.cross(ytable);
      canonicalRow = table.any().clone();
      table = table.groupby(cols, aggs);
      f = function() {
        var row;
        row = canonicalRow.clone();
        row.set('x', null);
        row.set('y', null);
        _.each(aggs, function(agg) {
          return _.each(_.flatten([agg.alias]), function(alias) {
            return row.set(alias, 0);
          });
        });
        return row;
      };
      table = xytable.join(table, ['x', 'y'], 'left', null, f);
      pairtable.left(table);
      return pairtable;
    };

    Bin2D.prototype.allVals = function(scale, nbins) {
      var binRange, binSize, col, domain, maxD, minD, type, _ref;
      col = scale.aes;
      type = scale.type;
      switch (type) {
        case data.Schema.ordinal:
          return scale.domain();
        case data.Schema.numeric:
          minD = scale.domain()[0];
          maxD = scale.domain()[1];
          binRange = (maxD - minD) * 1.0;
          binSize = binRange / nbins;
          return _.times(nbins, function(idx) {
            return idx * binSize + minD + (binSize / 2);
          });
        case data.Schema.date:
          domain = [domain[0].getTime(), domain[1].getTime()];
          _ref = [domain[0], domain[1]], minD = _ref[0], maxD = _ref[1];
          binRange = (maxD - minD) * 1.0;
          binSize = binRange / nbins;
          return _.times(nbins, function(idx) {
            return new Date(Math.ceil(idx * binSize) + minD + binSize / 2);
          });
      }
    };

    return Bin2D;

  })(gg.xform.GroupBy);

  gg.stat.Identity = (function(_super) {

    __extends(Identity, _super);

    function Identity() {
      return Identity.__super__.constructor.apply(this, arguments);
    }

    Identity.ggpackage = "gg.stat.Identity";

    Identity.aliases = ['identity'];

    Identity.prototype.compile = function() {
      return [];
    };

    return Identity;

  })(gg.stat.Stat);

  science = require('science');

  gg.stat.Loess = (function(_super) {

    __extends(Loess, _super);

    function Loess() {
      return Loess.__super__.constructor.apply(this, arguments);
    }

    Loess.ggpackage = "gg.stat.Loess";

    Loess.aliases = ['loess', 'smooth'];

    Loess.prototype.parseSpec = function() {
      Loess.__super__.parseSpec.apply(this, arguments);
      return this.params.ensureAll({
        bandwidth: [["band", "bw"], .3],
        acc: [["accuracy", "ac"], 1e-12]
      });
    };

    Loess.prototype.inputSchema = function() {
      return ['x', 'y'];
    };

    Loess.prototype.outputSchema = function() {
      return data.Schema.fromJSON({
        x: data.Schema.numeric,
        y: data.Schema.numeric
      });
    };

    Loess.prototype.schemaMapping = function() {
      return {
        x: 'x',
        y: 'y'
      };
    };

    Loess.prototype.compute = function(pairtable, params) {
      var acc, bw, loessfunc, smoothys, table, xs, ys;
      table = pairtable.left();
      table = table.filter(function(row) {
        return _.isValid(row.get('x')) && _.isValid(row.get('y'));
      });
      if (table.nrows() <= 1) {
        return pairtable;
      }
      table = table.orderby('x');
      xs = table.all('x');
      ys = table.all('y');
      loessfunc = science.stats.loess();
      acc = params.get('acc');
      bw = params.get('bandwidth');
      bw = Math.max(bw, 2.0 / xs.length);
      bw = Math.min(bw, 1.0);
      loessfunc.bandwidth(bw);
      loessfunc.accuracy(acc);
      smoothys = loessfunc(xs, ys);
      table = table.project([
        {
          alias: 'y',
          f: function(y, idx) {
            return smoothys[idx];
          }
        }
      ]);
      pairtable.left(table);
      return pairtable;
    };

    return Loess;

  })(gg.core.XForm);

  gg.stat.Sort = (function(_super) {

    __extends(Sort, _super);

    function Sort() {
      return Sort.__super__.constructor.apply(this, arguments);
    }

    Sort.ggpackage = "gg.stat.Sort";

    Sort.aliases = ['sort', 'sorted'];

    Sort.prototype.parseSpec = function() {
      var cols, reverse;
      Sort.__super__.parseSpec.apply(this, arguments);
      cols = ["col", "cols", "attr", "attrs", "aes", "aess"];
      cols = _.findGoodAttr(this.spec, cols, []);
      cols = _.flatten([cols]);
      reverse = _.findGood(this.spec, ['reverse', 'invert'], false);
      return this.params.putAll({
        cols: cols,
        reverse: reverse
      });
    };

    Sort.prototype.inputSchema = function(pairtable, params) {
      return params.get('cols');
    };

    Sort.prototype.compute = function(pairtable, params) {
      var cols, reverse, table;
      table = pairtable.left();
      reverse = params.get('reverse');
      cols = params.get('cols');
      table = table.orderby(cols, reverse);
      pairtable.left(table);
      return pairtable;
    };

    return Sort;

  })(gg.stat.Stat);

  gg.xform.EnvPut = (function(_super) {

    __extends(EnvPut, _super);

    function EnvPut() {
      return EnvPut.__super__.constructor.apply(this, arguments);
    }

    EnvPut.ggpackage = "gg.xform.EnvPut";

    EnvPut.type = "envput";

    EnvPut.prototype.parseSpec = function() {
      EnvPut.__super__.parseSpec.apply(this, arguments);
      return this.params.ensure('pairs', [], {});
    };

    EnvPut.prototype.compute = function(pairtable, params) {
      var k, md, pairs, v;
      md = pairtable.right();
      pairs = params.get('pairs');
      for (k in pairs) {
        v = pairs[k];
        md = md.setColVal(k, v);
      }
      pairtable.right(md);
      return pairtable;
    };

    return EnvPut;

  })(gg.wf.SyncBlock);

  gg.xform.Mapper = (function(_super) {

    __extends(Mapper, _super);

    function Mapper() {
      return Mapper.__super__.constructor.apply(this, arguments);
    }

    Mapper.ggpackage = "gg.xform.Mapper";

    Mapper.log = gg.util.Log.logger(Mapper.ggpackage, 'map');

    Mapper.attrs = ["mapping", "map", "aes", "aesthetic", "aesthetics"];

    Mapper.prototype.parseSpec = function() {
      Mapper.__super__.parseSpec.apply(this, arguments);
      this.params.put('aes', this.spec.aes);
      return this.params.put('keys', ['facet-x', 'facet-y', 'layer']);
    };

    Mapper.prototype.compute = function(pt, params) {
      var aes, functions, table;
      table = pt.left();
      aes = params.get('aes');
      functions = _.mappingToFunctions(table, aes);
      this.log("mapper " + this.name + " running on " + (JSON.stringify(aes)));
      this.log(functions);
      table = table.project(functions, true);
      pt.left(table);
      if (__indexOf.call(_.map(functions, function(desc) {
        return desc.alias;
      }), 'group') >= 0) {
        pt = pt.ensure(['group']);
      }
      return pt;
    };

    Mapper.groupSpec = function(aes) {
      var desc, groupable, keys;
      keys = [];
      desc = null;
      groupable = {};
      if ('group' in aes) {
        groupable = aes['group'];
        keys = ['group'];
      } else {
        keys = _.filter(_.keys(aes), gg.core.Aes.groupable);
        if (keys.length > 0) {
          groupable = _.pick(aes, keys);
        }
      }
      return {
        group: groupable,
        cols: keys
      };
    };

    Mapper.fromSpec = function(spec) {
      var aes;
      aes = spec.aes;
      this.log("fromSpec: " + (JSON.stringify(aes)));
      if (!((aes != null) && _.size(aes) > 0)) {
        return null;
      }
      return new gg.xform.Mapper(spec);
    };

    return Mapper;

  })(gg.wf.SyncExec);

  gg.xform.DetectScales = (function(_super) {

    __extends(DetectScales, _super);

    function DetectScales() {
      return DetectScales.__super__.constructor.apply(this, arguments);
    }

    DetectScales.ggpackage = "gg.xform.DetectScales";

    DetectScales.prototype.parseSpec = function() {
      return DetectScales.__super__.parseSpec.apply(this, arguments);
    };

    DetectScales.prototype.compute = function(pairtable, params) {
      var aes, constantCols, md, table;
      table = pairtable.left();
      md = pairtable.right();
      aes = params.get('aes');
      constantCols = [];
      _.each(aes, function(v, k) {
        if (_.isNumber(v) || (_.isString(v) && !table.has(v))) {
          return constantCols.push(k);
        }
      });
      this.log("constant columns: " + constantCols);
      md.each(function(row) {
        var config, layer;
        config = row.get('scalesconfig');
        layer = row.get('layer');
        return _.each(constantCols, function(col) {
          return config.layerSpec(layer)[col] = new gg.scale.Identity({
            aes: col
          });
        });
      });
      return pairtable;
    };

    return DetectScales;

  })(gg.core.XForm);

  gg.xform.UseScales = (function(_super) {

    __extends(UseScales, _super);

    function UseScales() {
      return UseScales.__super__.constructor.apply(this, arguments);
    }

    UseScales.ggpackage = "gg.xform.UseScales";

    UseScales.prototype.parseSpec = function() {
      UseScales.__super__.parseSpec.apply(this, arguments);
      return this.params.putAll({
        aess: this.spec.aess || []
      });
    };

    UseScales.prototype.compute = function(pairtable, params) {
      var md, posMapping, scales, table;
      pairtable = gg.core.FormUtil.ensureScales(pairtable, params, this.log);
      table = pairtable.left();
      md = pairtable.right();
      scales = md.any().get('scales');
      posMapping = md.any().get('posMapping');
      table = this.useScales(table, scales, posMapping);
      pairtable.left(table);
      return pairtable;
    };

    return UseScales;

  })(gg.core.XForm);

  gg.xform.ScalesSchema = (function(_super) {

    __extends(ScalesSchema, _super);

    function ScalesSchema() {
      return ScalesSchema.__super__.constructor.apply(this, arguments);
    }

    ScalesSchema.ggpackage = "gg.xform.ScalesSchema";

    ScalesSchema.prototype.useScales = function(table, scales, posMapping) {
      var log, schema;
      log = this.log;
      schema = table.schema;
      _.each(table.cols(), function(col) {
        var scale, scaletype, tabletype;
        tabletype = schema.type(col);
        scale = scales.get(col, tabletype, posMapping);
        scaletype = scale.type;
        if (scaletype !== data.Schema.unknown) {
          if (tabletype >= scaletype) {
            log("settype: " + col + "\t" + scaletype + " from " + tabletype);
            return table.schema.setType(col, scaletype);
          } else {
            log.warn("Upcasting " + col + ": " + tabletype + "->" + scaletype);
            return table.schema.setType(col, scaletype);
          }
        }
      });
      return table;
    };

    return ScalesSchema;

  })(gg.xform.UseScales);

  gg.xform.ScalesApply = (function(_super) {

    __extends(ScalesApply, _super);

    function ScalesApply() {
      return ScalesApply.__super__.constructor.apply(this, arguments);
    }

    ScalesApply.ggpackage = "gg.xform.ScalesApply";

    ScalesApply.prototype.useScales = function(table, scales, posMapping) {
      return scales.apply(table, posMapping);
    };

    return ScalesApply;

  })(gg.xform.UseScales);

  gg.xform.ScalesInvert = (function(_super) {

    __extends(ScalesInvert, _super);

    function ScalesInvert() {
      return ScalesInvert.__super__.constructor.apply(this, arguments);
    }

    ScalesInvert.ggpackage = "gg.xform.ScalesInvert";

    ScalesInvert.prototype.useScales = function(table, scales, posMapping) {
      return scales.invert(table, posMapping);
    };

    return ScalesInvert;

  })(gg.xform.UseScales);

  gg.xform.ScalesFilter = (function(_super) {

    __extends(ScalesFilter, _super);

    function ScalesFilter() {
      return ScalesFilter.__super__.constructor.apply(this, arguments);
    }

    ScalesFilter.ggpackage = "gg.xform.ScalesFilter";

    ScalesFilter.prototype.useScales = function(table, scales, posMapping) {
      return scales.filter(table, posMapping);
    };

    return ScalesFilter;

  })(gg.xform.UseScales);

  gg.xform.ScalesValidate = (function(_super) {

    __extends(ScalesValidate, _super);

    function ScalesValidate() {
      return ScalesValidate.__super__.constructor.apply(this, arguments);
    }

    ScalesValidate.ggpackage = "gg.xform.ScalesValidate";

    ScalesValidate.prototype.useScales = function(table, scales, posMapping) {
      return table;
    };

    return ScalesValidate;

  })(gg.xform.UseScales);

}).call(this);
