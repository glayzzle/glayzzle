
foreach_optional_arg:
    /* empty */                        { $$ = false; }
  | T_DOUBLE_ARROW foreach_variable    { $$ = $2; }
;

foreach_variable:
		variable
	|	'&' variable
	|	T_LIST '(' assignment_list ')'
;

for_statement:
		statement
	|	':' inner_statement_list T_ENDFOR ';'
;


foreach_statement:
		statement
	|	':' inner_statement_list T_ENDFOREACH ';'
;



while_statement:
		statement
	|	':' inner_statement_list T_ENDWHILE ';'
;



for_expr:
		/* empty */
	|	non_empty_for_expr	{ $$ = $1; }
;

non_empty_for_expr:
		non_empty_for_expr ','	expr
	|	expr					{ $$ = $1; }
;