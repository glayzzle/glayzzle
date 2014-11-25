is_reference: 
  '&'             { $$ = true; }
  | /* empty */   { $$ = false; }
;

optional_class_type:
    T_ARRAY                                     { /* optional_class_type */ $$ = ['const', $1]; }
  | T_CALLABLE                                  { /* optional_class_type */ $$ = ['const', $1]; }
  | fully_qualified_class_name                  { /* optional_class_type */ $$ = $1; }
;

function_declaration:
  T_FUNCTION is_reference T_STRING '(' parameter_list ')' '{' 
    any_statement* 
  '}'                             { /* function_declaration */ $$ = ['function', $3, $5, $8, false]; }
;

parameter_list:
  (parameter_expr ',')* parameter_expr? {
    $$ = $1.concat([$2]);
  }
;

parameter_expr:
  optional_class_type? is_reference? const_variable '=' any_statement? { 
    /* non_empty_parameter_list */ 
    $$ = { class: $1, isRef: $2 ? $2 : false, name: $3, default: $4 }; 
  }
;
