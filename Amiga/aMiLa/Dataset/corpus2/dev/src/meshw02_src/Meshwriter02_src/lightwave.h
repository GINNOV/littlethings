/*
**      $VER: lightwave.h 1.00 (13.02.1999)
**
**      Creation date : 17.11.1998
**
**      Description       :
**         Standart saver module for meshwriter.library.
**         Saves the mesh as Lightwave file.
**
**
**      Written by Stephan Bielmann
**
*/

#ifndef INCLUDE_LIGHTWAVE_H
#define INCLUDE_LIGHTWAVE_H

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
* Name         : write3LWOB                                          *
*                                                                    *
* Description  : Writes a standart lightwave object binary file.     *
*                Revision date : 28.11.1994                          *
*                                                                    *
* Arguments    : lwobfile  IN : An already opened file stream.       *
*                mesh      IN : Pointer to the mesh.                 *
*                                                                    *
* Return Value : RCNOERROR                                           *
*                RCWRITEDATA                                         *
*                RCVERTEXOVERFLOW                                    *
*                                                                    *
* Comment      :                                                     *
*                                                                    *
\********************************************************************/
extern ULONG write3LWOB(BPTR lwobfile, TOCLMesh *mesh);

#endif

/************************* End of file ******************************/
