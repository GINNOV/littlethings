/*
**	$Filename: pbar.h $
**	$Release: 1.0 $
**	$Revision: 36.1 $
**	$Date: 23/07/96 $
**
**	PBar definitions, a progress bar system
**
**	(C) Copyright 1996 by Eden Software
**	All Rights Reserved
*/

#ifndef EXEC_TYPES_H
#include <exec/types.h>
#endif

#ifndef UTILITY_TAGITEM_H
#include <utility/tagitem.h>
#endif

#ifndef INTUITION_INTUITION_H
#include <intuition/intuition.h>
#endif

/* ----------------------------------------------------------------------- */

#define PB_TagBase			TAG_USER + 0x50000

/* Tags for CreatePBar() */

#define PB_VisualInfo		PB_TagBase+1			/* Visual Info */
#define PB_LeftEdge			PB_TagBase+2			/* X pos */
#define	PB_TopEdge			PB_TagBase+3			/* Y pos */
#define PB_Width			PB_TagBase+4			/* Width */
#define PB_Height			PB_TagBase+5			/* Height */
#define PB_BarColour		PB_TagBase+6			/* PBar colour */
#define PB_Window			PB_TagBase+7			/* Window for bar */

/* Tags for UpdatePBar() */
#define PB_NewValue			PB_TagBase+8			/* New percentage */
#define PB_NewColour		PB_TagBase+9			/* New colour */

/* Prototypes */
