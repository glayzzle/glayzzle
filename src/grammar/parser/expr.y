
expr_without_variable:
		T_LIST '('  assignment_list ')' '=' expr { zend_do_list_end(&$$, &$7 TSRMLS_CC); }
	|	variable '=' expr		{ zend_check_writable_variable(&$1); zend_do_assign(&$$, &$1, &$3 TSRMLS_CC); }
	|	variable '=' '&' variable { zend_check_writable_variable(&$1); zend_do_end_variable_parse(&$4, BP_VAR_W, 1 TSRMLS_CC); zend_do_end_variable_parse(&$1, BP_VAR_W, 0 TSRMLS_CC); zend_do_assign_ref(&$$, &$1, &$4 TSRMLS_CC); }
	|	variable '=' '&' T_NEW class_name_reference ctor_arguments { zend_error(E_DEPRECATED, "Assigning the return value of new by reference is deprecated");  zend_check_writable_variable(&$1); zend_do_extended_fcall_begin(TSRMLS_C); zend_do_begin_new_object(&$4, &$5 TSRMLS_CC); zend_do_end_new_object(&$3, &$4, &$7 TSRMLS_CC); zend_do_extended_fcall_end(TSRMLS_C); zend_do_end_variable_parse(&$1, BP_VAR_W, 0 TSRMLS_CC); $3.EA = ZEND_PARSED_NEW; zend_do_assign_ref(&$$, &$1, &$3 TSRMLS_CC); }
	|	T_CLONE expr { zend_do_clone(&$$, &$2 TSRMLS_CC); }
	|	variable T_PLUS_EQUAL expr 	{ zend_check_writable_variable(&$1); zend_do_end_variable_parse(&$1, BP_VAR_RW, 0 TSRMLS_CC); zend_do_binary_assign_op(ZEND_ASSIGN_ADD, &$$, &$1, &$3 TSRMLS_CC); }
	|	variable T_MINUS_EQUAL expr	{ zend_check_writable_variable(&$1); zend_do_end_variable_parse(&$1, BP_VAR_RW, 0 TSRMLS_CC); zend_do_binary_assign_op(ZEND_ASSIGN_SUB, &$$, &$1, &$3 TSRMLS_CC); }
	|	variable T_MUL_EQUAL expr		{ zend_check_writable_variable(&$1); zend_do_end_variable_parse(&$1, BP_VAR_RW, 0 TSRMLS_CC); zend_do_binary_assign_op(ZEND_ASSIGN_MUL, &$$, &$1, &$3 TSRMLS_CC); }
	|	variable T_DIV_EQUAL expr		{ zend_check_writable_variable(&$1); zend_do_end_variable_parse(&$1, BP_VAR_RW, 0 TSRMLS_CC); zend_do_binary_assign_op(ZEND_ASSIGN_DIV, &$$, &$1, &$3 TSRMLS_CC); }
	|	variable T_CONCAT_EQUAL expr	{ zend_check_writable_variable(&$1); zend_do_end_variable_parse(&$1, BP_VAR_RW, 0 TSRMLS_CC); zend_do_binary_assign_op(ZEND_ASSIGN_CONCAT, &$$, &$1, &$3 TSRMLS_CC); }
	|	variable T_MOD_EQUAL expr		{ zend_check_writable_variable(&$1); zend_do_end_variable_parse(&$1, BP_VAR_RW, 0 TSRMLS_CC); zend_do_binary_assign_op(ZEND_ASSIGN_MOD, &$$, &$1, &$3 TSRMLS_CC); }
	|	variable T_AND_EQUAL expr		{ zend_check_writable_variable(&$1); zend_do_end_variable_parse(&$1, BP_VAR_RW, 0 TSRMLS_CC); zend_do_binary_assign_op(ZEND_ASSIGN_BW_AND, &$$, &$1, &$3 TSRMLS_CC); }
	|	variable T_OR_EQUAL expr 		{ zend_check_writable_variable(&$1); zend_do_end_variable_parse(&$1, BP_VAR_RW, 0 TSRMLS_CC); zend_do_binary_assign_op(ZEND_ASSIGN_BW_OR, &$$, &$1, &$3 TSRMLS_CC); }
	|	variable T_XOR_EQUAL expr 		{ zend_check_writable_variable(&$1); zend_do_end_variable_parse(&$1, BP_VAR_RW, 0 TSRMLS_CC); zend_do_binary_assign_op(ZEND_ASSIGN_BW_XOR, &$$, &$1, &$3 TSRMLS_CC); }
	|	variable T_SL_EQUAL expr	{ zend_check_writable_variable(&$1); zend_do_end_variable_parse(&$1, BP_VAR_RW, 0 TSRMLS_CC); zend_do_binary_assign_op(ZEND_ASSIGN_SL, &$$, &$1, &$3 TSRMLS_CC); }
	|	variable T_SR_EQUAL expr	{ zend_check_writable_variable(&$1); zend_do_end_variable_parse(&$1, BP_VAR_RW, 0 TSRMLS_CC); zend_do_binary_assign_op(ZEND_ASSIGN_SR, &$$, &$1, &$3 TSRMLS_CC); }
	|	rw_variable T_INC { zend_do_post_incdec(&$$, &$1, ZEND_POST_INC TSRMLS_CC); }
	|	T_INC rw_variable { zend_do_pre_incdec(&$$, &$2, ZEND_PRE_INC TSRMLS_CC); }
	|	rw_variable T_DEC { zend_do_post_incdec(&$$, &$1, ZEND_POST_DEC TSRMLS_CC); }
	|	T_DEC rw_variable { zend_do_pre_incdec(&$$, &$2, ZEND_PRE_DEC TSRMLS_CC); }
	|	expr T_BOOLEAN_OR expr { zend_do_boolean_or_begin(&$1, &$2 TSRMLS_CC);  zend_do_boolean_or_end(&$$, &$1, &$4, &$2 TSRMLS_CC); }
	|	expr T_BOOLEAN_AND expr { zend_do_boolean_and_begin(&$1, &$2 TSRMLS_CC); zend_do_boolean_and_end(&$$, &$1, &$4, &$2 TSRMLS_CC); }
	|	expr T_LOGICAL_OR expr { zend_do_boolean_or_begin(&$1, &$2 TSRMLS_CC); zend_do_boolean_or_end(&$$, &$1, &$4, &$2 TSRMLS_CC); }
	|	expr T_LOGICAL_AND expr { zend_do_boolean_and_begin(&$1, &$2 TSRMLS_CC); zend_do_boolean_and_end(&$$, &$1, &$4, &$2 TSRMLS_CC); }
	|	expr T_LOGICAL_XOR expr { zend_do_binary_op(ZEND_BOOL_XOR, &$$, &$1, &$3 TSRMLS_CC); }
	|	expr '|' expr	{ zend_do_binary_op(ZEND_BW_OR, &$$, &$1, &$3 TSRMLS_CC); }
	|	expr '&' expr	{ zend_do_binary_op(ZEND_BW_AND, &$$, &$1, &$3 TSRMLS_CC); }
	|	expr '^' expr	{ zend_do_binary_op(ZEND_BW_XOR, &$$, &$1, &$3 TSRMLS_CC); }
	|	expr '.' expr 	{ zend_do_binary_op(ZEND_CONCAT, &$$, &$1, &$3 TSRMLS_CC); }
	|	expr '+' expr 	{ zend_do_binary_op(ZEND_ADD, &$$, &$1, &$3 TSRMLS_CC); }
	|	expr '-' expr 	{ zend_do_binary_op(ZEND_SUB, &$$, &$1, &$3 TSRMLS_CC); }
	|	expr '*' expr	{ zend_do_binary_op(ZEND_MUL, &$$, &$1, &$3 TSRMLS_CC); }
	|	expr '/' expr	{ zend_do_binary_op(ZEND_DIV, &$$, &$1, &$3 TSRMLS_CC); }
	|	expr '%' expr 	{ zend_do_binary_op(ZEND_MOD, &$$, &$1, &$3 TSRMLS_CC); }
	| 	expr T_SL expr	{ zend_do_binary_op(ZEND_SL, &$$, &$1, &$3 TSRMLS_CC); }
	|	expr T_SR expr	{ zend_do_binary_op(ZEND_SR, &$$, &$1, &$3 TSRMLS_CC); }
	|	'+' expr %prec T_INC { ZVAL_LONG(&$1.u.constant, 0); if ($2.op_type == IS_CONST) { add_function(&$2.u.constant, &$1.u.constant, &$2.u.constant TSRMLS_CC); $$ = $2; } else { $1.op_type = IS_CONST; INIT_PZVAL(&$1.u.constant); zend_do_binary_op(ZEND_ADD, &$$, &$1, &$2 TSRMLS_CC); } }
	|	'-' expr %prec T_INC { ZVAL_LONG(&$1.u.constant, 0); if ($2.op_type == IS_CONST) { sub_function(&$2.u.constant, &$1.u.constant, &$2.u.constant TSRMLS_CC); $$ = $2; } else { $1.op_type = IS_CONST; INIT_PZVAL(&$1.u.constant); zend_do_binary_op(ZEND_SUB, &$$, &$1, &$2 TSRMLS_CC); } }
	|	'!' expr { zend_do_unary_op(ZEND_BOOL_NOT, &$$, &$2 TSRMLS_CC); }
	|	'~' expr { zend_do_unary_op(ZEND_BW_NOT, &$$, &$2 TSRMLS_CC); }
	|	expr T_IS_IDENTICAL expr		{ zend_do_binary_op(ZEND_IS_IDENTICAL, &$$, &$1, &$3 TSRMLS_CC); }
	|	expr T_IS_NOT_IDENTICAL expr	{ zend_do_binary_op(ZEND_IS_NOT_IDENTICAL, &$$, &$1, &$3 TSRMLS_CC); }
	|	expr T_IS_EQUAL expr			{ zend_do_binary_op(ZEND_IS_EQUAL, &$$, &$1, &$3 TSRMLS_CC); }
	|	expr T_IS_NOT_EQUAL expr 		{ zend_do_binary_op(ZEND_IS_NOT_EQUAL, &$$, &$1, &$3 TSRMLS_CC); }
	|	expr '<' expr 					{ zend_do_binary_op(ZEND_IS_SMALLER, &$$, &$1, &$3 TSRMLS_CC); }
	|	expr T_IS_SMALLER_OR_EQUAL expr { zend_do_binary_op(ZEND_IS_SMALLER_OR_EQUAL, &$$, &$1, &$3 TSRMLS_CC); }
	|	expr '>' expr 					{ zend_do_binary_op(ZEND_IS_SMALLER, &$$, &$3, &$1 TSRMLS_CC); }
	|	expr T_IS_GREATER_OR_EQUAL expr { zend_do_binary_op(ZEND_IS_SMALLER_OR_EQUAL, &$$, &$3, &$1 TSRMLS_CC); }
	|	expr T_INSTANCEOF class_name_reference { zend_do_instanceof(&$$, &$1, &$3, 0 TSRMLS_CC); }
	|	parenthesis_expr 	{ $$ = $1; }
	|	new_expr		{ $$ = $1; }
	|	'(' new_expr ')' instance_call { $$ = $2;  $$ = $5; }
	|	expr '?' 
		expr ':' 
		expr	 { zend_do_qm_false(&$$, &$7, &$2, &$5 TSRMLS_CC); }
	|	expr '?' ':'
		expr     { zend_do_jmp_set_else(&$$, &$5, &$2, &$3 TSRMLS_CC); }
	|	internal_functions_in_yacc { $$ = $1; }
	|	T_INT_CAST expr 	{ zend_do_cast(&$$, &$2, IS_LONG TSRMLS_CC); }
	|	T_DOUBLE_CAST expr 	{ zend_do_cast(&$$, &$2, IS_DOUBLE TSRMLS_CC); }
	|	T_STRING_CAST expr	{ zend_do_cast(&$$, &$2, IS_STRING TSRMLS_CC); }
	|	T_ARRAY_CAST expr 	{ zend_do_cast(&$$, &$2, IS_ARRAY TSRMLS_CC); }
	|	T_OBJECT_CAST expr 	{ zend_do_cast(&$$, &$2, IS_OBJECT TSRMLS_CC); }
	|	T_BOOL_CAST expr	{ zend_do_cast(&$$, &$2, IS_BOOL TSRMLS_CC); }
	|	T_UNSET_CAST expr	{ zend_do_cast(&$$, &$2, IS_NULL TSRMLS_CC); }
	|	T_EXIT exit_expr	{ zend_do_exit(&$$, &$2 TSRMLS_CC); }
	|	'@' expr { zend_do_begin_silence(&$1 TSRMLS_CC); zend_do_end_silence(&$1 TSRMLS_CC); $$ = $3; }
	|	scalar				{ $$ = $1; }
	|	combined_scalar_offset { zend_do_end_variable_parse(&$1, BP_VAR_R, 0 TSRMLS_CC); }
	|	combined_scalar { $$ = $1; }
	|	'`' backticks_expr '`' { zend_do_shell_exec(&$$, &$2 TSRMLS_CC); }
	|	T_PRINT expr  { zend_do_print(&$$, &$2 TSRMLS_CC); }
	|	T_YIELD { zend_do_yield(&$$, NULL, NULL, 0 TSRMLS_CC); }
	|	function is_reference  '(' parameter_list ')' lexical_vars '{' inner_statement_list '}' { zend_do_end_function_declaration(&$1 TSRMLS_CC); $$ = $3; }
	|	T_STATIC function is_reference '(' parameter_list ')' lexical_vars '{' inner_statement_list '}' { zend_do_end_function_declaration(&$2 TSRMLS_CC); $$ = $4; }
;

yield_expr:
		T_YIELD expr_without_variable { zend_do_yield(&$$, &$2, NULL, 0 TSRMLS_CC); }
	|	T_YIELD variable { zend_do_yield(&$$, &$2, NULL, 1 TSRMLS_CC); }
	|	T_YIELD expr T_DOUBLE_ARROW expr_without_variable { zend_do_yield(&$$, &$4, &$2, 0 TSRMLS_CC); }
	|	T_YIELD expr T_DOUBLE_ARROW variable { zend_do_yield(&$$, &$4, &$2, 1 TSRMLS_CC); }
;

is_reference:
		/* empty */	{ $$.op_type = ZEND_RETURN_VAL; }
	|	'&'			{ $$.op_type = ZEND_RETURN_REF; }
;


global_var_list:
		global_var_list ',' global_var	{ zend_do_fetch_global_variable(&$3, NULL, ZEND_FETCH_GLOBAL_LOCK TSRMLS_CC); }
	|	global_var						{ zend_do_fetch_global_variable(&$1, NULL, ZEND_FETCH_GLOBAL_LOCK TSRMLS_CC); }
;


global_var:
		T_VARIABLE			{ $$ = $1; }
	|	'$' r_variable		{ $$ = $2; }
	|	'$' '{' expr '}'	{ $$ = $3; }
;


lexical_vars:
		/* empty */
	|	T_USE '(' lexical_var_list ')'
;

lexical_var_list:
		lexical_var_list ',' T_VARIABLE			{ zend_do_fetch_lexical_variable(&$3, 0 TSRMLS_CC); }
	|	lexical_var_list ',' '&' T_VARIABLE		{ zend_do_fetch_lexical_variable(&$4, 1 TSRMLS_CC); }
	|	T_VARIABLE								{ zend_do_fetch_lexical_variable(&$1, 0 TSRMLS_CC); }
	|	'&' T_VARIABLE							{ zend_do_fetch_lexical_variable(&$2, 1 TSRMLS_CC); }
;

static_var_list:
		static_var_list ',' T_VARIABLE { zend_do_fetch_static_variable(&$3, NULL, ZEND_FETCH_STATIC TSRMLS_CC); }
	|	static_var_list ',' T_VARIABLE '=' static_scalar { zend_do_fetch_static_variable(&$3, &$5, ZEND_FETCH_STATIC TSRMLS_CC); }
	|	T_VARIABLE  { zend_do_fetch_static_variable(&$1, NULL, ZEND_FETCH_STATIC TSRMLS_CC); }
	|	T_VARIABLE '=' static_scalar { zend_do_fetch_static_variable(&$1, &$3, ZEND_FETCH_STATIC TSRMLS_CC); }

;

echo_expr_list:
		echo_expr_list ',' expr { zend_do_echo(&$3 TSRMLS_CC); }
	|	expr					{ zend_do_echo(&$1 TSRMLS_CC); }
;


exit_expr:
		/* empty */	{ memset(&$$, 0, sizeof(znode)); $$.op_type = IS_UNUSED; }
	|	'(' ')'		{ memset(&$$, 0, sizeof(znode)); $$.op_type = IS_UNUSED; }
	|	parenthesis_expr	{ $$ = $1; }
;

backticks_expr:
		/* empty */	{ ZVAL_EMPTY_STRING(&$$.u.constant); INIT_PZVAL(&$$.u.constant); $$.op_type = IS_CONST; }
	|	T_ENCAPSED_AND_WHITESPACE	{ $$ = $1; }
	|	encaps_list	{ $$ = $1; }
;


expr:
		r_variable					{ $$ = $1; }
	|	expr_without_variable		{ $$ = $1; }
;

parenthesis_expr:
		'(' expr ')'		{ $$ = $2; }
	|	'(' yield_expr ')'	{ $$ = $2; }
;

