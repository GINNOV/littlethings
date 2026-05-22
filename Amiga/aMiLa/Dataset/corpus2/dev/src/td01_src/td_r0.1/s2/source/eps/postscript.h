/*
**      $VER: postscript.h 1.00 (4.4.1999)
**
**      Creation date : 23.01.1999
**
**      Description       :
**         Standart saver module for meshwriter.library.
**         Saves the mesh as PostScript file.
**
**
**      Written by Stephan Bielmann
**
*/

#ifndef INCLUDE_POSTSCRIPT_H
#define INCLUDE_POSTSCRIPT_H

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
* Name         : write2EPS                                           *
*                                                                    *
* Description  : Writes a standart Encapsulated PostScript ASCII     *
*                file.                                               *
*                                                                    *
* Arguments    : epsfile  IN : An already opened file stream.        *
*                mesh     IN : Pointer to the mesh.                  *
*                viewtype IN : Type of view.                         *
*                drawmode IN : Drawing mode.                         *
*                width    IN : Width of output media.                *
*                height   IN : Height of output media.               *
*                                                                    *
* Return Value : RCNOERROR                                           *
*                RCWRITEDATA                                         *
*                                                                    *
* Comment      :                                                     *
*                                                                    *
\********************************************************************/
extern ULONG write2EPS(BPTR epsfile,TOCLMesh *mesh,
                ULONG viewtype,ULONG drawmode,
                ULONG width,ULONG height);

#endif

/************************* End of file ******************************/


