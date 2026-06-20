/*
 * POSIX Compatibility Library for AmigaOS
 *
 * Written by Frank Wille <frank@phoenix.owl.de> in 2003-2004
 *
 * $Id: getpid.c,v 1.3 2017/05/17 20:38:43 phx Exp $
 */

#include <sys/types.h>
#pragma amiga-align
#include <dos/dosextens.h>
#ifdef __amigaos4__
#include <dos/obsolete.h>
#endif
#include <proto/exec.h>
#pragma default-align


pid_t getpid(void)
{
#ifdef __amigaos4__NOT_YET  /* @@@ how to find such an ID? */
  return ((struct Process *)FindTask(NULL))->pr_ProcessID;
#else
  return ((struct Process *)FindTask(NULL))->pr_TaskNum;
#endif
}
