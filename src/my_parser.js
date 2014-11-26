var lex = require('./lexer');
var tokens = require('./tokens');
var names = require('./grammar/tokens');

function isNumber(n) {
  return n != '.' && n != ',' && !isNaN(parseFloat(n)) && isFinite(n);
}

function getTokenName(token) {
  if (!isNumber(token)) {
    return "'" + token + "'";
  } else {
    if (token == 1) return 'the end of file (EOF)';
    return names[token];
  }
}

module.exports = {
  parser: {
    // le lexer
    lexer: lex,
    token: null,
    /** main entry point : converts a source code to AST **/
    parse: function(code) {
      this.lexer.setInput(code);
      var token = this.lexer.lex() || lex.EOF;
      var ast = [];
      while(token != lex.EOF) {
        ast.push(this.read_start(token));
        token = this.lexer.lex() || lex.EOF;
      }
      return ast;
    }
    /** handling errors **/
    ,error: function(token, expect) {
      token = getTokenName(token);
      var msgExpect = '';
      if (expect) {
        msgExpect = ', expecting ';
        if (Array.isArray(expect)) {
          for(var i = 0; i < expect.length; i++) {
            expect[i] = getTokenName(expect[i]);
          }
          msgExpect += expect.join(', ');
        } else {
          msgExpect += getTokenName(expect);
        }
      }
      throw new Error(
        'Parse Error : unexpected ' + token + msgExpect,
        '\nat line ' + this.lexer.yylloc.first_line
      );
    }
    /** force to expect specified token **/
    ,expect: function(token) {
      if (this.token != token) {
        this.error(this.token, token);
      }
      return true;
    }
    /** consume the next token **/
    ,next: function() {
      this.token = this.lexer.lex() || this.error(lex.EOF);
      return this.token;
    }
    /** convert an token to ast **/
    ,read_token: function(token) {
console.log("read_token:",token);
      if (isNumber(token)) {
        return [token, this.lexer.yytext, this.lexer.yylloc.first_line];
      } else {
        return token;
      }
    }
    /** helper : reads a list of tokens / sample : T_STRING ',' T_STRING ... **/
    ,read_list: function(token, item, separator) {
      var result = [];
      if (token == separator) token = next;           // trim separator
      if (token != item) {
        this.error(token, [item, separator]);
      }
      result.push(this.lexer.yytext);
      this.token = this.lexer.lex() || lex.EOF;
      while(this.token != lex.EOF) {
        if (this.token != separator) break;
        this.token = this.lexer.lex() || lex.EOF;     // trim separator
        if (this.token != item) break;
        result.push(this.lexer.yytext);
        this.token = this.lexer.lex() || lex.EOF;
      }
      return result;
    }
    /** main entry **/
    ,read_start: function(token) {
      if (token == tokens.T_NAMESPACE) {
        return this.read_namespace(token);
      } else {
        return this.read_top_statement(token);
      }
    }
    /** reading namespaces **/
    ,read_namespace: function(token) {
      if (token != tokens.T_NAMESPACE) this.error(token, tokens.T_NAMESPACE);
      token = this.next();
console.log('read_namespace:', token);
      if (token == '{') {
        var body = this.read_top_statements(this.next());
        if (this.token != '}') this.error(this.token, '}');
        return ['namespace', [], body];
      } else {
        var name = this.read_namespace_name(token);
        if (this.token == ';') {
          var body = this.read_top_statements(this.next());
          if (this.token != lex.EOF) this.error(this.token, lex.EOF);
          return ['namespace', name, body];
        } else if (this.token == '{') {
          var body = this.read_top_statements(this.next());
          if (this.token != '}') this.error(this.token, '}');
          return ['namespace', name, body];
        } else {
          this.error(this.token, ['{', ';']);
        }
      }
    }
    /** reading a namespace **/
    ,read_namespace_name: function(token) {
      return this.read_list(token, tokens.T_STRING, tokens.T_NS_SEPARATOR);
    }
    /** reading a list of top statements **/
    ,read_top_statements: function(token) {
console.log("read_top_statements:",token);
      var result = [];
      if (token) this.token = token;
      while(this.token !== lex.EOF && this.token !== '}') {
console.log("	while:",this.token);
        result.push(this.read_top_statement(this.token));
        this.token = this.lexer.lex() || lex.EOF;
      }
      return result;
    }
    /** reading a top statement **/
    ,read_top_statement: function(token) {
console.log("read_top_statement:",token);
      if (token == tokens.T_FUNCTION ) {
        return this.read_function(token);
      } else if (token == tokens.T_FINAL || token == tokens.T_ABSTRACT) {
        var flag = this.read_class_scope(token);
        token = this.read();
        if ( token == tokens.T_CLASS) {
          return this.read_class(token, flag);
        } else if ( token == tokens.T_INTERFACE, flag ) {
          return this.read_interface(token);
        } else if ( token == tokens.T_TRAIT, flag ) {
          return this.read_trait(token);
        } else {
          this.error(this.token, [tokens.T_CLASS, tokens.T_INTERFACE, tokens.T_TRAIT]);
        }
      } else if ( token == tokens.T_CLASS) {
        return this.read_class(token);
      } else if ( token == tokens.T_INTERFACE ) {
        return this.read_interface(token);
      } else if ( token == tokens.T_TRAIT ) {
        return this.read_trait(token);
      } else {
        return this.read_inner_statement(token);
      }
    }
    /** reads a list of simple inner statements **/
    ,read_inner_statements: function(token) {
      var result = [];
      if (token) this.token = token;
      while(this.token != lex.EOF) {
        result.push(this.read_inner_statement(this.token));
        this.token = this.lexer.lex() || lex.EOF;
      }
      return result;
    }
    /** reads a simple inner statement **/
    ,read_inner_statement: function(token) {
console.log("read_inner_statement:",token);
      if (token == '{') {
        var body = this.read_inner_statements(this.next());
        if (this.token != '}') this.error(this.token, '}');
        this.next();
        return body;
      } else if (token == '}' ) {
        this.error(token);
      } else {
        return this.read_token(token);
      }
    }
    /** checks if current token is a reference keyword **/
    ,is_reference: function(token) {
      return (token == '&');
    }
    /** reading a function **/
    ,read_function: function(token) {
      if (token != tokens.T_FUNCTION) this.error(token, tokens.T_FUNCTION);
      var isRef = this.is_reference(token);
      if (isRef) token = this.next();
      if (token != tokens.T_STRING) this.error(token, tokens.T_STRING);
      var name = this.lexer.yytext;
      if (this.next() != '(') this.error(this.token, '(');
      var params = this.read_parameter_list(this.next());
      if (this.token != ')') this.error(this.token, ')');
      if (this.next() != '{') this.error(this.token, '{');
      var body = this.read_inner_statements(this.next());
      if (this.token != '}') this.error(this.token, '}');
      return ['function', name, params, body, isRef];
    }
    /** reads a list of parameters **/
    ,read_parameter_list: function(token) {

    }
    /** reading a class **/
    ,read_class: function(token, flag) {
      this.expect(tokens.T_CLASS);
      // @todo
      return ['class', flag];
    }
    /** **/
    ,read_class_scope: function(token) {
      if (token == tokens.T_FINAL || token == tokens.T_ABSTRACT) {
        this.next();
        return token;
      }
      return 0;
    }
    /** reading an interface **/
    ,read_interface: function(token, flag) {
      this.expect(tokens.T_INTERFACE);
      return ['interface', flag];
    }
    /** reading a trait **/
    ,read_trait: function(token, flag) {
      this.expect(tokens.T_TRAIT);
      return ['trait', flag];
    }
  }
};