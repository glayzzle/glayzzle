/* lexical grammar, rewrite from zend_language_scanner.l (PHP 5.5) */
%lex

%{
  var conf = require('./php').context.conf;
@import 'lexer/tokens.js'
%}

%s INITIAL

%%

LNUM                [0-9]+
DNUM                ([0-9]*"."[0-9]+)|([0-9]+"."[0-9]*)
EXPONENT_DNUM       (({LNUM}|{DNUM})[eE][+-]?{LNUM})
HNUM                "0x"[0-9a-fA-F]+
BNUM                "0b"[01]+
LABEL               [a-zA-Z_\x7f-\xff][a-zA-Z0-9_\x7f-\xff]*
WHITESPACE          [ \n\r\t]+
TABS_AND_SPACES     [ \t]*
TOKENS              [;:,.\[\]()|^&+-\/*=%!~$<>?@]
ANY_CHAR            [^]
NEWLINE             ("\r"|"\n"|"\r\n")

@import 'lexer/initial.l'
@import 'lexer/php_main.l'
@import 'lexer/php_mixed.l'
@import 'lexer/php_strings.l'
@import 'lexer/php_numbers.l'
@import 'lexer/php_constants.l'
@import 'lexer/php_comments.l'

/lex

