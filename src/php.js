/**
 * Glayzzle : PHP on NodeJS
 * @url http://glayzzle.com
 * @author Ioan CHIRIAC
 * @license BSD-3-Clause
 */

var util = require('util');
var path = require('path');
var fs = require('fs');

/**
 * PHP helper (makes NodeJS and PHP to communicate)
 * 
 * Usage : 
 * 
 * demo.js :
 * var PHP = require('./src/php');
 * var result = PHP.include('./demo.php');
 * console.log(result);
 * console.log(PHP.globals.foo(5));
 * 
 * demo.php
 * function foo($x) {
 *   return $x;
 * }
 * return "foo";
 * 
 */
module.exports = {
  // Current version
  VERSION: '0.0.3',

  // contains the PHP tokenizer
  parser: null,

  // retro-PHP-compatibility layer
  globals: false,

  // current execution context
  context: false,
  
  // cleans actual context
  clean: function() {
    this.globals = require('./compat');
    this.context = require('./context').init(this);
    return this;
  }
  // run a eval over PHP code
  ,eval: function(code, ignore, output) {
    try {
      return this.context.eval(code).__main(
        output ? output : process.stdout
      );
    } catch(e) {
      if (!ignore) throw e;
    }
  }
  /**
   * Includes a PHP script
   */
  ,include: function(filename, ignore, output) {
    filename = path.resolve(filename);
    // @todo : improve speed by avoid fs access
    if (ignore || fs.existsSync(filename)) {
      try {
        var code = this.context.get(filename);
      } catch(e) {
        if (!ignore) {
          return util.error(
            'Warning : T_INCLUDE error on ' + filename + '\nCaused by : \n' 
            + e.message
            + '\n\nStack : '
            + e.stack
          );
        }
      }
      if (code) {
        return code.__main(
          output ? output : process.stdout
        );
      }
    } else {
      if (!ignore) {
        return util.error(
          'Warning : T_INCLUDE error on ' + filename
        );
      }
    }
  }
  // includes the specified script only one time
  , include_once: function(filename, ignore, output) {
    filename = path.resolve(filename);
    if (!this.context.once(filename)) {
      return this.include(filename, ignore, output);
    }
  }
  // requires the specified script and throws an error if its not found
  , require: function(filename, output) {
    filename = path.resolve(filename);
    if (fs.existsSync(filename)) {
      return this.include(filename, true, output);
    } else {
      throw new Error(
        "Error : Required file " + filename + " does not exists"
      );
    }
  }
  // require_once
  , require_once: function(filename, output) {
    filename = path.resolve(filename);
    if (!this.context.once(filename)) {
      return this.require(filename, output);
    }
  }
};
if (typeof(process.env.DEBUG) == 'undefined') process.env.DEBUG = 0;
module.exports.clean();