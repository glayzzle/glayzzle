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
          var list = {
            static: {
              public: [],
              protected: [],
              private: []
            },
            public: [],
            protected: [],
            private: []
          };
          for(var i = 0; i < item.properties.length; i++) {
            var decl = item.properties[i];
            // scan static
            if (decl.modifiers.indexOf(builder.T_STATIC) != -1 ) {
              if ( decl.modifiers.indexOf(builder.T_PRIVATE) != -1 ) {
                for(var p = 0; p < decl.properties.length; p++) {
                  list.static.private.push(
                    decl.properties[p].name + ': ' + builder.toString(decl.properties[p].default)
                  );
                }
              }
              if ( decl.modifiers.indexOf(builder.T_PROTECTED) != -1 ) {
                for(var p = 0; p < decl.properties.length; p++) {
                  list.static.protected.push(
                    decl.properties[p].name + ': ' + builder.toString(decl.properties[p].default)
                  );
                }
              }
              if ( decl.modifiers.indexOf(builder.T_PUBLIC) != -1 ) {
                for(var p = 0; p < decl.properties.length; p++) {
                  list.static.public.push(
                    decl.properties[p].name + ': ' + builder.toString(decl.properties[p].default)
                  );
                }
              }
            } else {
              // instance scope declarations
              if ( decl.modifiers.indexOf(builder.T_PRIVATE) != -1 ) {
                for(var p = 0; p < decl.properties.length; p++) {
                  list.private.push(
                    decl.properties[p].name + ': ' + builder.toString(decl.properties[p].default)
                  );
                }
              }
              if ( decl.modifiers.indexOf(builder.T_PROTECTED) != -1 ) {
                for(var p = 0; p < decl.properties.length; p++) {
                  list.protected.push(
                    decl.properties[p].name + ': ' + builder.toString(decl.properties[p].default)
                  );
                }
              }
              if ( decl.modifiers.indexOf(builder.T_PUBLIC) != -1 ) {
                for(var p = 0; p < decl.properties.length; p++) {
                  list.public.push(
                    decl.properties[p].name + ': ' + builder.toString(decl.properties[p].default)
                  );
                }
              }
            }
          }
          if (
            list.static.public.length > 0
            || list.static.protected.length > 0
            || list.static.private.length > 0
          ) {
            buffer.push('.static({\n\t\t\t'
              + (list.static.public.length > 0 ? 'public: {\n\t\t\t\t' + list.static.public.join(',\n\t\t\t\t') + '\n\t\t\t},' : '')
              + (list.static.protected.length > 0 ? 'protected: {\n\t\t\t\t' + list.static.protected.join(',\n\t\t\t\t') + '\n\t\t\t},' : '')
              + (list.static.private.length > 0 ? 'private: {\n\t\t\t\t' + list.static.private.join(',\n\t\t\t\t') + '\n\t\t\t}' : '')
            + '\n\t\t})');
          }
          if (list.public.length > 0) {
            buffer.push('.public({\n\t\t\t'+list.public.join(',\n\t\t\t')+'\n\t\t})');
          }
          if (list.protected.length > 0) {
            buffer.push('.protected({\n\t\t\t'+list.public.join(',\n\t\t\t')+'\n\t\t})');
          }
          if (list.private.length > 0) {
            buffer.push('.private({\n\t\t\t'+list.public.join(',\n\t\t\t')+'\n\t\t})');
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
    };
  }
};