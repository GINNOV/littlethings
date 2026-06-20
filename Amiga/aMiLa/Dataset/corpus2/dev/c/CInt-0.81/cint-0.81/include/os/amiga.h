/******************************************************************************

    MODUL
	amiga.h

    DESCRIPTION
	Lokale Besonderheiten für AmigaOS.

******************************************************************************/

#ifndef AMIGA_H
#define AMIGA_H

/**************************************
		Includes
**************************************/
#ifndef EXEC_TYPES_H
#   include <exec/types.h>
#endif
#ifndef CLIB_INTUITION_PROTOS_H
#   include <clib/intuition_protos.h>
#endif
#ifndef INTUITION_CLASSUSR_H
#   include <intuition/classusr.h>
#endif


/**************************************
	    Globale Variable
**************************************/


/**************************************
	Defines und Strukturen
**************************************/


/**************************************
	       Prototypes
**************************************/
extern void GetAttrs P((Object *, Tag, ...));
extern void GetAttrsA P((Object *, struct TagItem *));


#endif /* AMIGA_H */

/******************************************************************************
*****  ENDE amiga.h
******************************************************************************/
