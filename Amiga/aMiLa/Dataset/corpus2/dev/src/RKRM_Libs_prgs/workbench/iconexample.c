;/* iconexample.c - Execute me to compile me with SAS C 5.10
LC -b1 -cfistq -v -y -j73 iconexample.c
Blink FROM LIB:c.o,iconexample.o TO iconexample LIBRARY LIB:LC.lib,LIB:Amiga.lib
quit
*/
/*
Copyright (c) 1992 Commodore-Amiga, Inc.

This example is provided in electronic form by Commodore-Amiga, Inc. for
use with the "Amiga ROM Kernel Reference Manual: Libraries", 3rd Edition,
published by Addison-Wesley (ISBN 0-201-56774-1).

The "Amiga ROM Kernel Reference Manual: Libraries" contains additional
information on the correct usage of the techniques and operating system
functions presented in these examples.  The source and executable code
of these examples may only be distributed in free electronic form, via
bulletin board or as part of a fully non-commercial and freely
redistributable diskette.  Both the source and executable code (including
comments) must be included, without modification, in any copy.  This
example may not be published in printed form or distributed with any
commercial product.  However, the programming techniques and support
routines set forth in these examples may be used in the development
of original executable software products for Commodore Amiga computers.

All other rights reserved.

This example is provided "as-is" and is subject to change; no
warranties are made.  All use is at your own risk. No liability or
responsibility is assumed.
*/
/*
** iconexample.c - Workbench icon startup, creation, and parsing example
*/

#include <exec/types.h>
#include <libraries/dos.h>
#include <workbench/workbench.h>
#include <workbench/startup.h>

#include <clib/alib_protos.h>
#include <clib/exec_protos.h>
#include <clib/dos_protos.h>
#include <clib/icon_protos.h>
#include <stdlib.h>
#include <stdio.h>
#include <string.h>

#ifdef LATTICE
int CXBRK(void) { return(0); }   /* Disable SAS Lattice CTRL/C handling */
int chkabort(void) { return(0); }/* really */
#endif

/* our functions */
void cleanexit(UBYTE *,LONG);
void cleanup(void);
void message(UBYTE *);
BOOL makeIcon(UBYTE *, char **, char *);
BOOL showToolTypes(struct WBArg *);

UBYTE *projname     = "RAM:Example_Project";
UBYTE *conwinname   = "CON:10/10/620/180/iconexample";

UBYTE deftoolname[] = {"iconexample"};

USHORT IconImageData1[] =  {
/* Plane 0 */
    0x0000,0x0000,0x0000,0x1000,0x0000,0x0000,0x0000,0x3000,
    0x0FFF,0xFFFC,0x0000,0x3000,0x0800,0x0004,0x0000,0x3000,
    0x0800,0x07FF,0xFFC0,0x3000,0x08A8,0xA400,0x00A0,0x3000,
    0x0800,0x0400,0x0090,0x3000,0x08AA,0xA400,0x0088,0x3000,
    0x0800,0x042A,0xA0FC,0x3000,0x082A,0xA400,0x0002,0x3000,
    0x0800,0x0400,0x0002,0x3000,0x0800,0xA42A,0xA0A2,0x3000,
    0x0800,0x0400,0x0002,0x3000,0x0950,0xA42A,0x8AA2,0x3000,
    0x0800,0x0400,0x0002,0x3000,0x082A,0xA400,0x0002,0x3000,
    0x0800,0x042A,0x2AA2,0x3000,0x0FFF,0xFC00,0x0002,0x3000,
    0x0000,0x0400,0x0002,0x3000,0x0000,0x07FF,0xFFFE,0x3000,
    0x0000,0x0000,0x0000,0x3000,0x7FFF,0xFFFF,0xFFFF,0xF000,
/* Plane 1 */
    0xFFFF,0xFFFF,0xFFFF,0xE000,0xD555,0x5555,0x5555,0x4000,
    0xD000,0x0001,0x5555,0x4000,0xD7FF,0xFFF9,0x5555,0x4000,
    0xD7FF,0xF800,0x0015,0x4000,0xD757,0x5BFF,0xFF55,0x4000,
    0xD7FF,0xFBFF,0xFF65,0x4000,0xD755,0x5BFF,0xFF75,0x4000,
    0xD7FF,0xFBD5,0x5F01,0x4000,0xD7D5,0x5BFF,0xFFFD,0x4000,
    0xD7FF,0xFBFF,0xFFFD,0x4000,0xD7FF,0x5BD5,0x5F5D,0x4000,
    0xD7FF,0xFBFF,0xFFFD,0x4000,0xD6AF,0x5BD5,0x755D,0x4000,
    0xD7FF,0xFBFF,0xFFFD,0x4000,0xD7D5,0x5BFF,0xFFFD,0x4000,
    0xD7FF,0xFBD5,0xD55D,0x4000,0xD000,0x03FF,0xFFFD,0x4000,
    0xD555,0x53FF,0xFFFD,0x4000,0xD555,0x5000,0x0001,0x4000,
    0xD555,0x5555,0x5555,0x4000,0x8000,0x0000,0x0000,0x0000,
};

struct Image iconImage1 =
    {
    0, 0,                /* Top Corner */
    52, 22, 2,           /* Width, Height, Depth */
    &IconImageData1[0],  /* Image Data */
    0x003, 0x000,        /* PlanePick,PlaneOnOff */
    NULL                 /* Next Image */
    };

UBYTE *toolTypes[] =
    {
    "FILETYPE=text",
    "FLAGS=BOLD|ITALICS",
    NULL
    };

struct DiskObject projIcon =
    {
    WB_DISKMAGIC,                   /* Magic Number */
    WB_DISKVERSION,                 /* Version */
        {                           /* Embedded Gadget Structure */
        NULL,                       /* Next Gadget Pointer */
        97,12,52,23,                /* Left,Top,Width,Height */
        GADGIMAGE|GADGHBOX,         /* Flags */
        GADGIMMEDIATE|RELVERIFY,    /* Activation Flags */
        BOOLGADGET,                 /* Gadget Type */
        (APTR)&iconImage1,          /* Render Image */
        NULL,                       /* Select Image */
        NULL,                       /* Gadget Text */
        NULL,                       /* Mutual Exclude */
        NULL,                       /* Special Info */
        0,                          /* Gadget ID */
        NULL                        /* User Data */
        },
    WBPROJECT,                      /* Icon Type */
    deftoolname,                    /* Default Tool */
    toolTypes,                      /* Tool Type Array */
    NO_ICON_POSITION,               /* Current X */
    NO_ICON_POSITION,               /* Current Y */
    NULL,                           /* Drawer Structure */
    NULL,                           /* Tool Window */
    4000                            /* Stack Size */
    };

/* Opens and allocations we must clean up */
struct Library *IconBase = NULL;
FILE *conwin = NULL;
LONG olddir = -1;

BOOL FromWb;

void main(int argc, char **argv)
    {
    struct WBStartup *WBenchMsg;
    struct WBArg *wbarg;
    FILE  *file;
    LONG  wLen;
    SHORT i;

    FromWb = (argc==0) ? TRUE : FALSE;

    /* Open icon.library */
    if(!(IconBase = OpenLibrary("icon.library",33)))
         cleanexit("Can't open icon.library\n",RETURN_FAIL);

    /* If started from CLI, this example will create a small text
     * file RAM:Example_Project, and create an icon for the file
     * which points to this program as its default tool.
     */
    if(!FromWb)
        {
        /* Make a sample project (data) file */
        wLen = -1;
        if(file=fopen(projname,"w"))
            {
            wLen = fprintf(file,"Have a nice day\n");
            fclose(file);
            }
        if(wLen < 0) cleanexit("Error writing data file\n",RETURN_FAIL);

        /* Now save/update icon for this data file */
        if(makeIcon(projname, toolTypes, deftoolname))
             {
             printf("%s data file and icon saved.\n",projname);
             printf("Use Workbench menu Icon Information to examine the icon.\n");
             printf("Then copy this example (iconexample) to RAM:\n");
             printf("and double-click the %s project icon\n",projname);
             }
        else cleanexit("Error writing icon\n",RETURN_FAIL);
        }

    else  /* Else we are FromWb - ie. we were either
           * started by a tool icon, or as in this case,
           * by being the default tool of a project icon.
           */
        {
        if(!(conwin = fopen(conwinname,"r+")))
             cleanexit("Can't open output window\n",RETURN_FAIL);

        WBenchMsg = (struct WBStartup *)argv;

        /* Note wbarg++ at end of FOR statement steps through wbargs.
         * First arg is our executable (tool).  Any additional args
         * are projects/icons passed to us via either extend select
         * or default tool method.
         */
        for(i=0, wbarg=WBenchMsg->sm_ArgList;
            i < WBenchMsg->sm_NumArgs;
            i++, wbarg++)
            {
            /* if there's a directory lock for this wbarg, CD there */
            olddir = -1;
            if((wbarg->wa_Lock)&&(*wbarg->wa_Name))
                olddir = CurrentDir(wbarg->wa_Lock);

            showToolTypes(wbarg);

            if((i>0)&&(*wbarg->wa_Name))
                fprintf(conwin,"In Main. We could open the %s file here\n",
                                 wbarg->wa_Name);
            if(olddir != -1)  CurrentDir(olddir); /* CD back where we were */
            }
        Delay(500);
        }
    cleanup();
    exit(RETURN_OK);
    }

BOOL makeIcon(UBYTE *name, char **newtooltypes, char *newdeftool)
    {
    struct DiskObject *dobj;
    char *olddeftool;
    char **oldtooltypes;
    BOOL success = FALSE;

    if(dobj=GetDiskObject(name))
        {
        /* If file already has an icon, we will save off any fields we
         * need to update, update those fields, put the object, restore
         * the old field pointers and then free the object.  This will
         * preserve any custom imagery the user has, and the user's
         * current placement of the icon.  If your application does
         * not know where the user currently keeps your application,
         * you should not update his dobj->do_DefaultTool.
         */
         oldtooltypes = dobj->do_ToolTypes;
         olddeftool = dobj->do_DefaultTool;

         dobj->do_ToolTypes = newtooltypes;
         dobj->do_DefaultTool = newdeftool;

         success = PutDiskObject(name,dobj);

         /* we must restore the original pointers before freeing */
         dobj->do_ToolTypes = oldtooltypes;
         dobj->do_DefaultTool = olddeftool;
         FreeDiskObject(dobj);
         }
    /* Else, put our default icon */
    if(!success)  success = PutDiskObject(name,&projIcon);
    return(success);
    }

BOOL showToolTypes(struct WBArg *wbarg)
    {
    struct DiskObject *dobj;
    char **toolarray;
    char *s;
    BOOL success = FALSE;

    fprintf(conwin,"\nWBArg Lock=0x%lx, Name=%s\n",
                           wbarg->wa_Lock,wbarg->wa_Name);

    if((*wbarg->wa_Name) && (dobj=GetDiskObject(wbarg->wa_Name)))
        {
        fprintf(conwin,"  We have read the DiskObject (icon) for this arg\n");
        toolarray = (char **)dobj->do_ToolTypes;

        if(s=(char *)FindToolType(toolarray,"FILETYPE"))
            {
            fprintf(conwin,"    Found tooltype FILETYPE with value %s\n",s);
            }
        if(s=(char *)FindToolType(toolarray,"FLAGS"))
            {
            fprintf(conwin,"    Found tooltype FLAGS with value %s\n",s);
            if(MatchToolValue(s,"BOLD"))
                fprintf(conwin,"      BOLD flag requested\n");
            if(MatchToolValue(s,"ITALICS"))
                fprintf(conwin,"      ITALICS flag requested\n");
            }
        /* Free the diskobject we got */
        FreeDiskObject(dobj);
        success = TRUE;
        }
    else if(!(*wbarg->wa_Name))
        fprintf(conwin,"  Must be a disk or drawer icon\n");
    else
        fprintf(conwin,"  Can't find any DiskObject (icon) for this WBArg\n");
    return(success);
    }


/* Workbench-started programs with no output window may want to display
 * messages in a different manner (requester, window title, etc)
 */
void message(UBYTE *s)
    {
    if(FromWb && conwin)  fprintf(conwin,s,strlen(s));
    else if (!FromWb) printf(s);
    }

void cleanexit(UBYTE *s, LONG n)
    {
    if(*s)  message(s);
    cleanup();
    exit(n);
    }

void cleanup()
   {
   if(conwin)    fclose(conwin);
   if(IconBase)  CloseLibrary(IconBase);
   }
