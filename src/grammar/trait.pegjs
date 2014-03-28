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
