/**
 * Glayzzle - run PHP on NodeJS
 * @url http://glayzzle.com
 * @license BSD-3-Clause
 */

var util = require('util');
var fs = require('fs');
var pkg = require('../package.json');
var context = require('./context');


/**
 * php main class
 * 
 * Usage : 
 * 
 * demo.js :
 * var glayzzle = require('./src/php');
 * var php = new glayzzle();
 * var result = php.include('./demo.php');
 * console.log(result);
 * console.log(php.foo(5));
 * 
 * demo.php
 * function foo($x) {
 *   return $x;
 * }
 * return "foo";
 */
var php = function(config) {
  this.config = config || {};
  // initialize the context
  this.context = new context(this);
  // sets the temporary directory
  if (this.config.hasOwnProperty('sys_temp_dir')) {
    this.context.tmp = this.config.sys_temp_dir;
  }
  // configure the stdout object
  if (this.config.hasOwnProperty('stdout')) {
    this.writer = this.config.stdout;
  }
};

// define PHP the version
Object.defineProperty(php.prototype, "version", {
  enumerable: true,
  configurable: false,
  writable: false,
  value: pkg.version
});

// define PHP output module
Object.defineProperty(php.prototype, "stdout", {
  enumerable: false,
  configurable: false,
  writable: true,
  value: function(msg) {
    process.stdout.write(msg);
  }
});

// define PHP output module
Object.defineProperty(php.prototype, "stderr", {
  enumerable: false,
  configurable: false,
  writable: true,
  value: function(msg) {
    process.stderr.write(msg);
  }
});

// defines the path module (resolves filenames)
Object.defineProperty(php.prototype, "path", {
  enumerable: false,
  configurable: false,
  writable: true,
  value: require('path').resolve
});

// defines the path module (resolves filenames)
Object.defineProperty(php.prototype, "context", {
  enumerable: false,
  configurable: false,
  writable: true,
  value: null
});

// helper for reading a constant
Object.defineProperty(php.prototype, "constant", {
  enumerable: false,
  configurable: false,
  writable: false,
  value: function(key) {
    return this.context.constants.get(key);
  }
});


// defines the warning module
Object.defineProperty(php.prototype, "trigger_error", {
  enumerable: false,
  configurable: false,
  writable: false,
  value: function(e, type) {
    type = type || this.constant('E_USER_NOTICE');
    var errType = 'Error';
    switch(type) {
      case this.constant('E_ERROR'): errType = 'Fatal Error'; break;
      case this.constant('E_WARNING'): errType = 'Warning'; break;
      case this.constant('E_PARSE'): errType = 'Parse Error'; break;
      case this.constant('E_NOTICE'): errType = 'Notice'; break;
      default:
        return false;
    }
    // @todo : output with the standard error writer
    this.stderr(
      errType + ' : ' + e.message + '\nCaused by : \n' + e.stack
    );
    return true;
  }
});


// define PHP execution context
Object.defineProperty(php.prototype, "context", {
  enumerable: false,
  configurable: false,
  writable: true,
  value: null
});

/**
 * run a eval over the specified PHP code
 */
php.prototype.eval = function(code) {
  return this.context.eval(code);
};

/**
 * run a eval over the specified PHP code
 */
php.prototype.include = function(filename) {
  try {
    return this.context.get(
      this.path(filename)
    );
  } catch(e) {
    this.trigger_error(
      'T_INCLUDE error on ' + filename, this.constant('E_WARNING'), e
    );
    return false;
  }
};

/**
 * includes the specified script only one time
 */
php.prototype.include_once = function(filename) {
  filename = this.path(filename);
  if (!this.context.includes.hasOwnProperty(filename)) {
    return this.include(filename);
  }
  return null;
};

/**
 * requires the specified script and throws an error if its not found
 */
php.prototype.require = function(filename) {
  var result = this.include(filename);
  if (result === false) {
    throw new Error(
      "Error : Required file " + filename + " does not exists"
    );
  }
  return result;
};

/**
 * require_once
 */
php.prototype.require_once = function(filename) {
  var result = this.include_once(filename);
  if (result === false) {
    throw new Error(
      "Error : Required file " + filename + " does not exists"
    );
  }
  return result;
};

// expose the php constructor
module.exports = php;