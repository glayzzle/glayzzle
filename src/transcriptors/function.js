/**
 * Glayzzle : PHP on NodeJS
 * @url http://glayzzle.com
 * @author Ioan CHIRIAC
 * @license BSD-3-Clause
 */

module.exports = {
  init: function(builder) {
    return {
      // SERIALIZE A GLOBAL FUNCTION
      T_DECLARE: function(item) {
        var params = [];
        if (item.parameters.length > 0) {
          for(var i = 0; i < item.parameters.length; i++) {
            if (item.parameters[i]) params.push(builder.toString(item.parameters[i]));
          }
        }
        builder.functions.push(
          item.name + ': function(' + params.join(', ') + ') {\n\t\t' 
          + builder.toString(item.body)
          + '\n\t}'
        );
        return '';
      }
      // Serialize parameters
      ,T_PARAMETER: function(item) {
        // @todo should handle byref, type hinting, default values
        return item.name;
      }
      // PROXY for functions calls
      ,T_CALL: function(item) {
        var ret = builder.getCompat().__checkFunction(item.name, item.args[1].args);
        if (ret === false) {
          if (builder.getCompat().hasOwnProperty(item.name)) {
            // global function
            item.args[1].unshift({type: 'common.T_STRING', value: item.name });
            return  builder.use('./compat') + '.__call' + builder.toString(item.args);
          } else {
            // local scope function
            return 'this.' + item.name + builder.toString(item.args);
          }
        } else return ret;
      }
    };
  }
};