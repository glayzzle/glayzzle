/*!
 * Glayzzle : PHP on NodeJS
 * @authors https://github.com/glayzzle/glayzzle/graphs/contributors
 * @license BSD-3-Clause
 * @url http://glayzzle.com
 */

"use strict";

var Class = require('./reflection/class');


/**
 * Handles classes (from global context)
 * @constructor Classes
 */
var Classes = function(ctx) {
  this.items = {};
  this.loaders = [];
  this.ctx = ctx;
};

/**
 * Gets a class reflection
 * @return {Class}
 */
Classes.prototype.get = function(name) {
  if (!this.items.hasOwnProperty(name)) {
    // force autoload
    if (!this.has(name, true)) {
      this.ctx.php.trigger_error(
        'Unable find class: '+name
        , this.ctx.constant.get('E_ERROR')
      );
      return null;
    }
  }
  return this.items[name];
};

/**
 * Checks if the class can be found
 */
Classes.prototype.has = function(name, autoload) {
  if (this.items.hasOwnProperty(name)) {
    return true;
  } else if (autoload) {
    var found = false;
    for(var i = 0; i < this.ctx.loaders.length; i++) {
      var res = this.ctx.loaders[i](name);
      if (res === false) {
        return false;
      }
      if (res === true) {
        return this.items.hasOwnProperty(name);
      }
    }
  }
  return false;
};

/**
 * Initialize a new class instance
 * @return {Object}
 */
Classes.prototype.construct = function(name, arguments) {
  var item = this.get(name);
  return new item(arguments);
};

/**
 * Declares a new class
 */
Classes.prototype.declare = function(name, fn) {

  if (typeof name === 'function') {
    fn = name;
    name = fn.prototype.constructor.name;
  }

  if (!name) {
    throw new Error('Please provide a named function, or the name argument');
  }

  if (this.items.hasOwnProperty(name)) {
    this.ctx.php.trigger_error(
      'Cannot declare class '+name+', because the name is already in use'
      , this.ctx.constant.get('E_ERROR')
    );
    return this.items[name];
  }

  // register the class into the namespace scope
  var namespace = name.split('\\');
  var className = namespace.pop();
  namespace = this.ctx.namespace.get(namespace);
  this.items[name] = new Class(className, namespace);
  namespace.classes[className] = this.items[name];
  return this.items[name];
};


module.exports = Classes;
