//
//  To compile:
//  gcc -o RadioEnquire RadioEnquire.c -lraauto -lauto
//
//  To make the compiled code smaller:
//  strip RadioEnquire
//

#include <exec/exec.h>
#include <intuition/intuition.h>
#include <dos/dos.h>
#include <expansion/expansion.h>

#include <classes/window.h>

#include <gadgets/layout.h>
#include <gadgets/radiobutton.h>

#include <proto/exec.h>
#include <proto/intuition.h>
#include <proto/expansion.h>

#include <proto/window.h>
#include <proto/layout.h>
#include <proto/radiobutton.h>
#include <proto/space.h>

#include <reaction/reaction_macros.h>


Object *win;

struct MsgPort *AppPort;
struct Library *ExpansionBase = NULL;
struct ExpansionIFace *IExpansion = NULL;

char computer[30];
char Imemory[30];
char extensions[30];

enum
{
    OBJ_RADIO,
    OBJ_OUTPUT,
    OBJ_QUIT,
    OBJ_NUM
};

Object *Objects[OBJ_NUM];
#define OBJ(x) Objects[x]
#define GAD(x) (struct Gadget *)Objects[x]

STRPTR radio[] =
{
    " Computer"," Installed Memory"," Extensions",NULL
};

#define SPACE LAYOUT_AddChild, SpaceObject, End

void GetComputerInfo(struct Window *);
BOOL startup(void);
void shutdown(void);


Object *
make_window(void)
{
    return WindowObject,
        WA_ScreenTitle,        "Reaction Example",
        WA_Title,              "Radio",
        WA_DragBar,            TRUE,
        WA_CloseGadget,        TRUE,
        WA_SizeGadget,         TRUE,
        WA_DepthGadget,        TRUE,
        WA_Activate,           TRUE,
        WINDOW_IconifyGadget,  TRUE,
        WINDOW_IconTitle,      "Iconified",
        WINDOW_AppPort,        AppPort,
        WINDOW_Position,       WPOS_CENTERSCREEN,
        WINDOW_Layout,         VLayoutObject,
            LAYOUT_SpaceOuter, TRUE,
            LAYOUT_AddChild,   HLayoutObject,
                SPACE,
                LAYOUT_AddChild,   VLayoutObject,
                    LAYOUT_SpaceOuter,  TRUE,
                    LAYOUT_BevelStyle,  BVS_GROUP,
                    LAYOUT_Label,       " System Info ",

                    LAYOUT_AddChild,    OBJ(OBJ_RADIO) = RadioButtonObject,
                        GA_ID,          OBJ_RADIO,
                        GA_Text,        radio,
                        GA_RelVerify,   TRUE,
                    End,  // Radio

                End,  // VLayout
                SPACE,
            End,  // HLayout
            SPACE,

            LAYOUT_AddChild,    OBJ(OBJ_OUTPUT) = ButtonObject,
                GA_ID,          OBJ_OUTPUT,
                GA_ReadOnly,    TRUE,
            End, // Button
            CHILD_WeightedHeight,   0,

            LAYOUT_AddChild,    Button("_Quit",OBJ_QUIT),
            CHILD_WeightedHeight,   0,

        End,  // VLayout
    End;  // WindowObject
}


int main()
{
    struct Window *window;

    if (startup() == FALSE)
    {
        printf("Failed to open a library\n");
        shutdown();
        return(10);
    }
    if (AppPort = IExec->CreateMsgPort())
    {
        win = make_window();
        if (window = RA_OpenWindow(win))
        {
            uint32
                sigmask     = 0,
                siggot      = 0,
                result      = 0;
            uint16
                code        = 0;
            BOOL
                done        = FALSE;

            GetComputerInfo(window);
            IIntuition->GetAttr(WINDOW_SigMask, win, &sigmask);
            while (!done)
            {
                siggot = IExec->Wait(sigmask | SIGBREAKF_CTRL_C);
                if (siggot & SIGBREAKF_CTRL_C) done = TRUE;
                while ((result = RA_HandleInput(win, &code)))
                {
                    switch(result & WMHI_CLASSMASK)
                    {
                        case WMHI_CLOSEWINDOW:
                            done = TRUE;
                            break;
                        case WMHI_GADGETUP:
                            switch (result & WMHI_GADGETMASK)
                            {
                                case OBJ_QUIT:
                                    done=TRUE;
                                    break;
                                case OBJ_RADIO:
                                    switch(code)
                                    {
                                        case 0:
                                            IIntuition->SetGadgetAttrs( GAD(OBJ_OUTPUT), window, NULL,
                                                GA_Text, computer, TAG_END);
                                            break;
                                        case 1:
                                            IIntuition->SetGadgetAttrs( GAD(OBJ_OUTPUT), window, NULL,
                                                GA_Text, Imemory, TAG_END);
                                            break;
                                        case 2:
                                            IIntuition->SetGadgetAttrs( GAD(OBJ_OUTPUT), window, NULL,
                                                GA_Text, extensions, TAG_END);
                                            break;
                                    }
                                    break;
                            }
                            break;
                        case WMHI_ICONIFY:
                            if (RA_Iconify(win)) window = NULL;
                            break;
                        case WMHI_UNICONIFY:
                            window = RA_OpenWindow(win);
                            break;
                    }
                }
            }
        }
        IIntuition->DisposeObject(win);
        IExec->DeleteMsgPort(AppPort);
    }
    shutdown();
}


void GetComputerInfo(struct Window *window)
{
    STRPTR machine;
    STRPTR extras;
    uint32 InstalledMem;

    IExpansion->GetMachineInfoTags(GMIT_MachineString, &machine,
                                   GMIT_MemorySize, &InstalledMem,
                                   GMIT_Extensions, &extras,
                                        TAG_END);
    strcpy(computer, machine);
    strcpy(extensions, extras);
    sprintf(Imemory, "%d", InstalledMem);

    IIntuition->SetGadgetAttrs( GAD(OBJ_OUTPUT), window, NULL,
                                GA_Text, computer, TAG_END);
}


BOOL startup(void)
{
    BOOL retval = FALSE;

    if (ExpansionBase = IExec->OpenLibrary( "expansion.library", 0 ))
    {
        if (IExpansion = (struct ExpansionIFace *) IExec->GetInterface( ExpansionBase, "main", 1, NULL ))
        {
            retval = TRUE;
        }
     }
    return(retval);
}


void shutdown(void)
{
    if (IExpansion) IExec->DropInterface( (struct Interface *) IExpansion );
    if (ExpansionBase) IExec->CloseLibrary( ExpansionBase );
}


