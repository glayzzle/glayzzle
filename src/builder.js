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
  T_PUBLIC:     1,
  T_PROTECTED:  2,
  T_PRIVATE:    4,
  T_STATIC:     8,
  T_ABSTRACT:   16,
  T_FINAL:      32,
  
  compat: null,
  requires: [],
  functions: [],
  classes: {},
  serialize: {},
  filename: null,
  directory: null,
  // compiles again the parser using pegjs
  compile: function(cb, cb_err) {
    var PEG = require('pegjs');
    var fs = require('fs');
    var PHP = require('./php');
    var GRAMMAR_PATH = __dirname + '/grammar/';
    if (process.env.DEBUG > 0) console.log('> Read parsing rules');
    // Reads a list of files and executes the specified callback
    var readFiles = function(files, cb) {
      var counter = files.length;
      var result = { files: {}, errors: []};
      if (!files || files.length == 0) {
        cb(result);
      } else {
        files.forEach(function (file){
          fs.readFile(file, 'utf8', function(err,data) {
            if (err) {
              result.errors.push(err);
            } else {
              result.files[file] = data;
            }
            counter --;
            if (counter == 0) cb(result);
          });
        });
      }
    };
    fs.readFile(GRAMMAR_PATH + 'php.pegjs', 'utf8', function(err, data) {
      if (err) {
        if (cbErr) cbErr(err);
        return;
      }
      if (process.env.DEBUG > 0) console.log('> Build parser');
      var importRegex = /^@import\s+'([A-Za-z0-9\-_.]*)'$/mg;
      var files = [];
      match = importRegex.exec(data);
      while (match != null) {
        files.push(match[1]);
        match = importRegex.exec(data);
      }
      if (files && files.length > 0) {
        for(var i = 0; i < files.length; i++) {
          files[i] = GRAMMAR_PATH + files[i];
        }
      } else {
        files = [];
      }
      readFiles(files, function(imports) {
        try {
          data = data.replace(
            importRegex,
            function(match, file) {
              return imports.files[GRAMMAR_PATH + file];
            }
          );
          fs.writeFileSync(
            __dirname + '/parser.js'
            , 'module.exports = ' 
            + PEG.buildParser(data, {
              cache:    false,
              output:   'source',
              optimize: 'speed',
              plugins:  []
            })
            + ';\n'
          );
        } catch(e) {
          PHP.context.parseError(e, data);
        }
        if (process.env.DEBUG > 0) console.log('*** BUILD DONE ***');
        if (cb) cb();
      });
    });
  }
  // initialize the specified file
  ,init: function(filename) {
    this.filename = filename;
    this.directory = path.dirname(filename);
    this.requires = [];
    this.functions = [];
    this.classes = {};
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
      } else if (t === 'string' ) {
        return JSON.stringify(ast);
      } else return ast;
    }
  }
};