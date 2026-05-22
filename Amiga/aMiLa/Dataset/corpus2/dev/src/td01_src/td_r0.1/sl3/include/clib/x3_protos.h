/*
**      $VER: x3_protos.h 0.1 (15.5.99)
**
**      Creation Date : 11.4.1999
**
**      prototypes for x3 libraries
**
**
**      Writen by Stephan Bielmann
**
*/

#ifndef CLIB_X3_PROTOS_H
#define CLIB_X3_PROTOS_H

#ifndef X3_X3_H
#include <X3/x3.h>
#endif /* X3_X3_H */

ULONG tdo3XSave(ULONG meshhandle,STRPTR filename,struct Screen *screen);
ULONG tdo3XLoad(ULONG meshhandle,STRPTR filename,ULONG *erroffset,struct Screen *screen);
ULONG tdo3XCheckFile(STRPTR filename);
STRPTR tdo3XExt();
STRPTR tdo3XName();

#endif /* CLIB_X3_PROTOS_H */
