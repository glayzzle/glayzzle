possible_comma:
  ',' | /* empty */
;

static_array_pair_list:
    non_empty_static_array_pair_list possible_comma                                     { $$ = $1; }
  | /* empty */                                                                         { $$ = []; }
;

non_empty_static_array_pair_list:
    non_empty_static_array_pair_list ',' static_scalar T_DOUBLE_ARROW static_scalar     { $$ = $1; $1.push([$3, $5]); }
  | non_empty_static_array_pair_list ',' static_scalar                                  { $$ = $1; $1.push([false, $3]); }
  | static_scalar T_DOUBLE_ARROW static_scalar                                          { $$ = [[$1, $2]]; }
  | static_scalar                                                                       { $$ = [[false, $1]]; }
;


array_method_dereference:
    array_method_dereference '[' dim_offset ']'                                         { $$ = ['offset', $3, $1]; }
  | method '[' dim_offset ']'                                                           { $$ = ['offset', $3, $1]; }
;


array_function_dereference:
    array_function_dereference '[' dim_offset ']'                                       { $$ = ['offset', $3, $1]; }
  | function_call '[' dim_offset ']'                                                    { $$ = ['offset', $3, $1]; }
;

dim_offset:
    expr                                                                                { $$ = $1; }
  | /* empty */                                                                         { $$ = false; }
;


array_pair_list:
    non_empty_array_pair_list possible_comma                                            { $$ = $1; }
  | /* empty */                                                                         { $$ = []; }
;

non_empty_array_pair_list:
    non_empty_array_pair_list ',' expr T_DOUBLE_ARROW expr                              { $$ = $1; $1.push([$3, $5]); }
  | non_empty_array_pair_list ',' expr                                                  { $$ = $1; $1.push([false, $3]); }
  | expr T_DOUBLE_ARROW expr                                                            { $$ = [[$1, $3]]; }
  | expr                                                                                { $$ = [[false, $1]]; }
;
[]