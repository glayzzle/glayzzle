
switch_case_list:
    '{' case_list '}'                  { $$ = $2; }
  | '{' ';' case_list '}'              { $$ = $3; }
  | ':' case_list T_ENDSWITCH ';'      { $$ = $2; }
  | ':' ';' case_list T_ENDSWITCH ';'  { $$ = $3; }
;


case_list:
  /* empty */	{ $$ = null; }
  | case_list T_CASE expr case_separator inner_statement_list {
    $$ = [$1, ['case', $3, $5]];
  }
  | case_list T_DEFAULT case_separator inner_statement_list {
    $$ = [$1, ['default', null, $4]];
  }
;


case_separator:
  ':' | ';'
;

