/*********************************************************************

	A small program to test the functions in "clip.h"
	
	This code is public domain in all respects.
	D. Keletsekis, 30 July 1998

**********************************************************************/

// some of these may not be needed..
#include <exec/exec.h>
#include <exec/execbase.h>
#include <exec/memory.h>
#include <dos/dosextens.h>
#include <dos/rdargs.h>
#include <dos/dostags.h>
#include <string.h>
#include <stdio.h>
#include <ctype.h>
#include <dos.h>
#include <proto/dos.h>
#include <proto/exec.h>

// !!!!! SET THE PATH TO WHEREVER CLIP.H IS !!!!!!!!
#include <clip.h>

int main(void);

// --------------------------------------------------------------------
//	A small program to test the functions in clip.h
//	Usage  : Clip  [Unit/N] [Text/F]
//	Where  : 
//	- Unit : is the clipboard unit you want opened (default = 0)
//	- Text : is the text you want to write to the clipboard. If none
//	         is given then we read from the clipboard & print out.
//	         Note that you must give a unit number as the 1st argument
//	         and that the text need not be quoted.
//    example : 
//	> clip 1 This text will be written to clip no 1
//	  - will write the above text to clip 1
//	> clip
//	  - will print whatever is in clip 0 to your console
// --------------------------------------------------------------------

int main(void)
{
   struct IOClipReq *clip;
   struct RDArgs *rdargs;
   LONG   args[3];
   LONG   rc = 10;  // return code
   LONG   unit=0;
   UBYTE  *buff = NULL;

   // read in command line arguments
   memset((char *)args, 0, sizeof(args));
   rdargs = ReadArgs("UNIT/N,TEXT/F", args, NULL);
   if (args[0]) // get the clip unit number
   {  unit = *((LONG *)args[0]);
      if (unit > 255 || unit < 0)  // units can be 0-255
      {  PutStr ("Invalid Clipboard unit\n");
	 unit = 0;
      }
      // get the text to write to the clipboard (if any)
      if (args[1]) 
         buff = (UBYTE *)args[1];
   }

   // Open the clipboard..
   if (clip = ClipOpen (unit))
   {
       // if we were given text to write...
       if (buff)
           ClipWrite (clip, buff, -1);

       // else - print out whatever the clipboard is currently filled with
       else if (buff = ClipRead (clip))
       {   PutStr (buff);
           FreeVec (buff); // must free the buffer when we're done..
       }

       // Must close the clipboard when we're finished
       ClipClose (clip);

       rc = 0;  // everything ok..
   }

   // cleanup
   if (rdargs) FreeArgs (rdargs);
   return (rc);
}




