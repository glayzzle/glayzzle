/**
 * Magma : PHP on NodeJS
 * @license BSD
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

	// list of included files
	files: [],

	// list of included buffers
	includes: {},

	// detects each script changes
	watchers: {},

	// gets the current parser or load the default php parser
	getParser: function() {
		if (!this.parser) {
			this.parser = require('./parser');
		}
		return this.parser;
	},

	// check if the specified was never called
	once: function(filename) {
		return this.files.indexOf(filename) == -1;
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
				process.exit(1);
			}
		} else {
			util.error(e);
		}
		console.log(e.stack);
	}
	// Converts a filename to a cache filename 
	,getCacheFile: function(filename) {
		var result = this.tmp + '/magma.' + crypto.createHash('md5').update(filename).digest('hex') + '.js';
		return result;
	}
	// (parse if not cached or updated) and returns the specified file structure
	,get: function(filename) {
		// check memory cache
		if (!this.once(filename)) return this.includes[filename];
		// check files cache
		if (process.env.DEBUG == 0) {
			var cache = this.getCacheFile(filename);
			try {
				var filenameStat = fs.statSync(filename);
				var cacheStat = fs.statSync(cache); 
				if ( cacheStat.mtime > filenameStat.mtime ) {
					this.register(filename, cache);
					return this.includes[filename];
				}
			} catch(e) { }
		}
		// parse and build file cache
		if (process.env.DEBUG > 0) console.log("-> PHP INCLUDE " + filename);
		this.refresh('include', filename);
		//this.watchers[filename] = fs.watch(filename, this.refresh);
		return this.includes[filename];
	}
	// registers the specified file
	, register: function(filename, cache) {
		this.includes[filename] = require(cache);
		var PHP = require('./php');
		// registers each function globally
		for(var name in this.includes[filename]) {
			PHP.functions[name] = this.includes[filename][name];
		}
		this.files.push(filename);
		return this;
	}
	// parse and build file cache
	, refresh: function(event, filename) {
		var cache = this.getCacheFile(filename);
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
							results.push({ type: 'output', data: buffer});
						}
						var offset = 2;
						if (String.fromCharCode(data[i+2]) == '=') {
							offset ++;
						} else if(data.toString('utf8', i + 2, i + 5).toLowerCase() == 'php') {
							offset += 3;
						}
						var next = data.indexOf("?>", i);
						results.push({ 
							type: 'php'
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
			var source = builder.init(filename).toString(results);
			builder.functions.push('__main: function( __output ) {\n\t\t' + source + '\n\t}');
			source = '/** MAGMA GENERATED CODE : '+filename+' ('+cache+') **/\n\n' 
				+ builder.headers() + '\n'
				+ 'module.exports = {\n\t'
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
			this.register(filename, cache);
		} catch(e) {
			if ( event == 'include' ) {
				this.parseError(e, data);
			} else {
				// check and remove file from cache entry : parse error found
				var offset = this.files.indexOf(filename);
				if (offset > -1) {
					this.files = this.files.slice(0, offset - 1).concat(
						this.files.slice(offset + 1)
					);
					console.log(this.files);
				}
			}
		}
	}
};