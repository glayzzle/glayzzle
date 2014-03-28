class_declaration_statement "T_CLASS"
  = f:(T_ABSTRACT / T_FINAL)? __* T_CLASS __* n:T_STRING __ e:extends_from? __ i:implements_list? __ '{' __ b:class_statement_list __ '}' {
    return {
      type: 'class.T_DECLARE',
      flag: f,
      name: n,
      extends: e,
      implements: i,
      body: b
    };
  }
  / T_INTERFACE T_STRING interface_extends_list? '{' class_statement_list '}'
  / T_TRAIT T_STRING '{' class_statement_list '}'

class_const_name
  = T_CLASS / T_STRING

class_type
  = T_ARRAY / T_CALLABLE / name 

extends_from
  = T_EXTENDS __ n:name            { return n; }

interface_extends_list
  = T_EXTENDS __ n:name_list       { return n; }

implements_list
  = T_IMPLEMENTS __ n:name_list    { return n; }

class_statement_list
  = class_statement*

class_statement
  = __ m:variable_modifiers __ p:property_declaration_list __ ';' {
    return {
      type: 'class.T_PROPERTY',
      modifiers: m,
      properties: p
    };
  }
  / __ T_CONST __ c:constant_declaration_list __ ';' {
    return {
      type: 'class.T_CONST',
      items: c
    };
  }
  / __ m:method_modifiers __ T_FUNCTION __ optional_ref n:T_STRING __ '(' __ p:parameter_list __ ')' __ b:method_body {
    return {
      type: 'class.T_METHOD',
      modifiers: m,
      name: n,
      parameters: p,
      body: b
    };
  }
  / __ T_USE __ name_list __ trait_adaptations


method_body "T_METHOD_BODY"
  = ';' / statements_body

variable_modifiers
  = non_empty_member_modifiers
  / T_VAR   { return [1]; }

method_modifiers
  = non_empty_member_modifiers

non_empty_member_modifiers
  = member_modifier+

member_modifier
  = T_PUBLIC __         { return 1; }
  / T_PROTECTED __      { return 2; }
  / T_PRIVATE __        { return 4; }
  / T_STATIC __         { return 8; }
  / T_ABSTRACT __       { return 16; }
  / T_FINAL __          { return 32; }

property_declaration_list
  = a1:property_declaration al:( __ ',' __ property_declaration)* { return makeList(a1, al) }

property_declaration
  = n:T_VARIABLE __ ('=' __ d:static_scalar)? {
    return {
      name: n.name,
      default: typeof d !== 'undefined' ? d : null
    };
  }


class_name
  = T_STATIC / name

class_name_reference
  = class_name / dynamic_class_name_reference

dynamic_class_name_reference
  = object_access_for_dcnr / base_variable

class_name_or_var
  = class_name / reference_variable
