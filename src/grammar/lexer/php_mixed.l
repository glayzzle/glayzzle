
<ST_LOOKING_FOR_VARNAME>{LABEL}[[}] {
	yyless(yyleng - 1);
	zend_copy_value(zendlval, yytext, yyleng);
	zendlval->type = IS_STRING;
	yy_pop_state(TSRMLS_C);
	yy_push_state(ST_IN_SCRIPTING TSRMLS_CC);
	return T_STRING_VARNAME;
}


<ST_LOOKING_FOR_VARNAME>{ANY_CHAR} {
	yyless(0);
	yy_pop_state(TSRMLS_C);
	yy_push_state(ST_IN_SCRIPTING TSRMLS_CC);
	goto restart;
}


<ST_VAR_OFFSET>[0]|([1-9][0-9]*) { /* Offset could be treated as a long */
	if (yyleng < MAX_LENGTH_OF_LONG - 1 || (yyleng == MAX_LENGTH_OF_LONG - 1 && strcmp(yytext, long_min_digits) < 0)) {
		zendlval->value.lval = strtol(yytext, NULL, 10);
		zendlval->type = IS_LONG;
	} else {
		zendlval->value.str.val = (char *)estrndup(yytext, yyleng);
		zendlval->value.str.len = yyleng;
		zendlval->type = IS_STRING;
	}
	return T_NUM_STRING;
}

<ST_VAR_OFFSET>{LNUM}|{HNUM}|{BNUM} { /* Offset must be treated as a string */
	zendlval->value.str.val = (char *)estrndup(yytext, yyleng);
	zendlval->value.str.len = yyleng;
	zendlval->type = IS_STRING;
	return T_NUM_STRING;
}


<ST_VAR_OFFSET>"]" {
	yy_pop_state(TSRMLS_C);
	return ']';
}

<ST_VAR_OFFSET>{TOKENS}|[{}"`] {
	/* Only '[' can be valid, but returning other tokens will allow a more explicit parse error */
	return yytext[0];
}

<ST_VAR_OFFSET>[ \n\r\t\\'#] {
	/* Invalid rule to return a more explicit parse error with proper line number */
	yyless(0);
	yy_pop_state(TSRMLS_C);
	return T_ENCAPSED_AND_WHITESPACE;
}

<ST_IN_SCRIPTING,ST_VAR_OFFSET>{LABEL} {
	zend_copy_value(zendlval, yytext, yyleng);
	zendlval->type = IS_STRING;
	return T_STRING;
}