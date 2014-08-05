
<ST_LOOKING_FOR_VARNAME>{LABEL}[[}] {
	return T_STRING_VARNAME;
}


<ST_LOOKING_FOR_VARNAME>{ANY_CHAR} {
  this.less(0);
  this.popState();
  this.pushState("ST_IN_SCRIPTING");
  this.reject();
}


<ST_VAR_OFFSET>[0]|([1-9][0-9]*) { /* Offset could be treated as a long */
	return T_NUM_STRING;
}

<ST_VAR_OFFSET>{LNUM}|{HNUM}|{BNUM} { /* Offset must be treated as a string */
	return T_NUM_STRING;
}


<ST_VAR_OFFSET>"]" {
	return ']';
}

<ST_VAR_OFFSET>{TOKENS}|[{}"`] {
	return yytext;
}

<ST_VAR_OFFSET>[ \n\r\t\\'#] {
	return T_ENCAPSED_AND_WHITESPACE;
}

<ST_IN_SCRIPTING,ST_VAR_OFFSET>{LABEL} {
	return T_STRING;
}