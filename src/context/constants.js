/*!
 * Glayzzle : PHP on NodeJS
 * @authors https://github.com/glayzzle/glayzzle/graphs/contributors
 * @license BSD-3-Clause
 * @url http://glayzzle.com
 */

"use strict";

var os = require('os');
var path = require('path');

var core = 'Core';
var user = 'user';
var std = 'standard';

/**
 * Handles constants
 * @constructor Constants
 */
var Constants = function(ctx) {
  this.ctx = ctx;
  // List of default constants
  // php -r "print_r(get_defined_constants(true));" > constants.txt
  this.items: {
    /** CORE CONSTANTS **/
    E_ERROR:             { value: 1, category: core },
    E_WARNING:           { value: 2, category: core },
    E_PARSE:             { value: 4, category: core },
    E_NOTICE:            { value: 8, category: core },
    E_CORE_ERROR:        { value: 16, category: core },
    E_CORE_WARNING:      { value: 32, category: core },
    E_COMPILE_ERROR:     { value: 64, category: core },
    E_COMPILE_WARNING:   { value: 128, category: core },
    E_USER_ERROR:        { value: 256, category: core },
    E_USER_WARNING:      { value: 512, category: core },
    E_USER_NOTICE:       { value: 1024, category: core },
    E_STRICT:            { value: 2048, category: core },
    E_RECOVERABLE_ERROR: { value: 4096, category: core },
    E_DEPRECATED:        { value: 8192, category: core },
    E_USER_DEPRECATED:   { value: 16384, category: core },
    E_ALL:               { value: 32767, category: core },
    PHP_OS:              { value: os.type(), category: core },
    PHP_EOL:             { value: os.EOL, category: core },
    /** STANDARD **/
    CONNECTION_ABORTED:  { value: 1, category: std },
    CONNECTION_NORMAL:   { value: 0, category: std },
    CONNECTION_TIMEOUT:  { value: 2, category: std },
    INI_USER:            { value: 1, category: std },
    INI_PERDIR:          { value: 2, category: std },
    INI_SYSTEM:          { value: 4, category: std },
    INI_ALL:             { value: 7, category: std },
    INI_SCANNER_NORMAL:  { value: 0, category: std },
    INI_SCANNER_RAW:     { value: 1, category: std },
    PHP_URL_SCHEME:      { value: 0, category: std },
    PHP_URL_HOST:        { value: 1, category: std },
    PHP_URL_PORT:        { value: 2, category: std },
    PHP_URL_USER:        { value: 3, category: std },
    PHP_URL_PASS:        { value: 4, category: std },
    PHP_URL_PATH:        { value: 5, category: std },
    PHP_URL_QUERY:       { value: 6, category: std },
    PHP_URL_FRAGMENT:    { value: 7, category: std },
    PHP_QUERY_RFC1738:   { value: 1, category: std },
    PHP_QUERY_RFC3986:   { value: 2, category: std },
    M_E:                 { value: 2.718281828459, category: std },
    M_LOG2E:             { value: 1.442695040889, category: std },
    M_LOG10E:            { value: 0.43429448190325, category: std },
    M_LN2:               { value: 0.69314718055995, category: std },
    M_LN10:              { value: 2.302585092994, category: std },
    M_PI:                { value: 3.1415926535898, category: std },
    M_PI_2:              { value: 1.5707963267949, category: std },
    M_PI_4:              { value: 0.78539816339745, category: std },
    M_1_PI:              { value: 0.31830988618379, category: std },
    M_2_PI:              { value: 0.63661977236758, category: std },
    M_SQRTPI:            { value: 1.7724538509055, category: std },
    M_2_SQRTPI:          { value: 1.1283791670955, category: std },
    M_LNPI:              { value: 1.1447298858494, category: std },
    M_EULER:             { value: 0.57721566490153, category: std },
    M_SQRT2:             { value: 1.4142135623731, category: std },
    M_SQRT1_2:           { value: 0.70710678118655, category: std },
    M_SQRT3:             { value: 1.7320508075689, category: std },
    INF:                 { value: 'INF', category: std },
    NAN:                 { value: 'NAN', category: std },
    PHP_ROUND_HALF_UP:   { value: 1, category: std },
    PHP_ROUND_HALF_DOWN: { value: 2, category: std },
    PHP_ROUND_HALF_EVEN: { value: 3, category: std },
    PHP_ROUND_HALF_ODD:  { value: 4, category: std },
    /* ... */
    DIRECTORY_SEPARATOR: { value: path.sep, category: std },
    PATH_SEPARATOR:      { value: path.delimiter, category: std },
  };
};

/**
 * Sets a constant value
 */
Constants.prototype.set = function(name, contents, category) {
  if (this.items.hasOwnProperty(name)) {
    this.ctx.php.trigger_error(
      'Constant ' + name + ' is already defined', this.item.E_NOTICE.value
    );
    return false;
  } else {
    this.items[name] = { value: contents, category: category || user };
    return true;
  }
};

/**
 * Reads a constant value
 */
Constants.prototype.get = function(name) {
  if (!this.items.hasOwnProperty(name)) {
    this.ctx.php.trigger_error(
      ' Use of undefined constant '+name+' - assumed \''+name+'\''
      , this.items.E_NOTICE.value
    );
    return name;
  } else {
    return this.items[name].value;
  }
};

/**
 * Check if the specified constant exists
 */
Constants.prototype.has = function(name) {
  return this.items.hasOwnProperty(name);
};


module.exports = Constants;
