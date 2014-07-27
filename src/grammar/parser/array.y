static_array_pair_list:
		/* empty */ { $$.op_type = IS_CONST; INIT_PZVAL(&$$.u.constant); array_init(&$$.u.constant); }
	|	non_empty_static_array_pair_list possible_comma	{ $$ = $1; }
;

possible_comma:
		/* empty */
	|	','
;

non_empty_static_array_pair_list:
		non_empty_static_array_pair_list ',' static_scalar T_DOUBLE_ARROW static_scalar	{ zend_do_add_static_array_element(&$$, &$3, &$5); }
	|	non_empty_static_array_pair_list ',' static_scalar { zend_do_add_static_array_element(&$$, NULL, &$3); }
	|	static_scalar T_DOUBLE_ARROW static_scalar { $$.op_type = IS_CONST; INIT_PZVAL(&$$.u.constant); array_init(&$$.u.constant); zend_do_add_static_array_element(&$$, &$1, &$3); }
	|	static_scalar { $$.op_type = IS_CONST; INIT_PZVAL(&$$.u.constant); array_init(&$$.u.constant); zend_do_add_static_array_element(&$$, NULL, &$1); }
;


array_method_dereference:
		array_method_dereference '[' dim_offset ']' { fetch_array_dim(&$$, &$1, &$3 TSRMLS_CC); }
	|	method '[' dim_offset ']' { $1.EA = ZEND_PARSED_METHOD_CALL; fetch_array_dim(&$$, &$1, &$3 TSRMLS_CC); }
;


array_function_dereference:
		array_function_dereference '[' dim_offset ']' { fetch_array_dim(&$$, &$1, &$3 TSRMLS_CC); }
	|	function_call '[' dim_offset ']' { 
    zend_do_begin_variable_parse(TSRMLS_C); $1.EA = ZEND_PARSED_FUNCTION_CALL; 
    fetch_array_dim(&$$, &$1, &$4 TSRMLS_CC); }
;

dim_offset:
		/* empty */		{ $$.op_type = IS_UNUSED; }
	|	expr			{ $$ = $1; }
;


array_pair_list:
		/* empty */ { zend_do_init_array(&$$, NULL, NULL, 0 TSRMLS_CC); }
	|	non_empty_array_pair_list possible_comma	{ $$ = $1; }
;

non_empty_array_pair_list:
		non_empty_array_pair_list ',' expr T_DOUBLE_ARROW expr	{ zend_do_add_array_element(&$$, &$5, &$3, 0 TSRMLS_CC); }
	|	non_empty_array_pair_list ',' expr			{ zend_do_add_array_element(&$$, &$3, NULL, 0 TSRMLS_CC); }
	|	expr T_DOUBLE_ARROW expr	{ zend_do_init_array(&$$, &$3, &$1, 0 TSRMLS_CC); }
	|	expr 				{ zend_do_init_array(&$$, &$1, NULL, 0 TSRMLS_CC); }
	|	non_empty_array_pair_list ',' expr T_DOUBLE_ARROW '&' w_variable { zend_do_add_array_element(&$$, &$6, &$3, 1 TSRMLS_CC); }
	|	non_empty_array_pair_list ',' '&' w_variable { zend_do_add_array_element(&$$, &$4, NULL, 1 TSRMLS_CC); }
	|	expr T_DOUBLE_ARROW '&' w_variable	{ zend_do_init_array(&$$, &$4, &$1, 1 TSRMLS_CC); }
	|	'&' w_variable 			{ zend_do_init_array(&$$, &$2, NULL, 1 TSRMLS_CC); }
;