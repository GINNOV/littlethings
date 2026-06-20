#include <proto/exec.h>
#include "mystartup.h"

struct WBStartup *WBStartup = NULL;

struct DosLibrary *DOSBase = NULL;

__saveds int mystartup(void)
{
    struct Process *myproc;
    int retval;

    myproc = (struct Process *)FindTask(NULL);
    if (! myproc->pr_CLI) {
        WaitPort(&myproc->pr_MsgPort);
        WBStartup = (struct WBStartup *)GetMsg(&myproc->pr_MsgPort);
    }

    if (! (DOSBase = (struct DosLibrary *)OpenLibrary("dos.library",
            __min_oslibver)))
        goto err;

    retval = main();
    goto end;

err:
    retval = RETURN_FAIL;
end:
    if (DOSBase)
        CloseLibrary((struct Library *)DOSBase);
    if (WBStartup) {
        Forbid();
        ReplyMsg((struct Message *)WBStartup);
    }
    return retval;
}
