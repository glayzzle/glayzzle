
inner_statement_list:
		inner_statement_list inner_statement { zend_do_extended_info(TSRMLS_C); HANDLE_INTERACTIVE(); }
	|	/* empty */
;


inner_statement:
		statement
	|	function_declaration_statement
	|	class_declaration_statement
	|	T_HALT_COMPILER '(' ')' ';'   { zend_error(E_COMPILE_ERROR, "__HALT_COMPILER() can only be used from the outermost scope"); }
;


statement:
		unticked_statement { DO_TICKS(); }
	|	T_STRING ':' { zend_do_label(&$1 TSRMLS_CC); }
;

unticked_statement:
		'{' inner_statement_list '}'
	|	T_IF parenthesis_expr statement elseif_list else_single { zend_do_if_cond(&$2, &$1 TSRMLS_CC); zend_do_if_after_statement(&$1, 1 TSRMLS_CC); zend_do_if_end(TSRMLS_C); }
	|	T_IF parenthesis_expr ':' inner_statement_list new_elseif_list new_else_single T_ENDIF ';' { zend_do_if_cond(&$2, &$1 TSRMLS_CC); zend_do_if_after_statement(&$1, 1 TSRMLS_CC); zend_do_if_end(TSRMLS_C); }
	|	T_WHILE parenthesis_expr while_statement { $1.u.op.opline_num = get_next_op_number(CG(active_op_array)); zend_do_while_cond(&$3, &$$ TSRMLS_CC); zend_do_while_end(&$1, &$4 TSRMLS_CC); }
	|	T_DO statement T_WHILE parenthesis_expr ';' { $1.u.op.opline_num = get_next_op_number(CG(active_op_array));  zend_do_do_while_begin(TSRMLS_C);  $4.u.op.opline_num = get_next_op_number(CG(active_op_array)); zend_do_do_while_end(&$1, &$4, &$6 TSRMLS_CC); }
	|	T_FOR '(' for_expr ';' for_expr ';' for_expr ')' for_statement { 
      zend_do_free(&$3 TSRMLS_CC); $4.u.op.opline_num = get_next_op_number(CG(active_op_array)); zend_do_extended_info(TSRMLS_C); zend_do_for_cond(&$6, &$7 TSRMLS_CC);  zend_do_free(&$9 TSRMLS_CC); zend_do_for_before_statement(&$4, &$7 TSRMLS_CC); 
      zend_do_for_end(&$7 TSRMLS_CC); 
    }
	|	T_SWITCH parenthesis_expr	switch_case_list { zend_do_switch_cond(&$2 TSRMLS_CC); zend_do_switch_end(&$4 TSRMLS_CC); }
	|	T_BREAK ';'				{ zend_do_brk_cont(ZEND_BRK, NULL TSRMLS_CC); }
	|	T_BREAK expr ';'		{ zend_do_brk_cont(ZEND_BRK, &$2 TSRMLS_CC); }
	|	T_CONTINUE ';'			{ zend_do_brk_cont(ZEND_CONT, NULL TSRMLS_CC); }
	|	T_CONTINUE expr ';'		{ zend_do_brk_cont(ZEND_CONT, &$2 TSRMLS_CC); }
	|	T_RETURN ';'						{ zend_do_return(NULL, 0 TSRMLS_CC); }
	|	T_RETURN expr_without_variable ';'	{ zend_do_return(&$2, 0 TSRMLS_CC); }
	|	T_RETURN variable ';'				{ zend_do_return(&$2, 1 TSRMLS_CC); }
	|	yield_expr ';' { zend_do_free(&$1 TSRMLS_CC); }
	|	T_GLOBAL global_var_list ';'
	|	T_STATIC static_var_list ';'
	|	T_ECHO echo_expr_list ';'
	|	T_INLINE_HTML			{ zend_do_echo(&$1 TSRMLS_CC); }
	|	expr ';'				{ zend_do_free(&$1 TSRMLS_CC); }
	|	T_UNSET '(' unset_variables ')' ';'
	|	T_FOREACH '(' variable T_AS foreach_variable foreach_optional_arg ')' foreach_statement { zend_do_foreach_end(&$1, &$4 TSRMLS_CC); }
	|	T_FOREACH 
    '(' expr_without_variable T_AS foreach_variable foreach_optional_arg ')'
    foreach_statement { zend_do_foreach_end(&$1, &$4 TSRMLS_CC); }
	|	T_DECLARE '(' declare_list ')' declare_statement { 
    $1.u.op.opline_num = get_next_op_number(CG(active_op_array)); 
    zend_do_declare_begin(TSRMLS_C); 
    zend_do_declare_end(&$1 TSRMLS_CC); }
	|	';'		/* empty statement */
	|	T_TRY '{' inner_statement_list '}' catch_statement finally_statement {
    zend_do_bind_catch(&$1, &$6 TSRMLS_CC);
    zend_do_try(&$1 TSRMLS_CC);
    zend_do_end_finally(&$1, &$6, &$8 TSRMLS_CC); 
  }
	|	T_THROW expr ';' { zend_do_throw(&$2 TSRMLS_CC); }
	|	T_GOTO T_STRING ';' { zend_do_goto(&$2 TSRMLS_CC); }
;


catch_statement:
				/* empty */ { $$.op_type = IS_UNUSED; }
	|	T_CATCH '(' fully_qualified_class_name 	T_VARIABLE ')' '{' inner_statement_list '}' additional_catches {
   zend_do_mark_last_catch(&$2, &$13 TSRMLS_CC); $$ = $1;
  }
;

finally_statement:
					/* empty */ { $$.op_type = IS_UNUSED; }
	|	T_FINALLY '{' inner_statement_list '}' { zend_do_finally(&$1 TSRMLS_CC);  $$ = $1; }
;

additional_catches:
		non_empty_additional_catches { $$ = $1; }
	|	/* empty */ { $$.u.op.opline_num = -1; }
;

non_empty_additional_catches:
		additional_catch { $$ = $1; }
	|	non_empty_additional_catches additional_catch { $$ = $2; }
;

additional_catch:
	T_CATCH '(' fully_qualified_class_name  T_VARIABLE ')'  '{' inner_statement_list '}'  { $$.u.op.opline_num = get_next_op_number(CG(active_op_array));  zend_do_begin_catch(&$1, &$3, &$5, NULL TSRMLS_CC); zend_do_end_catch(&$1 TSRMLS_CC); }
;

unset_variables:
		unset_variable
	|	unset_variables ',' unset_variable
;

unset_variable:
		variable	{ zend_do_end_variable_parse(&$1, BP_VAR_UNSET, 0 TSRMLS_CC); zend_do_unset(&$1 TSRMLS_CC); }
;


declare_statement:
		statement
	|	':' inner_statement_list T_ENDDECLARE ';'
;


declare_list:
		T_STRING '=' static_scalar					{ zend_do_declare_stmt(&$1, &$3 TSRMLS_CC); }
	|	declare_list ',' T_STRING '=' static_scalar	{ zend_do_declare_stmt(&$3, &$5 TSRMLS_CC); }
;


assignment_list:
		assignment_list ',' assignment_list_element
	|	assignment_list_element
;


assignment_list_element:
		variable								{ zend_do_add_list_element(&$1 TSRMLS_CC); }
	|	T_LIST '('  assignment_list ')'	{ zend_do_new_list_end(TSRMLS_C); }
	|	/* empty */							{ zend_do_add_list_element(NULL TSRMLS_CC); }
;
