#include "amiga.h"
#include "signals.h"
#include "processes.h"

int getpid(void)
{
    __chkabort();
    return _our_pid;
}
