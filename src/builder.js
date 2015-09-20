/**
 * Glayzzle : PHP on NodeJS
 * @url http://glayzzle.com
 * @license BSD-3-Clause
 */

var Writer = require('./writer.js');

/**
 * The builder library
 */
var builder = {
  decorators: {},
  /**
   * Parsing an ast node
   */
  parse: function(result, ast) {
      var cb = builder.decorators[ast[0]];
      if (typeof cb === 'function') {
        return cb.apply(cb, [result, ast]);
      } else {
        console.log(ast);
        throw new Error('Not implemented ' + ast[0]);
      }
  },
  /**
   * Declare a decorator
   */
  declare: function(name, reader) {
    if (typeof reader === 'function') {
      builder.decorators[name] = reader;
    } else {
      if (!builder.decorators.hasOwnProperty(name)) {
        builder.decorators[name] = function(writer, ast) {
          var cb = this[ast[1]];
          if (typeof cb === 'function') {
            cb(writer, ast);
          } else {
            throw new Error('Not implemented : ' + ast[1]);
          }
        };
      }
      for(var i in reader) {
        builder.decorators[name][i] = reader[i]; 
      }
    }
    return builder.decorators[name];
  },
  /**
   * Converts AST code to javascript
   */
  getCode: function(ast, filename) {
    if (ast[0] !== 'program') {
      throw new Error('Bad AST structure');
    }
    var result = new Writer(this);
    for(var i = 0; i < ast[1].length; i++) {
      this.parse(result, ast[1][i]);
    }
    // console.log(result.toString());
    return result;
  }
};


// initialize default transcriptors
require('./transcriptors/internal.js')(builder.declare);

// exports the builder library
module.exports = builder;