
namespace_statement
  = T_NAMESPACE namespace_name ';'
  / T_NAMESPACE namespace_name '{' __ top_statement* __ '}'
  / T_NAMESPACE '{' top_statement* '}'
  / T_USE use_declarations ';'
  / T_USE T_FUNCTION use_function_declarations ';'
  / T_USE T_CONST use_const_declarations ';'

namespace_name_parts
  = T_NS_SEPARATOR? (T_STRING T_NS_SEPARATOR)* T_STRING

namespace_name
  = namespace_name_parts
  

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
