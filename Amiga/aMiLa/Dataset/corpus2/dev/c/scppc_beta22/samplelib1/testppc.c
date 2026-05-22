#include <proto/dos.h>
#include <proto/exec.h>

extern int _b;  /* this will be resolved to the definition of 'b' */
                /* from the 68k compiler */

test1(void)
{
    struct DOSLibrary *DOSBase;
    void *SysBase = *(void **)4;


printf("in test1\n");
    
    DOSBase = OpenLibrary("dos.library", 0);
    if (DOSBase)
    {
        Write(Output(), "in test1\n", 9);
        CloseLibrary(DOSBase);
    }
    return(_b);
}

test2(int a)
{
    struct DOSLibrary *DOSBase;
    void *SysBase = *(void **)4;
    
    DOSBase = OpenLibrary("dos.library", 0);
    if (DOSBase)
    {
        Write(Output(), "in test2\n", 9);
        CloseLibrary(DOSBase);
    }
    _b = a;
    return(_b);
}




/* These are so the 68k can access these functions */
int (*__PPC_test1)(void) = test1;
int (*__PPC_test2)(int) = test2;
