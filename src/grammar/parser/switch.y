
switch_case_list:
		'{' case_list '}'					{ $$ = $2; }
	|	'{' ';' case_list '}'				{ $$ = $3; }
	|	':' case_list T_ENDSWITCH ';'		{ $$ = $2; }
	|	':' ';' case_list T_ENDSWITCH ';'	{ $$ = $3; }
;


case_list:
		/* empty */	{ $$.op_type = IS_UNUSED; }
	|	case_list T_CASE expr case_separator inner_statement_list { 
  zend_do_extended_info(TSRMLS_C);  zend_do_case_before_statement(&$1, &$2, &$3 TSRMLS_CC); 
  zend_do_case_after_statement(&$$, &$2 TSRMLS_CC); $$.op_type = IS_CONST; }
	|	case_list T_DEFAULT case_separator inner_statement_list { 
  zend_do_extended_info(TSRMLS_C);  zend_do_default_before_statement(&$1, &$2 TSRMLS_CC);
  zend_do_case_after_statement(&$$, &$2 TSRMLS_CC); $$.op_type = IS_CONST; }
;


case_separator:
		':'
	|	';'
;

