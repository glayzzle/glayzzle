constant_declaration:
  T_CONST T_STRING '=' static_scalar                    { $$ = [['const', $2, $4]]; }
  | constant_declaration ',' T_STRING '=' static_scalar { $$ = $1; $1.push(['const', $3, $5]); }
;

encaps_list:
  encaps_var                                { $$ = [$1]; }
  | T_ENCAPSED_AND_WHITESPACE encaps_var    { $$ = [['string', $1], $2]; }
  | encaps_list encaps_var                  { $$ = $1; $1.push($2); }
  | encaps_list T_ENCAPSED_AND_WHITESPACE   { $$ = $1; $1.push($2); }
;

encaps_var:
    T_VARIABLE                                                    { $$ = ['var', $1]; }
  | T_VARIABLE '[' encaps_var_offset ']'                          { $$ = ['offset', $3, ['var', $1]]; }
  | T_VARIABLE T_OBJECT_OPERATOR T_STRING                         { $$ = ['prop', $3, ['var', $1]]; }
  | T_DOLLAR_OPEN_CURLY_BRACES expr '}'                           { $$ = $2; }
  | T_DOLLAR_OPEN_CURLY_BRACES T_STRING_VARNAME '[' expr ']' '}'  { $$ = ['offset', $4, ['var', $2]]; }
  | T_CURLY_OPEN variable '}'                                     { $$ = ['var', $2]; }
;

encaps_var_offset:
    T_STRING        { $$ = ['string', $1]; }
  | T_NUM_STRING    { $$ = ['number', $1]; }
  | T_VARIABLE      { $$ = ['var', $1]; }
;

internal_functions_in_yacc:
    T_ISSET '(' isset_variables ')'            { $$ = ['call', 'isset', $3]; }
  | T_EMPTY '(' variable ')'                   { $$ = ['call', 'empty', $3]; }
  | T_EMPTY '(' expr_without_variable ')'      { $$ = ['call', 'empty', $3]; }
  | T_INCLUDE expr                             { $$ = ['call', 'include', $2]; }
  | T_INCLUDE_ONCE expr                        { $$ = ['call', 'include_once', $2]; }
  | T_EVAL '(' expr ')'                        { $$ = ['call', 'eval', $3]; }
  | T_REQUIRE expr                             { $$ = ['call', 'require', $2]; }
  | T_REQUIRE_ONCE expr                        { $$ = ['call', 'require_once', $2]; }
;