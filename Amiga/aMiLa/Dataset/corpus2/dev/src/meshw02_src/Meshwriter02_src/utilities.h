/*
**      $VER: utilities.h 1.00 (13.02.1999)
**
**      Creation date : 02.01.1999
**
**      Description       :
**         Standart saver module for meshwriter.library.
**         Saves the mesh as Reflections file.
**
**
**      Written by Stephan Bielmann
**
*/

#ifndef INCLUDE_UTILITIES_H
#define INCLUDE_UTILITIES_H

/*************************** Includes *******************************/

/*
** Amiga includes
*/
#include <exec/types.h>

/*************************** Functions ******************************/

/********************************************************************\
*                                                                    *
* Name         : setUBYTEArray                                       *
*                                                                    *
* Description  : Copies an array of n UBYTEs into another one.       *
*                                                                    *
* Arguments    : array IN/OUT: The array to copy into.               *
*                text  IN    : Text to copy into the array.          *
*                size  IN    : Size of output array.                 *
*                                                                    *
* Comment      :                                                     *
*                                                                    *
\********************************************************************/
extern VOID setUBYTEArray(UBYTE *array,STRPTR text,ULONG size);

/********************************************************************\
*                                                                    *
* Name         : stringlen                                           *
*                                                                    *
* Description  : Returns the length of a '\0' terminated string.     *
*                                                                    *
* Arguments    : string IN  : String to process.                     *
*                                                                    *
* Return Value : Lenght of the string.                               *
*                                                                    *
* Comment      : To prevent endless loops if no '\0' is found, the   *
*                lenght is limited to 10000.                         *
*                                                                    *
\********************************************************************/
extern ULONG stringlen (STRPTR string);

#endif

/************************* End of file ******************************/


