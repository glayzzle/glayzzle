
expr_without_variable:
    T_LIST '('  assignment_list ')' '=' expr {
      $$ = {
        type: 'common.T_LIST',
        items: $3,
        expr: $6
      };
    }
  | variable '=' expr
  | variable '=' '&' variable 
  | variable '=' '&' T_NEW class_name_reference ctor_arguments
  | T_CLONE expr
  | variable T_PLUS_EQUAL expr
  | variable T_MINUS_EQUAL expr
  | variable T_MUL_EQUAL exp
  | variable T_DIV_EQUAL expr
  | variable T_CONCAT_EQUAL expr
  | variable T_MOD_EQUAL expr
  | variable T_AND_EQUAL expr
  | variable T_OR_EQUAL expr
  | variable T_XOR_EQUAL expr
  | variable T_SL_EQUAL expr
  | variable T_SR_EQUAL expr
  | rw_variable T_INC
  | T_INC rw_variable
  | rw_variable T_DEC
  | T_DEC rw_variable
  | expr T_BOOLEAN_OR expr
  | expr T_BOOLEAN_AND expr
  | expr T_LOGICAL_OR expr
  | expr T_LOGICAL_AND expr
  | expr T_LOGICAL_XOR expr
  | expr '|' expr 
  | expr '&' expr
  | expr '^' expr 
  | expr '.' expr
  | expr '+' expr
  | expr '-' expr
  | expr '*' expr
  | expr '/' expr
  | expr '%' expr
  | expr T_SL expr
  | expr T_SR expr
  | '+' expr %prec T_INC
  | '-' expr %prec T_INC
  | '!' expr
  | '~' expr
  | expr T_IS_IDENTICAL expr
  | expr T_IS_NOT_IDENTICAL expr
  | expr T_IS_EQUAL expr
  | expr T_IS_NOT_EQUAL expr
  | expr '<' expr
  | expr T_IS_SMALLER_OR_EQUAL expr
  | expr '>' expr
  | expr T_IS_GREATER_OR_EQUAL expr
  | expr T_INSTANCEOF class_name_reference
  | parenthesis_expr                                  { $$ = $1; }
  | new_expr                                          { $$ = $1; }
  | '(' new_expr ')' instance_call                    { $$ = $2;  $$ = $5; }
  | expr '?' 
    expr ':' 
    expr                                              { $$ = ['?', $1, $3, $5]; }
  | expr '?' ':'
    expr                                              { $$ = ['?', $1, null, $4]; }
  | internal_functions_in_yacc                        { $$ = $1; }
  | T_INT_CAST expr
  | T_DOUBLE_CAST expr
  | T_STRING_CAST expr
  | T_ARRAY_CAST expr
  | T_OBJECT_CAST expr
  | T_BOOL_CAST expr
  | T_UNSET_CAST expr
  | T_EXIT exit_expr
  | '@' expr
  | scalar                                            { $$ = $1; }
  | combined_scalar_offset
  | combined_scalar                                   { $$ = $1; }
  | '`' backticks_expr '`'
  | T_PRINT expr
  | T_YIELD
  | function is_reference 
    '(' parameter_list ')' 
    lexical_vars '{' 
      inner_statement_list 
    '}'
  | T_STATIC function is_reference 
    '(' parameter_list ')' l
    exical_vars '{' 
      inner_statement_list
    '}'
;

yield_expr:
    T_YIELD expr_without_variable                       { $$ = ['yield', $2, null]; }
  | T_YIELD variable                                    { $$ = ['yield', null, $4]; }
  | T_YIELD expr T_DOUBLE_ARROW expr_without_variable   { $$ = ['yield', $2, $4]; }
  | T_YIELD expr T_DOUBLE_ARROW variable                { $$ = ['yield', $2, $4]; }
;

is_reference:
  /* empty */                       { $$ = false; }
  | '&'                             { $$ = true; }
;

global_var_list:
    global_var_list ',' global_var  { $$ = [$1, $3]; }
  | global_var                      { $$ = $1; }
;


global_var:
    T_VARIABLE                      { $$ = $1; }
  | '$' r_variable                  { $$ = $2; }
  | '$' '{' expr '}'                { $$ = $3; }
;


lexical_vars:
    /* empty */
  | T_USE '(' lexical_var_list ')'
;

lexical_var_list:
    lexical_var_list ',' T_VARIABLE
  | lexical_var_list ',' '&' T_VARIABLE 
  | T_VARIABLE                      { $$ = $1; }
  | '&' T_VARIABLE                  { $$ = $2; }
;

static_var_list:
    static_var_list ',' T_VARIABLE
  | static_var_list ',' T_VARIABLE '=' static_scalar
  | T_VARIABLE
  | T_VARIABLE '=' static_scalar
;

echo_expr_list:
    echo_expr_list ',' expr         { $$ = [$1, $3]; }
  | expr                            { $$ = $1; }
;


exit_expr:
    /* empty */                     { $$ = []; }
  | '(' ')'                         { $$ = []; }
  | parenthesis_expr                { $$ = $1; }
;

backticks_expr:
    /* empty */                     { $$ = null; }
  | T_ENCAPSED_AND_WHITESPACE       { $$ = $1; }
  | encaps_list                     { $$ = $1; }
;


expr:
    r_variable                      { $$ = $1; }
  | expr_without_variable	          { $$ = $1; }
;

parenthesis_expr:
    '(' expr ')'                    { $$ = $2; }
  | '(' yield_expr ')'              { $$ = $2; }
;

