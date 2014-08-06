
r_variable:
  variable      { $$ = $1; }
;


w_variable:
  variable      { $$ = $1; }
;

rw_variable:
  variable      { $$ = $1; }
;

variable:
  base_variable_with_function_calls T_OBJECT_OPERATOR 
  object_property  method_or_not variable_properties
  | base_variable_with_function_calls { $$ = $1; }
;

variable_properties:
		variable_properties variable_property
	|	/* empty */
;


variable_property:
		T_OBJECT_OPERATOR object_property method_or_not
;

variable_without_objects:
		reference_variable { $$ = $1; }
	|	simple_indirect_reference reference_variable
;


variable_class_name:
		reference_variable
;

base_variable_with_function_calls:
		base_variable
	|	array_function_dereference
	|	function_call
;


base_variable:
		reference_variable
	|	simple_indirect_reference reference_variable
	|	static_member
;

reference_variable:
		reference_variable '[' dim_offset ']'
	|	reference_variable '{' expr '}'
	|	compound_variable
;


compound_variable:
    T_VARIABLE        { $$ = ['var', $1]; }
  | '$' '{' expr '}'  { $$ = ['var', $3]; }
;

variable_name:
    T_STRING          { $$ = $1; }
  | '{' expr '}'      { $$ = $2; }
;

simple_indirect_reference:
		'$'
	|	simple_indirect_reference '$' 
;


isset_variables:
		isset_variable			{ $$ = $1; }
	|	isset_variables ',' isset_variable
;

isset_variable:
		variable
	|	expr_without_variable	{ zend_error(E_COMPILE_ERROR, "Cannot use isset() on the result of an expression (you can use \"null !== expression\" instead)"); }
;