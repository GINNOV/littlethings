/* REXX */

chaine1 = "This program is SHAREWARE. If you like it and use it,%a contribution of US $20 is asked. Write to:"
chaine2 = "Ce programme est SHAREWARE. Si vous l'appreciez et l'utilisez,%une contribution de 100 FF est demandee. Ecrivez a :"
chaine3 = "Denis GOUNELLE%27, rue Jules Guesde%45400 FLEURY-LES-AUBRAIS%FRANCE"

SAY "STATIC UBYTE EngSharewareText[] ="
CALL Encodage( chaine1 )
SAY D2C(10) || "STATIC UBYTE FraSharewareText[] ="
CALL Encodage( chaine2 )
SAY D2C(10) || "STATIC UBYTE AddressText[] ="
CALL Encodage( chaine3 )

EXIT 0

/******************************************************************************/

Encodage: PROCEDURE
	  PARSE ARG chaine

	SAY "{ "
	resultat = "  "
	l = LENGTH( chaine )
	IF LEFT( chaine , 1 ) = '"' THEN chaine = SUBSTR( chaine , 2 )

	DO k = 1 WHILE k <= l
		c = SUBSTR( chaine , k , 1 )
		IF c ~= '%'
		THEN DO
		     c = C2D( c ) + 128 ;
		     c = "0x" || D2X( c )
		END
		ELSE c = "0x8a"
		resultat = resultat c ","
		IF LENGTH( resultat ) > 80
		THEN DO
		     SAY resultat
		     resultat = "  "
		END
	END

	SAY resultat || " 0x00" || D2C(10) || "} ;"
	RETURN 0

