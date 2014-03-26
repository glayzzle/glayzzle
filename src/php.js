/**
 * Magma : PHP on NodeJS
 * @license BSD
 */
var util = require('util');

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
	VERSION: '0.0.1',

	// contains the PHP tokenizer
	parser: null,

	// retro-PHP-compatibility layer
	globals: require('./compat'),

	// current execution context
	context: require('./context'),

	// List of global functions
	functions: {},

	/**
	 * Includes a PHP script
	 */
	include: function(filename, ignore, output) {
		try {
			var code = this.context.get(filename);
		} catch(e) {
			if (!ignore) {
				return util.error('Warning : T_INCLUDE error on ' + filename + '\nCaused by : \n' + e);
			}
		}
		if (code) {
			return code.__main(
				output ? output : process.stdout
			);
		}
	}
};