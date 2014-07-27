namespace_name:
		T_STRING { $$ = $1; }
	|	namespace_name T_NS_SEPARATOR T_STRING { zend_do_build_namespace_name(&$$, &$1, &$3 TSRMLS_CC); }
;

use_declarations:
		use_declarations ',' use_declaration
	|	use_declaration
;

use_declaration:
		namespace_name 			{ zend_do_use(&$1, NULL, 0 TSRMLS_CC); }
	|	namespace_name T_AS T_STRING	{ zend_do_use(&$1, &$3, 0 TSRMLS_CC); }
	|	T_NS_SEPARATOR namespace_name { zend_do_use(&$2, NULL, 1 TSRMLS_CC); }
	|	T_NS_SEPARATOR namespace_name T_AS T_STRING { zend_do_use(&$2, &$4, 1 TSRMLS_CC); }
;