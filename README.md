Glayzzle - PHP to JS transpiler
===============================

This is a CLI library in order to run a PHP script using the NodeJS V8 engine.

[![npm version](https://badge.fury.io/js/glayzzle.svg)](https://www.npmjs.com/package/glayzzle)
[![Build Status](https://travis-ci.org/glayzzle/glayzzle.svg)](https://travis-ci.org/glayzzle/glayzzle)
[![Coverage Status](https://coveralls.io/repos/glayzzle/glayzzle/badge.png)](https://coveralls.io/r/glayzzle/glayzzle)
[![Gitter](https://img.shields.io/badge/GITTER-join%20chat-green.svg)](https://gitter.im/glayzzle/Lobby)

Why (disclaimer) ?
------------------

I'm a PHP developper from years. Now I'm mainly using NodeJS and Javascript because that's the way to go. I won't discuss about NodeJS vs PHP, because they came with different solutions.

The main motivation behind this project

You are JS purist and Glayzzle burns your eyes !
------------------------------------------------

This project is not made for someone who masters JS and don't like PHP. It's just a matter of taste, some guys prefer SOLID vs Duck typing, and may prefer use a friendly syntax used from years instead learning a new syntax like Typescript.

What you can do with ?
----------------------

The project is still under developpement, so you can't use it yet :smile:.

Seriously, I plan to :

* Handle all PHP structures (namespace, classes, traits, interfaces)
* Impl a PHP core specific layer (in order to support main PHP functions)
* Impl a new syntax keyword in order to natively support any Javascript library
* Impl a debug support with node
* Impl plugins for gulp/grunt/babel in order to export code for browser
* Add a support for [apache codova](https://cordova.apache.org/)
* Add a support for [electron](http://electron.atom.io/)

Things you could do with :

* Write a mobile application
* Write a GUI application
* Every [cool stuff](http://blog.teamtreehouse.com/7-awesome-things-can-build-node-js) you could do in NodeJS
* Write an application for the browser
* Use frameworks like Vue.JS, SailsJS or Express/Koa

Things you can't do :

* Run an old application (PHP modules like PDO or lib_mysql will not be available)
* Dynamic variable name lookup like `$$var`, not sure I want to degrade overall performance in order to be able to do that
* Maybe others, work is still in progress

For JS guys who cry : Don't block the loop !
--------------------------------------------

PHP is synchronous, some implementations with libevent/promises was done as experiments - like [react php](http://reactphp.org/) (BTW the `Hello world` demo is almost the same as NodeJS :wink:)

The main problem here is how to make run synchronous code without blocking the loop.

My answer to this would be : let I/O tasks to be run asynchrously, and execute next statement when task result is ready.

Now how to do that without breaking the structure flow, and without degrading performances ?

I will use generators and promises in order to achieve this, the resulting transpiled code will be easy to read and will perform well with a native support.

Install & Run :
---------------

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

Other planed things :

* Add a standalone FCGI support in order to run it with Apache/Ngnix
* Add a generic daemon FCGI server (something similar to php-fcgi)


Project Status :
================

Actually the project is a Prof Of Concept, and does not run over all PHP syntax.

Here's my todo list :

- [x] (100%) Develop a [parser/lexer](https://github.com/glayzzle/php-parser)
- [ ] (.10%) Develop a [runtime](https://github.com/glayzzle/php-runtime)
- [ ] (.10%) Develop a [transpiler](https://github.com/glayzzle/php-transpiler)
- [ ] (..0%) Develop a compatibility layer
- [ ] (..0%) Write some demo projects

If you want to contribute, fell free to contact me from my website http://glayzzle.com or from github.
