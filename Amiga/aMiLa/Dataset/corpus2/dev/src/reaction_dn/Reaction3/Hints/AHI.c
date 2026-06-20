//
//  To compile:
//  gcc -o AHI AHI.c -lraauto -lauto
//
//  To make the compiled code smaller:
//  strip AHI
//

#include <exec/exec.h>
#include <intuition/intuition.h>
#include <dos/dos.h>
#include <libraries/gadtools.h>

#include <classes/window.h>

#include <images/label.h>
#include <images/bitmap.h>

#include <gadgets/space.h>
#include <gadgets/listbrowser.h>
#include <gadgets/slider.h>
#include <gadgets/string.h>
#include <gadgets/layout.h>
#include <gadgets/chooser.h>
#include <gadgets/clicktab.h>

#include <proto/exec.h>
#include <proto/intuition.h>
#include <proto/utility.h>
#include <proto/icon.h>

#include <proto/space.h>
#include <proto/listbrowser.h>
#include <proto/slider.h>
#include <proto/string.h>
#include <proto/window.h>
#include <proto/layout.h>
#include <proto/chooser.h>
#include <proto/space.h>
#include <proto/clicktab.h>
#include <proto/label.h>
#include <proto/bitmap.h>

#include <reaction/reaction_macros.h>


Object *win;
struct Screen *scr;
struct MsgPort *AppPort;
struct List drivermode_list;
struct Hook slider_hook;
char textstr[10];

enum
{
    OBJ_MUSIC_UNIT = 1,
    OBJ_PLAY,

    // *** page 1 ***

    OBJ_DRIVERBROWSER,
    OBJ_PIC,

    // *** page 2 ***

    OBJ_CHANNEL_SLIDER,
    OBJ_VOLUME_SLIDER,
    OBJ_FREQUENCY,
    OBJ_INPUT,
    OBJ_OUTPUT,
    OBJ_MONITOR_SLIDER,
    OBJ_GAIN_SLIDER,

    // *** page 3 ***

    OBJ_DEBUG_LEVEL,
    OBJ_ECHO,
    OBJ_SURROUND,
    OBJ_MASTER_VOL,
    OBJ_CPU_SLIDER,
    OBJ_ANTI_CLICK_SLIDER,
    OBJ_VOL_SCALING,

    // *** others ***

    OBJ_SAVE,
    OBJ_USE,
    OBJ_CANCEL,
    OBJ_NUM
};

Object *Objects[OBJ_NUM];
#define OBJ(x) Objects[x]
#define GAD(x) (struct Gadget *)Objects[x]

#define SPACE LAYOUT_AddChild, SpaceObject, End

struct HintInfo helpstrs[] =
{
    {OBJ_MUSIC_UNIT,-1,"Select unit",0},
    {OBJ_PLAY,-1,"Play a test sound",0},

    {OBJ_DRIVERBROWSER,-1,"Driver modes",0},

    {OBJ_CHANNEL_SLIDER,-1,"Select number of \n channels to use",0},
    {OBJ_VOLUME_SLIDER,-1,"Volume",0},
    {OBJ_FREQUENCY,-1,"Frequency",0},
    {OBJ_INPUT,-1,"Select input",0},
    {OBJ_OUTPUT,-1,"Select output",0},
    {OBJ_MONITOR_SLIDER,-1,"Monitor",0},
    {OBJ_GAIN_SLIDER,-1,"Gain",0},

    {OBJ_DEBUG_LEVEL,-1,"Set the level of debug output",0},
    {OBJ_ECHO,-1,"Set echo on or off",0},
    {OBJ_SURROUND,-1,"Set on or off",0},
    {OBJ_MASTER_VOL,-1,"Set volume with or without clipping",0},
    {OBJ_CPU_SLIDER,-1,"Allowed max use of CPU",0},
    {OBJ_ANTI_CLICK_SLIDER,-1,"Anti-click time",0},
    {OBJ_VOL_SCALING,-1,"Volume Scaling",0},
    {-1,-1,0,0}
};

STRPTR music_unit[] =
{
    "Music unit", "Unit 0", "Unit 1", "Unit 2", "Unit 3", NULL
};

STRPTR PageLabels[] = {"Driver Mode", "Settings", "Advanced Settings", NULL};


// *** page 1 ***

STRPTR list_strings[] =
{
    "EMU10kx: 16 bit mono",
    "EMU10kx: 16 bit stereo++",
    "EMU10kx: HiFi 16 bit 7.1 multichannel",
    "EMU10kx: HiFi 16 bit mono",
    "EMU10kx: HiFi 16 bit stereo++",
    NULL
};


// *** page 2 ***

STRPTR frequency[] =
{
    "8000 Hz", "11025 Hz", "16000 Hz", "22050 Hz",
    "24000 Hz", "32000 Hz", "44100 Hz", "48000 Hz", NULL
};

STRPTR input[] =
{
    "Mixer", "Line in", "Mic", "CD", "Aux", "Phone", "Video", "Mixer (mono)", NULL
};

STRPTR output[] = {"Front", "   Front and Rear   ", NULL};


// *** page 3 ***

STRPTR debug_level[] = {"None", "Low", "High", "Full", NULL};

STRPTR en_disable[] = {"Enabled", "Disabled", NULL};

STRPTR master_vol[] = {"With clipping", "Without clipping", NULL};

STRPTR vol_scaling[] = {"Safe", "Safe, dynamic", "Full volume", "-3 dB", "-6 dB", NULL};


// *** prototypes ***

BOOL make_browserlist(struct List *, char **);
VOID free_browserlist(struct List *);
STRPTR HookFunc(struct Hook *,Object *, struct TagItem *);



Object *
make_window(void)
{
    Object  *page1 = NULL,
            *page2 = NULL,
            *page3 = NULL;


    page1 = VLayoutObject,

        LAYOUT_AddChild,     HLayoutObject,

        LAYOUT_AddChild, OBJ(OBJ_DRIVERBROWSER) = ListBrowserObject,
            GA_ID,                     OBJ_DRIVERBROWSER,
            GA_RelVerify,              TRUE,
            LISTBROWSER_Labels,        &drivermode_list,
            LISTBROWSER_ShowSelected,  TRUE,
        End,  // ListBrowser

        LAYOUT_AddImage,  LabelObject,
            LABEL_DisposeImage, TRUE,
            LABEL_Image,        BitMapObject,
                BITMAP_SourceFile, "AHI.gif",
                BITMAP_Screen,     scr,
            BitMapEnd,
        End,  // Label

        End,   // HLayout

        LAYOUT_AddChild,     HLayoutObject,
            LAYOUT_BevelStyle,      BVS_FIELD,
            GA_BackFill,            NULL,

            LAYOUT_AddImage, LabelObject,
                LABEL_Text,  " Mode ID\n",
                LABEL_Text,  " Recording\n",
                LABEL_Text,  " Author\n",
                LABEL_Text,  " Copyright\n",
                LABEL_Text,  " Driver\n",
                LABEL_Text,  " Version\n",
                LABEL_Text,  " Annotation",
            End,  // Label

            LAYOUT_AddImage, LabelObject,
                LABEL_Text,  " 0x001e0001\n",
                LABEL_Text,  " Full duplex\n",
                LABEL_Text,  " Martin `Leviticus` Blom, Bertrand Lee et al.\n",
                LABEL_Text,  " GNU GPL\n",
                LABEL_Text,  " Devs:AHI/emu10kx.audio\n",
                LABEL_Text,  " emu10kx.audio 5.19 OS4 (08-Sept-2004)\n",
                LABEL_Text,  " Funded by Hyperion Entertainment, Based on the Linux driver.",
            End,  // Label

            SPACE,

        End,   // HLayout
        CHILD_WeightedHeight,   0,
    End;  // VLayout


    page2 = VLayoutObject,
        LAYOUT_VertAlignment,  LALIGN_CENTRE,
        LAYOUT_SpaceOuter,     TRUE,
        LAYOUT_AddChild, HLayoutObject,
            LAYOUT_HorizAlignment,  LALIGN_CENTRE,
            LAYOUT_SpaceOuter,     TRUE,
            LAYOUT_AddChild,       VLayoutObject,
                LAYOUT_BevelStyle,  BVS_GROUP,
                LAYOUT_Label,       " Options ",

                LAYOUT_AddChild,       OBJ(OBJ_FREQUENCY) = ChooserObject,
                    GA_ID,               OBJ_FREQUENCY,
                    GA_RelVerify,        TRUE,
                    CHOOSER_LabelArray,  frequency,
                    CHOOSER_Selected,    6,
                End,  // Chooser
                Label(" _Frequency: "),

                LAYOUT_AddChild,     OBJ(OBJ_CHANNEL_SLIDER) = SliderObject,
                    GA_ID,               OBJ_CHANNEL_SLIDER,
                    SLIDER_Min,          1,
                    SLIDER_Max,          32,
                    SLIDER_Level,        20,
                    SLIDER_Orientation,  SLIDER_HORIZONTAL,
                    SLIDER_LevelPlace,   PLACETEXT_LEFT,
                    SLIDER_LevelMaxLen,  8,
                    SLIDER_LevelJustify, SLJ_CENTER,
                    SLIDER_LevelFormat,  "%ld",
                    SLIDER_Ticks,        15,
                    SLIDER_ShortTicks,   TRUE,
                End,  // Slider
                Label("C_hannels: "),

                LAYOUT_AddChild,     OBJ(OBJ_VOLUME_SLIDER) = SliderObject,
                    GA_ID,               OBJ_VOLUME_SLIDER,
                    SLIDER_Min,          -194,
                    SLIDER_Max,          24,
                    SLIDER_Level,        0,
                    SLIDER_LevelPlace,   PLACETEXT_LEFT,
                    SLIDER_LevelMaxLen,  8,
                    SLIDER_LevelJustify, SLJ_CENTER,
                    SLIDER_LevelFormat,  "%s",
                    SLIDER_Orientation,  SLIDER_HORIZONTAL,
                    SLIDER_Ticks,        15,
                    SLIDER_ShortTicks,   TRUE,
                    SLIDER_LevelHook,    &slider_hook,
                End,  // Slider
                Label("Volume: "),

                LAYOUT_AddChild,     OBJ(OBJ_MONITOR_SLIDER) = SliderObject,
                    GA_ID,               OBJ_MONITOR_SLIDER,
                    SLIDER_Min,          -194,
                    SLIDER_Max,          24,
                    SLIDER_Level,        -52,
                    SLIDER_LevelPlace,   PLACETEXT_LEFT,
                    SLIDER_LevelMaxLen,  8,
                    SLIDER_LevelJustify, SLJ_CENTER,
                    SLIDER_LevelFormat,  "%s",
                    SLIDER_Orientation,  SLIDER_HORIZONTAL,
                    SLIDER_Ticks,        15,
                    SLIDER_ShortTicks,   TRUE,
                    SLIDER_LevelHook,    &slider_hook,
                End,  // Slider
                Label("_Monitor: "),

                LAYOUT_AddChild,     OBJ(OBJ_GAIN_SLIDER) = SliderObject,
                    GA_ID,               OBJ_GAIN_SLIDER,
                    SLIDER_Min,          0,
                    SLIDER_Max,          45,
                    SLIDER_Level,        0,
                    SLIDER_LevelPlace,   PLACETEXT_LEFT,
                    SLIDER_LevelMaxLen,  8,
                    SLIDER_LevelJustify, SLJ_CENTER,
                    SLIDER_LevelFormat,  "%s",
                    SLIDER_Orientation,  SLIDER_HORIZONTAL,
                    SLIDER_Ticks,        15,
                    SLIDER_ShortTicks,   TRUE,
                    SLIDER_LevelHook,    &slider_hook,
                End,  // Slider
                Label("_Gain: "),

                LAYOUT_AddChild,       OBJ(OBJ_INPUT) = ChooserObject,
                    GA_ID,               OBJ_INPUT,
                    GA_RelVerify,        TRUE,
                    CHOOSER_LabelArray,  input,
                    CHOOSER_Selected,    0,
                End,  // Chooser
                Label("_Input: "),

                LAYOUT_AddChild,       OBJ(OBJ_OUTPUT) = ChooserObject,
                    GA_ID,               OBJ_OUTPUT,
                    GA_RelVerify,        TRUE,
                    CHOOSER_LabelArray,  output,
                    CHOOSER_Selected,    0,
                End,  // Chooser
                Label("_Output: "),

             End,  // VLayout
             CHILD_WeightedWidth,   0,
         End,  // HLayout
         CHILD_WeightedHeight,   0,
    End;  // VLayout


    page3 = VLayoutObject,
        LAYOUT_VertAlignment,  LALIGN_CENTRE,
        LAYOUT_SpaceOuter,     TRUE,
        LAYOUT_AddChild, HLayoutObject,
            LAYOUT_HorizAlignment,  LALIGN_CENTRE,
            LAYOUT_SpaceOuter,     TRUE,
            LAYOUT_AddChild,       VLayoutObject,
                LAYOUT_BevelStyle,  BVS_GROUP,
                LAYOUT_Label,       " Global Options ",

                LAYOUT_AddChild,       OBJ(OBJ_DEBUG_LEVEL) = ChooserObject,
                    GA_ID,               OBJ_DEBUG_LEVEL,
                    GA_RelVerify,        TRUE,
                    CHOOSER_LabelArray,  debug_level,
                    CHOOSER_Selected,    0,
                End,  // Chooser
                Label(" _Debug level:"),

                LAYOUT_AddChild,       OBJ(OBJ_ECHO) = ChooserObject,
                    GA_ID,               OBJ_ECHO,
                    GA_RelVerify,        TRUE,
                    CHOOSER_LabelArray,  en_disable,
                    CHOOSER_Selected,    0,
                End,  // Chooser
                Label(" _Echo:"),

                LAYOUT_AddChild,       OBJ(OBJ_SURROUND) = ChooserObject,
                    GA_ID,               OBJ_SURROUND,
                    GA_RelVerify,        TRUE,
                    CHOOSER_LabelArray,  en_disable,
                    CHOOSER_Selected,    0,
                End,  // Chooser
                Label(" Surround in _Fast modes:"),

                LAYOUT_AddChild,       OBJ(OBJ_MASTER_VOL) = ChooserObject,
                    GA_ID,               OBJ_MASTER_VOL,
                    GA_RelVerify,        TRUE,
                    CHOOSER_LabelArray,  master_vol,
                    CHOOSER_Selected,    0,
                End,  // Chooser
                Label(" _Master volume:"),

                LAYOUT_AddChild,     OBJ(OBJ_CPU_SLIDER) = SliderObject,
                    GA_ID,               OBJ_CPU_SLIDER,
                    SLIDER_Min,          0,
                    SLIDER_Max,          100,
                    SLIDER_Level,        90,
                    SLIDER_LevelPlace,   PLACETEXT_LEFT,
                    SLIDER_LevelMaxLen,  6,
                    SLIDER_LevelJustify, SLJ_CENTER,
                    SLIDER_LevelFormat,  "%ld %%",
                    SLIDER_Orientation,  SLIDER_HORIZONTAL,
                    SLIDER_Ticks,        15,
                    SLIDER_ShortTicks,   TRUE,
                End,  // Slider
                Label("CPU usage limit:"),

                LAYOUT_AddChild,     OBJ(OBJ_ANTI_CLICK_SLIDER) = SliderObject,
                    GA_ID,               OBJ_ANTI_CLICK_SLIDER,
                    SLIDER_Min,          0,
                    SLIDER_Max,          100,
                    SLIDER_Level,        0,
                    SLIDER_LevelPlace,   PLACETEXT_LEFT,
                    SLIDER_LevelMaxLen,  6,
                    SLIDER_LevelJustify, SLJ_CENTER,
                    SLIDER_LevelFormat,  "%ld ms",
                    SLIDER_Orientation,  SLIDER_HORIZONTAL,
                    SLIDER_Ticks,        15,
                    SLIDER_ShortTicks,   TRUE,
                End,  // Slider
                Label(" Default anti-click time:"),

                LAYOUT_AddChild,       OBJ(OBJ_VOL_SCALING) = ChooserObject,
                    GA_ID,               OBJ_VOL_SCALING,
                    GA_RelVerify,        TRUE,
                    CHOOSER_LabelArray,  vol_scaling,
                    CHOOSER_Selected,    2,
                End,  // Chooser
                Label(" Volume sc_aling:"),

             End,  // VLayout
             CHILD_WeightedWidth,   0,
         End,  // HLayout
         CHILD_WeightedHeight,   0,
     End;  // VLayout


    return WindowObject,
        WA_ScreenTitle,        "Reaction Example",
        WA_Title,              "AHI Prefrences",
        WA_DragBar,            TRUE,
        WA_CloseGadget,        TRUE,
        WA_SizeGadget,         TRUE,
        WA_DepthGadget,        TRUE,
        WA_Activate,           TRUE,
        WINDOW_IconifyGadget,  TRUE,
        WINDOW_IconTitle,      "Iconified",
        WINDOW_Icon,           IIcon->GetDiskObject("AHI"),
        WINDOW_AppPort,        AppPort,
        WINDOW_GadgetHelp,     TRUE,
        WINDOW_HintInfo,       &helpstrs,
        WINDOW_Position,       WPOS_CENTERSCREEN,
        WINDOW_Layout,         VLayoutObject,
            LAYOUT_SpaceOuter,     TRUE,
            LAYOUT_AddChild,        HLayoutObject,

                LAYOUT_AddChild,    SpaceObject,
                    SPACE_MinWidth,    2,
                End,  // Space
                CHILD_WeightedWidth,   0,

                LAYOUT_AddChild,       OBJ(OBJ_MUSIC_UNIT) = ChooserObject,
                    GA_ID,                 OBJ_MUSIC_UNIT,
                    GA_RelVerify,          TRUE,
                    CHOOSER_LabelArray,    music_unit,
                End,  // Chooser

                SPACE,
                LAYOUT_AddChild, Button("_Play a test sound",OBJ_PLAY),

                LAYOUT_AddChild,    SpaceObject,
                    SPACE_MinWidth,    2,
                End,  // Space
                CHILD_WeightedWidth,   0,
            End,   // HLayout
            CHILD_WeightedHeight,   0,

            LAYOUT_AddChild,       ClickTabObject,
                GA_Text,            PageLabels,
                CLICKTAB_PageGroup, PageObject,
                    PAGE_Add,       page1,
                    PAGE_Add,       page2,
                    PAGE_Add,       page3,
                End,  // Page
            End,  // ClickTab

            LAYOUT_AddChild,        HLayoutObject,

                LAYOUT_AddChild,    SpaceObject,
                    SPACE_MinWidth,    2,
                End,  // Space
                CHILD_WeightedWidth,   0,

                LAYOUT_AddChild,        HLayoutObject,
                    LAYOUT_EvenSize,    TRUE,
                    LAYOUT_AddChild, Button("_Save",OBJ_SAVE),
                    CHILD_WeightedWidth,   0,
                    SPACE,
                    LAYOUT_AddChild, Button("_Use",OBJ_USE),
                    CHILD_WeightedWidth,   0,
                    SPACE,
                    LAYOUT_AddChild, Button("_Cancel",OBJ_CANCEL),
                    CHILD_WeightedWidth,   0,
                End,   // HLayout
                CHILD_WeightedHeight,   0,

                LAYOUT_AddChild,    SpaceObject,
                    SPACE_MinWidth,    2,
                End,  // Space
                CHILD_WeightedWidth,   0,

                End,   // HLayout
            CHILD_WeightedHeight,   0,

        End,   // VLayout
    End;  // WindowObject
}


int main()
{
    struct Window *window;

    RA_SetUpHook(slider_hook, HookFunc, NULL);

    if (scr = IIntuition->LockPubScreen (NULL))
    {
        if (make_browserlist(&drivermode_list, list_strings))
        {
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
                                        case OBJ_CANCEL:
                                            done=TRUE;
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
            free_browserlist(&drivermode_list);
        }
        IIntuition->UnlockPubScreen (NULL,scr);
    }
}


BOOL make_browserlist(struct List *list,  char **string)
{
    struct Node *node;

    IExec->NewList(list);
    while (*string)
    {
        if (node = IListBrowser->AllocListBrowserNode(1,
            LBNA_Column, 0,
                LBNCA_Text, *string,
            TAG_DONE))
        {
            IExec->AddTail(list, node);
        }
        else
        {
            printf(" AllocListBrowserNode() failed\n");
            return(FALSE);
        }
        string++;
    }
    return(TRUE);
}

VOID free_browserlist(struct List *list)
{
    struct Node *node, *nextnode;

    node = list->lh_Head;
    while (nextnode = node->ln_Succ)
    {
        IListBrowser->FreeListBrowserNode(node);
        node = nextnode;
    }
    IExec->NewList(list);
}


STRPTR HookFunc(struct Hook *hook, Object *slider_obj, struct TagItem *Msg)
{
    char tempstr_1[10];
    char tempstr_2[10];
    char tempchar;
    int32 num;
    int32 len;

    num = IUtility->GetTagData(SLIDER_Level, 0, Msg);

    if (num == -194)
    {
        sprintf (textstr, "Muted");
    }
    else if (num == -1)
    {
        sprintf (textstr,"-0.5 dB");
    }
    else
    {
        num = num*5;
        if ((num < 10) && (num > -5))
        {
            sprintf (tempstr_1,"0%d",num);
        }
        else
        {
            sprintf (tempstr_1,"%d",num);
        }
        len = strlen(tempstr_1);
        tempchar = tempstr_1[len-1];
        strncpy(tempstr_2,tempstr_1,len-1);
        tempstr_2[len-1] = 0;
        sprintf (textstr, "%s.%c dB",tempstr_2,tempchar);
    }
    return textstr;
}

