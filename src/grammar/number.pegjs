/*
 * Numbers
 */
NumericLiteral "number"
  = literal:HexIntegerLiteral !('$' / DecimalDigit) {
      return literal;
    }
  / literal:DecimalLiteral !('$' / DecimalDigit) {
      return literal;
    }

DecimalLiteral
  = DecimalIntegerLiteral "." DecimalDigit* ExponentPart? {
      return parseFloat(text());
    }
  / "." DecimalDigit+ ExponentPart? {
      return parseFloat(text());
    }
  / DecimalIntegerLiteral ExponentPart? {
      return parseFloat(text());
    }

DecimalIntegerLiteral
  = "0"
  / NonZeroDigit DecimalDigit*

DecimalDigit
  = [0-9]

NonZeroDigit
  = [1-9]

ExponentPart
  = ExponentIndicator SignedInteger

ExponentIndicator
  = "e"i

SignedInteger
  = [+-]? DecimalDigit+

HexIntegerLiteral
  = "0x"i digits:$HexDigit+ {
      return parseInt(digits, 16);
     }

HexDigit
  = [0-9a-f]i