/*
**      $VER: geo.c 1.00 (19.02.1999)
**
**      Creation date : 19.02.1999
**
**      Description       :
**         Standart saver module for meshwriter.library.
**         Saves the mesh as Videoscape file.
**
**
**      Written by Stephan Bielmann
**
*/

#ifndef INCLUDE_GEO_H
#define INCLUDE_GEO_H

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
* Name         : write3GEOA                                          *
*                                                                    *
* Description  : Writes a standart Videoscape ASCII file.            *
*                                                                    *
* Arguments    : geofile IN  : An already opened file stream.        *
*                mesh    IN  : Pointer to the mesh.                  *
*                                                                    *
* Return Value : RCNOERROR                                           *
*                RCWRITEDATA                                         *
*                                                                    *
* Comment      :                                                     *
*                                                                    *
\********************************************************************/
extern ULONG write3GEOA(BPTR geofile, TOCLMesh *mesh);

/********************************************************************\
*                                                                    *
* Name         : write3GEOB                                          *
*                                                                    *
* Description  : Writes a standart Videoscape binary file.           *
*                                                                    *
* Arguments    : geofile IN  : An already opened file stream.        *
*                mesh    IN  : Pointer to the mesh.                  *
*                                                                    *
* Return Value : RCNOERROR                                           *
*                RCWRITEDATA                                         *
*                                                                    *
* Comment      :                                                     *
*                                                                    *
\********************************************************************/
extern ULONG write3GEOB(BPTR geofile, TOCLMesh *mesh);

#endif

/************************* End of file ******************************/
