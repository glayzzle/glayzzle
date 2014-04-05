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
        // handling constants
        if(item.constants.length > 0) {
          var list = [];
          for(var i = 0; i < item.constants.length; i++) {
            var consts = item.constants[i].items;
            for(var c = 0; c < consts.length; c++) {
                list.push(
                  consts[c].name + ': ' + builder.toString(consts[c].value)
                );
            }
          }
          buffer.push('.constants({\n\t\t\t'+list.join(',\n\t\t\t')+'\n\t\t})');
        }
        // handling properties
        if(item.properties.length > 0) {
          for(var i = 0; i < item.properties.length; i++) {
            var property = item.properties[i];
            if (property.modifiers.indexOf(builder.T_STATIC) != -1 ) {
              if ( property.modifiers.indexOf(builder.T_PRIVATE) != -1 ) {
                
              }
            }
          }
        }
        // handling methods
        builder.functions.push(buffer.join('\n\t\t'));
        builder.classes[item.name] = '';
        if (item.extends) {
          var target = item.extends;
          if (builder.classes.hasOwnProperty(target)) {
            target = 'this.' + target;
          } else {
            target =  builder.use('./php') + '.' + target;
          }
          builder.classes[item.name] += '.extends('+target+')';
        }
        builder.classes[item.name] += '.getPrototype()';
        return '';
      }
      ,T_METHOD: function(item) {
      
      }
    };
  }
};