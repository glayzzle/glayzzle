constant_declaration: T_CONST constant_item (',' constant_item)* ';' {
  $$ = $2;
};

constant_item: T_STRING '=' static_scalar {
  $$ = ['const', $1, $3];
};