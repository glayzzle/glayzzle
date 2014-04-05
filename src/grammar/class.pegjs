class_declaration_statement /*"T_CLASS" */
  = f:class_flag? __* T_CLASS __* n:T_STRING e:(__* extends_from)? i:(__* implements_list)? __* '{' b:class_statement_list '}' {
    var result = {
      type: 'class.T_DECLARE',
      flag: f,
      name: n,
      extends: typeof(e) == 'undefined' || !e ? false : e[1],
      implements: typeof(i) == 'undefined' || !i ? [] : i[1],
      properties: [],
      constants: [],
      methods: []
    };
    if (
      result.name == 'implements'
      || result.extends == 'implements'
    ) {
      expected('class name T_STRING but T_IMPLEMENTS found');
    }
    if (
      result.name == 'extends'
      || result.extends == 'extends'
    ) {
      expected('class name T_STRING but T_EXTENDS found');
    }
    var lastDoc = null;
    for(var i = 0; i < b.length; i++) {
      var tok = b[i];
      if ( typeof(tok) == 'object' && tok.type) {
        if (lastDoc) tok.doc = lastDoc;
        switch(tok.type) {
          case 'class.T_CONST':
            result.constants.push(tok);
            break;
          case 'class.T_PROPERTY':
            result.properties.push(tok);
            break;
          case 'class.T_METHOD':
            result.methods.push(tok);
            break;
          default:
            throw new Error('Unexpected token ' + tok.type);
        }
        lastDoc = null;
      } else if ( tok.substring(0, 3) === '/**' ) {
        lastDoc = tok;
      }
    }
    return result;
  }
  / T_INTERFACE T_STRING interface_extends_list? '{' class_statement_list '}'
  / T_TRAIT T_STRING '{' class_statement_list '}'

class_flag
  = T_ABSTRACT { return builder.T_ABSTRACT; }
  / T_FINAL    { return builder.T_FINAL; }

class_const_name
  = T_CLASS / T_STRING

class_type
  = T_ARRAY / T_CALLABLE / T_STRING 

extends_from
  = T_EXTENDS __+ n:T_STRING            { return n; }

interface_extends_list
  = T_EXTENDS __+ n:name_list       { return n; }

implements_list
  = T_IMPLEMENTS __+ n:name_list    { return n; }

class_statement_list
  = class_statement*

class_statement
  = 
  /* @todo T_USE __ name_list __ trait_adaptations */
  T_CONST __+ c:constant_declaration_list __* ';' {
    return {
      type: 'class.T_CONST',
      items: c
    };
  }
  / m:variable_modifiers p:property_declaration_list __* ';' {
    return {
      type: 'class.T_PROPERTY',
      modifiers: m,
      properties: p
    };
  }
  / m:method_modifiers? T_FUNCTION __+ '&'? n:T_STRING __* p:function_args __* b:statements_body {
    return {
      type: 'class.T_METHOD',
      modifiers: typeof(m) == 'undefined' || !m ? [] : m,
      name: n,
      parameters: p,
      body: b
    };
  }
  / __


variable_modifiers
  = non_empty_member_modifiers
  / T_VAR __+   { return [1]; }

method_modifiers
  = non_empty_member_modifiers

non_empty_member_modifiers
  = member_modifier+

member_modifier
  = T_PUBLIC __+         { return builder.T_PUBLIC; }
  / T_PROTECTED __+      { return builder.T_PROTECTED; }
  / T_PRIVATE __+        { return builder.T_PRIVATE; }
  / T_STATIC __+         { return builder.T_STATIC; }
  / T_ABSTRACT __+       { return builder.T_ABSTRACT; }
  / T_FINAL __+          { return builder.T_FINAL; }

property_declaration_list
  = a1:property_declaration al:( __* ',' __* property_declaration)* { return makeList(a1, al) }

property_declaration
  = n:T_VARIABLE ( __* '=' __* d:static_scalar)? {
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
