//
//  Converted to C from AmigaE source BlockSize.e
//  BlockSize.e written by Dave Noris (DaveN).
//
//  To compile:
//  gcc -o BlockSize BlockSize.c -lraauto -lauto
//
//  To make the compiled code smaller:
//  strip BlockSize
//

#include <exec/exec.h>
#include <intuition/intuition.h>
#include <intuition/icclass.h>
#include <dos/dos.h>
#include <dos/dosextens.h>
#include <images/label.h>

#include <classes/window.h>
#include <classes/requester.h>

#include <gadgets/fuelgauge.h>
#include <gadgets/layout.h>
#include <gadgets/radiobutton.h>
#include <gadgets/chooser.h>
#include <gadgets/getfile.h>

#include <proto/exec.h>
#include <proto/intuition.h>
#include <proto/dos.h>
#include <proto/utility.h>

#include <proto/fuelgauge.h>
#include <proto/window.h>
#include <proto/layout.h>
#include <proto/radiobutton.h>
#include <proto/chooser.h>
#include <proto/space.h>
#include <proto/requester.h>
#include <proto/getfile.h>
#include <proto/label.h>

#include <reaction/reaction_macros.h>

#include <stdlib.h>
#include <string.h>
#include <stdarg.h>


Object *win;

struct Window *window;
struct MsgPort *AppPort;
struct List chooserlist;
struct Hook idcmphook;

enum
{
    OBJ_512,
    OBJ_1024,
    OBJ_2048,
    OBJ_4096,
    OBJ_8192,
    OBJ_16384,
    OBJ_OVER_16384,
    OBJ_ROOT_LAYOUT,
    OBJ_RESET,
    OBJ_GETFILE,
    OBJ_HIDDEN_CHOOSER,
    OBJ_RESET_2,
    OBJ_BLOCKSIZE,
    OBJ_VOL_OTHER,
    OBJ_START,
    OBJ_STOP,
    OBJ_RADIO,
    OBJ_FUEL_DONE,
    OBJ_NUM
};

enum
{
    RADIO_1, RADIO_2, RADIO_3, RADIO_4, RADIO_5, RADIO_6
};

Object *Objects[OBJ_NUM];
#define OBJ(x) Objects[x]
#define GAD(x) (struct Gadget *)Objects[x]

#define SPACE LAYOUT_AddChild, SpaceObject, End
#define FUELMAX 2000

STRPTR RadioDisplay[] =
{
    " Number of files by size",
    " Amount of the used space taken by size",
    " Kbytes wasted for present block size",
    " Percentage wasted for present block size",
    " Storage needed for files if block size used",
    " Percentage wasted if block size used",
    NULL
};

STRPTR VolOther[] =
{
    " Volume",
    " Other",
    NULL
};

typedef struct
{
    STRPTR  Name;
} Volume;

Volume *Volumes;

int16 radio_num = 0;        //  what is selected on the radio
uint32 fg_Max = FUELMAX;    //  what FUELGAUGE_Max is at the moment
int16 NumVolumes;           //  number of volumes on computer
int32 NumBlocksUsed;        //  blocks in use that the target says it has
int16 BlockSize;            //  block size the target has reported
int32 BlocksDone;           //  blocks completed
int32 filesizes[8];         //  array of files by size
int32 filesizesblocks[8];   //  array of blocks used by each filesize
BOOL ReqSelect = FALSE;     //  was volume selected from the requester?
BOOL ReadyToStart = FALSE;  //  is it ok to start scan?
BOOL StopScan = FALSE;      //  has user clicked Stop while scanning?

BOOL MakeChooserList(struct List *);
VOID FreeChooserList(struct List *);
BOOL GetDosList(void);
VOID FreeDosList(void);
STRPTR ConvertStr(BSTR);
VOID IDCMPFunc(struct Hook *,Object *,struct IntuiMessage *);
VOID GetBlockSize(void);
VOID start(void);
VOID StartScan(STRPTR, int32);
VOID CheckForStop(void);
VOID UpdateProgressBar(int32, STRPTR);
VOID ShowResults(void);
VOID pickradio(void);
VOID ClearTargetStrings(void);
VOID ClearResults(void);
uint32 MessageBoxA(char *, char *, APTR);
uint32 VARARGS68K MessageBox(char *, char *, ...);

// ***************************************************************


Object *
make_window(void)
{
    OBJ(OBJ_HIDDEN_CHOOSER) = ChooserObject,
        GA_ID,                  OBJ_HIDDEN_CHOOSER,
        GA_RelVerify,           TRUE,
        CHOOSER_Labels,         &chooserlist,
        CHOOSER_DropDown,       TRUE,
        CHOOSER_AutoFit,        TRUE,
        CHOOSER_Hidden,         TRUE,
        ICA_TARGET,             ICTARGET_IDCMP,
    End;  // Chooser

    return WindowObject,
        WA_ScreenTitle,        "Reaction Example",
        WA_Title,              " BlockSize",
        WA_DragBar,            TRUE,
        WA_CloseGadget,        TRUE,
        WA_SizeGadget,         TRUE,
        WA_DepthGadget,        TRUE,
        WA_Activate,           TRUE,
        WINDOW_LockHeight,     TRUE,
        WINDOW_IconifyGadget,  TRUE,
        WINDOW_IconTitle,      "Iconified",
        WINDOW_AppPort,        AppPort,
        WINDOW_IDCMPHookBits,  IDCMP_IDCMPUPDATE,
        WINDOW_IDCMPHook,      &idcmphook,
        WINDOW_Position,       WPOS_CENTERSCREEN,
        WINDOW_Layout,         OBJ(OBJ_ROOT_LAYOUT) = VLayoutObject,
            GA_ID,                 OBJ_ROOT_LAYOUT,

            LAYOUT_SpaceOuter,     TRUE,
            LAYOUT_AddChild,       HLayoutObject,
                LAYOUT_SpaceOuter,     TRUE,
                LAYOUT_EvenSize,       TRUE,
                LAYOUT_AddChild,       VLayoutObject,
                    LAYOUT_SpaceOuter,     TRUE,
                    LAYOUT_BevelStyle,     BVS_GROUP,
                    LAYOUT_Label,          " Target ",
                    LAYOUT_AddChild,       VLayoutObject,
                        LAYOUT_SpaceOuter,     TRUE,

                        LAYOUT_AddChild,       OBJ(OBJ_RESET) = LayoutObject,
                            LAYOUT_AddChild,       OBJ(OBJ_GETFILE) = GetFileObject,
                                GA_ID,                 OBJ_GETFILE,
                                GA_RelVerify,          TRUE,
                                GETFILE_ReadOnly,      TRUE,
                                GETFILE_DrawersOnly,   TRUE,
                                GETFILE_TitleText,     "Select Volume / Device / Drawer",
                            End,  // GetFile
                        End,  // Layout
                        SPACE,

                        LAYOUT_AddChild,       HLayoutObject,
                            LAYOUT_SpaceOuter,     TRUE,
                            LAYOUT_AddChild,    OBJ(OBJ_RESET_2) = HLayoutObject,

                                LAYOUT_AddChild,    OBJ(OBJ_VOL_OTHER) = RadioButtonObject,
                                    GA_ID,          OBJ_VOL_OTHER,
                                    GA_Text,        VolOther,
                                    GA_RelVerify,   TRUE,
                                End,  // RadioButton
                                CHILD_WeightedHeight,   0,
                                CHILD_WeightedWidth,   0,

                                LAYOUT_AddChild, VLayoutObject,
                                    LAYOUT_BevelStyle,  BVS_SBAR_HORIZ,
                                End,  // VLayout
                                CHILD_WeightedWidth,   0,

                                LAYOUT_AddChild,    OBJ(OBJ_BLOCKSIZE) = ButtonObject,
                                    GA_ID,          OBJ_BLOCKSIZE,
                                    GA_ReadOnly,    TRUE,
                                    GA_RelVerify,   TRUE,
                                End,  // Button
                                Label("   Block size: "),
                                CHILD_WeightedHeight,   0,

                            End,  // HLayout
                        End,  // HLayout

                        LAYOUT_AddChild,    HLayoutObject,
                            LAYOUT_AddChild,    Button("Start",OBJ_START),
                            LAYOUT_AddChild,    Button("Stop",OBJ_STOP),
                        End,  // HLayout
                        CHILD_WeightedHeight,   0,

                    End,  // VLayout
                End,  // VLayout
                LAYOUT_AddChild,    VLayoutObject,
                    LAYOUT_SpaceOuter,  TRUE,
                    LAYOUT_BevelStyle,  BVS_GROUP,
                    LAYOUT_Label,       " Display ",
                    LAYOUT_AddChild,    OBJ(OBJ_RADIO) = RadioButtonObject,
                        GA_Text,        RadioDisplay,
                        GA_ID,          OBJ_RADIO,
                        GA_RelVerify,   TRUE,
                    End,  // RadioButton
                End,  // VLayout
            End,  // HLayout

            LAYOUT_AddChild,    VLayoutObject,
                LAYOUT_SpaceOuter,  TRUE,
                LAYOUT_BevelStyle,  BVS_GROUP,
                LAYOUT_Label,       " Blocks read ",
                LAYOUT_AddChild,    OBJ(OBJ_FUEL_DONE) = FuelGaugeObject,
                    GA_ID,          OBJ_FUEL_DONE,
                    FUELGAUGE_Justification, FGJ_CENTER,
                    GA_RELVERIFY,   TRUE,
                End,
            End,  // VLayout
            SPACE,

            LAYOUT_AddChild,    VLayoutObject,
                LAYOUT_SpaceOuter,              TRUE,
                LAYOUT_BevelStyle,      BVS_GROUP,
                LAYOUT_Label,           " Results ",
                LAYOUT_AddChild,    OBJ(OBJ_512) = FuelGaugeObject,
                    GA_ID,          OBJ_512,
                    FUELGAUGE_Min,         0,
                    FUELGAUGE_Max,         FUELMAX,  // 1000,
                    FUELGAUGE_Percent,     FALSE,
                    FUELGAUGE_Ticks,       FALSE,
                    FUELGAUGE_Justification, FGJ_CENTER,
                    GA_TEXT,               "0",
                End,
                Label("512"),
                LAYOUT_AddChild,    OBJ(OBJ_1024) = FuelGaugeObject,
                    GA_ID,          OBJ_1024,
                    FUELGAUGE_Min,         0,
                    FUELGAUGE_Max,         FUELMAX,  // 1000,
                    FUELGAUGE_Percent,     FALSE,
                    FUELGAUGE_Ticks,       FALSE,
                    FUELGAUGE_Justification, FGJ_CENTER,
                    GA_TEXT,               "0",
                End,
                Label("1024"),
                LAYOUT_AddChild,    OBJ(OBJ_2048) = FuelGaugeObject,
                    GA_ID,          OBJ_2048,
                    FUELGAUGE_Min,         0,
                    FUELGAUGE_Max,         FUELMAX,  // 1000,
                    FUELGAUGE_Percent,     FALSE,
                    FUELGAUGE_Ticks,       FALSE,
                    FUELGAUGE_Justification, FGJ_CENTER,
                    GA_TEXT,               "0",
                End,
                Label("2048"),
                LAYOUT_AddChild,    OBJ(OBJ_4096) = FuelGaugeObject,
                    GA_ID,          OBJ_4096,
                    FUELGAUGE_Min,         0,
                    FUELGAUGE_Max,         FUELMAX,  // 1000,
                    FUELGAUGE_Percent,     FALSE,
                    FUELGAUGE_Ticks,       FALSE,
                    FUELGAUGE_Justification, FGJ_CENTER,
                    GA_TEXT,               "0",
                End,
                Label("4096"),
                LAYOUT_AddChild,    OBJ(OBJ_8192) = FuelGaugeObject,
                    GA_ID,          OBJ_8192,
                    FUELGAUGE_Min,         0,
                    FUELGAUGE_Max,         FUELMAX,  // 1000,
                    FUELGAUGE_Percent,     FALSE,
                    FUELGAUGE_Ticks,       FALSE,
                    FUELGAUGE_Justification, FGJ_CENTER,
                    GA_TEXT,               "0",
                End,
                Label("8192"),
                LAYOUT_AddChild,    OBJ(OBJ_16384) = FuelGaugeObject,
                    GA_ID,          OBJ_16384,
                    FUELGAUGE_Min,         0,
                    FUELGAUGE_Max,         FUELMAX,  // 1000,
                    FUELGAUGE_Percent,     FALSE,
                    FUELGAUGE_Ticks,       FALSE,
                    FUELGAUGE_Justification, FGJ_CENTER,
                    GA_TEXT,               "0",
                End,
                Label("16384"),
                LAYOUT_AddChild,    OBJ(OBJ_OVER_16384) = FuelGaugeObject,
                    GA_ID,          OBJ_OVER_16384,
                    FUELGAUGE_Min,         0,
                    FUELGAUGE_Max,         FUELMAX,  // 1000,
                    FUELGAUGE_Percent,     FALSE,
                    FUELGAUGE_Ticks,       FALSE,
                    FUELGAUGE_Justification, FGJ_CENTER,
                    GA_TEXT,               "0",
                End,
                Label(">16384"),
            End,  // VLayout
        End,   // VLayout
    End;  // WindowObject
}


int
main()
{
    BOOL ChooserOK = FALSE;

    RA_SetUpHook(idcmphook,IDCMPFunc, NULL);
    ChooserOK = MakeChooserList(&chooserlist);
    if ((AppPort = IExec->CreateMsgPort())  && (ChooserOK))
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
                ReqVol      = FALSE,  //  was volume selected from the requester?
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
                                case OBJ_VOL_OTHER:
                                    ReqVol = (ReqVol == 0);  // swap between TRUE and FALSE
                                    break;
                                case OBJ_GETFILE:
                                    if (ReqVol)
                                        {
                                        if (gfRequestFile(OBJ(OBJ_GETFILE), window))
                                            {
                                            ReqSelect = TRUE;
                                            GetBlockSize();   // check out selection
                                            }
                                        }
                                    else
                                        IIntuition->ActivateGadget(GAD(OBJ_HIDDEN_CHOOSER), window, NULL);
                                    break;
                                case OBJ_START:
                                    if (ReadyToStart) start();
                                    break;
                                case OBJ_RADIO:
                                    radio_num = code;
                                    pickradio();
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
    }
    if (AppPort) IExec->DeleteMsgPort(AppPort);
    if (ChooserOK) FreeChooserList(&chooserlist);
}


void CheckForStop()
{
    uint32 result = 0;
    uint16 code   = 0;

    if ((result = RA_HandleInput(win, &code)) != WMHI_LASTMSG)
    {
        switch(result & WMHI_CLASSMASK)
        {
            case WMHI_GADGETUP:
            {
                switch (result & WMHI_GADGETMASK)
                {
                    case OBJ_STOP:
                        StopScan = TRUE;
                        break;
                    case OBJ_RADIO:        // Does user want to see other results
                        radio_num = code;  // when the scan is in progress?
                        pickradio();
                        break;
                }
            }
        }
    }
}


void IDCMPFunc(struct Hook *hook,Object *wobj,struct IntuiMessage *Msg)
{
    struct Window *window = Msg->IDCMPWindow;
    uint32 active;

    if (Msg->Class == IDCMP_IDCMPUPDATE)
    {
        if (IUtility->GetTagData(GA_ID, 0, Msg->IAddress) == OBJ_HIDDEN_CHOOSER)
        {
            active = IUtility->GetTagData(CHOOSER_Active, -1, Msg->IAddress);
            IIntuition->SetGadgetAttrs(GAD(OBJ_GETFILE),window,NULL,
                    GETFILE_FullFile, Volumes[active].Name, TAG_END);
            ReqSelect = FALSE;
            GetBlockSize();
        }
    }
}


BOOL MakeChooserList(struct List *list)
{
    struct Node *node;
    int i;

    GetDosList();  // get the volume names

    IExec->NewList(list);

    for (i=0; i<NumVolumes; i++)
    {
        node = IChooser->AllocChooserNode(CNA_Text, Volumes[i].Name, TAG_END);
        if(node)
        {
            IExec->AddTail(list, node);
        }
        else
        {
            MessageBox("OK","Failed to create the Chooser List");
            FreeDosList();
            return(FALSE);
        }
    }
    return(TRUE);
}


void FreeChooserList(struct List *list)
{
    struct Node *node, *nextnode;

    node = list->lh_Head;
    while(nextnode = node->ln_Succ)
    {
        IChooser->FreeChooserNode(node);
        node = nextnode;
    }
    IExec->NewList(list);
    FreeDosList();
}


BOOL GetDosList(void)
{
    struct DosList *dlist;
    int i;

    NumVolumes=0;
    dlist=IDOS->LockDosList(LDF_VOLUMES | LDF_READ);
    while (dlist=IDOS->NextDosEntry(dlist, LDF_VOLUMES))
    {
        NumVolumes++;
    }
    IDOS->UnLockDosList(LDF_VOLUMES | LDF_READ);

    Volumes = (Volume *)IExec->AllocVec(NumVolumes * sizeof(Volume),MEMF_SHARED);
    i=0;
    dlist=IDOS->LockDosList(LDF_VOLUMES | LDF_READ);
    while (dlist=IDOS->NextDosEntry(dlist, LDF_VOLUMES))
    {
        Volumes[i++].Name = ConvertStr(dlist->dol_Name);
    }
    IDOS->UnLockDosList(LDF_VOLUMES | LDF_READ);
}


STRPTR ConvertStr(BSTR str)
{
    STRPTR retstr;
    STRPTR Blen;

    if (!str) return(NULL);
    Blen=(STRPTR)BADDR(str);      // returns BCPL string length
    if (!Blen[0]) return(NULL);

    retstr=(STRPTR)IExec->AllocVec(Blen[0] + 2, MEMF_SHARED);  // allocate for ":" as well as NULL
    IExec->CopyMem(Blen + 1, retstr, Blen[0]);
    retstr[Blen[0]]=0;
    IUtility->Strlcat(retstr,":",Blen[0] + 2);
    return(retstr);
}


void FreeDosList(void)
{
    int i;

    for (i=0; i<NumVolumes; i++)
    {
        IExec->FreeVec(Volumes[i].Name);
    }
    IExec->FreeVec(Volumes);
    NumVolumes=0;
}


void GetBlockSize()
{
    struct  InfoData *infod = NULL;
    struct  FileInfoBlock *fib = NULL;
    int32   lock;
    char   *target, blocksizestr[8];
    BOOL    good = FALSE;

    IIntuition->GetAttrs(OBJ(OBJ_GETFILE),GETFILE_FullFile,&target,TAG_DONE);
    if (!(lock = IDOS->Lock(target,ACCESS_READ)))
    {
        MessageBox("OK","Failed to get a Lock on: %s", target);
        goto done;
    }
    if (!(fib = IDOS->AllocDosObjectTags(DOS_FIB,TAG_DONE)))
    {
        MessageBox("OK","Failed to allocate a FileInfoBlock for: %s", target);
        goto done;
    }
    if (!(infod = IDOS->AllocDosObjectTags(DOS_INFODATA,TAG_DONE)))
    {
        MessageBox("OK","Failed to allocate an InfoData for: %s", target);
        goto done;
    }
    if (!(IDOS->Examine(lock,fib)))
    {
        MessageBox("OK","Failed to Examine: %s", target);
        goto done;
    }
    if FIB_IS_DRAWER(fib)                //  macro from dos/dos.h
    {
        if (IDOS->Info(lock,infod))
        {
            NumBlocksUsed = infod->id_NumBlocksUsed;

            BlockSize = infod->id_BytesPerBlock;
            sprintf (blocksizestr, "%d", infod->id_BytesPerBlock);

            IIntuition->SetGadgetAttrs( GAD(OBJ_BLOCKSIZE), window, NULL,
                                        GA_Text, blocksizestr, TAG_END);
            if (ReqSelect)
            {
                IIntuition->SetGadgetAttrs( GAD(OBJ_FUEL_DONE), window, NULL,
                    FUELGAUGE_Percent,  FALSE,
                    FUELGAUGE_Level,    0,
                    GA_TEXT,            "0",  TAG_END);
            }
            else
            {
                IIntuition->SetGadgetAttrs( GAD(OBJ_FUEL_DONE), window, NULL,
                    GA_TEXT,            "",
                    FUELGAUGE_Percent,  TRUE,
                    FUELGAUGE_Max,      NumBlocksUsed,
                    FUELGAUGE_Level,    0, TAG_END);
            }
            ClearResults();
            ReadyToStart = TRUE;
        }
        else
        {
            MessageBox("OK","Failed to fill in the InfoData for: %s", target);
            goto done;
        }
     }
     else
     {
         MessageBox("OK","It appears that %s is not a volume or directory",target);
         goto done;
     }
    good = TRUE;

done:
    if (infod) IDOS->FreeDosObject(DOS_INFODATA,infod);
    if (fib) IDOS->FreeDosObject(DOS_FIB,fib);
    if (lock) IDOS->UnLock(lock);
    if (NOT good) ClearTargetStrings();
}


void ClearTargetStrings()
{
    IIntuition->SetGadgetAttrs(GAD(OBJ_GETFILE),window,NULL,GETFILE_FullFile,"",TAG_END);
    IIntuition->SetGadgetAttrs(GAD(OBJ_BLOCKSIZE),window,NULL,GA_Text,"",TAG_END);
    IIntuition->SetGadgetAttrs(GAD(OBJ_FUEL_DONE),window,NULL,FUELGAUGE_Level,0,TAG_END);
    ClearResults();
    ReadyToStart = FALSE;
}


void ClearResults()
{
    int i;

    for (i=OBJ_512; i<=OBJ_OVER_16384; i++)
    {
        IIntuition->SetGadgetAttrs(GAD(i),window,NULL,
        FUELGAUGE_Level, 0,
        FUELGAUGE_Max,   FUELMAX,
        GA_TEXT,  "0",  TAG_END);
    }
}


void start()
{
    STRPTR target;
    char textstr[1000];  //  for long path names in req mode
    int32   lock;
    int i;

    ReadyToStart = FALSE;     //  Clear the decks for action
    BlocksDone = 0;
    fg_Max = FUELMAX;
    if (StopScan)
    {
        ClearResults();       // reset FUELGAUGE_Max to FUELMAX in case fg_Max
        StopScan = FALSE;     // was greater than FUELMAX when user clicked stop
    }
    for (i=0; i<=7; i++)
    {
        filesizes[i] = 0;
        filesizesblocks[i] = 0;
    }
    IIntuition->GetAttrs(OBJ(OBJ_GETFILE),GETFILE_FullFile,&target,TAG_END);
    if (lock = IDOS->Lock(target,ACCESS_READ));
    {
        StartScan(target,lock);              //  Decks cleared, so Go

        //  **************** fill the gauge when finished ***************
        //  The difference between id_NumBlocksUsed and the number of blocks
        //  counted is usually about 1%, so here the progress fuelgauge gets
        //  filled to 100% to inform the user that the scan has finished.

        sprintf (textstr, "%d Blocks have been used on %s",BlocksDone,target);
        UpdateProgressBar(NumBlocksUsed,textstr);      // fill to 100%
        IDOS->UnLock(lock);
    }
    ReadyToStart = TRUE;
}


void StartScan(STRPTR target,int32 lock)
{
    struct  FileInfoBlock *fib = NULL;
    char textstr[20];

    if (!(fib = IDOS->AllocDosObjectTags(DOS_FIB,TAG_DONE)))
    {
        MessageBox("OK","Failed to allocate a FileInfoBlock for:  %s", target);
        goto done;
    }
    if (!(IDOS->Examine(lock,fib)))
    {
    MessageBox("OK","Failed to Examine:  %s", target);
    goto done;
    }
    while((IDOS->ExNext(lock,fib)) && (StopScan == FALSE))
    {
        if FIB_IS_FILE(fib)         //  macro from dos/dos.h
        {
            if (fib->fib_Size <512)
            {
                filesizes[0]++;
                filesizesblocks[0] += fib->fib_NumBlocks;
            }
            else if (fib->fib_Size <1024)
            {
                filesizes[1]++;
                filesizesblocks[1] += fib->fib_NumBlocks;
            }
            else if (fib->fib_Size <2048)
            {
                filesizes[2]++;
                filesizesblocks[2] += fib->fib_NumBlocks;
            }
            else if (fib->fib_Size <4096)
            {
                filesizes[3]++;
                filesizesblocks[3] += fib->fib_NumBlocks;
            }
            else if (fib->fib_Size <8192)
            {
                filesizes[4]++;
                filesizesblocks[4] += fib->fib_NumBlocks;
            }
            else if (fib->fib_Size <16384)
            {
                filesizes[5]++;
                filesizesblocks[5] += fib->fib_NumBlocks;
            }
            else
            {
                filesizes[6]++;
                filesizesblocks[6] += fib->fib_NumBlocks;
            }
            BlocksDone += fib->fib_NumBlocks;  // most accurate way
        }
        else if FIB_IS_DRAWER(fib)           //  macro from dos/dos.h
        {
            int32 oldlock;
            int32 newlock;

            BlocksDone += fib->fib_NumBlocks;  // most accurate, 1% slower
            filesizesblocks[7] += fib->fib_NumBlocks;

            oldlock = IDOS->CurrentDir(lock);

            newlock = IDOS->Lock(fib->fib_FileName,ACCESS_READ);

            IDOS->CurrentDir(oldlock);

            if (!(newlock))
            {
            MessageBox("OK","Failed to get a Lock on the directory:  %s", fib->fib_FileName);
            goto done;
            }

            StartScan(fib->fib_FileName,newlock);

            IDOS->UnLock(newlock);
        }
        CheckForStop();
        if (!(StopScan))  // if stop button has not been pressed, update results.
        {
            sprintf (textstr, "%d",BlocksDone);
            UpdateProgressBar(BlocksDone,textstr);
            ShowResults();
        }
    }
done:
    if (fib) IDOS->FreeDosObject(DOS_FIB,fib);
}


void UpdateProgressBar(int32 level, STRPTR levelstr)
{
    if (ReqSelect)         // Volume was selected from requester
    {
        IIntuition->SetGadgetAttrs( GAD(OBJ_FUEL_DONE), window, NULL,
                            GA_Text, levelstr, TAG_END);
    }
    else            // Volume was selected from Exec List
    {
        IIntuition->SetGadgetAttrs( GAD(OBJ_FUEL_DONE), window, NULL,
                            FUELGAUGE_Level, level, TAG_END);
    }
}


void ShowResults(void)
{
    char textstr[20];
    int i, max;

    for (i=OBJ_512; i<=OBJ_OVER_16384; i++)
    {
        if  (filesizes[i] > fg_Max)
        {
            fg_Max = fg_Max*2;     // extend the range so results fit in.
            for (max=OBJ_512; max<=OBJ_OVER_16384; max++)
            {
            IIntuition->SetGadgetAttrs( GAD(max), window, NULL,
                                FUELGAUGE_Max, fg_Max, TAG_END);
            }
        }
    }
    pickradio();
}


void pickradio()           // Radio buttons can be selected while scan
{                          // is running, to show other results.
    char textstr[20];
    int i;

    switch (radio_num)
    {
        case RADIO_1:
            for (i=OBJ_512; i<=OBJ_OVER_16384; i++)
            {
                sprintf (textstr, "%d", filesizes[i]);
                IIntuition->SetGadgetAttrs( GAD(i), window, NULL,
                    FUELGAUGE_Percent,  FALSE,
                    FUELGAUGE_Max,      fg_Max,
                    FUELGAUGE_Level,    filesizes[i],
                    GA_TEXT,            textstr,
                    TAG_END);
            }
            break;
        case RADIO_2:

            //  Missing 4% to 5%  is used by directorys,
            //  filesizes[7], maybe show dirs % in the
            //  progress bar when finished?
            //
            //  Perhaps using floats would be better as
            //  any result below 1% shows 0% as opposed
            //  to something like 0.35%

            for (i=OBJ_512; i<=OBJ_OVER_16384; i++)
            {
                IIntuition->SetGadgetAttrs( GAD(i), window, NULL,
                    FUELGAUGE_Percent,  TRUE,
                    FUELGAUGE_Max,      100,
                    FUELGAUGE_Level,    (filesizesblocks[i]*100) / BlocksDone,
                    GA_TEXT,            "",
                    TAG_END);
            }
            break;
        case RADIO_3:
            break;
        case RADIO_4:
            break;
        case RADIO_5:
            break;
        case RADIO_6:
            break;
    }
}

uint32 MessageBoxA(char *gadgets, char *format, APTR args )
{
    Object *requester;
    char buffer[512];
    uint32 result = 0;

    IUtility->SetMem(buffer, 0, 512);
    IExec->RawDoFmt(format, args, NULL, buffer);
    requester = IIntuition->NewObject(IRequester->REQUESTER_GetClass(), NULL,
            REQ_Type,               REQTYPE_INFO,
            REQ_TitleText,          "BlockSize Message",
            REQ_BodyText,           buffer,
            REQ_GadgetText,         gadgets,
    TAG_DONE);
    if (requester)
    {
        result = IIntuition->IDoMethod( requester, RM_OPENREQ, NULL, NULL, NULL );
        IIntuition->DisposeObject(requester);
    }
    return result;
}


uint32 VARARGS68K MessageBox(char *gadgets, char *format, ...)
{
    va_list  ap;
    int32    result;

    va_startlinear (ap, format);
    result = MessageBoxA(gadgets, format, va_getlinearva(ap,void*) );
    va_end(ap);
    return result;
}


