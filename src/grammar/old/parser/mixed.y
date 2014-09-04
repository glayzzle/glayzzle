
encaps_list:
  encaps_var                                { $$ = [$1]; }
  | T_ENCAPSED_AND_WHITESPACE encaps_var    { $$ = [['string', $1], $2]; }
  | encaps_list encaps_var                  { $$ = $1; $1.push($2); }
  | encaps_list T_ENCAPSED_AND_WHITESPACE   { $$ = $1; $1.push($2); }
;

encaps_var:
    const_variable                                                { $$ = $1; }
  | const_variable '[' encaps_var_offset ']'                      { $$ = ['offset', $3, $1]; }
  | const_variable T_OBJECT_OPERATOR T_STRING                     { $$ = ['prop', $3, $1]; }
  | T_DOLLAR_OPEN_CURLY_BRACES expr '}'                           { $$ = $2; }
  | T_DOLLAR_OPEN_CURLY_BRACES T_STRING_VARNAME '[' expr ']' '}'  { $$ = ['offset', $4, ['let', $2]]; /** @check **/ }
  | T_CURLY_OPEN variable '}'                                     { $$ = ['let', $2]; }
;

encaps_var_offset:
    T_STRING                                  { $$ = ['const', $1]; }
  | T_NUM_STRING                              { $$ = ['number', $1]; }
  | const_variable                            { $$ = $1; }
;

internal_functions_in_yacc:
    T_ISSET '(' isset_variables ')'            { $$ = ['call', 'isset', $3]; }
  | T_EMPTY '(' expr ')'                       { $$ = ['call', 'empty', $3]; }
  | T_INCLUDE expr                             { $$ = ['call', 'include', $2]; }
  | T_INCLUDE_ONCE expr                        { $$ = ['call', 'include_once', $2]; }
  | T_EVAL '(' expr ')'                        { $$ = ['call', 'eval', $3]; }
  | T_REQUIRE expr                             { $$ = ['call', 'require', $2]; }
  | T_REQUIRE_ONCE expr                        { $$ = ['call', 'require_once', $2]; }
;