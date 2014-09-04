
variable:
  base_variable_with_function_calls 
    T_OBJECT_OPERATOR object_property 
    method_or_not 
    variable_properties                                       { /* variable */
      $$ = ['prop', $3, $1];
      if ($4 !== false) {
        // @todo
      }
    }
  | base_variable_with_function_calls                         {  /* variable */ $$ = $1; }
;

const_variable:
  T_VARIABLE                                                  { /* const_variable */ $$ = ['let', ['const', $1.substring(1)]]; }
;

variable_properties:
    variable_properties variable_property                     { $$ = $1; $1.push($2); }
  | /* empty */                                               { $$ = []; }
;


variable_property:
  T_OBJECT_OPERATOR object_property method_or_not             {
    // @fixme must prepare some tests
  }
;

variable_without_objects:
    simple_indirect_reference reference_variable
  | reference_variable                                        { /* variable_without_objects */ $$ = $1; }
;

base_variable_with_function_calls:
    base_variable                                   { /* base_variable_with_function_calls */ $$ = $1; }
  | array_function_dereference                      { /* base_variable_with_function_calls */ $$ = $1; }
  | function_call                                   { /* base_variable_with_function_calls */ $$ = $1; }
;


base_variable:
  variable_without_objects                          { /* base_variable */ $$ = $1; }
  | static_member
;

reference_variable:
    compound_variable                                  { /* reference_variable */ $$ = $1; }
  | reference_variable '[' dim_offset ']'              { /* reference_variable */ $$ = ['offset', $3, $1]; }
  | reference_variable '{' expr '}'                    { /* reference_variable */
    $1[1] = [ 'op', 'join', $1[1], $3 ];
    $$ = $1; 
  }
;


compound_variable:
    const_variable                                    { /* compound_variable */ $$ = $1; }
  | '$' '{' expr '}'                                  { /* compound_variable */ $$ = ['let', $3]; }
;

variable_name:
    T_STRING                                          { /* variable_name */ $$ = ['const', $1]; }
  | '{' expr '}'                                      { /* variable_name */ $$ = $2; }
;

simple_indirect_reference:
    simple_indirect_reference '$' 
  | '$'
;


isset_variables:
    isset_variables ',' isset_variable                { /* isset_variables */ $$ = $1; $1.push($3); }
  | isset_variable                                    { /* isset_variables */ $$ = [$1]; }
;

isset_variable:
    variable                              { /* isset_variable */ $$ = $1; }
  | expr_without_variable                 {
    // @todo handle error raising
    zend_error(E_COMPILE_ERROR, "Cannot use isset() on the result of an expression (you can use \"null !== expression\" instead)");
  }
;