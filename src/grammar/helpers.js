{
  var nestedSpaces = 0;
  var builder = require('./builder');
  function makeList(a1, al) {
    var result = [a1];
    if (al && al.length > 0) {
      al.forEach(function(a) {
        result.push(a[3]);
      });
    }
    return result;
  }
  
  function makeInteger(o) {
    return parseInt(o.join(""), 10);
  }
}