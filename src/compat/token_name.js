/**
 * Glayzzle : PHP on NodeJS
 * @url http://glayzzle.com
 * @author Ioan CHIRIAC
 * @license BSD-3-Clause
 */
var tokens = require('../grammar/tokens');
module.exports = {
  execute: function(token) {
    if (tokens.hasOwnProperty(token)) {
      return tokens[token];
    } else {
      return null;
    }
    return result;
  }
};