Glayzzle - PHP under NodeJS
===========================

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

If you want to contribute, fell free to contact me from github.

Coding rules are here : http://nodeguide.com/style.html

Install & Run :
===============

```
../glayzzle/bin $ node php ../test/fibo.php
```


Test & Rebuild :
================

You can update the parser, or show AST and generated code :

Show some debug (the debug parameter is the nesting level on AST output) :
```
../glayzzle/bin $ node php --debug 5 ../test/fibo.php
```

If you want to try the server mode
```
../glayzzle/bin $ node php -S 127.0.0.1:8080 ../test/index.php
```

If you want to test some updates on lexer just use the build flag
```
../glayzzle/bin $ node php --build ../test/fibo.php
```

You will need pegjs library :
```
npm install pegjs
```

NOTE : The lexer use @import keywords to use external lexer files and this feature is not supported by pegjs so the only way to generate the lexer (to src/php.js) is to use the build flag.

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
