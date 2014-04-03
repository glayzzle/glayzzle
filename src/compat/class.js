
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

// private protected container
var protected = {
  stdClass: {}
};

// Create a new Class that inherits from this class
Class.__extends = function(options, prop) {
  // Instantiate a base class (but only create the instance,
  // don't run the constructor)
  initializing = true;
  var parentName = this.prototype.constructor.toString();
  var that = this;
  var proto = new that();
  initializing = false;

  // declare protected static elements
  protected[options.name] = {};
  var self = protected[options.name];
  // clone protected static element from parent
  for(var i in protected[parentName]) {
    self[i] = protected[parentName][i];
  }
  // override protected static elements
  for(var name in options.protected) {
    self[name] = options.protected[name];
  }

  // The dummy class constructor
  self['__class'] = function() {
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
  };

  // Declare the object prototype
  for (var name in prop) {
    if (typeof prop[name] === 'function') {
      proto[name] = prop[name];
    }
  }

  // Populate our constructed prototype object
  self['__class'].prototype = proto;

  // Copy public static elements
  for (var name in that) {
    self['__class'][name] = that[name];
  }

  // Enforce the constructor to be what we expect
  self['__class'].prototype.constructor = self['__class'];
  self['__class'].prototype.constructor.toString = function() {
    return options.name ? options.name : 'stdClass';
  };

  // makes it extensible if is not a final class
  if (options.final) self['__class'].__extends = function(options) {
    throw new Error(
      'Class ' +  options.name 
      + ' may not inherit from final class (' 
      + this + ')'
    );
  };
  return self;
};
Class.prototype.constructor.toString = function() { return 'stdClass'; }
module.exports = Class;