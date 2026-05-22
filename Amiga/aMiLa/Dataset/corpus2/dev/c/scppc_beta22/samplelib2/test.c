#include <proto/dos.h>
#include <proto/exec.h>

extern void *_PPC_test1, *_PPC_test2;
int b = 0;

__asm __saveds test1(void)
{
    struct DOSLibrary *DOSBase;
    void *SysBase = *(void **)4;

    DOSBase = OpenLibrary("dos.library", 0);
    if (DOSBase)
    {
        Write(Output(), "in test1\n", 9);
        CloseLibrary(DOSBase);
    }
    return(b);
}

__asm __saveds test2(register __d1 int a)
{
    struct DOSLibrary *DOSBase;
    void *SysBase = *(void **)4;
    
    DOSBase = OpenLibrary("dos.library", 0);
    if (DOSBase)
    {
        Write(Output(), "in test2\n", 9);
        CloseLibrary(DOSBase);
    }
    b = a;
    return(b);
}
