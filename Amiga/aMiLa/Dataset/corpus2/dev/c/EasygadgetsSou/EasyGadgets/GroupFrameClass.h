/*
 *	File:					GroupFrameClass.h
 *	Description:	Groupframe BOOPSI class
 *
 *	(C) 1995, Ketil Hunn
 *
 */

#ifndef EG_GROUPFRAMECLASS_H
#define EG_GROUPFRAMECLASS_H

/*** PRIVATE INCLUDES ****************************************************************/
#include <intuition/classes.h>

/*** DEFINES *************************************************************************/
#define GFA_Dummy      (IA_Dummy+10000)
#define GFA_Title      GFA_Dummy+1
#define GFA_Underscore GFA_Dummy+2

/*** GLOBALS *************************************************************************/
extern Class *GroupFrameClass;

/*** PROTOTYPES **********************************************************************/
BOOL InitializeGroupFrameClass(void);
BOOL FreeGroupFrameClass(void);

#endif
