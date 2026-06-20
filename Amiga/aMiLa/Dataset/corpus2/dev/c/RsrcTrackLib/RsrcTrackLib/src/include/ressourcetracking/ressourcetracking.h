/*
**      $VER: ressourcetracking.h 37.0 (20.07.98)
**
**      main include file for ressourcetracking.library
**
**      (C) Copyright 1998 Patrick BURNAND
**      All Rights Reserved.
**
**      Original code for the example.library done by Andreas R. Kleinert.
**      See Clib37x.lha on Aminet !
*/

#ifndef ressourcetracking_ressourcetracking_H
#define ressourcetracking_ressourcetracking_H

/*** THESE STRUCTURES ARE PRIVATE ! ***/

/* This structure contains a ressource tracking record.  It contains all */
/* the necessary information to call the reverse function.  The reverse */
/* function is the function called upon quitting.  For example FreeMem is the */
/* reverse function of AllocMem. */
/* Each time a ressource is allocated, such a record is created on a special */
/* stack. */
struct rsrcRec {
    long retval,   /* Return value of the called function */
                   /*   e.g. AllocMem: pointer to the allocated block. */
         data1,    /* First data useful to call the reverse function */
                   /*   e.g. AllocMem: size of the allocated block. */
         data2,    /* Second data useful to call the reverse function */
                   /*   e.g. AllocMem: unused since we only need the address */
                   /*   and the size of the allocated block to call FreeMem. */
         type;     /* type of allocated ressource */
                   /*   e.g. AllocMem: rTypeAllocMem */
  };

/* This structure contains all the ressource tracking information of one */
/* task.  It's created when a task calls rt_AddManager() for the first time */
/* and destroyed when the task calls rt_RemManager(). */
struct rtLibTaskLst {
    struct Task  *taskPtr;       /* Address of the owner-task. */
    struct rtLibTaskLst  *next;  /* Tasks addresses are chained. */
    int  recNum,                 /* Maximal number of ressource records. */
         actPos;                 /* Actual number of allocated ressources. */
    struct rsrcRec  firstRec[1]; /* Stack of recNum of ressource records. */
  };

#endif /* ressourcetracking_ressourcetracking_H */
