/*
 * Copyright (c) 1992 Commodore-Amiga, Inc.
 * 
 * This example is provided in electronic form by Commodore-Amiga, Inc. for 
 * use with the "Amiga ROM Kernel Reference Manual: Devices", 3rd Edition, 
 * published by Addison-Wesley (ISBN 0-201-56775-X).
 * 
 * The "Amiga ROM Kernel Reference Manual: Devices" contains additional 
 * information on the correct usage of the techniques and operating system 
 * functions presented in these examples.  The source and executable code 
 * of these examples may only be distributed in free electronic form, via 
 * bulletin board or as part of a fully non-commercial and freely 
 * redistributable diskette.  Both the source and executable code (including 
 * comments) must be included, without modification, in any copy.  This 
 * example may not be published in printed form or distributed with any
 * commercial product.  However, the programming techniques and support
 * routines set forth in these examples may be used in the development
 * of original executable software products for Commodore Amiga computers.
 * 
 * All other rights reserved.
 * 
 * This example is provided "as-is" and is subject to change; no
 * warranties are made.  All use is at your own risk. No liability or
 * responsibility is assumed.
 *
 *****************************************************************************
 *
 *
 * Cia_Interval.c
 *
 * Demonstrate allocation and use of a cia interval timer
 *
 * Compile with SAS C 5.10  lc -b1 -cfistq -v -y -L
 *
 * Run from CLI only
 */

#include <exec/types.h>
#include <exec/memory.h>
#include <exec/tasks.h>
#include <exec/interrupts.h>
#include <hardware/cia.h>
#include <resources/cia.h>

#include <clib/exec_protos.h>
#include <clib/cia_protos.h>

#include <stdlib.h>
#include <stdio.h>
#include <string.h>


/* prototypes */

void    StartTimer      (struct freetimer *ft, struct exampledata *ed);
int     FindFreeTimer   (struct freetimer *ft, int preferA);
int     TryTimer        (struct freetimer *ft);
void    main            ( USHORT, char **);


/* see usage of these defines in StartTimer() below */

#define COUNTDOWN 20
#define HICOUNT 0xFF
#define LOCOUNT 0xFF

#define STOPA_AND  CIACRAF_TODIN |CIACRAF_PBON | CIACRAF_OUTMODE | CIACRAF_SPMODE

        /*
        ;
        ; AND mask for use with control register A
        ; (interval timer A on either CIA)
        ;
        ; STOP -
        ;       START bit 0 == 0 (STOP IMMEDIATELY)
        ;       PBON  bit 1 == same
        ;       OUT   bit 2 == same
        ;       RUN   bit 3 == 0 (SET CONTINUOUS MODE)
        ;       LOAD  bit 4 == 0 (NO FORCE LOAD)
        ;       IN    bit 5 == 0 (COUNTS 02 PULSES)
        ;       SP    bit 6 == same
        ;       TODIN bit 7 == same (unused on ciacra)

        */

#define STOPB_AND  CIACRBF_ALARM | CIACRBF_PBON | CIACRBF_OUTMODE

        /*
        ;
        ; AND mask for use with control register B
        ; (interval timer B on either CIA)
        ;
        ; STOP -
        ;       START bit 0 == 0 (STOP IMMEDIATELY)
        ;       PBON  bit 1 == same
        ;       OUT   bit 2 == same
        ;       RUN   bit 3 == 0 (SET CONTINUOUS MODE)
        ;       LOAD  bit 4 == 0 (NO FORCE LOAD)
        ;       IN0   bit 5 == 0 (COUNTS 02 PULSES)
        ;       IN1   bit 6 == 0 (COUNTS 02 PULSES)
        ;       ALARM bit 7 == same (TOD alarm control bit)

        */

#define STARTA_OR  CIACRAF_START

        /*
        ;
        ; OR mask for use with control register A
        ; (interval timer A on either CIA)
        ;
        ; START -
        ;
        ;       START bit 0 == 1 (START TIMER)
        ;
        ;       All other bits unaffected.
        ;

        */

#define STARTB_OR  CIACRBF_START

        /*
        ;
        ; OR mask for use with control register B
        ; (interval timer A on either CIA)
        ;
        ; START -
        ;
        ;       START bit 0 == 1 (START TIMER)
        ;
        ;       All other bits unaffected.
        ;

        */


/*
 * Structure which will be used to hold all relevant information about
 * the cia timer we manage to allocate.
 *
 */

struct freetimer
{
    struct Library *ciabase;        /* CIA Library Base             */
    ULONG  timerbit;                /* timer bit allocated          */
    struct CIA *cia;                /* ptr to hardware              */
    UBYTE *ciacr;                   /* ptr to control register      */
    UBYTE *cialo;                   /* ptr to low byte of timer     */
    UBYTE *ciahi;                   /* ptr to high byte of timer    */
    struct Interrupt timerint;      /* Interrupt structure          */
    UBYTE  stopmask;                /* Stop/set-up timer            */
    UBYTE  startmask;               /* Start timer                  */
};

/*
 * Structure which will be used by the interrupt routine called
 * when our cia interval timer generates an interrupt.
 *
 */

struct exampledata
{
    struct Task *task;      /* task to signal */
    ULONG   signal;         /* Signal bit to use */
    ULONG   counter;
};


struct CIA *ciaa = (struct CIA *)0xbfe001;
struct CIA *ciab = (struct CIA *)0xbfd000;


#ifdef LATTICE
int CXBRK(void) { return(0); }  /* Disable SAS CTRL/C handling */
int chkabort(void) { return(0); }  /* really */
#endif

/*
 * This is the interrupt routine which will be called when our CIA
 * interval timer counts down.
 *
 * This example decrements a counter each time the interrupt routine
 * is called until the counter reaches 0, at which time it signals
 * our main task.
 *
 * Note that interrupt handling code should be efficient, and will
 * generally be written in assembly code.  Signaling another task
 * such as this example does is also a useful way of handling
 * interrupts in an expedient manner.
 *
 */

void __asm ExampleInterrupt(register __a1 struct exampledata *ed)
{

if (ed->counter)
    {
    ed->counter--;                  /* decrement counter */
    }
else
    {
    ed->counter = COUNTDOWN;        /* reset counter     */

    Signal(ed->task,(1L << ed->signal));
    }
}

/***********************************
 *  main()
 ***********************************/
void main(USHORT argc,char **argv)
{

struct freetimer ft;
struct exampledata ed;


/* Set up data which will be passed to interrupt */

ed.task = FindTask(0L);

if (ed.signal = AllocSignal(-1L))
    {

    /* Prepare freetimer structure : set-up interrupt */

    ft.timerint.is_Node.ln_Type = NT_INTERRUPT;
    ft.timerint.is_Node.ln_Pri  = 0;
    ft.timerint.is_Node.ln_Name = "cia_example";

    ft.timerint.is_Data         = (APTR)&ed;
    ft.timerint.is_Code         = (APTR)ExampleInterrupt;


    /* Call function to find a free CIA interval timer
     * with flag indicating that we prefer a CIA-A timer.
     */

    printf("Attempting to allocate a free timer\n");

    if (FindFreeTimer(&ft,TRUE))
        {

        if (ft.cia == ciaa)
            {
            printf("CIA-A timer ");
            }
        else
            {
            printf("CIA-B timer ");
            }

        if (ft.timerbit == CIAICRB_TA)
            {
            printf("A allocated\n");
            }
        else
            {
            printf("B allocated\n");
            }


        /* We found a free interval timer.  Let's start it running. */

        StartTimer(&ft,&ed);

        /* Wait for a signal */

        printf("Waiting for signal bit %ld\n",ed.signal);

        Wait(1L<<ed.signal);

        printf("We woke up!\n");

        /* Release the interval timer */

        RemICRVector(ft.ciabase,ft.timerbit,&ft.timerint);

        }
    else
        {
        printf("No CIA interval timer available\n");
        }

    FreeSignal(ed.signal);
    }
}


/*
 * This routine sets up the interval timer we allocated with
 * AddICRVector().  Note that we may have already received one, or
 * more interrupts from our timer.  Make no assumptions about the
 * initial state of any of the hardware registers we will be using.
 *
 */

void StartTimer(struct freetimer *ft, struct exampledata *ed)
{
register struct CIA *cia;

cia = ft->cia;

/* Note that there are differences between control register A,
 * and B on each CIA (e.g., the TOD alarm bit, and INMODE bits.
 */

if (ft->timerbit == CIAICRB_TA)
    {
    ft->ciacr = &cia->ciacra;       /* control register A   */
    ft->cialo = &cia->ciatalo;      /* low byte counter     */
    ft->ciahi = &cia->ciatahi;      /* high byte counter    */

    ft->stopmask = STOPA_AND;       /* set-up mask values   */
    ft->startmask = STARTA_OR;
    }
else
    {
    ft->ciacr = &cia->ciacrb;       /* control register B   */
    ft->cialo = &cia->ciatblo;      /* low byte counter     */
    ft->ciahi = &cia->ciatbhi;      /* high byte counter    */

    ft->stopmask = STOPB_AND;       /* set-up mask values   */
    ft->startmask = STARTB_OR;
    }


/* Modify control register within Disable().  This is done to avoid
 * race conditions since our compiler may generate code such as:
 *
 *      value = Read hardware byte
 *      AND  value with MASK
 *      Write value to hardware byte
 *
 * If we take a task switch in the middle of this sequence, two tasks
 * trying to modify the same register could trash each others' bits.
 *
 * Normally this code would be written in assembly language using atomic
 * instructions so that the Disable() would not be needed.
 */


Disable();

/* STOP timer, set 02 pulse count-down mode, set continuous mode */

*ft->ciacr &= ft->stopmask;
Enable();

/* Clear signal bit - interrupt will signal us later */
SetSignal(0L,1L<<ed->signal);

/* Count-down X # of times */
ed->counter = COUNTDOWN;

/* Start the interval timer - we will start the counter after
 * writing the low, and high byte counter values
 */

*ft->cialo = LOCOUNT;
*ft->ciahi = HICOUNT;

/* Turn on start bit - same bit for both A, and B control regs  */

Disable();
*ft->ciacr |= ft->startmask;

Enable();
}



/*
 * A routine to find a free interval timer.
 *
 * This routine makes no assumptions about which interval timers
 * (if any) are available for use.  Currently there are two interval
 * timers per CIA chip.
 *
 * Because CIA usage may change in the future, your code should use
 * a routine like this to find a free interval timer.
 *
 * Note that the routine takes a preference flag (which is used to
 * to indicate that you would prefer an interval timer on CIA-A).
 * If the flag is FALSE, it means that you would prefer an interval
 * timer on CIA-B.
 *
 */

FindFreeTimer(struct freetimer *ft, int preferA)
{
struct CIABase *ciaabase, *ciabbase;

/* get pointers to both resource bases */

ciaabase = OpenResource(CIAANAME);
ciabbase = OpenResource(CIABNAME);

/* try for a CIA-A timer first ? */

if (preferA)
    {
    ft->ciabase = ciaabase; /* library address  */
    ft->cia     = ciaa;     /* hardware address */
    }
else
    {
    ft->ciabase = ciabbase; /* library address  */
    ft->cia     = ciab;     /* hardware address */
    }

if (TryTimer(ft))
    return(TRUE);

/* try for an interval timer on the other cia */

if (!(preferA))
    {
    ft->ciabase = ciaabase; /* library address  */
    ft->cia     = ciaa;     /* hardware address */
    }
else
    {
    ft->ciabase = ciabbase; /* library address  */
    ft->cia     = ciab;     /* hardware address */
    }

if (TryTimer(ft))
    return(TRUE);

return(FALSE);

}


/*
 * Try to obtain a free interval timer on a CIA.
 */

TryTimer(struct freetimer *ft)
{

if (!(AddICRVector(ft->ciabase,CIAICRB_TA,&ft->timerint)))
    {
    ft->timerbit = CIAICRB_TA;
    return(TRUE);
    }

if (!(AddICRVector(ft->ciabase,CIAICRB_TB,&ft->timerint)))
    {
    ft->timerbit = CIAICRB_TB;
    return(TRUE);
    }

return(FALSE);
}


