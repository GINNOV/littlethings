/* ihand.c
 *
 * Install a AmigaDos Handler - ( dependent release 1.2 )
 *
 * 20-SEP-86 - Phillip Lindsay - (C) Commodore 1986  
 *  You may freely distribute this source and use it for Amiga Development -
 *  as long as the Copyright notice is left intact.
 *
 * (! Please don't make using this routine a habit, release 1.2 WORKBENCH
 *    greater than >33.43 offers a new mount command that will allow 
 *    specification of GlobalVec for non-BCPL modules - Thanks to Andy Finkel !)
 * 
 * Example "DEVS:MOUNTLIST" :
 *------------------------------------------------------------------------------
 * MY0:	    Handler   = l:my-handler
 *          Stacksize = 5000
 *          Priority  = 5
 *          GlobVec   = 1
 * #
 *------------------------------------------------------------------------------
 */

 
#include <exec/types.h>
#include <exec/memory.h>
#include <libraries/dos.h>
#include <libraries/dosextens.h>
#include <libraries/expansion.h>
#include <libraries/filehandler.h>
#include <functions.h>

#define OVER         0x02L                 /* BSTR overhead for size+NULL  */

#define HANDNAMESIZE (0x0cL+OVER)          /* size of BSTR+NULL            */
#define HANDNAME     "\x0cl:my-handler\0"  /* BSTR format handler name     */

#define DEVNAMESIZE  (0x03L+OVER)          /* size of BSTR+NULL            */
#define DEVNAME      "\x03MY0\0"           /* BSTR of device name          */

#define PRIORITY	5L
#define STACKSIZE	5000L
#define GLOBALVEC	-1L

ULONG ExpansionBase;                        /* for expansion library (1.2) */

main()
{
 
 struct DeviceNode *mynode;

 UBYTE *handname; 

 UBYTE  *devname;
 

 handname = AllocMem((ULONG)(HANDNAMESIZE),MEMF_PUBLIC | MEMF_CLEAR);
 if(!handname) 
   exit(TRUE);
 strcpy(handname,HANDNAME);

 devname =   AllocMem((ULONG)(DEVNAMESIZE),MEMF_PUBLIC | MEMF_CLEAR);
 if(!devname)
  { 
   FreeMem(handname,(ULONG)(HANDNAMESIZE));
   exit(TRUE);
  }
 strcpy(devname,DEVNAME);

 mynode = AllocMem((ULONG)sizeof(*mynode),MEMF_PUBLIC | MEMF_CLEAR); 

 if(!mynode) 
  {
   FreeMem(handname,(ULONG)(HANDNAMESIZE));
   FreeMem(devname,(ULONG)(DEVNAMESIZE));
   exit(TRUE);
  }
 
 mynode->dn_Priority     = PRIORITY;
 mynode->dn_StackSize    = STACKSIZE;
 mynode->dn_GlobalVec    = GLOBALVEC;   /* (-1) the trick for non-bcpl module */
 mynode->dn_Name         = (BSTR) ((ULONG)devname  >> 2); /* to BPTR */
 mynode->dn_Handler      = (BSTR) ((ULONG)handname >> 2); /* ""  ""  */
 
/* This will fail if your not 1.2 */
 ExpansionBase = (ULONG) OpenLibrary(EXPANSIONNAME,0L); 

 if(!ExpansionBase) 
  {
   FreeMem(handname,(ULONG)(HANDNAMESIZE+2)); 
   FreeMem(devname,(ULONG)(DEVNAMESIZE+2));
   FreeMem(mynode,(ULONG)sizeof(*mynode));
   exit(TRUE);
  }
 
  AddDosNode(0L,0L,mynode);

  CloseLibrary(ExpansionBase);  
  
}

/* EOF - ihand.c */
