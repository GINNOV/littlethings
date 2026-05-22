#include <stdlib.h>

#include <proto/dos.h>
#include <proto/exec.h>

#include "Library.h"
#include "Startup.h"

/*********************************************************************/

// change the libnix pool size by defining _MSTEP var

int  ThisRequiresConstructorHandling;
VOID *libnix_mempool;

asm
("
	.section \".text\"
	.align 2
	.type __restore_r13, @function
__restore_r13:
	lwz 13, 36(3)
	blr
__end__restore_r13:
	.size __restore_r13, __end__restore_r13 - __restore_r13
");

/**********************************************************************
	RunConstructors
**********************************************************************/

ULONG SAVEDS RunConstructors(struct MyLibrary *LibBase)
{
	struct CTDT *ctdt = (struct CTDT *)LibBase->ctdtlist, *last_ctdt = (struct CTDT *)LibBase->last_ctdt;

	while (ctdt < last_ctdt)
	{
		if (ctdt->priority >= 0)
		{
			if(ctdt->fp() != 0)
			{
				return 0;
			}
		}

		ctdt++;
	}

	malloc(0);

	return 1;
}

VOID SAVEDS RunDestructors(struct MyLibrary *LibBase)
{
	struct CTDT *ctdt = (struct CTDT *)LibBase->ctdtlist, *last_ctdt = (struct CTDT *)LibBase->last_ctdt;

	while (ctdt < last_ctdt)
	{
		if (ctdt->priority < 0)
		{
			if(ctdt->fp != (int (*)(void)) -1)
			{
				ctdt->fp();
			}
		}
		ctdt++;
	}
}
