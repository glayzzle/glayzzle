%ebnf
%pure_parser
%expect 3
%start start

@import 'parser/def.y'

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
