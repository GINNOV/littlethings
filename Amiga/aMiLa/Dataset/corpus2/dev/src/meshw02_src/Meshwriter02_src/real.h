/*
**      $VER: real.h 1.00 (13.03.1999)
**
**      Creation date : 13.03.1999
**
**      Description       :
**         Standart saver module for meshwriter.library.
**         Saves the mesh as Real 3D object file.
**
**
**      Written by Stephan Bielmann
**
*/

#ifndef INCLUDE_REAL_H
#define INCLUDE_REAL_H

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
* Name         : write3REAL                                          *
*                                                                    *
* Description  : Writes a standart Real 3D V2.20 binary file.        *
*                                                                    *
* Arguments    : realfile IN : An already opened file stream.        *
*                mesh     IN : Pointer to the mesh.                  *
*                                                                    *
* Return Value : RCNOERROR                                           *
*                RCWRITEDATA                                         *
*                                                                    *
* Comment      :                                                     *
*                                                                    *
\********************************************************************/
extern ULONG write3REAL(BPTR realfile, TOCLMesh *mesh);

#endif

/************************* End of file ******************************/
