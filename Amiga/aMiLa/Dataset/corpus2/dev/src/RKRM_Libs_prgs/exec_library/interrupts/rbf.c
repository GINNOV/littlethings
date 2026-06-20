;/* rbf.c - Execute me to compile me with SAS C 5.10
LC -d0 -b1 -cfistq -v -y -j73 rbf.c
Blink FROM LIB:c.o,rbf.o,rbfhandler.o TO rbf LIBRARY LIB:LC.lib,LIB:Amiga.lib
quit ;

** rbf.c - serial receive buffer full interrupt handler example.
** Must be linked with assembler handler rbfhandler.o
**
** To receive characters, this example requires ASCII serial input
** at your Amiga's current serial hardware baud rate (ie. 9600 after
** reboot, else last baud rate used)


Copyright (c) 1992 Commodore-Amiga, Inc.

This example is provided in electronic form by Commodore-Amiga, Inc. for
use with the "Amiga ROM Kernel Reference Manual: Libraries", 3rd Edition,
published by Addison-Wesley (ISBN 0-201-56774-1).

The "Amiga ROM Kernel Reference Manual: Libraries" contains additional
information on the correct usage of the techniques and operating system
functions presented in these examples.  The source and executable code
of these examples may only be distributed in free electronic form, via
bulletin board or as part of a fully non-commercial and freely
redistributable diskette.  Both the source and executable code (including
comments) must be included, without modification, in any copy.  This
example may not be published in printed form or distributed with any
commercial product.  However, the programming techniques and support
routines set forth in these examples may be used in the development
of original executable software products for Commodore Amiga computers.

All other rights reserved.

This example is provided "as-is" and is subject to change; no
warranties are made.  All use is at your own risk. No liability or
responsibility is assumed.
*/

#include <exec/execbase.h>
#include <exec/memory.h>
#include <exec/interrupts.h>
#include <resources/misc.h>
#include <hardware/custom.h>
#include <hardware/intbits.h>
#include <dos/dos.h>

#include <clib/exec_protos.h>
#include <clib/misc_protos.h>

#include <stdio.h>
#include <string.h>

#ifdef LATTICE
int CXBRK(void)  { return(0); }  /* Disable Lattice CTRL/C handling */
void chkabort(void) { return; }  /* really */
#endif

#define BUFFERSIZE 256

extern void RBFHandler();   /* proto for asm interrupt handler */
void main(void);

struct MiscResource *MiscBase;
extern struct ExecBase *SysBase;
extern struct Custom far custom;    /* defined in amiga.lib */

static UBYTE *allocname = "rbf-example";

struct RBFData {
    struct Task *rd_Task;
    ULONG rd_Signal;
    ULONG rd_BufferCount;
    UBYTE rd_CharBuffer[BUFFERSIZE + 2];
    UBYTE rd_FlagBuffer[BUFFERSIZE + 2];
    UBYTE rd_Name[32];
};

void main(void)
{
    struct RBFData *rbfdata;
    UBYTE *currentuser;
    BYTE signr;
    struct Device *serdevice;
    struct Interrupt *rbfint, *priorint;
    BOOL priorenable;
    ULONG signal;

    if (MiscBase = OpenResource("misc.resource"))
    {
        currentuser = AllocMiscResource(MR_SERIALPORT, allocname);        /* Allocate the serial */
        if (currentuser)                                                  /* port registers.     */
        {
            printf("serial hardware allocated by %s. Trying to remove it\n",
                   currentuser);                                         /* Hey! someone got it! */
            Forbid();
            if (serdevice = (struct Device *)FindName(&SysBase->DeviceList, currentuser))
                RemDevice(serdevice);
            Permit();

            currentuser = AllocMiscResource(MR_SERIALPORT, allocname);          /* and try again */
        }
        if (currentuser == NULL)
        {                                                                      /* Get the serial */
            currentuser = AllocMiscResource(MR_SERIALBITS, allocname);         /* control bits.  */
            if (currentuser)
            {
                printf("serial control allocated by %s\n", currentuser);            /* Give up. */
                FreeMiscResource(MR_SERIALPORT);
            }
            else
            {                                                                  /* Got them both. */
                printf("serial hardware allocated\n");
                if ((signr = AllocSignal(-1)) != -1)          /* Allocate a signal bit for the   */
                {                                             /* interrupt handler to signal us. */
                    if (rbfint = AllocMem(sizeof(struct Interrupt), MEMF_PUBLIC|MEMF_CLEAR))
                    {
                        if (rbfdata = AllocMem(sizeof(struct RBFData), MEMF_PUBLIC|MEMF_CLEAR))
                        {
                            rbfdata->rd_Task = FindTask(NULL);        /* Init rfbdata structure. */
                            rbfdata->rd_Signal = 1L << signr;

                            rbfint->is_Node.ln_Type = NT_INTERRUPT;      /* Init interrupt node. */
                            strcpy(rbfdata->rd_Name, allocname);
                            rbfint->is_Node.ln_Name = rbfdata->rd_Name;
                            rbfint->is_Data = (APTR)rbfdata;
                            rbfint->is_Code = RBFHandler;
                                                                        /* Save state of RBF and */
                            priorenable = custom.intenar & INTF_RBF ? TRUE : FALSE; /* interrupt */
                            custom.intena = INTF_RBF;                             /* disable it. */
                            priorint = SetIntVector(INTB_RBF, rbfint);

                            if (priorint) printf("replaced the %s RBF interrupt handler\n",
                                                 priorint->is_Node.ln_Name);
                            printf("enabling RBF interrupt\n");
                            custom.intena = INTF_SETCLR | INTF_RBF;

                            printf("waiting for buffer to fill up. Use CTRL-C to break\n");
                            signal = Wait(1L << signr | SIGBREAKF_CTRL_C);

                            if (signal & SIGBREAKF_CTRL_C) printf(">break<\n");
                            printf("Character buffer contains:\n%s\n", rbfdata->rd_CharBuffer);

                            custom.intena = INTF_RBF;               /* Restore previous handler. */
                            SetIntVector(INTB_RBF, priorint);
                                                                  /* Enable it if it was enabled */
                            if (priorenable) custom.intena = INTF_SETCLR|INTF_RBF;    /* before. */

                            FreeMem(rbfdata, sizeof(struct RBFData));
                        }
                        else  printf("can't allocate memory for rbf data\n");
                        FreeMem(rbfint, sizeof(struct Interrupt));
                    }
                    else printf("can't allocate memory for interrupt structure\n");
                    FreeSignal(signr);
                }
                else printf("can't allocate signal\n");

                FreeMiscResource(MR_SERIALBITS);   /* release serial hardware */
                FreeMiscResource(MR_SERIALPORT);
            }
        }
    } /* There is no 'CloseResource()' function */
}