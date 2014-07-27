combined_scalar_offset:
	  combined_scalar '[' dim_offset ']' { zend_do_begin_variable_parse(TSRMLS_C); fetch_array_dim(&$$, &$1, &$3 TSRMLS_CC); }
	| combined_scalar_offset '[' dim_offset ']' { fetch_array_dim(&$$, &$1, &$3 TSRMLS_CC); }
    | T_CONSTANT_ENCAPSED_STRING '[' dim_offset ']' { $1.EA = 0; zend_do_begin_variable_parse(TSRMLS_C); fetch_array_dim(&$$, &$1, &$3 TSRMLS_CC); }
;

combined_scalar:
      T_ARRAY '(' array_pair_list ')' { $$ = $3; }
    | '[' array_pair_list ']' { $$ = $2; }
;

common_scalar:
		T_LNUMBER 					{ $$ = $1; }
	|	T_DNUMBER 					{ $$ = $1; }
	|	T_CONSTANT_ENCAPSED_STRING	{ $$ = $1; }
	|	T_LINE 						{ $$ = $1; }
	|	T_FILE 						{ $$ = $1; }
	|	T_DIR   					{ $$ = $1; }
	|	T_TRAIT_C					{ $$ = $1; }
	|	T_METHOD_C					{ $$ = $1; }
	|	T_FUNC_C					{ $$ = $1; }
	|	T_NS_C						{ $$ = $1; }
	|	T_START_HEREDOC T_ENCAPSED_AND_WHITESPACE T_END_HEREDOC { $$ = $2; }
	|	T_START_HEREDOC T_END_HEREDOC { ZVAL_EMPTY_STRING(&$$.u.constant); INIT_PZVAL(&$$.u.constant); $$.op_type = IS_CONST; }
;


static_scalar: /* compile-time evaluated scalars */
		common_scalar		{ $$ = $1; }
	|	static_class_name_scalar	{ $$ = $1; }
	|	namespace_name 		{ zend_do_fetch_constant(&$$, NULL, &$1, ZEND_CT, 1 TSRMLS_CC); }
	|	T_NAMESPACE T_NS_SEPARATOR namespace_name { $$.op_type = IS_CONST; ZVAL_EMPTY_STRING(&$$.u.constant);  zend_do_build_namespace_name(&$$, &$$, &$3 TSRMLS_CC); $3 = $$; zend_do_fetch_constant(&$$, NULL, &$3, ZEND_CT, 0 TSRMLS_CC); }
	|	T_NS_SEPARATOR namespace_name { char *tmp = estrndup(Z_STRVAL($2.u.constant), Z_STRLEN($2.u.constant)+1); memcpy(&(tmp[1]), Z_STRVAL($2.u.constant), Z_STRLEN($2.u.constant)+1); tmp[0] = '\\'; efree(Z_STRVAL($2.u.constant)); Z_STRVAL($2.u.constant) = tmp; ++Z_STRLEN($2.u.constant); zend_do_fetch_constant(&$$, NULL, &$2, ZEND_CT, 0 TSRMLS_CC); }
	|	'+' static_scalar { ZVAL_LONG(&$1.u.constant, 0); add_function(&$2.u.constant, &$1.u.constant, &$2.u.constant TSRMLS_CC); $$ = $2; }
	|	'-' static_scalar { ZVAL_LONG(&$1.u.constant, 0); sub_function(&$2.u.constant, &$1.u.constant, &$2.u.constant TSRMLS_CC); $$ = $2; }
	|	T_ARRAY '(' static_array_pair_list ')' { $$ = $3; Z_TYPE($$.u.constant) = IS_CONSTANT_ARRAY; }
	|	'[' static_array_pair_list ']' { $$ = $2; Z_TYPE($$.u.constant) = IS_CONSTANT_ARRAY; }
	|	static_class_constant { $$ = $1; }
	|	T_CLASS_C			{ $$ = $1; }
;

static_class_constant:
		class_name T_PAAMAYIM_NEKUDOTAYIM T_STRING { zend_do_fetch_constant(&$$, &$1, &$3, ZEND_CT, 0 TSRMLS_CC); }
;

scalar:
		T_STRING_VARNAME		{ $$ = $1; }
	|	class_name_scalar	{ $$ = $1; }
	|	class_constant		{ $$ = $1; }
	|	namespace_name	{ zend_do_fetch_constant(&$$, NULL, &$1, ZEND_RT, 1 TSRMLS_CC); }
	|	T_NAMESPACE T_NS_SEPARATOR namespace_name { $$.op_type = IS_CONST; ZVAL_EMPTY_STRING(&$$.u.constant);  zend_do_build_namespace_name(&$$, &$$, &$3 TSRMLS_CC); $3 = $$; zend_do_fetch_constant(&$$, NULL, &$3, ZEND_RT, 0 TSRMLS_CC); }
	|	T_NS_SEPARATOR namespace_name { char *tmp = estrndup(Z_STRVAL($2.u.constant), Z_STRLEN($2.u.constant)+1); memcpy(&(tmp[1]), Z_STRVAL($2.u.constant), Z_STRLEN($2.u.constant)+1); tmp[0] = '\\'; efree(Z_STRVAL($2.u.constant)); Z_STRVAL($2.u.constant) = tmp; ++Z_STRLEN($2.u.constant); zend_do_fetch_constant(&$$, NULL, &$2, ZEND_RT, 0 TSRMLS_CC); }
	|	common_scalar			{ $$ = $1; }
	|	'"' encaps_list '"' 	{ $$ = $2; }
	|	T_START_HEREDOC encaps_list T_END_HEREDOC { $$ = $2; }
	|	T_CLASS_C				{ if (Z_TYPE($1.u.constant) == IS_CONSTANT) {zend_do_fetch_constant(&$$, NULL, &$1, ZEND_RT, 1 TSRMLS_CC);} else {$$ = $1;} }
;
