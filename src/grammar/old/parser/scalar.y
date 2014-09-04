combined_scalar_offset:
    combined_scalar_offset '[' dim_offset ']'
  | T_CONSTANT_ENCAPSED_STRING '[' dim_offset ']'
  | combined_scalar '[' dim_offset ']'
;

combined_scalar:
  T_ARRAY '(' array_pair_list ')'   { $$ = ['array', $3]; }
  | '[' array_pair_list ']'         { $$ = ['array', $2]; }
;

common_scalar:
    T_LNUMBER                      { $$ = ['number', $1]; }
  | T_DNUMBER                      { $$ = ['number', $1]; }
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


static_scalar:
    common_scalar                                       { /* static_scalar */ $$ = $1; }
  | class_name T_DOUBLE_COLON T_CLASS                   { /* static_scalar */ $$ = $1; }
  | class_name T_DOUBLE_COLON T_STRING                  { /* static_scalar */ $$ = ['prop', $3, $1]; } 
  | T_NS_SEPARATOR namespace_name 
  | namespace_name 
  | '+' static_scalar 
  | '-' static_scalar 
  | T_ARRAY '(' static_array_pair_list ')'              { /* static_scalar */ $$ = ['array', $3]; }
  | '[' static_array_pair_list ']'                      { /* static_scalar */ $$ = ['array', $2]; }
  | T_CLASS_C
;

scalar:
    T_STRING_VARNAME                                    { /* scalar */ $$ = $1; }
  | class_name T_DOUBLE_COLON T_CLASS                   { /* scalar */ $$ = $1; }
  | class_constant                                      { /* scalar */ $$ = $1; }
  | T_NS_SEPARATOR namespace_name                       { /* scalar */ $$ = $2; }
  | common_scalar                                       { /* scalar */ $$ = $1; }
  | '"' encaps_list '"'                                 { /* scalar */ $$ = ['string', $2]; }
  | T_START_HEREDOC encaps_list T_END_HEREDOC           { /* scalar */ $$ = ['string', $2]; }
  | T_CLASS_C
;
/* 
conflict :   | namespace_name                                      { /* scalar *-/ $$ = $1; }
*/