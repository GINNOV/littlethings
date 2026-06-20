#ifndef  CLIB_DTCLASS_PROTOS_H
#define  CLIB_DTCLASS_PROTOS_H

/*
**	$VER: dtclass_protos.h 44.1 (25.1.1993)
**
**	C prototypes. For use with 32 bit integers only.
**
**	Copyright © 1999 Amiga, Inc.
**	    All Rights Reserved
*/

#ifdef __cplusplus
extern "C" {
#endif /* __cplusplus */

#ifndef  EXEC_TYPES_H
#include <exec/types.h>
#endif
#ifndef  INTUITION_CLASSES_H
#include <intuition/classes.h>
#endif
#ifndef  INTUITION_CLASSUSR_H
#include <intuition/classusr.h>
#endif
/*--- functions in V39 or higher (Release 3) ---*/

Class *ObtainEngine( VOID );

#ifdef __cplusplus
}
#endif /* __cplusplus */

#endif   /* CLIB_DTCLASS_PROTOS_H */
