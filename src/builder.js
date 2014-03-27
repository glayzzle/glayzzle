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
  serialize: {},
  filename: null,
  directory: null,
  // initialize the specified file
  init: function(filename) {
    this.filename = filename;
    this.directory = path.dirname(filename);
    this.requires = [];
    this.functions = [];
    return this;
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
    return this.use('./php')+'.globals.__call(' + JSON.stringify(name) + ', ' + this.transcriptNode({type: 'common.T_ARGS', args: args}) + ')';  
  }
  // Execute the right transcription on the specified AST node
  ,transcriptNode: function(node) {
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
  // Builds a PHP AST to JavaScript
  ,toString: function(ast) {
    if (!ast) return '';
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
          // console.log(typeof ast[i], ast[i]);
          result.push(ast[i]);
        }
      }
      return result.join('');
    }
  }
};