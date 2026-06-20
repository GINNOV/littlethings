#include "global.h"
#include "sort.h"

/* -------------------------------------------------------------------------
   NAME:    SortZBuffer
   
   AUTHOR:  Unknown (original Commodore 64 basic program)
            C version in 1992 by Terence Russell.
            
   PURPOSE: Sorts an array structure which is defined with an index range of
            0 to (maxElement-1).
            
            The sort is a Metzner Shell sort. I've done several tests on an
            Amiga 500 & 3000 with various sorts of data and have found this
            routine is just as fast as the QuickSort algorithm. As well it
            doesn't have the problem QuickSort has with sorting data which
            is nearly sorted to begin with.

   NOTE: No Copyright is claimed on this routine.
   ------------------------------------------------------------------------- */
            
void SORTWORLD(zBufferType *BUFFER, word maxElement)
{
    register word ShellSize = maxElement, loop, index, index2, preCalc;
    register word SWAP;

    while(ShellSize = ShellSize >> 1) /* >> 1 is equivalent to / 2 but faster*/
    {
	preCalc = maxElement - ShellSize; /* Faster assembly code! */
	
	for(loop = 0; loop < preCalc; loop++)
	{
	    index = loop;
	    
	    for(;;)
	    {
		index2 = index + ShellSize;
					/* Change > to < for descending values. */
		
		if( BUFFER[index][1] > BUFFER[index2][1])	/* element [x][1] is the comparison element*/
		{
		    SWAP = BUFFER[index2][0];
		    BUFFER[index2][0] = BUFFER[index][0];	/* move element 0 */
		    BUFFER[index][0] = SWAP;

		    SWAP = BUFFER[index2][1];
		    BUFFER[index2][1] = BUFFER[index][1];	/* move element 1 */
		    BUFFER[index][1] = SWAP;

		    index = index - ShellSize;
		    if(index < 0) break;
		}
	    	else break;
	    }
	}
    }   
}
