/*
**      $VER: dxf.h 1.00 (31.02.1999)
**
**      Creation date : 06.12.1998
**
**      Description       :
**         Standart saver module for meshwriter.library.
**         Saves the mesh as DXF ascii file.
**
**
**      Written by Stephan Bielmann
**
*/

#ifndef INCLUDE_DXF_H
#define INCLUDE_DXF_H

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
* Name         : write3DXF                                           *
*                                                                    *
* Description  : Writes a standart DXF ascii file.                   *
*                                                                    *
* Arguments    : dxffile IN  : An already opened file stream.        *
*                mesh    IN  : Pointer to the mesh.                  *
*                                                                    *
* Return Value : RCNOERROR                                           *
*                RCWRITEDATA                                         *
*                                                                    *
* Comment      :                                                     *
*                                                                    *
\********************************************************************/
extern ULONG write3DXF(BPTR dxffile, TOCLMesh *mesh);

#endif

/************************* End of file ******************************/
