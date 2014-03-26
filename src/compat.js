/**
 * Magma : PHP on NodeJS
 * @license BSD
 */
var util = require('util');
var builder = require('./builder');

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
				return '(new Date().getTime() / 1000)';
			} else if ( args.length == 1 && args[0] === false) {
				return '((Math.round(((new Date().getTime() / 1000) - parseInt((new Date().getTime() / 1000), 10)) * 1000) / 1000) + \' \' + parseInt((new Date().getTime() / 1000), 10)';
			} else {
				return builder.use('./php')+'.compat.microtime(' + builder.php_args({args: args}) + ')';
			}
		},
		round: function(args) {
				return builder.use('./php')+'.compat.round(' + builder.php_args({args: args}) + ')';
		}
	},
	//  discuss at: http://phpjs.org/functions/microtime/
	// original by: Paulo Freitas
	//   example 1: timeStamp = microtime(true);
	//   example 1: timeStamp > 1000000000 && timeStamp < 2000000000
	//   returns 1: true
	microtime: function(get_as_float) {
		var now = new Date().getTime() / 1000;
		var s = parseInt(now, 10);
		return (get_as_float) ? now : (Math.round((now - s) * 1000) / 1000) + ' ' + s;
	},
	//  discuss at: http://phpjs.org/functions/round/
	// original by: Philip Peterson
	//  revised by: Onno Marsman
	//  revised by: T.Wild
	//  revised by: Rafał Kukawski (http://blog.kukawski.pl/)
	//    input by: Greenseed
	//    input by: meo
	//    input by: William
	//    input by: Josep Sanz (http://www.ws3.es/)
	// bugfixed by: Brett Zamir (http://brett-zamir.me)
	//        note: Great work. Ideas for improvement:
	//        note: - code more compliant with developer guidelines
	//        note: - for implementing PHP constant arguments look at
	//        note: the pathinfo() function, it offers the greatest
	//        note: flexibility & compatibility possible
	//   example 1: round(1241757, -3);
	//   returns 1: 1242000
	//   example 2: round(3.6);
	//   returns 2: 4
	//   example 3: round(2.835, 2);
	//   returns 3: 2.84
	//   example 4: round(1.1749999999999, 2);
	//   returns 4: 1.17
	//   example 5: round(58551.799999999996, 2);
	//   returns 5: 58551.8
	round: function(value, precision, mode) {
		var m, f, isHalf, sgn; // helper variables
		precision |= 0; // making sure precision is integer
		m = Math.pow(10, precision);
		value *= m;
		sgn = (value > 0) | -(value < 0); // sign of the number
		isHalf = value % 1 === 0.5 * sgn;
		f = Math.floor(value);
		
		if (isHalf) {
			switch (mode) {
				case 'PHP_ROUND_HALF_DOWN':
					value = f + (sgn < 0); // rounds .5 toward zero
					break;
				case 'PHP_ROUND_HALF_EVEN':
					value = f + (f % 2 * sgn); // rouds .5 towards the next even integer
					break;
				case 'PHP_ROUND_HALF_ODD':
					value = f + !(f % 2); // rounds .5 towards the next odd integer
					break;
				default:
					value = f + (sgn > 0); // rounds .5 away from zero
			}
		}
		return (isHalf ? value : Math.round(value)) / m;
	}

};