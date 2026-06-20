#ifndef SIGNALS_H
#define SIGNALS_H

#include <signal.h>

extern void (*_sig_handlers[NSIG])(int);
extern long _sig_mask, _sig_pending;

void _sig_dispatch(int sig);
/* Effect: Do the action associated with signal sig it it isn't masked
     Mask it for the duration of the signal exec
*/

ULONG _check_signals(ULONG extra_sigs);
ULONG _wait_signals(ULONG extra_sigs);
int _handle_signals(ULONG sigs);

void _init_signals(void);
void _cleanup_signals(void);

#endif
