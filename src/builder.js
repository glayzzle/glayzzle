/**
 * Magma : PHP on NodeJS
 * @license BSD
 */
var util = require('util');
var path = require('path');

module.exports = {
	compat: null,
	requires: [],
	functions: [],
	filename: null,
	directory: null,
	init: function(filename) {
		this.filename = filename;
		this.directory = path.dirname(filename);
		this.requires = [];
		this.functions = [];
		return this;
	}
	,use: function(module, alias) {
		if ( this.requires.indexOf(module) == -1 ) {
			this.requires.push(module);
		}
		return module.replace(/[\.\\//]+/g, '_'); 
	}
	,headers: function() {
		if (this.requires.length == 0) return '';
		var result = [];
		this.requires.forEach(function(req) {
			result.push('var ' + req.replace(/[\.\\//]+/g, '_') + ' = require(' + JSON.stringify(req[0] == '.' ? path.resolve(__dirname, req) : req) + ')');
		});
		return result.join(';\n');
	}
	,getCompat: function() {
		if (!this.compat) {
			this.compat = require('./compat');
		}
		return this.compat;
	}
	// Builds a PHP AST to JavaScript
	,toString: function(ast) {
		if (!ast) return '';
		if (ast.type) {
			return this[ast.type](ast);
		} else {
			var result = [];
			for(var i = 0; i < ast.length; i++) {
				if (ast[i] == null) continue;
				if (ast[i].type) {
					result.push(this[ast[i].type](ast[i]));
				} else if(Array.isArray(ast[i])) {
					result.push(this.toString(ast[i]));
				} else {
					// console.log(typeof ast[i], ast[i]);
					result.push(ast[i]);
				}
			}
			return result.join('');
		}
	}
	// The T_ECHO equivalent
	,output: function(item) {
		return '__output.write(' + JSON.stringify(item.data) + ');\n';
	}
	,php: function(item) {
		return this.toString(item.data);
	}
	// SERIALIZE A GLOBAL FUNCTION
	,php_function: function(item) {
		var params = [];
		if (item.parameters) {
			item.parameters.forEach(function(param) {
				if (param && param.name) params.push(param.name);
			});
		}
		this.functions.push(
			item.name + ': function(' + params.join(', ') + ') {\n\t\t' 
			+ this.toString(item.body)
			+ '\n\t}'
		);
		return '';
	}
	,php_variable: function(item) {
		return item.name;
	}
	,php_string: function(item) {
		var output = JSON.stringify(item.data);
		return item.char + output.substring(1, output.length - 1) + item.char;
	}
	,php_T_ECHO: function(item) {
		return '__output.write(String(' + this.toString(item.statements) + '));\n';
	}
	// PROXY for functions
	,php_FUNCTION_CALL: function(item) {
		var ret = this.getCompat().checkFunction(item.name, item.args[1].args);
		if (ret === false) {
			if (require('./php').functions.hasOwnProperty(item.name)) {
				// global function
				return  builder.use('./php') + '.functions.' + item.name + this.toString(item.args);
			} else {
				// local scope function
				return 'this.' + item.name + this.toString(item.args);
			}
		} else return ret;
	}
	// Serialize arguments for a function call
	,php_args: function(item) {
		var result = [];
		var module = this;
		item.args.forEach(function(i) {
			if (Array.isArray(i)) {
				result.push(module.toString(i));
			} else {
				result.push(i);
			}
		});
		return result.join(', ');
	}
	, php_T_INCLUDE: function(item) {
		return  this.use('./php') 
			+ '.include(' 
			+ this.use('path') + '.resolve(' + JSON.stringify(this.directory) + ', ' + this.toString(item.target) + ')'
			+ ', ' + (item.ignore ? 'true' : 'false')
			+ ', __output'
		+')';
	}
	, php_T_INCLUDE_ONCE: function(item) {
		return  this.use('./php') 
			+ '.include_once(' 
			+ this.use('path') + '.resolve(' + JSON.stringify(this.directory) + ', ' + this.toString(item.target) + ')'
			+ ', ' + (item.ignore ? 'true' : 'false')
			+ ', __output'
		+')';
	}
	, php_T_REQUIRE: function(item) {
		return  this.use('./php') 
			+ '.require(' 
			+ this.use('path') + '.resolve(' + JSON.stringify(this.directory) + ', ' + this.toString(item.target) + ')'
			+ ', ' + (item.ignore ? 'true' : 'false')
			+ ', __output'
		+')';
	}
	, php_T_REQUIRE_ONCE: function(item) {
		return  this.use('./php') 
			+ '.require_once(' 
			+ this.use('path') + '.resolve(' + JSON.stringify(this.directory) + ', ' + this.toString(item.target) + ')'
			+ ', ' + (item.ignore ? 'true' : 'false')
			+ ', __output'
		+')';
	}
	,php_if: function(item) {
		return 'if (' +  this.toString(item.condition) + ')'
			 + this.toString(item.statement) 
			 + this.toString(item._elseif) 
			 + this.toString(item._else)
		; 
	}
	,php_statements: function(item) {
		return '{\n' +  this.toString(item.data) + '\n}\n';
	}
	,php_else: function(item) {
		return ' else ' +  this.toString(item.data);
	}
	,php_elseif: function(item) {
		return ' elseif(' + this.toString(item.condition) + ')' +  this.toString(item.statement);
	}
};