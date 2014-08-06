%pure_parser
%expect 3
%start start

@import 'parser/def.y'

%% /* language grammar */

start:
  T_EOF { return []; }
  | top_statement_list T_EOF { return $1 || []; }
;

top_statement_list:
    top_statement                     { $$ = [$1]; }
  | top_statement_list top_statement  { $$ = $1; $1.push($2); }
;

top_statement:
    statement                       { $$ = $1; }
  | function_declaration_statement  { $$ = $1; }
  | class_declaration_statement     { $$ = $1; }
  | T_HALT_COMPILER '(' ')' ';'     { YYACEPT }
  | T_NAMESPACE namespace_name ';' top_statement_list     { $$ = ['namespace', $2, $4]; }
  | T_NAMESPACE namespace_name '{' top_statement_list '}' { $$ = ['namespace', $2, $4]; }
  | T_NAMESPACE '{' top_statement_list '}'                { $$ = ['namespace', false, $4]; }
  | T_USE use_declarations ';'                            { $$ = ['use', $2]; }
  | constant_declaration ';'                              { $$ = $1; }
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
