
function_declaration_statement:
    unticked_function_declaration_statement { /* function_declaration_statement */ $$ = $1; }
;

unticked_function_declaration_statement:
  T_FUNCTION is_reference T_STRING '(' parameter_list ')' '{' 
    inner_statement* 
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
    '(' ')'                                                                                                     { /* function_call_parameter_list */ $$ = []; }
  | '(' non_empty_function_call_parameter_list ')'                                                              { /* function_call_parameter_list */ $$ = $2; }
  | '(' yield_expr ')'                                                                                          { /* function_call_parameter_list */ $$ = $2; }
;


non_empty_function_call_parameter_list:
    non_empty_function_call_parameter_list ',' expr                                                             { /* non_empty_function_call_parameter_list */ $$ = $1; $1.push($3); }
  | expr                                                                                                        { /* non_empty_function_call_parameter_list */ $$ = [$1]; }
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
    chaining_instance_call        { $$ = $1; }
  | /* empty */                   { $$ = false; }
;

function_call:
    T_NS_SEPARATOR namespace_name function_call_parameter_list                                                      { $$ = ['call', $2, $3]; }
  | namespace_name function_call_parameter_list                                                                     { $$ = ['call', $1, $2]; }
  | double_colon_expr variable_name function_call_parameter_list                                                    { $$ = ['call', ['offset', $1, $3], $4]; }
  | double_colon_expr variable_without_objects function_call_parameter_list                                         { $$ = ['call', ['offset', $1, $3], $4]; }
  | variable_without_objects function_call_parameter_list                                                           { $$ = ['call', $1, $2]; }
;

double_colon_expr: 
    reference_variable T_DOUBLE_COLON
  | class_name T_DOUBLE_COLON
;