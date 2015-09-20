/**
 * Glayzzle : PHP on NodeJS
 * @url http://glayzzle.com
 * @license BSD-3-Clause
 */

/**
 * Builder context
 */
var WriterContext = function() {
	this.vars = {};
	this.args = [];
};


WriterContext.prototype.param = function(name, optional, defValue) {
	this.args.push({
		name: name,
		optional: optional,
		value: defValue
	});
	this.vars[name] = {
		option: true,
		local: true
	};
};

WriterContext.prototype.setGlobal = function(name) {
	this.vars[name] = {
		option: false,
		local: false
	};
};

WriterContext.prototype.set = function(name, value) {
	this.vars[name] = {
		option: false,
		local: true,
		value: value
	};
};

WriterContext.prototype.has = function(name) {
	return this.vars.hasOwnProperty(name);
};


/**
 * Writer object (helper/decorator for the javascript code)
 * @params builder
 */
var Writer = function(builder) {
	this.builder = builder;
	this.functions = {};
	this.header = {};
	this.body = [];
	this.context = [];
	this.startContext();
};

Writer.prototype.startContext = function() {
	var ctx = new WriterContext();
	this.context.push(ctx);
	return ctx;
};

Writer.prototype.endContext = function() {
	return this.context.pop();
};

Writer.prototype.getContext = function() {
	return this.context[this.context.length - 1];
};

Writer.prototype.write = function(line) {
	this.body.push(line);
	return line;
};

Writer.prototype.parse = function(ast) {
	return this.builder.parse(this, ast);
};

Writer.prototype.getCode = function(ast) {
	var idx = this.body.length;
	this.builder.parse(this, ast);
	return this.body.splice(idx-1).join("\n");
};

Writer.prototype.asString = function(ast) {
	switch(ast[0]) {
		case 'string':
		case 'number':
		case 'bin':
			return this.parse(ast);
		case 'var':
			if (!this.getContext().has(ast[1])) {
				this.getContext().set(ast[1]);
			}
			return this.write(ast[1]);
		default:
			throw new Error('Unserializable type ' + ast[0]);
	}
};


/**
 * Outputs the generated code
 */
Writer.prototype.toString = function() {
	var code = '// headers section\n';
	for(var h in this.header) {
		code += this.header[h] + '\n';
	}
	code += '// functions declaration\n';
	code += '\n\t\treturn {';
	code += '\n\t\t\t__main: function() {\n';
	if (this.context.length !== 1) {
		throw new Error('Bad context size');
	}
	for(var v in this.context[0].vars) {
		var vEntry = this.context[0].vars[v];
		if (vEntry.local && !vEntry.option) {
			code += '\t\t\t\tvar ' + v + ' = ' + (vEntry.value ? vEntry.value : 'null') + ';\n';
		}
	}
	code += this.body.join('\n') + '\n\t\t\t}';
	for(var n in this.functions) {
		var f = this.functions[n];
		code += ',\n\t\t\t' + n + ': function(' + f.args + ') {\n' + f.body + '\n\t\t\t}';
	}
	return code + '\n\t\t};';
};

module.exports = Writer;

