
#include <objpak.h>
#include <setjmp.h>

/*
 * The following macros are used by other Objective-C compilers
 * for exception handling, as follows:
 *
 *   DURING
 *     ... code that might send -error: ...
 *   HANDLER
 *     ... code that handles exception (falls through) ...
 *   ENDHANDLER
 *
 * We implement this using Blocks and can (unlike other compilers)
 * postpone the longjmp() and first evaluate the handler as subroutine
 * of -error:
 */

#define DURING if (1) { jmp_buf buf; if (setjmp(buf)==0) [{
#define HANDLER } ifError:{ :msg :rcv |
#define ENDHANDLER longjmp(buf,1);}]; }

