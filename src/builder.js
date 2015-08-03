/**
 * Glayzzle : PHP on NodeJS
 * @url http://glayzzle.com
 * @license BSD-3-Clause
 */

var builder = function(php) {
  this.php = php;
  require('./transcriptors/internal')(this);
};


// define temporary path
Object.defineProperty(builder.prototype, "decorators", {
  enumerable: false,
  configurable: false,
  writable: false,
  value: {}
});

/**
 * Converts AST code to javascript
 */
builder.prototype.getCode = function(ast, filename) {
  if (ast[0] !== 'program') {
  	throw new Error('Bad AST structure');
  }
  console.log(ast);
  var result = {
    header: [],
    functions: []
  };
  result.functions.push('__main: function() { return null; }');
  
  // @todo
  return result;
};

module.exports = builder;