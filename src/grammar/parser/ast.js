/**
 * Helpers for building AST
 */
function buildClassBody(body) {
  var result = {
    constants: {},
    properties: {},
    methods: {},
    traits: []
  };
  for(var i in body) {
    switch(body[i][0]) {
      case 'method':
        result.methods[body[i][2]] = {
          flags:  body[i][1],
          args:   body[i][3],
          body:   body[i][4],
        };
        break;
      case 'property':
        for(var p in body[i][2]) {
          if (body[i][2][p][0] == 'let') {
            result.properties[body[i][2][p][1][1]] = {
              flags: body[i][1],
              value: []
            };
          } else if (body[i][2][p][0] == 'set') {  // set mode (sets a default value)
            result.properties[body[i][2][p][1][1][1]] = {
              flags: body[i][1],
              value: body[i][2][p][2]
            };
          }
        }
        break;
      case 'constant':
        for(var p in body[i][1]) {
          result.constants[body[i][1][p][0]] = body[i][1][p][1];
        }
        break;
      case 'use':
        result.traits.push(body[i][1]);
        break;
    }
  }
  return result;
}