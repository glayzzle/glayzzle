/*!
 * Glayzzle : PHP on NodeJS
 * @authors https://github.com/glayzzle/glayzzle/graphs/contributors
 * @license BSD-3-Clause
 * @url http://glayzzle.com
 */

"use strict";

var Namespace = require('./reflection/namespace');

/**
 * Handles namespaces
 * @constructor Variables
 */
var Namespaces = function(php) {
  this.root = new Namespace('', null);
  this.php = php;
};



/**
 * gets or creates a namespace
 * @return {Namespace}
 */
Namespaces.prototype.get = function(name) {
  if (typeof name === 'string') {
    name = name.split('\\');
  }
  if (name[0] === '') name.shift();

  var item  = this.root;
  for(var i = 0; i < name.length; i++) {
    var child = name[i];
    if (!item.children.hasOwnProperty(child)) {
      item.children[child] = new Namespace(child, item);
    }
    item = item.children[child];
  }
  return item;
};

// check if a variable exists
Namespaces.prototype.has = function(name) {
  if (name[0] === '\\') name = name.substring(1);
  var names = name.split('\\');
  var item  = this.root;
  for(var i = 0; i < names.length; i++) {
    name = names[i];
    if (!item.children.hasOwnProperty(name)) return false;
  }
  return true;
};

module.exports = Namespaces;
