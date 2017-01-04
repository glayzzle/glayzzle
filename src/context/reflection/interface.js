/*!
 * Glayzzle : PHP on NodeJS
 * @authors https://github.com/glayzzle/glayzzle/graphs/contributors
 * @license BSD-3-Clause
 * @url http://glayzzle.com
 */

"use strict";

var Interface = function(name, namespace) {
  this.name = name;
  this.namespace = namespace;
  this.extends = null;
  this.public = {};
  this.protected = {};
  this.static = {
    public: {},
    protected: {},
    constant: {}
  };
};

module.exports = Interface;
