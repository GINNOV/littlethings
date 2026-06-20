/* this is a test library */
#include <exec/types.h>

char myname[] = "mylib.library";
char myid[] = "mylib 1.0 (23 Oct 1986)\r\n";

LONG GetDown()
{
        return (77);
}

ULONG Double(arg)
ULONG arg;
{
        return (2 * arg);
}

LONG Triple(arg)
LONG arg;
{
    arg *= 3;

    return ((LONG)arg);
}

LONG Add(apples,oranges)
LONG apples,oranges;
{
    return(apples+oranges);
}

LONG Sum(a,b,c,d,e,f)
LONG a,b,c,d,e,f;
{
    return(a+b+c+d+e+f);
}

