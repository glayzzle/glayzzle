MathOperators "Operators"
  = '|'
  / '&'
  / '^'
  / '.'  { return '+'; }
  / '+'
  / '-'
  / '*'
  / '/'
  / '%'

RelationalOperator "RelationalOperator"
  = '<'
  / '>'
  / '!'
  / '~'
  / '='