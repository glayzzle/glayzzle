/**
 * Magma : PHP on NodeJS
 * @license BSD
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
    };
  }
};