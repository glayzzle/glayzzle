fs = require('fs');
var PEG = require("pegjs");
console.log("read parser");

var builder = {
  output: function(item) {
    return 'console.log(' + JSON.stringify(item.data) + ');';
  }
  ,php: function(item) {
    return jsBuild(item.data);
  }
  ,php_function: function(item) {
    return 'function ' + item.name + '() {\n' 
      + jsBuild(item.body)
      + '\n}'
    ;
  }
  ,php_variable: function(item) {
    return item.name + ' = null;';
  }
  ,php_if: function(item) {
    return 'if (' + jsBuild(item.condition) + ')' + jsBuild(item.statement) + jsBuild(item._elseif) + jsBuild(item._else); 
  }
  ,php_statements: function(item) {
    return '{\n' + jsBuild(item.data) + '\n}\n';
  }
  ,php_else: function(item) {
    return ' else ' + jsBuild(item.statement);
  }
  ,php_elseif: function(item) {
    return ' elseif(' + jsBuild(item.condition) + ')' + jsBuild(item.statement);
  }
};

var jsBuild = function(nodes) {
  if (!nodes) return '';
  if (nodes.type) {
    return builder[nodes.type](nodes) + "\n";
  } else {
    var result = [];
    for(var i = 0; i < nodes.length; i++) {
      if (nodes[i].type) {
        result.push(builder[nodes[i].type](nodes[i]));
      }
    }
    return result.join("\n");
  }
};


fs.readFile('src/php.pegjs', 'utf8', function(err, data) {
  if (err) {
    return console.error(err);
  }
  console.log("build parser");
  var php = PEG.buildParser(data);
  console.log("read " + process.argv[2]);
  fs.readFile(process.argv[2], 'utf8', function (err,data) {
    if (err) {
      return console.log(err);
    }
    console.log("parse file");
    try {
      var results = [];
      var buffer = '';
      for(var i = 0; i < data.length; i++) {
        c = data[i];
        if ( c == '<') {
          if (data[i+1] == '?') {
            if (buffer) {
              results.push({ type: 'output', data: buffer});
            }
            var offset = 2;
            if (data[i+2] == '=') {
              offset ++;
            } else if(data.substring(i + 2, i + 5).toLowerCase() == 'php') {
              offset += 3;
            }
            var next = data.indexOf("?>", i);
            results.push(
              { 
                type: 'php'
                , data: php.parse(
                  data.substring(
                    i + offset, next > i ? 
                      next:  data.length
                  )
                )
              }
            );
            if ( next > i ) {
              i = next + 2;
              buffer = '';
              continue;
            } else break;
          }
        }
        buffer += c;
      }
      console.log(JSON.stringify(results));
      console.log(jsBuild(results));
    } catch(e) {
      console.error(
        e.message + "\n"
        + "At line " + e.line + ', ' + e.column 
      );
    }
  });
});

