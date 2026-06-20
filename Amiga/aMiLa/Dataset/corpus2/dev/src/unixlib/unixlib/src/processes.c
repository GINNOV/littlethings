#include "amiga.h"
#include <clib/alib_protos.h>

#include "processes.h"

int _next_pid, _our_pid;
struct MinList _processes;
char _door_name[DOOR_LEN];
struct MsgPort *_children_exit;
struct MsgPort *_startup_port;

void _free_entry(struct process *p)
{
  Remove((struct Node *)p);
  free(p);
}

struct process *_find_pid(int pid)
{
  struct process *entry;

  scan_processes (entry) if (entry->pid == pid) return entry;

  return 0;
}

void _init_processes(void)
{
  NewList((struct List *)&_processes);
  /* Choose a fairly unique pid for ourselves, but keep it within a range
     which guarantees positive pid's for all created processes.
     This range is further restricted to 23 bits so that a pid fits within the
     range of an emacs number (generally 24 bits, though it is 26 on the Amiga) */
  _our_pid = ((int)_us ^ _startup_time) & 0x7fffff;
  _next_pid = _our_pid + 1;
  _sprintf(_door_name, "door.%lx.%lx", _us, _startup_time);
  if ((_startup_port = CreateMsgPort()) &&
      (_children_exit = CreatePort(_door_name, 0))) return;

  _fail("No memory");
}

void _cleanup_processes(void)
{
  if (_startup_port) DeleteMsgPort(_startup_port);
  if (_children_exit)
    {
      struct exit_message *msg;

      Forbid();
      while (msg = (struct exit_message *)GetMsg(_children_exit))
	FreeMem(msg, sizeof(struct exit_message));
      DeletePort(_children_exit);
      Permit();
    }
}
