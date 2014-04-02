
/* Simple JavaScript Inheritance
 * By John Resig http://ejohn.org/
 * MIT Licensed.
 * --------------------------------------------- 
 * Glayzzle : PHP on NodeJS
 * @url http://glayzzle.com
 * @author Ioan CHIRIAC
 * @license BSD-3-Clause
 */

// Inspired by base2 and Prototype
var initializing = false, fnTest = /xyz/.test(function(){xyz;}) ? /\b_super\b/ : /.*/;

// The base Class implementation (does nothing)
var Class = function(){};

// Create a new Class that inherits from this class
Class.__extends = function(prop) {
  var _super = this.prototype;
 
  // Instantiate a base class (but only create the instance,
  // don't run the init constructor)
  initializing = true;
  var prototype = new this();
  initializing = false;
 
  // Copy the properties over onto the new prototype
  for (var name in prop) {
    // Check if we're overwriting an existing function
    prototype[name] = typeof prop[name] == "function" &&
      typeof _super[name] == "function" && fnTest.test(prop[name]) ?
      (function(name, fn){
        return function() {
          var tmp = this._super;
         
          // Add a new ._super() method that is the same method
          // but on the super-class
          this._super = _super[name];
         
          // The method only need to be bound temporarily, so we
          // remove it when we're done executing
          var ret = fn.apply(this, arguments);
          this._super = tmp;
         
          return ret;
        };
      })(name, prop[name]) :
      prop[name];
  }

  // The dummy class constructor
  function result() {
    
    // All construction is actually done in the init method
    if ( !initializing && this.__construct ) {
      this = prototype;
      this.__construct.apply(this, arguments);
    }
  }
 
  // Populate our constructed prototype object
  result.prototype = prototype;
 
  // Enforce the constructor to be what we expect
  result.prototype.constructor = result;

  console.log(result.prototype);
  // And make this class extendable
  result.__extends = Class.__extends;
 
  return result;
};
module.exports = Class;