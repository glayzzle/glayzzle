<ST_DOUBLE_QUOTES,ST_BACKQUOTE,ST_HEREDOC>"${" {
	//yy_push_state(ST_LOOKING_FOR_VARNAME TSRMLS_CC);
	return T_DOLLAR_OPEN_CURLY_BRACES;
}


/* Make sure a label character follows "->", otherwise there is no property
 * and "->" will be taken literally
 */
<ST_DOUBLE_QUOTES,ST_HEREDOC,ST_BACKQUOTE>"$"{LABEL}"->"[a-zA-Z_\x7f-\xff] {
  this.less(yyleng-3);
  this.begin('ST_LOOKING_FOR_PROPERTY');
  return T_VARIABLE;
}

/* A [ always designates a variable offset, regardless of what follows
 */
<ST_DOUBLE_QUOTES,ST_HEREDOC,ST_BACKQUOTE>"$"{LABEL}"[" {
  this.less(1);
  this.pushState('ST_VAR_OFFSET');
  return T_VARIABLE;
}

<ST_IN_SCRIPTING,ST_DOUBLE_QUOTES,ST_HEREDOC,ST_BACKQUOTE,ST_VAR_OFFSET>"$"{LABEL} {
  return T_VARIABLE;
}


<ST_IN_SCRIPTING>b?['] {
  while(this._input.length > 0) {
    var char = this.input();
    if (char == '\\') {
      this.input();
    } else if (char == '\'') {
      break;
    }
  }
  return T_CONSTANT_ENCAPSED_STRING;
}


<ST_IN_SCRIPTING>b?["] {
  while(this._input.length > 0) {
    var char = this.input();
    if (char == '\\') {
      char = this.input();
    } else if (char == '"') {
      break;
    } else if (char == '$') {
      char = this.input();
      if ( char == '{' || IS_LABEL_START(char)) {
        break;
      } else this.unput(char);
    } else if (char == '{') {
      char = this.input();
      if (char == '$') {
        break;
      } else this.unput(char);
    }
  }
  if (char == '"') {
    return T_CONSTANT_ENCAPSED_STRING;
  } else {
    this.less(1);
    this.begin("ST_DOUBLE_QUOTES");
    return '"';
  }
}


<ST_IN_SCRIPTING>b?"<<<"{TABS_AND_SPACES}({LABEL}|([']{LABEL}['])|(["]{LABEL}["])){NEWLINE} {
  this.heredoc_label = this.matches[2];
  if (this.heredoc_label[0] == '\'') {
    this.begin('ST_NOWDOC');
    this.heredoc_label = this.heredoc_label.substring(1, this.heredoc_label.length - 1);
  } else {
    if (this.heredoc_label[0] == '"') {
      this.heredoc_label = this.heredoc_label.substring(1, this.heredoc_label.length - 1);
    }
    this.begin('ST_HEREDOC');
  }
  return T_START_HEREDOC;
}


<ST_IN_SCRIPTING>[`] {
  this.begin("ST_BACKQUOTE");
  return '`';
}


<ST_END_HEREDOC>{ANY_CHAR} {
  while(this._input.length > 0) {
    var char = this.input();
    if (char == ';') {
      this.unput(char);
      break;
    }
  }
  this.popState();
  this.popState();
  return T_END_HEREDOC;
}


<ST_DOUBLE_QUOTES,ST_BACKQUOTE,ST_HEREDOC>"{$" {
  this.less(1);
  this.begin('ST_IN_SCRIPTING');
  return T_CURLY_OPEN;
}


<ST_DOUBLE_QUOTES>["] {
  this.popState();
  return '"';
}

<ST_BACKQUOTE>[`] {
  this.popState();
  return '`';
}


<ST_DOUBLE_QUOTES>{ANY_CHAR} {
  while(this._input.length > 0) {
    var char = this.input();
    if (char == '\\') {
      char = this.input();
    } else if (char == '"') {
      this.unput(char);
      break;
    } else if (char == '$') {
      char = this.input();
      if ( char == '{' || IS_LABEL_START(char)) {
        this.unput('$' + char);
        break;
      }
    } else if (char == '{') {
      char = this.input();
      if (char == '$') {
        this.unput('{$');
        break;
      }
    }
  }
  return T_ENCAPSED_AND_WHITESPACE;
}


<ST_BACKQUOTE>{ANY_CHAR} {
  while(this._input.length > 0) {
    var char = this.input();
    if (char == '\\') {
      this.input();
    } else if ( char == '$' ) {
      if (
        this._input[0] == '{'
        || IS_LABEL_START(c)
      ) {
        this.unput(char);
        break;
      }
    } else if (char == '`') {
      this.unput(char);
      break;
    }
  }
  // yytext = scan_escape_string(yytext);
  return T_ENCAPSED_AND_WHITESPACE;
}


<ST_HEREDOC>{ANY_CHAR} {
  while(this._input.length > 0) {
    var char = this.input();
    if (
      char == '\n'
      || char == '\r'
      || char == '\r\n'
    ) {
      char = this.input();
      if (IS_LABEL_START(char)) {
        var label = char;
        while(this._input.length > 0) {
          char = this.input();
          if (char == ';') {
            break;
          } else {
            label += char;
            if (label.length > this.heredoc_label.length) break;
          }
        }
        if (label == this.heredoc_label) break;
      }
    }
  }
  this.less(yytext.length - this.heredoc_label.length - 1);
  this.begin('ST_END_HEREDOC');
  return T_ENCAPSED_AND_WHITESPACE;
}


<ST_NOWDOC>{ANY_CHAR} {
  while(this._input.length > 0) {
    var char = this.input();
    if (
      char == '\n'
      || char == '\r'
      || char == '\r\n'
    ) {
      char = this.input();
      if (IS_LABEL_START(char)) {
        var label = char;
        while(this._input.length > 0) {
          char = this.input();
          if (char == ';') {
            break;
          } else {
            label += char;
            if (label.length > this.heredoc_label.length) break;
          }
        }
        if (label == this.heredoc_label) break;
      }
    }
  }
  this.less(yytext.length - this.heredoc_label.length - 1);
  this.begin('ST_END_HEREDOC');
  return T_ENCAPSED_AND_WHITESPACE;
}
