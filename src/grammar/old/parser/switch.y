
switch_case_list:
    '{' case_list '}'                  { /* switch_case_list:1 */ $$ = $2; }
  | '{' ';' case_list '}'              { /* switch_case_list:2 */ $$ = $3; }
  | ':' case_list T_ENDSWITCH ';'      { /* switch_case_list:3 */ $$ = $2; }
  | ':' ';' case_list T_ENDSWITCH ';'  { /* switch_case_list:4 */ $$ = $3; }
;


case_list:
  case_list T_CASE expr case_separator inner_statement* { /* case_list */  $$ = $1; $1.push([$3, $5]); }
  | case_list T_DEFAULT case_separator inner_statement* { /* case_list */  $$ = $1; $1.push(['default', $4]); }
  | /* empty */                                             { /* case_list */  $$ = []; }
;


case_separator:
  ':' | ';'
;

