/*!
 * Glayzzle : PHP on NodeJS
 * @authors https://github.com/glayzzle/glayzzle/graphs/contributors
 * @license BSD-3-Clause
 * @url http://glayzzle.com
 */

"use strict";

var Namespace = function(name, parent) {
  this.parent = parent;
  this.name = name;
  this.children = {};
  this.functions = {};
  this.constants = {};
  this.classes = {};
  this.traits = {};
  this.interfaces = {};
};

module.exports = Namespace;
