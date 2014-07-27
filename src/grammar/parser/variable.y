
r_variable:
	variable { zend_do_end_variable_parse(&$1, BP_VAR_R, 0 TSRMLS_CC); $$ = $1; }
;


w_variable:
	variable	{ zend_do_end_variable_parse(&$1, BP_VAR_W, 0 TSRMLS_CC); $$ = $1;
				  zend_check_writable_variable(&$1); }
;

rw_variable:
	variable	{ zend_do_end_variable_parse(&$1, BP_VAR_RW, 0 TSRMLS_CC); $$ = $1;
				  zend_check_writable_variable(&$1); }
;

variable:
		base_variable_with_function_calls T_OBJECT_OPERATOR 
			object_property  method_or_not variable_properties
			{ zend_do_pop_object(&$$ TSRMLS_CC); $$.EA = $1.EA | ($7.EA ? $7.EA : $6.EA); }
	|	base_variable_with_function_calls { $$ = $1; }
;

variable_properties:
		variable_properties variable_property { $$.EA = $2.EA; }
	|	/* empty */ { $$.EA = 0; }
;


variable_property:
		T_OBJECT_OPERATOR object_property method_or_not { $$.EA = $4.EA; }
;

variable_without_objects:
		reference_variable { $$ = $1; }
	|	simple_indirect_reference reference_variable { zend_do_indirect_references(&$$, &$1, &$2 TSRMLS_CC); }
;


variable_class_name:
		reference_variable { zend_do_end_variable_parse(&$1, BP_VAR_R, 0 TSRMLS_CC); $$=$1;; }
;

base_variable_with_function_calls:
		base_variable				{ $$ = $1; }
	|	array_function_dereference	{ $$ = $1; }
	|	function_call { zend_do_begin_variable_parse(TSRMLS_C); $$ = $1; $$.EA = ZEND_PARSED_FUNCTION_CALL; }
;


base_variable:
		reference_variable { $$ = $1; $$.EA = ZEND_PARSED_VARIABLE; }
	|	simple_indirect_reference reference_variable { zend_do_indirect_references(&$$, &$1, &$2 TSRMLS_CC); $$.EA = ZEND_PARSED_VARIABLE; }
	|	static_member { $$ = $1; $$.EA = ZEND_PARSED_STATIC_MEMBER; }
;

reference_variable:
		reference_variable '[' dim_offset ']' { fetch_array_dim(&$$, &$1, &$3 TSRMLS_CC); }
	|	reference_variable '{' expr '}'		{ fetch_string_offset(&$$, &$1, &$3 TSRMLS_CC); }
	|	compound_variable			{ zend_do_begin_variable_parse(TSRMLS_C); fetch_simple_variable(&$$, &$1, 1 TSRMLS_CC); }
;


compound_variable:
		T_VARIABLE			{ $$ = $1; }
	|	'$' '{' expr '}'	{ $$ = $3; }
;

variable_name:
		T_STRING		{ $$ = $1; }
	|	'{' expr '}'	{ $$ = $2; }
;

simple_indirect_reference:
		'$' { Z_LVAL($$.u.constant) = 1; }
	|	simple_indirect_reference '$' { Z_LVAL($$.u.constant)++; }
;


isset_variables:
		isset_variable			{ $$ = $1; }
	|	isset_variables ',' isset_variable { zend_do_boolean_and_end(&$$, &$1, &$4, &$2 TSRMLS_CC); }
;

isset_variable:
		variable				{ zend_do_isset_or_isempty(ZEND_ISSET, &$$, &$1 TSRMLS_CC); }
	|	expr_without_variable	{ zend_error(E_COMPILE_ERROR, "Cannot use isset() on the result of an expression (you can use \"null !== expression\" instead)"); }
;