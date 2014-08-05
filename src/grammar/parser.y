%pure_parser
%expect 3
%start start

@import 'parser/def.y'

%% /* language grammar */

start:
  top_statement_list 
;

top_statement_list:
    top_statement_list top_statement
  | /* empty */
;

top_statement:
    statement
  | function_declaration_statement
  | class_declaration_statement 
  | T_HALT_COMPILER '(' ')' ';'     { YYACCEPT; }
  | T_NAMESPACE namespace_name ';' top_statement_list { 
    $$ = {
       type: 'internal.T_NAMESPACE',
       name: $2,
       body: $4
    }; 
  }
  | T_NAMESPACE namespace_name '{' top_statement_list '}' { 
    $$ = {
       type: 'internal.T_NAMESPACE',
       name: $2,
       body: $4
    }; 
  }
  | T_NAMESPACE '{' top_statement_list '}' {
    $$ = {
       type: 'internal.T_NAMESPACE',
       name: '/',
       body: $3
    }; 
  }
  | T_USE use_declarations ';' { $$ = { type: 'internal.T_USE', items: $2 }; }
  | constant_declaration ';'
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
