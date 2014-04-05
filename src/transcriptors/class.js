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
        var buffer = [
          item.name + ': ' + builder.use('./compat/class')
          + '(' + JSON.stringify(item.name) + ')'
        ];
        // handle flags
        if (item.flag === builder.T_FINAL) {
          buffer.push('.final()');
        } else if (item.flag === builder.T_ABSTRACT) {
          buffer.push('.abstract()');
        }
        // handling properties
        if(item.properties) {
          for(var i = 0; i < item.properties.length; i++) {
            var property = item.properties[i];
            if ( property.modifiers.indexOf(builder.T_PRIVATE) != -1 ) {
              
            }
          }
        }
        buffer.push('.getPrototype()');
        builder.functions.push(buffer.join('\n\t\t'));
        return '';
      }
      ,T_METHOD: function(item) {
      
      }
    };
  }
};