
function_declaration_statement:
    unticked_function_declaration_statement { /* function_declaration_statement */ $$ = $1; }
;

unticked_function_declaration_statement:
  T_FUNCTION is_reference T_STRING '(' parameter_list ')' '{' 
    inner_statement_list 
  '}'                             { /* unticked_function_declaration_statement */ $$ = ['function', $3, $5, $8, false]; }
;

parameter_list:
    non_empty_parameter_list        { /* parameter_list */ $$ = $1; }
  | /* empty */                     { /* parameter_list */ $$ = []; }
;


non_empty_parameter_list:
    non_empty_parameter_list ',' optional_class_type is_reference const_variable '=' static_scalar              { /* non_empty_parameter_list */ $$ = $1, $1.push([$3, $5, $7]); }
  | non_empty_parameter_list ',' optional_class_type is_reference const_variable                                { /* non_empty_parameter_list */ $$ = $1, $1.push([$3, $5, false]); }
  | non_empty_parameter_list ',' is_reference const_variable '=' static_scalar                                  { /* non_empty_parameter_list */ $$ = $1, $1.push([false, $4, $6]); }
  | non_empty_parameter_list ',' is_reference const_variable                                                    { /* non_empty_parameter_list */ $$ = $1, $1.push([false, $4, false]); }
  | const_variable '=' static_scalar                                                                            { /* non_empty_parameter_list */ $$ = [[false, $1, $3]]; }
  | const_variable                                                                                              { /* non_empty_parameter_list */ $$ = [[false, $1, false]]; }
  | is_reference const_variable '=' static_scalar                                                               { /* non_empty_parameter_list */ $$ = [[false, $2, $4]]; }
  | is_reference const_variable                                                                                 { /* non_empty_parameter_list */ $$ = [[false, $2, false]]; }
  | optional_class_type is_reference const_variable '=' static_scalar                                           { /* non_empty_parameter_list */ $$ = [[$1, $3, $5]]; }
  | optional_class_type is_reference const_variable                                                             { /* non_empty_parameter_list */ $$ = [[$1, $3, false]]; }
;


function_call_parameter_list:
    '(' ')'                                           { /* function_call_parameter_list */ $$ = []; }
  | '(' non_empty_function_call_parameter_list ')'    { /* function_call_parameter_list */ $$ = $2; }
  | '(' yield_expr ')'                                { /* function_call_parameter_list */ $$ = $2; }
;


non_empty_function_call_parameter_list:
    non_empty_function_call_parameter_list ',' expr_without_variable      { /* non_empty_function_call_parameter_list */ $$ = $1; $1.push($3); }
  | non_empty_function_call_parameter_list ',' variable                   { /* non_empty_function_call_parameter_list */ $$ = $1; $1.push($3); }
  | non_empty_function_call_parameter_list ',' '&' variable               { /* non_empty_function_call_parameter_list */ $$ = $1; $1.push($4); }
  | expr_without_variable                                                 { /* non_empty_function_call_parameter_list */ $$ = [$1]; }
  | variable                                                              { /* non_empty_function_call_parameter_list */ $$ = [$1]; }
  | '&' variable                                                          { /* non_empty_function_call_parameter_list */ $$ = [$1]; }
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

function_call:
		namespace_name function_call_parameter_list
	|	T_NS_SEPARATOR namespace_name function_call_parameter_list
	|	class_name T_DOUBLE_COLON variable_name 	function_call_parameter_list
	|	class_name T_DOUBLE_COLON variable_without_objects function_call_parameter_list
	|	variable_class_name T_DOUBLE_COLON variable_name  function_call_parameter_list
	|	variable_class_name T_DOUBLE_COLON variable_without_objects  function_call_parameter_list
	|	variable_without_objects function_call_parameter_list
;