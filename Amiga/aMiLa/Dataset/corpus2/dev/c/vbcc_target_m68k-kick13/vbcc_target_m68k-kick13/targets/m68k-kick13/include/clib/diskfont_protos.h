#ifndef CLIB_DISKFONT_PROTOS_H
#define CLIB_DISKFONT_PROTOS_H


/*
**	$VER: diskfont_protos.h 34.106 (21.05.2022)
**
**	C prototypes.
**
**	Copyright © 2022 
**	All Rights Reserved
*/

#ifndef  EXEC_TYPES_H
#include <exec/types.h>
#endif
#ifndef  LIBRARIES_DOS_H
#include <libraries/dos.h>
#endif
#ifndef  LIBRARIES_DISKFONT_H
#include <libraries/diskfont.h>
#endif

struct TextFont * OpenDiskFont(struct TextAttr * textAttr);
LONG AvailFonts(STRPTR buffer, LONG bufBytes, LONG flags);
struct FontContentsHeader * NewFontContents(BPTR fontsLock, STRPTR fontName);
VOID DisposeFontContents(struct FontContentsHeader * fontContentsHeader);

#endif	/*  CLIB_DISKFONT_PROTOS_H  */
