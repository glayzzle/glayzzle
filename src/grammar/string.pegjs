StringLiteral "string"
  = '"' chars:DoubleStringCharacter* '"' {
      return {type: 'common.T_STRING', char: '"', data: chars.join("")};
    }
  / "'" chars:SingleStringCharacter* "'" {
      return {type: 'common.T_STRING', char: "'", data: chars.join("")};
    }

DoubleStringCharacter
  = !('"' / "\\") . { return text(); }
  / "\\" s:EscapeSequence { return s; }

SingleStringCharacter
  = !("'" / "\\") . { return text(); }
  / "\\" s:EscapeSequence { return s; }

EscapeSequence
  = CharacterEscapeSequence
  / "0" !DecimalDigit { return "\0"; }
  / HexEscapeSequence
  / UnicodeEscapeSequence

CharacterEscapeSequence
  = SingleEscapeCharacter
  / NonEscapeCharacter

SingleEscapeCharacter
  = "'"
  / '"'
  / "\\"
  / "b"  { return "\b";   }
  / "f"  { return "\f";   }
  / "n"  { return "\n";   }
  / "r"  { return "\r";   }
  / "t"  { return "\t";   }
  / "v"  { return "\x0B"; }   // IE does not recognize "\v".

NonEscapeCharacter
  = !(EscapeCharacter / T_EOL) . { return text(); }

EscapeCharacter
  = SingleEscapeCharacter
  / DecimalDigit
  / "x"
  / "u"

HexEscapeSequence
  = "x" digits:$(HexDigit HexDigit) {
      return String.fromCharCode(parseInt(digits, 16));
    }

UnicodeEscapeSequence
  = "u" digits:$(HexDigit HexDigit HexDigit HexDigit) {
      return String.fromCharCode(parseInt(digits, 16));
    }