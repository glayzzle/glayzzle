
class_type:
    T_CLASS               { /* class_entry_type */ $$ = { abstract: false, final: false }; }
  | T_ABSTRACT T_CLASS    { /* class_entry_type */ $$ = { abstract: true, final: false }; }
  | T_FINAL T_CLASS       { /* class_entry_type */ $$ = { abstract: false, final: true }; }
;

trait_declaration: 
  T_TRAIT T_STRING extends_from implements_list '{' class_statement_list '}' {
    $$ = ['trait', $2, $3, $4, buildClassBody($6)]; 
  }
;

class_declaration:
  class_type T_STRING extends_from implements_list '{' class_statement_list '}' {
    $$ = ['class', $2, $3, $4, buildClassBody($6)]; 
  }
;

interface_declaration: 
  T_INTERFACE T_STRING interface_extends_list '{' class_statement_list '}' { 
    $$ = ['interface', $2, $3, false, $5];
  }
;

extends_from:
    T_EXTENDS namespace_name                { /* extends_from */ $$ = $2; }
  | /* empty */                             { /* extends_from */ $$ = false; }
;

interface_extends_list:
    T_EXTENDS interface_list                { /* interface_extends_list */ $$ = $2; }
  | /* empty */                             { /* interface_extends_list */ $$ = []; }
;

implements_list:
    T_IMPLEMENTS interface_list            { $$ = $1; }
  | /* empty */                            { $$ = []; }
;

interface_list:
    interface_list ',' namespace_name                 { /* interface_list */ $$ = $1; $1.push($3); }
  | namespace_name                                    { /* interface_list */ $$ = [$1]; }
;

class_statement_list:
  class_statement* { $$ = $1 || []; }
;

class_statement:
    variable_modifiers class_variable_declaration ';'             { $$ = ['property', $1, $2]; } 
  | class_constant_declaration ';'                                { $$ = ['constant', $1]; }
  | trait_use_statement                                           { $$ = ['use', $1]; }
  | member_modifier* T_FUNCTION is_reference T_STRING  '(' parameter_list ')' method_body {
    $$ = ['method', $1 || ['public'], $4, $6, $7];
  }
;

variable_modifiers:
    member_modifier*                  { $$ = $1; }
  | T_VAR                             { $$ = ['public']; }
;

member_modifier:
    T_PUBLIC          { $$ = 'public'; }
  | T_PROTECTED       { $$ = 'protected'; }
  | T_PRIVATE         { $$ = 'private'; }
  | T_STATIC          { $$ = 'static'; }
  | T_ABSTRACT        { $$ = 'abstract'; }
  | T_FINAL           { $$ = 'final'; }
;

method_body:
  ';' /* abstract method */               { $$ = []; }
  | '{' inner_statement* '}'              { $$ = $2; }
;


class_variable_declaration:
    class_variable_declaration ',' variable '=' any_statement     { $$ = $1; $1.push(['set', $3, $5]); }
  | class_variable_declaration ',' variable                       { $$ = $1; $1.push($3); }
  | variable '=' any_statement                                    { $$ = [['set', $1, $3]]; }
  | variable                                                      { $$ = [$1]; }
;

class_constant_declaration:
    class_constant_declaration ',' T_STRING '=' any_statement           { $$ = $1; $1.push([$3, $5]); }
  | T_CONST T_STRING '=' any_statement                                  { $$ = [[$2, $4]]; }
;
