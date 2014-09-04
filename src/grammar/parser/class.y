optional_class_type:
    T_ARRAY                                     { /* optional_class_type */ $$ = ['const', $1]; }
  | T_CALLABLE                                  { /* optional_class_type */ $$ = ['const', $1]; }
  | fully_qualified_class_name                  { /* optional_class_type */ $$ = $1; }
;

class_declaration_statement:
  unticked_class_declaration_statement          { $$ = $1; }
;

unticked_class_declaration_statement:
  class_entry_type T_STRING extends_from implements_list
    '{'
      class_statement_list
    '}'                                         {
    var body = {
      constants: {},
      properties: {},
      methods: {},
      traits: []
    };
    for(var i in $6) {
      switch($6[i][0]) {
        case 'method':
          body.methods[$6[i][2]] = {
            flags: $6[i][1],
            args: $6[i][3],
            body: $6[i][4],
          };
          break;
        case 'property':
          for(var p in $6[i][2]) {
            if ($6[i][2][p][0] == 'let') {
              body.properties[$6[i][2][p][1][1]] = {
                flags: $6[i][1],
                value: []
              };
            } else if ($6[i][2][p][0] == 'set') {  // set mode (sets a default value)
              body.properties[$6[i][2][p][1][1][1]] = {
                flags: $6[i][1],
                value: $6[i][2][p][2]
              };
            }
          }
          break;
        case 'constant':
          for(var p in $6[i][1]) {
            body.constants[$6[i][1][p][0]] = $6[i][1][p][1];
          }
          break;
        case 'use':
          body.traits.push($6[i][1]);
          break;
      }
    }
    $$ = ['class', $2, $3, $4, body]; 
  }
  | interface_entry T_STRING interface_extends_list
    '{'
      class_statement_list
    '}'                                         { $$ = ['interface', $2, $3, false, $5]; }
;

class_entry_type:
    T_CLASS               { /* class_entry_type */ $$ = { trait: false, abstract: false, final: false }; }
  | T_ABSTRACT T_CLASS    { /* class_entry_type */ $$ = { trait: false, abstract: true, final: false }; }
  | T_TRAIT               { /* class_entry_type */ $$ = { trait: true, abstract: false, final: false }; }
  | T_FINAL T_CLASS       { /* class_entry_type */ $$ = { trait: false, abstract: false, final: true }; }
;

extends_from:
    T_EXTENDS fully_qualified_class_name    { /* extends_from */ $$ = $2; }
  | /* empty */                             { /* extends_from */ $$ = false; }
;

interface_entry:
  T_INTERFACE
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
    interface_list ',' fully_qualified_class_name     { /* interface_list */ $$ = $1; $1.push($3); }
  | fully_qualified_class_name                        { /* interface_list */ $$ = [$1]; }
;


class_statement_list:
    class_statement_list class_statement              { /* class_statement_list */ $$ = $1; $1.push($2); }
  | class_statement                                   { /* class_statement_list */ $$ = [$1]; }
  | /* empty */                                       { /* class_statement_list */ $$ = []; }
;


class_statement:
    variable_modifiers class_variable_declaration ';'             { $$ = ['property', $1, $2]; } 
  | class_constant_declaration ';'                                { $$ = ['constant', $1]; }
  | trait_use_statement                                           { $$ = ['use', $1]; }
  | T_FUNCTION is_reference T_STRING  '(' parameter_list ')' method_body {
    $$ = ['method', ['public'], $3, $5, $7];
  }
  | non_empty_member_modifiers T_FUNCTION is_reference T_STRING  '(' parameter_list ')' method_body {
    $$ = ['method', $1, $4, $6, $8];
  }
;

method_body:
  ';' /* abstract method */             { $$ = []; }
  | '{' inner_statement* '}'        { $$ = $2; }
;

variable_modifiers:
    non_empty_member_modifiers        { $$ = $1; }
  | T_VAR                             { $$ = ['public']; }
;

method_modifiers:
		/* empty */
	|	non_empty_member_modifiers
;

non_empty_member_modifiers:
    non_empty_member_modifiers member_modifier    { $$ = $1; $1.push($2); }
  | member_modifier                               { $$ = [$1]; }
;

member_modifier:
    T_PUBLIC          { $$ = 'public'; }
  | T_PROTECTED       { $$ = 'protected'; }
  | T_PRIVATE         { $$ = 'private'; }
  | T_STATIC          { $$ = 'static'; }
  | T_ABSTRACT        { $$ = 'abstract'; }
  | T_FINAL           { $$ = 'final'; }
;

class_variable_declaration:
    class_variable_declaration ',' const_variable '=' static_scalar     { $$ = $1; $1.push(['set', $3, $5]); }
  | class_variable_declaration ',' const_variable                       { $$ = $1; $1.push($3); }
  | const_variable '=' static_scalar                                    { $$ = [['set', $1, $3]]; }
  | const_variable                                                      { $$ = [$1]; }
;

class_constant_declaration:
    class_constant_declaration ',' T_STRING '=' static_scalar           { $$ = $1; $1.push([$3, $5]); }
  | T_CONST T_STRING '=' static_scalar                                  { $$ = [[$2, $4]]; }
;

new_expr:
  T_NEW class_name_reference ctor_arguments                             { $$ = ['new', $2, $3]; }
;


class_name:
    T_STATIC                                              { /* class_name */ $$ = ['ref', 'static']; }
  | T_NS_SEPARATOR namespace_name                         { /* class_name */ $$ = ['ref', $2]; }
  | namespace_name                                        { /* class_name */ $$ = ['ref', $1]; }
;

fully_qualified_class_name:
    T_NS_SEPARATOR namespace_name                         { /* fully_qualified_class_name */ $$ = $2; }
  | namespace_name                                        { /* fully_qualified_class_name */ $$ = $1; }
;

class_name_reference:
    base_variable T_OBJECT_OPERATOR  object_property  dynamic_class_name_variable_properties
  | base_variable { $$ = $1; }
  | class_name
;


dynamic_class_name_variable_properties:
		dynamic_class_name_variable_properties dynamic_class_name_variable_property
	|	/* empty */
;


dynamic_class_name_variable_property:
		T_OBJECT_OPERATOR object_property
;


ctor_arguments:
    function_call_parameter_list      { /* ctor_arguments */ $$ = $1; }
  | /* empty */                       { /* ctor_arguments */ $$ = false; }
;


method:
  function_call_parameter_list        { /* method */ $$ = $1; }
;

method_or_not:
    method                            { /* method_or_not: methd */ $$ = $1; }
  | array_method_dereference          { /* method_or_not: array */ $$ = $1; }
  | /* empty */                       { /* method_or_not: empty */ $$ = false; }
;


static_member:
		class_name T_DOUBLE_COLON variable_without_objects
	|	reference_variable T_DOUBLE_COLON variable_without_objects

;


object_property:
		object_dim_list
	|	variable_without_objects
;

object_dim_list:
  object_dim_list '[' dim_offset ']'
	|	object_dim_list '{' expr '}'
	|	variable_name
;


class_constant:
    class_name T_DOUBLE_COLON T_STRING              { /* class_constant */ $$ = ['prop', $3, $1]; }
  | reference_variable T_DOUBLE_COLON T_STRING     { /* class_constant */ $$ = ['prop', $3, $1]; }
;
