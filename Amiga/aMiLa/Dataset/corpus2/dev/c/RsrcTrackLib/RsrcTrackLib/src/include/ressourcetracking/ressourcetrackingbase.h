/*
**      $VER: ressourcetrackingbase.h 37.1 (4.12.96)
**
**      definition of RessourceTrackingBase
**
**      (C) Copyright 1998 Patrick BURNAND
**      All Rights Reserved.
**
**      Original code for the example.library done by Andreas R. Kleinert.
**      See Clib37x.lha on Aminet !
*/

#ifndef ressourcetracking_ressourcetrackingBASE_H
#define ressourcetracking_ressourcetrackingBASE_H

#ifdef   __MAXON__
#ifndef  EXEC_LIBRARIES_H
#include <exec/libraries.h>
#endif
#else
#ifndef  EXEC_LIBRARIES
#include <exec/libraries.h>
#endif /* EXEC_LIBRARIES_H */
#include <exec/semaphores.h>
#endif

#ifdef __GNUC__
#include "ressourcetracking/ressourcetracking.h"
#elif VBCC
#include "include/ressourcetracking/ressourcetracking.h"
#else
#include "/include/ressourcetracking/ressourcetracking.h"
#endif

/* This structure is PRIVATE ! */
/* But you are allowed to use the library base pointers.  It allows you not to */
/* OpenLibrary().  They are initialized when the library is successfully opened. */
/* Never CloseLibrary() on these pointers !  It's done automagically when the */
/* ressourcetracking.library is flushed from memory. */
struct RessourceTrackingBase
{
 struct Library          rtb_LibNode;        /* Private ! */
 APTR                    rtb_SegList;        /* Private ! */
 struct ExecBase        *rtb_SysBase;        /* You can use these library */
 struct IntuitionBase   *rtb_IntuitionBase;  /* base pointers to avoid to */
 struct GfxBase         *rtb_GfxBase;        /* open them.  Read-only ! */
 struct DOSBase         *rtb_DOSBase;        /* Never call CloseLibrary() ! */
 struct rtLibTaskLst    *rtb_TaskLstPtr,   /* Chained list of tasks */
                        *rtb_LastTPtr;  /* Contains task pointer of the task */
                                        /* which did the last operation. */
                                        /* Avoids to search the list through */
                                        /* for every operation. */
 struct SignalSemaphore  rtb_Semaphore;   /* Exclusive access to the list ! */
};

#endif /* ressourcetracking_ressourcetrackingBASE_H */
