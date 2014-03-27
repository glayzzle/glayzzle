{
  function makeInteger(o) {
    return parseInt(o.join(""), 10);
  }
  function makeList(a1, al) {
    var result = [a1];
    if (al && al.length > 0) {
      al.forEach(function(a) {
        result.push(a[3]);
      });
    }
    return result;
  }
}

start
  = __ statements:top_statement_list __ {
    return statements;
  }

@import 'number.pegjs'
@import 'string.pegjs'
@import 'tokens.pegjs'
@import 'unicode.pegjs'
@import 'maths.pegjs'

/** PHP LEXER **/

top_statement_list
    = top_statement*

namespace_name_parts
  = T_NS_SEPARATOR? (T_STRING T_NS_SEPARATOR)* T_STRING

namespace_name
  = namespace_name_parts

top_statement
  = statement
  / function_declaration_statement
  / class_declaration_statement
  / T_HALT_COMPILER '(' ')' ';' /** @todo **/
  / T_NAMESPACE namespace_name ';'
  / T_NAMESPACE namespace_name '{' top_statement_list '}'
  / T_NAMESPACE '{' top_statement_list '}'
  / T_USE use_declarations ';'
  / T_USE T_FUNCTION use_function_declarations ';'
  / T_USE T_CONST use_const_declarations ';'
  / constant_declaration ';'

use_declarations
  = use_declaration (',' use_declaration)*

use_declaration
  = namespace_name
  / namespace_name T_AS T_STRING
  / T_NS_SEPARATOR namespace_name
  / T_NS_SEPARATOR namespace_name T_AS T_STRING

use_function_declarations
  = use_function_declaration (',' use_function_declaration)*

use_function_declaration
  = namespace_name
  / namespace_name T_AS T_STRING
  / T_NS_SEPARATOR namespace_name
  / T_NS_SEPARATOR namespace_name T_AS T_STRING

use_const_declarations
  = use_const_declaration (',' use_const_declaration)*

use_const_declaration
  = namespace_name
  / namespace_name T_AS T_STRING
  / T_NS_SEPARATOR namespace_name
  / T_NS_SEPARATOR namespace_name T_AS T_STRING

constant_declaration_list
  = a1:constant_declaration al:( __ ',' __ constant_declaration)* { return makeList(a1, al); }

constant_declaration
  = n:T_STRING __ '=' __ v:static_scalar {
    return {
      name: n,
      value: v
    };
  }

inner_statement_list
  = inner_statement*

inner_statement
    = statement
    / function_declaration_statement
    / class_declaration_statement
    / T_HALT_COMPILER { throw new Error('__HALT_COMPILER() can only be used from the outermost scope'); }

statement
    = '{' __ statements:inner_statement_list __ '}' {
      return { type: "common.T_STATEMENTS", data: statements };
    }
    / T_IF __ condition:parentheses_expr __ statement:statement __ _elseif:elseif* _else:else_single? {
      return {
        type: "common.T_IF"
        , condition: condition
        , statement: statement
        , _elseif: _elseif
        , _else: _else
      };
    }
    / T_IF __ parentheses_expr ':' inner_statement_list __ _elseif:elseif* _else:else_single? T_ENDIF ';'
    / T_WHILE parentheses_expr while_statement
    / T_DO statement T_WHILE parentheses_expr ';'
    / T_FOR '(' for_expr ';'  for_expr ';' for_expr ')' for_statement
    / T_SWITCH parentheses_expr switch_case_list
    / T_BREAK ';'
    / T_BREAK expr ';'
    / T_CONTINUE ';'
    / T_CONTINUE expr ';'
    / T_RETURN ';'
    / T_RETURN expr ';'
    / yield_expr ';'
    / T_GLOBAL global_var_list ';'
    / T_STATIC static_var_list ';'
    / __ T_ECHO __ tokens:expr_list __ ';'		{ return { type: 'internal.T_ECHO', statements: tokens }; }
    / T_INLINE_HTML
    / __ expr:expr __ ';' __
    / T_UNSET '(' variables_list ')' ';'
    / T_FOREACH '(' expr T_AS foreach_variable ')' foreach_statement
    / T_FOREACH '(' expr T_AS variable T_DOUBLE_ARROW foreach_variable ')' foreach_statement
    / T_DECLARE '(' declare_list ')' declare_statement
    / ';'
    / T_TRY '{' inner_statement_list '}' catches optional_finally?
    / T_THROW expr ';'
    / T_GOTO T_STRING ';'
    / T_STRING ':'

catches
  = catch*

catch
  = T_CATCH '(' name T_VARIABLE ')' '{' inner_statement_list '}'

optional_finally
  = T_FINALLY '{' inner_statement_list '}'                { $$ = $3; }


variables_list
  = variable (',' variable)*

optional_ref
  = __ ref:'&'?                                   { return ref ? true : false; }

function_declaration_statement
    = phpdoc:__ T_FUNCTION  optional_ref n:T_STRING __ '(' p:parameter_list ')' __ '{' __ s:inner_statement_list __ '}' {
      return {
        type: 'function.T_DECLARE',
        meta: phpdoc,
        name: n,
        parameters: p,
        body: s
      };
    }

class_declaration_statement
  = f:(T_ABSTRACT / T_FINAL)? __ T_CLASS __ n:T_STRING __ e:extends_from? __ i:implements_list? __ '{' __ b:class_statement_list __ '}' {
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


extends_from
  = T_EXTENDS n:name            { return n; }

interface_extends_list
  = T_EXTENDS n:name_list       { return n; }

implements_list
  = T_IMPLEMENTS n:name_list    { return n; }

name_list
  = a1:name al:( __ ',' __ name)*     { return makeList(a1, al) }

for_statement
  = statement
  / ':' inner_statement_list T_ENDFOR ';'

foreach_statement
  = statement
  / ':' inner_statement_list T_ENDFOREACH ';'

declare_statement
  = statement
  / ':' inner_statement_list T_ENDDECLARE ';'

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

case
  = T_CASE expr case_separator inner_statement_list
  / T_DEFAULT case_separator inner_statement_list

case_separator
  = ':'
  / ';'

while_statement
  = statement
  / ':' inner_statement_list T_ENDWHILE ';'

elseif
  = T_ELSEIF __ c:parentheses_expr __ s:statement {
    return { type: "common.T_ELSEIF", condition: c, statement: s };
  }

else_single
  = T_ELSE __ s:statement { return { type: 'common.T_ELSE', data: s }; }

foreach_variable
  = variable
  / '&' variable
  / list_expr

parameter_list
  = non_empty_parameter_list?

non_empty_parameter_list
  = parameter (',' parameter)*

parameter
  = __ t:class_type? r:optional_ref __ v:T_VARIABLE (__ '=' __ v:static_scalar) ? {
    return { 
      type: 'function.T_PARAMETER', 
      name: v.name, 
      ref: r, 
      class: t?
      value: typeof v == 'undefined' ? null : v
    };
  }

class_type
  = name
  / T_ARRAY
  / T_CALLABLE

argument_list
  = '(' ')'  { return ['(', [], ')']; }
  / '(' __ arg1:argument argList:( __ ',' __ argument )* __ ')' {
    var args = [arg1[3] ? arg1 : arg1[1]];
    if (argList) for(var i = 0; i<argList.length; i++) {
      if (argList[i][3][3]) {
        args.push(argList[i][3]);
      } else {
        args.push(argList[i][3][1]);
      }
    }
    return ['(', {
      type: 'common.T_ARGS', args: args
    }, ')']; 
  }
  /* todo '(' yield_expr ')'  */

argument
  = expr
  / '&' variable

global_var_list
  = global_var (',' global_var)*

global_var
  = T_VARIABLE
  / '$' variable
  / '$' '{' expr '}'

static_var_list
  = static_var (',' static_var)*

static_var
  = T_VARIABLE
  / T_VARIABLE '=' static_scalar

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

trait_adaptations
  = ';'
  / '{' trait_adaptation_list '}'

trait_adaptation_list
  = trait_adaptation*

trait_adaptation
  = trait_method_reference_fully_qualified T_INSTEADOF name_list ';'
  / trait_method_reference T_AS member_modifier T_STRING ';'
  / trait_method_reference T_AS member_modifier ';'
  / trait_method_reference T_AS T_STRING ';'

trait_method_reference_fully_qualified
  =name T_PAAMAYIM_NEKUDOTAYIM T_STRING

trait_method_reference
  = trait_method_reference_fully_qualified
  / T_STRING

method_body
  = ';' /* abstract method */
  / '{' inner_statement_list '}'

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

expr_list
  = expr __ (',' __ expr __)*

for_expr
  = expr_list*

boolean_expr
  = 'true' { return true; }
  / 'false' { return false; }

expr
  /** SPECIAL PHP FUNCTIONS : **/
  = T_ISSET __ '(' __ v:variables_list __ ')'
  / T_EMPTY __ '(' __ e:expr __ ')'
  / __ i:'@'? T_INCLUDE_ONCE __ ('(' __)? t:expr (__ ')')?      { return { type: 'internal.T_INCLUDE', target: t, ignore: i, once: true }; }
  / __ i:'@'? T_INCLUDE __ '('? __  t:expr __')'?               { return { type: 'internal.T_INCLUDE', target: t, ignore: i, once: false }; }
  / __ T_REQUIRE_ONCE  __ '('? __ t:expr __')'?                 { return { type: 'internal.T_REQUIRE', target: t, once: true }; }
  / __ T_REQUIRE  __ '('? __ t:expr __')'?                      { return { type: 'internal.T_REQUIRE', target: t, once: false }; }
  / T_EVAL parentheses_expr
  / T_EXIT exit_expr?
  / T_PRINT expr

  /** **/
  / __ variable __ expr?
  / __ boolean_expr __ expr?
  / __ list_expr __ '=' expr
  / __ variable __ '=' expr
  / __ variable __ '='  __ '&' variable
  / __ variable '=' '&' new_expr
  / __ new_expr
  / __ T_CLONE expr
  / __ T_OBJECT_OPERATOR expr
  / __ variable __ (
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
  ) __ expr
  / __ variable __ T_INC __ expr?
  / __ T_INC __ variable __ expr?
  / __ variable __ T_DEC __ expr?
  / __ T_DEC variable __ expr?
  / __ MathOperators __ expr
  / __ RelationalOperator __ expr
  /* ---- LEFT RECURSION
  / nexpr T_BOOLEAN_OR nexpr
  / nexpr T_BOOLEAN_AND nexpr
  / nexpr T_LOGICAL_OR nexpr
  / nexpr T_LOGICAL_AND nexpr
  / nexpr T_LOGICAL_XOR nexpr
  / nexpr T_SL nexpr
  / nexpr T_SR nexpr
  / nexpr T_IS_IDENTICAL nexpr
  / nexpr T_IS_NOT_IDENTICAL nexpr
  / nexpr T_IS_EQUAL nexpr
  / nexpr T_IS_NOT_EQUAL nexpr
  / nexpr T_IS_SMALLER_OR_EQUAL nexpr
  / nexpr T_IS_GREATER_OR_EQUAL nexpr
  / nexpr T_INSTANCEOF class_name_reference
  / nexpr '?' nexpr ':' nexpr
  / nexpr '?' ':' nexpr
  ---*/

  / __ parentheses_expr __
  /* we need a separate '(' new_expr ')' rule to avoid problems caused by a s/r conflict */
  / '(' __ new_expr __ ')'
  / T_INT_CAST expr
  / T_DOUBLE_CAST expr
  / T_STRING_CAST expr
  / T_ARRAY_CAST expr
  / T_OBJECT_CAST expr
  / T_BOOL_CAST expr
  / T_UNSET_CAST expr
  / '@' expr
  / __ scalar __ expr?
  / __ array_expr
  / __ scalar_dereference
  / '`' backticks_expr? '`'
  / T_YIELD
  / T_FUNCTION optional_ref '(' parameter_list ')' lexical_vars? '{' inner_statement_list '}'
  / T_STATIC T_FUNCTION optional_ref '(' parameter_list ')' lexical_vars? '{' inner_statement_list '}'

parentheses_expr
  = __ '(' __ expr:expr* __ ')' __                      { return ['(', expr, ')']; }
  / __ '(' __ expr:yield_expr __ ')' __                 { return ['(', expr, ')'];}


yield_expr
  = __ T_YIELD expr
  / __ T_YIELD expr __ T_DOUBLE_ARROW __ expr

array_expr
  = T_ARRAY '(' array_pair_list? ')'
  / '[' array_pair_list? ']'

scalar_dereference
  = scalar_dereference_expr
  / scalar_dereference_expr '[' dim_offset ']'
  /* alternative array syntax missing intentionally */

scalar_dereference_expr
  = array_expr '[' dim_offset ']'
  / T_CONSTANT_ENCAPSED_STRING '[' dim_offset ']'

new_expr
  = T_NEW class_name_reference ctor_arguments?

lexical_vars
  = T_USE '(' lexical_var_list ')'

lexical_var_list
  = lexical_var ( ',' lexical_var )*

lexical_var
  = optional_ref T_VARIABLE

function_call "T_FUNCTION_CALL"
  = function_call_expr
  / function_call_expr '[' dim_offset ']'
  /* alternative array syntax missing intentionally */

function_call_expr
  = n:name a:argument_list	                                                     { return { type: 'function.T_CALL', name: n, args: a }; }
  / class_name_or_var T_PAAMAYIM_NEKUDOTAYIM T_STRING argument_list
  / class_name_or_var T_PAAMAYIM_NEKUDOTAYIM '{' expr '}' argument_list
  / static_property argument_list
  / variable_without_objects argument_list

class_name
  = T_STATIC
  / name

name
  = namespace_name_parts                              { return text(); }
  / T_NS_SEPARATOR namespace_name_parts               { return text(); }
  / T_NAMESPACE T_NS_SEPARATOR namespace_name_parts   { return text(); }

class_name_reference
  = class_name
  / dynamic_class_name_reference

dynamic_class_name_reference
  = object_access_for_dcnr
  / base_variable

class_name_or_var
  = class_name
  / reference_variable

object_access_for_dcnr
  = object_access_for_dcnr_expr
  / object_access_for_dcnr_expr T_OBJECT_OPERATOR object_property
  / object_access_for_dcnr_expr '[' dim_offset ']'
  / object_access_for_dcnr_expr '{' expr '}'

object_access_for_dcnr_expr
  = base_variable __ T_OBJECT_OPERATOR __ object_property

exit_expr
  = '(' ')'
  / parentheses_expr

backticks_expr
  = T_ENCAPSED_AND_WHITESPACE
  / encaps_list

ctor_arguments
  = argument_list

common_scalar
  = T_LNUMBER
  / T_DNUMBER
  / T_CONSTANT_ENCAPSED_STRING
  / T_LINE
  / T_FILE
  / T_DIR
  / T_CLASS_C
  / T_TRAIT_C
  / T_METHOD_C
  / T_FUNC_C
  / T_NS_C
  / T_START_HEREDOC T_ENCAPSED_AND_WHITESPACE T_END_HEREDOC
  / T_START_HEREDOC T_END_HEREDOC
  / name

static_scalar
  /* compile-time evaluated scalars */
  = common_scalar
  / class_name __ T_PAAMAYIM_NEKUDOTAYIM __ class_const_name
  / '+' __ static_scalar
  / '-' __ static_scalar
  / T_ARRAY __ '(' static_array_pair_list? ')'
  / '[' __ static_array_pair_list? __ ']'

scalar "Scalar Value"
  = common_scalar
  / class_name_or_var __ T_PAAMAYIM_NEKUDOTAYIM __ class_const_name
  / '"' encaps_list '"'
  / T_START_HEREDOC encaps_list T_END_HEREDOC

class_const_name
  = T_STRING
  / T_CLASS

static_array_pair_list
  = non_empty_static_array_pair_list optional_comma?

optional_comma = ','

non_empty_static_array_pair_list
  = static_array_pair (',' static_array_pair)*

static_array_pair
  = static_scalar T_DOUBLE_ARROW static_scalar
  / static_scalar

variable
  = base_variable /** @todo LR object_access **/
  / function_call
  / new_expr_array_deref

new_expr_array_deref
  = new_expr_array_deref_expr
  / new_expr_array_deref_expr '[' dim_offset ']'
  /* alternative array syntax missing intentionally */

new_expr_array_deref_expr
  = '(' new_expr ')' '[' dim_offset ']' 

object_access
  = object_access_expr
  / object_access_expr argument_list
  / object_access_expr '[' dim_offset ']'
  / object_access_expr '{' expr '}'

object_access_expr
  = variable_or_new_expr T_OBJECT_OPERATOR object_property
  / variable_or_new_expr T_OBJECT_OPERATOR object_property argument_list

variable_or_new_expr
  = variable
  / '(' new_expr ')'

variable_without_objects
  = reference_variable
  / T_STRING_VARNAME

base_variable
  = variable_without_objects
  / static_property

static_property
  = class_name_or_var T_PAAMAYIM_NEKUDOTAYIM '$' reference_variable
  / static_property_with_arrays

static_property_with_arrays
  = static_property_with_arrays_expr
  / static_property_with_arrays_expr '[' dim_offset ']'
  / static_property_with_arrays_expr '{' expr '}'

static_property_with_arrays_expr
  = class_name_or_var T_PAAMAYIM_NEKUDOTAYIM T_VARIABLE
  / class_name_or_var T_PAAMAYIM_NEKUDOTAYIM '$' '{' expr '}'

reference_variable
  = reference_variable_var '[' dim_offset ']'
  / reference_variable_var '{' expr '}'
  / reference_variable_var

reference_variable_var
  = T_STRING_VARNAME
  / '$' '{' expr '}'

dim_offset
  = expr?

object_property
  = T_STRING
  / '{' expr '}'
  / variable_without_objects

list_expr
  = T_LIST '(' list_expr_elements ')'

list_expr_elements
  = list_expr_element? (',' list_expr_element)*

list_expr_element
  = variable
  / list_expr

array_pair_list
  = non_empty_array_pair_list optional_comma?

non_empty_array_pair_list
  = array_pair (',' array_pair)*

array_pair
  = expr T_DOUBLE_ARROW expr
  / expr
  / expr T_DOUBLE_ARROW '&' variable
  / '&' variable

encaps_list
  = encaps_list_expr encaps_var
  / encaps_list_expr T_ENCAPSED_AND_WHITESPACE
  / encaps_list_expr

encaps_list_expr
  = encaps_var
  / T_ENCAPSED_AND_WHITESPACE encaps_var

encaps_var
  = T_VARIABLE
  / T_VARIABLE '[' encaps_var_offset ']'
  / T_VARIABLE T_OBJECT_OPERATOR T_STRING
  / T_DOLLAR_OPEN_CURLY_BRACES expr '}'
  / T_DOLLAR_OPEN_CURLY_BRACES T_STRING_VARNAME '}'
  / T_DOLLAR_OPEN_CURLY_BRACES T_STRING_VARNAME '[' expr ']' '}'
  / T_CURLY_OPEN variable '}'

encaps_var_offset
  = T_STRING
  / T_NUM_STRING
  / T_VARIABLE
