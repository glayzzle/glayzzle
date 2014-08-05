
inner_statement_list:
    inner_statement_list inner_statement  {  $$ = [$1, $2]; }
  | /* empty */
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
      else_single                         {
      $$ = {
        type: 'common.T_IF',
        condition: $2,
        statement: $3,
        _elseif: $4,
        _else: $5
      };
    }
  | T_IF parenthesis_expr ':' 
    inner_statement_list 
    new_elseif_list 
    new_else_single 
    T_ENDIF ';'                           { 
      $$ = {
        type: 'common.T_IF',
        condition: $2,
        statement: $4,
        _elseif: $5,
        _else: $6
      };
    }
  | T_WHILE parenthesis_expr 
    while_statement                       {
      $$ = {
        type: 'common.T_WHILE',
        condition: $2,
        statement: $3
      };
    }
  | T_DO statement 
    T_WHILE parenthesis_expr ';'          {
      $$ = {
        type: 'common.T_DO',
        condition: $4,
        statement: $2
      };
    }
  | T_FOR '(' 
    for_expr ';' 
    for_expr ';' 
    for_expr ')' for_statement            {
      $$ = {
        type: 'common.T_FOR',
        init: $3,
        check: $5,
        incr: $7,
        statement: $9
      };
    }
  | T_SWITCH 
    parenthesis_expr 
    switch_case_list                      {
      $$ = {
        type: 'common.T_SWITCH',
        check: $2,
        statement: $3
      };
    }
  | T_BREAK ';'                           { $$ = 'break'; }
  | T_BREAK expr ';'                      { $$ = ['break', $2]; }
  | T_CONTINUE ';'                        { $$ = 'continue'; }
  | T_CONTINUE expr ';'                   { $$ = ['continue', $2]; }
  | T_RETURN ';'                          { $$ = ['return']; }
  | T_RETURN expr_without_variable ';'    { $$ = ['return', $2]; }
  | T_RETURN variable ';'                 { $$ = ['return', $2]; }
  | yield_expr ';'                        { $$ = 'yield'; }
  | T_GLOBAL global_var_list ';'          { $$ = [$1, $2]; /* @todo */ }
  | T_STATIC static_var_list ';'          { $$ = [$1, $2]; /* @todo */ }
  | T_ECHO echo_expr_list ';'             { $$ = [$1, $2]; /* @todo */ }
  | T_INLINE_HTML                         { $$ = $1; /* @todo */ }
  | expr ';'                              { $$ = $1; }
  | T_UNSET '(' unset_variables ')' ';'   { $$ = this.define_function('unset', $3); }
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
    declare_statement                     { /* @todo */
      $$ = ['declare', $3, $5];
    }
  | ';' /* empty statement */
  | T_TRY '{' inner_statement_list '}' 
    catch_statement 
    finally_statement                     { /* @todo */
      $$ = ['try', $3, $5, $6]; 
    }
  | T_THROW expr ';'                      { $$ = ['throw', $2]; /* @todo */ }
  | T_GOTO T_STRING ';'                   { this.compile_error("LABELS and GOTO statements are not supported"); }
;


catch_statement:
    /* empty */                           { $$ = null; }
  | T_CATCH '(' 
      fully_qualified_class_name 
      T_VARIABLE 
    ')' '{' 
      inner_statement_list 
    '}' additional_catches                { /* @todo */
    $$ = ['catch', $3, $4, $7, $9];
  }
;

finally_statement:
    /* empty */                           { $$ = null; }
  | T_FINALLY '{' 
    inner_statement_list 
    '}'                                   { /* @todo */
      $$ = ['finally', $3];
    }
;

additional_catches:
  non_empty_additional_catches            { $$ = $1; }
  | /* empty */                           { $$ = null; }
;

non_empty_additional_catches:
    additional_catch                      { $$ = $1; }
  | non_empty_additional_catches 
    additional_catch                      { $$ = [$1, $2]; }
;

additional_catch:
  T_CATCH '(' 
    fully_qualified_class_name T_VARIABLE 
  ')' '{' 
    inner_statement_list 
  '}'                                     { /* @todo */
    $$ = ['catch', $3, $4, $7];
  }
;

unset_variables:
    unset_variable
  | unset_variables ',' unset_variable
;

unset_variable:
  variable                                { $$ = $1; }
;

declare_statement:
    statement
  | ':' inner_statement_list T_ENDDECLARE ';'
;


declare_list:
    T_STRING '=' static_scalar            { /* @todo */ 
    $$ = [$1, $3];
  }
  | declare_list 
    ',' 
    T_STRING '=' static_scalar            { /* @todo */
    $$ = [$1, [$3, $5]];
  }
;


assignment_list:
    assignment_list ',' assignment_list_element
  | assignment_list_element
;


assignment_list_element:
    variable                              { $$ = $1; }
  | T_LIST '('  assignment_list ')'       { $$ = [$1, $3]; }
  | /* empty */                           { $$ = null; }
;
