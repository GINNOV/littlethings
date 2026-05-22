/* ------------------------------------------------------------------ */
/* $VER: MyGuiTest.asl.c 39.01 (12.12.1999)                           */
/*                                                                    */
/* Supporting ASL requestor functions                                 */
/* Advanced demo program for easyaudio.library                        */
/*                                                                    */
/* (C) Copyright 1999-2000 Matthew J Fletcher - All Rights Reserved.  */
/* amimjf@connectfree.co.uk - www.amimjf.connectfree.co.uk            */
/* ------------------------------------------------------------------ */


#include <exec/types.h>
#include <exec/libraries.h>
#include <dos/dos.h>
#include <libraries/asl.h>
#include <clib/exec_protos.h>
#include <clib/asl_protos.h>
#include <clib/dos_protos.h>

#include "MyGuiTest.h"

#include <stdio.h>
#include <string.h>

#define MYLEFTEDGE 0
#define MYTOPEDGE  0
#define MYWIDTH    320
#define MYHEIGHT   400

struct Library *AslBase = NULL;

struct TagItem frtags[] =
{
    ASL_Hail,           (ULONG)"Pick an IFF sample",
    ASL_Height,         MYHEIGHT,
    ASL_Width,          MYWIDTH,
    ASL_LeftEdge,       MYLEFTEDGE,
    ASL_TopEdge,        MYTOPEDGE,
    ASL_OKText,         (ULONG)"Ok",
    ASL_CancelText,     (ULONG)"Cancel",
    ASL_Pattern,        (ULONG)"#?.iff",
    ASL_Dir,            (ULONG)"sys:",
    ASL_FuncFlags, FILF_PATGAD,/* | FILF_MULTISELECT, */
    TAG_DONE
};

STRPTR OpenASL(void)
{
    struct FileRequester *fr;
    char *buffer;

    /* -------------------------------- */
    /* check to see if we can get stuff */
    /* -------------------------------- */

    if (AslBase = OpenLibrary("asl.library", 37L))
    {
        if (fr = (struct FileRequester *)
            AllocAslRequest(ASL_FileRequest, frtags))
        {
            if (AslRequest(fr, NULL))
            {
                /* ------------------------------------- */
                /* we can presume now that it all worked */
                /* ------------------------------------- */

                strcpy(buffer,fr->rf_Dir); /* copy first bit to buffer */

                strcat(buffer,fr->rf_File); /* add second bit */

                return(buffer);
            }
            
        }
        /* else User Cancelled */
    }
    FreeAslRequest(fr);
    CloseLibrary(AslBase);

/* bye bye */
}
