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
        console.log(item.properties);
        var buffer = [];
        // handling properties
        if(item.properties) {
          for(var i = 0; i < item.properties.length; i++) {
            var property = item.properties[i];
            if ( property.modifiers.indexOf(builder.T_PRIVATE) != -1 ) {
              
            }
          }
        }
        // console.log(item);
        return '/* todo */';
      }
      ,T_METHOD: function(item) {
      
      }
    };
  }
};