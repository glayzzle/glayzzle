<INITIAL>"<%="   %{
  if (conf.asp_tags) {
    this.begin('ST_IN_SCRIPTING');
    return tok.T_OPEN_TAG_WITH_ECHO;
  }
%}

<INITIAL>"<?="   %{
  this.begin('ST_IN_SCRIPTING');
  return tok.T_OPEN_TAG_WITH_ECHO;
%}

<INITIAL>{ANY_CHAR} %{
  return tok.T_INLINE_HTML;
%}