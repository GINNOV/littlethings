#ifndef  CLIB_TEXTFIELD_PROTOS_H
#define  CLIB_TEXTFIELD_PROTOS_H

/*
**	$VER: textfield_protos.h 1.1 (6.10.1999)
**
**	C prototypes. For use with 32 bit integers only.
**
**	Copyright © 1999 Amiga, Inc.
**	    All Rights Reserved
*/

#ifdef __cplusplus
extern "C" {
#endif /* __cplusplus */

#ifndef  INTUITION_INTUITION_H
#include <intuition/intuition.h>
#endif
#ifndef  INTUITION_CLASSES_H
#include <intuition/classes.h>
#endif
Class *TEXTFIELD_GetClass( VOID );

#ifdef __cplusplus
}
#endif /* __cplusplus */

#endif   /* CLIB_TEXTFIELD_PROTOS_H */
