Magma
=====

The main idea of this projet is to enable a developper to run a plain PHP script
dirrectly from a NodeJS environement, without using the PHP engine.

The project parse the script with a lexical parser PegJS, and converts back the 
AST to Javascript. 

After building the Javascript, the program will execute the result.

To improve the lexer, take a look at :
http://pegjs.majda.cz/documentation

Project Status :
================

Actually the project is a Prof Of Concept, and does not run over all PHP syntax.
Take a look at test folder for supported syntaxes.

Here's the todo list :

* Finish the lexer
* Convert back to JS the AST
* Make some benchmarks
* Create a framework for packaging the PHP code
* Create a cache system to improve interpretation speeds
* Migrate common PHP functions to be compliant with php
* Migrate most used PHP modules

If you want to contribute, fell free to contact me from github - the coding rules
are simple : use tabs, unix line ends, UTF8, fork, pull & have fun...

Install & Run :
===============

```
../magma/bin $ node php ../test/fibo.php
```

Test & Rebuild :
================

You can update the parser, or show AST and generated code :

You will need pegjs library :
```
npm install pegjs
```

Show some debug (the debug parameter is the nesting level on AST output) :
```
../magma/bin $ node php --debug 5 ../test/fibo.php
```

If you want to test some updates on lexer just use the build flag
```
../magma/bin $ node php --build ../test/fibo.php
```

NOTE : The lexer use @import keywords to use external lexer files and this feature is not supported by pegjs so the only way to generate the lexer (to src/php.js) is to use the build flag.
