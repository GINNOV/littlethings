/*
**      $VER: postscript.h 1.00 (20.02.1999)
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
*                                                                    *
* Return Value : RCNOERROR                                           *
*                RCWRITEDATA                                         *
*                                                                    *
* Comment      :                                                     *
*                                                                    *
\********************************************************************/
extern ULONG write2EPS(BPTR epsfile,TOCLMesh *mesh,ULONG viewtype,ULONG drawmode);

/********************************************************************\
*                                                                    *
* Name         : write2PSP                                           *
*                                                                    *
* Description  : Writes a standart PostScript ASCII file, for a      *
*                portrait visualisation, A4 portrait for example.    *
*                But this one is independent of the page/display     *
*                size.                                               *
*                                                                    *
* Arguments    : psfile   IN : An already opened file stream.        *
*                mesh     IN : Pointer to the mesh.                  *
*                viewtype IN : Type of view.                         *
*                drawmode IN : Drawing mode.                         *
*                                                                    *
* Return Value : RCNOERROR                                           *
*                RCWRITEDATA                                         *
*                                                                    *
* Comment      :                                                     *
*                                                                    *
\********************************************************************/
extern ULONG write2PSP(BPTR psfile,TOCLMesh *mesh,ULONG viewtype,ULONG drawmode);

/********************************************************************\
*                                                                    *
* Name         : write2PSL                                           *
*                                                                    *
* Description  : Writes a standart PostScript ASCII file, for a      *
*                landscape visualisation, A4 landscape for example.  *
*                But this one is independent of the page/display     *
*                size.                                               *
*                                                                    *
* Arguments    : psfile   IN : An already opened file stream.        *
*                mesh     IN : Pointer to the mesh.                  *
*                viewtype IN : Type of view.                         *
*                drawmode IN : Drawing mode.                         *
*                                                                    *
* Return Value : RCNOERROR                                           *
*                RCWRITEDATA                                         *
*                                                                    *
* Comment      :                                                     *
*                                                                    *
\********************************************************************/
extern ULONG write2PSL(BPTR psfile,TOCLMesh *mesh,ULONG viewtype,ULONG drawmode);

#endif

/************************* End of file ******************************/


