#include "proto/exec.h"
#include "proto/dos.h"
#include "test_pragmas.h"
#include <stdio.h>

char __stdiowin[] = "con:0/0/640/100";


struct Library *TestBase;

main()
{
        int ret;
        
        printf("Each time this version is run, the value\n");
        printf("returned from test1() will be incremented\n");
        printf("The value is not reset unless the library\n");
        printf("gets flushed from memory.\n");
        
        
        TestBase = OpenLibrary("test_one.library",0);
        if (TestBase)
        {
            printf("Library Opened Sucessfully.\n");
            ret = test1();
            
            printf("test1 returned = %d\n", ret);
            
            test2(ret+1);
            
            printf("test1 returned = %d\n",test1());
            CloseLibrary(TestBase);
            printf("Library Closed.\n");
        }
}
