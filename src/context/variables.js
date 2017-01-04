/*!
 * Glayzzle : PHP on NodeJS
 * @authors https://github.com/glayzzle/glayzzle/graphs/contributors
 * @license BSD-3-Clause
 * @url http://glayzzle.com
 */

"use strict";


/**
 * Handles variables (from global context)
 * @constructor Variables
 */
var Variables = function(php) {
  this.items = {};
  this.php = php;
};

// gets a variable
Variables.prototype.get = function(name) {
  if (!this.items.hasOwnProperty(name)) {
    this.php.trigger_error(
      'Undefined variable: '+name
      , this.php.constant('E_NOTICE')
    );
  } else {
    return this.items[name];
  }
};

// sets a variable
Variables.prototype.set = function(name, value) {
  this.items[name] = value;
  return value;
};

// check if a variable exists
Variables.prototype.has = function(name) {
  return this.items.hasOwnProperty(name);
};

module.exports = Variables;
