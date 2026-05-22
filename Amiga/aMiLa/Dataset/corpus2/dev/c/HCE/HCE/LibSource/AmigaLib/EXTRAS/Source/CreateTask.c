#include <exec/types.h>
#include <exec/tasks.h>
#include <exec/memory.h>

#define ME_TASK    0
#define ME_STACK   1
#define NUMENTRIES 2

struct FakeMemEntry {
     ULONG fme_Reqs;
     ULONG fme_Length;
};

struct FakeMemList {
    struct Node fml_Node;
    UWORD fml_NumEntries;
    struct FakeMemEntry fml_ME[NUMENTRIES];
};

struct FakeMemList TaskMemTemplate = {
      { 0 },
      NUMENTRIES,
      {
        { MEMF_PUBLIC | MEMF_CLEAR, sizeof(struct Task) },
        { MEMF_CLEAR, 0 }
       }  
};

struct Task *CreateTask (name, pri, initPC, stacksize)
char *name;
ULONG pri;
APTR initPC;
ULONG stacksize;
{
    struct Task *newTask;
    struct FakeMemList fakememlist;
    struct MemList *ml;

    stacksize = (stacksize + 3) & ~3;

    fakememlist = TaskMemTemplate;
    fakememlist.fml_ME[ME_STACK].fme_Length = stacksize;
    ml = (struct MemList *)AllocEntry((struct MemList *)&fakememlist);

    if(!ml)
        return(NULL);
        newTask = (struct Task *)ml->ml_ME[ME_TASK].me_Addr;
        newTask->tc_SPLower = ml->ml_ME[ME_TASK].me_Addr;

        newTask->tc_SPUpper = (APTR)((ULONG)(newTask->tc_SPLower) + stacksize);

        newTask->tc_Node.ln_Type = NT_TASK;
        newTask->tc_Node.ln_Pri = pri;
        newTask->tc_Node.ln_Name = name;

        AddTask (newTask, initPC, 0L);

    return (newTask);
}
