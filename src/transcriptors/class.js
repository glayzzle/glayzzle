/**
 * Glayzzle : PHP on NodeJS
 * @url http://glayzzle.com
 * @author Ioan CHIRIAC
 * @license BSD-3-Clause
 */

module.exports = {
  init: function(builder) {
    return {
      // SERIALIZE A CLASS
      T_DECLARE: function(item) {
        console.log(item);
        // console.log(item);
        return '/* todo */';
      }
      ,T_METHOD: function(item) {
      
      }
    };
  }
};