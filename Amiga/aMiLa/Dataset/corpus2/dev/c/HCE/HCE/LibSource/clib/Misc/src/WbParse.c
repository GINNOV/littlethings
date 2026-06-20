/*
 * This module invoked if called from workbench.
 */

#include <libraries/dosextens.h>
#include <workbench/workbench.h>
#include <workbench/startup.h>
#include <workbench/icon.h>

typedef struct DiskObject DISKOBJ;
typedef struct Process PROC;
typedef struct FileHandle HANDLE;
typedef struct WBStartup WBSTART;
typedef struct WBArg WBARG;

void *IconBase = 0;
extern void CloseLibrary(), FreeDiskObject();
extern void *OpenLibrary();
extern long Open();
extern DISKOBJ *GetDiskObject();
extern char *FindToolType();

_wb_parse(processp, wbMsg)
register PROC *processp;
WBSTART *wbMsg;
{
	register char *cp;
	register DISKOBJ *diskobjp;
	register HANDLE	*handlep;
	register ULONG window;
	WBARG *wbMsgp;

	if ( !(IconBase = OpenLibrary("icon.library", 0L)) )
		return;
	wbMsgp = wbMsg->sm_ArgList;
	if ( !(diskobjp = GetDiskObject(wbMsgp->wa_Name)) )
		goto done;

	/*
	 * Manx does this, and it seems like a good idea.
	 */

	cp = FindToolType(diskobjp->do_ToolTypes, "WINDOW");

          if(cp[0] != '\0')          /* Changed by J.P. */
              {
		if (window = Open(cp, MODE_OLDFILE))
                    {
			handlep =  (HANDLE *)(window << 2);
			processp->pr_ConsoleTask = (void *)handlep->fh_Type;
			processp->pr_CIS = window;
			processp->pr_COS = Open("*", MODE_OLDFILE);
		     }
	       }
	FreeDiskObject(diskobjp);
done:
	CloseLibrary(IconBase);
	IconBase = 0L;
}
