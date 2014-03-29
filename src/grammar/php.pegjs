@import 'helpers.js'

start
  = statements:top_statement* {
    return statements;
  }

@import 'number.pegjs'
@import 'string.pegjs'
@import 'maths.pegjs'
@import 'tokens.pegjs'
@import 'statement.pegjs'
@import 'expr.pegjs'
@import 'types.pegjs'
@import 'variables.pegjs'
@import 'namespace.pegjs'
@import 'function.pegjs'
@import 'class.pegjs'
@import 'trait.pegjs'
