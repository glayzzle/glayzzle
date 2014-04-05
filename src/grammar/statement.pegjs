
top_statement
  = function_declaration_statement
  / class_declaration_statement
  / namespace_statement
  / statement
  / __

inner_statement
  = function_declaration_statement
  / class_declaration_statement
/**
 * @todo THIS PART SHOULD BE VERIFIED AT SERIALISATION
 * T_HALT_COMPILER { throw new Error('__HALT_COMPILER() can only be used from the outermost scope'); } 
 */
  / statement
  / __

statements_body
  = '{' s:(statement / __)* '}' {
    return { type: "common.T_STATEMENTS", data: s };
  }

statement
    = T_IF __*  c:parentheses_expr_req __* s:statement __* ei:elseif* __* es:else_single? {
      return {
        type: "common.T_IF"
        , condition: c
        , statement: s
        , _elseif: ei
        , _else: es
      };
    }
    / T_IF __* parentheses_expr_req ':' inner_statement* __ _elseif:elseif* _else:else_single? T_ENDIF ';'
    / T_WHILE __* parentheses_expr_req __* while_statement
    / T_DO __* statement __* T_WHILE parentheses_expr_req ';'
    / T_FOR __* '(' __* for_expr __* ';' __* for_expr __* ';' __* for_expr __* ')' __* for_statement
    / T_SWITCH parentheses_expr_req switch_case_list
    / T_BREAK (__+ expr)? __* ';'
    / T_CONTINUE (__+ expr)? __* ';'
    / T_RETURN (__+ expr)? __* ';'
    / T_ECHO __+ t:expr_list __* ';'  {
      return { 
        type: 'internal.T_ECHO', statements: t 
      }; 
    }
    / yield_expr ';'
    / T_GLOBAL global_var_list ';'
    / T_STATIC static_var_list ';'
    / T_INLINE_HTML
    / T_UNSET '(' variables_list ')' ';'
    / T_FOREACH __* '(' expr T_AS foreach_variable ')' foreach_statement
    / T_FOREACH __* '(' expr T_AS variable T_DOUBLE_ARROW foreach_variable ')' foreach_statement
    / T_DECLARE __* '(' declare_list ')' declare_statement
    / T_TRY statements_body catches optional_finally?
    / T_THROW __+ expr ';'
    / ';'
    / statements_body
    / expr ';'

for_statement
  = statement
  / ':' inner_statement* T_ENDFOR ';'

foreach_statement
  = statement
  / ':' inner_statement* T_ENDFOREACH ';'

declare_statement
  = statement
  / ':' inner_statement* T_ENDDECLARE ';'

declare_list
  = declare_list_element (',' declare_list_element)*

declare_list_element 
  =T_STRING '=' static_scalar

switch_case_list
  = '{' ';'? case* '}'
  / ':' ';'? case* T_ENDSWITCH ';'

case= ((T_CASE __+ expr) / T_DEFAULT) __* case_separator inner_statement*

case_separator
  = ':'
  / ';'

while_statement
  = statement
  / ':' inner_statement* T_ENDWHILE ';'

elseif
  = T_ELSEIF __* c:parentheses_expr __* s:statement {
    return { type: "common.T_ELSEIF", condition: c, statement: s };
  }

else_single
  = T_ELSE __* s:statement { return { type: 'common.T_ELSE', data: s }; }

foreach_variable
  = variable
  / '&' variable
  / list_expr

catches
  = catch*

catch
  = T_CATCH '(' name T_VARIABLE ')' statements_body

optional_finally
  = T_FINALLY statements_body

constant_declaration_list
  = e:constant_declaration __* l:( ',' __* constant_declaration __*)* { return makeList(e, l); }

constant_declaration
  = n:T_STRING __* '=' __* v:static_scalar {
    return {
      name: n,
      value: v
    };
  }

static_var_list
  = static_var (',' static_var)*

static_var
  = T_VARIABLE / T_VARIABLE '=' static_scalar
