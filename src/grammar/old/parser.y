%ebnf
%pure_parser
%expect 3
%start start

@import 'old/parser/def.y'

%% /* language grammar */

start:
  top_statement* { return $1 || []; }
;

top_statement:
    function_declaration_statement                        { /* top_statement : func */ $$ = $1; }
  | class_declaration_statement                           { /* top_statement : class */ $$ = $1; }
  | T_HALT_COMPILER '(' ')' ';'                           { YYACEPT }
  | ns_declaration                                        { /* top_statement : ns */ $$ = $2; }
  | T_USE use_declarations ';'                            { /* top_statement : use */ $$ = ['use', $2]; }
  | constant_declaration ';'                              { /* top_statement : const */ $$ = $1; }
  | statement                                             { /* top_statement : statement */ $$ = $1; }
;

@import 'old/parser/mixed.y'
@import 'old/parser/namespace.y'
@import 'old/parser/statements.y'
@import 'old/parser/expr.y'
@import 'old/parser/function.y'
@import 'old/parser/class.y'
@import 'old/parser/trait.y'
@import 'old/parser/if.y'
@import 'old/parser/switch.y'
@import 'old/parser/loops.y'
@import 'old/parser/array.y'
@import 'old/parser/scalar.y'
@import 'old/parser/variable.y'
