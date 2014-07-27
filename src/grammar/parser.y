

%pure_parser
%expect 3
%start start

@import 'parser/def.y'

%% /* language grammar */

start:
  top_statement_list	{ zend_do_end_compilation(TSRMLS_C); }
;

top_statement_list:
    top_statement_list top_statement { zend_do_extended_info(TSRMLS_C); HANDLE_INTERACTIVE(); } 
  | /* empty */
;

top_statement:
		statement						{ zend_verify_namespace(TSRMLS_C); }
	|	function_declaration_statement	{ zend_verify_namespace(TSRMLS_C); zend_do_early_binding(TSRMLS_C); }
	|	class_declaration_statement		{ zend_verify_namespace(TSRMLS_C); zend_do_early_binding(TSRMLS_C); }
	|	T_HALT_COMPILER '(' ')' ';'		{ zend_do_halt_compiler_register(TSRMLS_C); YYACCEPT; }
	|	T_NAMESPACE namespace_name ';'	{ zend_do_begin_namespace(&$2, 0 TSRMLS_CC); }
	|	T_NAMESPACE namespace_name '{' top_statement_list '}' 	{ zend_do_begin_namespace(&$2, 1 TSRMLS_CC); zend_do_end_namespace(TSRMLS_C); }
	|	T_NAMESPACE '{' top_statement_list '}'				{ zend_do_begin_namespace(NULL, 1 TSRMLS_CC); zend_do_end_namespace(TSRMLS_C); }
	|	T_USE use_declarations ';'      { zend_verify_namespace(TSRMLS_C); }
	|	constant_declaration ';'		{ zend_verify_namespace(TSRMLS_C); }
;

@import 'parser/mixed.y'
@import 'parser/namespace.y'
@import 'parser/statements.y'
@import 'parser/expr.y'
@import 'parser/function.y'
@import 'parser/class.y'
@import 'parser/trait.y'
@import 'parser/if.y'
@import 'parser/switch.y'
@import 'parser/loops.y'
@import 'parser/array.y'
@import 'parser/scalar.y'
@import 'parser/variable.y'
