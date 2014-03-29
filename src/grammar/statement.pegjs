
top_statement
  = function_declaration_statement
  / class_declaration_statement
  / namespace_statement
  /* / statement */
  / __

inner_statement
  = function_declaration_statement
  / class_declaration_statement
/**
 * @todo THIS PART SHOULD BE VERIFIED AT SERIALISATION
 * T_HALT_COMPILER { throw new Error('__HALT_COMPILER() can only be used from the outermost scope'); } 
  / statement
 */
  / __

statements_body
  = '{' s:(__)* '}' {   //statement / __
    return { type: "common.T_STATEMENTS", data: s };
  }

statement
    = T_IF __*  c:parentheses_expr __* s:statement __* ei:elseif* __* es:else_single? {
      return {
        type: "common.T_IF"
        , condition: c
        , statement: s
        , _elseif: ei
        , _else: es
      };
    }
    / T_IF __* parentheses_expr ':' inner_statement* __ _elseif:elseif* _else:else_single? T_ENDIF ';'
    / T_WHILE parentheses_expr while_statement
    / T_DO statement T_WHILE parentheses_expr ';'
    / T_FOR '(' for_expr ';'  for_expr ';' for_expr ')' for_statement
    / T_SWITCH parentheses_expr switch_case_list
    / T_BREAK __* ';'
    / T_BREAK __* expr ';'
    / T_CONTINUE __* ';'
    / T_CONTINUE __* expr ';'
    / T_RETURN __* ';'
    / T_RETURN __* expr ';'
    / yield_expr ';'
    / T_GLOBAL global_var_list ';'
    / T_STATIC static_var_list ';'
    / T_ECHO __ tokens:expr_list __* ';'  {
      return { 
        type: 'internal.T_ECHO'
        , statements: tokens 
      }; 
    }
    / T_INLINE_HTML
    / T_UNSET '(' variables_list ')' ';'
    / T_FOREACH '(' expr T_AS foreach_variable ')' foreach_statement
    / T_FOREACH '(' expr T_AS variable T_DOUBLE_ARROW foreach_variable ')' foreach_statement
    / T_DECLARE '(' declare_list ')' declare_statement
    / ';'
    / T_TRY statements_body catches optional_finally?
    / T_THROW expr ';'
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
  = '{' case_list? '}'
  / '{' ';' case_list? '}'
  / ':' case_list? T_ENDSWITCH ';'
  / ':' ';' case_list? T_ENDSWITCH ';'

case_list
  = case*

case= (T_CASE expr/ T_DEFAULT) case_separator inner_statement*

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
  = e:constant_declaration l:( __* ',' __* constant_declaration)* { return makeList(e, l); }

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
