שתשתÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿ	Include	Macros:copper.i

RegRGB		MACRO
Registre	Set	color
		Rept	\1
		CMove	0,Registre
Registre	Set	Registre+2
		EndR
		ENDM

Debut

CompteurVert.	Set	43-3
		Rept	(21*4)/2

		IF	CompteurVert.=256
CompteurVert.	SET	0
		CWait	$df,$ff
		ENDIF

		CWait	0,CompteurVert.
		CMove	0,bplcon4
		IFNE	CompteurVert.
		CMove	0,bplcon4
		ENDIF
Bank		SET	$8020
		Rept	3
		CMove	Bank,bplcon3
		RegRGB	32
Bank		SET	Bank+$2000
		Endr

		CMove	Bank,bplcon3
		RegRGB	10

CompteurVert.	Set	CompteurVert.+3
		CWait	0,CompteurVert.
		CMove	$8000,bplcon4
		IFNE	CompteurVert.
		CMove	$8000,bplcon4
		ENDIF
Bank		SET	$20
		Rept	3
		CMove	Bank,bplcon3
		RegRGB	32
Bank		SET	Bank+$2000
		Endr
		CMove	Bank,bplcon3
		RegRGB	10

CompteurVert.	Set	CompteurVert.+3
		EndR

Fin
