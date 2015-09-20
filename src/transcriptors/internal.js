/**
 * Glayzzle : PHP on NodeJS
 * @url http://glayzzle.com
 * @author Ioan CHIRIAC
 * @license BSD-3-Clause
 */

module.exports = function(declare) {
  declare('sys', {
    echo: function(writer, ast) {
      writer.write('php.stdout(');
      for(var i = 0; i < ast[2].length; i++) {
        writer.asString(ast[2][i]);
      }
      return writer.write(');\n');
    }
  });
  declare('set', function(writer, ast) {
    if (ast[1][0] === 'var') {
      if (!writer.getContext().has(ast[1][1])) {
        writer.getContext().set(
          ast[1][1], writer.getCode(ast[2])
        );
      } else {
        writer.write(ast[1][1] + ' = ');
        writer.write(ast[2]);
        writer.write(';');
      }
    } else {
      throw new Error('???');
    }
  });
  declare('bin', {
    '.': function(writer, ast) {
      writer.asString(ast[2]);
      writer.write('+');
      writer.asString(ast[3]);
    }
  });
  declare('number', function(writer, ast) {
    return writer.write(ast[1]);
  });
  declare('string', function(writer, ast) {
    return writer.write('"' + ast[1] + '"');
  });
};

/*
  init: function(builder) {
    return {
      T_ECHO: function(item) {
        return 'this.__output.write(String(' + builder.toString(item.statements) + '));\n';
      }
      ,T_INCLUDE: function(item) {
        return  builder.use('./php') 
          + '.include'+(item.once ? '_once' : '' )+'(' 
          + builder.use('path') + '.resolve(' + JSON.stringify(builder.directory) + ', ' + builder.toString(item.target) + ')'
          + ', ' + (item.ignore ? 'true' : 'false')
          + ', __output'
        +')';
      }
      ,T_REQUIRE: function(item) {
        return  builder.use('./php') 
          + '.require'+(item.once ? '_once' : '' )+'(' 
          + builder.use('path') + '.resolve(' + JSON.stringify(builder.directory) + ', ' + builder.toString(item.target) + ')'
          + ', ' + (item.ignore ? 'true' : 'false')
          + ', __output'
        +')';
      }
      // @todo
      ,T_USE: function(item) {
        console.log(item);
        return '';
      }
      // @todo
      ,T_NAMESPACE: function(item) {
        console.log(item);
        return '';
      }
    };
  }
};
*/