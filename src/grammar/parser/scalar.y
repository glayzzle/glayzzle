combined_scalar_offset:
    combined_scalar '[' dim_offset ']'
  | combined_scalar_offset '[' dim_offset ']'
  | T_CONSTANT_ENCAPSED_STRING '[' dim_offset ']'
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
	|	T_START_HEREDOC T_END_HEREDOC 
;


static_scalar: /* compile-time evaluated scalars */
		common_scalar		{ $$ = $1; }
	|	static_class_name_scalar	{ $$ = $1; }
	|	namespace_name 		
	|	T_NAMESPACE T_NS_SEPARATOR namespace_name 
	|	T_NS_SEPARATOR namespace_name 
	|	'+' static_scalar 
	|	'-' static_scalar 
	|	T_ARRAY '(' static_array_pair_list ')'
	|	'[' static_array_pair_list ']'
	|	static_class_constant 
	|	T_CLASS_C
;

static_class_constant:
		class_name T_PAAMAYIM_NEKUDOTAYIM T_STRING
;

scalar:
		T_STRING_VARNAME		{ $$ = $1; }
	|	class_name_scalar	{ $$ = $1; }
	|	class_constant		{ $$ = $1; }
	|	namespace_name
	|	T_NAMESPACE T_NS_SEPARATOR namespace_name
	|	T_NS_SEPARATOR namespace_name
	|	common_scalar
	|	'"' encaps_list '"'
	|	T_START_HEREDOC encaps_list T_END_HEREDOC
	|	T_CLASS_C
;
