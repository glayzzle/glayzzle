
elseif_list:
  T_ELSEIF parenthesis_expr statement {
    $$ = [[$3, $4]];
  }
  | elseif_list T_ELSEIF parenthesis_expr statement   {
    $$ = $1;
    $1.push([$3, $4]);
  }
  | /* empty */                                     { $$ = null; }
;


new_elseif_list:
  T_ELSEIF parenthesis_expr ':' inner_statement_list {
    $$ = [[$3, $5]];
  }
  | new_elseif_list T_ELSEIF parenthesis_expr ':' inner_statement_list {
    $$ = $1;
    $1.push([$3, $5]);
  }
  | /* empty */                                     { $$ = null; }
;


else_single:
  T_ELSE statement      { $$ = $2; }
  | /* empty */         { $$ = null; }
;


new_else_single:
  T_ELSE ':' inner_statement_list     { $$ = $3; }
  | /* empty */                       { $$ = null; }
;
