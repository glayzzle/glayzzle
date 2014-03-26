{
  function makeInteger(o) {
    return parseInt(o.join(""), 10);
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
  = constant_declaration (',' constant_declaration)*

constant_declaration
  = T_STRING '=' static_scalar

inner_statement_list
  = inner_statement*

inner_statement
    = statement
    / function_declaration_statement
    / class_declaration_statement
    / T_HALT_COMPILER { throw new Error('__HALT_COMPILER() can only be used from the outermost scope'); }

statement
    = '{' __ statements:inner_statement_list __ '}' {
      return { type: "php_statements", data: statements };
    }
    / T_IF __ condition:parentheses_expr __ statement:statement __ _elseif:elseif* _else:else_single? {
      return {
        type: "php_if"
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
    / __ T_ECHO __ tokens:expr_list __ ';'		{ return { type: 'php_T_ECHO', statements: tokens }; }
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
    = phpdoc:__ T_FUNCTION  optional_ref name:T_STRING __ '(' parameters:parameter_list ')' __ '{' __ statements:inner_statement_list __ '}' {
      return {
        type: 'php_function',
        meta: phpdoc,
        name: name,
        parameters: parameters,
        body: statements
      };
    }

class_declaration_statement
  = class_entry_type T_STRING extends_from? implements_list? '{' class_statement_list '}'
  / T_INTERFACE T_STRING interface_extends_list? '{' class_statement_list '}'
  / T_TRAIT T_STRING '{' class_statement_list '}'

class_entry_type
  = T_CLASS
  / T_ABSTRACT T_CLASS
  / T_FINAL T_CLASS

extends_from
  = T_EXTENDS name

interface_extends_list
  = T_EXTENDS name_list

implements_list
  = T_IMPLEMENTS name_list

name_list
  = name (',' name)*

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
  = T_ELSEIF __ condition:parentheses_expr __ statement:statement {
    return { type: "php_elseif", condition: condition, statement: statement };
  }

else_single
  = T_ELSE __ statement:statement { return { type: 'php_else', data: statement }; }

foreach_variable
  = variable
  / '&' variable
  / list_expr

parameter_list
  = non_empty_parameter_list?

non_empty_parameter_list
  = parameter (',' parameter)*

parameter
  = __ type:class_type? ref:optional_ref __ param:T_VARIABLE                                    { return { type: 'php_parameter', name: param.name, ref: ref, class: type }; }
  / __ type:class_type? ref:optional_ref __ param:T_VARIABLE __ '=' __ value:static_scalar      { return { type: 'php_parameter', name: param.name, ref: ref, class: type, default: value }; }

class_type
  = name
  / T_ARRAY
  / T_CALLABLE

argument_list
  = '(' ')'                                                     { return ['(', [], ')']; }
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
      type: 'php_args', args: args
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
  = variable_modifiers property_declaration_list ';'
  / T_CONST constant_declaration_list ';'
  / method_modifiers T_FUNCTION optional_ref T_STRING '(' parameter_list ')' method_body
  / T_USE name_list trait_adaptations

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
  / T_VAR

method_modifiers
  = non_empty_member_modifiers

non_empty_member_modifiers
  = member_modifier+

member_modifier
  = T_PUBLIC
  / T_PROTECTED
  / T_PRIVATE
  / T_STATIC
  / T_ABSTRACT
  / T_FINAL

property_declaration_list
  = property_declaration (',' property_declaration)*

property_declaration
  = T_VARIABLE
  / T_VARIABLE '=' static_scalar

expr_list
  = expr __ (',' __ expr __)*

for_expr
  = expr_list*

boolean_expr
  = 'true' { return true; }
  / 'false' { return false; }

expr
  = __ variable __ expr?
  / __ boolean_expr __ expr?
  / __ list_expr __ '=' expr
  / __ variable __ '=' expr
  / __ variable __ '='  __ '&' variable
  / __ variable '=' '&' new_expr
  / __ new_expr
  / __ T_CLONE expr
  / __ variable __ T_PLUS_EQUAL __ expr
  / __ variable __ T_MINUS_EQUAL __ expr
  / __ variable __ T_MUL_EQUAL __ expr
  / __ variable __ T_DIV_EQUAL __ expr
  / __ variable __ T_CONCAT_EQUAL __ expr
  / __ variable __ T_MOD_EQUAL __ expr
  / __ variable __ T_AND_EQUAL __ expr
  / __ variable __ T_OR_EQUAL __ expr
  / __ variable __ T_XOR_EQUAL __ expr
  / __ variable __ T_SL_EQUAL __ expr
  / __ variable __ T_SR_EQUAL __ expr
  / __ variable __ T_INC
  / __ T_INC variable __
  / __ variable T_DEC __
  / __ T_DEC variable __
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
  / T_ISSET '(' variables_list ')'
  / T_EMPTY '(' expr ')'
  / T_INCLUDE expr
  / T_INCLUDE_ONCE expr
  / T_EVAL parentheses_expr
  / T_REQUIRE expr
  / T_REQUIRE_ONCE expr
  / T_INT_CAST expr
  / T_DOUBLE_CAST expr
  / T_STRING_CAST expr
  / T_ARRAY_CAST expr
  / T_OBJECT_CAST expr
  / T_BOOL_CAST expr
  / T_UNSET_CAST expr
  / T_EXIT exit_expr?
  / '@' expr
  / __ scalar __ expr?
  / __ array_expr
  / __ scalar_dereference
  / '`' backticks_expr? '`'
  / T_PRINT expr
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

function_call
  = function_call_expr
  / function_call_expr '[' dim_offset ']'
  /* alternative array syntax missing intentionally */

function_call_expr
  = name:name args:argument_list	{ return { type: 'php_FUNCTION_CALL', name: name, args: args }; }
  / class_name_or_var T_PAAMAYIM_NEKUDOTAYIM T_STRING argument_list
  / class_name_or_var T_PAAMAYIM_NEKUDOTAYIM '{' expr '}' argument_list
  / static_property argument_list
  / variable_without_objects argument_list

class_name
  = T_STATIC
  / name

name
  = namespace_name_parts								{ return text(); }
  / T_NS_SEPARATOR namespace_name_parts					{ return text(); }
  / T_NAMESPACE T_NS_SEPARATOR namespace_name_parts		{ return text(); }

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
  = base_variable T_OBJECT_OPERATOR object_property

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
  / class_name T_PAAMAYIM_NEKUDOTAYIM class_const_name
  / __ '+' __ static_scalar
  / __ '-' __ static_scalar
  / T_ARRAY '(' static_array_pair_list? ')'
  / '[' static_array_pair_list? ']'

scalar "Scalar Value"
  = common_scalar
  / class_name_or_var T_PAAMAYIM_NEKUDOTAYIM class_const_name
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

IdentifierStart
  = '$'+

Identifier
  = IdentifierStart name:T_STRING                       { return { type: 'php_variable', name: name }; }

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
  / Identifier

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
  = Identifier
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
