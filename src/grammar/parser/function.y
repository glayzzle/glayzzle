
function_declaration_statement:
    unticked_function_declaration_statement { $$ = $1; }
;

unticked_function_declaration_statement:
  function is_reference T_STRING 
    '(' parameter_list ')'
    '{' 
      inner_statement_list 
    '}'                             { $$ = ['function', $3, $5, $8]; }
;

parameter_list:
		non_empty_parameter_list
	|	/* empty */
;


non_empty_parameter_list:
		optional_class_type T_VARIABLE                                                                          { $$ = [[$1, $2, false]]; }
	|	optional_class_type '&' T_VARIABLE                                                                      { $$ = [[$1, $3, false]]; }
	|	optional_class_type '&' T_VARIABLE '=' static_scalar                                                    { $$ = [[$1, $3, $5]]; }
	|	optional_class_type T_VARIABLE '=' static_scalar                                                        { $$ = [[$1, $2, $4]]; }
	|	non_empty_parameter_list ',' optional_class_type T_VARIABLE                                             { $$ = $1, $1.push([$3, $4, false]); }
	|	non_empty_parameter_list ',' optional_class_type '&' T_VARIABLE                                         { $$ = $1, $1.push([$3, $5, false]); }
	|	non_empty_parameter_list ',' optional_class_type '&' T_VARIABLE	 '=' static_scalar                      { $$ = $1, $1.push([$3, $5, $7]); }
	|	non_empty_parameter_list ',' optional_class_type T_VARIABLE '=' static_scalar                           { $$ = $1, $1.push([$3, $4, $6]); }
;


function_call_parameter_list:
    '(' ')'                                           { $$ = []; }
  | '(' non_empty_function_call_parameter_list ')'    { $$ = $2; }
  | '(' yield_expr ')'                                { $$ = $2; }
;


non_empty_function_call_parameter_list:
		expr_without_variable
	|	variable
	|	'&' w_variable
	|	non_empty_function_call_parameter_list ',' expr_without_variable
	|	non_empty_function_call_parameter_list ',' variable
	|	non_empty_function_call_parameter_list ',' '&' w_variable
;


chaining_method_or_property:
		chaining_method_or_property variable_property
	|	variable_property
;

chaining_dereference:
		chaining_dereference '[' dim_offset ']'
	| '[' dim_offset ']'
;

chaining_instance_call:
		chaining_dereference 	chaining_method_or_property
	|	chaining_dereference
	|	chaining_method_or_property
;

instance_call:
		/* empty */
	|	chaining_instance_call
;

function:
	T_FUNCTION
;


function_call:
		namespace_name function_call_parameter_list
	|	T_NAMESPACE T_NS_SEPARATOR namespace_name function_call_parameter_list
	|	T_NS_SEPARATOR namespace_name function_call_parameter_list
	|	class_name T_DOUBLE_COLON variable_name 	function_call_parameter_list
	|	class_name T_DOUBLE_COLON variable_without_objects function_call_parameter_list
	|	variable_class_name T_DOUBLE_COLON variable_name  function_call_parameter_list
	|	variable_class_name T_DOUBLE_COLON variable_without_objects  function_call_parameter_list
	|	variable_without_objects function_call_parameter_list
;