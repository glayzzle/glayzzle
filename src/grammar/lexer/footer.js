
// defines if all tokens must be retrieved (used by token_get_all only)
lexer.all_tokens = true;
// enables the evald mode (ignore opening tags)
lexer.mode_eval = false;
// change lexer algorithm
var lex = lexer.lex;
lexer.lex = function() {
  var token = lex.call(this);
  if (!this.all_tokens) {
    while(
      token === T_WHITESPACE  // ignore white space
      || token === T_COMMENT  // ignore single lines comments
      || (
        !this.mode_eval // ignore open/close tags
        && (
          token == T_OPEN_TAG
          || token == T_CLOSE_TAG
        )
      )
    ) {
      token = lex.call(this);
    }
    if (token == this.EOF) token = T_EOF;
    if (!this.mode_eval && token == T_OPEN_TAG_WITH_ECHO) {
      // open tag with echo statement
      return T_ECHO; 
    }
  }
  return token;
};
// FORCE TO CHANGE THE INITIAL STATE IN EVAL MODE
var setInput = lexer.setInput;
lexer.setInput = function (input, yy) {
  setInput.call(this, input, yy);
  if (
    !this.all_tokens && this.mode_eval
  ) {
    this.conditionStack = ['ST_IN_SCRIPTING'];
  }
};

module.exports = lexer;