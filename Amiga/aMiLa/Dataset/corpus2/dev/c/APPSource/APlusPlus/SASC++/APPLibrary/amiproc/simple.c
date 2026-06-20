#include <stdio.h>
#include "amiproc.h"

int func(void *string)
{
   printf("%s\n", string);
   return 0;
}

int main(void)
{
   int rc;
   struct AmiProcMsg *apm;

   if(apm = AmiProc_Start(func, "This is a test"))
      rc = AmiProc_Wait(apm);
   else
      rc = 20;

   return rc;
}

