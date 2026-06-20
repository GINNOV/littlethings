/*
 *  $VER: init.c $Revision$ (12-Jun-2006)
 *
 *  This file is part of ramdev.
 *
 *  (C) Copyright 2006 Hyperion Entertainment
 *      All rights reserved
 */

/************************************************************************
*
* ramdev.c -- Skeleton device code.
*
* A sample 4 unit ramdisk that can be bound to an expansion slot device,
* or used without.  Works with the Fast File System.
* This code is required reading for device driver writers.  It contains
* information not found elsewhere.
*
* This example includes a task, though a task is not actually needed for
* a simple ram disk.  Unlike a single set of hardware registers that
* may need to be shared by multiple tasks, ram can be freely shared.
* This example does not show arbitration of hardware resources.
*
************************************************************************/

#define __USE_INLINE__ 1
#include "ramdev.h"

#include <exec/exec.h>
#include <proto/exec.h>
#include <dos/dos.h>
#include <stdarg.h>

/* Version Tag */
STATIC CONST UBYTE
#ifdef __GNUC__
__attribute__((used))
#endif
verstag[] = VERSTAG;

/*
 * The system (and compiler) rely on a symbol named _start which marks
 * the beginning of execution of an ELF file. To prevent others from 
 * executing this library, and to keep the compiler/linker happy, we
 * define an empty _start symbol here.
 *
 * On the classic system (pre-AmigaOS4) this was usually done by
 * moveq #0,d0
 * rts
 *
 */
int32 _start(void);

int32 _start(void)
{
    /* If you feel like it, open DOS and print something to the user */
    return 100;
}

/* FOR RTF_AUTOINIT:
    This routine gets called after the device has been allocated.
    The device pointer is in D0.  The AmigaDOS segment list is in a0.
    If it returns the device pointer, then the device will be linked
    into the device list.  If it returns NULL, then the device
    will be unloaded.

   IMPORTANT:
    If you don't use the "RTF_AUTOINIT" feature, there is an additional
    caveat.  If you allocate memory in your Open function, remember that
    allocating memory can cause an Expunge... including an expunge of your
    device.  This must not be fatal.  The easy solution is don't add your
    device to the list until after it is ready for action.

   This call is single-threaded by exec; please read the description for
   "dev_open" below. */

/* The ROMTAG Init Function */
struct Library *libInit (struct MyDev *md, APTR seglist, struct Interface *ISys) {
	struct Library *ExpansionBase = NULL;
	struct ExpansionIFace *IExpansion = NULL;
	struct MyDev *result = NULL;
	IExec = (struct ExecIFace *)ISys;

	if(INFO_LEVEL-5 >= 0)
		kprintf("%s/Init: called\n",MYDEVNAME);

	md->md_Device.dd_Library.lib_Node.ln_Type = NT_DEVICE;
	md->md_Device.dd_Library.lib_Node.ln_Pri  = 0;
	md->md_Device.dd_Library.lib_Node.ln_Name = MYDEVNAME;
	md->md_Device.dd_Library.lib_Flags        = LIBF_SUMUSED|LIBF_CHANGED;
	md->md_Device.dd_Library.lib_Version      = VERSION;
	md->md_Device.dd_Library.lib_Revision     = REVISION;
	md->md_Device.dd_Library.lib_IdString     = VSTRING;

	/* Save pointer to our loaded code (the SegList) */
	md->segList = (BPTR)seglist;

	if (AUTOMOUNT) {
		struct CurrentBinding cb;
		struct DeviceNode *dn;
		struct MkDosNodePkt mdn;
		LONG i;

		/* Here starts the AutoConfig stuff.  If this driver was to be tied to
		   an expansion board, you would put this driver in the expansion drawer,
		   and be called when BindDrivers finds a board that matches this driver.
		   The Amiga assigned product number of your board must be
		   specified in the "PRODUCT=" field in the TOOLTYPES of this driver's icon.
		   GetCurrentBinding() returns your (first) board.

		   Note that for an AutoConfig driver in ROM your initialization would
		   look very different because it happens at a different time using
		   different parameters. */
		ExpansionBase = OpenLibrary("expansion.library",0);
		if(ExpansionBase == NULL)
			goto out;
		IExpansion = (struct ExpansionIFace *)GetInterface(ExpansionBase, "main", 1, NULL);
		if (IExpansion == NULL)
			goto out;

		/* Get the Current Bindings */
		/*GetCurrentBinding(&cb,sizeof(cb));*/

		/* Get start of list; exit and unload driver if controller
		   not found */
		/*if(cb.cb_ConfigDev == NULL)*/
		/*	goto out;*/

		/* Save board base address */
		/*md->md_Base = cb.cb_ConfigDev->cd_BoardAddr;*/

		/* Mark board as configured */
		/*cb.cb_ConfigDev->cd_Flags |= CDF_CONFIGME;*/

		/* If your card was successfully configured, you can mount the
		   units as DOS nodes */

		/* Here we build a packet describing the characteristics of our disk to
		   pass to AmigaDOS.  This serves the same purpose as a "mount" command
		   of this device would.  For disks, it might be useful to actually
		   get this information right from the disk itself.  Just as mount,
		   it could be for multiple partitions on the single physical device.
		   For this example, we will simply hard code the appropriate parameters.

		   The AddDosNode call adds things to dos's list without needing to
		   use mount.  We'll mount all 4 of our units whenever we are
		   started. */

		/* Initialize the parameter packet */
		memset(&mdn,0,sizeof(mdn));

		mdn.mdn_DOSName		= mdn.mdn_Name;
		mdn.mdn_ExecName	= md->md_Device.dd_Library.lib_Node.ln_Name; /* Address of driver name */
		mdn.mdn_TableSize	= 12; /* # long words in AmigaDOS env. */
		mdn.mdn_SizeBlock	= SECTOR / sizeof(LONG); /* # longwords in a block */
		mdn.mdn_NumHeads	= 1; /* RAM disk has only one "head" */
		mdn.mdn_SecsPerBlk	= 1; /* secs/logical block, must = "1" */
		mdn.mdn_BlkTrack	= SECTORSPER; /* secs/track (must be reasonable) */
		mdn.mdn_ResBlks		= 1; /* reserved blocks, MUST BE > 0! */
		mdn.mdn_UpperCyl	= (RAMSIZE / BYTESPERTRACK) - 1; /* upper cylinder */
		mdn.mdn_NumBuffers	= 1; /* # AmigaDOS buffers to start */

		/* Now tell AmigaDOS about all units UNITNUM */
		for(i = 0 ; i < MD_NUMUNITS ; i++)
		{
			strcpy(mdn.mdn_Name,"RAM0");
			mdn.mdn_Name[3] = '0' + i;

			/* Before adding to the dos list, you should really check if you
			   are about to cause a name collision.  This example does not. */

			dn = MakeDosNode(&mdn);
			if(dn != NULL)
			{
				/* Setting ADNF_STARTPROC in the 'flags' parameter will work,
				   but only if dn_SegList is filled in in the SegPtr of the
				   handler task. */
				AddDosNode(0,0,dn);
			}
		}
	}

	result = md;

out:

	/* Clean up if the initialization failed */
	if(result == NULL)
		DeleteLibrary((struct Library *)md);

	if(IExpansion != NULL)
		DropInterface((struct Interface *)IExpansion);

	if(ExpansionBase != NULL)
		CloseLibrary(ExpansionBase);

	return (struct Library *)result;
}

/***********************************************************************/

/* Here begins the system interface commands.  When the user calls
   OpenDevice/CloseDevice/RemDevice, this eventually gets translated
   into a call to the following routines (Open/Close/Expunge).
   Exec has already put our device pointer in a6 for us.

   IMPORTANT:
     These calls are guaranteed to be single-threaded; only one task
     will execute your Open/Close/Expunge at a time.

     For Kickstart V33/34, the single-threading method involves "Forbid".
     There is a good chance this will change.  Anything inside your
     Open/Close/Expunge that causes a direct or indirect Wait() will break
     the Forbid().  If the Forbid() is broken, some other task might
     manage to enter your Open/Close/Expunge code at the same time.
     Take care!

   Since exec has turned off task switching while in these routines
   (via Forbid/Permit), we should not take too long in them. */

/***********************************************************************/

/* dev_open() sets the io_Error field on an error. If it was successful,
   we should also set up the io_Unit and ln_Type fields.
   Exec takes care of setting up io_Device. */

/* Open the library */
LONG libOpen(struct DeviceManagerInterface *Self,
	struct IORequest *io, ULONG unit_number,
	ULONG flags)
{
	LONG error;
	struct MyDev *md = (struct MyDev *)Self->Data.LibBase;

	/* Subtle point: any AllocMem() call can cause a call to this device's
	   expunge vector.  If lib_OpenCnt is zero, the device might get expunged. */

	md->md_Device.dd_Library.lib_OpenCnt++; /* Fake an opener for duration of call */

	/* see if the unit number is in range */
	if(unit_number >= MD_NUMUNITS)
	{
		/* unit number out of range */
		error = IOERR_OPENFAIL;
		goto out;
	}

	/* see if the unit is already initialized */
	if(md->md_Units[unit_number] == NULL)
	{
		/* initialize the unit; exit if it fails */
		error = InitUnit(unit_number,md);
		if(error != OK)
			goto out;
	}

	io->io_Unit = (struct Unit *)md->md_Units[unit_number];

	/* mark us as having another opener */
	md->md_Device.dd_Library.lib_OpenCnt++;
	io->io_Unit->unit_OpenCnt++; /* Internal bookkeeping */

	/* prevent delayed expunges */
	md->md_Device.dd_Library.lib_Flags &= ~LIBF_DELEXP;

	/* IMPORTANT: Mark IORequest as "complete" */
	io->io_Message.mn_Node.ln_Type = NT_REPLYMSG;

	/* Success */
	error = OK;

out:

	/* Did the unit open? */
	if(error != OK)
	{
		/* IMPORTANT: trash io_Device on open failure */
		io->io_Device = NULL;

		if(INFO_LEVEL-2 >= 0)
			kprintf("%s/Open: failed\n",MYDEVNAME);
	}

	/* Save the error code */
	io->io_Error = error;

	md->md_Device.dd_Library.lib_OpenCnt--; /* End of expunge protection */

	return(error);
}

/***********************************************************************/

/* There are two different things that might be returned from the dev_close()
   routine.  If the device wishes to be unloaded, then dev_close() must return
   the segment list (as given to dev_init()).  Otherwise dev_close() MUST
   return NULL. */

/* Close the library */
BPTR libClose(struct DeviceManagerInterface *Self,
	struct IORequest *io)
{
	struct MyDev *md = (struct MyDev *)Self->Data.LibBase;
	struct Unit * unit = io->io_Unit;
	BPTR result = (BPTR)NULL;

	if(INFO_LEVEL-20 >= 0)
		kprintf("%s/Close: called\n",MYDEVNAME);

	/* IMPORTANT: make sure the IORequest is not used again
	   with a -1 in io_Device, any BeginIO() attempt will
	   immediatly halt (which is better than a subtle corruption
	   that will lead to hard-to-trace crashes!!! */
	io->io_Unit = (struct Unit *)-1;
	io->io_Device = (struct Device *)-1;

	/* see if the unit is still in use */
	unit->unit_OpenCnt--;
	if(unit->unit_OpenCnt == 0)
		ExpungeUnit((struct MyDevUnit *)unit,md); /* release it */

	/* mark us as having one fewer openers */
	md->md_Device.dd_Library.lib_OpenCnt--;

	/* see if there is anyone left with us open */
	if(md->md_Device.dd_Library.lib_OpenCnt == 0)
	{
		/* see if we have a delayed expunge pending */
		if(md->md_Device.dd_Library.lib_Flags & LIBF_DELEXP)
		{
			/* do the expunge */
			result = libExpunge(Self);
		}
	}

	/* MUST return either zero or the SegList!!! */
	return(result);
}

/***********************************************************************/

/* dev_expunge() is called by the memory allocator when the system is low on
   memory.

   There are two different things that might be returned from the dev_expunge()
   routine.  If the device is no longer open then dev_expunge() may return the
   segment list (as given to dev_init()).  Otherwise dev_expunge() may set the
   delayed expunge flag and return NULL.
 
   One other important note: because dev_expunge() is called from the memory
   allocator, it may NEVER Wait() or otherwise take long time to complete. */

/* Expunge the library */
BPTR libExpunge(struct DeviceManagerInterface *Self) {
	struct MyDev *md = (struct MyDev *)Self->Data.LibBase;
	BPTR result = (BPTR)NULL;

	if(INFO_LEVEL-10 >= 0)
		kprintf("%s/Expunge: called\n",MYDEVNAME);


	/* see if anyone has us open */
	if (md->md_Device.dd_Library.lib_OpenCnt > 0) {
		/* it is still open.  set the delayed expunge flag */
		md->md_Device.dd_Library.lib_Flags |= LIBF_DELEXP;
	} else {
		/* go ahead and get rid of us. */
		result = md->segList;

		/* unlink from device list */
		Remove((struct Node *)md); /* Remove first (before FreeMem) */

		/* ...device specific closings here... */

		/* free our memory */
		DeleteLibrary((struct Library *)md);
	}

	return(result);
}

/* ------------------- Manager Interface ------------------------ */
/* These are generic. Replace if you need more fancy stuff */
STATIC LONG _manager_Obtain(struct DeviceManagerInterface *Self)
{
    return Self->Data.RefCount++;
}

STATIC ULONG _manager_Release(struct DeviceManagerInterface *Self)
{
    return Self->Data.RefCount--;
}

/* Manager interface vectors */
STATIC CONST APTR lib_manager_vectors[] =
{
    (APTR)_manager_Obtain,
    (APTR)_manager_Release,
    NULL,
    NULL,
    (APTR)libOpen,
    (APTR)libClose,
    (APTR)libExpunge,
    NULL,
    (APTR)libBeginIO,
    (APTR)libAbortIO,
    (APTR)-1
};

/* "__library" interface tag list */
STATIC CONST struct TagItem lib_managerTags[] =
{
    { MIT_Name,        (Tag)"__device"       },
    { MIT_VectorTable, (Tag)lib_manager_vectors },
    { MIT_Version,     1                        },
    { TAG_DONE,        0                        }
};

/* ------------------- Library Interface(s) ------------------------ */

/* Uncomment this line (and see below) if your library has a 68k jump table */
/* extern APTR VecTable68K[]; */

STATIC CONST CONST_APTR libInterfaces[] =
{
    lib_managerTags,
    NULL
};

STATIC CONST struct TagItem libCreateTags[] =
{
    { CLT_DataSize,    sizeof(struct MyDev) },
    { CLT_InitFunc,    (Tag)libInit },
    { CLT_Interfaces,  (Tag)libInterfaces},
    /* Uncomment the following line if you have a 68k jump table */
    /* { CLT_Vector68K, (Tag)VecTable68K }, */
    {TAG_DONE,         0 }
};


/* ------------------- ROM Tag ------------------------ */
STATIC CONST struct Resident lib_res
#ifdef __GNUC__
__attribute__((used))
#endif
=
{
    RTC_MATCHWORD,
    (struct Resident *)&lib_res,
    (APTR)(&lib_res + 1),
    RTF_NATIVE|RTF_AUTOINIT, /* Add RTF_COLDSTART if you want to be resident */
    VERSION,
    NT_DEVICE, /* Make this NT_DEVICE if needed */
    0, /* PRI, usually not needed unless you're resident */
    "ramdev.device",
    VSTRING,
    (APTR)libCreateTags
};

