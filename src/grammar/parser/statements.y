
inner_statement_list:
  inner_statement                         { $$ = [$1]; }
  | inner_statement_list inner_statement  { $$ = $1; $1.push($2); }
;


inner_statement:
    statement
  | function_declaration_statement
  | class_declaration_statement
  | T_HALT_COMPILER '(' ')' ';'           { this.compile_error("__HALT_COMPILER() can only be used from the outermost scope"); }
;


statement:
    unticked_statement                    { $$ = $1; }
  | T_STRING ':'                          { this.compile_error("LABELS and GOTO statements are not supported"); }
;

unticked_statement:
    '{' inner_statement_list '}'          { $$ = $2; }
  | T_IF parenthesis_expr 
      statement 
      elseif_list 
      else_single                         { $$ = ['if', $2, $3, $4, $5]; }
  | T_IF parenthesis_expr ':' 
    inner_statement_list 
    new_elseif_list 
    new_else_single 
    T_ENDIF ';'                           { $$ = ['if', $2, $4, $5, $6]; }
  | T_WHILE parenthesis_expr 
    while_statement                       { $$ = ['while', $2, $3]; }
  | T_DO statement 
    T_WHILE parenthesis_expr ';'          { $$ = ['do', $4, $2]; }
  | T_FOR '(' 
    for_expr ';' 
    for_expr ';' 
    for_expr ')' for_statement            { $$ = ['for', $3, $5, $7, $9]; }
  | T_SWITCH 
    parenthesis_expr 
    switch_case_list                      {
      $$ = {
        type: 'common.T_SWITCH',
        check: $2,
        statement: $3
      };
    }
  | T_BREAK ';'                           { $$ = ['break', null]; }
  | T_BREAK expr ';'                      { $$ = ['break', $2]; }
  | T_CONTINUE ';'                        { $$ = ['continue', null]; }
  | T_CONTINUE expr ';'                   { $$ = ['continue', $2]; }
  | T_RETURN ';'                          { $$ = ['return']; }
  | T_RETURN expr_without_variable ';'    { $$ = ['return', $2]; }
  | T_RETURN variable ';'                 { $$ = ['return', $2]; }
  | yield_expr ';'                        { $$ = ['yield', $1]; }
  | T_GLOBAL global_var_list ';'          { $$ = ['global', $2]; }
  | T_STATIC static_var_list ';'          { $$ = ['static', $2]; }
  | T_ECHO echo_expr_list ';'             { $$ = ['call', 'echo', $2]; }
  | T_INLINE_HTML                         { $$ = ['call', 'echo', $1]; }
  | expr ';'                              { $$ = $1; }
  | T_UNSET '(' unset_variables ')' ';'   { $$ = ['unset', $3]; }
  | T_FOREACH 
    '(' 
      variable T_AS foreach_variable 
      foreach_optional_arg 
    ')' foreach_statement                 {
      $$ = {
        type: 'common.T_FOREACH',
        source: $3,
        item: $5,
        alias: $6,
        statement: $8
      };
    }
  | T_FOREACH 
    '(' 
      expr_without_variable T_AS foreach_variable 
      foreach_optional_arg 
    ')' foreach_statement                 {
      $$ = {
        type: 'common.T_FOREACH',
        source: $3,
        item: $5,
        alias: $6,
        statement: $8
      };
    }
  | T_DECLARE '(' declare_list ')' 
    declare_statement                     { $$ = ['declare', $3, $5]; }
  | ';' /* empty statement */
  | T_TRY '{' inner_statement_list '}' 
    catch_statement 
    finally_statement                     { $$ = ['try', $3, $5, $6]; }
  | T_THROW expr ';'                      { $$ = ['throw', $2]; }
  | T_GOTO T_STRING ';'                   { this.compile_error("LABELS and GOTO statements are not supported"); }
;


catch_statement:
    /* empty */                               { $$ = false; }
  | T_CATCH '(' 
      fully_qualified_class_name 
      T_VARIABLE 
    ')' '{' 
      inner_statement_list 
    '}' additional_catches                    { $$ = ['catch', $3, $4, $7, $9]; }
;

finally_statement:
    /* empty */                               { $$ = false; }
  | T_FINALLY '{' inner_statement_list '}'    { $$ = $3; }
;

additional_catches:
  /* empty */                                 { $$ = false; }
  | non_empty_additional_catches              { $$ = $1; }
;

non_empty_additional_catches:
    additional_catch                      { $$ = [$1]; }
  | non_empty_additional_catches 
    additional_catch                      { $$ = $1; $1.push($2); }
;

additional_catch:
  T_CATCH '(' 
    fully_qualified_class_name T_VARIABLE 
  ')' '{' 
    inner_statement_list 
  '}'                                     { $$ = [$3, $4, $7]; }
;

unset_variables:
    unset_variable                        { $$ = [$1]; }
  | unset_variables ',' unset_variable    { $$ = $1; $1.push($2); }
;

unset_variable:
  variable                                { $$ = $1; }
;

declare_statement:
    statement                                   { $$ = [$1]; }
  | ':' inner_statement_list T_ENDDECLARE ';'   { $$ = $2; }
;


declare_list:
    T_STRING '=' static_scalar                  { $$ = [[$1, $3]]; }
  | declare_list ',' 
    T_STRING '=' static_scalar                  { $$ = $1; $1.push([$3, $5]); }
;


assignment_list:
  assignment_list_element                         { $$ = [$1]; }
  | assignment_list ',' assignment_list_element   { $$ = $1; $1.push($3); }
;

assignment_list_element:
    variable                                      { $$ = ['var', $1]; }
  | T_LIST '('  assignment_list ')'               { $$ = ['list', $3]; }
  | /* empty */                                   { $$ = false; }
;
