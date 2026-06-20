#include "amiproc.h"

#include <stdio.h>

/* Declare some __near external data.  This is reallocated for  */
/* each new subprocess, so all processes have their own private */
/* copy.  When the copy is first made, it will have the value   */
/* it's being set to here, even if the parent has changed it.   */
char *ext = "This is the original value of ext";

int subprocess(void *arg)
{
   printf("%s: ext = \"%s\"\n\n", arg, ext);
   return 0;
}

void main(void)
{
   struct AmiProcMsg *first, *second;
   
   first = AmiProc_Start(subprocess, "First subprocess");

   subprocess("Original process, before resetting externs");

   ext = "This is the new value of ext";
   second = AmiProc_Start(subprocess, "Second subprocess");

   subprocess("Original process, after resetting externs");

   AmiProc_Wait(first);
   AmiProc_Wait(second);
}
