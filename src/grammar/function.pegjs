function_declaration_statement
    = T_FUNCTION __* '&'? n:T_STRING __* p:function_args __* s:statements_body {
      return {
        type: 'function.T_DECLARE',
        name: n,
        parameters: p,
        body: s
      };
    }

function_args
  = '(' __* p:(parameter_list __*)? ')' {
    return typeof(p) == 'undefined' ? [] : p;
  }

function_call "T_FUNCTION_CALL"
  = function_call_expr
  / function_call_expr '[' dim_offset ']'
  /* alternative array syntax missing intentionally */

function_call_expr
  = n:name a:argument_list { 
    return { 
      type: 'function.T_CALL'
      , name: n
      , args: a
    };
  }
  / class_name_or_var T_PAAMAYIM_NEKUDOTAYIM T_STRING argument_list
  / class_name_or_var T_PAAMAYIM_NEKUDOTAYIM '{' expr '}' argument_list
  / static_property argument_list
  / variable_without_objects argument_list
