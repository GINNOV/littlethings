#include "amiga.h"
#include "files.h"
#include "fifofd.h"
#include "signals.h"
#include "timers.h"
#include <fcntl.h>

extern int __close(int fd);

void _close_all(void)
{
    int fd, lfd = _last_fd();

    for (fd = 0; fd < lfd; fd++)
	__close(fd);
}

void __saveds __exit(int rc)
{
    /*
     * I really don't know why I should flush stdout here! If not done
     * a crash is very likely. SAS C misteries ...
     */
    fflush(stdout);
    _close_all();
    _cleanup_fifo();
    _cleanup_signals();
    _free_timer(_odd_timer);
    _XCEXIT(rc);
}

#ifdef _exit
#undef _exit
#endif

void __saveds _exit(int rc)
{
    __exit(rc);
}
