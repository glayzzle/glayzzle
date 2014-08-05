
elseif_list:
		/* empty */
	|	elseif_list T_ELSEIF parenthesis_expr statement
;


new_elseif_list:
		/* empty */
	|	new_elseif_list T_ELSEIF parenthesis_expr ':' inner_statement_list 
;


else_single:
		/* empty */
	|	T_ELSE statement
;


new_else_single:
		/* empty */
	|	T_ELSE ':' inner_statement_list
;
