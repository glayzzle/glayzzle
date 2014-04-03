
// using http://ejohn.org/blog/simple-javascript-inheritance/
var Class = require('../src/compat/class');

// declare the bar class
var bar = (function() {
  // private vars with no collision
  var this_var1 = 'bar';
  // define the parent handler
  var parent = Class.prototype;
  // class declaration
  return Class.__extends({
    // declare a public var
    arg: null,
    var2: 'public-bar',
    // public constructor
    __construct: function(arg1) {
      // constructor code
      this.arg = arg1;
    },
    // public function
    bar: function() {
      console.log('I am the public BAR function : '+this_var1+' !');
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

console.log('*** TEST BEHAVIOUR WITH BAR ***');
var i1 = new bar('azerty');
i1.bar();
console.log(i1);
console.log(i1 instanceof bar);
console.log(bar);
console.log(bar.getInstance());

/** TEST EXTENDS **/
console.log('*** TEST EXTENSION WITH FOO ***');
var foo = (function() {
  // private vars with no collision
  var this_var1 = 'foo';
  // define the parent handler
  var parent = bar.prototype;
  // class declaration
  return bar.__extends({
    // declare a public var
    var2: 'public-foo',
    // public function
    bar: function() {
      console.log('I am the public FOO function : '+this_var1+' !');
      parent.bar();
    }
  });
}());

var i2 = new foo('test-foo');
i2.bar();
console.log(i2);
console.log(i2 instanceof bar);