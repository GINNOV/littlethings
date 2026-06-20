#include "ppcdispatch.h"

extern void *_PPC_test1, *_PPC_test2;
int b = 0;

__asm __saveds test1(void)
{
        return(CallPPCFunction(_PPC_test1));
}

__asm __saveds test2(register __d1 int a)
{
        return CallPPCFunction(_PPC_test2, a);
}
