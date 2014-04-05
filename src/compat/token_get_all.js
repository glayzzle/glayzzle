/**
 * Glayzzle : PHP on NodeJS
 * @url http://glayzzle.com
 * @author Ioan CHIRIAC
 * @license BSD-3-Clause
 */
var tok = require('../tokenizer');
module.exports = {
  execute: function(code) {
    return tok.parseHTML(tok.createContext(code)).tokens;
  }
};