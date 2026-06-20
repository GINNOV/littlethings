/* iconv.library
 *
 * Copyright (C) 2006-2007 Ilkka Lehtoranta
 */

#include <stddef.h>
#include <stdlib.h>

#include <exec/resident.h>
#include <proto/dos.h>
#include <proto/exec.h>

#include "Library.h"
#include "Startup.h"

/**********************************************************************
	LibReserved
**********************************************************************/

STATIC ULONG LibReserved(void)
{
	return 0;
}

/*********************************************************************/

#define COMPILE_VERSION		3
#define COMPILE_REVISION	0
#define COMPILE_DATE 		"(31.3.2007)"
#define PROGRAM_VER			"3.0"

STATIC CONST TEXT __attribute__((section(".text"))) VerString[] = "\0$VER: iconv.library " PROGRAM_VER " " COMPILE_DATE;
STATIC CONST TEXT LibName[]	= "iconv.library";

struct ExecBase	*SysBase;
struct DosLibrary	*DOSBase;

#ifdef BUILD_BASEREL_LIBRARY
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
#endif

/**********************************************************************
	FreeLib
**********************************************************************/

STATIC VOID FreeLib(struct MyLibrary *LibBase)
{
	CloseLibrary((struct Library *)DOSBase);
	FreeMem((UBYTE *)LibBase - LibBase->Library.lib_NegSize, LibBase->Library.lib_NegSize + LibBase->Library.lib_PosSize);
}

/**********************************************************************
	LibInit
**********************************************************************/

extern APTR __r13_init;

STATIC struct Library *LibInit(struct MyLibrary *LibBase, BPTR SegList, struct ExecBase *MySysBase)
{
#ifdef BUILD_BASEREL_LIBRARY
	char *r13 = (char *)&__r13_init;
#endif

	SysBase		= MySysBase;
	DOSBase		= (struct DosLibrary *)OpenLibrary("dos.library", 36);

	if (DOSBase)
	{
#ifdef BUILD_BASEREL_LIBRARY
		InitSemaphore(&LibBase->Semaphore);

		NEWLIST(&LibBase->TaskContext.TaskList);

		LibBase->DataSeg   = r13 - R13_OFFSET;
		LibBase->DataSize  = __dbsize();
#endif
		LibBase->SegList   = SegList;
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

STATIC BPTR LibExpunge(void)
{
	struct MyLibrary *LibBase = (struct MyLibrary *)REG_A6;
	LibBase->Library.lib_Flags	|= LIBF_DELEXP;
	return DeleteLib(LibBase);
}

/**********************************************************************
	LibClose
**********************************************************************/

STATIC BPTR LibClose(void)
{
	struct MyLibrary *LibBase = (struct MyLibrary *)REG_A6;
	BPTR SegList = 0;

#ifdef BUILD_BASEREL_LIBRARY
	if (LibBase->Parent)
	{
		struct MyLibrary *ChildBase = LibBase;

		if ((--ChildBase->Library.lib_OpenCnt) > 0)
			return NULL;

		LibBase	= ChildBase->Parent;

		REMOVE(&ChildBase->TaskContext.TaskNode.Node);

		RunDestructors(ChildBase);

		FreeMem((UBYTE *)ChildBase - ChildBase->Library.lib_NegSize, LibBase->Library.lib_NegSize + LibBase->Library.lib_PosSize + LibBase->DataSize + 15);
	}

	ObtainSemaphore(&LibBase->Semaphore);
#endif

	LibBase->Library.lib_OpenCnt--;

#ifdef BUILD_BASEREL_LIBRARY
	if (LibBase->Library.lib_OpenCnt == 0)
	{
		LibBase->Alloc = 0;
//		UserLibClose(LibBase, SysBase);
	}

	ReleaseSemaphore(&LibBase->Semaphore);
#endif

	if (LibBase->Library.lib_Flags & LIBF_DELEXP)
	{
		SegList	= DeleteLib(LibBase);
	}

	return SegList;
}

/**********************************************************************
	LibOpen
**********************************************************************/

#ifdef BUILD_BASEREL_LIBRARY
STATIC int comp_ctdt(struct CTDT *a, struct CTDT *b)
{
	if (a->priority == b->priority)
		return (0);
	if ((unsigned long)a->priority < (unsigned long) b->priority)
		return (-1);

	return (1);
}
#endif

STATIC struct Library *LibOpen(void)
{
	struct MyLibrary *LibBase = (struct MyLibrary *)REG_A6;
#ifdef BUILD_BASEREL_LIBRARY
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
#endif
	LibBase->Library.lib_Flags &= ~LIBF_DELEXP;
	LibBase->Library.lib_OpenCnt++;

#ifdef BUILD_BASEREL_LIBRARY
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

		if (1)
		{
			LibBase->Alloc = 1;
		}
		else
		{
			goto error;
		}
	}

	if ((newbase = AllocMem(MyBaseSize + LibBase->DataSize + 15)) != NULL)
	{
		CopyMem((UBYTE *)LibBase - LibBase->Library.lib_NegSize, newbase, MyBaseSize);

		childbase = (APTR)((UBYTE *)newbase + LibBase->Library.lib_NegSize);

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
				FreeMem(newbase, MyBaseSize + LibBase->DataSize + 15);
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
//			UserLibClose(LibBase, SysBase);
		}
	}

	ReleaseSemaphore(&LibBase->Semaphore);
	return (struct Library *)childbase;
#else
	return (struct Library *)LibBase;
#endif
}

/**********************************************************************
	Library table
**********************************************************************/

#define	PROTO(ret, name) ret ICONV_##name(void);

typedef void * iconv_t;
PROTO(iconv_t, libiconv_open)
PROTO(size_t, libiconv)
PROTO(int, libiconv_close)
PROTO(int, libiconvctl)
PROTO(void, libiconvlist)
PROTO(void, libiconv_set_relocation_prefix)
PROTO(const char *, iconv_canonicalize)

STATIC CONST APTR FuncTable[] =
{
	(APTR)	FUNCARRAY_BEGIN,
	(APTR)	FUNCARRAY_32BIT_NATIVE, 

	(APTR)	LibOpen,
	(APTR)	LibClose,
	(APTR)	LibExpunge,
	(APTR)	LibReserved,
	(APTR)	-1,

	(APTR)	FUNCARRAY_32BIT_SYSTEMV,
	(APTR)	ICONV_libiconv_open,
	(APTR)	ICONV_libiconv,
	(APTR)	ICONV_libiconv_close,
	(APTR)	ICONV_libiconvctl,
	(APTR)	ICONV_libiconvlist,
	(APTR)	ICONV_libiconv_set_relocation_prefix,
	(APTR)	ICONV_iconv_canonicalize,
	(APTR)	-1,

	(APTR)	FUNCARRAY_END
};

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

CONST struct Resident __attribute__((section(".text"))) RomTag =
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

CONST ULONG __abox__	= 1;

#ifdef BUILD_BASEREL_LIBRARY
__asm("\n.section \".ctdt\",\"a\",@progbits\n__ctdtlist:\n.long -1,-1\n");
#endif
