/**
 * Glayzzle : PHP on NodeJS
 * @url http://glayzzle.com
 * @license BSD-3-Clause
 */

var fs = require('fs');
var md5 = require('crypto').createHash('md5');
var builder = require('./builder');

// Converts a filename to a cache filename 
function getCacheFile(php, filename) {
  return php.context.tmp 
    + php.constant('DIRECTORY_SEPARATOR') 
    + 'glz.' + this.php.VERSION 
    + '-' + md5.update(filename).digest('hex') 
    + '.js'
  ;
}

/**
 * The running context
 */
var context = function(php) {
  this.php        = php;
  this.builder    = new builder(php);
  this.constants  = require('./constants')(php);
  this.parser     = require('php-parser');
};

// define temporary path
Object.defineProperty(context.prototype, "tmp", {
  enumerable: false,
  configurable: false,
  writable: false,
  value: require('os').tmpdir()
});

// list of included buffers
Object.defineProperty(context.prototype, "includes", {
  enumerable: true,
  configurable: false,
  writable: false,
  value: {}
});

/**
 * evaluates the specified code and returns its function
 */
context.prototype.eval = function(code) {


  // 1. Convert PHP code to AST
  try {
    var ast = this.parser.parseEval(code);
  } catch(e) {
    // @todo parse error
    throw e;
  }

  // 2. Convert AST to Javascript
  try {
    code = this.builder.getCode(ast, 'evald code');
  } catch(e) {
    // @todo parse error
    throw e;
  }

  // 3. Evaluate the javascript
  try {
    code = Function('php', 
      code.header.join(';\n')
      + 'return {' + code.functions.join(',\n') + '};'
    )(this.php);
  } catch(e) {
    // @todo parse error
    throw e;
  }

  // 4. Execute the eval body
  return code.__main();
};

/**
 * includes the specified file
 */
context.prototype.include = function(filename) {
  // 1. Resolves the filename
  var path = this.php.path(filename);

  // 2. Check memory cache
  var once = this.includes.hasOwnProperty(path);
  var now = Date.now();
  // check memory status (ttl 2 sec)
  if (once && now - this.includes[path].time < 2000) {
    return this.includes[path].module.__main();
  }

  // 3. Check file cache
  var cache = getCacheFile(this.php, path);
  try {
    var fileStat = fs.statSync(path).mtime;
    var cacheStat = fs.statSync(cache).mtime;
  } catch(e) {
    if (!fileStat) {
      throw Error('Unable to locate file ' + filename);
    } else if (!cacheStat) {
      this.writeAsCache(path, cache);
      cacheStat = now;
      once = true;
    }
  }
  
  // 4. Run the cache if needed
  if ( cacheStat > fileStat ) {
    if (!once) {
      // the cache is ok but never included yet
      this.includes[path] = {
        time: now,
        module: require(path)(this.php)
      }
    } else {
      this.includes[path].time = now;
    }
  } else {
    this.writeAsCache(path, cache);
  }
  
  // 5. Executes the code
  return this.includes[path].module.__main();
};

// reads the specified file and saves it to cache
context.prototype.writeAsCache = function(filename, cache) {
  // 1. Convert PHP code to AST
  try {
    var ast = this.parser.parse(
      fs.readFileSync(filename), filename
    );
  } catch(e) {
    // @todo parse error
    throw e;
  }

  // 2. Convert AST to Javascript
  try {
    var code = this.builder.getCode(ast, filename);
  } catch(e) {
    // @todo parse error
    throw e;
  }

  // 3. Save the code to cache
  delete require.cache[cache];
  try {
    fs.writeFileSync(
      cache
      , '/** GLAYZZLE GENERATED CODE : '+filename+' ('+cache+') **/\n\n' 
      + 'module.exports = function(php) {\n\t'
      + code.header.join(';\n\t')
      + '\n\treturn {' + code.functions.join(',\n\t\t') + '\n\t};'
      + '\n};' 
      , { flag: 'w+' }
    );
  } catch(e) {
    // @todo system write error
    throw e;
  }
  
  // 4. Include it
  try {
    this.includes[filename] = {
      time: Date.now(),
      module: require(cache)(this.php)
    };
  } catch(e) {
    // @todo parse error
    throw e;
  }
};

// exporting the context class
module.exports = context;