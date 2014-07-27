
foreach_optional_arg:
		/* empty */						{ $$.op_type = IS_UNUSED; }
	|	T_DOUBLE_ARROW foreach_variable	{ $$ = $2; }
;

foreach_variable:
		variable			{ zend_check_writable_variable(&$1); $$ = $1; }
	|	'&' variable		{ zend_check_writable_variable(&$2); $$ = $2;  $$.EA |= ZEND_PARSED_REFERENCE_VARIABLE; }
	|	T_LIST '(' assignment_list ')' { zend_do_list_init(TSRMLS_C); $$ = $1; $$.EA = ZEND_PARSED_LIST_EXPR; }
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
		/* empty */			{ $$.op_type = IS_CONST;  Z_TYPE($$.u.constant) = IS_BOOL;  Z_LVAL($$.u.constant) = 1; }
	|	non_empty_for_expr	{ $$ = $1; }
;

non_empty_for_expr:
		non_empty_for_expr ','	expr { zend_do_free(&$1 TSRMLS_CC); $$ = $4; }
	|	expr					{ $$ = $1; }
;