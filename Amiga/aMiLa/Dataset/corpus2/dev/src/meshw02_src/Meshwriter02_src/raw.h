/*
**      $VER: raw.h 1.00 (13.02.1999)
**
**      Creation date : 19.11.1998
**
**      Description       :
**         Standart saver module for meshwriter.library.
**         Saves the mesh as RAW file.
**
**
**      Written by Stephan Bielmann
**
*/

#ifndef INCLUDE_RAW_H
#define INCLUDE_RAW_H

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
* Name         : write3RAWA                                          *
*                                                                    *
* Description  : Writes a standart RAW ascii file.                   *
*                                                                    *
* Arguments    : rawfile IN  : An already opened file stream.        *
*                mesh    IN  : Pointer to the mesh.                  *
*                                                                    *
* Return Value : RCNOERROR                                           *
*                RCWRITEDATA                                         *
*                                                                    *
* Comment      :                                                     *
*                                                                    *
\********************************************************************/
extern ULONG write3RAWA(BPTR rawfile, TOCLMesh *mesh);

/********************************************************************\
*                                                                    *
* Name         : write3RAWB                                          *
*                                                                    *
* Description  : Writes a standart RAW binary file.                  *
*                                                                    *
* Arguments    : rawfile IN  : An already opened file stream.        *
*                mesh    IN  : Pointer to the mesh.                  *
*                                                                    *
* Return Value : RCNOERROR                                           *
*                RCWRITEDATA                                         *
*                                                                    *
* Comment      :                                                     *
*                                                                    *
\********************************************************************/
extern ULONG write3RAWB(BPTR rawfile, TOCLMesh *mesh);

#endif

/************************* End of file ******************************/
