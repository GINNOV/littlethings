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

static TEXT language[64];
static TEXT untranslated[64];
static TEXT lc_all[64];
static TEXT lc_ctype[64];
static TEXT lang[64];
static TEXT charset[128];

/**********************************************************************
	getenv
**********************************************************************/

char *getenv(const char *name)
{
	char dummy[2];
	size_t len;
	char *var;

	if (name[0] == 'L')
	{
		if (name[1] == 'A')
		{
			var = language;

			if (!strcmp(name, "LANGUAGE"))
				return var;

			var = lang;

			if (!strcmp(name, "LANG"))
				return var;
		}
		else
		{
			var = lc_all;

			if (!strcmp(name, "LC_ALL"))
				return var;

			var = lc_ctype;

			if (!strcmp(name, "LC_CTYPE"))
				return var;
		}
	}
	else
	{
		var = untranslated;

		if (!strcmp(name, "GETTEXT_LOG_UNTRANSLATED"))
			return var;

		var = charset;

		if (!strcmp(name, "CHARSETALIASDIR"))
			return var;
	}

	var = NULL;

	if (GetVar((char *)name, dummy, sizeof(dummy), GVF_BINARY_VAR) == -1)
		return var;

	len = IoErr() + 1;

	var = malloc(len);

	if (!var)
	{
		return NULL;
	}

	if (GetVar((char *)name, var, len, GVF_BINARY_VAR) == -1)
	{
		free(var);
		var = NULL;
	}

	return var;
}

/**********************************************************************
	GetVars
**********************************************************************/

static void GetVars(void)
{
	GetVar("LANGUAGE", language, sizeof(language), 0);
	GetVar("GETTEXT_LOG_UNTRANSLATED", untranslated, sizeof(untranslated), 0);
	GetVar("LC_ALL", lc_all, sizeof(lc_all), 0);
	GetVar("LC_CTYPE", lc_ctype, sizeof(lc_ctype), 0);
	GetVar("LANG", lang, sizeof(lang), 0);
	GetVar("CHARSETALIASDIR", charset, sizeof(charset), 0);
}

/**********************************************************************
	RunConstructors
**********************************************************************/

ULONG SAVEDS RunConstructors(struct MyLibrary *LibBase)
{
	ULONG rc = 0;

	struct CTDT *ctdt = LibBase->ctdtlist, *last_ctdt = LibBase->last_ctdt;

	while (ctdt < last_ctdt)
	{
		if (ctdt->priority >= 0)
		{
			if(ctdt->fp() != 0)
			{
				return rc;
			}
		}

		ctdt++;
	}

	malloc(0);
	GetVars();

	rc = 1;

	return rc;
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

void __chkabort(void) { }
void abort(void) { }
int raise(int sig) { return 0; };
