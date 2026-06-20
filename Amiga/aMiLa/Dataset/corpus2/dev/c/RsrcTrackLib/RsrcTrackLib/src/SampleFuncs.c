/*
**      $VER: SampleFuncs.c 37.0 (20.07.98)
**
**      Functions of ressourcetracking.library
**
**      (C) Copyright 1998 Patrick BURNAND
**      All Rights Reserved.
**
**      Original code for the example.library done by Andreas R. Kleinert.
**      See Clib37x.lha on Aminet !
*/

#include <exec/types.h>
#include <exec/memory.h>
#include <exec/semaphores.h>

#include <proto/exec.h>
#include <proto/intuition.h>
#include <proto/dos.h>
#include <proto/ressourcetracking.h>

#include <intuition/intuition.h>
#include <ressourcetracking/ressourcetrackingbase.h>


#include "compiler.h"


extern struct RessourceTrackingBase *RessourceTrackingBase;


/* Internal and private functions */
void voidf(struct rsrcRec *rp);
void CallCustomF0(struct rsrcRec *rp);
void CallCustomF1(struct rsrcRec *rp);
void CallCustomF2(struct rsrcRec *rp);
struct rsrcRec *NewRsrcRec(void);
void RemRsrcRec(struct rsrcRec *rp);

void rt_FreeMem (struct rsrcRec *rp);
void rt_FreeSignal (struct rsrcRec *rp);
void rt_CloseLibrary (struct rsrcRec *rp);
void rt_RemSemaphore (struct rsrcRec *rp);
void rt_Permit (struct rsrcRec *rp);
void rt_FreeTrap (struct rsrcRec *rp);
void rt_DeleteMsgPort (struct rsrcRec *rp);
void rt_RemPort (struct rsrcRec *rp);


/* All the possible ressource types.  Each type correspond to a function to call to */
/* «undo»  the  operation.  For example, FreeMem undoes AllocMem.  The order of the */
/* types  must  exactly  match  the order of the function calls below.  (You surely */
/* don't  want that the ressource tracking system calls CloseLibrary with an adress */
/* obtained with AllocMem...) */
enum rsrcType {
   rTypeVoid1,
   rTypeMarker,
   rTypeCustomF0,
   rTypeCustomF1,
   rTypeCustomF2,
   rTypeAllocMem,
   rTypeAllocSignal,
   rTypeOpenLibrary,
   rTypeSemaphore,
   rTypeForbid,
   rTypeTrap,
   rTypeMsgPort,
   rTypePubMsgPort,
   rTypeVoid2
   };

/* Function  table.   Each  entry is called to «undo» an operation.  Each functions */
/* address must correspond with the ressource types above. */
/* Note  that  the function in this table must never be called by the user.  If you */
/* allocated  a  memory  block using rt_AllocMem, never call rt_FreeMem or FreeMem. */
/* You must use rt_UnsetMarker or rt_RemManager for this.  Else the memory would be */
/* freed  twice.   (The  ressource  tracking  system  does  always  and blindly his */
/* work...) */
 APTR MyFTab[] = {
   (APTR)voidf,
   (APTR)voidf,
   (APTR)CallCustomF0,
   (APTR)CallCustomF1,
   (APTR)CallCustomF2,
   (APTR)rt_FreeMem,
   (APTR)rt_FreeSignal,
   (APTR)rt_CloseLibrary,
   (APTR)rt_RemSemaphore,
   (APTR)rt_Permit,
   (APTR)rt_FreeTrap,
   (APTR)rt_DeleteMsgPort,
   (APTR)rt_RemPort
   };


/* Now, let's begin with the function themselves. */


/* Allocates a memory block using AllocMem and stores all necessary informations in */
/* a  ressource  tracking  record.   The  memory is then freed automatically by the */
/* ressource  tracking  system  when you call rt_UnsetMarker or rt_RemManager.  The */
/* usage  of  this  function  is exactly the same as the standard AllocMem.  Except */
/* that  you  must  never  call rt_FreeMem or FreeMem afterwards (If you program in */
/* assembly, note that the registers are not the same !).  If the memory allocation */
/* fails  the  ressource  tracking  system  will  still  continue to work properly. */
/* rt_FreeMem is protected against a null pointer */
APTR __saveds ASM rt_AllocMem ( register __d1 ULONG byteSize GNUCREG(d1), register __d2 ULONG requirements GNUCREG(d2) )
{
   struct rsrcRec *rP = NewRsrcRec();
   rP->data1 = byteSize;   rP->type = rTypeAllocMem;
   rP->retval = (long)AllocMem(byteSize, requirements);
   return (APTR)rP->retval;
}
/* Internal function to free the allocated memory.  Never call it ! */
void rt_FreeMem (struct rsrcRec *rp)
{
   if (rp->retval)   FreeMem ((APTR)rp->retval, rp->data1);
}



/* Exactly the same as for rt_AllocMem.  (Except that it opens a shared library...) */
struct Library __saveds ASM *rt_OpenLibrary ( register __d1 UBYTE *libName GNUCREG(d1), register __d2 ULONG version GNUCREG(d2) )
{
   struct rsrcRec *rP = NewRsrcRec();
   rP->type = rTypeOpenLibrary;
   rP->retval = (long)OpenLibrary(libName,version);
   return (struct Library *)rP->retval;
}

void rt_CloseLibrary (struct rsrcRec *rp)
{
   if (rp->retval)  CloseLibrary((struct Library *)rp->retval);
}




void  __saveds ASM rt_AddSemaphore ( register __d1 struct SignalSemaphore *sigSem GNUCREG(d1) )
{
   struct rsrcRec *rP = NewRsrcRec();
   rP->type=rTypeSemaphore;
   rP->data1=(long)sigSem;
   AddSemaphore(sigSem);
}

void rt_RemSemaphore (struct rsrcRec *rp)
{
   RemSemaphore((struct SignalSemaphore *)rp->data1);
}




ULONG __saveds ASM rt_AllocTrap ( register __d1 ULONG trapNum GNUCREG(d1) )
{
   struct rsrcRec *rP = NewRsrcRec();
   rP->type=rTypeTrap;
   return  rP->retval = AllocTrap(trapNum);
}

void rt_FreeTrap (struct rsrcRec *rp)
{
   if (rp->retval!=-1L)  FreeTrap(rp->retval);
}




struct MsgPort __saveds ASM *rt_CreateMsgPort ( void )
{
   struct rsrcRec *rP = NewRsrcRec();
   rP->type=rTypeMsgPort;
   return  (struct MsgPort *)(rP->retval = (long)CreateMsgPort());
}

void rt_DeleteMsgPort (struct rsrcRec *rp)
{
   struct Message *mp;

   if (rp->retval)  {
      Forbid();
      while (mp=GetMsg((struct MsgPort *)rp->retval))
         ReplyMsg(mp);
      DeleteMsgPort((struct MsgPort *)rp->retval);
      Permit();
   }
}




void  __saveds ASM rt_AddPort ( register __d1 struct MsgPort *port GNUCREG(d1) )
{
   struct rsrcRec *rP = NewRsrcRec();
   rP->type=rTypePubMsgPort;
   rP->retval=(long)port;
   AddPort(port);
}

void rt_RemPort (struct rsrcRec *rp)
{
   RemPort ((struct MsgPort *)rp->retval);
}




void __saveds ASM rt_Forbid ( void )
{
   struct rsrcRec *rP = NewRsrcRec();
   rP->type=rTypeForbid;
   Forbid();
}

void rt_Permit ( struct rsrcRec *rp)  { Permit(); }




BYTE __saveds ASM rt_AllocSignal ( register __d1 ULONG signalNum GNUCREG(d1) )
{
   struct rsrcRec *rP = NewRsrcRec();
   rP->type = rTypeAllocSignal;
   rP->retval = AllocSignal(signalNum);
   return (BYTE)rP->retval;
}

void rt_FreeSignal (struct rsrcRec *rp)
{
   if (rp->retval!=-1L)  FreeSignal(rp->retval);
}




/* Adds  a  function  pointer to the stack of allocated ressources.  The address of */
/* your  function is passed by the parameter.  The function you pass the address of */
/* must  have  no  parameter.   If you want that 1 parameter will be passed to your */
/* function,  use  rt_SetCustomF1.   (rt_SetCustomF2  for  2 parameters) The use of */
/* rt_SetCustomF0 is very similar to the ansi c atexit() function. */
void __saveds ASM rt_SetCustomF0 ( register __d1 APTR f GNUCREG(d1) )
{
   struct rsrcRec *rP = NewRsrcRec();
   rP->type=rTypeCustomF0;
   rP->retval=(long)f;
}

void __saveds ASM rt_SetCustomF1 ( register __d1 APTR f GNUCREG(d1), register __d2 ULONG arg1 GNUCREG(d2) )
{
   struct rsrcRec *rP = NewRsrcRec();
   rP->type=rTypeCustomF1;
   rP->retval=(long)f;  rP->data1=arg1;
}

void __saveds ASM rt_SetCustomF2 ( register __d1 APTR f GNUCREG(d1), register __d2 ULONG arg1 GNUCREG(d2), register __d3 ULONG arg2 GNUCREG(d3) )
{
   struct rsrcRec *rP = NewRsrcRec();
   rP->type=rTypeCustomF2;
   rP->retval=(long)f;  rP->data1=arg1;  rP->data2=arg2;
}



/* Adds  a  ressource  tracking  manager for the calling task to the list of */
/* managers.   RecNum  represents  the maxiamal number of ressource that can */
/* simultanously be allocated. */
ULONG __saveds ASM rt_AddManager  ( register __d1 ULONG recNum GNUCREG(d1) )
{
   ULONG recNum_d1 = recNum;
   struct Task *taskPtr = (struct Task *)FindTask(NULL);
   struct rtLibTaskLst *tNPtr = RessourceTrackingBase->rtb_TaskLstPtr;
   long sz = sizeof(*tNPtr)+recNum_d1*sizeof(struct rsrcRec);
   char ok=FALSE;

   /* First  try  to  find  if  this task is already registered.  This check */
   /* is necessary since it's legal to call rt_AddManager() several times. */
   ObtainSemaphoreShared (&RessourceTrackingBase->rtb_Semaphore);
   tNPtr = RessourceTrackingBase->rtb_TaskLstPtr;
   while (tNPtr)  {
     if  ( ok = (tNPtr->taskPtr==taskPtr) )  break;
     tNPtr=tNPtr->next;
   }
   ReleaseSemaphore (&RessourceTrackingBase->rtb_Semaphore);

   /* If  this  task calls rt_AddManager() for the first time, allocate */
   /* records and add the task to the list */
   /* Note  that  the  allocated memory block is the first allocated */
   /* ressource. It will be automatically freed when rt_RemManager() will be */
   /* called. */
   if (!ok && recNum_d1>0)
     if  ( tNPtr = AllocMem (sz, MEMF_PUBLIC|MEMF_CLEAR) )  {
       tNPtr->taskPtr = taskPtr;
       tNPtr->actPos = 1;
       tNPtr->recNum = recNum_d1;
       tNPtr->firstRec[0].retval = (long)tNPtr;
       tNPtr->firstRec[0].data1 = sz;
       tNPtr->firstRec[0].type = rTypeAllocMem;
       /* Add the record to the chained list. */
       ObtainSemaphore (&RessourceTrackingBase->rtb_Semaphore);
       tNPtr->next = RessourceTrackingBase->rtb_TaskLstPtr;
       RessourceTrackingBase->rtb_TaskLstPtr = RessourceTrackingBase->rtb_LastTPtr = tNPtr;
       ReleaseSemaphore (&RessourceTrackingBase->rtb_Semaphore);
       ok=TRUE;
     }

   return ok;
}


/* Removes  the  ressource  tracking  manager  of  the  calling  task.   All */
/* remaining  ressources are first freed or closed.  It's perfectly legal to */
/* call this function if rt_AddManager() wasn't called or failed. */
void  __saveds ASM rt_RemManager ( void )
{
   struct Task *taskPtr = (struct Task *)FindTask(NULL);
   struct rtLibTaskLst *tLstPtr, *oTLstPtr;
   char found=FALSE;

   ObtainSemaphore (&RessourceTrackingBase->rtb_Semaphore);
   /* Find the task in the list */
   oTLstPtr = tLstPtr = RessourceTrackingBase->rtb_TaskLstPtr;
   while (tLstPtr)  {
      if  ( found = (tLstPtr->taskPtr==taskPtr) )  break;
      oTLstPtr = tLstPtr;
      tLstPtr = tLstPtr->next;
   }
   /* If it exists, remove it from the chained list */
   if (found)  {
      RessourceTrackingBase->rtb_LastTPtr = RessourceTrackingBase->rtb_TaskLstPtr;
      oTLstPtr->next = tLstPtr->next;
      if (tLstPtr==RessourceTrackingBase->rtb_TaskLstPtr)
         RessourceTrackingBase->rtb_TaskLstPtr = tLstPtr->next;
   }
   ReleaseSemaphore (&RessourceTrackingBase->rtb_Semaphore);

   /* Free all the remaining ressources and the stack itself */
   if (found)
     while (tLstPtr->actPos)
       RemRsrcRec (&tLstPtr->firstRec[--tLstPtr->actPos]);
}



/* Adds  a  marker in the list of allocated ressources.  This marker is used */
/* to  be  able  not  to  free every ressource, but only the last allocated. */
/* When  rt_UnsetMarker()  is  called  all  the  rssources  since  the  last */
/* rt_SetMarker() are closed. */
void __saveds ASM rt_SetMarker (void)
{
   struct rsrcRec *rP = NewRsrcRec();
   rP->type=rTypeMarker;
}

void  __saveds ASM rt_UnsetMarker ( void )
{
   struct Task *taskPtr = (struct Task *)FindTask(NULL);
   struct rtLibTaskLst *tNPtr;
   struct rsrcRec *rp;

   tNPtr = RessourceTrackingBase->rtb_LastTPtr;
   if  (tNPtr->taskPtr!=taskPtr)  {
      ObtainSemaphore (&RessourceTrackingBase->rtb_Semaphore);
      tNPtr = RessourceTrackingBase->rtb_TaskLstPtr;
      while (tNPtr) {
         if (tNPtr->taskPtr==taskPtr)  break;
         tNPtr=tNPtr->next;
      }
      RessourceTrackingBase->rtb_LastTPtr = tNPtr;
      ReleaseSemaphore (&RessourceTrackingBase->rtb_Semaphore);
   }

   /* Closes all the ressources until we find the Marker */
   if (tNPtr)
      while  (tNPtr->actPos>1)  {
         if  ((rp=&tNPtr->firstRec[--tNPtr->actPos])->type==rTypeMarker)  break;
         RemRsrcRec (rp);
      }
}


/* Finds  the total number of used ressource records.  This function is only */
/* useful  to  pass  the  right  number to rt_AddManager().  Remember that a */
/* ressource  tracking  record only takes 16 bytes, so it isen't dramatic if */
/* you pass a to large number to rt_AddManager().  If you want this function */
/* to return a meaningfull number, call it just before rt_RemManager(). */
ULONG __saveds ASM rt_FindNumUsed  ( void )
{
   struct Task *taskPtr = (struct Task *)FindTask(NULL);
   struct rtLibTaskLst *tNPtr;
   int rn;

   ObtainSemaphoreShared (&RessourceTrackingBase->rtb_Semaphore);
   tNPtr = RessourceTrackingBase->rtb_TaskLstPtr;
   while (tNPtr)  {
      if (tNPtr->taskPtr==taskPtr)  break;
      tNPtr=tNPtr->next;
   }
   ReleaseSemaphore (&RessourceTrackingBase->rtb_Semaphore);

   if (tNPtr)
     for (rn=tNPtr->recNum;rn;rn--)
       if (tNPtr->firstRec[rn].type)
         return rn;

   return 0;
}


/* Removes  a  ressource tracking record of the stack.  It only calls one of */
/* the   function   defined   in   MyFTab.    e.g:    if  the  ressource  is */
/* rTypeOpenLibrary, it will call CloseLibrary(). */
void RemRsrcRec ( struct rsrcRec *rp )
{
   void (*rtfPtr)(struct rsrcRec *rp) = MyFTab[rp->type];

   if  ( rp->type >= rTypeVoid2 || rp->type <= rTypeVoid1 )  {
      BOOL trash = DisplayAlert (0,"\x00\x10\x10" "Corrupted ressource list detected.\x00", 28);
      return;
   }
   (*rtfPtr)(rp);
}


/* Adds  a new ressource tracking record on the stack of allocated ressource */
/* belonging to the task. */
struct rsrcRec *NewRsrcRec ( void )
{
   struct Task *taskPtr = (struct Task *)FindTask(NULL);
   struct rtLibTaskLst *tNPtr;

   /* First check if the task address is cached in rtb_LastTPtr.  If not, */
   /* finds it in the chained list */
   tNPtr = RessourceTrackingBase->rtb_LastTPtr;
   if  (tNPtr->taskPtr!=taskPtr)  {
      ObtainSemaphore (&RessourceTrackingBase->rtb_Semaphore);
      tNPtr = RessourceTrackingBase->rtb_TaskLstPtr;
      while (tNPtr) {
         if (tNPtr->taskPtr==taskPtr)  break;
         tNPtr=tNPtr->next;
      }
      RessourceTrackingBase->rtb_LastTPtr = tNPtr;
      ReleaseSemaphore (&RessourceTrackingBase->rtb_Semaphore);
   }

   /* The task must be found here.  Else the system may crash... */
   if (!tNPtr) {
      BOOL trash = DisplayAlert (0,
       "\x00\x10\x10" "Error when creating ressource tracking record:\x00\xff"
       "\x00\x10\x1a" "rt_AddManager() has not been successfully called by this task.\x00\xff"
       "\x00\x10\x27" "Don't forget to rt_RemManager() before exit()ing.  "
                      "You can do it atexit().\x00", 50);
      return NULL;
   }

   /* There must be enough space here.  Else the system may crash... */
   if (tNPtr->actPos > tNPtr->recNum)  {
      BOOL trash = DisplayAlert (0,
       "\x00\x10\x10" "Error when creating ressource tracking record:\x00\xff"
       "\x00\x10\x1a" "No enough place to store the new ressource allocation data...\x00\xff"
       "\x00\x10\x27" "You should rt_AddManager() with an higher parameter value.\x00"
       , 50);
      return NULL;
   }

   /* Everything ok, returns adress of the record */
   return &tNPtr->firstRec[tNPtr->actPos++];
}




void voidf(struct rsrcRec *rp)  {}


/* Calls  the function that the user pushed on the ressource tracking stack. */
/* Note:    you  must  never  call  this  function  directly.   It's  called */
/* automatically  by RemRsrcRec() when this function finds the rTypeCustomF0 */
/* ressource type. */
void CallCustomF0(struct rsrcRec *rp)  {
   void (*f0Ptr)(void) = (APTR)rp->retval;
   (*f0Ptr)();
}

/* Same as CallCustomF0 but the called function has 1 parameter. */
void CallCustomF1(struct rsrcRec *rp)  {
   void (*f1Ptr)(long a1) = (APTR)rp->retval;
   (*f1Ptr)(rp->data1);
}

/* Same as CallCustomF0 and CallCustomF1 but the called function has 2 */
/* parameter. */
void CallCustomF2(struct rsrcRec *rp)  {
   void (*f2Ptr)(long a1, long a2) = (APTR)rp->retval;
   (*f2Ptr)(rp->data1, rp->data2);
}

