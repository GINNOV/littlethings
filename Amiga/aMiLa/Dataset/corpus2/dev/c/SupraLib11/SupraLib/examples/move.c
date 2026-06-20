/*******************************************************************
*
*    ---------------
*   * Supra library *
*    ---------------
*
*   -- Move file demo --
*   Demonstration of FCopy() function.
*
*   This is a simple program that moves a source file to a
*   destination file.
*   Usage is: Move sfile dfile
*   sfile = source file to be moved
*   dfile = destination file
*
*   Example: move c:list ram:ls
*   (will copy c:list to ram:ls, and delete c:list)
*
*
*   ©1995 by Jure Vrhovnik -- all rights reserved
*   jurev@gea.fer.uni-lj.si
*
*******************************************************************/

#include <clib/dos_protos.h>
#include <dos/dos.h>
#include <libraries/supra.h>
#include <stdio.h>

main(int argc, char *argv[])
{
UBYTE err;

    if (argc == 0) {    /* Started from WB */
        printf("Please start this from CLI\n");
    } else if (argc != 3) {  /* Move needs exactly two arguments */
        printf("Usage: %s source dest\n",argv[0]);
    } else {
        if (err = FCopy(argv[1], argv[2], 0)) { /* Error occured */
            switch(err) {
                case FC_ERR_EXIST:
                    printf("%s does not exist\n", argv[1]);
                    break;
                case FC_ERR_DEST:
                    printf("Error writing to %s\n", argv[2]);
                    break;
                default:
                    printf("Error: cannot move the file\n");
            }
        } else {
            if (!(DeleteFile(argv[1]))) printf("Cannot delete source file\n");
            printf("File moved\n");
        }
    }
}

