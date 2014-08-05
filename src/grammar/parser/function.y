
function_declaration_statement:
    unticked_function_declaration_statement { $$ = $1; }
;

unticked_function_declaration_statement:
  function is_reference T_STRING 
    '(' parameter_list ')'
    '{' 
      inner_statement_list 
    '}'                             { /* @todo */
    $$ = {
      type: 'function.T_DECLARE',
      name: $3,
      parameters: $5,
      body: $8
    };
  }
;

parameter_list:
		non_empty_parameter_list
	|	/* empty */
;


non_empty_parameter_list:
		optional_class_type T_VARIABLE
	|	optional_class_type '&' T_VARIABLE
	|	optional_class_type '&' T_VARIABLE '=' static_scalar
	|	optional_class_type T_VARIABLE '=' static_scalar
	|	non_empty_parameter_list ',' optional_class_type T_VARIABLE
	|	non_empty_parameter_list ',' optional_class_type '&' T_VARIABLE
	|	non_empty_parameter_list ',' optional_class_type '&' T_VARIABLE	 '=' static_scalar 
	|	non_empty_parameter_list ',' optional_class_type T_VARIABLE '=' static_scalar
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
	|	class_name T_PAAMAYIM_NEKUDOTAYIM variable_name 	function_call_parameter_list
	|	class_name T_PAAMAYIM_NEKUDOTAYIM variable_without_objects function_call_parameter_list
	|	variable_class_name T_PAAMAYIM_NEKUDOTAYIM variable_name  function_call_parameter_list
	|	variable_class_name T_PAAMAYIM_NEKUDOTAYIM variable_without_objects  function_call_parameter_list
	|	variable_without_objects function_call_parameter_list
;