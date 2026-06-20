;/* clonescreen.c - clone an existing public screen.
lc -b1 -cfist -v -y -j73 clonescreen
blink FROM LIB:c.o clonescreen.o TO clonescreen LIB LIB:lc.lib LIB:amiga.lib
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

#define INTUI_V36_NAMES_ONLY

#include <exec/types.h>
#include <exec/memory.h>
#include <intuition/intuition.h>
#include <intuition/screens.h>

#include <clib/exec_protos.h>
#include <clib/dos_protos.h>
#include <clib/graphics_protos.h>
#include <clib/intuition_protos.h>

#include <string.h>

#ifdef LATTICE
int CXBRK(void)    { return(0); }  /* Disable Lattice CTRL/C handling */
int chkabort(void) { return(0); }  /* really */
#endif

VOID cloneScreen( UBYTE * );

struct Library *IntuitionBase;
struct GfxBase *GfxBase;

/*
** Open all libraries for the cloneScreen() subroutine.
*/
VOID main(int argc, char **argv)
{
UBYTE *pub_screen_name = "Workbench";

IntuitionBase = OpenLibrary("intuition.library",0);
if (IntuitionBase != NULL)
    {
    /* Require version 37 of Intuition. */
    if (IntuitionBase->lib_Version >= 37)
        {
        /* Note the two methods of getting the library version
        ** that you really want.
        */
        GfxBase = (struct GfxBase *)OpenLibrary("graphics.library",37);
        if (GfxBase != NULL)
            {
            cloneScreen(pub_screen_name);

            CloseLibrary((struct Library *)GfxBase);
            }
        }
    CloseLibrary(IntuitionBase);
    }
}

/* Clone a public screen whose name is passed to the routine.
**    Width, Height, Depth, Pens, Font and DisplayID attributes are
** all copied from the screen.
**    Overscan is assumed to be OSCAN_TEXT, as there is no easy way to
** find the overscan type of an existing screen.
**    AutoScroll is turned on, as it does not hurt.  Screens that are
** smaller than the display clip will not scroll.
*/

VOID cloneScreen(UBYTE *pub_screen_name)
{
struct Screen *my_screen;
ULONG  screen_modeID;
UBYTE *pub_scr_font_name;
UBYTE *font_name;
ULONG  font_name_size;
struct TextAttr pub_screen_font;
struct TextFont *opened_font;

struct Screen   *pub_screen = NULL;
struct DrawInfo *screen_drawinfo = NULL;

/* name is a (UBYTE *) pointer to the name of the public screen to clone */
pub_screen = LockPubScreen(pub_screen_name);
if (pub_screen != NULL)
    {
    /* Get the DrawInfo structure from the locked screen
    ** This returns pen, depth and font info.
    */
    screen_drawinfo = GetScreenDrawInfo(pub_screen);
    if (screen_drawinfo != NULL)
        {
        screen_modeID = GetVPModeID(&(pub_screen->ViewPort));
        if( screen_modeID != INVALID_ID )
            {
            /* Get a copy of the font
            ** The name of the font must be copied as the public screen may
            ** go away at any time after we unlock it.
            ** Allocate enough memory to copy the font name, create a
            ** TextAttr that matches the font, and open the font.
            */
            pub_scr_font_name = screen_drawinfo->dri_Font->tf_Message.mn_Node.ln_Name;
            font_name_size = 1 + strlen(pub_scr_font_name);
            font_name = AllocMem(font_name_size, MEMF_CLEAR);
            if (font_name != NULL)
                {
                strcpy(font_name, pub_scr_font_name);
                pub_screen_font.ta_Name  = font_name;
                pub_screen_font.ta_YSize = screen_drawinfo->dri_Font->tf_YSize;
                pub_screen_font.ta_Style = screen_drawinfo->dri_Font->tf_Style;
                pub_screen_font.ta_Flags = screen_drawinfo->dri_Font->tf_Flags;

                opened_font = OpenFont(&pub_screen_font);
                if (opened_font != NULL)
                    {
                    /* screen_modeID may now be used in a call to
                    ** OpenScreenTagList() with the tag SA_DisplayID.
                    */
                    my_screen = OpenScreenTags(NULL,
                        SA_Width,      pub_screen->Width,
                        SA_Height,     pub_screen->Height,
                        SA_Depth,      screen_drawinfo->dri_Depth,
                        SA_Overscan,   OSCAN_TEXT,
                        SA_AutoScroll, TRUE,
                        SA_Pens,       (ULONG)(screen_drawinfo->dri_Pens),
                        SA_Font,       (ULONG)&pub_screen_font,
                        SA_DisplayID,  screen_modeID,
                        SA_Title,      "Cloned Screen",
                        TAG_END);
                    if (my_screen != NULL)
                        {
                        /* Free the drawinfo and public screen as we don't
                        ** need them any more.  We now have our own screen.
                        */
                        FreeScreenDrawInfo(pub_screen,screen_drawinfo);
                        screen_drawinfo = NULL;
                        UnlockPubScreen(pub_screen_name,pub_screen);
                        pub_screen = NULL;

                        Delay(300);   /* should be rest_of_program */

                        CloseScreen(my_screen);
                        }
                    CloseFont(opened_font);
                    }
                FreeMem(font_name, font_name_size);
                }
            }
        }
    }

/* These are freed in the main loop if OpenScreenTagList() does
** not fail.  If something goes wrong, free them here.
*/
if (screen_drawinfo != NULL )
    FreeScreenDrawInfo(pub_screen,screen_drawinfo);
if (pub_screen != NULL )
    UnlockPubScreen(pub_screen_name,pub_screen);
}
