var glayzzle = require('../src/php');
var inspect = require('util').inspect;
var php = new glayzzle();

console.log('--> ', php);

php.eval('echo "Hello World";');