constant_declaration: 
  T_CONST constant_item optionnal_constant_item* ';' {
  $3.unshift($2);
  $$ = ['define', $3];
};

constant_item: T_STRING '=' static_scalar {
  $$ = [$1, $3];
};

optionnal_constant_item: ',' constant_item {
  $$ = $2;
};