#include "amiga.h"
#include "processes.h"
#include <amiga/ioctl.h>
#include <exec/memory.h>
#include <dos/dosextens.h>
#include <dos/dostags.h>
#include <string.h>

/* Variables used by a child that is starting up */
struct MemList *_child_entry;	/* Memory used for child's code */
struct Message startup_message;
struct exit_message *_child_exit;
char *_child_command;
int _child_command_len;
char *_child_door_name;
int _child_door_name_len;
extern char far _child_startup, far _child_startup_end;

int exec(char *program, char **argv, int input, int output, char *dir, int stacksize)
{
  int index, comsize;
  char *combuf, *bp;
  BPTR in, out, dirlock;
  struct process *entry = (struct process *)malloc(sizeof(struct process));
  static struct MemList alloc_child = { { 0 }, 1 };
  int _pseudo_close(int fd);
  
  /* in & out must be different fhs for CreateNewProc. But get_fh
     is not guaranteed to return different fhs when called twice on
     the same file :-( Luckily it does for socketpairs.
     Don't try & pass the same AmigaDOS file for input & output */
  if (input == -1) in = Input();
  else if (ioctl(input, _AMIGA_GET_FH, &in) == -1) { in = 0; }
  if (output == -1) out = Output();
  else if (ioctl(output, _AMIGA_GET_FH, &out) == -1) { out = 0; }
  if (input != -1) _pseudo_close(input);
  if (output != -1 && input != output) _pseudo_close(output);

  comsize = 256;
  combuf = AllocMem(comsize, 0);

  _child_exit = AllocMem(sizeof(struct exit_message), 0);
  _child_door_name = AllocMem(DOOR_LEN, 0);

  alloc_child.ml_ME[0].me_Length = &_child_startup_end - &_child_startup;
  _child_entry = AllocEntry(&alloc_child);

  if (entry && in && out && combuf && _child_exit && _child_door_name &&
      (long)_child_entry > 0)
    {
      memcpy(_child_entry->ml_ME[0].me_Addr, &_child_startup,
	     _child_entry->ml_ME[0].me_Length);
      strcpy(_child_door_name, _door_name);
      _child_door_name_len = DOOR_LEN;

      bp = combuf;
      for (index = 0; argv[index] != 0; index++)
	{
	  char *s = argv[index];
	  int len;

	  len = 3;
	  while (*s) len += 1 + 2 * (*s++ == '"');
	  if (bp + len + 1 >= combuf + comsize)
	    {
	      char *newbuf;
	      int new_comsize;

	      new_comsize = 2 * comsize + len;
	      newbuf = AllocMem(new_comsize, 0);
	      if (!newbuf) { errno = ENOMEM; goto error; }
	      memcpy(newbuf, combuf, comsize);

	      bp = newbuf + (bp - combuf);
	      combuf = newbuf;
	      comsize = new_comsize;
	    }
	  *bp++ = ' ';
	  *bp++ = '"';
	  s = argv[index];
	  while (*s)
	    {
	      if (*s == '"' || *s == '*') *bp++ = '*';
	      *bp++ = *s++;
	    }
	  *bp++ = '"';
	}
      *bp = '\0';
      if (dir) dirlock = Lock(dir, SHARED_LOCK);
      else
	{
	  BPTR cd = CurrentDir(0);

	  dirlock = DupLock(cd);
	  CurrentDir(cd);
	}
      if (dirlock)
	{
	  entry->pid = _next_pid++;
	  entry->input = in;
	  _child_command = combuf;
	  _child_command_len = comsize;

	  /* This message is sent by the child when it has started */
	  startup_message.mn_Length = sizeof(startup_message);
	  startup_message.mn_Node.ln_Type = NT_MESSAGE;

	  /* This message is sent by the child when it exits */
	  _child_exit->m.mn_Length = sizeof(*_child_exit);
	  _child_exit->m.mn_Node.ln_Type = NT_MESSAGE;
	  _child_exit->pid = entry->pid;

	  entry->process = CreateNewProcTags(NP_Entry, _child_entry->ml_ME[0].me_Addr,
					     NP_Input, in,
					     NP_CloseInput, input != -1,
					     NP_Output, out,
					     NP_CloseOutput, output != -1,
					     NP_StackSize,
					      stacksize > 0 ? stacksize : _stack_size,
					     NP_CurrentDir, dirlock,
					     NP_Cli, TRUE,
					     TAG_END);
	  if (entry->process)
	    {
	      do WaitPort(_startup_port); while (!GetMsg(_startup_port));
	      entry->status = alive;
	      AddHead((struct List *)&_processes, (struct Node *)entry);
	      return entry->pid;
	    }
	}
      errno = convert_oserr(IoErr());
      FreeMem(combuf, comsize);
      free(entry);
      if (dirlock) UnLock(dirlock);
    }
  else errno = ENOMEM;

 error:
  if (in && input != -1) Close(in);
  if (out && output != -1) Close(out);
  if (combuf) FreeMem(combuf, comsize);
  if (_child_exit) FreeMem(_child_exit, sizeof(struct exit_message));
  if (_child_door_name) FreeMem(_child_door_name, DOOR_LEN);
  if ((long)_child_entry > 0) FreeEntry(_child_entry);
  return -1;
}
