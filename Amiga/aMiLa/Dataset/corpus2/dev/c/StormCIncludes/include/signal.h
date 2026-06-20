#ifndef _INCLUDE_SIGNAL_H
#define _INCLUDE_SIGNAL_H

/*
**  $VER: signal.h 1.2 (30.07.2000)
**  StormC Release 4.0
**
**  '(C) Copyright 1995-2000 Haage & Partner Computer GmbH'
**	 All Rights Reserved
*/

#ifdef __cplusplus
extern "C" {
#endif

void (*signal(int, void(*)(int)))(int);
int raise(int);

typedef int sig_atomic_t;

#define _NSIG	6

#define SIGTERM 0
#define SIGABRT 1
#define SIGFPE  2
#define SIGILL  3
#define SIGINT  4
#define SIGSEGV 5

#define SIG_IGN ((void(*)(int))  0)
#define SIG_DFL ((void(*)(int))  1)
#define SIG_ERR ((void(*)(int)) -1)

#ifdef __cplusplus
}
#endif

#endif	/* _INCLUDE_SIGNAL_H */
