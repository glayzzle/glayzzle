/**
 * Magma : PHP on NodeJS
 * @license BSD
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
        var module = this;
        item.args.forEach(function(i) {
          result.push(builder.toString(i));
        });
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
        return '{\n' +  builder.toString(item.data) + '\n}\n';
      }
      ,T_IF: function(item) {
        return 'if (' +  builder.toString(item.condition) + ')'
           + builder.toString(item.statement) 
           + builder.toString(item._elseif) 
           + builder.toString(item._else)
        ; 
      }
      ,T_ELSE: function(item) {
        return ' else ' +  builder.toString(item.data);
      }
      ,T_ELSEIF: function(item) {
        return ' elseif(' + builder.toString(item.condition) + ')' +  builder.toString(item.statement);
      }
    };
  }
};