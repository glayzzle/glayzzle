/**
 * Glayzzle : PHP on NodeJS
 * @url http://glayzzle.com
 * @license BSD-3-Clause
 */

var md5 = require('crypto').createHash('md5');

module.exports = {
  execute: function(text) {
    return md5.update(text).digest('hex');
  }
};