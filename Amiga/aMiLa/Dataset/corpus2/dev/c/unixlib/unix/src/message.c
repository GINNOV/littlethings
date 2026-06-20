#include "amiga.h"
#include <intuition/intuition.h>
#include <stdarg.h>

static struct EasyStruct msg =
{
    sizeof(struct EasyStruct),
    0,
    NULL,
    NULL,
    "Ok",
};

static void message(char *format, long *args)
/* Display a message which is as visible as possible (either to the console
   or to as a requester).
   Assume very little about library state */
{
    LONG msg_EasyRequestArgs(struct Window *window, struct EasyStruct *easyStruct,
			     ULONG * idcmpPtr, APTR args);
#pragma libcall msg_IntuitionBase msg_EasyRequestArgs 24C BA9804
    BPTR fh;
    int close = FALSE;
    extern char *_ProgramName;
    extern struct WBStartup *WBenchMsg;

    fh = _us->pr_CES;
    if (!fh)
	if (!WBenchMsg && (fh = Open("console:", MODE_OLDFILE)))
	    close = TRUE;

    if (fh) {
	FPrintf(fh, "%s: ", _ProgramName);
	VFPrintf(fh, format, (long *) args);
	FPutC(fh, '\n');
	if (close)
	    Close(fh);
    } else {
	struct Window *win = (struct Window *) _us->pr_WindowPtr;
	if (win != (struct Window *) -1) {
	    struct Library *msg_IntuitionBase = OpenLibrary("intuition.library", 37);

	    if (msg_IntuitionBase) {
		msg.es_Title = _ProgramName;
		msg.es_TextFormat = format;
		msg_EasyRequestArgs(win, &msg, 0, args);
		CloseLibrary(msg_IntuitionBase);
	    }
	}
    }
}

void _message(char *format,...)
/* Display a message which is as visible as possible (either to the console
   or to as a requester).
   Assume very little about library state */
{
    va_list args;

    va_start(args, format);
    message(format, (long *) args);
}

void _fail(char *format,...)
/* Display a message which is as visible as possible (either to the console
   or to as a requester).
   Assume very little about library state.
   Exit with error code RETURN_FAIL after that. */
{
    va_list args;

    va_start(args, format);
    message(format, (long *) args);

    exit(RETURN_FAIL);		/* The library should always be cleanup-able */
}
