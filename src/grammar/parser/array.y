static_array_pair_list:
		/* empty */
	|	non_empty_static_array_pair_list possible_comma	{ $$ = $1; }
;

possible_comma:
		/* empty */
	|	','
;

non_empty_static_array_pair_list:
		non_empty_static_array_pair_list ',' static_scalar T_DOUBLE_ARROW static_scalar
	|	non_empty_static_array_pair_list ',' static_scalar
	|	static_scalar T_DOUBLE_ARROW static_scalar
	|	static_scalar
;


array_method_dereference:
		array_method_dereference '[' dim_offset ']'
	|	method '[' dim_offset ']'
;


array_function_dereference:
		array_function_dereference '[' dim_offset ']'
	|	function_call '[' dim_offset ']'
;

dim_offset:
		/* empty */
	|	expr			{ $$ = $1; }
;


array_pair_list:
		/* empty */
	|	non_empty_array_pair_list possible_comma	{ $$ = $1; }
;

non_empty_array_pair_list:
		non_empty_array_pair_list ',' expr T_DOUBLE_ARROW expr
	|	non_empty_array_pair_list ',' expr
	|	expr T_DOUBLE_ARROW expr
	|	expr
	|	non_empty_array_pair_list ',' expr T_DOUBLE_ARROW '&' w_variable
	|	non_empty_array_pair_list ',' '&' w_variable
	|	expr T_DOUBLE_ARROW '&' w_variable
	|	'&' w_variable
;