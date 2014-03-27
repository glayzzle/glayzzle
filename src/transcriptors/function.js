/**
 * Magma : PHP on NodeJS
 * @license BSD
 */

module.exports = {
  init: function(builder) {
    return {
      // SERIALIZE A GLOBAL FUNCTION
      T_DECLARE: function(item) {
        var params = [];
        if (item.parameters) {
          item.parameters.forEach(function(param) {
            if (param && param.name) params.push(param.name);
          });
        }
        builder.functions.push(
          item.name + ': function(' + builder.toString(item.parameters) + ') {\n\t\t' 
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