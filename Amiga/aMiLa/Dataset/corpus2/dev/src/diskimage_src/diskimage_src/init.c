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

#include "diskimage_device.h"
#include <exec/exec.h>
#include <proto/exec.h>
#include <dos/dos.h>
#include <stdarg.h>

#include "diskimage.device_rev.h"
#define LIBNAME "diskimage.device"

/* Version Tag */
CONST UBYTE
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
struct Library *libInit (struct DiskImageBase *libBase, APTR seglist, struct ExecIFace *IExec) {
	struct DiskImageBase *result = NULL;
	struct LocaleInfo *li;

	dbug(("Init()\n"));

	libBase->dib_LibNode.lib_Node.ln_Type = NT_DEVICE;
	libBase->dib_LibNode.lib_Node.ln_Pri  = 0;
	libBase->dib_LibNode.lib_Node.ln_Name = LIBNAME;
	libBase->dib_LibNode.lib_Flags        = LIBF_SUMUSED|LIBF_CHANGED;
	libBase->dib_LibNode.lib_Version      = VERSION;
	libBase->dib_LibNode.lib_Revision     = REVISION;
	libBase->dib_LibNode.lib_IdString     = VSTRING;

	libBase->dib_IExec = IExec;
	
	/* Save pointer to our loaded code (the SegList) */
	libBase->dib_SegList = (BPTR)seglist;

	libBase->dib_DOSBase = IExec->OpenLibrary("dos.library", 52);
	libBase->dib_IDOS = (struct DOSIFace *)
		IExec->GetInterface(libBase->dib_DOSBase, "main", 1, NULL);
	if (!libBase->dib_IDOS) goto out;

	libBase->dib_UtilityBase = IExec->OpenLibrary("utility.library", 52);
	libBase->dib_IUtility = (struct UtilityIFace *)
		IExec->GetInterface(libBase->dib_UtilityBase, "main", 1, NULL);
	if (!libBase->dib_IUtility) goto out;

	libBase->dib_SigSem = IExec->AllocSysObject(ASOT_SEMAPHORE, NULL);
	if (!libBase->dib_SigSem) goto out;

	libBase->dib_Port = IExec->AllocSysObjectTags(ASOT_PORT,
		ASOPORT_Action,	PA_IGNORE,
		TAG_END);
	if (!libBase->dib_Port) goto out;
		
	libBase->dib_Units = IExec->AllocSysObjectTags(ASOT_LIST,
		ASOLIST_Min,	TRUE,
		TAG_END);
	if (!libBase->dib_Units) goto out;

	result = libBase;

out:

	/* Clean up if the initialization failed */
	if (!result) {
		IExec->FreeSysObject(ASOT_LIST, libBase->dib_Units);
		IExec->FreeSysObject(ASOT_PORT, libBase->dib_Port);
		IExec->FreeSysObject(ASOT_SEMAPHORE, libBase->dib_SigSem);
		IExec->DropInterface((struct Interface *)libBase->dib_IUtility);
		IExec->CloseLibrary(libBase->dib_UtilityBase);
		IExec->DropInterface((struct Interface *)libBase->dib_IDOS);
		IExec->CloseLibrary(libBase->dib_DOSBase);
		IExec->DeleteLibrary((struct Library *)libBase);
	}

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

static void FreeUnit (struct ExecIFace *IExec, struct DiskImageUnit *unit) {
	IExec->FreeSysObject(ASOT_PORT, unit->diu_ChangePort);
	IExec->FreeSysObject(ASOT_LIST, unit->diu_ChangeInts);
	IExec->FreeSysObject(ASOT_PORT, unit->diu_Port);
	IExec->FreeSysObject(ASOT_SEMAPHORE, unit->diu_SigSem);
	IExec->FreeSysObject(ASOT_MESSAGE, unit);
}

/* dev_open() sets the io_Error field on an error. If it was successful,
   we should also set up the io_Unit and ln_Type fields.
   Exec takes care of setting up io_Device. */

/* Open the library */
LONG libOpen(struct DeviceManagerInterface *Self,
	struct IORequest *io, ULONG unit_number,
	ULONG flags)
{
	struct DiskImageBase *libBase = (struct DiskImageBase *)Self->Data.LibBase;
	struct ExecIFace *IExec = libBase->dib_IExec;
	struct DiskImageUnit *unit;

	dbug(("Open()\n"));

	/* Subtle point: any AllocMem() call can cause a call to this device's
	   expunge vector.  If lib_OpenCnt is zero, the device might get expunged. */

	IExec->ObtainSemaphore(libBase->dib_SigSem);
	   
	libBase->dib_LibNode.lib_OpenCnt++; /* Fake an opener for duration of call */
	io->io_Error = OK;
	
	if (unit_number == ~0) {
		io->io_Unit = NULL;
		io->io_Message.mn_Node.ln_Type = NT_REPLYMSG;

		libBase->dib_LibNode.lib_Flags &= ~LIBF_DELEXP;
		IExec->ReleaseSemaphore(libBase->dib_SigSem);

		return OK;
	}

	unit = (struct DiskImageUnit *)IExec->GetHead(libBase->dib_Units);
	while (unit) {
		if (unit->diu_UnitNum == unit_number) {
			unit->diu_OpenCnt++;
			
			io->io_Unit = (struct Unit *)unit;
			io->io_Message.mn_Node.ln_Type = NT_REPLYMSG;
			
			libBase->dib_LibNode.lib_Flags &= ~LIBF_DELEXP;
			IExec->ReleaseSemaphore(libBase->dib_SigSem);
			
			return OK;
		}
		unit = (struct DiskImageUnit *)IExec->GetSucc(&unit->diu_Msg.mn_Node);
	}
	
	unit = IExec->AllocSysObjectTags(ASOT_MESSAGE,
		ASOMSG_Size,		sizeof(struct DiskImageUnit),
		ASOMSG_ReplyPort,	libBase->dib_Port,
		ASOMSG_Name,		libBase->dib_LibNode.lib_Node.ln_Name,
		TAG_END);
	if (unit) {
		memset((struct Message *)unit+1, 0, sizeof(struct DiskImageUnit)-sizeof(struct Message));
		unit->diu_OpenCnt = 1;
		unit->diu_UnitNum = unit_number;
		unit->diu_LibBase = libBase;

		unit->diu_SigSem = IExec->AllocSysObject(ASOT_SEMAPHORE, NULL);
		
		unit->diu_Port = IExec->AllocSysObjectTags(ASOT_PORT,
			ASOPORT_AllocSig,	FALSE,
			ASOPORT_Action,		PA_IGNORE,
			TAG_END);

		unit->diu_ChangeInts = IExec->AllocSysObjectTags(ASOT_LIST,
			ASOLIST_Min,	TRUE,
			TAG_END);

		unit->diu_ChangePort = IExec->AllocSysObjectTags(ASOT_PORT,
			ASOPORT_AllocSig,	FALSE,
			ASOPORT_Action,		PA_IGNORE,
			TAG_END);

		if (unit->diu_SigSem && unit->diu_Port && unit->diu_ChangeInts &&
			unit->diu_ChangePort)
		{
			unit->diu_Port->mp_SigTask =
			unit->diu_ChangePort->mp_SigTask =
			(struct Task *)libBase->dib_IDOS->CreateNewProcTags(
				NP_Name,		libBase->dib_LibNode.lib_Node.ln_Name,
				NP_Input,		0,
				NP_Output,		0,
				NP_Error,		0,
				NP_CurrentDir,	0,
				NP_Entry,		UnitProcEntry,
				NP_Priority,	-1,
				TAG_END);
		}
		
		if (unit->diu_Port->mp_SigTask) {
			libBase->dib_Port->mp_SigBit = SIGB_CHILD;
			libBase->dib_Port->mp_SigTask = IExec->FindTask(NULL);
			libBase->dib_Port->mp_Flags = PA_SIGNAL;

			IExec->PutMsg(&((struct Process *)unit->diu_Port->mp_SigTask)->pr_MsgPort,
				&unit->diu_Msg);
			IExec->WaitPort(libBase->dib_Port);
			IExec->GetMsg(libBase->dib_Port);
			IExec->SetSignal(0, SIGF_CHILD);
			
			IExec->AddTail(libBase->dib_Units, &unit->diu_Msg.mn_Node);
			io->io_Unit = (struct Unit *)unit;
			io->io_Message.mn_Node.ln_Type = NT_REPLYMSG;
			
			libBase->dib_LibNode.lib_Flags &= ~LIBF_DELEXP;
			IExec->ReleaseSemaphore(libBase->dib_SigSem);
			
			return OK;
		}

		FreeUnit(IExec, unit);
	}

	/* IMPORTANT: Mark IORequest as "complete" */
	io->io_Message.mn_Node.ln_Type = NT_REPLYMSG;

	/* IMPORTANT: trash io_Device on open failure */
	io->io_Device = NULL;
	
	if (io->io_Error == OK) io->io_Error = TDERR_NotSpecified;

	IExec->ReleaseSemaphore(libBase->dib_SigSem);

	libBase->dib_LibNode.lib_OpenCnt--; /* End of expunge protection */

	return(io->io_Error);
}

/***********************************************************************/

/* There are two different things that might be returned from the dev_close()
   routine.  If the device wishes to be unloaded, then dev_close() must return
   the segment list (as given to dev_init()).  Otherwise dev_close() MUST
   return NULL. */

BPTR libExpunge(struct DeviceManagerInterface *Self);

/* Close the library */
BPTR libClose(struct DeviceManagerInterface *Self,
	struct IORequest *io)
{
	struct DiskImageBase *libBase = (struct DiskImageBase *)Self->Data.LibBase;
	struct ExecIFace *IExec = libBase->dib_IExec;
	struct DiskImageUnit *unit = (struct DiskImageUnit *)io->io_Unit;
	BPTR result = 0;

	dbug(("Close()\n"));

	IExec->ObtainSemaphore(libBase->dib_SigSem);
	
	/* IMPORTANT: make sure the IORequest is not used again
	   with a -1 in io_Device, any BeginIO() attempt will
	   immediatly halt (which is better than a subtle corruption
	   that will lead to hard-to-trace crashes!!! */
	io->io_Unit = (struct Unit *)-1;
	io->io_Device = (struct Device *)-1;

	/* see if the unit is still in use */
	if(unit && --unit->diu_OpenCnt == 0) {
		IExec->Remove(&unit->diu_Msg.mn_Node);

		libBase->dib_Port->mp_SigBit = SIGB_CHILD;
		libBase->dib_Port->mp_SigTask = IExec->FindTask(NULL);
		libBase->dib_Port->mp_Flags = PA_SIGNAL;

		IExec->PutMsg(unit->diu_Port, &unit->diu_Msg);
		IExec->WaitPort(libBase->dib_Port);
		IExec->GetMsg(libBase->dib_Port);
		IExec->SetSignal(0, SIGF_CHILD);

		FreeUnit(IExec, unit);
	}

	/* mark us as having one fewer openers */
	libBase->dib_LibNode.lib_OpenCnt--;

	/* see if there is anyone left with us open */
	if(libBase->dib_LibNode.lib_OpenCnt == 0)
	{
		/* see if we have a delayed expunge pending */
		if(libBase->dib_LibNode.lib_Flags & LIBF_DELEXP)
		{
			/* do the expunge */
			return libExpunge(Self);
		}
	}

	IExec->ReleaseSemaphore(libBase->dib_SigSem);
		
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
	struct DiskImageBase *libBase = (struct DiskImageBase *)Self->Data.LibBase;
	struct ExecIFace *IExec = libBase->dib_IExec;
	BPTR result = 0;

	dbug(("Expunge()\n"));

	/* see if anyone has us open */
	if (libBase->dib_LibNode.lib_OpenCnt > 0) {
		/* it is still open.  set the delayed expunge flag */
		libBase->dib_LibNode.lib_Flags |= LIBF_DELEXP;
	} else {
		struct LocaleInfo *li;
		/* go ahead and get rid of us. */
		result = libBase->dib_SegList;

		/* unlink from device list */
		IExec->Remove((struct Node *)libBase); /* Remove first (before FreeMem) */

		/* ...device specific closings here... */
		IExec->FreeSysObject(ASOT_LIST, libBase->dib_Units);
		IExec->FreeSysObject(ASOT_PORT, libBase->dib_Port);
		IExec->FreeSysObject(ASOT_SEMAPHORE, libBase->dib_SigSem);
		IExec->DropInterface((struct Interface *)libBase->dib_IUtility);
		IExec->CloseLibrary(libBase->dib_UtilityBase);
		IExec->DropInterface((struct Interface *)libBase->dib_IDOS);
		IExec->CloseLibrary(libBase->dib_DOSBase);

		/* free our memory */
		IExec->DeleteLibrary((struct Library *)libBase);
	}

	return result;
}

/* ------------------- Manager Interface ------------------------ */
/* These are generic. Replace if you need more fancy stuff */
LONG _manager_Obtain(struct DeviceManagerInterface *Self)
{
    return Self->Data.RefCount++;
}

ULONG _manager_Release(struct DeviceManagerInterface *Self)
{
    return Self->Data.RefCount--;
}

/* Manager interface vectors */
STATIC CONST APTR lib_manager_vectors[] = {
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
STATIC CONST struct TagItem lib_managerTags[] = {
    { MIT_Name,        (Tag)"__device"       	},
    { MIT_VectorTable, (Tag)lib_manager_vectors },
    { MIT_Version,     1                        },
    { TAG_DONE,        0                        }
};

extern CONST APTR lib_main_vectors[];

STATIC CONST struct TagItem lib_mainTags[] = {
    { MIT_Name,        (Tag)"main"       		},
    { MIT_VectorTable, (Tag)lib_main_vectors 	},
    { MIT_Version,     1                        },
    { TAG_DONE,        0                        }
};

/* ------------------- Library Interface(s) ------------------------ */

/* Uncomment this line (and see below) if your library has a 68k jump table */
/* extern APTR VecTable68K[]; */

STATIC CONST CONST_APTR libInterfaces[] =
{
    lib_managerTags,
	lib_mainTags,
    NULL
};

STATIC CONST struct TagItem libCreateTags[] =
{
    { CLT_DataSize,    sizeof(struct DiskImageBase) },
    { CLT_InitFunc,    (Tag)libInit },
    { CLT_Interfaces,  (Tag)libInterfaces},
    /* Uncomment the following line if you have a 68k jump table */
    /* { CLT_Vector68K, (Tag)VecTable68K }, */
    {TAG_DONE,         0 }
};


/* ------------------- ROM Tag ------------------------ */
CONST struct Resident lib_res
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
    LIBNAME,
    VSTRING,
    (APTR)libCreateTags
};
