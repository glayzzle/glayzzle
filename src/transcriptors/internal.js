/**
 * Glayzzle : PHP on NodeJS
 * @url http://glayzzle.com
 * @author Ioan CHIRIAC
 * @license BSD-3-Clause
 */

module.exports = {
  init: function(builder) {
    return {
      T_ECHO: function(item) {
        return '__output.write(String(' + builder.toString(item.statements) + '));\n';
      }
      ,T_INCLUDE: function(item) {
        return  this.use('./php') 
          + '.include'+(item.once ? '_once' : '' )+'(' 
          + this.use('path') + '.resolve(' + JSON.stringify(this.directory) + ', ' + this.toString(item.target) + ')'
          + ', ' + (item.ignore ? 'true' : 'false')
          + ', __output'
        +')';
      }
      ,T_REQUIRE: function(item) {
        return  this.use('./php') 
          + '.require'+(item.once ? '_once' : '' )+'(' 
          + this.use('path') + '.resolve(' + JSON.stringify(this.directory) + ', ' + this.toString(item.target) + ')'
          + ', ' + (item.ignore ? 'true' : 'false')
          + ', __output'
        +')';
      }
      // @todo
      ,T_USE: function(item) {
        console.log(item);
        return '';
      }
      // @todo
      ,T_NAMESPACE: function(item) {
        console.log(item);
        return '';
      }
    };
  }
};