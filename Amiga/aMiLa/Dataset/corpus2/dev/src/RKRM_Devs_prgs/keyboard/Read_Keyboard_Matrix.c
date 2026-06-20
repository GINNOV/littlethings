/*
 * Copyright (c) 1992 Commodore-Amiga, Inc.
 * 
 * This example is provided in electronic form by Commodore-Amiga, Inc. for 
 * use with the "Amiga ROM Kernel Reference Manual: Devices", 3rd Edition, 
 * published by Addison-Wesley (ISBN 0-201-56775-X).
 * 
 * The "Amiga ROM Kernel Reference Manual: Devices" contains additional 
 * information on the correct usage of the techniques and operating system 
 * functions presented in these examples.  The source and executable code 
 * of these examples may only be distributed in free electronic form, via 
 * bulletin board or as part of a fully non-commercial and freely 
 * redistributable diskette.  Both the source and executable code (including 
 * comments) must be included, without modification, in any copy.  This 
 * example may not be published in printed form or distributed with any
 * commercial product.  However, the programming techniques and support
 * routines set forth in these examples may be used in the development
 * of original executable software products for Commodore Amiga computers.
 * 
 * All other rights reserved.
 * 
 * This example is provided "as-is" and is subject to change; no
 * warranties are made.  All use is at your own risk. No liability or
 * responsibility is assumed.
 *
 *****************************************************************************
 *
 * Read_Keyboard_Matrix.c
 *
 * Compile with SAS C 5.10  lc -b1 -cfistq -v -y -L
 *
 * Run from CLI only
 */

#include <exec/types.h>
#include <exec/memory.h>
#include <exec/libraries.h>
#include <dos/dos.h>
#include <devices/keyboard.h>

#include <clib/exec_protos.h>
#include <clib/alib_protos.h>

#include <stdio.h>

#ifdef LATTICE
int CXBRK(void) { return(0); }     /* Disable SAS CTRL/C handling */
int chkabort(void) { return(0); }  /* really */
#endif


/*
 * There are keycodes from 0x00 to 0x7F, so the matrix needs to be
 * of 0x80 bits in size, or 0x80/8 which is 0x10 or 16 bytes...
 */
#define MATRIX_SIZE 16L

/*
 * This assembles the matrix for display that translates directly
 * to the RAW key value of the key that is up or down
 */

void Display_Matrix(UBYTE *keyMatrix)
{
SHORT  bitcount;
SHORT  bytecount;
SHORT   mask;
USHORT twobyte;

printf("\n    0 1 2 3 4 5 6 7");
printf("\n  +-----------------");
for (bitcount=0;bitcount<16;bitcount++)
    {
    printf("\n%x |",bitcount);
    mask=1 << bitcount;
    for (bytecount=0;bytecount<16;bytecount+=2)
        {
        twobyte=keyMatrix[bytecount] | (keyMatrix[bytecount+1] << 8);
        if (twobyte & mask)
            printf(" *");
        else
            printf(" -");
        }
    }
printf("\n\n");
}


VOID main(int argc, char *argv[])
{
extern struct Library *SysBase;
struct IOStdReq *KeyIO;
struct MsgPort  *KeyMP;
UBYTE    *keyMatrix;

if (KeyMP=CreatePort(NULL,NULL))
    {
     if (KeyIO=(struct IOStdReq *)
                CreateExtIO(KeyMP,sizeof(struct IOStdReq)))
        {
        if (!OpenDevice("keyboard.device",NULL,(struct IORequest *)KeyIO,NULL))
            {
            if (keyMatrix=AllocMem(MATRIX_SIZE,MEMF_PUBLIC|MEMF_CLEAR))
                {
                KeyIO->io_Command=KBD_READMATRIX;
                KeyIO->io_Data=(APTR)keyMatrix;
                KeyIO->io_Length= SysBase->lib_Version >= 36 ? MATRIX_SIZE : 13;
                DoIO((struct IORequest *)KeyIO);

                /* Check for CLI startup... */
                if (argc)
                    Display_Matrix(keyMatrix);

                FreeMem(keyMatrix,MATRIX_SIZE);
                }
            CloseDevice((struct IORequest *)KeyIO);
            }
        DeleteExtIO((struct IORequest *)KeyIO);
        }
    DeletePort(KeyMP);
    }
}
