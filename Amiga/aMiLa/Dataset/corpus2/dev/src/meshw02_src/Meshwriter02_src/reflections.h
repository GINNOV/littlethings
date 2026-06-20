/*
**      $VER: reflections.h 1.00 (13.02.1999)
**
**      Creation date : 02.01.1999
**
**      Description       :
**         Standart saver module for meshwriter.library.
**         Saves the mesh as Reflections file.
**
**
**      Written by Stephan Bielmann
**
*/

#ifndef INCLUDE_REFLECTIONS_H
#define INCLUDE_REFLECTIONS_H

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
* Name         : write3REF4                                          *
*                                                                    *
* Description  : Writes a standart reflections 4.X binary file.      *
*                Revision 9 dated : 01.09.1996                       *
*                                                                    *
* Arguments    : reffile  IN : An already opened file stream.        *
*                mesh     IN : Pointer to the mesh.                  *
*                                                                    *
* Return Value : RCNOERROR                                           *
*                RCWRITEDATA                                         *
*                                                                    *
* Comment      : No default material.                                *
*                                                                    *
\********************************************************************/
extern ULONG write3REF4(BPTR reffile, TOCLMesh *mesh);

#endif

/************************* End of file ******************************/
