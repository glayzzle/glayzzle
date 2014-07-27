
trait_use_statement:
		T_USE trait_list trait_adaptations
;

trait_list:
		fully_qualified_class_name						{ zend_do_use_trait(&$1 TSRMLS_CC); }
	|	trait_list ',' fully_qualified_class_name		{ zend_do_use_trait(&$3 TSRMLS_CC); }
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
	trait_method_reference_fully_qualified T_INSTEADOF trait_reference_list	{ zend_add_trait_precedence(&$1, &$3 TSRMLS_CC); }
;

trait_reference_list:
		fully_qualified_class_name									{ zend_resolve_class_name(&$1, ZEND_FETCH_CLASS_GLOBAL, 1 TSRMLS_CC); zend_init_list(&$$.u.op.ptr, Z_STRVAL($1.u.constant) TSRMLS_CC); }
	|	trait_reference_list ',' fully_qualified_class_name			{ zend_resolve_class_name(&$3, ZEND_FETCH_CLASS_GLOBAL, 1 TSRMLS_CC); zend_add_to_list(&$1.u.op.ptr, Z_STRVAL($3.u.constant) TSRMLS_CC); $$ = $1; }
;

trait_method_reference:
		T_STRING													{ zend_prepare_reference(&$$, NULL, &$1 TSRMLS_CC); }
	|	trait_method_reference_fully_qualified						{ $$ = $1; }
;

trait_method_reference_fully_qualified:
	fully_qualified_class_name T_PAAMAYIM_NEKUDOTAYIM T_STRING		{ zend_prepare_reference(&$$, &$1, &$3 TSRMLS_CC); }
;

trait_alias:
		trait_method_reference T_AS trait_modifiers T_STRING		{ zend_add_trait_alias(&$1, &$3, &$4 TSRMLS_CC); }
	|	trait_method_reference T_AS member_modifier					{ zend_add_trait_alias(&$1, &$3, NULL TSRMLS_CC); }
;

trait_modifiers:
		/* empty */					{ Z_LVAL($$.u.constant) = 0x0; } /* No change of methods visibility */
	|	member_modifier	{ $$ = $1; } /* REM: Keep in mind, there are not only visibility modifiers */
;
