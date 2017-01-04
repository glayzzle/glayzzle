/*!
 * Glayzzle : PHP on NodeJS
 * @authors https://github.com/glayzzle/glayzzle/graphs/contributors
 * @license BSD-3-Clause
 * @url http://glayzzle.com
 */

"use strict";

var Variables = require('./variables');
var Namespaces = require('./namespaces');
var Traits = require('./traits');
var Functions = require('./functions');
var Interfaces = require('./interfaces');
var Classes = require('./classes');
var Constants = require('./constants');

/**
 * Defines the global PHP context that contains
 * a list of informations
 * @constructor Context
 */
var Context = function(php) {
  this.php        = php;
  this.loaders    = [];
  this.class      = new Classes(this);
  this.interface  = new Interfaces(this);
  this.trait      = new Traits(this);
  this.function   = new Functions(this);
  this.constant   = new Constants(this);
  this.variable   = new Variables(this);
  this.namespace  = new Namespaces(this);
};


/**
 * Declares an autoload function
 * @return {Boolean}
 */
Context.prototype.autoload = function(fn, prepend) {
  if (prepend) {
    this.loaders.unshift(fn);
  } else {
    this.loaders.push(fn);
  }
  return true;
};

module.exports = Context;
