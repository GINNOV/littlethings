/****************************************************************
*
*    ---------------
*   * Supra library *
*    ---------------
*
*   -- Subdir --
*   Demonstration of RecDirInit(), RecDirNextTags, RecDirFree()
*
*   Usage: subdir path
*   path = directory path to be examined (including with it's
*   subdirs).
*
*   This program will scan files through the entire directory
*   tree, starting from a provided path.
*
*
*   ©1995 by Jure Vrhovnik -- all rights reserved
*   jurev@gea.fer.uni-lj.si
*
*****************************************************************/

#include <stdio.h>
#include <stdlib.h>
#include <clib/exec_protos.h>
#include <clib/dos_protos.h>
#include <string.h>

#include <libraries/supra.h>


struct RecDirInfo rdi;
char path[50];

char full[200];
LONG size, allsize=0, files=0;
int pos;

main(int argc, char *argv[])
{
UBYTE err;

    if (argc == 0) {
        printf("Enter directory to list: ");
        gets(path);
        rdi.rdi_Path = path;
    } else rdi.rdi_Path = argv[1];

    rdi.rdi_Num = -1;       /* Unlimited number of subdirs deep */
    rdi.rdi_Pattern = NULL; /* No pattern */

    if (RecDirInit(&rdi) == 0) {
        printf("Scanning %s\n\n", rdi.rdi_Path);

        while ((err = RecDirNextTags(&rdi, NULL,
                                    RD_FULL, full,
                                    RD_SIZE, &size,
                                    TAG_DONE)) == 0) {
            pos = strlen(full)-25;
            if (pos < 0) pos = 0;

            printf("%-25s%15ld\n", full+pos, size);
            allsize += size;
            files++;
        }

        switch(err) {
            case DN_ERR_END:
                printf("\n%ld files -- %ld bytes listed\n", files, allsize);
                break;
            default:
                printf("error, terminating...\n");
        }
    } else {
        printf("Path not found.\n");
    }
}

