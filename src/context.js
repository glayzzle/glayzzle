/**
 * Glayzzle : PHP on NodeJS
 * @url http://glayzzle.com
 * @author Ioan CHIRIAC
 * @license BSD-3-Clause
 */

var fs = require('fs');
var os = require('os');
var crypto = require('crypto');
var builder = require('./builder');
var path = require('path');
var util = require('util');

// Searching helper for a Buffer
// From : https://groups.google.com/forum/#!topic/nodejs/fHiHwJZc6b4
if ( !Buffer.prototype.indexOf ) {
  Buffer.prototype.indexOf = function(str) {
    if (typeof str !== 'string' || str.length === 0 || str.length > this.length) return -1;
    var search = str.split("").map(function(el) { 
      return el.charCodeAt(0); 
    }), searchLen = search.length, ret = -1, i, j, len;
    
    for (i=0,len=this.length; i<len; ++i) {
      if (this[i] == search[0] && (len-i) >= searchLen) {
        if (searchLen > 1) {
          for (j=1; j<searchLen; ++j) {
            if (this[i+j] != search[j]) 
              break;
            else if (j == searchLen-1) {
              ret = i;
              break;
            }
          }
        } else ret = i;
        if (ret > -1) break;
      }
    }
    return ret;
  };
}
if ( !Buffer.prototype.substring ) {
  Buffer.prototype.substring = function(start, end) {
    return this.toString('utf8', start, end);
  };
}
// This module handles the project 
module.exports = {

  // defines the default temporary path
  tmp: os.tmpdir(),

  // list of included buffers
  includes: {},

  // list of reflection entries
  relection: {
    functions: {},
    classes: {}
  },

  // PHP engine
  php: null,

  // initialize the current context with specified PHP engine
  init: function(php) {
    this.php = php;
    return this;
  }
  // gets the current parser or load the default php parser
  ,getParser: function() {
    if (!this.parser) {
      this.parser = require('./parser');
    }
    return this.parser;
  }

  /**
   * Shows a parsing error message and outputs the source at the specified line
   */
  ,parseError: function(e, file) {
    if(e.line) {
      util.error(
        "\nParse Error : " + e.message + "\n"
        + "At line " + e.line + ', ' + e.column
      );
      if ( file ) {
        file = file.toString();
        console.log("\nSource Code :\n");
        var line = e.line - 2;
        if (line < 0) line = 0;
        var pstart = 0;
        var pnext = 0;
        for(var i = 0; i < line; i++) {
          pnext = file.indexOf("\n", pstart);
          if ( pnext < 0 ) {
            pstart = 0;
            break;
          }
          pstart = pnext + 1; 
        }
        var pend = pstart;
        for(var i = 1; i < 5; i++) {
          pnext = file.indexOf("\n", pend);
          if ( pend > pnext ) {
            pnext = file.length;
            break;
          }
          var curLine = line + i;
          var loc = file.substring(pend, pnext);
          if (curLine ==  e.line ) {
            loc = '>> ' + loc;
          }
          if (loc.length > 74) {
            loc = loc.substring(0, 71) + '...';
          }
          console.log( curLine + '. ' + loc );
          pend = pnext + 1;
        }
        if (process.env.DEBUG > 0) {
          if (!e.stack) {
            e.stack = (new Error(e.message)).stack;
          }
          console.log('\n' + e.stack);
        }
        process.exit(1);
      }
    } else {
      util.error(e.stack || e);
    }
    return false;
  }
  // Converts a filename to a cache filename 
  ,getCacheFile: function(filename) {
    var result = this.tmp + path.sep + 'glz.' + this.php.VERSION + '-' + crypto.createHash('md5').update(filename).digest('hex') + '.js';
    return result;
  }
  // (parse if not cached or updated) and returns the specified file structure
  ,get: function(filename) {
    // check memory cache
    var once = this.includes.hasOwnProperty(filename);
    var now = Date.now();
    // check memory status
    if (once && now - this.includes[filename].time < 2000) {
      return this.includes[filename].module;
    }
    // check files cache
    var cache = this.getCacheFile(filename);
    try {
      var cacheStat = fs.statSync(cache); 
      var filenameStat = fs.statSync(filename);
      if ( cacheStat.mtime > filenameStat.mtime ) {
        if (!once) {
          // include the cache file for the first time
          return this.register(filename, cache, !once);
        }
        this.includes[filename].time = now;
        return this.includes[filename].module;
      }
    } catch(e) {
      // original file not found ?
      if (cacheStat && !filenameStat) return false;
    }
    // parse the php file
    return this.refresh(filename, cache, !once);
  }
  // registers the specified file
  , register: function(filename, cache, refresh) {
    delete require.cache[cache];
    var include = this.includes[filename] = {
      module: require(cache)
      , time: Date.now()
    };
    // registers each function globally
    for(var name in include.module) {
      if (!refresh && this.relection.functions.hasOwnProperty(name)) {
        throw new Error(
          'Can not re-declare function "'+name
          +'", already defined in '
          +this.relection.functions[name].filename+' !'
        )
      }
      this.php.globals[name] = include.module[name];
      this.relection.functions[name] = {
        filename: filename
      };
    }
    return include.module;
  }
  // evaluates the specified code and returns its function
  , eval: function(code) {
    var AST = this.getParser().parse(code);
    builder.init('evald code');
    builder.functions.push(builder.getMainFunction(AST));
    var source = builder.headers() + '\n'
      + 'exec = {\n\t'
        + '__output: process.stdout,\n\t'
        + builder.functions.join('\n\t,')
      + '};'
    ;
    var exec = null;
    if (process.env.DEBUG > 9) console.log(source);
    eval(source);
    // registers each function globally
    for(var name in exec) {
      if (this.relection.functions.hasOwnProperty(name)) {
        throw new Error(
          'Can not re-declare function "'+name
          +'", already defined in '
          +this.relection.functions[name].filename+' !'
        )
      }
      this.php.globals[name] = exec[name];
    }
    return exec;
  }
  // parse and build file cache
  , refresh: function(filename, cache, refresh) {
    var data = fs.readFileSync(filename);
    if (process.env.DEBUG > 0) console.log("-> Parse " + filename);
    try {
      var results = [];
      var buffer = '';
      for(var i = 0; i < data.length; i++) {
        var c = String.fromCharCode(data[i]);
        if ( c == '<') {
          if (String.fromCharCode(data[i+1]) == '?') {
            if (buffer) {
              results.push({ type: 'doc.T_HTML', data: buffer});
            }
            var offset = 2;
            if (String.fromCharCode(data[i+2]) == '=') {
              offset ++;
            } else if(data.toString('utf8', i + 2, i + 5).toLowerCase() == 'php') {
              offset += 3;
            }
            var next = data.indexOf("?>", i);
            results.push({ 
              type: 'doc.T_PHP'
              , data: this.getParser().parse(
                  data.toString('utf8', i + offset, next > i ? next: data.length)
              )
            });
            if ( next > i ) {
              i = next + 2;
              buffer = '';
              continue;
            } else break;
          }
        }
        buffer += c;
      }
      builder.init(filename);
      builder.functions.push(builder.getMainFunction(results));
      source = '/** GLAYZZLE GENERATED CODE : '+filename+' ('+cache+') **/\n\n' 
        + builder.headers() + '\n'
        + 'module.exports = {\n\t'
          + '__output: process.stdout,\n\t'
          + builder.functions.join('\n\t,')
        + '};'
      ;
      if (process.env.DEBUG > 0) {
        console.log('** AST :');
        console.log(util.inspect(results, { depth: process.env.DEBUG, colors: true}));
        console.log(source);
        console.log('** RUNTIME OUTPUT :');
      }
      fs.writeFileSync(cache, source, {
        flag: 'w+'
      });
      return this.register(filename, cache, refresh);
    } catch(e) {
      return this.parseError(e, data);
    }
  }
};