#include "amiga.h"
#include "signals.h"
#include "processes.h"
#include <exec/execbase.h>

extern struct ExecBase *SysBase;

static void break_list(struct List *tasks, BPTR fh)
{
  struct Process *p;

  for (p = (struct Process *)tasks->lh_Head; p->pr_Task.tc_Node.ln_Succ;
       p = (struct Process *)p->pr_Task.tc_Node.ln_Succ)
    {
      if (p->pr_Task.tc_Node.ln_Type == NT_PROCESS)
	{
	  struct CommandLineInterface *cli = p->pr_CLI ? BADDR(p->pr_CLI) : 0;

	  if (p->pr_CIS == fh || p->pr_COS == fh || p->pr_CES == fh ||
	      cli && (cli->cli_StandardInput == fh || cli->cli_CurrentInput == fh ||
		      cli->cli_StandardOutput == fh || cli->cli_CurrentOutput == fh))
	    Signal(p, SIGBREAKF_CTRL_C | SIGBREAKF_CTRL_D);
	}
    }
}

static int magickill(BPTR fh, int signo)
{
  switch (signo)
    {
    case SIGINT: case SIGQUIT: case SIGKILL: case SIGHUP:
      Forbid();
      break_list(&SysBase->TaskReady, fh);
      break_list(&SysBase->TaskWait, fh);
      Permit();
      return 0;
    default: errno = EINVAL; return -1;
    }
}

int kill(int pid, int signal)
{
  chkabort();
  /* Our process list is now reasonably upto date */
  if (pid < 0) pid = -pid;	/* Consider that each process is a pg unto itself */
  if (pid == _our_pid) 
    {
      if (signal) _sig_dispatch(signal);
      return 0;
    }
  else 
    {
      struct process *entry;
      int killrc;

      entry = _find_pid(pid);
      if (!entry || entry->status != alive)
	{
	  errno = ESRCH;
	  return -1;
	}
      if (!signal) return 0;
      killrc = magickill(entry->input, signal);
      if (signal == SIGKILL)
	{
	  /* Fake the kill from emacs point of view */
	  entry->status = exited;
	  entry->rc = SIGKILL;
	  _sig_dispatch(SIGCHLD);
	  return 0;
	}
      return killrc;
    }
}
