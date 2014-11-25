
const_variable:
  T_VARIABLE      { /* const_variable */ $$ = ['let', ['const', $1.substring(1)]]; }
;


any_statement: 
  T_STRING { /** crap tokens (ignored) **/ }
;