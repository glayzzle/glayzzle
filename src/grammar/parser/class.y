optional_class_type:
		/* empty */					{ $$.op_type = IS_UNUSED; }
	|	T_ARRAY						{ $$.op_type = IS_CONST; Z_TYPE($$.u.constant)=IS_ARRAY; }
	|	T_CALLABLE					{ $$.op_type = IS_CONST; Z_TYPE($$.u.constant)=IS_CALLABLE; }
	|	fully_qualified_class_name			{ $$ = $1; }
;

class_declaration_statement:
		unticked_class_declaration_statement	{ DO_TICKS(); }
;

unticked_class_declaration_statement:
		class_entry_type T_STRING extends_from implements_list
			'{'
				class_statement_list
			'}' { zend_do_end_class_declaration(&$1, &$3 TSRMLS_CC); }
	|	interface_entry T_STRING interface_extends_list
			'{'
				class_statement_list
			'}' { zend_do_end_class_declaration(&$1, NULL TSRMLS_CC); }
;

class_entry_type:
		T_CLASS			{ $$.u.op.opline_num = CG(zend_lineno); $$.EA = 0; }
	|	T_ABSTRACT T_CLASS { $$.u.op.opline_num = CG(zend_lineno); $$.EA = ZEND_ACC_EXPLICIT_ABSTRACT_CLASS; }
	|	T_TRAIT { $$.u.op.opline_num = CG(zend_lineno); $$.EA = ZEND_ACC_TRAIT; }
	|	T_FINAL T_CLASS { $$.u.op.opline_num = CG(zend_lineno); $$.EA = ZEND_ACC_FINAL_CLASS; }
;


extends_from:
		/* empty */					{ $$.op_type = IS_UNUSED; }
	|	T_EXTENDS fully_qualified_class_name	{ zend_do_fetch_class(&$$, &$2 TSRMLS_CC); }
;

interface_entry:
	T_INTERFACE		{ $$.u.op.opline_num = CG(zend_lineno); $$.EA = ZEND_ACC_INTERFACE; }
;

interface_extends_list:
		/* empty */
	|	T_EXTENDS interface_list
;

implements_list:
		/* empty */
	|	T_IMPLEMENTS interface_list
;

interface_list:
		fully_qualified_class_name			{ zend_do_implements_interface(&$1 TSRMLS_CC); }
	|	interface_list ',' fully_qualified_class_name { zend_do_implements_interface(&$3 TSRMLS_CC); }
;


class_statement_list:
		class_statement_list class_statement
	|	/* empty */
;


class_statement:
		variable_modifiers class_variable_declaration ';' { CG(access_type) = Z_LVAL($1.u.constant); }
	|	class_constant_declaration ';'
	|	trait_use_statement
	|	method_modifiers function is_reference T_STRING  '(' parameter_list ')' 	method_body { zend_do_abstract_method(&$4, &$1, &$9 TSRMLS_CC); zend_do_end_function_declaration(&$2 TSRMLS_CC); }
;

method_body:
		';' /* abstract method */		{ Z_LVAL($$.u.constant) = ZEND_ACC_ABSTRACT; }
	|	'{' inner_statement_list '}'	{ Z_LVAL($$.u.constant) = 0;	}
;

variable_modifiers:
		non_empty_member_modifiers		{ $$ = $1; }
	|	T_VAR							{ Z_LVAL($$.u.constant) = ZEND_ACC_PUBLIC; }
;

method_modifiers:
		/* empty */							{ Z_LVAL($$.u.constant) = ZEND_ACC_PUBLIC; }
	|	non_empty_member_modifiers			{ $$ = $1;  if (!(Z_LVAL($$.u.constant) & ZEND_ACC_PPP_MASK)) { Z_LVAL($$.u.constant) |= ZEND_ACC_PUBLIC; } }
;

non_empty_member_modifiers:
		member_modifier						{ $$ = $1; }
	|	non_empty_member_modifiers member_modifier	{ Z_LVAL($$.u.constant) = zend_do_verify_access_types(&$1, &$2); }
;

member_modifier:
		T_PUBLIC				{ Z_LVAL($$.u.constant) = ZEND_ACC_PUBLIC; }
	|	T_PROTECTED				{ Z_LVAL($$.u.constant) = ZEND_ACC_PROTECTED; }
	|	T_PRIVATE				{ Z_LVAL($$.u.constant) = ZEND_ACC_PRIVATE; }
	|	T_STATIC				{ Z_LVAL($$.u.constant) = ZEND_ACC_STATIC; }
	|	T_ABSTRACT				{ Z_LVAL($$.u.constant) = ZEND_ACC_ABSTRACT; }
	|	T_FINAL					{ Z_LVAL($$.u.constant) = ZEND_ACC_FINAL; }
;

class_variable_declaration:
		class_variable_declaration ',' T_VARIABLE					{ zend_do_declare_property(&$3, NULL, CG(access_type) TSRMLS_CC); }
	|	class_variable_declaration ',' T_VARIABLE '=' static_scalar	{ zend_do_declare_property(&$3, &$5, CG(access_type) TSRMLS_CC); }
	|	T_VARIABLE						{ zend_do_declare_property(&$1, NULL, CG(access_type) TSRMLS_CC); }
	|	T_VARIABLE '=' static_scalar	{ zend_do_declare_property(&$1, &$3, CG(access_type) TSRMLS_CC); }
;

class_constant_declaration:
		class_constant_declaration ',' T_STRING '=' static_scalar	{ zend_do_declare_class_constant(&$3, &$5 TSRMLS_CC); }
	|	T_CONST T_STRING '=' static_scalar	{ zend_do_declare_class_constant(&$2, &$4 TSRMLS_CC); }
;

new_expr:
		T_NEW class_name_reference ctor_arguments { zend_do_end_new_object(&$$, &$1, &$4 TSRMLS_CC); zend_do_extended_fcall_end(TSRMLS_C);}
;


class_name:
		T_STATIC { $$.op_type = IS_CONST; ZVAL_STRINGL(&$$.u.constant, "static", sizeof("static")-1, 1);}
	|	namespace_name { $$ = $1; }
	|	T_NAMESPACE T_NS_SEPARATOR namespace_name { $$.op_type = IS_CONST; ZVAL_EMPTY_STRING(&$$.u.constant);  zend_do_build_namespace_name(&$$, &$$, &$3 TSRMLS_CC); }
	|	T_NS_SEPARATOR namespace_name { char *tmp = estrndup(Z_STRVAL($2.u.constant), Z_STRLEN($2.u.constant)+1); memcpy(&(tmp[1]), Z_STRVAL($2.u.constant), Z_STRLEN($2.u.constant)+1); tmp[0] = '\\'; efree(Z_STRVAL($2.u.constant)); Z_STRVAL($2.u.constant) = tmp; ++Z_STRLEN($2.u.constant); $$ = $2; }
;

fully_qualified_class_name:
		namespace_name { $$ = $1; }
	|	T_NAMESPACE T_NS_SEPARATOR namespace_name { $$.op_type = IS_CONST; ZVAL_EMPTY_STRING(&$$.u.constant);  zend_do_build_namespace_name(&$$, &$$, &$3 TSRMLS_CC); }
	|	T_NS_SEPARATOR namespace_name { char *tmp = estrndup(Z_STRVAL($2.u.constant), Z_STRLEN($2.u.constant)+1); memcpy(&(tmp[1]), Z_STRVAL($2.u.constant), Z_STRLEN($2.u.constant)+1); tmp[0] = '\\'; efree(Z_STRVAL($2.u.constant)); Z_STRVAL($2.u.constant) = tmp; ++Z_STRLEN($2.u.constant); $$ = $2; }
;



class_name_reference:
		class_name						{ zend_do_fetch_class(&$$, &$1 TSRMLS_CC); }
	|	dynamic_class_name_reference	{ zend_do_end_variable_parse(&$1, BP_VAR_R, 0 TSRMLS_CC); zend_do_fetch_class(&$$, &$1 TSRMLS_CC); }
;


dynamic_class_name_reference:
		base_variable T_OBJECT_OPERATOR  object_property  dynamic_class_name_variable_properties { zend_do_pop_object(&$$ TSRMLS_CC); $$.EA = ZEND_PARSED_MEMBER; }
	|	base_variable { $$ = $1; }
;


dynamic_class_name_variable_properties:
		dynamic_class_name_variable_properties dynamic_class_name_variable_property
	|	/* empty */
;


dynamic_class_name_variable_property:
		T_OBJECT_OPERATOR object_property { zend_do_push_object(&$2 TSRMLS_CC); }
;


ctor_arguments:
		/* empty */	{ Z_LVAL($$.u.constant) = 0; }
	|	function_call_parameter_list 	{ $$ = $1; }
;


method:
		function_call_parameter_list { zend_do_end_function_call(&$1, &$$, &$2, 1, 1 TSRMLS_CC); zend_do_extended_fcall_end(TSRMLS_C); }
;

method_or_not:
		method						{ $$ = $1; $$.EA = ZEND_PARSED_METHOD_CALL; zend_do_push_object(&$$ TSRMLS_CC); }
	|	array_method_dereference	{ $$ = $1; zend_do_push_object(&$$ TSRMLS_CC); }
	|	/* empty */ { $$.EA = ZEND_PARSED_MEMBER; }
;


static_member:
		class_name T_PAAMAYIM_NEKUDOTAYIM variable_without_objects { $$ = $3; zend_do_fetch_static_member(&$$, &$1 TSRMLS_CC); }
	|	variable_class_name T_PAAMAYIM_NEKUDOTAYIM variable_without_objects { $$ = $3; zend_do_fetch_static_member(&$$, &$1 TSRMLS_CC); }

;


object_property:
		object_dim_list { $$ = $1; }
	|	variable_without_objects { zend_do_end_variable_parse(&$1, BP_VAR_R, 0 TSRMLS_CC);
  znode tmp_znode;  zend_do_pop_object(&tmp_znode TSRMLS_CC); 
  zend_do_fetch_property(&$$, &tmp_znode, &$1 TSRMLS_CC);
  }
;

object_dim_list:
  object_dim_list '[' dim_offset ']' { fetch_array_dim(&$$, &$1, &$3 TSRMLS_CC); }
	|	object_dim_list '{' expr '}'		{ fetch_string_offset(&$$, &$1, &$3 TSRMLS_CC); }
	|	variable_name { znode tmp_znode;  zend_do_pop_object(&tmp_znode TSRMLS_CC);  zend_do_fetch_property(&$$, &tmp_znode, &$1 TSRMLS_CC);}
;


class_constant:
		class_name T_PAAMAYIM_NEKUDOTAYIM T_STRING { zend_do_fetch_constant(&$$, &$1, &$3, ZEND_RT, 0 TSRMLS_CC); }
	|	variable_class_name T_PAAMAYIM_NEKUDOTAYIM T_STRING { zend_do_fetch_constant(&$$, &$1, &$3, ZEND_RT, 0 TSRMLS_CC); }
;

static_class_name_scalar:
	class_name T_PAAMAYIM_NEKUDOTAYIM T_CLASS { zend_do_resolve_class_name(&$$, &$1, 1 TSRMLS_CC); }
;

class_name_scalar:
	class_name T_PAAMAYIM_NEKUDOTAYIM T_CLASS { zend_do_resolve_class_name(&$$, &$1, 0 TSRMLS_CC); }
;
