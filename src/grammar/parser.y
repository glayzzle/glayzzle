%ebnf
%pure_parser
%expect 3
%start start

@import 'parser/tokens.y'

%% /* language grammar */

start:
  namespace_declaration   { return $1 || []; }
  | top_statement*          { return $1 || []; }
;

top_statement:
    function_declaration    { $$ = $1; }
  | class_declaration       { $$ = $1; }
  | trait_declaration       { $$ = $1; }
  | interface_declaration   { $$ = $1; }
  | any_declaration
;

@import 'parser/namespace.y'
@import 'parser/function.y'
@import 'parser/class.y'
@import 'parser/any.y'

%%

@import 'parser/ast.js'
