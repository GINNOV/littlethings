
/*
 *  SIGNAL.H
 *
 *  (c)Copyright 1990, Matthew Dillon, All Rights Reserved
 */

#ifndef SIGNAL_H
#define SIGNAL_H

typedef char sig_atomic_t;
typedef void (*__sigfunc)(int);

#define SIG_ERR ((__sigfunc)(-1))
#define SIG_DFL ((__sigfunc)(0))
#define SIG_IGN ((__sigfunc)(1))

#define SIGABRT     1
#define SIGFPE	    2
#define SIGILL	    3
#define SIGINT	    4	/*  also static init in signal/signal.c */
#define SIGSEGV     5
#define SIGTERM     6
#define SIGPIPE     7
#define SIGCLD	    8
#define SIGQUIT     9
#define SIGBUS	    10
#define SIGIOT	    11

#define SIGHUP	    SIGINT

#define NSIG	    32

extern __sigfunc signal(int, __sigfunc);
extern int raise(int);

#endif

