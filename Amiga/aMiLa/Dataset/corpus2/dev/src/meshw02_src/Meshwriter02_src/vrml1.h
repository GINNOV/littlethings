/*
**      $VER: vrml1.h 1.00 (13.02.1999)
**
**      Creation date : 29.11.1998
**
**      Description       :
**         Standart saver module for meshwriter.library.
**         Saves the mesh as VRML 1 ascii file.
**
**
**      Written by Stephan Bielmann
**
*/

#ifndef INCLUDE_VRML1_H
#define INCLUDE_VRML1_H

/*************************** Includes *******************************/

/*
** Amiga includes
*/
#include <dos/dos.h>

/*
** Project includes
*/
#include "meshwriter_private.h"

/*************************** Functions ******************************/

/********************************************************************\
*                                                                    *
* Name         : write3VRML1                                         *
*                                                                    *
* Description  : Writes a standart VRML1 ascii file.                 *
*                                                                    *
* Arguments    : vrmlfile IN : An already opened file stream.        *
*                mesh     IN : Pointer to the mesh.                  *
*                                                                    *
* Return Value : RCNOERROR                                           *
*                RCWRITEDATA                                         *
*                                                                    *
* Comment      : Default material is the first.                      *
*                                                                    *
\********************************************************************/
extern ULONG write3VRML1(BPTR vrmlfile, TOCLMesh *mesh);

#endif

/************************* End of file ******************************/

