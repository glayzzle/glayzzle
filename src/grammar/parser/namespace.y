
ns_declaration: 
  T_NAMESPACE '{' top_statement* '}'                        { /* ns_declaration */ $$ = ['namespace', [], $2]; }
  | T_NAMESPACE namespace_name '{' top_statement* '}'       { /* ns_declaration */ $$ = ['namespace', $1, $3]; }
  | T_NAMESPACE namespace_name ';' top_statement*           { /* ns_declaration */ $$ = ['namespace', $1, $3]; }
;

namespace_name:
    namespace_name T_NS_SEPARATOR T_STRING        { /* namespace_name */ $$ = $1; $1.push($3); }
  | T_STRING                                      { /* namespace_name */ $$ = [$1]; }
;

use_declarations:
    use_declarations ',' use_declaration          { /* use_declarations */ $$ = $1; $1.push($3); }
  | use_declaration                               { /* use_declarations */ $$ = [$1]; }
;

use_declaration:
    namespace_name                                { /* use_declaration */ $$ = [$1, false]; }
  | namespace_name T_AS T_STRING                  { /* use_declaration */ $$ = [$1, $3]; }
  | T_NS_SEPARATOR namespace_name                 { /* use_declaration */ $$ = [$2, false]; }
  | T_NS_SEPARATOR namespace_name T_AS T_STRING   { /* use_declaration */ $$ = [$2, $3]; }
;