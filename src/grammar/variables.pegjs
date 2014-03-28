
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

object_property
  = T_STRING
  / '{' expr '}'
  / variable_without_objects

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

object_access_for_dcnr
  = object_access_for_dcnr_expr
  / object_access_for_dcnr_expr T_OBJECT_OPERATOR object_property
  / object_access_for_dcnr_expr '[' dim_offset ']'
  / object_access_for_dcnr_expr '{' expr '}'

object_access_for_dcnr_expr
  = base_variable __ T_OBJECT_OPERATOR __ object_property

