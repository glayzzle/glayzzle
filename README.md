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