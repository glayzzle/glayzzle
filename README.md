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

Actually the project is a Prof Of Concept, and does not run yet.

Here's the todo list :

* Finish the lexer
* Convert back to JS the AST
* Make some benchmarks
* Create a framework for packaging the PHP code
* Create a cache system to improve interpretation speeds
* Migrate common PHP functions to be compliant with php
* Migrate most used PHP modules

If you want to contribute, fell free to contact me from github

Install & Run :
===============

```
node magma.js test/fibo.php
```

Actually I rebuild the lexer at each run to be able to test and update 
the lexer more easily, but in future the lexer will be generated and it will not
be necessary to install pegjs.

Test & Rebuild :
================

You can update the parser, or show AST and generated code :

You will need pegjs library :
```
npm intall pegjs
```

Show some debug (the debug parameter is the nesting level on AST output) :
```
node magma.js --debug 5 test/fibo.php
```

If you want to test some updates on lexer just use the build flag
```
node magma.js --build test/fibo.php
```

NOTE : The lexer use @import keywords to use external lexer files and this feature is not supported by pegjs so the only way to generate the lexer (to src/php.js) is to use the build flag.

