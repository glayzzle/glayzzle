
namespace_declaration:
  T_NAMESPACE namespace_name ';' top_statement* { 
    /* ns_declaration */ return ['namespace', $1, $3 || []];
  }
  | T_NAMESPACE '{' top_statement* '}'                      { /* ns_declaration */ $$ = ['namespace', [], $2]; }
  | T_NAMESPACE namespace_name '{' top_statement* '}'       { /* ns_declaration */ $$ = ['namespace', $1, $3]; }
;

namespace_name:
    namespace_name T_NS_SEPARATOR T_STRING                { /* namespace_name */ $$ = $1; $1.push($3); }
  | T_STRING                                              { /* namespace_name */ $$ = [$1]; }
;

use_declaration:
  T_USE use_list ';'                                      { /* use_declaration */ $$ = ['use', $2]; }
;

use_list:
    use_name ',' use_name                                 { /* use_list */ $$ = $1; $1.push($3); }
  | use_name                                              { /* use_list */ $$ = [$1]; }
;

use_name:
    namespace_name                                        { /* use_name */ $$ = [$1, false]; }
  | namespace_name T_AS T_STRING                          { /* use_name */ $$ = [$1, $3]; }
  | T_NS_SEPARATOR namespace_name                         { /* use_name */ $$ = [$2, false]; }
  | T_NS_SEPARATOR namespace_name T_AS T_STRING           { /* use_name */ $$ = [$2, $3]; }
;