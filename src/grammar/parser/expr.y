
expr_without_variable:
    T_LIST '('  assignment_list ')' '=' expr  { $$ = ['list', $3, $6]; }
  | variable '=' expr                         { $$ = ['set', $1, $3]; }
  | variable '=' '&' variable                 { $$ = ['set', $1, $4]; }
  | variable '=' '&' new_expr                 { $$ = ['set', $1, $4]; }
  | T_CLONE expr                              { $$ = ['clone', $2]; }
  | variable T_PLUS_EQUAL expr                { $$ = ['set', $1, ['op', 'add', $1, $3] ]; }
  | variable T_MINUS_EQUAL expr               { $$ = ['set', $1, ['op', 'sub', $1, $3] ]; }
  | variable T_MUL_EQUAL exp                  { $$ = ['set', $1, ['op', 'mul', $1, $3] ]; }
  | variable T_DIV_EQUAL expr                 { $$ = ['set', $1, ['op', 'div', $1, $3] ]; }
  | variable T_CONCAT_EQUAL expr              { $$ = ['set', $1, ['op', 'join', $1, $3] ]; }
  | variable T_MOD_EQUAL expr                 { $$ = ['set', $1, ['op', 'mod', $1, $3] ]; }
  | variable T_AND_EQUAL expr
  | variable T_OR_EQUAL expr
  | variable T_XOR_EQUAL expr
  | variable T_SL_EQUAL expr
  | variable T_SR_EQUAL expr
  | variable T_INC                            { $$ = ['op', 'post', '+', $1]; }
  | T_INC variable                            { $$ = ['op', 'pre', '+', $1]; }
  | variable T_DEC                            { $$ = ['op', 'post', '-', $1]; }
  | T_DEC variable                            { $$ = ['op', 'pre', '-', $1]; }
  | expr T_BOOLEAN_OR expr
  | expr T_BOOLEAN_AND expr
  | expr T_LOGICAL_OR expr
  | expr T_LOGICAL_AND expr
  | expr T_LOGICAL_XOR expr
  | expr '|' expr                             { $$ = ['op', 'or', $1, $3 ]; }
  | expr '&' expr                             { $$ = ['op', 'and', $1, $3 ]; }
  | expr '^' expr                             { $$ = ['op', 'pow', $1, $3 ]; }
  | expr '.' expr                             { $$ = ['op', 'join', $1, $3 ]; }
  | expr '+' expr                             { $$ = ['op', 'add', $1, $3 ]; }
  | expr '-' expr                             { $$ = ['op', 'sub', $1, $3 ]; }
  | expr '*' expr                             { $$ = ['op', 'mul', $1, $3 ]; }
  | expr '/' expr                             { $$ = ['op', 'div', $1, $3 ]; }
  | expr '%' expr                             { $$ = ['op', 'mod', $1, $3 ]; }
  | expr T_SL expr                            { $$ = ['op', '<<', $1, $3 ]; }
  | expr T_SR expr                            { $$ = ['op', '>>', $1, $3 ]; }
  | '+' expr %prec T_INC
  | '-' expr %prec T_INC
  | '!' expr
  | '~' expr
  | expr T_IS_IDENTICAL expr                          { $$ = ['compare', '==', $1, $3]; }
  | expr T_IS_NOT_IDENTICAL expr                      { $$ = ['compare', '!', $1, $3]; }
  | expr T_IS_EQUAL expr                              { $$ = ['compare', '=', $1, $3]; }
  | expr T_IS_NOT_EQUAL expr                          { $$ = ['compare', '?', $1, $3]; }
  | expr '<' expr                                     { $$ = ['compare', '<', $1, $3]; }
  | expr T_IS_SMALLER_OR_EQUAL expr                   { $$ = ['compare', '<=', $1, $3]; }
  | expr '>' expr                                     { $$ = ['compare', '>', $1, $3]; }
  | expr T_IS_GREATER_OR_EQUAL expr                   { $$ = ['compare', '>=', $1, $3]; }
  | expr T_INSTANCEOF class_name_reference            { $$ = ['compare', '@', $1, $3]; }
  | parenthesis_expr                                  { $$ = $1; }
  | new_expr                                          { $$ = $1; }
  | '(' new_expr ')' instance_call                    {
      if ($4) {
        // @fixme check instance_call signature
        $4[3] = $2;
        $$ = $4;
      } else {
        $$ = $2;
      }
    }
  | expr '?' expr ':' expr                            { $$ = ['?', $1, $3, $5]; }
  | expr '?' ':' expr                                 { $$ = ['?', $1, ['const', 'null'], $4]; }
  | internal_functions_in_yacc                        { $$ = $1; }
  | T_INT_CAST expr
  | T_DOUBLE_CAST expr
  | T_STRING_CAST expr
  | T_ARRAY_CAST expr
  | T_OBJECT_CAST expr
  | T_BOOL_CAST expr
  | T_UNSET_CAST expr
  | T_EXIT exit_expr                                  { /* expr : exit */ $$ = ['call', 'exit', $2]; }
  | '@' expr                                          { /* expr : ignore errors */ $$ = ['ignore', $2]; }
  | combined_scalar_offset
  | combined_scalar                                   { /* expr : combined_scalar */  $$ = $1; }
  | scalar                                            { /* expr : scalar */ $$ = $1; }
  | '`' backticks_expr '`'
  | T_PRINT expr                                      { $$ = ['call', 'print', $2]; }
  | T_YIELD
  | T_STATIC T_FUNCTION is_reference '(' parameter_list ')' lexical_vars '{' 
      inner_statement*
    '}'                                               { /* expr: closure2 */ $$ = ['function', false, $5, $9, $7 /** use statements **/ ]; }
  | T_FUNCTION is_reference '(' parameter_list ')' lexical_vars '{' 
      inner_statement* 
    '}'                                               { /* expr: closure1 */ $$ = ['function', false, $4, $8, $6 /** use statements **/ ]; }
;

yield_expr:
    T_YIELD expr_without_variable                       { /* yield_expr */ $$ = ['yield', $2, null]; }
  | T_YIELD variable                                    { /* yield_expr */ $$ = ['yield', null, $4]; }
  | T_YIELD expr T_DOUBLE_ARROW expr_without_variable   { /* yield_expr */ $$ = ['yield', $2, $4]; }
  | T_YIELD expr T_DOUBLE_ARROW variable                { /* yield_expr */ $$ = ['yield', $2, $4]; }
;

is_reference:
    '&'                                                 { /* is_reference */ $$ = true; }
  | /* empty */                                         { /* is_reference */ $$ = false; }
;

global_var_list:
    global_var_list ',' global_var                      { /* global_var_list */ $$ = $1; $1.push($3); }
  | global_var                                          { /* global_var_list */ $$ = [$1]; }
;


global_var:
    '$' variable                                        { /* global_var */ $$ = ['let', $2]; }
  | '$' '{' expr '}'                                    { /* global_var */ $$ = ['let', $3]; }
  | const_variable                                      { /* global_var */ $$ = $1; }
;


lexical_vars:
    T_USE '(' lexical_var_list ')'                          { /* lexical_vars */ $$ = $3; }
  | /* empty */                                             { /* lexical_vars */ $$ = false; }
;

lexical_var_list:
    lexical_var_list ',' const_variable                     { /* lexical_var_list */ $$ = $1; $1.push($3); }
  | lexical_var_list ',' '&' const_variable                 { /* lexical_var_list */ $$ = $1; $1.push($4); }
  | const_variable                                          { /* lexical_var_list */ $$ = [$1]; }
  | '&' const_variable                                      { /* lexical_var_list */ $$ = [$2]; }
;

static_var_list:
    static_var_list ',' const_variable                      { /* static_var_list */ $$ = $1; $1.push($3); }
  | static_var_list ',' const_variable '=' static_scalar    { /* static_var_list */ $$ = $1; $1.push(['set', $3, $5]); }
  | const_variable                                          { /* static_var_list */ $$ = [$1]; }
  | const_variable '=' static_scalar                        { /* static_var_list */ $$ = [['set', $1, $3]]; }
;

echo_expr_list:
    echo_expr_list ',' expr         { /* echo_expr_list */ $$ = $1; $1.push($3); }
  | expr                            { /* echo_expr_list */ $$ = [$1]; }
;


exit_expr:
    '(' ')'                         { /* exit_expr */ $$ = []; }
  | parenthesis_expr                { /* exit_expr */ $$ = $1; }
  | /* empty */                     { /* exit_expr */ $$ = []; }
;

backticks_expr:
    /* empty */                     { $$ = false; }
  | T_ENCAPSED_AND_WHITESPACE       { $$ = $1; }
  | encaps_list                     { $$ = $1; }
;


expr:
  expr_without_variable             { /* expr : novar */ $$ = $1; }
  | '&' variable                    { /* expr : &var */ $$ = $2; }
  | variable                        { /* expr : var */ $$ = $1; }
;

parenthesis_expr:
    '(' expr ')'                    { $$ = $2; }
  | '(' yield_expr ')'              { $$ = $2; }
;

