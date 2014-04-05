/**
 * Glayzzle : PHP on NodeJS
 * @url http://glayzzle.com
 * @author Ioan CHIRIAC
 * @license BSD-3-Clause
 */

/*    ['T_ABSTRACT', 'abstract']
    ,['T_AND_EQUAL', '&=']
    ,['T_ARRAY', 'array']
    ,['T_ARRAY_CAST', '(array)']
    ,['T_AS', 'as']
    ,['T_BAD_CHARACTER', function(c) {
      if (c < 32 && c != 9 && c != 10 && c != 13) {
        return true
      }
    }]
    ,['T_BOOLEAN_AND', '&&']
    ,['T_BOOLEAN_OR', '||']
    ,['T_BOOL_CAST', '(bool)']
    ,['T_BREAK', 'break;']
    ,['T_CALLABLE', '']
/*T_CALLABLE	callable	callable
T_CASE	case	switch
T_CATCH	catch	Les exceptions (disponible depuis PHP 5.0.0)
T_CHARACTER	 	Plus utilisé actuellement
T_CLASS	class	classes et objets
T_CLASS_C	__CLASS__	constantes magiques (disponible depuis PHP 4.3.0)
T_CLONE	clone	classes et objets. (disponible depuis PHP 5.0.0)
T_CLOSE_TAG	?> or %>	échapper depuis le HTML
T_COMMENT	// ou #, et /* */ /*en PHP 5	commentaires
T_CONCAT_EQUAL	.=	opérateurs d'assignation
T_CONST	const	constantes de classe
T_CONSTANT_ENCAPSED_STRING	"foo" ou 'bar'	syntaxe chaîne de caractères
T_CONTINUE	continue	continue
T_CURLY_OPEN	{$	syntaxe d'analyse de variable complexe
T_DEC	--	opérateurs d'incrémention/décrémention
T_DECLARE	declare	declare
T_DEFAULT	default	switch
T_DIR	__DIR__	constantes magiques (disponible depuis PHP 5.3.0)
T_DIV_EQUAL	/=	opérateurs d'assignation
T_DNUMBER	0.12, etc.	nombres à virgule flottante
T_DOC_COMMENT	/** */ /*	style de commentaire dans la PHPDoc (disponible depuis PHP 5.0.0)
T_DO	do	do...while
T_DOLLAR_OPEN_CURLY_BRACES	${	syntaxe de variable complexe analysée
T_DOUBLE_ARROW	=>	syntaxe de tableau
T_DOUBLE_CAST	(real), (double) ou (float)	transtypage
T_DOUBLE_COLON	::	Voyez T_PAAMAYIM_NEKUDOTAYIM plus bas
T_ECHO	echo	echo
T_ELSE	else	else
T_ELSEIF	elseif	elseif
T_EMPTY	empty	empty()
T_ENCAPSED_AND_WHITESPACE	" $a"	partie des constantes d'une chaîne de caractères contenant des variables
T_ENDDECLARE	enddeclare	declare, syntaxe alternative
T_ENDFOR	endfor	for, syntaxe alternative
T_ENDFOREACH	endforeach	foreach, syntaxe alternative
T_ENDIF	endif	if, syntaxe alternative
T_ENDSWITCH	endswitch	switch, syntaxe alternative
T_ENDWHILE	endwhile	while, syntaxe alternative
T_END_HEREDOC	 	syntaxe heredoc
T_EVAL	eval()	eval()
T_EXIT	exit ou die	exit(), die()
T_EXTENDS	extends	extends, classes et objets
T_FILE	__FILE__	constantes magiques
T_FINAL	final	Mot-clé "final" (disponible depuis PHP 5.0.0)
T_FINALLY	finally	Les exceptions (disponible depuis PHP 5.5.0)
T_FOR	for	for
T_FOREACH	foreach	foreach
T_FUNCTION	function or cfunction	fonctions
T_FUNC_C	__FUNCTION__	constantes magiques (disponible depuis PHP 4.3.0)
T_GLOBAL	global	scope de variable
T_GOTO	goto	 (disponible depuis PHP 5.3.0)
T_HALT_COMPILER	__halt_compiler()	__halt_compiler (disponible depuis PHP 5.1.0)
T_IF	if	if
T_IMPLEMENTS	implements	Interfaces (disponible depuis PHP 5.0.0)
T_INC	++	opérateurs d'incrémention/décrémention
T_INCLUDE	include()	include
T_INCLUDE_ONCE	include_once()	include_once

T_INSTANCEOF	instanceof	opérateurs de type (disponible depuis PHP 5.0.0)
T_INSTEADOF	insteadof	Traits (disponible depuis PHP 5.4.0)
T_INT_CAST	(int) ou (integer)	transtypage
T_INTERFACE	interface	Interfaces (disponible depuis PHP 5.0.0)
T_ISSET	isset()	isset()
T_IS_EQUAL	==	opérateurs de comparaison
T_IS_GREATER_OR_EQUAL	>=	opérateurs de comparaison
T_IS_IDENTICAL	===	opérateurs de comparaison
T_IS_NOT_EQUAL	!= ou <>	opérateurs de comparaison
T_IS_NOT_IDENTICAL	!==	opérateurs de comparaison
T_IS_SMALLER_OR_EQUAL	<=	opérateurs de comparaison
T_LINE	__LINE__	constantes magiques
T_LIST	list()	list()
T_LNUMBER	123, 012, 0x1ac, etc	entiers
T_LOGICAL_AND	and	opérateurs logiques
T_LOGICAL_OR	or	opérateurs logiques
T_LOGICAL_XOR	xor	opérateurs logiques
T_METHOD_C	__METHOD__	constantes magiques (disponible depuis PHP 5.0.0)
T_MINUS_EQUAL	-=	opérateurs d'assignation
T_ML_COMMENT	/* et */ /*	commentaires (PHP 4 uniquement)
T_MOD_EQUAL	%=	opérateurs d'assignation
T_MUL_EQUAL	*=	opérateurs d'assignation
T_NAMESPACE	namespace	namespaces (disponible PHP 5.3.0)
T_NS_C	__NAMESPACE__	namespaces (disponible depuis PHP 5.3.0)
T_NS_SEPARATOR	\	namespaces (disponible depuis PHP 5.3.0)
T_NEW	new	classes et objets
T_NUM_STRING	"$a[0]"	index d'un tableau numérique se trouvant dans une chaîne de caractères
T_OBJECT_CAST	(object)	transtypage
T_OBJECT_OPERATOR	->	classes et objets
T_OLD_FUNCTION	old_function	(uniquement PHP 4)
T_OPEN_TAG	<?php, <? or <%	sortie du mode HTML
T_OPEN_TAG_WITH_ECHO	<?= ou <%=	sortie du mode HTML
T_OR_EQUAL	|=	opérateurs d'assignation
T_PAAMAYIM_NEKUDOTAYIM	::	::. Définie également en tant que T_DOUBLE_COLON.
T_PLUS_EQUAL	+=	opérateurs d'assignation
T_PRINT	print()	print
T_PRIVATE	private	classes et objets (disponible depuis PHP 5.0.0)
T_PUBLIC	public	classes et objets (disponible depuis PHP 5.0.0)
T_PROTECTED	protected	classes et objets (disponible depuis PHP 5.0.0)
T_REQUIRE	require()	require
T_REQUIRE_ONCE	require_once()	require_once
T_RETURN	return	valeurs retournées
T_SL	<<	opérateurs sur les bits
T_SL_EQUAL	<<=	opérateurs d'assignation
T_SR	>>	opérateurs sur les bits
T_SR_EQUAL	>>=	opérateurs d'assignation
T_START_HEREDOC	<<<	syntaxe heredoc
T_STATIC	static	scope de variable
T_STRING	parent, true etc.	identifiants, e.g. mots-clés comme parent et self, noms de fonctions, classes et autres, correspondent. Voir aussi T_CONSTANT_ENCAPSED_STRING.
T_STRING_CAST	(string)	transtypage
T_STRING_VARNAME	"${a	syntaxe d'analyse d'une variable complexe
T_SWITCH	switch	switch
T_THROW	throw	Les exceptions (disponible depuis PHP 5.0.0)
T_TRAIT	trait	Traits (disponible depuis PHP 5.4.0)
T_TRAIT_C	__TRAIT__	__TRAIT__ (disponible depuis PHP 5.4.0)
T_TRY	try	Les exceptions (disponible depuis PHP 5.0.0)
T_UNSET	unset()	unset()
T_UNSET_CAST	(unset)	type-casting (disponible depuis PHP 5.0.0)
T_USE	use	namespaces (disponible depuis PHP 5.3.0 ; réservé depuis PHP 4.0.0)
T_VAR	var	classes et objets
T_VARIABLE	$foo	variables
T_WHILE	while	while, do...while
T_WHITESPACE	\t \r\n	 
T_XOR_EQUAL	^=	opérateurs d'assignation
T_YIELD	yield	générateurs (disponible depuis PHP 5.5.0) */

module.exports = {
  tokens: {
    T_INLINE_HTML:          1
    ,T_OPEN_TAG_WITH_ECHO:  2
    ,T_OPEN_TAG:            3
  }
  ,createContext: function(buffer) {
    return {
      tokens: [],
      offset: 0,
      buffer: buffer,
      char: buffer.charAt(0),
      size: buffer.length,
      word: 0,
      start_line: 1,
      start_col: 1,
      line: 1,
      col: 1,
      next: function() {
        this.char = this.buffer.charAt(++this.offset);
        if (this.char == '\n') {
          this.line++;
          this.col = 0;
        } else if(this.char == '\r') {
          this.line++;
          this.col = 0;
          if (this.buffer.charAt(this.offset + 1) == '\n') {
            this.offset++;
          }
        }
        this.col++;
        return this.char;
      },
      read: function(next) {
        var word = this.buffer.substring(this.word, this.offset + 1);
        if (next) this.word = this.offset + 1;
        return word;
      },
      addToken: function( type, prev ) {
        this.tokens.push(
          [
            type,
            this.buffer.substring(this.word, this.offset - prev),
            this.start_line,
            this.start_col
          ]
        );
        this.start_line = this.line;
        this.start_col = this.col - prev;
        this.word = this.offset - prev;
      }
    };
  }
  ,parseHTML: function(context) {
    var c = context.char;
    do {
      if( c == '<' )  {
        c = context.next();
        if (c == '?') {
          c = context.next();
          if (c == '=') {
            context.addToken(this.tokens.T_INLINE_HTML, 2);
            context.next();
            context.addToken(this.tokens.T_OPEN_TAG_WITH_ECHO, 0);
            this.parseT_EXPR();
          } else if(
            c == 'p' 
            && context.next() == 'h' 
            && context.next() == 'p'
          ) {
            //
            context.addToken(this.tokens.T_INLINE_HTML, 5);
          }
        }
      }
    } while(c = context.next());
    return context;
  }
  /**
   * Parsing space
   */
  ,parse__: function(context) {
    
  }
  ,parseT_EXPR: function(context) {
    this.parse__();
  }
};