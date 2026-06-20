
#include <stdio.h>
#include <stdlib.h>

#include <exec/types.h>
#include <exec/memory.h>
#include <exec/semaphores.h>

#include <proto/exec.h>
#include <proto/intuition.h>
#include <proto/dos.h>
#include <proto/ressourcetracking.h>

#include <intuition/intuition.h>
#include <ressourcetracking/ressourcetrackingbase.h>


struct RessourceTrackingBase *RessourceTrackingBase = NULL;


int main ()
{
   struct MsgPort *m;

   if  ( RessourceTrackingBase = (APTR) OpenLibrary("ressourcetracking.library", 37) )
   {
      if (rt_AddManager(100)) {

         printf ("m=rt_CreateMsgPort()==$%08lX\n", (long)(m=rt_CreateMsgPort()));

         m->mp_Node.ln_Name = "hello";
         m->mp_Node.ln_Pri = 1;
         rt_AddPort(m);

         Delay(20*50);
      }

      rt_RemManager();
      puts ("rt_RemManager();");

      CloseLibrary ((APTR)RessourceTrackingBase);

   } else  puts("\nressourcetracking.library opening failed");
   return 0;
}

