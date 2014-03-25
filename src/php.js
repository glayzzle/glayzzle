/**
 * Magma : PHP on NodeJS
 * @license BSD
 */

var fs = require('fs');
var util = require('util');
var builder = require('./builder');

module.exports = {
	// Current version
	VERSION: '0.0.1',

	// defines a debug level
	debug: 0,

	// contains the PHP tokenizer
	parser: null,

	// gets the current parser or load the default php parser
	getParser: function() {
		if (!this.parser) {
			this.parser = require('./parser');
		}
		return this.parser;
	},

	/**
	 * Shows a parsing error message and outputs the source at the specified line
	 */
	parseError: function(e, file) {
		if(e.line) {
			util.error(
				"\n! Parse Error : " + e.message + "\n"
				+ "At line " + e.line + ', ' + e.column
			);
			if ( file ) {
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
				for(var i = 0; i < 5; i++) {
					pnext = file.indexOf("\n", pend);
					if ( pnext < 0 ) {
						pnext = file.length;
						break;
					}
					var curLine = line + i;
					var loc = file.substring(pnext, pend)
					if (curLine ==  e.line ) {
						loc = '>> ' + loc;
					}
					if (loc.length > 74) {
						loc = loc.substring(0, 71) + '...';
					}
					console.log( curLine + '. ' + loc );
					pend = pnext + 1;
				}
			}
		} else {
			util.error(e);
		}
		process.exit(1);
	},

	/**
	 * Includes a PHP script
	 */
	include: function(filename, cb) {
		if (this.debug) console.log("-> PHP INCLUDE " + filename);
		var module = this;
      fs.readFile(filename, 'utf8', function (err,data) {
        if (err) {
          return console.log(err);
        }
        if (module.debug) console.log("parse file");
        try {
          var results = [];
          var buffer = '';
          for(var i = 0; i < data.length; i++) {
            c = data[i];
            if ( c == '<') {
              if (data[i+1] == '?') {
                if (buffer) {
                  results.push({ type: 'output', data: buffer});
                }
                var offset = 2;
                if (data[i+2] == '=') {
                  offset ++;
                } else if(data.substring(i + 2, i + 5).toLowerCase() == 'php') {
                  offset += 3;
                }
                var next = data.indexOf("?>", i);
                results.push(
                  { 
                    type: 'php'
                    , data: module.getParser().parse(
                      data.substring(
                        i + offset, next > i ? 
                          next:  data.length
                      )
                    )
                  }
                );
                if ( next > i ) {
                  i = next + 2;
                  buffer = '';
                  continue;
                } else break;
              }
            }
            buffer += c;
          }
          var source = builder.toString(results);
          if (module.debug) {
            console.log('** AST :');
            console.log(util.inspect(results, {
              depth: module.debug, colors: true
            }));
            console.log('** GENERATED SOURCE :');
            console.log(source);
            console.log('** RUNTIME OUTPUT :');
          }
          eval(source);
        } catch(e) {
          module.parseError(e, data);
        }
        if (cb) cb();
      });
    }
};