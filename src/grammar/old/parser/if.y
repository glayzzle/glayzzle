
elseif_list:
    elseif_list T_ELSEIF parenthesis_expr statement                         { /* elseif_list */ $$ = $1; $1.push([$3, $4]); }
  | T_ELSEIF parenthesis_expr statement                                     { /* elseif_list */ $$ = [[$2, $3]]; }
  | /* empty */                                                             { /* elseif_list */ $$ = false; }
;

new_elseif_list:
    new_elseif_list T_ELSEIF parenthesis_expr ':' inner_statement*          { /* new_elseif_list */ $$ = $1; $1.push([$3, $5]); }
  | T_ELSEIF parenthesis_expr ':' inner_statement*                          { /* new_elseif_list */ $$ = [[$2, $4]]; }
  | /* empty */                                                             { /* new_elseif_list */ $$ = false; }
;

else_single:
  T_ELSE statement                                                          { /* else_single */ $$ = $2; }
  | /* empty */                                                             { /* else_single */ $$ = false; }
;


new_else_single:
  T_ELSE ':' inner_statement*                                               { /* new_else_single */ $$ = $3; }
  | /* empty */                                                             { /* new_else_single */ $$ = false; }
;
