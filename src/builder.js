/**
 * Magma : PHP on NodeJS
 * @license BSD
 */
var util = require('util');
module.exports = {
	// Builds a PHP AST to JavaScript
	toString: function(ast) {
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
		return 'console.log(' + JSON.stringify(item.data) + ');\n';
	}
	,php: function(item) {
		return this.toString(item.data);
	}
	,php_function: function(item) {
		var params = [];
		if (item.parameters) {
			item.parameters.forEach(function(param) {
				if (param && param.name) params.push(param.name);
			});
		}
		return '\nfunction ' + item.name + '(' + params.join(', ') + ') {\n' 
			+ this.toString(item.body)
			+ '\n}\n'
		;
	}
	,php_variable: function(item) {
		return item.name;
	}
	,php_T_ECHO: function(item) {
		return 'console.log(' + this.toString(item.statements) + ');\n';
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