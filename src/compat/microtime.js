/**
 * Magma : PHP on NodeJS
 * @license BSD
 */


module.exports = {

  //  discuss at: http://phpjs.org/functions/microtime/
  // original by: Paulo Freitas
  //   example 1: timeStamp = microtime(true);
  //   example 1: timeStamp > 1000000000 && timeStamp < 2000000000
  //   returns 1: true

  build: function(sender, args) {
    if ( args.length == 1 && args[0] === true) {
      return '(new Date().getTime() / 1000)';
    } else if ( args.length == 1 && args[0] === false) {
      return '((Math.round(((new Date().getTime() / 1000) - parseInt((new Date().getTime() / 1000), 10)) * 1000) / 1000) + \' \' + parseInt((new Date().getTime() / 1000), 10)';
    } else {
      return sender.globalCall('microtime', args);
    }
  },

  execute: function(get_as_float) {
    var now = new Date().getTime() / 1000;
    var s = parseInt(now, 10);
    return (get_as_float) ? now : (Math.round((now - s) * 1000) / 1000) + ' ' + s;
  }
};