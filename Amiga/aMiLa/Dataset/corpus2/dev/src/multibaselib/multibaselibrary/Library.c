#include <stddef.h>

#include <exec/execbase.h>
#include <exec/initializers.h>
#include <exec/nodes.h>
#include <exec/resident.h>
#include <proto/dos.h>
#include <proto/exec.h>

#include "Library.h"
#include "Version.h"

STATIC CONST TEXT __TEXTSEGMENT__ VerString[] = "$VER: multibase.library 1.0 (25.05.08) Copyright © Ilkka Lehtoranta";
STATIC CONST TEXT LibName[] = "multibase.library";

/**********************************************************************
	LIB_Init
**********************************************************************/

STATIC struct Library *LIB_Init(VREG(d0, struct MyLibrary *base), VREG(A0, APTR seglist), VREG(A6, struct ExecBase *sysbase))
{
	SysBase = sysbase;

	base->Library.lib_Node.ln_Type = NT_LIBRARY;
	base->Library.lib_Node.ln_Pri  = -10;
	base->Library.lib_Node.ln_Name = (STRPTR)LibName;
	base->Library.lib_Flags    = LIBF_SUMUSED | LIBF_CHANGED;
	base->Library.lib_Version  = VERSION;
	base->Library.lib_Revision = REVISION;
	base->Library.lib_IdString = (APTR)&VerString[6];

	NEWLIST(&base->TaskContext.TaskList);

	#if HAVE_USER_INIT
	InitSemaphore(&base->Semaphore);
	#endif

	return &base->Library;
}

/**********************************************************************
	LIB_UserOpen
**********************************************************************/
STATIC BOOL LIB_UserOpen(struct MyLibrary *base)
{
	BOOL rc = TRUE;

	base->Library.lib_Flags &= ~LIBF_DELEXP;
	base->Library.lib_OpenCnt++;

#if HAVE_USER_INIT
	if (!base->UserInitDone)
	{
		rc = FALSE;

		ObtainSemaphore(&base->Semaphore);

		if (!base->UserInitDone) // double check to avoid race condition
		{
			if (UserLibOpen(base))
				rc = base->UserInitDone = TRUE;
		}

		ReleaseSemaphore(&base->Semaphore);
	}
#endif

	return rc;
}

/**********************************************************************
	LIB_UserClose
**********************************************************************/

STATIC VOID LIB_UserClose(struct MyLibrary *base)
{
	base->Library.lib_OpenCnt--;

#if HAVE_USER_INIT
	if (base->Library.lib_OpenCnt == 0)
	{
		ObtainSemaphore(&base->Semaphore);

		if (base->Library.lib_OpenCnt == 0) // double check to avoid race condition
		{
			if (base->UserInitDone)
			{
				UserLibClose(base);
				base->UserInitDone = FALSE;
			}
		}

		ReleaseSemaphore(&base->Semaphore);
	}
#endif
}

/**********************************************************************
	LIB_Delete
**********************************************************************/

STATIC BPTR LIB_Delete(struct MyLibrary *LibBase, struct ExecBase *SysBase)
{
	BPTR SegList = 0;

	if (LibBase->Library.lib_OpenCnt == 0)
	{
		SegList = LibBase->SegList;
		REMOVE(&LibBase->Library.lib_Node);
		FreeMem((APTR)((ULONG)(LibBase) - (ULONG)(LibBase->Library.lib_NegSize)), LibBase->Library.lib_NegSize + LibBase->Library.lib_PosSize);
	}

	return SegList;
}

/**********************************************************************
	LIB_Expunge
**********************************************************************/

STATIC BPTR LIB_Expunge(struct MyLibrary *LibBase)
{
	if (LibBase->Parent)
	{
		struct MyLibrary *ChildBase;

		ChildBase = LibBase;
		LibBase = LibBase->Parent;

		FreeMem((APTR)((ULONG)(ChildBase) - (ULONG)(ChildBase->Library.lib_NegSize)), LibBase->Library.lib_NegSize + LibBase->Library.lib_PosSize);
	}

	LibBase->Library.lib_Flags |= LIBF_DELEXP;

	return LIB_Delete(LibBase, SysBase);
}

/**********************************************************************
	LIB_Close
**********************************************************************/

STATIC BPTR LIB_Close(struct MyLibrary *LibBase)
{
	BPTR SegList = 0;

	if (LibBase->Parent)
	{
		struct MyLibrary *ChildBase = LibBase;

		if ((--ChildBase->Library.lib_OpenCnt) > 0)
			return NULL;

		LibBase = ChildBase->Parent;

		REMOVE(&ChildBase->TaskContext.TaskNode.Node);
		FreeMem((APTR)((ULONG)(ChildBase) - (ULONG)(ChildBase->Library.lib_NegSize)), LibBase->Library.lib_NegSize + LibBase->Library.lib_PosSize);
	}

	LIB_UserClose(LibBase);

	if (LibBase->Library.lib_Flags & LIBF_DELEXP)
		SegList = LIB_Delete(LibBase, SysBase);

	return SegList;
}

/**********************************************************************
	LIB_Open
**********************************************************************/

STATIC struct Library *LIB_Open(struct MyLibrary *LibBase)
{
	struct MyLibrary *newbase, *childbase;
	struct Task *MyTask = FindTask(NULL);
	struct TaskNode *ChildNode;

	/* Has this task already opened a child? */
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

	childbase = NULL;

	if (LIB_UserOpen(LibBase))
	{
		if ((newbase = AllocMem(LibBase->Library.lib_NegSize + LibBase->Library.lib_PosSize, MEMF_ANY)) != NULL)
		{
			CopyMem((APTR)((ULONG)LibBase - (ULONG)LibBase->Library.lib_NegSize), newbase, LibBase->Library.lib_NegSize + LibBase->Library.lib_PosSize);
			CacheClearE(newbase, LibBase->Library.lib_NegSize, CACRF_ClearI | CACRF_ClearD); /* In MorphOS we dont need this if using SysV ABI */

			childbase = (APTR)((ULONG)newbase + (ULONG)LibBase->Library.lib_NegSize);

			childbase->Parent = LibBase;
			childbase->Library.lib_OpenCnt = 1;

			/* Register which task opened this child */
			childbase->TaskContext.TaskNode.Task = MyTask;
			ADDTAIL(&LibBase->TaskContext.TaskList, &childbase->TaskContext.TaskNode.Node);
		}
		else
		{
			LIB_UserClose(LibBase);
		}
	}

	return (struct Library *)childbase;
}

/**********************************************************************
	LIB_Reserved
**********************************************************************/

STATIC ULONG LIB_Reserved(void)
{
	return 0;
}

/**********************************************************************
	Library
**********************************************************************/

#if defined(__MORPHOS__)
STATIC struct Library *LIBStubs_Open   (void) { return LIB_Open((APTR)REG_A6); }
STATIC BPTR            LIBStubs_Close  (void) { return LIB_Close((APTR)REG_A6); }
STATIC BPTR            LIBStubs_Expunge(void) { return LIB_Expunge((APTR)REG_A6); }
#else
STATIC struct Library *LIBStubs_Open   (MREG(a6, APTR LibBase)) { return LIB_Open(LibBase); }
STATIC BPTR            LIBStubs_Close  (MREG(a6, APTR LibBase)) { return LIB_Close(LibBase); }
STATIC BPTR            LIBStubs_Expunge(MREG(a6, APTR LibBase)) { return LIB_Expunge(LibBase); }
#endif

STATIC const APTR FuncTable[] =
{
	#if defined(__MORPHOS__)
	(APTR) FUNCARRAY_32BIT_NATIVE, 
	#endif

	(APTR) LIBStubs_Open,
	(APTR) LIBStubs_Close,
	(APTR) LIBStubs_Expunge,
	(APTR) LIB_Reserved,

	(APTR) -1,
};

STATIC CONST ULONG InitTable[] =
{
	sizeof(struct MyLibrary),
	(ULONG) FuncTable,
	NULL,
	(ULONG) LIB_Init
};

CONST struct Resident __TEXTSEGMENT__ RomTag =
{
	RTC_MATCHWORD,
	(struct Resident *)&RomTag,
	(struct Resident *)&RomTag+1,
	#if defined(__MORPHOS__)
	RTF_AUTOINIT | RTF_PPC | RTF_EXTENDED,
	#else
	RTF_AUTOINIT,
	#endif
	VERSION,
	NT_LIBRARY,
	0,
	(char *)LibName,
	(char *)&VerString[6],
	(APTR)InitTable
	#if defined(__MORPHOS__)
	/* Resident structure extension */
	, REVISION, NULL
	#endif
};

/**********************************************************************
	Globals
**********************************************************************/

struct ExecBase *SysBase;

#if defined(__MORPHOS__)
CONST ULONG __abox__ = 1;
#endif
