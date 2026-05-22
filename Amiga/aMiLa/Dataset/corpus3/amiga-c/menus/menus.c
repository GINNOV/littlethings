/* Example showing the basic usage of the menu system with a window.
* Menu layout is done with GadTools, as is recommended for applications.
*/

#define INTUI_V36_NAMES_ONLY

#include <exec/types.h>
#include <intuition/intuition.h>
#include <intuition/intuitionbase.h>
#include <libraries/gadtools.h>

#include <clib/exec_protos.h>
#include <clib/gadtools_protos.h>
#include <clib/intuition_protos.h>

#include <stdio.h>

#ifdef LATTICE
int CXBRK(void)    { return(0); }  /* Disable Lattice CTRL/C handling */
int chkabort(void) { return(0); }  /* really */
#endif

struct Library *GadToolsBase;
struct IntuitionBase *IntuitionBase;

struct NewMenu mynewmenu[] =
        {
                { NM_TITLE, "Project",    0 , 0, 0, 0,},
                {  NM_ITEM, "Open...",   "O", 0, 0, 0,},
                {  NM_ITEM, "Save",      "S", 0, 0, 0,},
                {  NM_ITEM, NM_BARLABEL,  0 , 0, 0, 0,},
                {  NM_ITEM, "Print",      0 , 0, 0, 0,},
                {   NM_SUB, "Draft",      0 , 0, 0, 0,},
                {   NM_SUB, "NLQ",        0 , 0, 0, 0,},
                {  NM_ITEM, NM_BARLABEL,  0 , 0, 0, 0,},
                {  NM_ITEM, "Quit...",   "Q", 0, 0, 0,},

                { NM_TITLE, "Edit",       0 , 0, 0, 0,},
                {  NM_ITEM, "Cut",       "X", 0, 0, 0,},
                {  NM_ITEM, "Copy",      "C", 0, 0, 0,},
                {  NM_ITEM, "Paste",     "V", 0, 0, 0,},
                {  NM_ITEM, NM_BARLABEL,  0 , 0, 0, 0,},
                {  NM_ITEM, "Undo",      "Z", 0, 0, 0,},

                {   NM_END, NULL,         0 , 0, 0, 0,},
        };


/*
** Watch the menus and wait for the user to select the close gadget
** or quit from the menus.
*/
VOID handle_window_events(struct Window *win, struct Menu *menuStrip)
{
    struct IntuiMessage *msg;
    SHORT done;
    UWORD menuNumber;
    UWORD menuNum;
    UWORD itemNum;
    UWORD subNum;
    struct MenuItem *item;

    done = FALSE;
    while (FALSE == done)
    {
        /* we only have one signal bit, so we do not have to check which
        ** bit broke the Wait().
        */
        Wait(1L << win->UserPort->mp_SigBit);

        while ( (FALSE == done) &&
                (NULL != (msg = (struct IntuiMessage *)GetMsg(win->UserPort))))
        {
            switch (msg->Class)
            {
                case IDCMP_CLOSEWINDOW:
                    done = TRUE;
                    break;
                case IDCMP_MENUPICK:
                    menuNumber = msg->Code;
                    while ((menuNumber != MENUNULL) && (!done))
                    {
                        item = ItemAddress(menuStrip, menuNumber);

                        /* process the item here! */
                        menuNum = MENUNUM(menuNumber);
                        itemNum = ITEMNUM(menuNumber);
                        subNum  = SUBNUM(menuNumber);

                        /* stop if quit is selected. */
                        if ((menuNum == 0) && (itemNum == 5))
                            done = TRUE;

                        menuNumber = item->NextSelect;
                    }
                    break;
            }
            ReplyMsg((struct Message *)msg);
        }
    }
}


/*
** Open all of the required libraries and set-up the menus.
*/
VOID main(int argc, char *argv[])
{
    struct Window *win;
    APTR *my_VisualInfo;
    struct Menu *menuStrip;

/* Open the Intuition Library */
    IntuitionBase = (struct IntuitionBase *)OpenLibrary("intuition.library", 37);
    if (IntuitionBase != NULL)
    {
        /* Open the gadtools Library */
        GadToolsBase = OpenLibrary("gadtools.library", 37);
        if (GadToolsBase != NULL)
        {
            if (NULL != (win = OpenWindowTags(NULL,
                                              WA_Width,  400,       WA_Activate,    TRUE,
                                              WA_Height, 100,       WA_CloseGadget, TRUE,
                                              WA_Title,  "Menu Test Window",
                                              WA_IDCMP,  IDCMP_CLOSEWINDOW | IDCMP_MENUPICK,
                                              TAG_END)))
            {
                if (NULL != (my_VisualInfo = GetVisualInfo(win->WScreen, TAG_END)))
                {
                    if (NULL != (menuStrip = CreateMenus(mynewmenu, TAG_END)))
                    {
                        if (LayoutMenus(menuStrip, my_VisualInfo, TAG_END))
                        {
                            if (SetMenuStrip(win, menuStrip))
                            {
                                handle_window_events(win,menuStrip);

                                ClearMenuStrip(win);
                            }
                            FreeMenus(menuStrip);
                        }
                    }
                    FreeVisualInfo(my_VisualInfo);
                }
                CloseWindow(win);
            }
            CloseLibrary((struct Library *)GadToolsBase);
        }
        CloseLibrary((struct Library *)IntuitionBase);
    }
}

