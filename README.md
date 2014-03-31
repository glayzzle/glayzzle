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

First bench :
=============

## The famous Fibonnaci benchmark :

```
// THE ORIGINAL CLI OUTPUT :
~$ php ../test/fibo.php
Hello world :
The result is : 832040
Run in 1.872sec

// THE NODEJS OUTPUT
../glayzzle/bin $ node php -f ../test/fibo.php
Hello world :
The result is : 832040
Run in 0.295sec
```

NodeJS is naturally many times more rapid than PHP with it's JIT engine, 
so that's normal that Glayzzle keep this benefit...

Test & Rebuild :
================

You will need pegjs library :
```
npm install pegjs
```

NOTE : The lexer use @import keywords to use external lexer files and this feature is not supported by pegjs so the only way to generate the lexer (to src/parser.js) is to launch a test.


Show some debug (the debug parameter is the nesting level on AST output) :
```
../glayzzle/bin $ node test --debug 5 ../test/fibo.php
```

To improve the lexer, take a look at :
http://pegjs.majda.cz/documentation

Project Status :
================

Actually the project is a Prof Of Concept, and does not run over all PHP syntax.
Take a look at test folder for supported syntaxes.

Here's the todo list :

| TASK                                                      | STATUS           |
|-----------------------------------------------------------|------------------|
| Finish the lexer                                          | [progress...40%] |
| Convert back the AST to JS                                | [progress...20%] | 
| Make some benchmarks                                      | [progress...20%] |
| Create a framework for packaging the PHP code             | [progress...50%] |
| Create a cache system to improve interpretation speeds    | [progress...60%] |
| Migrate common PHP functions to be compliant with php     |                  |
| Migrate most used PHP modules                             |                  |

If you want to contribute, fell free to contact me from my website http://glayzzle.com or from github.
Coding rules are here : http://nodeguide.com/style.html


