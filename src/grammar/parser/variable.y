
variable:
  const_variable  { $$ = $1 }
;

const_variable:
  T_VARIABLE      { /* const_variable */ $$ = ['let', ['const', $1.substring(1)]]; }
;
