
static_scalar:
  ('+'|'-')? T_LNUMBER | T_DNUMBER { $$ = ['number', $1]; }
  | T_CONSTANT_ENCAPSED_STRING     { $$ = ['string', $1.substring(1, $1.length - 1)]; }
  | T_LINE                         { $$ = ['number', this.lexer.yylloc.last_line]; }
  | T_FILE                         { $$ = $1; }
  | T_DIR                          { $$ = $1; }
  | T_TRAIT_C                      { $$ = $1; }
  | T_METHOD_C                     { $$ = $1; }
  | T_FUNC_C                       { $$ = $1; }
  | T_NS_C                         { $$ = $1; }
  | T_START_HEREDOC T_ENCAPSED_AND_WHITESPACE T_END_HEREDOC { $$ = ['string', $2]; }
  | T_START_HEREDOC T_END_HEREDOC  { $$ = ['string', '']; } 
;
