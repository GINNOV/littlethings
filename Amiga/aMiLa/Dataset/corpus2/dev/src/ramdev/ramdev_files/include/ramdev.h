#ifndef RAMDEV_H
#define RAMDEV_H

#include <exec/exec.h>
#include <dos/dos.h>
#include <expansion/expansion.h>
#include <expansion/expansionbase.h>
#include <hardware/intbits.h>
#include <hardware/cia.h>
#include <devices/trackdisk.h>
#include <devices/newstyle.h>
#include <proto/exec.h>
#include <proto/expansion.h>
#include <string.h>

#define MYDEVNAME "ramdev.device"
#include "ramdev.device_rev.h"

/***********************************************************************/

/* Compile time options */
#define INFO_LEVEL	1000	/* Specify amount of debugging info desired
						   If > 0 you must link with debug.lib!
						   You will need to run a terminal program to
						   set the baud rate. */
#define INTRRUPT	0	/* Set this to 1 to enable fake interrupt
						   code */
#define AUTOMOUNT	0	/* Work with the "mount" command if 0
						   Do it automatically if 1 */

/***********************************************************************/

/* This means "no error" for device I/O operations */
#define OK (0)

#define kprintf DebugPrintF

/***********************************************************************/

/* Stack size and priority for the task we will create */
#define MYPROCSTACKSIZE	0x900
#define MYPROCPRI			0	/* Devices are often 5, NOT higher */

/***********************************************************************/

/* Base constants */
#define NUMBEROFTRACKS 	40	/* Change THIS to change size of ramdisk */
#define SECTOR			512	/* # bytes per sector */
#define SECTORSPER		10	/* # Sectors per "track" */

/***********************************************************************/

/* Use this much RAM per unit */
#define BYTESPERTRACK	(SECTORSPER * SECTOR)
#define RAMSIZE			(NUMBEROFTRACKS * BYTESPERTRACK)

/***********************************************************************/

/* Board I/O addresses and flags */
#define IAMPULLING	7		/* "I am pulling the interrupt" bit of INTCRL1 */
#define INTENABLE	4		/* "Interrupt Enable" bit of INTCRL2 */
#define INTCTRL1	0x40	/* Interrupt control register offset on board */
#define INTCTRL2	0x42	/* Interrupt control register offset on board */
#define INTACK		0x50	/* My board's interrupt reset address */

/***********************************************************************/

/* Device command definitions (copied from devices/trackdisk.h) */
#define CMD_MOTOR			(CMD_NONSTD+0)	/* control the disk's motor (NO-OP) */
#define CMD_SEEK			(CMD_NONSTD+1)	/* explicit seek (NO-OP) */
#define CMD_FORMAT			(CMD_NONSTD+2)	/* format disk - equated to WRITE for RAMDISK */
#define CMD_REMOVE			(CMD_NONSTD+3)	/* notify when disk changes (NO-OP) */
#define CMD_CHANGENUM		(CMD_NONSTD+4)	/* number of disk changes (always 0) */
#define CMD_CHANGESTATE		(CMD_NONSTD+5)	/* is there a disk in the drive? (always TRUE) */
#define CMD_PROTSTATUS		(CMD_NONSTD+6)	/* is the disk write protected? (always FALSE) */
#define CMD_RAWREAD			(CMD_NONSTD+7)	/* Not supported */
#define CMD_RAWWRITE		(CMD_NONSTD+8)	/* Not supported */
#define CMD_GETDRIVETYPE	(CMD_NONSTD+9)	/* Get drive type */
#define CMD_GETNUMTRACKS	(CMD_NONSTD+10)	/* Get number of tracks */
#define CMD_ADDCHANGEINT	(CMD_NONSTD+11)	/* Add disk change interrupt (NO-OP) */
#define CMD_REMCHANGEINT	(CMD_NONSTD+12)	/* Remove disk change interrupt ( NO-OP) */

/***********************************************************************/

/* Layout of parameter packet for MakeDosNode */
struct MkDosNodePkt
{
	STRPTR	mdn_DOSName;	/* Pointer to DOS file handler name */
	STRPTR	mdn_ExecName;	/* Pointer to device driver name */
	ULONG	mdn_Unit;		/* Unit number */
	ULONG	mdn_Flags;		/* OpenDevice flags */
	ULONG	mdn_TableSize;	/* Environment size */
	ULONG	mdn_SizeBlock;	/* # longwords in a block */
	ULONG	mdn_SecOrg;		/* sector origin -- unused */
	ULONG	mdn_NumHeads;	/* number of surfaces */
	ULONG	mdn_SecsPerBlk;	/* secs per logical block -- unused */
	ULONG	mdn_BlkTrack;	/* secs per track */
	ULONG	mdn_ResBlks;	/* reserved blocks -- MUST be at least 1! */
	ULONG	mdn_Prefac;		/* unused */
	ULONG	mdn_Interleave;	/* interleave */
	ULONG	mdn_LowCyl;		/* lower cylinder */
	ULONG	mdn_UpperCyl;	/* upper cylinder */
	ULONG	mdn_NumBuffers;	/* number of buffers */
	ULONG	mdn_MemBufType;	/* Type of memory for AmigaDOS buffers */
	UBYTE	mdn_Name[5];	/* DOS file handler name "RAM0" */
};

/***********************************************************************/

/* Device data structures */

/* Forward declaration for below */
struct MyDev;

struct MyDevUnit
{
	struct Unit		mdu_Unit;
	UWORD			mdu_UnitNum;

	/* Now longword aligned! */

	struct MyDev		*mdu_Device;
	struct Task		*mdu_Task; /* Task Control Block for disk task */
	ULONG			mdu_SigMask; /* Signal these bits on interrupt */

	struct Interrupt	mdu_InterruptServer; /* Interrupt structure */
	UWORD			mdu_pad1; /* longword align */

	UBYTE			mdu_RAM[RAMSIZE]; /* RAM used to simulate disk */
};

#define MD_NUMUNITS 4 /* maximum number of units in this device */

/* State bit for unit stopped */
#define MDUF_STOPPED (1<<2)

/* State bit for 'unit task needs waking up' */
#define MDUF_WAKEUP (1<<3)

struct MyDev
{
	struct Device			md_Device;
	UWORD				pad;

	/* now longword aligned */

	struct ExecIFace		*IExec;
	BPTR				segList;

	UBYTE				*md_Base;	/* Base address of this device's expansion board */
	struct MyDevUnit		*md_Units[MD_NUMUNITS];
};

#define IExec md->IExec

/* dev_init.c */
struct Library *libInit (struct MyDev *md, APTR seglist, struct Interface *ISys);
LONG libOpen(struct DeviceManagerInterface *Self, struct IORequest *io, ULONG unit_number, ULONG flags);
BPTR libClose(struct DeviceManagerInterface *Self, struct IORequest *io);
BPTR libExpunge(struct DeviceManagerInterface *Self);

/* dev_unit.c */
LONG InitUnit (ULONG unit_number, struct MyDev *md);
void ExpungeUnit (struct MyDevUnit * mdu,struct MyDev * md);

/* dev_io.c */
LONG libAbortIO (struct DeviceManagerInterface *Self, struct IORequest *which_io);
void libBeginIO (struct DeviceManagerInterface *Self, struct IORequest *io);

/* dev_io_cmd.c */
BOOL is_immediate_command (UWORD command);
BOOL is_never_immediate_command (UWORD command);
void terminate_io (LONG error, struct IORequest *io, struct MyDev *md);
void queue_io (struct IORequest *io, struct MyDev *md);
LONG read_write (struct IOStdReq *io, struct MyDev *md);
void perform_io (struct IOStdReq *io, struct MyDev *md);

/* dev_task.c */
void task_begin (struct MyDevUnit *mdu);
ULONG interrupt (struct MyDevUnit *mdu);

#endif /* RAMDEV_H */
