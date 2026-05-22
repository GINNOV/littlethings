/*************************************************************
*
*    ---------------
*   * Supra library *
*    ---------------
*
*   -- File type --
*   Demonstration of FileType()
*
*   Usage: ftype file
*   file = file to be examined
*   This function will return code 10 if provided file is
*   a directory, code 5 if file does not exist, or 0 if
*   it's a plain file.
*
*
*   ©1995 by Jure Vrhovnik -- all rights reserved
*   jurev@gea.fer.uni-lj.si
*
*************************************************************/

#include <stdio.h>
#include <stdlib.h>
#include <libraries/supra.h>

main(int argc, char *argv[])
{
LONG type;

    if (argc == 0) {
        printf("Please run this program from CLI\n");
    } else {
        type = FileType(argv[1]);
        if (type < 0) {
            printf(" %s is a file\n", argv[1]);
        } else if (type > 0) {
            printf(" %s is a directory\n", argv[1]);
            exit(10);
        } else {
            printf(" %s does not exist\n", argv[1]);
            exit(5);
        }
    }
}
