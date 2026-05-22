#include "amiga.h"
#include "signals.h"
#include "processes.h"
#include <sys/wait.h>

int wait4(int pid, int *statusp, int options, struct rusage *rusage)
{
  struct process *p;

  do {
    int seen = FALSE;

    scan_processes(p)
      if (pid == 0 || p->pid == pid)
	{
	  seen = TRUE;

	  if (p->status == exited)
	    {
	      int pid = p->pid;

	      if (statusp) *statusp = p->rc;
	      _free_entry(p);

	      return pid;
	    }
	}
    if (options & WNOHANG) return 0;
    if (!seen)
      {
	errno = ECHILD;
	return -1;
      }
    _handle_signals(_wait_signals(0));
  } while (1);
}

int wait3(int *statusp, int options, struct rusage *rusage)
{
  return wait4(0, statusp, options, rusage);
}

int wait(int *statusp)
{
  return wait4(0, statusp, 0, NULL);
}

int waitpid(int pid, int *statusp, int options)
{
  /* We have no process groups, so : 
       Our process group encompasses all our children
       Each child is a process group unto itself
     This is somewhat contradictory ... Should this be changed ? */
  if (pid == -1) pid = 0;
  if (pid < 0) pid = -pid;
  return wait4(pid, statusp, options, NULL);
}
