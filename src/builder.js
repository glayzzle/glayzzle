/**
 * Glayzzle : PHP on NodeJS
 * @url http://glayzzle.com
 * @author Ioan CHIRIAC
 * @license BSD-3-Clause
 */

var util = require('util');
var path = require('path');

module.exports = {
  /** MODIFIERS CONSTANTS **/
   T_PUBLIC:     1
  ,T_PROTECTED:  2
  ,T_PRIVATE:    4
  ,T_STATIC:     8
  ,T_ABSTRACT:   16
  ,T_FINAL:      32
  
  ,compat:      null
  ,requires:    []
  ,functions:   []
  ,classes:     {}
  ,serialize:   {}
  ,filename:    null
  ,directory:   null

  // initialize the specified file
  ,init: function(filename) {
    this.filename = filename;
    this.directory = path.dirname(filename);
    this.requires = [];
    this.functions = [];
    this.classes = {};
    return this;
  }

  // gets the current parser or load the default php parser
  ,getParser: function() {
    if (!this.parser) {
      this.parser = require('./parser').parser;
      this.parser.define_function = function() {
        var name = arguments[0];
        arguments.shift();
        return {
          type: 'function.T_CALL',
          name: name,
          args: arguments
        };
      };
    }
    return this.parser;
  }

  // Require to use the specified module
  ,use: function(module, alias) {
    if ( this.requires.indexOf(module) == -1 ) {
      this.requires.push(module);
    }
    if ( !alias ) alias = module.replace(/[\.\\//]+/g, '_');
    return alias;
  }
  // Generate file headers
  ,headers: function() {
    if (this.requires.length == 0) return '';
    var result = [];
    this.requires.forEach(function(req) {
      result.push(
        'var ' 
        + req.replace(/[\.\\//]+/g, '_') 
        + ' = require(' 
          + JSON.stringify(req[0] == '.' ? 
            path.resolve(__dirname, req) : req) 
        + ')'
      );
    });
    return result.join(';\n');
  }
  // Gets the PHP compatibility layer
  ,getCompat: function() {
    if (!this.compat) {
      this.compat = require('./compat');
    }
    return this.compat;
  }
  , globalCall: function(name, args) {
    name = JSON.stringify(name);
    if ( args && args.length > 0) {
      args.unshift(name);
      return this.use('./php')+'.globals.__call('  + this.transcriptNode({type: 'common.T_ARGS', args: args }) + ')';
    } else {
      return this.use('./php')+'.globals.__call('  + name + ')';
    }
  }
  // Execute the right transcription on the specified AST node
  ,transcriptNode: function(node) {
    if (!node || !node.type) return '';
    // lazy loads serialisation module
    if (!this.serialize.hasOwnProperty(node.type)) {
      var mod = node.type.split('.');
      var transcriptor = require('./transcriptors/' + mod[0]);
      var entries = transcriptor.init(this);
      this.serialize[mod[0]] = {};
      for(var f in entries) {
        this.serialize[mod[0] + '.' + f] =  entries[f];
        this.serialize[mod[0]][f] =  entries[f];
      }
    }
    return this.serialize[node.type](node);
  }
  // Generate the main script code
  ,getMainFunction: function(ast) {
    var code = this.toString(ast);
    var cls = [];
    for(var n in this.classes) {
      cls.push('this.' + n + ' = this.' + n + this.classes[n] + ';');
    }
    return '__main: function( __output ) {'
      + '\n\t\tthis.__output = __output;'
      + '\n\t\t' + cls.join('\n\t\t') + code 
      + '\n\t}'
    ;
  }
  // Builds a PHP AST to JavaScript
  ,toString: function(ast) {
    if (ast === null) return 'null';
    var t = typeof ast;
    if (t === 'object') {
      if (ast.type) {
        return this.transcriptNode(ast);
      } else {
        var result = [];
        for(var i = 0; i < ast.length; i++) {
          if (ast[i] == null) continue;
          if (ast[i].type) {
            result.push(this.transcriptNode(ast[i]));
          } else if(Array.isArray(ast[i])) {
            result.push(this.toString(ast[i]));
          } else {
            result.push(ast[i]);
          }
        }
        return result.join('');
      }
    } else {
      if ( t === 'undefined' ) {
        return 'null';
      } else return ast;
    }
  }
};