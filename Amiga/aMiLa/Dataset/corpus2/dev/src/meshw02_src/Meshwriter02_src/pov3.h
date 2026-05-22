/*
**      $VER: pov3.h 1.00 (13.02.1999)
**
**      Creation date : 29.11.1998
**
**      Description       :
**         Standart saver module for meshwriter.library.
**         Saves the mesh as POV3 ascii file.
**         POV z = Mesh y and POV y = Mesh z
**
**
**      Written by Stephan Bielmann
**
*/

#ifndef INCLUDE_POV3_H
#define INCLUDE_POV3_H

/*************************** Functions ******************************/

/********************************************************************\
*                                                                    *
* Name         : write3POV3                                          *
*                                                                    *
* Description  : Writes a standart POV3 ascii file.                  *
*                                                                    *
* Arguments    : povfile IN : An already opened file stream.         *
*                mesh    IN : Pointer to the mesh.                   *
*                                                                    *
* Return Value : RCNOERROR                                           *
*                RCWRITEDATA                                         *
*                                                                    *
* Comment      : No default material !                               *
*                                                                    *
\********************************************************************/
extern ULONG write3POV3(BPTR povfile, TOCLMesh *mesh);

#endif

/************************* End of file ******************************/
