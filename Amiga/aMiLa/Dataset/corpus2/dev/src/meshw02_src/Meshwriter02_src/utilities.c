/*
**      $VER: utilities.c 1.00 (13.02.1999)
**
**      Creation date : 02.01.1999
**
**      Description       :
**         Utilities module for meshwriter.library.
**
**
**      Written by Stephan Bielmann
**
*/

/*************************** Includes *******************************/

/*
** Amiga includes
*/
#include <exec/types.h>

/********************** Private functions ***************************/

/********************** Public functions ****************************/

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
VOID setUBYTEArray(UBYTE *array,STRPTR text,ULONG size) {
	UBYTE i,j;
	
	for(i=0;i<size && text[i]!='\0';i++) array[i]=text[i];
	for(j=i;j<size;j++) array[j]='\0';  
}

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
ULONG stringlen (STRPTR string) {
	ULONG i;
	
	if(!string) return(0);
	
	i=0;
	while(i<10000 && string[i]!='\0') i++;

	return(i);
}

/************************* End of file ******************************/
