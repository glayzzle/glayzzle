/*!
 * Glayzzle : PHP on NodeJS
 * @authors https://github.com/glayzzle/glayzzle/graphs/contributors
 * @license BSD-3-Clause
 * @url http://glayzzle.com
 */

"use strict";

/**
 * Define the reflection wrapper
 * @constructor {Class}
 */
var Class = function(name) {
  this.abstract = false;
  this.final = false;
  this.implements = [];
  this.extends = null;
  this._proto = null;

  /** STORE DEFAULT PROPERTIES (WITH THEIR SCOPE) **/
  this.public = {};
  this.protected = {};
  this.private = {};
  this.static = {
    public: {},
    protected: {},
    private: {},
    constant: {}
  };


  if (typeof name === 'function') {
    this.name = name.prototype.constructor.name;
  } else {
    this.name = name || 'stdClass';
  }

};


/**
 * Extends the specified prototype
 */
Class.prototype.extends = function(parent) {
  if (typeof parent.getClass === 'function') {
    // passed a class object instance, so retrieve its reflection object
    this._extends = parent.getClass();
    // stores the reflection object
    if ( this._extends._final ) {
      this._extends = null;
      throw new Error('Could not inherit from a final class !');
    }
  } else {
    throw new Error('Could not extend from the specified object, expects a class declaration interface !');
  }
  return this;
};
/**
 * This class is final
 * => Cannont be extended
 */
Class.prototype.final = function() {
  if (this._proto) throw new Error('ILLEGAL operation, class prototype is already defined !');
  if (arguments.length == 1) {
    this._final = arguments[0];
  } else this._final = true;
  if ( this._final && this._abstract ) {
    this._final = false;
    throw new Error('A class could not be both final and abstract !');
  }
  return this;
};
/**
 * This class is an abstract class
 * => Cannot be dirrectly instanciated
 */
Class.prototype.abstract = function() {
  if (this._proto) throw new Error('ILLEGAL operation, class prototype is already defined !');
  if (arguments.length == 1) {
    this._abstract = arguments[0];
  } else this._abstract = true;
  if ( this._final && this._abstract ) {
    this._abstract = false;
    throw new Error('A class could not be both final and abstract !');
  }
  return this;
};
/**
 * Defines the class interface
 */
Class.prototype.static = function(properties) {
  if (this._proto) throw new Error('ILLEGAL operation, class prototype is already defined !');
  if (properties.hasOwnProperty('public')) {
    for(var i in properties.public) {
      this._static.public[i] = properties.public[i];
    }
  }
  if (properties.hasOwnProperty('protected')) {
    for(var i in properties.protected) {
      this._static.protected[i] = properties.protected[i];
    }
  }
  if (properties.hasOwnProperty('private')) {
    for(var i in properties.private) {
      this._static.private[i] = properties.private[i];
    }
  }
  return this;
};
/**
 * Define some constants
 */
Class.prototype.constants = function(properties) {
  if (this._proto) throw new Error('ILLEGAL operation, class prototype is already defined !');
  for(var i in properties) {
    this._static.constant[i] = properties[i];
  }
  return this;
};
/**
 * Define public functions and properties
 */
Class.prototype.public = function(properties) {
  if (this._proto) throw new Error('ILLEGAL operation, class prototype is already defined !');
  for(var i in properties) {
    this._public[i] = properties[i];
  }
  return this;
};
/**
 * Define protected functions and properties
 */
Class.prototype.protected = function(properties) {
  if (this._proto) throw new Error('ILLEGAL operation, class prototype is already defined !');
  for(var i in properties) {
    this._protected[i] = properties[i];
  }
  return this;
};
/**
 * Define private functions and properties
 */
Class.prototype.private = function(properties) {
  if (this._proto) throw new Error('ILLEGAL operation, class prototype is already defined !');
  for(var i in properties) {
    this._private[i] = properties[i];
  }
  return this;
};
/**
 * Makes the prototype
 */
Class.prototype.getPrototype = function() {
  if (!this._proto) {
    var reflection = this;
    this._proto = function() {
      // use the public constructor
      if (reflection._public.hasOwnProperty('__construct')) {
        this.__construct.apply(this, arguments);
      }
    };
    this._proto.toString = function() {
      return reflection._name ? reflection._name : 'stdClass';
    };
    var __self = {};
    // handle inheritance
    if (this._extends) {
      // declare public elements
      for(var i in this._extends._public) {
        __self[i] = this._extends._public[i];
      }
      // declare static elements
      for(var i in this._extends._static.public) {
        this._proto[i] = this._extends._static.public[i];
      }
    }
    // declare public elements
    for(var i in this._public) {
      __self[i] = this._public[i];
    }
    // declare protected elements
    for(var i in this._protected) {
      Object.defineProperty(__self, i, {
        value: this._public[i],
        enumerable: false,
        configurable: false,
        writable: true
      });
    }
    // declare static elements
    for(var i in this._static.public) {
      this._proto[i] = this._static.public[i];
    }
    // declare static constants
    for(var i in this._static.constant) {
      this._proto[i] = this._static.constant[i];
    }
    // reflection handler, like the java getClass helper
    this._proto.getClass = __self.getClass = function() {
      return reflection;
    };
    this._proto.prototype = __self;
    this._proto.prototype.constructor = this._proto;
  }
  return this._proto;
};

module.exports = Class;
