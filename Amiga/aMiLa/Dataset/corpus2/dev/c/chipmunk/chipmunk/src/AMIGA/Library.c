/*
 *  chipmunk.library
 *
 *  Copyright © 2008 Ilkka Lehtoranta <ilkleht@isoveli.org>
 *  All rights reserved.
 *  
 *  $Id: Library.c,v 1.3 2006/11/02 23:29:20 itix Exp $
 */

#include <stddef.h>
#include <stdlib.h>

#include	<exec/resident.h>
#include <proto/dos.h>
#include <proto/exec.h>

#include	"Library.h"
#include "Startup.h"

/*********************************************************************/

#define COMPILE_VERSION		1
#define COMPILE_REVISION	0
#define COMPILE_DATE 		"(18.3.2008)"
#define PROGRAM_VER			"1.0"

STATIC CONST TEXT __attribute__((section(".text"))) VerString[]	= "\0$VER: chipmunk.library " PROGRAM_VER " " COMPILE_DATE;
STATIC CONST TEXT LibName[]	= "chipmunk.library";

struct ExecBase	*SysBase;
struct DosLibrary	*DOSBase;

extern CONST APTR FuncTable[];

/**********************************************************************
	data relocs
**********************************************************************/

#define R13_OFFSET 0x8000

extern int __datadata_relocs(void);

STATIC __inline int __dbsize(void)
{
	extern APTR __sdata_size, __sbss_size;
	STATIC CONST ULONG size[] =
	{
		(ULONG)&__sdata_size, (ULONG)&__sbss_size
	};
	return size[0] + size[1];
}

/**********************************************************************
	LibReserved
**********************************************************************/

ULONG LibReserved(void)
{
	return 0;
}

/**********************************************************************
	UserLibClose
**********************************************************************/

STATIC VOID UserLibClose(VOID)
{
}

/**********************************************************************
	FreeLib
**********************************************************************/

STATIC VOID FreeLib(struct MyLibrary *LibBase)
{
	CloseLibrary((struct Library *)DOSBase);
	FreeMem((APTR)((ULONG)(LibBase) - (ULONG)(LibBase->Library.lib_NegSize)), LibBase->Library.lib_NegSize + LibBase->Library.lib_PosSize);
}

/**********************************************************************
	LibInit
**********************************************************************/

extern APTR __r13_init;

STATIC struct Library *LibInit(struct MyLibrary *LibBase, BPTR SegList, struct ExecBase *MySysBase)
{
	char *r13 = (char *)&__r13_init;

	SysBase		= MySysBase;
	DOSBase		= (struct DosLibrary *)OpenLibrary("dos.library", 36);

	if (DOSBase)
	{
		InitSemaphore(&LibBase->Semaphore);

		NEWLIST(&LibBase->TaskContext.TaskList);

		LibBase->SegList	= SegList;
		LibBase->DataSeg   = r13 - R13_OFFSET;
		LibBase->DataSize  = __dbsize();
	}
	else
	{
		FreeLib(LibBase);
		LibBase	= NULL;
	}

	return (struct Library *)LibBase;
}

/**********************************************************************
	DeleteLib
**********************************************************************/

STATIC BPTR DeleteLib(struct MyLibrary *LibBase)
{
	BPTR	SegList	= 0;

	if (LibBase->Library.lib_OpenCnt == 0)
	{
		SegList	= LibBase->SegList;

		REMOVE(&LibBase->Library.lib_Node);
		FreeLib(LibBase);
	}

	return SegList;
}

/**********************************************************************
	LibExpunge
**********************************************************************/

BPTR LibExpunge(void)
{
	struct MyLibrary *LibBase = (struct MyLibrary *)REG_A6;
	LibBase->Library.lib_Flags	|= LIBF_DELEXP;
	return DeleteLib(LibBase);
}

/**********************************************************************
	LibClose
**********************************************************************/

BPTR LibClose(void)
{
	struct MyLibrary *LibBase = (struct MyLibrary *)REG_A6;
	BPTR SegList = 0;

	if (LibBase->Parent)
	{
		struct MyLibrary *ChildBase = LibBase;

		if ((--ChildBase->Library.lib_OpenCnt) > 0)
			return NULL;

		LibBase	= ChildBase->Parent;

		REMOVE(&ChildBase->TaskContext.TaskNode.Node);

		RunDestructors(ChildBase);

		FreeVec((APTR)((ULONG)(ChildBase) - (ULONG)(ChildBase->Library.lib_NegSize)));
	}

	ObtainSemaphore(&LibBase->Semaphore);

	LibBase->Library.lib_OpenCnt--;

	if (LibBase->Library.lib_OpenCnt == 0)
	{
		LibBase->Alloc = 0;
		UserLibClose();
	}

	ReleaseSemaphore(&LibBase->Semaphore);

	if (LibBase->Library.lib_Flags & LIBF_DELEXP)
	{
		SegList	= DeleteLib(LibBase);
	}

	return SegList;
}

/**********************************************************************
	LibOpen
**********************************************************************/

STATIC int comp_ctdt(struct CTDT *a, struct CTDT *b)
{
	if (a->priority == b->priority)
		return (0);
	if ((unsigned long)a->priority < (unsigned long) b->priority)
		return (-1);

	return (1);
}

struct Library *LibOpen(void)
{
	struct MyLibrary *LibBase = (struct MyLibrary *)REG_A6;
	struct MyLibrary	*newbase, *childbase;
	struct Task *MyTask = FindTask(NULL);
	struct TaskNode *ChildNode;
	ULONG MyBaseSize;

	ForeachNode(&LibBase->TaskContext.TaskList, ChildNode)
	{
		if (ChildNode->Task == MyTask)
		{
			/* Yep, return it */
			childbase = (APTR)(((ULONG)ChildNode) - offsetof(struct MyLibrary, TaskContext.TaskNode.Node));
			childbase->Library.lib_Flags &= ~LIBF_DELEXP;
			childbase->Library.lib_OpenCnt++;

			return(&childbase->Library);
		}
	}

	childbase  = NULL;
	MyBaseSize = LibBase->Library.lib_NegSize + LibBase->Library.lib_PosSize;
	LibBase->Library.lib_Flags &= ~LIBF_DELEXP;
	LibBase->Library.lib_OpenCnt++;

	ObtainSemaphore(&LibBase->Semaphore);

	if (LibBase->Alloc == 0)
	{
		if (LibBase->ConstructorsSorted == 0)
		{
			struct HunkSegment *seg;
			struct CTDT *_last_ctdt;

			LibBase->ConstructorsSorted = 1;
			LibBase->ctdtlist = (APTR)__ctdtlist;

			seg = (struct HunkSegment *)(((unsigned int)__ctdtlist) - sizeof(struct HunkSegment));
			_last_ctdt = (struct CTDT *)(((unsigned int)seg) + seg->Size);

			qsort((struct CTDT *)__ctdtlist, _last_ctdt - __ctdtlist, sizeof(*__ctdtlist), (int (*)(const void *, const void *))comp_ctdt);

			LibBase->last_ctdt = _last_ctdt;
		}

		LibBase->Alloc = 1;
	}

	if ((newbase = AllocVec(MyBaseSize + LibBase->DataSize + 15, MEMF_ANY)) != NULL)
	{
		CopyMem((APTR)((ULONG)LibBase - (ULONG)LibBase->Library.lib_NegSize), newbase, MyBaseSize);

		childbase = (APTR)((ULONG)newbase + (ULONG)LibBase->Library.lib_NegSize);

		if (LibBase->DataSize)
		{
			UBYTE *orig   = LibBase->DataSeg;
			LONG *relocs = (LONG *)__datadata_relocs;
			int	mem	= ((int)newbase + MyBaseSize + 15) & (unsigned int) ~15;

			CopyMem(orig, (char *)mem, LibBase->DataSize);

			if (relocs[0] > 0)
			{
				int i, num_relocs = relocs[0];

				for (i = 0, relocs++; i < num_relocs; ++i, ++relocs)
				{
					*(long *)(mem + *relocs) -= (int)orig - mem;
				}
			}

			childbase->DataSeg = (char *)mem + R13_OFFSET;

			if (RunConstructors(childbase) == 0)
			{
				RunDestructors(childbase);
				FreeVec(newbase);
				childbase = 0;
				goto error;
			}
		}

		childbase->Parent = LibBase;
		childbase->Library.lib_OpenCnt = 1;

		/* Register which task opened this child */
		childbase->TaskContext.TaskNode.Task = MyTask;
		ADDTAIL(&LibBase->TaskContext.TaskList, &childbase->TaskContext.TaskNode.Node);
	}
	else
	{
error:
		LibBase->Library.lib_OpenCnt--;

		if (LibBase->Library.lib_OpenCnt == 0)
		{
			LibBase->Alloc	= 0;
			UserLibClose();
		}
	}

	ReleaseSemaphore(&LibBase->Semaphore);
	return (struct Library *)childbase;
}

/**********************************************************************
	Library table
**********************************************************************/

STATIC CONST struct MyInitData InitData =
{
	{ 0xa0, 8, NT_LIBRARY, 0 },
	{ 0xa0, 9, -5, 0 },
	{ 0x80, 10 }, (ULONG)&LibName,
	{ 0xa0, 14,	LIBF_SUMUSED|LIBF_CHANGED, 0 },
	{ 0x90, 20 }, COMPILE_VERSION,
	{ 0x90, 22 }, COMPILE_REVISION,
	{ 0x80, 24 }, (ULONG)&VerString[7],
	0
};

STATIC CONST ULONG InitTable[] =
{
	sizeof(struct MyLibrary),
	(ULONG)	FuncTable,
	(ULONG)	&InitData,
	(ULONG)	LibInit
};

CONST struct Resident RomTag	=
{
	RTC_MATCHWORD,
	(struct Resident *)&RomTag,
	(struct Resident *)&RomTag+1,
	RTF_AUTOINIT | RTF_PPC | RTF_EXTENDED,
	COMPILE_VERSION,
	NT_LIBRARY,
	0,
	(char *)LibName,
	(char *)&VerString[7],
	(APTR)&InitTable,

	COMPILE_REVISION, NULL
};

/**********************************************************************
	Not needed but recommended (avoid confusion to PowerUp libraries)
**********************************************************************/

CONST ULONG __attribute__((section(".rodata"))) __abox__	= 1;

__asm("\n.section \".ctdt\",\"a\",@progbits\n__ctdtlist:\n.long -1,-1\n");
