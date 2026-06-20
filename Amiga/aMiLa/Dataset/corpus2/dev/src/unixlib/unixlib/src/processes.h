#ifndef _PROCESSES_H
#define _PROCESSES_H_

struct process
{
    struct MinNode node;
    struct Task *process;
    int pid;
    BPTR input;
    enum { alive, exited } status;
    int rc;
};

struct exit_message		/* Sent by children when exiting */
{
  struct Message m;
  int pid;
  int rc;
};

extern int _next_pid, _our_pid;
extern struct MinList _processes;
#define DOOR_LEN 32
extern char _door_name[DOOR_LEN];
extern struct MsgPort *_children_exit;
extern struct MsgPort *_startup_port;

#define scan_processes(p) for (p = (struct process *)_processes.mlh_Head; \
			       p->node.mln_Succ; \
			       p = (struct process *)p->node.mln_Succ)

#define no_processes() (_processes.mlh_Head->mln_Succ == 0)

void _free_entry(struct process *p);
struct process *_find_pid(int pid);
void _init_processes(void);
void _cleanup_processes(void);

#endif
