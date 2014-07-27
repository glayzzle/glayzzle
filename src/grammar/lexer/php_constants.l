
<ST_IN_SCRIPTING>"__CLASS__" {
	const char *class_name = NULL;
	
	if (CG(active_class_entry)
		&& (ZEND_ACC_TRAIT ==
			(CG(active_class_entry)->ce_flags & ZEND_ACC_TRAIT))) {
		/* We create a special __CLASS__ constant that is going to be resolved
		   at run-time */
		zendlval->value.str.len = sizeof("__CLASS__")-1;
		zendlval->value.str.val = estrndup("__CLASS__", zendlval->value.str.len);
		zendlval->type = IS_CONSTANT;
	} else {
		if (CG(active_class_entry)) {
			class_name = CG(active_class_entry)->name;
		}
		
		if (!class_name) {
			class_name = "";
		}
		
		zendlval->value.str.len = strlen(class_name);
		zendlval->value.str.val = estrndup(class_name, zendlval->value.str.len);
		zendlval->type = IS_STRING;
	}
	return T_CLASS_C;
}

<ST_IN_SCRIPTING>"__TRAIT__" {
	const char *trait_name = NULL;
	
	if (CG(active_class_entry)
		&& (ZEND_ACC_TRAIT == 
			(CG(active_class_entry)->ce_flags & ZEND_ACC_TRAIT))) {
		trait_name = CG(active_class_entry)->name;
	}
	
	if (!trait_name) {
		trait_name = "";
	}
	
	zendlval->value.str.len = strlen(trait_name);
	zendlval->value.str.val = estrndup(trait_name, zendlval->value.str.len);
	zendlval->type = IS_STRING;
	
	return T_TRAIT_C;
}

<ST_IN_SCRIPTING>"__FUNCTION__" {
	const char *func_name = NULL;

	if (CG(active_op_array)) {
		func_name = CG(active_op_array)->function_name;
	}

	if (!func_name) {
		func_name = "";
	}
	zendlval->value.str.len = strlen(func_name);
	zendlval->value.str.val = estrndup(func_name, zendlval->value.str.len);
	zendlval->type = IS_STRING;
	return T_FUNC_C;
}

<ST_IN_SCRIPTING>"__METHOD__" {
	const char *class_name = CG(active_class_entry) ? CG(active_class_entry)->name : NULL;
	const char *func_name = CG(active_op_array)? CG(active_op_array)->function_name : NULL;
	size_t len = 0;

	if (class_name) {
		len += strlen(class_name) + 2;
	}
	if (func_name) {
		len += strlen(func_name);
	}

	zendlval->value.str.len = zend_spprintf(&zendlval->value.str.val, 0, "%s%s%s",
		class_name ? class_name : "",
		class_name && func_name ? "::" : "",
		func_name ? func_name : ""
		);
	zendlval->type = IS_STRING;
	return T_METHOD_C;
}

<ST_IN_SCRIPTING>"__LINE__" {
	zendlval->value.lval = CG(zend_lineno);
	zendlval->type = IS_LONG;
	return T_LINE;
}

<ST_IN_SCRIPTING>"__FILE__" {
	char *filename = zend_get_compiled_filename(TSRMLS_C);

	if (!filename) {
		filename = "";
	}
	zendlval->value.str.len = strlen(filename);
	zendlval->value.str.val = estrndup(filename, zendlval->value.str.len);
	zendlval->type = IS_STRING;
	return T_FILE;
}

<ST_IN_SCRIPTING>"__DIR__" {
	char *filename = zend_get_compiled_filename(TSRMLS_C);
	const size_t filename_len = strlen(filename);
	char *dirname;

	if (!filename) {
		filename = "";
	}

	dirname = estrndup(filename, filename_len);
	zend_dirname(dirname, filename_len);

	if (strcmp(dirname, ".") == 0) {
		dirname = erealloc(dirname, MAXPATHLEN);
#if HAVE_GETCWD
		VCWD_GETCWD(dirname, MAXPATHLEN);
#elif HAVE_GETWD
		VCWD_GETWD(dirname);
#endif
	}

	zendlval->value.str.len = strlen(dirname);
	zendlval->value.str.val = dirname;
	zendlval->type = IS_STRING;
	return T_DIR;
}

<ST_IN_SCRIPTING>"__NAMESPACE__" {
	if (CG(current_namespace)) {
		*zendlval = *CG(current_namespace);
		zval_copy_ctor(zendlval);
	} else {
		ZVAL_EMPTY_STRING(zendlval);
	}
	return T_NS_C;
}