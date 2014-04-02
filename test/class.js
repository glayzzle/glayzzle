
// using http://ejohn.org/blog/simple-javascript-inheritance/
var Class = require('../src/compat/class');

// declare the bar class
var bar = (function() {
  // private vars with no collision
  var this_var1 = 'bar';
  // class declaration
  return Class.__extends({
    // declare a public var
    arg: null,
    var2: 'public-bar',
    // public constructor
    __construct: function(arg1) {
      // constructor code
      // this.arg = arg1;
    }
  });
}());

// static public vars
bar.static_var2 = 'bar2';
// static public method
bar.getInstance = function() {
  // bar == self
  return bar.static_var2;
};

var i1 = new bar('azerty');
console.log(i1);
console.log(i1 instanceof bar);
console.log(bar);
console.log(bar.getInstance());

/**
var foo = function(arg1) {
  
  // private vars
  var this_var1 = 'foo';
  // 
}
var obj = new Proxy()

*/