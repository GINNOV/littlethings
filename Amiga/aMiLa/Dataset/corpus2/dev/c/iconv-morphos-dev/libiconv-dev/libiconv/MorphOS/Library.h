#ifndef	__LIBRARY_H__
#define	__LIBRARY_H__

/* iconv.library
 *
 * Copyright (C) 2006 Ilkka Lehtoranta
 */

#ifndef	DOS_DOS_H
#include <dos/dos.h>
#endif

#ifndef	EXEC_LIBRARIES_H
#include <exec/libraries.h>
#endif

#ifndef	UTILITY_UTILITY_H
#include <utility/utility.h>
#endif

/**********************************************************************
	Structures
**********************************************************************/

#pragma pack(2)
struct MyInitData
{
	UBYTE ln_Type_Init[4];
	UBYTE ln_Pri_Init[4];
	UBYTE ln_Name_Init[2];
	ULONG ln_Name_Content;
	UBYTE lib_Flags_Init[4];
	UBYTE lib_Version_Init[2]; UWORD lib_Version_Content;
	UBYTE lib_Revision_Init[2]; UWORD lib_Revision_Content;
	UBYTE lib_IdString_Init[2];
	ULONG lib_IdString_Content;
	UWORD EndMark;
};
#pragma pack()

struct TaskNode
{
	struct MinNode Node;
	struct Task *Task;
};

struct MyLibrary
{
	struct Library				Library;
#ifdef BUILD_BASEREL_LIBRARY
	UBYTE							Alloc;
	UBYTE							ConstructorsSorted;
	APTR							DataSeg;

	ULONG							DataSize;
	BPTR							SegList;
	struct MyLibrary			*Parent;

	union
	{
		struct MinList TaskList;
		struct TaskNode TaskNode;
	} TaskContext;

	APTR                    ctdtlist;
	APTR                    last_ctdt;

	struct SignalSemaphore	Semaphore;
#else
	BPTR							SegList;
#endif
};

#ifdef BUILD_BASEREL_LIBRARY
#define SAVEDS __saveds
#else
#define SAVEDS
#endif

/**********************************************************************
	Prototypes
**********************************************************************/

ULONG SAVEDS		RunConstructors(struct MyLibrary *LibBase);
VOID SAVEDS			RunDestructors	(struct MyLibrary *LibBase);


#endif /* __LIBRARY_H__ */
