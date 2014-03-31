/**
 * Glayzzle : PHP on NodeJS
 * @url http://glayzzle.com
 * @author Ioan CHIRIAC
 * @license BSD-3-Clause
 */

module.exports = {
  init: function(builder) {
    return {
      // SERIALIZE OUTER PHP TOKENS
      T_HTML: function(item) {
        return '__output.write(' + JSON.stringify(item.data) + ');\n';
      }
      // SERIALIZE PHP AST
      ,T_PHP: function(item) {
        return builder.toString(item.data);
      }
    };
  }
};