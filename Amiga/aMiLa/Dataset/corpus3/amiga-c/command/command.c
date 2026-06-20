/* Executes a CLI command and write the output to a file */
#include <proto/dos.h>
#include <proto/exec.h>
#include <stdio.h>
#include <stdlib.h>

main()
{

    struct Library *DOSBase;

    int version = 0;
    BOOL result;
    FILE *f;
    BPTR fh;


    DOSBase=OpenLibrary("dos.library",version);

    if (DOSBase){
        printf("DOS Library V%d open \n",version);
        fh = Open("ram:file.bin", MODE_NEWFILE) ;

        result = Execute("dir LIBS:",NULL,fh);
        // NULL as output redurect to shell 

        printf("%d",result);

        Close(fh) ;
        CloseLibrary(DOSBase);
    }else{
        printf("No DOS \n");
    }

    return 0;

}