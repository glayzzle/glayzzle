
<ST_IN_SCRIPTING>{BNUM} {
	char *bin = yytext + 2; /* Skip "0b" */
	int len = yyleng - 2;

	/* Skip any leading 0s */
	while (*bin == '0') {
		++bin;
		--len;
	}

	if (len < SIZEOF_LONG * 8) {
		if (len == 0) {
			zendlval->value.lval = 0;
		} else {
			zendlval->value.lval = strtol(bin, NULL, 2);
		}
		zendlval->type = IS_LONG;
		return T_LNUMBER;
	} else {
		zendlval->value.dval = zend_bin_strtod(bin, NULL);
		zendlval->type = IS_DOUBLE;
		return T_DNUMBER;
	}
}

<ST_IN_SCRIPTING>{LNUM} {
	if (yyleng < MAX_LENGTH_OF_LONG - 1) { /* Won't overflow */
		zendlval->value.lval = strtol(yytext, NULL, 0);
	} else {
		errno = 0;
		zendlval->value.lval = strtol(yytext, NULL, 0);
		if (errno == ERANGE) { /* Overflow */
			if (yytext[0] == '0') { /* octal overflow */
				zendlval->value.dval = zend_oct_strtod(yytext, NULL);
			} else {
				zendlval->value.dval = zend_strtod(yytext, NULL);
			}
			zendlval->type = IS_DOUBLE;
			return T_DNUMBER;
		}
	}

	zendlval->type = IS_LONG;
	return T_LNUMBER;
}

<ST_IN_SCRIPTING>{HNUM} {
	char *hex = yytext + 2; /* Skip "0x" */
	int len = yyleng - 2;

	/* Skip any leading 0s */
	while (*hex == '0') {
		hex++;
		len--;
	}

	if (len < SIZEOF_LONG * 2 || (len == SIZEOF_LONG * 2 && *hex <= '7')) {
		if (len == 0) {
			zendlval->value.lval = 0;
		} else {
			zendlval->value.lval = strtol(hex, NULL, 16);
		}
		zendlval->type = IS_LONG;
		return T_LNUMBER;
	} else {
		zendlval->value.dval = zend_hex_strtod(hex, NULL);
		zendlval->type = IS_DOUBLE;
		return T_DNUMBER;
	}
}


<ST_IN_SCRIPTING>{DNUM}|{EXPONENT_DNUM} {
	zendlval->value.dval = zend_strtod(yytext, NULL);
	zendlval->type = IS_DOUBLE;
	return T_DNUMBER;
}
