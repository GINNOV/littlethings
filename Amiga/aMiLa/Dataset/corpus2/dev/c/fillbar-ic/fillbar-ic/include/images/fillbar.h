#ifndef	IMAGES_FILLBAR_H
#define	IMAGES_FILLBAR_H

/*
**	$VER: fillbar.h 43.4 (12.1.97)
**
**	Definitions for the FILLBAR BOOPSI image class
**
**	(C) Copyright 1997 Antonio Santos.
**	All Rights Reserved
*/

/*****************************************************************************/

#ifndef UTILITY_TAGITEM_H
#include <utility/tagitem.h>
#endif

/*****************************************************************************/

#define FILLBARICLASS		"fillbar.image"
#define FILLBAR_NAME		"images/fillbar.image"
#define FILLBAR_VERSION		43

/*****************************************************************************/

#define FILLBAR_Dummy				(TAG_USER+0x04000000)

#define FILLBAR_FrameAround			(FILLBAR_Dummy + 1L)	/* (BOOL)	TRUE	IG		*/
#define FILLBAR_FrameInside			(FILLBAR_Dummy + 2L)	/* (BOOL)	TRUE	IG		*/
#define FILLBAR_LabelLeft			(FILLBAR_Dummy + 3L)	/* (BOOL)	TRUE	IG		*/
#define FILLBAR_LabelRight			(FILLBAR_Dummy + 4L)	/* (BOOL)	TRUE	IG		*/
#define FILLBAR_LabelLeftString		(FILLBAR_Dummy + 5L)	/* (STRPTR)	"  0%"	I		*/
#define FILLBAR_LabelRightString	(FILLBAR_Dummy + 6L)	/* (STRPTR)	"100%"	I		*/
#define FILLBAR_LabelInside			(FILLBAR_Dummy + 7L)	/* (BOOL)	TRUE	ISG		*/
#define FILLBAR_Value				(FILLBAR_Dummy + 8L)	/* (WORD)	0		ISG		*/
#define FILLBAR_BGPen				IA_BGPen
#define FILLBAR_FGPen				IA_FGPen
//#define FILLBAR_BGPen				(FILLBAR_Dummy + 9L)	/* (WORD)	?		IS		*/
//#define FILLBAR_FGPen				(FILLBAR_Dummy + 10L)	/* (WORD)	?		IS		*/
#define FILLBAR_FillPen				(FILLBAR_Dummy + 11L)	/* (WORD)	?		IS		*/

/* also knows about SYSIA_DrawInfo, IA_Left, IA_Top, IA_Width, IA_Height */
	
/*****************************************************************************/

#endif /* IMAGES_FILLBAR_H */
