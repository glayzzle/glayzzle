
elseif_list:
		/* empty */
	|	elseif_list T_ELSEIF parenthesis_expr statement { 
    zend_do_if_cond(&$3, &$2 TSRMLS_CC); 
    zend_do_if_after_statement(&$2, 0 TSRMLS_CC); 
  }
;


new_elseif_list:
		/* empty */
	|	new_elseif_list T_ELSEIF parenthesis_expr ':' inner_statement_list { 
    zend_do_if_cond(&$3, &$2 TSRMLS_CC);
    zend_do_if_after_statement(&$2, 0 TSRMLS_CC); 
  }
;


else_single:
		/* empty */
	|	T_ELSE statement
;


new_else_single:
		/* empty */
	|	T_ELSE ':' inner_statement_list
;
