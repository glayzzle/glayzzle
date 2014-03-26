/**
 * Magma : PHP on NodeJS
 * @license BSD
 */
var util = require('util');
var phpBuilder = require('./builder');

module.exports = {
	checkFunction: function(name, args) {
		if (this.functions[name]) {
			return this.functions[name](args);
		} else {
			return false;
		}
	}
	,functions: {
		// compatibility example
		microtime: function(args) {
			if ( args.length == 1 && args[0] === true) {
				return '(process.hrtime()[0] * 1000 + process.hrtime()[1] / 1000)';
			} else if ( args.length == 1 && args[0] === false) {
				return 'process.hrtime()';
			} else {
				return 'PHP.compat.microtime(' + phpBuilder.php_args({args: args}) + ')';
			}
		}
	},
	microtime: function(asFloat) {
		if (!asFloat) {
			return process.hrtime();
		} else {
			var ret = process.hrtime();
			return hrTime[0] * 1000 + hrTime[1] / 1000;
		}
	}
};