// listbrowser.c
// Public Domain by Matthias Rustler
// Use at your own risk

// A simple ReAction Listbrowser gadget

#include <stdio.h>
#include <stdlib.h>

#define  ALL_REACTION_CLASSES
#define  ALL_REACTION_MACROS

#include <reaction/reaction.h>
#include <intuition/classusr.h>
#include <proto/exec.h>
#include <proto/intuition.h>
#include <clib/alib_protos.h>

char * vers="\0$VER: Listbrowser 0.1 (2.3.2003)";

struct IntuitionBase *IntuitionBase;
struct Library *WindowBase;
struct Library *LayoutBase;
struct Library *ListBrowserBase;

BOOL alllibrariesopen = FALSE;
Object *window, *layout, *listbrowser;
struct List browsernodes;

#define GID_LIST (1)

void cleanexit(char *str);
void additem(char * newstr, int fgpen);
void free_list(struct List *list);

int main(void)
{
    char *str;
    struct Window *intuiwin=NULL;
    ULONG windowsignal,receivedsignal,result,code,retval;
    BOOL end;

    if ( ! (IntuitionBase= (struct IntuitionBase*)OpenLibrary("intuition.library",39)))
        cleanexit("Can't open intuition.library");

    if ( ! (WindowBase= OpenLibrary("window.class",44)))
        cleanexit("Can't open window.class");

    if ( ! (LayoutBase= OpenLibrary("gadgets/layout.gadget",44)))
        cleanexit("Can't open layout.gadget");

    if ( ! (ListBrowserBase= OpenLibrary("gadgets/listbrowser.gadget",44)))
        cleanexit("Can't open getfile.gadget");

    alllibrariesopen = TRUE;

    NewList(&browsernodes);

    additem("ReAction",1);
    additem("Listbrowser",2);
    additem("Example",3);

    window = WindowObject,
        WINDOW_Position, WPOS_CENTERSCREEN,
        WA_Activate, TRUE,
        WA_Title, "ListBrowser.gadget demo",
        WA_DragBar, TRUE,
        WA_CloseGadget, TRUE,
        WA_DepthGadget, TRUE,
        WA_SizeGadget, TRUE,
        WA_IDCMP, IDCMP_CLOSEWINDOW|IDCMP_GADGETUP,
        WINDOW_Layout, VLayoutObject,
            LAYOUT_DeferLayout, TRUE,
            LAYOUT_SpaceInner, TRUE,
            LAYOUT_SpaceOuter, TRUE,
            LAYOUT_AddChild, listbrowser = ListBrowserObject,
                GA_ID,GID_LIST,
                LISTBROWSER_Labels, &browsernodes,
                GA_RelVerify , TRUE , // to get a message
                LISTBROWSER_ShowSelected, TRUE,
            End,
        LayoutEnd,
    WindowEnd;

    if ( ! (window))
        cleanexit("Can't create window");

    if ( ! (intuiwin = (struct Window *) DoMethod(window,WM_OPEN)))
        cleanexit("Can't open window");

    GetAttr(WINDOW_SigMask,window,&windowsignal);

    end = FALSE;

    while (!end)
    {
        receivedsignal = Wait(windowsignal);
        while ((result = DoMethod(window,WM_HANDLEINPUT,&code)) != WMHI_LASTMSG)
        {
            switch (result & WMHI_CLASSMASK)
            {
                
                case WMHI_CLOSEWINDOW:
                    end=TRUE;
                    break;
                case WMHI_GADGETUP:
                    switch (result & WMHI_GADGETMASK)
                    {
                       case GID_LIST:
                            GetAttr(LISTBROWSER_Selected,listbrowser,&retval);
                            printf("Entry %d clicked\n",retval);
                            break;
                    }
                    break;
            }
        }
    }
    DoMethod(window,WM_CLOSE);
    cleanexit(NULL);
}

void additem(char * newstr, int fgpen)
{
    struct Node *node;
    if (node = AllocListBrowserNode(1,
        LBNA_Flags, LBFLG_CUSTOMPENS,
        LBNCA_Justification, LCJ_LEFT,
        LBNCA_CopyText, TRUE,
        LBNCA_FGPen, fgpen,
        LBNCA_Text, newstr,
        TAG_DONE))
    {
        AddTail(&browsernodes, node);
    }
    else
    {
        cleanexit("Couldn't create Node");
    }
}

void free_list(struct List *list)
{
    struct Node *node, *nextnode;

    node = list->lh_Head;
    while (nextnode = node->ln_Succ)
    {
        FreeListBrowserNode(node);
        puts("Node freed");
        node = nextnode;
    }
    NewList(list);
}


void cleanexit(char *str)
{
    if (str) printf("Error: %s\n",str);

    if (alllibrariesopen)
    {
        DisposeObject(window);
        free_list(&browsernodes);
    }

    CloseLibrary((struct Library*)IntuitionBase);
    CloseLibrary(WindowBase);
    CloseLibrary(LayoutBase);
    CloseLibrary(ListBrowserBase);

    exit(0);
}

