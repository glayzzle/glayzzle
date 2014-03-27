/**
 * Magma : PHP on NodeJS
 * @license BSD
 */
var util = require('util');
var builder = require('./builder');
var path = require('path');
var fs = require('fs');

module.exports = {
  __functions: {
    // default compatibility transformer
    __build: function(sender, args, name) {
      return builder.globalCall(name, args);
    },
  }
  ,__getCompatFunction: function(name) {
    if (!this.__functions.hasOwnProperty(name)) {
      if (fs.existsSync(__dirname + '/compat/' + name + '.js')) {
        var c = require('./compat/' + name);
        this.__functions[name] = c.hasOwnProperty('build') ? 
          c.build : this.__functions.__build
        ;
        // @fixme ? check if already defined
        this[name] = c.execute;
      } else {
        // flag as undefined
        console.log(__dirname + '/compat/' + name + '.js');
        this.__functions[name] = false;
      }
    }
    return this.__functions[name];
  }
  ,__call: function() {
    var name = arguments[0];
    if (!this.__functions.hasOwnProperty(name)) {
      if (!this.__getCompatFunction(name)) {
        throw new Error(
          'Error : Undefined function ' + name
        );
      }
    }
    return this[name].apply(this, Array.prototype.slice.call(arguments, 1));
  }
  // check if the specified function should be transformed (for PHP compatibility)
  ,__checkFunction: function(name, args) {
    var func = this.__getCompatFunction(name);
    if (func) {
      return func(this, args, name);
    } else {
      return false;
    }
  }
};