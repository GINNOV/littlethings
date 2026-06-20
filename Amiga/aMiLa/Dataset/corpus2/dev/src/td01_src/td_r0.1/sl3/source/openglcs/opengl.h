/*
**      $VER: opengl.h 1.00 (10.4.1999)
**
**      Creation date : 10.4.1999
**
**      Description       :
**         Standart saver module for meshwriter.library.
**         Saves the mesh as OpenGL C-source code.
**
**
**      Written by Stephan Bielmann
**
*/

#ifndef INCLUDE_OPENGL_H
#define INCLUDE_OPENGL_H

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
* Name         : write3OPENGL                                        *
*                                                                    *
* Description  : Writes a standart OpenGL C-source code.             *
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
ULONG write3OPENGL(BPTR openglfile, TOCLMesh *mesh);

#endif

/************************* End of file ******************************/

