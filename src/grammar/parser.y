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
  constant_declaration { 
    /* top_statement : const */ $$ = $1; 
  }
;

@import 'parser/mixed.y'
@import 'parser/scalar.y'
@import 'parser/variable.y'