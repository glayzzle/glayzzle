/*!
 * Glayzzle : PHP on NodeJS
 * @authors https://github.com/glayzzle/glayzzle/graphs/contributors
 * @license BSD-3-Clause
 * @url http://glayzzle.com
 */

"use strict";

var Trait = function(name, namespace) {
  this.extends = null;
  this.public = {};
  this.protected = {};
  this.private = {};
  this.static = {
    public: {},
    protected: {},
    private: {},
    constant: {}
  };
};

module.exports = Trait;
