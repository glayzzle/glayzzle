var fs = require('fs');
var PEG = require("pegjs");
console.log('Load YACC');
fs.readFile('yacc.pegjs', 'utf8', function(err, data) {
  if (err) return console.error(err);
  var yacc = PEG.buildParser(data);
  console.log('Load Zend Language Parser');
  fs.readFile('zend_language_parser.y', 'utf8', function(err, data) {
    if (err) return console.error(err);
    console.log('Parse with YACC');
    try {
      var result = yacc.parse(data);
      console.log(JSON.Stringify(result));
    } catch(e) {
      console.error(
        e.message + "\n"
        + "At line " + e.line + ', ' + e.column 
      );
    }
  });
});

