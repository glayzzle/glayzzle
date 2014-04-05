Glayzzle - PHP under NodeJS
===========================

The main idea of this projet is to enable a developper to run a plain PHP script
dirrectly from a NodeJS environement, without using the PHP engine.

The project parse the script with a lexical parser, and converts back the AST to Javascript. 

After building the Javascript, the program will execute the result.

The overtime for parsing is similar to PHP, on a batch mode, the JIT gain will cover the gap.

In the server mode, the resulting JS code is (eventually parsed if updated) and executed once and the object structure is keeped in memory, so the difference between an include in PHP or with Glayzzle is just enormous !


Install & Run :
===============

```
npm install -g glayzzle
glz -r "echo 'hello world';"
```

To run a PHP file you can use the same parameter as PHP :

```
glz -f your-file.php
// or 
glz your-file.php
```

You can also run a script as a server (using NodeJS cluster module)

```
glz -S 127.0.0.1:8080 index.php
```

Include PHP from JS :
=====================

With this library you can now use and call PHP scripts directly from a JavaScript.


```php
<?php
// foo.php
function foo($bar) {
  echo $bar;
  return true;
}
```

```js
// main.js
var PHP = require('php');
PHP.include('./foo.php');
console.log('Foo Result : ' + PHP.globals.foo("Hello World"));
```

Project Status :
================

Actually the project is a Prof Of Concept, and does not run over all PHP syntax.
Take a look at test folder for supported syntaxes.

Here's the todo list :

| TASK                                                      | STATUS           |
|-----------------------------------------------------------|------------------|
| Finish the lexer                                          | [progress...10%] |
| Convert back the AST to JS                                | [progress...30%] | 
| Make some benchmarks                                      | [progress...20%] |
| Create a framework for packaging the PHP code             | [progress...50%] |
| Create a cache system to improve interpretation speeds    | [progress...70%] |
| Migrate common PHP functions to be compliant with php     | [progress...05%] |
| Migrate most used PHP modules                             |                  |

If you want to contribute, fell free to contact me from my website http://glayzzle.com or from github.
Coding rules are here : http://nodeguide.com/style.html


