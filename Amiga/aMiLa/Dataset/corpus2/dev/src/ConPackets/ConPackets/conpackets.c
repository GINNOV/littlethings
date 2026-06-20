/* ConPackets.c -  C. Scheppner, A. Finkel, P. Lindsay  CBM
 *   DOS packet example
 *   Requires 1.2
 */

#include <stdio.h>
#include <exec/types.h>
#include <exec/memory.h>
#include <libraries/dos.h>
#include <libraries/dosextens.h>
#include <devices/conunit.h>

#define ACTION_SCREEN_MODE  994L
#define DOSTRUE  -1L
#define DOSFALSE  0L

/* Used for checking version */
ULONG DosBase;

/* Globals initialized by findWindow() */
struct Window  *conWindow;
struct ConUnit *conUnit;

main()
   {
   LONG  infile;
   WORD  curX, curY;

   if(!(DosBase=(OpenLibrary("dos.library",33))))
      cleanexit("\nVersion 1.2 required\n");

   if((infile = Input()) <= 0)
      cleanexit("\nNo stdin ... Did you RUN this ???\n");

   if (! findWindow()) cleanexit("\nNot enough free memory\n");

   printf("\033[0 p\014");  /* Turn off cursor, home and clear */
   printf("Window = $%lx   ConUnit = $%lx\n\n",conWindow, conUnit);
   printf("CURSOR LIMITS:  XMax = %ld   YMax = %ld\n",
              conUnit->cu_XMax + 1, conUnit->cu_YMax + 1);
   curX = conUnit->cu_XCCP;
   curY = conUnit->cu_YCCP;
   printf("*<--- here cursor was at position %ld,%ld\n",curX,curY);

   /* Move to first position of last line and clear to EOL */
   clearLast();
   printf("ABSOLUTE CURSOR POSITIONING...");
   Delay(100);
   clearLast();
   setRawCon(DOSTRUE);
   printf("RAW MODE: Press ANY key...");
   printf(" Hex value = %02lx",(UBYTE)getchar());
   /* Maybe they pressed a string key - if so, get rest */
   while(WaitForChar(infile,100L)) printf(" %02lx",(UBYTE)getchar());

   setRawCon(DOSFALSE);
   printf("\nShort demo --- That's it\n");
   cleanup();
   }


clearLast()
   {
   printf("\033[%ld;%0H\033[M", conUnit->cu_YMax + 1);
   }


cleanexit(s)
char *s;
   {
   if(*s)    printf(s);    /* Print error */
   cleanup();
   exit(0);
   }

cleanup()
   {
   setRawCon(DOSFALSE);
   printf("\033[1 p\n"); /* Turn cursor on */
   if(DosBase) CloseLibrary(DosBase);
   }



/* sendpkt code - A. Finkel, P. Lindsay, C. Scheppner  CBM */

LONG setRawCon(toggle)
LONG toggle;     /* DOSTRUE (-1L)  or  DOSFALSE (0L) */
   {
   struct MsgPort *conid;
   struct Process *me;
   LONG myargs[8] ,nargs, res1;

   me = (struct Process *) FindTask(NULL);
   conid = (struct MsgPort *) me->pr_ConsoleTask;

   myargs[0]=toggle;
   nargs = 1;
   res1 = (LONG)sendpkt(conid,ACTION_SCREEN_MODE,myargs,nargs);
   return(res1);
   }


LONG findWindow() /* inits conWindow and conUnit (global vars) */
   {
   struct InfoData *id;
   struct MsgPort  *conid;
   struct Process  *me;
   LONG myargs[8] ,nargs, res1;

   /* Alloc to insure longword alignment */
   id = (struct InfoData *)AllocMem(sizeof(struct InfoData),
                                       MEMF_PUBLIC|MEMF_CLEAR);
   if(! id) return(0);
   me = (struct Process *) FindTask(NULL);
   conid = (struct MsgPort *) me->pr_ConsoleTask;

   myargs[0]=((ULONG)id) >> 2;
   nargs = 1;
   res1 = (LONG)sendpkt(conid,ACTION_DISK_INFO,myargs,nargs);
   conWindow = (struct Window *)id->id_VolumeNode;
   conUnit = (struct ConUnit *)
                 ((struct IOStdReq *)id->id_InUse)->io_Unit;
   FreeMem(id,sizeof(struct InfoData));
   return(res1);
   }


LONG sendpkt(pid,action,args,nargs)
struct MsgPort *pid;  /* process indentifier ... (handlers message port ) */
LONG action,          /* packet type ... (what you want handler to do )   */
     args[],          /* a pointer to a argument list */
     nargs;           /* number of arguments in list  */
   {
   struct MsgPort        *replyport;
   struct StandardPacket *packet;
 
   LONG  count, *pargs, res1;

   replyport = (struct MsgPort *) CreatePort(NULL,0);
   if(!replyport) return(NULL);

   packet = (struct StandardPacket *) 
      AllocMem((long)sizeof(struct StandardPacket),MEMF_PUBLIC|MEMF_CLEAR);
   if(!packet) 
      {
      DeletePort(replyport);
      return(NULL);
      }

   packet->sp_Msg.mn_Node.ln_Name = (char *)&(packet->sp_Pkt);
   packet->sp_Pkt.dp_Link         = &(packet->sp_Msg);
   packet->sp_Pkt.dp_Port         = replyport;
   packet->sp_Pkt.dp_Type         = action;

   /* copy the args into the packet */
   pargs = &(packet->sp_Pkt.dp_Arg1);       /* address of first argument */
   for(count=0;count < nargs;count++) 
      pargs[count]=args[count];
 
   PutMsg(pid,packet); /* send packet */

   WaitPort(replyport);
   GetMsg(replyport); 

   res1 = packet->sp_Pkt.dp_Res1;

   FreeMem(packet,(long)sizeof(struct StandardPacket));
   DeletePort(replyport); 

   return(res1);
   }


