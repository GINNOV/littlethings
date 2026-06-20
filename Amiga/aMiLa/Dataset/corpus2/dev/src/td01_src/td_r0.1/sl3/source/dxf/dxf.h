/*
**      $VER: dxf.c 0.1 (11.4.1999)
**
**      Creation date : 11.4.1999
**
**      Description       :
**         Standart saver module for 3do.library.
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

/*************************** Functions ******************************/

/********************************************************************\
*                                                                    *
* Name         : s3Save                                              *
*                                                                    *
* Description  : Function to save the file in the by this library    *
*                supported format.                                   *
*                                                                    *
* Arguments    : meshhandle IN : Handle to the mesh.                 *
*                filename   IN : Name of the file to save.           *
*                screen     IN : Screen on which optional windows    *
*                                apear, NULL if no screen may        *
*                                be opened!                          *
*                                                                    *
* Return Value : RCNOERROR                                           *
*                RCCHGBUF                                            *
*                RCWRITEDATA                                         *
*                RCVERTEXOVERFLOW                                    *
*                RCVERTEXINPOLYGONOVERFLOW                           *
*                RCOPENWINDOW                                        *
*                RCINTERNAL                                          *
*                                                                    *
* Comment      :                                                     *
*                                                                    *
\********************************************************************/
extern ULONG __saveds ASM s3Save(register __d2 ULONG meshhandle,
                                 register __d3 STRPTR filename,
                                 register __a2 struct Screen *screen);

#endif

/************************* End of file ******************************/
