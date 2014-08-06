/**
 * Glayzzle : PHP on NodeJS
 * @url http://glayzzle.com
 * @author Ioan CHIRIAC
 * @license BSD-3-Clause
 */
var lexer = require('../lexer');
module.exports = {
  execute: function(code) {
    var result = [], EOF = 1;
    lexer.all_tokens = true;
    lexer.setInput(code);
    var token = lexer.lex() || lexer.EOF;
    while(token != lexer.EOF) {
      if (typeof token === 'string') {
        result.push(token);
      } else {
        result.push([ token, lexer.yytext, lexer.yylloc.first_line ]);
      }
      token = lexer.lex() || lexer.EOF;
    }
    return result;
  }
};