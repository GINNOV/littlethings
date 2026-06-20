/* asendpacket.c - (asynchronous)      send multiple packets to a dos-      */
/* 05-SEP-86                              handler                           */
/* Phillip Lindsay - Commodore-Amiga                                        */

#include "exec/types.h"
#include "exec/ports.h"
#include "exec/io.h"
#include "exec/memory.h"
#include "libraries/dos.h"
#include "libraries/dosextens.h"
#include <stdio.h>
#include "functions.h"           /* aztec C include */


#define DOSTRUE             -1L  /* AmigaDos TRUE */
#define MAXARGS              7L  /* limit in packet structure (dosextens.h) */

/* 
   asynchronous sendpkt routine 
   you must supply a port for packet replies...This function returns the
   address of the pending packet. 

*/ 
long asendpkt(replyport,pid,action,args,nargs)

struct MsgPort *replyport; /* where all packet replies are sent */
struct MsgPort *pid;	  /* process indentifier ... (handlers message port ) */
long action,             /* packet type ... (what you want handler to do )   */
     args[],            /* a pointer to a argument list */
     nargs;            /* number of arguments in list  */
{
  
 struct StandardPacket *packet;
 
 long   count, *pargs; 

 if(nargs > MAXARGS) exit(FALSE); 
 
 packet = (struct StandardPacket *) 
   AllocMem((long)sizeof(*packet),MEMF_PUBLIC | MEMF_CLEAR);
 if(!packet) 
   {
    FreeMem(packet,(long)sizeof(*packet));
    return(NULL);
   }

 packet->sp_Msg.mn_Node.ln_Name = (char *) &(packet->sp_Pkt); /* link packet- */
 packet->sp_Pkt.dp_Link         = &(packet->sp_Msg);        /* to message    */
 packet->sp_Pkt.dp_Port         = replyport;         /* set-up reply port   */
 packet->sp_Pkt.dp_Type         = action;           /* what to do... */

 /* move all the arguments to the packet */
 pargs = &(packet->sp_Pkt.dp_Arg1);        /* address of first argument */
 for(count=NULL;count < nargs;count++) 
   pargs[count]=args[count];

 PutMsg(pid,packet); /* send packet */

 return((long)packet);   /* everything went ok...so far... give-em the packet */
  
}

/* end of asendpkt.c */


/* 
  
   simple packet flush with error detection ... returns ZERO for error
   or DOSTRUE (-1) for a-o-k.
   
   A packet error can be detected in most cases by "Res1" being equal
   to zero--"Res2" will hold more information pertaining to the error. 
   The problem with handling multiple packets is detecting an error for a 
   particular packet. What makes things a little more difficult is the fact
   that the "Res1" member of the packet structure is not generally an 
   indicator of an error. So depending on what type of packets you'll be
   handling you might want to deal with packet replies differently.

   ( I was designing a elegant packet handling tool, but I found that
      AmigaDos doesn't handle ports like EXEC does. So I couldn't have
      a software interrupt generated on packet arrvial [sigh...] Tim?  ) 

*/

long pktflush(rport,pkts)
struct MsgPort *rport;      /* reply port for packets     */
long           pkts;        /* number of packets to flush */

{
 struct StandardPacket *apkt;
 long res1,cres;

 res1 = DOSTRUE;

 while(pkts--)                          /* received all packets? */
  {
   WaitPort(rport);                     /* sleep until a packet arrives */
   apkt = (struct StandardPacket *) GetMsg(rport);       /* get packet */
   cres = apkt->sp_Pkt.dp_Res1;         /* get result */
   FreeMem(apkt,(long)sizeof(*apkt));   /* free packet structure from memory  */
   res1 = (!cres ? cres : res1);        /* error?     */  
  } 

 return(res1);
}

  
/* 
   for all those people interested in implementing AmigaDos file I/O
   with an asynchronous design.
*/
 

/* start of example */

#define NARGS	 3L                      /* number of arguments */
#define NBUFFS   3L                      /* number of buffers   */
#define BUFFLEN 60L                      /* buffer length       */
#define ESC     27L

main()
{

 struct MsgPort        *filehdlr;      /* for process id  handler  */
 struct MsgPort        *rport;         /* where all packets return */
 long                  arg[NARGS],     /* array of arguments       */
                       rpkt,           /* holds returned packet    */
                       count;          /* count messages           */ 
 struct FileHandle     *filehandle;    /* our file handle          */
 BPTR                  fh,             /* AmigaDos file handle     */
                       fharg1;         /* Arg1 from filehandle     */
 UBYTE                 *buff;          /* buffer pointer           */
 struct StandardPacket *pkt;           /* our packet               */
 

/* get buffers */
 buff = (UBYTE *) AllocMem((BUFFLEN * NBUFFS),MEMF_PUBLIC | MEMF_CLEAR);
 if(!buff) exit(TRUE);

 rport = (struct MsgPort *) CreatePort(NULL,NULL); /* make reply port */
 if(!rport) 
  { 
   FreeMem(buff,(BUFFLEN * NBUFFS));
   exit(TRUE);
  }

/* here we open a dummy file */
 fh = (BPTR) Open("df1:temp",MODE_NEWFILE);
 if(!fh) 
  {
   FreeMem(buff,(BUFFLEN * NBUFFS));
   DeletePort(rport);
   exit(TRUE);
  }

/* bring our AmigaDos file handle into the real world... */
 filehandle = (struct FileHandle *)  (fh << 2);

/* read your AmigaDOS Technical Reference Manual for packet requirements */

 fharg1     = filehandle->fh_Arg1;  /* get Arg1 */
 
 filehdlr   = filehandle->fh_Type;  /* get handler for file */
 
/* 
   you could get process id of the handler this way also ...
      filehdlr = (struct MsgPort *) DeviceProc("DF1:");
*/

/* give each buffer unique data */

 for(count=0;count < (BUFFLEN * NBUFFS);count ++)
  buff[count]= 0x31 + (count / BUFFLEN);

/* set-up arguments and send packets */

 arg[0]= (long) fharg1;        /* file handle Arg1  */
 arg[1]= (long) &buff[0];     /* buffer            */
 arg[2]=        BUFFLEN;     /* buffer length     */
 puts("one");
 rpkt = asendpkt(rport,filehdlr,ACTION_WRITE,arg,NARGS);

 arg[1]= (long) &buff[BUFFLEN];
 puts("two");
 rpkt = asendpkt(rport,filehdlr,ACTION_WRITE,arg,NARGS);

 arg[1]= (long) &buff[BUFFLEN + BUFFLEN];
 puts("three");
 rpkt = asendpkt(rport,filehdlr,ACTION_WRITE,arg,NARGS);

/* a more elegant packet flush routine would be nice */

if(!pktflush(rport,3L)) puts("Error in packets sent.");

/* done clean up... */
 Close(fh);
 FreeMem(buff,(BUFFLEN * NBUFFS));
 DeletePort(rport);
 exit(FALSE);
 
}
