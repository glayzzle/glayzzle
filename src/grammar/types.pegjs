array_expr
  = T_ARRAY '(' array_pair_list? ')'
  / '[' array_pair_list? ']'

static_scalar
  = '[' __* a:static_array_pair_list? __* ']' { 
    return {
      type: 'common.T_ARRAY'
      ,items: a === null ? []: a
    };
  }
  / T_ARRAY __* '(' __* a:static_array_pair_list? __* ')' { 
    return {
      type: 'common.T_ARRAY'
      ,items: a === null ? []: a
    }; 
  }
  / class_name T_PAAMAYIM_NEKUDOTAYIM class_const_name
  / common_scalar

scalar "T_SCALAR"
  = class_name_or_var __* T_PAAMAYIM_NEKUDOTAYIM __* class_const_name
  / '"' encaps_list '"'
  / T_START_HEREDOC encaps_list T_END_HEREDOC
  / common_scalar

common_scalar "T_COMMON_SCALAR"
  = ('+' / '-')? (T_LNUMBER / T_DNUMBER) {
    return text();
  }
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

static_array_pair_list
  = e:static_array_pair __* l:( ',' __* static_array_pair __*)* ','? { return makeList(e, l); }

static_array_pair
  = static_scalar __* T_DOUBLE_ARROW __* static_scalar
  / static_scalar


array_pair_list
  = non_empty_array_pair_list ','?

non_empty_array_pair_list
  = array_pair (',' array_pair)*

array_pair
  = expr T_DOUBLE_ARROW expr
  / expr
  / expr T_DOUBLE_ARROW '&' variable
  / '&' variable

