/*
**      $VER: rawb.h 1.00 (15.05.1999)
**
**      Creation date : 15.05.1999
**
**      Description       :
**         Standart 3d extension module for tdo.library.
**         Loads and saves the mesh as RAW binary file.
**
**
**      Written by Stephan Bielmann
**
*/

#ifndef INCLUDE_RAWB_H
#define INCLUDE_RAWB_H

/*************************** Includes *******************************/

/*
** Amiga includes
*/
#include <dos/dos.h>

/*
** Project includes
*/
#include "tdo_public.h"

/*************************** Functions ******************************/

extern ULONG __saveds ASM tdo3XSave(register __d1 ULONG meshhandle,register __d2 STRPTR filename,register __a0 struct Screen *screen);
extern ULONG __saveds ASM tdo3XLoad(register __d1 ULONG meshhandle,register __d2 STRPTR filename,register __d3 ULONG *erroffset,register __a0 struct Screen *screen);
extern ULONG __saveds ASM tdo3XCheckFile(register __d2 STRPTR filename);
extern STRPTR __saveds ASM tdo3XExt();
extern STRPTR __saveds ASM tdo3XName();

#endif

/************************* End of file ******************************/
