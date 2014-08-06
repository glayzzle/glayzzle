
<INITIAL>"<script"{WHITESPACE}+"language"{WHITESPACE}*"="{WHITESPACE}*("php"|"\"php\""|"'php'"){WHITESPACE}*">" {
  this.begin("ST_IN_SCRIPTING");
  return T_OPEN_TAG;
}


<INITIAL>"<%=" {
  if (conf.asp_tags) {
    this.begin("ST_IN_SCRIPTING");
    return T_OPEN_TAG_WITH_ECHO;
  } else {
    this.reject();
  }
}


<INITIAL>"<?=" {
  this.begin("ST_IN_SCRIPTING");
  return T_OPEN_TAG_WITH_ECHO;
}


<INITIAL>"<%" {
  if (conf.asp_tags) {
    this.begin("ST_IN_SCRIPTING");
    return T_OPEN_TAG;
  } else {
    this.reject();
  }
}


<INITIAL>"<?php"([ \t]|{NEWLINE}) {
  this.begin("ST_IN_SCRIPTING");
  return T_OPEN_TAG;
}


<INITIAL>"<?" {
  if (conf.short_tags) {
    this.begin("ST_IN_SCRIPTING");
    return T_OPEN_TAG;
  } else {
    throw new Error('Unauth state');
    this.unput("<?");
  }
}

<INITIAL>{ANY_CHAR} {
  while(this._input.length > 0) {
    var char = this.input();
    if (char == '<') {
      var q = this.input();
      /*if (q == 's' && this._input.substring(0, 6) == 'cript ') {
          this.unput('<s');
          break;
      } else */ 
      if(q == '?') {
        if (
          this._input.substring(0, 3) == 'php' || this._input.substring(0, 1) == '='
        ) {
          this.unput('<?');
          break;
        } else if (conf.short_tags) {
          this.unput('<?');
          break;
        }
      } else if(conf.asp_tags && q == '%') {
        this.unput('<%');
        break;
      }
    }
  }
  return T_INLINE_HTML;
}

<ST_IN_SCRIPTING>("?>"|"</script"{WHITESPACE}*">"){NEWLINE}? {
  var c = this.input();
  if ( 
    c != '\r\n'
    && c != '\n'
    && c != '\r'
  ) {
    this.unput(c);
  }
  this.popState();
  return T_CLOSE_TAG;
}


<ST_IN_SCRIPTING>"%>"{NEWLINE}? {
  if (conf.asp_tags) {
    this.popState();
    return T_CLOSE_TAG;  /* implicit ';' at php-end tag */
  } else {
    this.less(1);
    return yytext;
  }
}