/*
**      $VER: geoa.h 1.00 (19.6.1999)
**
**      Creation date : 8.5.1999
**
**      Description       :
**         Standart 3d extension module for tdo.library.
**         Loads and saves the mesh as Videoscape ASCII file.
**
**
**      Written by Stephan Bielmann
**
*/

#ifndef INCLUDE_GEOA_H
#define INCLUDE_GEOA_H

/*************************** Includes *******************************/

/*
** Amiga includes
*/
#include <dos/dos.h>

/*
** Project includes
*/
#include "td_public.h"

/*************************** Functions ******************************/

extern TDerrors __saveds ASM td3XSave(register __d1 ULONG spacehandle,register __d2 STRPTR filename,register __d3 TDenum type,register __d4 ULONG index,register __a0 struct Screen *screen);
extern TDerrors __saveds ASM td3XLoad(register __d1 ULONG spacehandle,register __d2 STRPTR filename,register __d3 TDenum type,register __a0 struct Screen *screen,register __d4 ULONG *erroffset);
extern TDerrors __saveds ASM td3XCheckFile(register __d2 STRPTR filename);
extern STRPTR __saveds ASM td3XExt();
extern STRPTR __saveds ASM td3XName();
extern ULONG __saveds ASM td3XSaverSupports(register __d1 TDenum type);
extern ULONG __saveds ASM td3XLoaderSupports(register __d1 TDenum type);

#endif

/************************* End of file ******************************/
