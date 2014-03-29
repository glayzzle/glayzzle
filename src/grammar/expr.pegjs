
expr /* "T_EXPR" */
  /** SPECIAL PHP FUNCTIONS : **/
  = T_ISSET __* '(' __* v:variables_list __* ')'
  / T_EMPTY __* '(' e:expr ')'
  / i:'@'? T_INCLUDE_ONCE t:optional_parentheses_expr           { return { type: 'internal.T_INCLUDE', target: t, ignore: i, once: true }; }
  / i:'@'? T_INCLUDE t:optional_parentheses_expr                { return { type: 'internal.T_INCLUDE', target: t, ignore: i, once: false }; }
  / T_REQUIRE_ONCE  t:optional_parentheses_expr                 { return { type: 'internal.T_REQUIRE', target: t, once: true }; }
  / T_REQUIRE t:optional_parentheses_expr                       { return { type: 'internal.T_REQUIRE', target: t, once: false }; }
  / T_EVAL parentheses_expr
  / T_EXIT optional_parentheses_expr
  / T_PRINT expr
  / T_HALT_COMPILER parentheses_expr ';'
  /** **/
  / new_expr
  / T_CLONE expr
  / T_OBJECT_OPERATOR expr
  / boolean_expr __* expr?
  / list_expr __* '=' expr
  / T_INC __* variable __ expr?
  / T_DEC variable __* expr?
  / variable __* (
    T_PLUS_EQUAL
    / T_MINUS_EQUAL
    / T_MUL_EQUAL
    / T_DIV_EQUAL
    / T_CONCAT_EQUAL
    / T_MOD_EQUAL
    / T_AND_EQUAL
    / T_OR_EQUAL
    / T_XOR_EQUAL
    / T_SL_EQUAL
    / T_SR_EQUAL
  ) __* expr
  / pre_expr __* (
      T_BOOLEAN_OR
    / T_BOOLEAN_AND
    / T_LOGICAL_OR
    / T_LOGICAL_AND
    / T_LOGICAL_XOR
    / T_SL
    / T_SR
    / T_IS_IDENTICAL
    / T_IS_NOT_IDENTICAL
    / T_IS_EQUAL
    / T_IS_NOT_EQUAL
    / T_IS_SMALLER_OR_EQUAL
    / T_IS_GREATER_OR_EQUAL
    / '>'
    / '<'
  ) __* expr
  / variable __* T_INC __ expr?
  / variable __* '=' expr_list
  / variable __* '='  __ '&' variable
  / variable __* '=' '&' new_expr
  / variable __* T_DEC __ expr?
  / variable __* expr?
  / __* MathOperators __* expr
  / T_INSTANCEOF class_name_reference 
  / pre_expr __* '?' __* (expr __*)? ':' __* expr {
    console.log('-->' + text() + '<--');
  }
  / T_INT_CAST expr
  / T_DOUBLE_CAST expr
  / T_STRING_CAST expr
  / T_ARRAY_CAST expr
  / T_OBJECT_CAST expr
  / T_BOOL_CAST expr
  / T_UNSET_CAST expr
  / '@' expr
  
  / scalar __* expr?
  / array_expr
  / scalar_dereference
  / '`' backticks_expr? '`'
  / T_YIELD
  / pre_expr __* (T_STATIC __*)? T_FUNCTION __* '&'? function_args lexical_vars? statements_body

expr_list
  = __* expr __* expr_list

pre_expr
  = T_ISSET __* '(' __* v:variables_list __* ')'
  / T_EMPTY __* '(' e:expr ')'
  / i:'@'? T_INCLUDE_ONCE t:optional_parentheses_expr           { return { type: 'internal.T_INCLUDE', target: t, ignore: i, once: true }; }
  / i:'@'? T_INCLUDE t:optional_parentheses_expr                { return { type: 'internal.T_INCLUDE', target: t, ignore: i, once: false }; }
  / T_REQUIRE_ONCE  t:optional_parentheses_expr                 { return { type: 'internal.T_REQUIRE', target: t, once: true }; }
  / T_REQUIRE t:optional_parentheses_expr                       { return { type: 'internal.T_REQUIRE', target: t, once: false }; }
  / T_EVAL parentheses_expr
  / T_EXIT optional_parentheses_expr
  / T_PRINT expr
  / T_HALT_COMPILER parentheses_expr ';'
  /** **/
  / new_expr
  / T_CLONE expr
  / T_OBJECT_OPERATOR expr
  / boolean_expr __* expr?
  / list_expr __* '=' expr
  / T_INC __* variable __ expr?
  / T_DEC variable __* expr?
  / variable __* (
    T_PLUS_EQUAL
    / T_MINUS_EQUAL
    / T_MUL_EQUAL
    / T_DIV_EQUAL
    / T_CONCAT_EQUAL
    / T_MOD_EQUAL
    / T_AND_EQUAL
    / T_OR_EQUAL
    / T_XOR_EQUAL
    / T_SL_EQUAL
    / T_SR_EQUAL
  ) __* expr
  / variable __* T_INC __ expr?
  / variable __* '=' expr_list
  / variable __* '='  __ '&' variable
  / variable __* '=' '&' new_expr
  / variable __* T_DEC __ expr?
  / variable __* expr?
  / __* MathOperators __* expr
  / T_INSTANCEOF class_name_reference 
  / T_INT_CAST expr
  / T_DOUBLE_CAST expr
  / T_STRING_CAST expr
  / T_ARRAY_CAST expr
  / T_OBJECT_CAST expr
  / T_BOOL_CAST expr
  / T_UNSET_CAST expr
  / '@' expr
  
  / scalar __* expr?
  / array_expr
  / scalar_dereference
  / '`' backticks_expr? '`'
  / T_YIELD


optional_parentheses_expr 
  = '('? __* t:expr __* ')'? { return t; }

name "T_CLASS_NAME"
  = namespace_name

parentheses_expr
  = '(' __* ')' { return ['()']; }
  / '(' __* e:expr+ __* ')'                      { return ['(', e, ')']; }
  / '(' __* e:yield_expr __* ')'                 { return ['(', e, ')']; }

parameter "T_PARAMETER_EXPR"
  = t:class_type? __* r:'&'? v:T_VARIABLE (__* '=' __* v:static_scalar) ? {
    return { 
      type: 'function.T_PARAMETER', 
      name: v.name, 
      ref: r, 
      class: t?
      value: typeof v == 'undefined' ? null : v
    };
  }

new_expr "T_NEW_EXPR"
  = T_NEW __* c:class_name_reference __* a:argument_list? {
    return {
      type: 'class.T_NEW',
      name: c,
      ctor: typeof(a) == 'undefined' ? [] : a
    };
  }

optional_ref
  = r:'&'? { return typeof(r) != 'undefined' && r ? true : false; }

argument
  = expr / '&' variable

for_expr
  = expr_list*

boolean_expr
  = 'true' { return true; }
  / 'false' { return false; }

global_var
  = T_VARIABLE
  / '$' variable
  / '$' '{' expr '}'


yield_expr
  = __ T_YIELD expr
  / __ T_YIELD expr __ T_DOUBLE_ARROW __ expr


scalar_dereference
  = scalar_dereference_expr
  / scalar_dereference_expr '[' dim_offset ']'
  /* alternative array syntax missing intentionally */

scalar_dereference_expr
  = array_expr '[' dim_offset ']'
  / T_CONSTANT_ENCAPSED_STRING '[' dim_offset ']'

lexical_vars
  = T_USE '(' lexical_var_list ')'

lexical_var
  = optional_ref T_VARIABLE

list_expr
  = T_LIST '(' __ list_expr_elements? __ ')'

list_expr_element
  = list_expr / variable

encaps_list
  = encaps_list_expr encaps_var
  / encaps_list_expr T_ENCAPSED_AND_WHITESPACE
  / encaps_list_expr

encaps_list_expr
  = encaps_var
  / T_ENCAPSED_AND_WHITESPACE encaps_var

backticks_expr
  = T_ENCAPSED_AND_WHITESPACE / encaps_list

/** LISTS : **/

expr_list
  = e:expr l:( __* ',' __* expr)* { return makeList(e, l); }

list_expr_elements
  = e:list_expr_element l:( __* ',' __* list_expr_element)* { return makeList(e, l); }

lexical_var_list
  = e:lexical_var l:( __* ',' __* lexical_var )* { return makeList(e, l); }

global_var_list
  = g:global_var l:( __* ',' __* global_var)* { return makeList(g, l); }

parameter_list
  = p:parameter l:( __* ',' parameter)* { return makeList(p, l); }

variables_list
  = v:variable l:( __* ',' __* variable)* { return makeList(v, l); }

name_list
  = n:T_STRING l:( __* ',' __* T_STRING)* { return makeList(n, l); }

argument_list
  = '(' ')'  { return ['(', [], ')']; }
  / '(' __* a:argument l:( __* ',' __* argument )* __* ')' {
    var args = [a[3] ? a : a[1]];
    if (l) for(var i = 0; i<l.length; i++) {
      if (l[i][3][3]) {
        args.push(l[i][3]);
      } else {
        args.push(l[i][3][1]);
      }
    }
    return ['(', {
      type: 'common.T_ARGS', args: args
    }, ')']; 
  }
  /* todo '(' yield_expr ')'  */