
foreach_optional_arg:
    T_DOUBLE_ARROW foreach_variable             { /* foreach_optional_arg */ $$ = $2; }
  | /* empty */                                 { /* foreach_optional_arg */ $$ = false; }
;

foreach_variable:
    variable                                    { /* foreach_variable */ $$ = $1; }
  | '&' variable                                { /* foreach_variable */ $$ = $2; }
  | T_LIST '(' assignment_list ')'              { /* foreach_variable */ $$ = ['list', $3]; }
;

for_statement:
  statement                                     { /* for_statement */ $$ = $1; }
  | ':' inner_statement_list T_ENDFOR ';'       { /* for_statement */ $$ = $2; }
;

foreach_statement:
    statement                                   { /* foreach_statement */ $$ = $1; }
  | ':' inner_statement_list T_ENDFOREACH ';'   { /* foreach_statement */ $$ = $2; }
;

while_statement:
    statement                                   { /* while_statement */ $$ = $1; }
  | ':' inner_statement_list T_ENDWHILE ';'     { /* while_statement */ $$ = $2; }
;

for_expr:
    non_empty_for_expr                          { /* for_expr */ $$ = $1; }
  | /* empty */                                 { /* for_expr */ $$ = false; }
;

non_empty_for_expr:
    non_empty_for_expr ','  expr                { /* non_empty_for_expr */ $$ = $1; $1.push($3); }
  | expr                                        { /* non_empty_for_expr */ $$ = [$1]; }
;