#include <stdio.h>

#include <exec/types.h>
#include <exec/tasks.h>
#include <exec/memory.h>

#include <inline/exec.h>

#define STACKSIZE 80000

extern struct ExecBase * SysBase;

struct StackSwapStruct MyStackSwap;
int MainReturn;

extern int main2(int argc, char *argv[]);

int main(int argc, char *argv[])
{
    struct Task *me = FindTask(NULL);
    ULONG currentstack = (ULONG) me->tc_SPUpper - (ULONG) me->tc_SPLower;

    if (currentstack < STACKSIZE) {
        ULONG * MyStack;
        
        if (MyStack = (ULONG *) AllocVec(STACKSIZE, MEMF_PUBLIC)) {
            MyStackSwap.stk_Lower = MyStack;
            MyStackSwap.stk_Upper = (ULONG)MyStack + STACKSIZE;
            MyStackSwap.stk_Pointer = (void *)(MyStackSwap.stk_Upper - 16);
            StackSwap(&MyStackSwap);

            /* From here until the second StackSwap() call, the local variables
               within this function are off-limits (unless your compiler accesses
               them through a register other than A7 with a stack-frame) */

            MainReturn = main2(argc, argv);

            // @todo can crash here - don't know why

            StackSwap(&MyStackSwap);

            /* Now locals can be accessed again */
            FreeVec(MyStack);
        } else {
            printf("Error: Can't allocate new stack!\n");
        }

        return MainReturn;
    }

    return main2(argc, argv);
}
