constant_declaration:
    constant_declaration ',' T_STRING '=' static_scalar { 
      $$ = { type: 'constants.DECLARE', name: $3, value: $5 }; 
    }
  | T_CONST T_STRING '=' static_scalar {
      $$ = { type: 'constants.DECLARE', name: $2, value: $4 };
    }
  ;

encaps_list:
    encaps_list encaps_var                  { $$ = [$1, $2]; }
  | encaps_list T_ENCAPSED_AND_WHITESPACE   { $$ = $1; }
  | encaps_var                              { $$ = $1; }
  | T_ENCAPSED_AND_WHITESPACE encaps_var    { $$ = $2; }
;

encaps_var:
    T_VARIABLE                                                    { $$ = $1; }
  | T_VARIABLE '[' encaps_var_offset ']'                          { $$ = [$1, $3]; }
  | T_VARIABLE T_OBJECT_OPERATOR T_STRING                         { $$ = [$1, $3]; }
  | T_DOLLAR_OPEN_CURLY_BRACES expr '}'                           { $$ = $2; }
  | T_DOLLAR_OPEN_CURLY_BRACES T_STRING_VARNAME '[' expr ']' '}'  { $$ = [$2, $4]; }
  | T_CURLY_OPEN variable '}'                                     { $$ = $2; }
;

encaps_var_offset:
    T_STRING        { $$ = $1; }
  | T_NUM_STRING    { $$ = $1; }
  | T_VARIABLE      { $$ = $1; }
;

internal_functions_in_yacc:
    T_ISSET '(' isset_variables ')'            { $$ = this.define_function('isset', $3); }
  | T_EMPTY '(' variable ')'                   { $$ = this.define_function('empty', $3); }
  | T_EMPTY '(' expr_without_variable ')'      { $$ = this.define_function('empty', $3); }
  | T_INCLUDE expr                             { $$ = this.define_function('include', $2); }
  | T_INCLUDE_ONCE expr                        { $$ = this.define_function('include_once', $2); }
  | T_EVAL '(' expr ')'                        { $$ = this.define_function('eval', $3); }
  | T_REQUIRE expr                             { $$ = this.define_function('require', $2); }
  | T_REQUIRE_ONCE expr                        { $$ = this.define_function('require_once', $2); }
;