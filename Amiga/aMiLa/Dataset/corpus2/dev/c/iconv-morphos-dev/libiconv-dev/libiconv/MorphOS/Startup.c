#include <stdlib.h>

#include <proto/dos.h>
#include <proto/exec.h>

#include <clib/debug_protos.h>

#include "Library.h"
#include "Startup.h"

#ifdef BUILD_BASEREL_LIBRARY
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
	struct CTDT *ctdt = LibBase->ctdtlist, *last_ctdt = LibBase->last_ctdt;

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
	struct CTDT *ctdt = LibBase->ctdtlist, *last_ctdt = LibBase->last_ctdt;

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
#else
void *malloc(size_t size)
{
	ULONG *ptr;

	if (size)
	{
		size += 4;

		if ((ptr = AllocTaskPooled(size)))
			*ptr++ = size;

		return ptr;
	}

	return NULL;
}

void free(void *ptr)
{
	if (ptr)
	{
		ULONG *p;
		ULONG s;

		p = ptr;
		s = *--p;

		FreeTaskPooled(p, s);
	}
}
#endif

void errno(void) { } /* Cause error if anything uses errno variable! */
void __chkabort(void) { }
void abort(void) { kprintf("iconv: Something called abort()! Painful death follows...\n"); for (;;) Wait(0); }

void libiconv_set_relocation_prefix(const char *orig_prefix, const char *curr_prefix)
{
	/* Dummy */
}

const char *locale_charset(void)
{
	/* ATM we always default to latin1 */
	return "ISO-8859-1";
}
