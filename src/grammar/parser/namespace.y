namespace_name:
    namespace_name T_NS_SEPARATOR T_STRING        { $$ = $1; $1.push($3); }
  | T_STRING                                      { $$ = [$1]; }
;

use_declarations:
    use_declaration                               { $$ = [$1]; }
  | use_declarations ',' use_declaration          { $$ = $1; $1.push($3); }
;

use_declaration:
    namespace_name                                { $$ = [$1, false]; }
  | namespace_name T_AS T_STRING                  { $$ = [$1, $3]; }
  | T_NS_SEPARATOR namespace_name                 { $$ = [$2, false]; }
  | T_NS_SEPARATOR namespace_name T_AS T_STRING   { $$ = [$2, $3]; }
;