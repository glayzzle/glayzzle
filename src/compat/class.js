
/**
 * Inspired by :
 * Simple JavaScript Inheritance
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
Class.protected = {
  stdClass: {}
};
Class.__extends = function(options, prop) {
  // Instantiate a base class (but only create the instance,
  // don't run the constructor)
  initializing = true;
  var that = this;
  var parentName = this.prototype.constructor.toString();
  var proto = new that();
  initializing = false;
  
  // declare protected static vars
  Class.protected[options.name] =  Class.protected[parentName];
  for(var name in options.protected) {
    Class.protected[options.name][name] = options.protected[name];
  }

  // Declare the object prototype
  for (var name in prop) {
    if (typeof prop[name] === 'function') {
      proto[name] = prop[name];
    }
  }

  // The dummy class constructor
  function result() {
    // All construction is actually done in the __construct method
    if ( !initializing) {
      // Copy the properties over onto the new prototype
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
  result.prototype = proto;

  // Copy static vars & generic functions
  for (var name in that) {
    result[name] = that[name];
  }

  // Enforce the constructor to be what we expect
  result.prototype.constructor = result;
  result.prototype.constructor.toString = function() {
    return options.name ? options.name : 'stdClass';
  };
  
  // makes it extensible if is not a final class
  if (options.final) result.__extends = function(options) {
    throw new Error(
      'Class ' +  options.name 
      + ' may not inherit from final class (' 
      + this + ')'
    );
  };
  return {
    protected: Class.protected[options.name],
    handler: result
  };
};
Class.prototype.constructor.toString = function() { return 'stdClass'; }
module.exports = Class;