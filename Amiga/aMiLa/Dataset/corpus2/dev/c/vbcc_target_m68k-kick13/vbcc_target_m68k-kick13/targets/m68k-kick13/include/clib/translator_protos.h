#ifndef CLIB_TRANSLATOR_PROTOS_H
#define CLIB_TRANSLATOR_PROTOS_H


/*
**	$VER: translator_protos.h 34.106 (21.05.2022)
**
**	C prototypes.
**
**	Copyright © 2022 
**	All Rights Reserved
*/

#ifndef  EXEC_TYPES_H
#include <exec/types.h>
#endif

LONG Translate(const STRPTR inputString, LONG inputLength, STRPTR outputBuffer,
	LONG bufferSize);

#endif	/*  CLIB_TRANSLATOR_PROTOS_H  */
