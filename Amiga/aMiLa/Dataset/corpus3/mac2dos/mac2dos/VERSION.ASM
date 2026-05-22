*****************************************************************
*								*
*			Mac-2-Dos				*
*								*
*	The Mac to/from Amiga file conversion utility.		*
*								*
*	Copyright (c) 1989 Central Coast Software		*
*	424 Vista Avenue, Golden, CO 80401			*
*	     All rights reserved, worldwide			*
*								*
*****************************************************************

;	INCLUDE	"MAC.I"	
;	INCLUDE	"VD0:MACROS.ASM"
	INCLUDE "PRE.OBJ"

	XDEF	ProgName.
	XDEF	About0.,About1.,About2.,About3.,About4.,About5.

ProgName.
	TEXTZ	<'Mac-2-Dos V1.1d'>

About0.	TEXTZ	<'Mac-2-Dos V1.1d, February 13, 1990'>
About1.	DC.B	'Copyright ',$A9,' 1989',0
About2.	TEXTZ	<'Central Coast Software'>
About3.	TEXTZ	<'424 Vista Avenue'>
About4.	TEXTZ	<'Golden, CO 80401 USA'>
About5.	TEXTZ	<'303-526-1030'>

	END
