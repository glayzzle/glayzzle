
<INITIAL>"<script"{WHITESPACE}+"language"{WHITESPACE}*"="{WHITESPACE}*("php"|"\"php\""|"'php'"){WHITESPACE}*">" {
	YYCTYPE *bracket = (YYCTYPE*)zend_memrchr(yytext, '<', yyleng - (sizeof("script language=php>") - 1));

	if (bracket != SCNG(yy_text)) {
		/* Handle previously scanned HTML, as possible <script> tags found are assumed to not be PHP's */
		YYCURSOR = bracket;
		goto inline_html;
	}

	HANDLE_NEWLINES(yytext, yyleng);
	zendlval->value.str.val = yytext; /* no copying - intentional */
	zendlval->value.str.len = yyleng;
	zendlval->type = IS_STRING;
	BEGIN(ST_IN_SCRIPTING);
	return T_OPEN_TAG;
}


<INITIAL>"<%=" {
	if (CG(asp_tags)) {
		zendlval->value.str.val = yytext; /* no copying - intentional */
		zendlval->value.str.len = yyleng;
		zendlval->type = IS_STRING;
		BEGIN(ST_IN_SCRIPTING);
		return T_OPEN_TAG_WITH_ECHO;
	} else {
		goto inline_char_handler;
	}
}


<INITIAL>"<?=" {
	zendlval->value.str.val = yytext; /* no copying - intentional */
	zendlval->value.str.len = yyleng;
	zendlval->type = IS_STRING;
	BEGIN(ST_IN_SCRIPTING);
	return T_OPEN_TAG_WITH_ECHO;
}


<INITIAL>"<%" {
	if (CG(asp_tags)) {
		zendlval->value.str.val = yytext; /* no copying - intentional */
		zendlval->value.str.len = yyleng;
		zendlval->type = IS_STRING;
		BEGIN(ST_IN_SCRIPTING);
		return T_OPEN_TAG;
	} else {
		goto inline_char_handler;
	}
}


<INITIAL>"<?php"([ \t]|{NEWLINE}) {
	zendlval->value.str.val = yytext; /* no copying - intentional */
	zendlval->value.str.len = yyleng;
	zendlval->type = IS_STRING;
	HANDLE_NEWLINE(yytext[yyleng-1]);
	BEGIN(ST_IN_SCRIPTING);
	return T_OPEN_TAG;
}


<INITIAL>"<?" {
	if (CG(short_tags)) {
		zendlval->value.str.val = yytext; /* no copying - intentional */
		zendlval->value.str.len = yyleng;
		zendlval->type = IS_STRING;
		BEGIN(ST_IN_SCRIPTING);
		return T_OPEN_TAG;
	} else {
		goto inline_char_handler;
	}
}

<INITIAL>{ANY_CHAR} {
	if (YYCURSOR > YYLIMIT) {
		return 0;
	}

inline_char_handler:

	while (1) {
		YYCTYPE *ptr = memchr(YYCURSOR, '<', YYLIMIT - YYCURSOR);

		YYCURSOR = ptr ? ptr + 1 : YYLIMIT;

		if (YYCURSOR < YYLIMIT) {
			switch (*YYCURSOR) {
				case '?':
					if (CG(short_tags) || !strncasecmp((char*)YYCURSOR + 1, "php", 3) || (*(YYCURSOR + 1) == '=')) { /* Assume [ \t\n\r] follows "php" */
						break;
					}
					continue;
				case '%':
					if (CG(asp_tags)) {
						break;
					}
					continue;
				case 's':
				case 'S':
					/* Probably NOT an opening PHP <script> tag, so don't end the HTML chunk yet
					 * If it is, the PHP <script> tag rule checks for any HTML scanned before it */
					YYCURSOR--;
					yymore();
				default:
					continue;
			}

			YYCURSOR--;
		}

		break;
	}

inline_html:
	yyleng = YYCURSOR - SCNG(yy_text);

	if (SCNG(output_filter)) {
		int readsize;
		size_t sz = 0;
		readsize = SCNG(output_filter)((unsigned char **)&(zendlval->value.str.val), &sz, (unsigned char *)yytext, (size_t)yyleng TSRMLS_CC);
		zendlval->value.str.len = sz;
		if (readsize < yyleng) {
			yyless(readsize);
		}
	} else {
	  zendlval->value.str.val = (char *) estrndup(yytext, yyleng);
	  zendlval->value.str.len = yyleng;
	}
	zendlval->type = IS_STRING;
	HANDLE_NEWLINES(yytext, yyleng);
	return T_INLINE_HTML;
}


<ST_IN_SCRIPTING>("?>"|"</script"{WHITESPACE}*">"){NEWLINE}? {
	zendlval->value.str.val = yytext; /* no copying - intentional */
	zendlval->value.str.len = yyleng;
	zendlval->type = IS_STRING;
	BEGIN(INITIAL);
	return T_CLOSE_TAG;  /* implicit ';' at php-end tag */
}


<ST_IN_SCRIPTING>"%>"{NEWLINE}? {
	if (CG(asp_tags)) {
		BEGIN(INITIAL);
		zendlval->value.str.len = yyleng;
		zendlval->type = IS_STRING;
		zendlval->value.str.val = yytext; /* no copying - intentional */
		return T_CLOSE_TAG;  /* implicit ';' at php-end tag */
	} else {
		yyless(1);
		return yytext[0];
	}
}