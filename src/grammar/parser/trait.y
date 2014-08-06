
trait_use_statement:
		T_USE trait_list trait_adaptations
;

trait_list:
		fully_qualified_class_name
	|	trait_list ',' fully_qualified_class_name
;

trait_adaptations:
		';'
	|	'{' trait_adaptation_list '}'
;

trait_adaptation_list:
		/* empty */
	|	non_empty_trait_adaptation_list
;

non_empty_trait_adaptation_list:
		trait_adaptation_statement
	|	non_empty_trait_adaptation_list trait_adaptation_statement
;

trait_adaptation_statement:
		trait_precedence ';'
	|	trait_alias ';'
;

trait_precedence:
	trait_method_reference_fully_qualified T_INSTEADOF trait_reference_list
;

trait_reference_list:
		fully_qualified_class_name
	|	trait_reference_list ',' fully_qualified_class_name
;

trait_method_reference:
		T_STRING
	|	trait_method_reference_fully_qualified
;

trait_method_reference_fully_qualified:
	fully_qualified_class_name T_DOUBLE_COLON T_STRING
;

trait_alias:
		trait_method_reference T_AS trait_modifiers T_STRING
	|	trait_method_reference T_AS member_modifier
;

trait_modifiers:
		/* empty */
	|	member_modifier
;
