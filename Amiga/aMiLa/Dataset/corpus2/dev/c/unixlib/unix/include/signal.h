#ifndef _SIGNAL_H
#define _SIGNAL_H

#include <sys/types.h>

#define NSIG 32			/* We define lots of signals (though most are
				   never generated) */

/* Signal number definitions */
/* Those which can be generated other than by kill are described with
    <name>, amiga: <cause> */
   

#define SIGHUP 1		/* hangup */
#define SIGINT 2		/* interrupt, amiga: ctrl-c */
#define SIGQUIT 3		/* quit, amiga: ctrl-d */
#define SIGILL 4		/* illegal instruction */
#define SIGTRAP 5		/* trace trap */
#define SIGIOT 6		/* abort, amiga: abort() called */
#define SIGABRT SIGIOT		/* compatibility */
#define SIGEMT 7		/* emulator trap */
#define SIGFPE 8		/* arithmetic exception, amiga: arith op */
#define SIGKILL 9		/* kill */
#define SIGBUS 10		/* bus error */
#define SIGSEGV 11		/* segmentation violation */
#define SIGSYS 12		/* bad argument to system call */
#define SIGPIPE 13		/* write on pipe or socket with no reader,
				   amiga: generated for 'pipe's or 'sktpair's */
#define SIGALRM 14		/* alarm clock, amiga: see alarm */
#define SIGTERM 15		/* software termination */
#define SIGURG 16		/* urgent condition on socket */
/* SIGSTOP, SIGTSTP, SIGCONT, SIGTTIN, SIGTTOU undefined to avoid creating the
   belief that we support stopped processes */
#define SIGCHLD 20		/* child status has changed */
#define SIGIO 23		/* I/O possible on a descriptor */
/* Less usual signals: SIGXCPU, SIGXFSZ, SIGVTALARM, SIGPROF, SIGLOST not defined */
#define SIGWINCH 28		/* window changed */
#define SIGUSR1 30		/* user-defined signal 1 */
#define SIGUSR2 31		/* user-defined signal 2 */

#if 0
#define SIG_DFL (void *)0
#define SIG_IGN (void *)1
#else
#define SIG_ERR (void (*)(int)) -1
#define SIG_DFL (void (*)(int)) 0
#define SIG_IGN (void (*)(int)) 1
#endif

/*
 * Flags for sigprocmask:
 */
#define SIG_BLOCK	1	/* block specified signal set */
#define SIG_UNBLOCK	2	/* unblock specified signal set */
#define SIG_SETMASK	3	/* set specified signal set */

/*
 * Macro for converting signal number to a mask
 */
#define sigmask(m)	(1UL << (m))

typedef long sigset_t;

extern void (*signal(int sig,void (*fn)(int)))(int);
extern int raise(int);
extern long sigsetmask(long mask);
extern int sigprocmask(int, const sigset_t *, sigset_t *);

/* Only kill(getpid(), sig) works */
/* Also, getpid() is a unique number for this process */
extern int getpid(void);
extern int kill(int pid, int sig);

#endif
