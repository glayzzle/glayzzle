optional_class_type:
		/* empty */
	|	T_ARRAY
	|	T_CALLABLE
	|	fully_qualified_class_name
;

class_declaration_statement:
  unticked_class_declaration_statement
;

unticked_class_declaration_statement:
  class_entry_type T_STRING extends_from implements_list
    '{'
      class_statement_list
    '}'
  | interface_entry T_STRING interface_extends_list
    '{'
      class_statement_list
    '}'
;

class_entry_type:
    T_CLASS
  | T_ABSTRACT T_CLASS
  | T_TRAIT
  | T_FINAL T_CLASS
;

extends_from:
    /* empty */
  | T_EXTENDS fully_qualified_class_name
;

interface_entry:
  T_INTERFACE
;

interface_extends_list:
    /* empty */
  | T_EXTENDS interface_list
;

implements_list:
		/* empty */
	|	T_IMPLEMENTS interface_list
;

interface_list:
		fully_qualified_class_name
	|	interface_list ',' fully_qualified_class_name
;


class_statement_list:
		class_statement_list class_statement
	|	/* empty */
;


class_statement:
		variable_modifiers class_variable_declaration ';' 
	|	class_constant_declaration ';'
	|	trait_use_statement
	|	method_modifiers function is_reference T_STRING  '(' parameter_list ')' 	method_body
;

method_body:
		';' /* abstract method */
	|	'{' inner_statement_list '}'
;

variable_modifiers:
		non_empty_member_modifiers
	|	T_VAR
;

method_modifiers:
		/* empty */
	|	non_empty_member_modifiers
;

non_empty_member_modifiers:
		member_modifier
	|	non_empty_member_modifiers member_modifier
;

member_modifier:
		T_PUBLIC
	|	T_PROTECTED
	|	T_PRIVATE
	|	T_STATIC
	|	T_ABSTRACT
	|	T_FINAL
;

class_variable_declaration:
		class_variable_declaration ',' T_VARIABLE
	|	class_variable_declaration ',' T_VARIABLE '=' static_scalar
	|	T_VARIABLE
	|	T_VARIABLE '=' static_scalar
;

class_constant_declaration:
		class_constant_declaration ',' T_STRING '=' static_scalar
	|	T_CONST T_STRING '=' static_scalar
;

new_expr:
		T_NEW class_name_reference ctor_arguments
;


class_name:
		T_STATIC
	|	namespace_name
	|	T_NAMESPACE T_NS_SEPARATOR namespace_name
	|	T_NS_SEPARATOR namespace_name
;

fully_qualified_class_name:
		namespace_name
	|	T_NAMESPACE T_NS_SEPARATOR namespace_name
	|	T_NS_SEPARATOR namespace_name
;



class_name_reference:
		class_name
	|	dynamic_class_name_reference
;


dynamic_class_name_reference:
		base_variable T_OBJECT_OPERATOR  object_property  dynamic_class_name_variable_properties
	|	base_variable { $$ = $1; }
;


dynamic_class_name_variable_properties:
		dynamic_class_name_variable_properties dynamic_class_name_variable_property
	|	/* empty */
;


dynamic_class_name_variable_property:
		T_OBJECT_OPERATOR object_property
;


ctor_arguments:
		/* empty */
	|	function_call_parameter_list
;


method:
		function_call_parameter_list
;

method_or_not:
		method
	|	array_method_dereference
	|	/* empty */
;


static_member:
		class_name T_DOUBLE_COLON variable_without_objects
	|	variable_class_name T_DOUBLE_COLON variable_without_objects

;


object_property:
		object_dim_list
	|	variable_without_objects
;

object_dim_list:
  object_dim_list '[' dim_offset ']'
	|	object_dim_list '{' expr '}'
	|	variable_name
;


class_constant:
		class_name T_DOUBLE_COLON T_STRING
	|	variable_class_name T_DOUBLE_COLON T_STRING
;

static_class_name_scalar:
	class_name T_DOUBLE_COLON T_CLASS
;

class_name_scalar:
	class_name T_DOUBLE_COLON T_CLASS
;
