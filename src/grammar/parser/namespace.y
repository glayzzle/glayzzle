namespace_name:
    T_STRING { $$ = $1; }
  | namespace_name T_NS_SEPARATOR T_STRING        { $$ = $1 + '\\' + $3; }
;

use_declarations:
    use_declarations ',' use_declaration          { $$ = [$1, $3]; }
  | use_declaration                               { $$ = $1; }
;

use_declaration:
    namespace_name                                { $$ = $1; }
  | namespace_name T_AS T_STRING                  { $$ = [$1, $3]; }
  | T_NS_SEPARATOR namespace_name                 { $$ = '\\' + $2; }
  | T_NS_SEPARATOR namespace_name T_AS T_STRING   { $$ = ['\\' + $2, $3]; }
;