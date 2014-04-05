/**
 * Glayzzle : PHP on NodeJS
 * @url http://glayzzle.com
 * @author Ioan CHIRIAC
 * @license BSD-3-Clause
 */

module.exports = {
  init: function(builder) {
    return {
      // Output a JS var name
      T_VARIABLE: function(item) {
        // @todo should handle variables scopes
        return item.name;
      }
      // Serialize arguments for a function call
      ,T_ARGS: function(item) {
        var result = [];
        console.log('args :', item.args);
        for(var i = 0; i < item.args.length; i++) {
          var arg = builder.toString(item.args[i]);
          if (arg && arg.length > 0) result.push(arg);
        }
        console.log(result);
        return result.join(', ');
      }
      // Outputs a string object
      ,T_STRING: function(item) {
        if (!item.char) item.char = "'";
        var output = JSON.stringify(item.data.toString());
        return item.char + output.substring(1, output.length - 1) + item.char;
      }
      // Generates a list of statements 
      ,T_STATEMENTS: function(item) {
        return ' {\n' +  builder.toString(item.data) + '\n}\n';
      }
      // Generates and array definition
      ,T_ARRAY: function(arr) {
        // @fixme should be handled with an object and keys
        if (arr.items.length > 0) {
          return '[' + builder.toString(arr.items) + ']';
        } else return '[]';
      }
      ,T_IF: function(item) {
        return 'if ' + builder.toString(item.condition) 
          + builder.toString(item.statement)
          + builder.toString(item._elseif) 
          + builder.toString(item._else)
        ; 
      }
      ,T_ELSE: function(item) {
        return ' else ' +  builder.toString(item.data);
      }
      ,T_ELSEIF: function(item) {
        return ' elseif' + builder.toString(item.condition) +  builder.toString(item.statement);
      }
    };
  }
};