
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
  // Instantiate a base class (but only create the instance,
  // don't run the init constructor)
  initializing = true;
  var prototype = new this();
  initializing = false;
 
  // Copy the properties over onto the new prototype
  for (var name in prop) {
    prototype[name] = prop[name];
  }

  // The dummy class constructor
  function result() {
    // All construction is actually done in the __construct method
    if ( !initializing) {
      // define defaut properties
      for (var name in prop) {
        if (typeof prop[name] !== 'function') {
          this[name] = prop[name];
        }
      }
      // loads the constructor
      if (this.__construct) this.__construct.apply(this, arguments);
    }
  }
 
  // Populate our constructed prototype object
  result.prototype = prototype;
 
  // Enforce the constructor to be what we expect
  result.prototype.constructor = result;

  // And make this class extendable
  result.__extends = Class.__extends;
 
  return result;
};
module.exports = Class;