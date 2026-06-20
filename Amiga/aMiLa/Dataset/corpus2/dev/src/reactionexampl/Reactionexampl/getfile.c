// getfile.c
// Public Domain by Matthias Rustler
// Use at your own risk

// Shows the use of a ReAction Getfile gadget
// The gadged doesn't open the filerequester itself,
// so we must open it with a method call in the message loop

#include <stdio.h>
#include <stdlib.h>

#define  ALL_REACTION_CLASSES
#define  ALL_REACTION_MACROS

#include <reaction/reaction.h>
#include <intuition/classusr.h>
#include <proto/exec.h>
#include <proto/intuition.h>
#include <clib/alib_protos.h>

char * vers="\0$VER: Getfile 0.2 (26.9.2)";

struct IntuitionBase *IntuitionBase;
struct Library *GfxBase;
struct Library *WindowBase;
struct Library *LayoutBase;
struct Library *StringBase;
struct Library *GetFileBase;

BOOL alllibrariesopen = FALSE;
Object *window, *layout, *filereq, *string;

#define GID_FILEREQ (1)

void cleanexit(char *str);

int main(void)
{
    char *str;
    struct Window *intuiwin=NULL;
    ULONG windowsignal,receivedsignal,result,code;
    BOOL end;

    if ( ! (IntuitionBase= (struct IntuitionBase*)OpenLibrary("intuition.library",39)))
        cleanexit("Can't open intuition.library");

    if ( ! (WindowBase= OpenLibrary("window.class",44)))
        cleanexit("Can't open window.class");

    if ( ! (LayoutBase= OpenLibrary("gadgets/layout.gadget",44)))
        cleanexit("Can't open layout.gadget");

    if ( ! (StringBase= OpenLibrary("gadgets/string.gadget",44)))
        cleanexit("Can't open string.gadget");

    if ( ! (GetFileBase= OpenLibrary("gadgets/getfile.gadget",44)))
        cleanexit("Can't open getfile.gadget");

    alllibrariesopen = TRUE;   // added 2002-09-25

    window = WindowObject,
        WINDOW_Position, WPOS_CENTERSCREEN,
        WA_Activate, TRUE,
        WA_Title, "Getfile.gadget demo",
        WA_DragBar, TRUE,
        WA_CloseGadget, TRUE,
        WA_DepthGadget, TRUE,
        WA_SizeGadget, TRUE,
        WA_IDCMP, IDCMP_CLOSEWINDOW|IDCMP_GADGETUP,
        WINDOW_Layout, VLayoutObject,
            LAYOUT_DeferLayout, TRUE,
            LAYOUT_SpaceInner, TRUE,
            LAYOUT_SpaceOuter, TRUE,
            LAYOUT_AddChild, filereq = GetFileObject,
                GETFILE_TitleText , "GetFile.gadget Demo" ,
                GETFILE_DoPatterns , TRUE ,
                GETFILE_ReadOnly, TRUE, //added 2002-09-25
                GA_ID , GID_FILEREQ ,
                GA_RelVerify , TRUE , // to get a message
            End,
            LAYOUT_AddChild, string = StringObject,
                STRINGA_MinVisible , 30 ,
            StringEnd,
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
                       case GID_FILEREQ:
                            // Now we open the requester
                            // The window parameter is important
                            if (DoMethod(filereq , GFILE_REQUEST , intuiwin))
                            {
                                GetAttr(GETFILE_FullFile , filereq ,(ULONG*)&str);
                            }
                            else
                            {
                                str="Filerequester canceled";
                            }
                            // str can be an automatic variable, because the string gadget copies
                            // the string into its buffer
                            SetGadgetAttrs( (struct Gadget *)string , intuiwin, NULL,
                                             STRINGA_TextVal , str , TAG_END);
                            break;
                    }
                    break;
            }
        }
    }
    DoMethod(window,WM_CLOSE);
    cleanexit(NULL);
}

void cleanexit(char *str)
{
    if (str) printf("Error: %s\n",str);

    if (alllibrariesopen)
    {
        DisposeObject(window);
    }

    CloseLibrary((struct Library*)IntuitionBase);
    CloseLibrary(WindowBase);
    CloseLibrary(LayoutBase);
    CloseLibrary(GetFileBase);   // added 2002-09-25
    CloseLibrary(StringBase);

    exit(0);
}

