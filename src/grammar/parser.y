%pure_parser
%expect 3
%start start

@import 'parser/def.y'

%% /* language grammar */

start:
  top_statement_list  { return $1 || []; }
  | /* empty */       { return []; }
;

top_statement_list:
    top_statement_list top_statement  { $$ = $1; $1.push($2); }
  | top_statement                     { $$ = [$1]; }
;

top_statement:
    function_declaration_statement                        { /* top_statement : func */ $$ = $1; }
  | class_declaration_statement                           { /* top_statement : class */ $$ = $1; }
  | T_HALT_COMPILER '(' ')' ';'                           { YYACEPT }
  | T_NAMESPACE ns_declaration                            { /* top_statement : ns */ $$ = $2; }
  | T_USE use_declarations ';'                            { /* top_statement : use */ $$ = ['use', $2]; }
  | constant_declaration ';'                              { /* top_statement : const */ $$ = $1; }
  | statement                                             { /* top_statement : statement */ $$ = $1; }
;

ns_declaration: 
  '{' top_statement_list '}'                        { /* ns_declaration */ $$ = ['namespace', [], $2]; }
  | namespace_name '{' top_statement_list '}'       { /* ns_declaration */ $$ = ['namespace', $1, $3]; }
  | namespace_name ';' top_statement_list           { /* ns_declaration */ $$ = ['namespace', $1, $3]; }
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
