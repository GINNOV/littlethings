/*
 * POSIX Compatibility Library for AmigaOS
 *
 * Written by Frank Wille <frank@phoenix.owl.de> in 2003-2004
 *
 * $Id: signal.h,v 1.2 2017/06/16 19:14:55 phx Exp $
 */

#ifndef _SIGNAL_H_
#define _SIGNAL_H_

#include_next <signal.h>
#include <sys/types.h>

#define SIGHUP 100
#define SIGQUIT 101
#define SIGKILL 102

/* Prototypes */
int kill(pid_t, int);
int killpg(pid_t, int);

#endif /* _SIGNAL_H_ */
