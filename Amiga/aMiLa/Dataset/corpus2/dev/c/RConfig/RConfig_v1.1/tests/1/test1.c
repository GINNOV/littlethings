/*
 * RConfig Validation Suite by Anthon Pang, Omni Communications Products
 *
 * Object Code: detach
 * Assigned Test # 1
 * Requirements: ?
 * Desired Observation(s):
 *   CLI prompt returns.  Detached program opens window, and stays
 *   loaded for 5 seconds before exiting.
 */

#include <exec/types.h>
#include <dos/dos.h>
#include <clib/dos_protos.h>

#include "rlib.h"

/*
 * Required by detach code
 */
long _stack = 0L;
long _priority = 0L;
long _BackGroundIO = 0L;
char *_procname = "test1";

BPTR f;

void main() {

    f = Open((STRPTR)"CON:50/50/200/50/Test1", MODE_OLDFILE);
    if (f) {
        Write(f, "\nDetached from CLI.\nExiting in 5 seconds.", 41);
        Delay(500); /* WAIT 5 SECONDS */
        Close(f);
    }
    exit(0);
}
