/*
**      $VER: imagine.h 1.00 (13.02.1999)
**
**      Creation date : 17.11.1998
**
**      Description       :
**         Standart saver module for meshwriter.library.
**         Saves the mesh as Imagine TDDD file.
**
**
**      Written by Stephan Bielmann
**
*/

#ifndef INCLUDE_IMAGINE_H
#define INCLUDE_IMAGINE_H

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
* Name         : write3TDDD                                          *
*                                                                    *
* Description  : Writes a standart imagine < 3.0 binary file.        *
*                                                                    *
* Arguments    : tdddfile IN : An already opened file stream.        *
*                mesh     IN : Pointer to the mesh.                  *
*                                                                    *
* Return Value : RCNOERROR                                           *
*                RCWRITEDATA                                         *
*                                                                    *
* Comment      : Default material is white !                         *
*                                                                    *
\********************************************************************/
extern ULONG write3TDDD(BPTR tdddfile, TOCLMesh *mesh);

/********************************************************************\
*                                                                    *
* Name         : write3TDDDH                                         *
*                                                                    *
* Description  : Writes a huge imagine binary file.                  *
*                                                                    *
* Arguments    : tdddfile IN : An already opened file stream.        *
*                mesh     IN : Pointer to the mesh.                  *
*                                                                    *
* Return Value : RCNOERROR                                           *
*                RCWRITEDATA                                         *
*                                                                    *
* Comment      : Default material is white !                         *
*                                                                    *
\********************************************************************/
extern ULONG write3TDDDH(BPTR tdddfile, TOCLMesh *mesh);

#endif

/************************* End of file ******************************/
