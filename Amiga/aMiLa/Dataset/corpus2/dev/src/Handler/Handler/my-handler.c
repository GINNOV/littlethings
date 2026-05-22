/*  my-handler.c 
 *
 *  This is a "dumb" handler that can be used as a model. 
 *  Functionally this handler does nothing but "play pretend" so I suppose 
 *  you could classify my-handler as a NIL: AmigaDOS device.
 * 
 *  Phillip Lindsay  (C) 1986 Commodore 
 *  You may freely distribute this source and use it for Amiga Development -
 *  as long as the Copyright notice is left intact.
 *   
 *  (! Please note that support of non-BCPL modules  
 *                                          is a new feature in release 1.2 !) 
 *
 * A sample "devs:mountlist" entry for a non-bcpl module:
 * 
 * (! PLEASE NOTE: that this is supported ONLY by the MOUNT command on
 *     1.2 WORKBENCH release greater than 33.43 THANKS TO ANDY FINKEL !)     
 *----------------------------------------------------------------------------- 
 *   MY0:       Handler   = l:my-handler
 *              Stacksize = 5000
 *              Priority  = 5
 *              GlobVec   = 1
 *   #
 * ----------------------------------------------------------------------------
 * Since most people will not have the new MOUNT command I have included
 *  a program that uses the expansion.library to install the device node. 
 * 
 * But PLEASE don't distribute AmigaDOS device handlers that use a 
 * "install program." The "mountlist" in almost all cases (except AUTOCONFIG) 
 *  should be taken advantage of for AmigaDOS device installation.
 *
 * I have done this under MANX, but I don't see too much trouble getting
 * it to work with Lattice...just don't use any startup code and
 * disable the stack checking on LC2 with '-v'. 
 * 
 */

#include <exec/types.h>
#include <exec/nodes.h>
#include <exec/lists.h>
#include <exec/ports.h>
#include <exec/libraries.h>
#include <exec/devices.h>
#include <exec/io.h>
#include <exec/memory.h>
#include <devices/console.h>
#include <intuition/intuition.h>
#include <libraries/dos.h>
#include <libraries/dosextens.h>
#include <libraries/filehandler.h>

#ifdef MANX
#include <functions.h>
#endif

#include "my-handler.h"

/* my version of BADDR() has no problems with casting */
#undef  BADDR
#define BADDR(x)	((APTR)((long)x << 2))

#define ACTION_FIND_INPUT       1005L /* please refer to DOS Tech. Ref. */
#define ACTION_FIND_OUTPUT      1006L
#define ACTION_END              1007L

#define DOS_FALSE	 0L
#define DOS_TRUE	-1L           /* BCPL "TRUE" */

#ifdef MANX
ULONG              SysBase, /* these are here to make the startup code happy */
                   _savsp;  /* (this is unique to Manx Aztec C startup)      */ 
#endif

_main() 
{

 /* handler support routines */

 extern void           returnpkt(); /* sends a packet back to sender          */
 struct DosPacket      *taskwait(); /* waits for packet from the world        */


 /* handler related data structures */

 struct Process        *myproc;     /* my process                             */
 struct DosPacket      *mypkt;      /* a pointer to the dos packet sent       */
 BSTR                  parmdevname; /* pointer to device name in parmpkt Arg1 */
 long                  parmextra;   /* extra info passed in parmpkt      Arg2 */
 struct DeviceNode     *mynode;     /* our device node passed in parmpkt Arg3 */
 struct FileHandle     *fh;         /* a pointer to our file handle           */
 long                  open;        /* handler open flag                      */
 long                  run;         /* handler main loop flag                 */

/* I have left all my debug's in...you'll see how they save you headaches
 * the first time you try to debug your handler...
 */
 
#ifdef DEBUG
  kprintf("**** Start my-handler ****\n");
#endif

/* misc. init. */
 myproc          = (struct Process *) FindTask(0L);  /* find myself        */
 open            = DOS_FALSE;                       /* not open            */
 run             = TRUE;                           /* handler loop flag    */

/* since we were started as a non-BCPL module we get sent the parameter pkt */
/* (ie. parameter packet not in D1) */

mypkt = taskwait();  /* wait for parameter packet */

#ifdef DEBUG
 kprintf("Got Parmeter Packet.\n");
#endif

 parmdevname     = (BSTR)  mypkt->dp_Arg1;  /* BSTR name passed to handler   */
 parmextra       = mypkt->dp_Arg2;          /* Extra Info passed             */

 /* get pointer to our device node */
 mynode = (struct DeviceNode *) BADDR(mypkt->dp_Arg3); /* ptr to device node */

 /*
  * This is where you do your handler initialization
  *  Open what ever devices ... parse the device name passed in
  *  the parameter packet...etc...
  */


/* if initialzation was possible then we... */
 
 mynode->dn_Task = &myproc->pr_MsgPort; /* install our taskid ...
                             * if we don't...for every reference to our handler
                             * a NEW process will be created.  This is fine for
                             * things like CON: (console handler) but if you
                             * plan to be the only dude on block ( like the
                             * file-system handler or SER: ) you should fill
                             * the task field with your taskid 
                             * (ie. &(pr_MsgPort) )
                             * Note: remember that shared code has to be
                             *  reentrant. (like CON: handler) 
                             *  ( keep your variables on the stack [autos],
                             *    and allocate memory for larger data
                             *  structures and "FLAG" global data structures
                             *  that need only be intialized once ) 
                             */
#ifdef DEBUG
 kprintf("Returning parmeter packet...A-O-K.\n");
#endif
 
returnpkt(mypkt,DOS_TRUE,mypkt->dp_Res2);    /* everything a-o-k */

#ifdef DEBUG
 kprintf("Waiting for packet..\n");
#endif

 while(run)   /* start of the real work */
  {
   mypkt = taskwait();  /* wait for a packet */
 
   switch(mypkt->dp_Type)
    {
     case ACTION_FIND_INPUT:     /* opening your device */
     case ACTION_FIND_OUTPUT: 

#ifdef DEBUG
 kprintf("Action FindInput/Ouput : %ld\n",mypkt->dp_Type);
#endif
 
          fh = (struct FileHandle *) BADDR(mypkt->dp_Arg1);  
          fh->fh_Port = DOS_TRUE;
          open++;
          returnpkt(mypkt,DOS_TRUE,mypkt->dp_Res2);
          break;
     
     case ACTION_END:

#ifdef DEBUG
 kprintf("Action End : %ld\n",mypkt->dp_Type);
#endif

/* we want to fall out of the loop if not OPEN.
 */

          if((--open) <= 0)  run = FALSE;
         
          returnpkt(mypkt,DOS_TRUE,mypkt->dp_Res2);
          break;

     case ACTION_READ:

#ifdef DEBUG
 kprintf("Action Read : %ld\n",mypkt->dp_Type);
#endif

/* we *always* read nothing */

          returnpkt(mypkt,0L,mypkt->dp_Res2);
          break;

     case ACTION_WRITE:
#ifdef DEBUG
 kprintf("Action Write : %ld\n",mypkt->dp_Type);
#endif

/* we *always* write everything */

          returnpkt(mypkt,mypkt->dp_Arg3,mypkt->dp_Res2);   
          break;

     default:
#ifdef DEBUG
 kprintf("Unknown packet type %ld\n",mypkt->dp_Type);
#endif
/* say what? */
          returnpkt(mypkt,DOS_FALSE,ERROR_ACTION_NOT_KNOWN);

    } /* end of switch(mypkt->dp_Type) */   
    
  } /* end of while(run) */


 mynode->dn_Task = FALSE; /* zero the taskid field of device node */

 /* INSERT HERE -> do some clean up and leave */
 
/* we are a process "so we fall off the end of the world" */

/*  If we are reentrant we can't rely on our initial stack being saved.
 *  Which means NO exit()'s ... We must just fall through....If your
 *  not reentrant then don't worry about ending here.
 *
 * BTW, you don't necessarlly have to leave...You could stick around and
 * wait all day for packets....its all according to what your handler
 * is set-up to do. 
 */

} /* end of _main() */



/* EOF - end of my-handler */
