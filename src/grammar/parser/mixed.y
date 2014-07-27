constant_declaration:
		constant_declaration ',' T_STRING '=' static_scalar	{ zend_do_declare_constant(&$3, &$5 TSRMLS_CC); }
	|	T_CONST T_STRING '=' static_scalar { zend_do_declare_constant(&$2, &$4 TSRMLS_CC); }
;


encaps_list:
		encaps_list encaps_var { zend_do_end_variable_parse(&$2, BP_VAR_R, 0 TSRMLS_CC);  zend_do_add_variable(&$$, &$1, &$2 TSRMLS_CC); }
	|	encaps_list T_ENCAPSED_AND_WHITESPACE	{ zend_do_add_string(&$$, &$1, &$2 TSRMLS_CC); }
	|	encaps_var { zend_do_end_variable_parse(&$1, BP_VAR_R, 0 TSRMLS_CC); zend_do_add_variable(&$$, NULL, &$1 TSRMLS_CC); }
	|	T_ENCAPSED_AND_WHITESPACE encaps_var	{ zend_do_add_string(&$$, NULL, &$1 TSRMLS_CC); zend_do_end_variable_parse(&$2, BP_VAR_R, 0 TSRMLS_CC); zend_do_add_variable(&$$, &$$, &$2 TSRMLS_CC); }
;



encaps_var:
		T_VARIABLE { zend_do_begin_variable_parse(TSRMLS_C); fetch_simple_variable(&$$, &$1, 1 TSRMLS_CC); }
	|	T_VARIABLE '[' encaps_var_offset ']' { zend_do_begin_variable_parse(TSRMLS_C);  fetch_array_begin(&$$, &$1, &$4 TSRMLS_CC); }
	|	T_VARIABLE T_OBJECT_OPERATOR T_STRING { zend_do_begin_variable_parse(TSRMLS_C); fetch_simple_variable(&$2, &$1, 1 TSRMLS_CC); zend_do_fetch_property(&$$, &$2, &$3 TSRMLS_CC); }
	|	T_DOLLAR_OPEN_CURLY_BRACES expr '}' { zend_do_begin_variable_parse(TSRMLS_C);  fetch_simple_variable(&$$, &$2, 1 TSRMLS_CC); }
	|	T_DOLLAR_OPEN_CURLY_BRACES T_STRING_VARNAME '[' expr ']' '}' { zend_do_begin_variable_parse(TSRMLS_C);  fetch_array_begin(&$$, &$2, &$4 TSRMLS_CC); }
	|	T_CURLY_OPEN variable '}' { $$ = $2; }
;


encaps_var_offset:
		T_STRING		{ $$ = $1; }
	|	T_NUM_STRING	{ $$ = $1; }
	|	T_VARIABLE		{ fetch_simple_variable(&$$, &$1, 1 TSRMLS_CC); }
;


internal_functions_in_yacc:
		T_ISSET '(' isset_variables ')' { $$ = $3; }
	|	T_EMPTY '(' variable ')'	{ zend_do_isset_or_isempty(ZEND_ISEMPTY, &$$, &$3 TSRMLS_CC); }
	|	T_EMPTY '(' expr_without_variable ')' { zend_do_unary_op(ZEND_BOOL_NOT, &$$, &$3 TSRMLS_CC); }
	|	T_INCLUDE expr 			{ zend_do_include_or_eval(ZEND_INCLUDE, &$$, &$2 TSRMLS_CC); }
	|	T_INCLUDE_ONCE expr 	{ zend_do_include_or_eval(ZEND_INCLUDE_ONCE, &$$, &$2 TSRMLS_CC); }
	|	T_EVAL '(' expr ')' 	{ zend_do_include_or_eval(ZEND_EVAL, &$$, &$3 TSRMLS_CC); }
	|	T_REQUIRE expr			{ zend_do_include_or_eval(ZEND_REQUIRE, &$$, &$2 TSRMLS_CC); }
	|	T_REQUIRE_ONCE expr		{ zend_do_include_or_eval(ZEND_REQUIRE_ONCE, &$$, &$2 TSRMLS_CC); }
;