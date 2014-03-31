var PHP = require('../src/php');
PHP.include('./foo.php');
console.log('Foo Result : ' + PHP.globals.foo("Hello World"));
