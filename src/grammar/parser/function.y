
function_declaration_statement:
		unticked_function_declaration_statement	{ DO_TICKS(); }
;

unticked_function_declaration_statement:
		function is_reference T_STRING 
		'(' parameter_list ')'
		'{' inner_statement_list '}' { zend_do_end_function_declaration(&$1 TSRMLS_CC); }
;

parameter_list:
		non_empty_parameter_list
	|	/* empty */
;


non_empty_parameter_list:
		optional_class_type T_VARIABLE				{ $$.op_type = IS_UNUSED; $$.u.op.num=1; zend_do_receive_arg(ZEND_RECV, &$2, &$$, NULL, &$1, 0 TSRMLS_CC); }
	|	optional_class_type '&' T_VARIABLE			{ $$.op_type = IS_UNUSED; $$.u.op.num=1; zend_do_receive_arg(ZEND_RECV, &$3, &$$, NULL, &$1, 1 TSRMLS_CC); }
	|	optional_class_type '&' T_VARIABLE '=' static_scalar			{ $$.op_type = IS_UNUSED; $$.u.op.num=1; zend_do_receive_arg(ZEND_RECV_INIT, &$3, &$$, &$5, &$1, 1 TSRMLS_CC); }
	|	optional_class_type T_VARIABLE '=' static_scalar				{ $$.op_type = IS_UNUSED; $$.u.op.num=1; zend_do_receive_arg(ZEND_RECV_INIT, &$2, &$$, &$4, &$1, 0 TSRMLS_CC); }
	|	non_empty_parameter_list ',' optional_class_type T_VARIABLE 	{ $$=$1; $$.u.op.num++; zend_do_receive_arg(ZEND_RECV, &$4, &$$, NULL, &$3, 0 TSRMLS_CC); }
	|	non_empty_parameter_list ',' optional_class_type '&' T_VARIABLE	{ $$=$1; $$.u.op.num++; zend_do_receive_arg(ZEND_RECV, &$5, &$$, NULL, &$3, 1 TSRMLS_CC); }
	|	non_empty_parameter_list ',' optional_class_type '&' T_VARIABLE	 '=' static_scalar { $$=$1; $$.u.op.num++; zend_do_receive_arg(ZEND_RECV_INIT, &$5, &$$, &$7, &$3, 1 TSRMLS_CC); }
	|	non_empty_parameter_list ',' optional_class_type T_VARIABLE '=' static_scalar 	{ $$=$1; $$.u.op.num++; zend_do_receive_arg(ZEND_RECV_INIT, &$4, &$$, &$6, &$3, 0 TSRMLS_CC); }
;


function_call_parameter_list:
		'(' ')'	{ Z_LVAL($$.u.constant) = 0; }
	|	'(' non_empty_function_call_parameter_list ')'	{ $$ = $2; }
	|	'(' yield_expr ')'	{ Z_LVAL($$.u.constant) = 1; zend_do_pass_param(&$2, ZEND_SEND_VAL, Z_LVAL($$.u.constant) TSRMLS_CC); }
;


non_empty_function_call_parameter_list:
		expr_without_variable	{ Z_LVAL($$.u.constant) = 1;  zend_do_pass_param(&$1, ZEND_SEND_VAL, Z_LVAL($$.u.constant) TSRMLS_CC); }
	|	variable				{ Z_LVAL($$.u.constant) = 1;  zend_do_pass_param(&$1, ZEND_SEND_VAR, Z_LVAL($$.u.constant) TSRMLS_CC); }
	|	'&' w_variable 				{ Z_LVAL($$.u.constant) = 1;  zend_do_pass_param(&$2, ZEND_SEND_REF, Z_LVAL($$.u.constant) TSRMLS_CC); }
	|	non_empty_function_call_parameter_list ',' expr_without_variable	{ Z_LVAL($$.u.constant)=Z_LVAL($1.u.constant)+1;  zend_do_pass_param(&$3, ZEND_SEND_VAL, Z_LVAL($$.u.constant) TSRMLS_CC); }
	|	non_empty_function_call_parameter_list ',' variable					{ Z_LVAL($$.u.constant)=Z_LVAL($1.u.constant)+1;  zend_do_pass_param(&$3, ZEND_SEND_VAR, Z_LVAL($$.u.constant) TSRMLS_CC); }
	|	non_empty_function_call_parameter_list ',' '&' w_variable			{ Z_LVAL($$.u.constant)=Z_LVAL($1.u.constant)+1;  zend_do_pass_param(&$4, ZEND_SEND_REF, Z_LVAL($$.u.constant) TSRMLS_CC); }
;


chaining_method_or_property:
		chaining_method_or_property variable_property 	{ $$.EA = $2.EA; }
	|	variable_property 								{ $$.EA = $1.EA; }
;

chaining_dereference:
		chaining_dereference '[' dim_offset ']'	{ fetch_array_dim(&$$, &$1, &$3 TSRMLS_CC); }
	| '[' dim_offset ']' { zend_do_pop_object(&$1 TSRMLS_CC); fetch_array_dim(&$$, &$1, &$2 TSRMLS_CC); }
;

chaining_instance_call:
		chaining_dereference 	chaining_method_or_property { $$ = $3; }
	|	chaining_dereference 		{ zend_do_push_object(&$1 TSRMLS_CC); $$ = $1; }
	|	chaining_method_or_property { $$ = $1; }
;

instance_call:
		/* empty */ 		{ $$ = $0; }
	|	chaining_instance_call { zend_do_push_object(&$0 TSRMLS_CC); zend_do_begin_variable_parse(TSRMLS_C); zend_do_pop_object(&$$ TSRMLS_CC); zend_do_end_variable_parse(&$2, BP_VAR_R, 0 TSRMLS_CC); }
;

function:
	T_FUNCTION { $$.u.op.opline_num = CG(zend_lineno); }
;


function_call:
		namespace_name function_call_parameter_list { zend_do_end_function_call(&$1, &$$, &$3, 0, $2.u.op.opline_num TSRMLS_CC); zend_do_extended_fcall_end(TSRMLS_C); }
	|	T_NAMESPACE T_NS_SEPARATOR namespace_name function_call_parameter_list { zend_do_end_function_call(&$1, &$$, &$5, 0, $4.u.op.opline_num TSRMLS_CC); zend_do_extended_fcall_end(TSRMLS_C); }
	|	T_NS_SEPARATOR namespace_name function_call_parameter_list { zend_do_end_function_call(&$2, &$$, &$4, 0, $3.u.op.opline_num TSRMLS_CC); zend_do_extended_fcall_end(TSRMLS_C); }
	|	class_name T_PAAMAYIM_NEKUDOTAYIM variable_name 	function_call_parameter_list { zend_do_end_function_call($4.u.op.opline_num?NULL:&$3, &$$, &$5, $4.u.op.opline_num, $4.u.op.opline_num TSRMLS_CC); zend_do_extended_fcall_end(TSRMLS_C);}
	|	class_name T_PAAMAYIM_NEKUDOTAYIM variable_without_objects function_call_parameter_list { zend_do_end_function_call(NULL, &$$, &$5, 1, 1 TSRMLS_CC); zend_do_extended_fcall_end(TSRMLS_C);}
	|	variable_class_name T_PAAMAYIM_NEKUDOTAYIM variable_name  function_call_parameter_list { zend_do_end_function_call(NULL, &$$, &$5, 1, 1 TSRMLS_CC); zend_do_extended_fcall_end(TSRMLS_C);}
	|	variable_class_name T_PAAMAYIM_NEKUDOTAYIM variable_without_objects  function_call_parameter_list { zend_do_end_function_call(NULL, &$$, &$5, 1, 1 TSRMLS_CC); zend_do_extended_fcall_end(TSRMLS_C);}
	|	variable_without_objects function_call_parameter_list { zend_do_end_function_call(&$1, &$$, &$3, 0, 1 TSRMLS_CC); zend_do_extended_fcall_end(TSRMLS_C);}
;