/*
** PROGRAMM:  AmigaGuideDesigner Preferences
** AUTOR:     Michael Weiser
** COPYRIGHT: ©1994 Michael Weiser (Giftware)
** COMPILER:  SAS/C 6.5
**
** MODUL:     MiscSetWin.c
** FUNKTION:  MiscSetWindow-Routinen für AmigaGuideDesigner
**
*/

/*#define DEBUG*/
#include "AGDPrefs.h"

       struct Window      *MiscSetWin=NULL;
       ULONG               MiscSetBit=0;

static UWORD               Width,Height;
static WORD                WZoom[4];

static BOOL                RTFileReq,RTFontReq,RTEasyReq;

static char               *LibLabels[3]  ={NULL};
static char               *EasyRLabels[3]={NULL};

static struct TagItem      EditorTags[]={GTST_String,NULL,
                                         GTST_MaxChars,STRMAXCHARS,
                                         TAG_DONE};

static struct TagItem      TmpDocFNTags[]={GTST_String,NULL,
                                           GTST_MaxChars,STRMAXCHARS,
                                           TAG_DONE};

static struct TagItem      FileRTags[]={GTCY_Active,0,
                                        GTCY_Labels,(ULONG)LibLabels,
                                        TAG_DONE};

static struct TagItem      FontRTags[]={GTCY_Active,0,
                                        GTCY_Labels,(ULONG)LibLabels,
                                        TAG_DONE};

static struct TagItem      EasyRTags[]={GTCY_Active,0,
                                        GTCY_Labels,(ULONG)EasyRLabels,
                                        TAG_DONE};

static struct TagItem      CrIconsTags[]={GTCB_Checked,FALSE,
                                          GTCB_Scaled,TRUE,
                                          TAG_DONE};

/* GADGETS */
/* erste Spalte */
#define GD_EDITOR_STR      0
#define GD_EDITOR_SEL      1
#define GD_TMPDOCFN_STR    2
#define GD_TMPDOCFN_SEL    3
#define GD_FILERLIB_CYC    4
#define GD_FONTRLIB_CYC    5
#define GD_EASYRLIB_CYC    6
#define GD_CRICONS_CKB     7
#define GD_USE_BUT         8
#define GD_CANCEL_BUT      9
#define GDNUM             10

static struct GadgetData   GadDat[GDNUM];
static struct Gadget      *GadList;
static struct SepData      SepD;

/* VANILLAKEYS */
#define KEY_EDITOR_LWR     0
#define KEY_EDITOR_UPR     1
#define KEY_TMPDOCFN_LWR   2
#define KEY_TMPDOCFN_UPR   3
#define KEY_FILERLIB       4
#define KEY_FONTRLIB       5
#define KEY_EASYRLIB       6
#define KEY_CRICONS        7
#define KEY_USE            8
#define KEY_CANCEL         9
#define KEY_NULL          10
#define KEYNUM            11

static char                VanKeys[KEYNUM];

static void SetStrGad(UBYTE,char *);
static void SetCycleGad(UBYTE,UBYTE);
static void SetCheckBoxGad(UBYTE,BOOL);

/* ==================================================================================== InitMiscSetWin
** fordert alle wichtigen Resourcen für das MiscSetWin an, damit später nur noch
** schnell das Window geöffnet werden muß
*/
void InitMiscSetWin(void)
{
  struct GadgetData *gd;
  ULONG i;
  UWORD tmp,labw,strw,selstrw,butw,selw,left,lableft,gadh,yadd,top;
  char *sel="Sel";

  DEBUG_PRINTF("\n  -- Invoking InitMiscSetWin-Function --\n");
  
  /* Gadgetlabels initialisieren */
  GadDat[GD_EDITOR_STR].GadgetText   ="_Editor";
  GadDat[GD_TMPDOCFN_STR].GadgetText ="_TmpDocsFileName";
  GadDat[GD_FILERLIB_CYC].GadgetText ="_File Requester";
  GadDat[GD_FONTRLIB_CYC].GadgetText ="F_ont Requester";
  GadDat[GD_EASYRLIB_CYC].GadgetText ="E_asyRequester";
  GadDat[GD_CRICONS_CKB].GadgetText  ="Create _Icons?";
  GadDat[GD_USE_BUT].GadgetText      ="_Use";
  GadDat[GD_CANCEL_BUT].GadgetText   ="_Cancel";

  GadDat[GD_EDITOR_SEL].GadgetText   =sel;
  GadDat[GD_TMPDOCFN_SEL].GadgetText =sel;

  LibLabels[0]                       ="ASL";
  LibLabels[1]                       ="ReqTools";

  EasyRLabels[0]                     ="Intuition";
  EasyRLabels[1]                     ="ReqTools";
  DEBUG_PRINTF("  Gadget-Labels initialized\n");

  /* Gadgetlabel-Breite der Gadgets */
  labw=0;
  for(i=GD_EDITOR_STR;i<=GD_EASYRLIB_CYC;i++)
  {
    tmp=TextLength(&Screen.ps_DummyRPort,GadDat[i].GadgetText,strlen(GadDat[i].GadgetText));
    if (tmp>labw) labw=tmp;
  }
  labw+=INTERWIDTH;
  DEBUG_PRINTF("  labw calculated\n");

  selw=TextLength(&Screen.ps_DummyRPort,sel,strlen(sel))+INTERWIDTH;
  DEBUG_PRINTF("  selw calculated\n");

  strw=Screen.ps_ScrFont->tf_XSize*15;
  tmp=TextLength(&Screen.ps_DummyRPort,LibLabels[0],strlen(LibLabels[0]));
  if (tmp>strw) strw=tmp;
  tmp=TextLength(&Screen.ps_DummyRPort,LibLabels[1],strlen(LibLabels[1]));
  if (tmp>strw) strw=tmp;
  tmp=TextLength(&Screen.ps_DummyRPort,EasyRLabels[0],strlen(EasyRLabels[0]));
  if (tmp>strw) strw=tmp;
  tmp=TextLength(&Screen.ps_DummyRPort,EasyRLabels[1],strlen(EasyRLabels[1]));
  if (tmp>strw) strw=tmp;
  strw+=4*INTERWIDTH;

  butw=TextLength(&Screen.ps_DummyRPort,
                  GadDat[GD_USE_BUT].GadgetText,
                  strlen(GadDat[GD_USE_BUT].GadgetText));

  tmp=TextLength(&Screen.ps_DummyRPort,
                 GadDat[GD_CANCEL_BUT].GadgetText,
                 strlen(GadDat[GD_CANCEL_BUT].GadgetText));

  if (tmp>butw) butw=tmp;
  butw+=3*INTERWIDTH;

  if (2*butw+INTERWIDTH>strw+labw) strw=2*butw+INTERWIDTH-labw;

  /* Größen der Gadgets berechnen */
  left   =Screen.ps_Screen->WBorLeft+INTERWIDTH;
  lableft=left+labw;
  gadh   =Screen.ps_ScrFont->tf_YSize+INTERHEIGHT;
  yadd   =gadh+INTERHEIGHT;
  selstrw=strw-selw;

  DEBUG_PRINTF("  gad-variables calculated\n");

  /* Windowgröße */
  if (AGDPrefsP.MiscSetWTop==~0) AGDPrefsP.MiscSetWTop=Screen.ps_Screen->BarHeight+1;
  Width =labw+strw+2*INTERWIDTH;
  Height=7*yadd+2*INTERHEIGHT+SEPHEIGHT;

  /* alternative Windowgröße */
  WZoom[0]=AGDPrefsP.MiscSetWLeft;
  WZoom[1]=AGDPrefsP.MiscSetWTop;
  WZoom[2]=200;
  WZoom[3]=Screen.ps_Screen->WBorTop+Screen.ps_Screen->Font->ta_YSize+1;
  DEBUG_PRINTF("  Window-Sizes calculated\n");

  top=Screen.ps_Screen->WBorTop+Screen.ps_Screen->Font->ta_YSize+1+INTERHEIGHT;

  /* Editor-String-Gadget */
  gd=&GadDat[GD_EDITOR_STR];
  gd->LeftEdge=lableft;
  gd->TopEdge =top;
  gd->Width   =selstrw;
  gd->Height  =gadh;
  gd->Flags   =PLACETEXT_LEFT;
  gd->GadgetID=GD_EDITOR_STR;
  gd->Type    =STRING_KIND;
  gd->Tags    =EditorTags;

  gd=&GadDat[GD_EDITOR_SEL];
  gd->LeftEdge=lableft+selstrw;
  gd->TopEdge =top;
  gd->Width   =selw;
  gd->Height  =gadh;
  gd->Flags   =PLACETEXT_IN;
  gd->GadgetID=GD_EDITOR_SEL;
  gd->Type    =BUTTON_KIND;
  gd->Tags    =NULL;

  top+=yadd;

  /* TmpDocFN-String-Gadget */
  gd=&GadDat[GD_TMPDOCFN_STR];
  gd->LeftEdge=lableft;
  gd->TopEdge =top;
  gd->Width   =selstrw;
  gd->Height  =gadh;
  gd->Flags   =PLACETEXT_LEFT;
  gd->GadgetID=GD_TMPDOCFN_STR;
  gd->Type    =STRING_KIND;
  gd->Tags    =TmpDocFNTags;

  gd=&GadDat[GD_TMPDOCFN_SEL];
  gd->LeftEdge=lableft+selstrw;
  gd->TopEdge =top;
  gd->Width   =selw;
  gd->Height  =gadh;
  gd->Flags   =PLACETEXT_IN;
  gd->GadgetID=GD_TMPDOCFN_SEL;
  gd->Type    =BUTTON_KIND;
  gd->Tags    =NULL;

  top+=yadd;

  gd=&GadDat[GD_FILERLIB_CYC];
  gd->LeftEdge=lableft;
  gd->TopEdge =top;
  gd->Width   =strw;
  gd->Height  =gadh;
  gd->Flags   =PLACETEXT_LEFT;
  gd->GadgetID=GD_FILERLIB_CYC;
  gd->Type    =CYCLE_KIND;
  gd->Tags    =FileRTags;

  top+=yadd;

  gd=&GadDat[GD_FONTRLIB_CYC];
  gd->LeftEdge=lableft;
  gd->TopEdge =top;
  gd->Width   =strw;
  gd->Height  =gadh;
  gd->Flags   =PLACETEXT_LEFT;
  gd->GadgetID=GD_FONTRLIB_CYC;
  gd->Type    =CYCLE_KIND;
  gd->Tags    =FontRTags;

  top+=yadd;

  gd=&GadDat[GD_EASYRLIB_CYC];
  gd->LeftEdge=lableft;
  gd->TopEdge =top;
  gd->Width   =strw;
  gd->Height  =gadh;
  gd->Flags   =PLACETEXT_LEFT;
  gd->GadgetID=GD_EASYRLIB_CYC;
  gd->Type    =CYCLE_KIND;
  gd->Tags    =EasyRTags;

  top+=yadd;

  gd=&GadDat[GD_CRICONS_CKB];
  gd->LeftEdge=lableft;
  gd->TopEdge =top;
  gd->Width   =CHECKBOX_WIDTH;
  gd->Height  =gadh;
  gd->Flags   =PLACETEXT_LEFT;
  gd->GadgetID=GD_CRICONS_CKB;
  gd->Type    =CHECKBOX_KIND;
  gd->Tags    =CrIconsTags;

  top+=yadd;

  SepD.LeftEdge=left;
  SepD.TopEdge =top;
  SepD.Width   =labw+strw;

  top+=SEPHEIGHT+INTERHEIGHT;

  /* Use-Button-Gadget */
  gd=&GadDat[GD_USE_BUT];
  gd->LeftEdge=left;
  gd->TopEdge =top;
  gd->Width   =butw;
  gd->Height  =gadh;
  gd->Flags   =PLACETEXT_IN;
  gd->GadgetID=GD_USE_BUT;
  gd->Type    =BUTTON_KIND;
  gd->Tags    =NULL;

  /* Cancel-Button-Gadget */
  gd=&GadDat[GD_CANCEL_BUT];
  gd->LeftEdge=left+Width-butw-2*INTERWIDTH;
  gd->TopEdge =top;
  gd->Width   =butw;
  gd->Height  =gadh;
  gd->Flags   =PLACETEXT_IN;
  gd->GadgetID=GD_CANCEL_BUT;
  gd->Type    =BUTTON_KIND;
  gd->Tags    =NULL;

  DEBUG_PRINTF("  Gadgets initialized\n");

  /* VanillaKeys ermittlen */
  VanKeys[KEY_EDITOR_LWR]   =FindVanillaKey(GadDat[GD_EDITOR_STR].GadgetText);
  VanKeys[KEY_EDITOR_UPR]   =toupper(VanKeys[KEY_EDITOR_LWR]);
  VanKeys[KEY_TMPDOCFN_LWR] =FindVanillaKey(GadDat[GD_TMPDOCFN_STR].GadgetText);
  VanKeys[KEY_TMPDOCFN_UPR] =toupper(VanKeys[KEY_TMPDOCFN_LWR]);
  VanKeys[KEY_FILERLIB]     =FindVanillaKey(GadDat[GD_FILERLIB_CYC].GadgetText);
  VanKeys[KEY_FONTRLIB]     =FindVanillaKey(GadDat[GD_FONTRLIB_CYC].GadgetText);
  VanKeys[KEY_EASYRLIB]     =FindVanillaKey(GadDat[GD_EASYRLIB_CYC].GadgetText);
  VanKeys[KEY_CRICONS]      =FindVanillaKey(GadDat[GD_CRICONS_CKB].GadgetText);
  VanKeys[KEY_USE]          =FindVanillaKey(GadDat[GD_USE_BUT].GadgetText);
  VanKeys[KEY_CANCEL]       =FindVanillaKey(GadDat[GD_CANCEL_BUT].GadgetText);
  VanKeys[KEY_NULL]         ='\0';

  DEBUG_PRINTF("  VanillaKeys calculated\n");

  DEBUG_PRINTF("  -- returning --\n\n");
}

/* =================================================================================== CloseMiscSetWin
** schließt das MiscSettingsWindow
*/
void CloseMiscSetWin(void)
{
  DEBUG_PRINTF("\n  -- Invoking CloseMiscSetWin-function --\n");

  if (MiscSetWin)
  {
    /* MenuStrip löschen */
    ClearMenuStrip(MiscSetWin);
    DEBUG_PRINTF("  MenuStrip at MiscSetWin cleared\n");

    /* Window schließen */
    CloseWindow(MiscSetWin);
    MiscSetWin=NULL;
    MiscSetBit=0;
    DEBUG_PRINTF("  MiscSetWin closed\n");

    FreeGadgets(GadList);
    GadList=NULL;
    DEBUG_PRINTF("  GadList freed\n");
  }

  AGDPrefsP.MiscSetWin=FALSE;

  DEBUG_PRINTF("  -- returning --\n\n");
}

/* ==================================================================================== OpenMiscSetWin
** öffnet das MiscSettingsWindow
*/
BOOL OpenMiscSetWin(void)
{
  DEBUG_PRINTF("\n  -- Invoking OpenMiscSetWin-function --\n");

  /* wenn noch nicht geöffnet (könnte mehrmals aufgerufen werden) */
  if (!MiscSetWin)
  {
    RTFileReq=MiscP.RTFileReq;
    RTFontReq=MiscP.RTFontReq;
    RTEasyReq=MiscP.RTEasyReq;

    EditorTags[0].ti_Data  =(ULONG)MiscP.Editor;
    TmpDocFNTags[0].ti_Data=(ULONG)MiscP.TmpDocFileName;
    FileRTags[0].ti_Data   =(ULONG)RTFileReq;
    FontRTags[0].ti_Data   =(ULONG)RTFontReq;
    EasyRTags[0].ti_Data   =(ULONG)RTEasyReq;
    CrIconsTags[0].ti_Data =(ULONG)MiscP.CrIcons;

    if (GadList=CreateGadgetList(GadDat,GDNUM))
    {
      DEBUG_PRINTF("  GadList created\n");

      /* Window öffnen */
      if (MiscSetWin=
          OpenWindowTags(NULL,
                         WA_Left,AGDPrefsP.MiscSetWLeft,
                         WA_Top,AGDPrefsP.MiscSetWTop,
                         WA_InnerWidth,Width,
                         WA_InnerHeight,Height,
                         WA_Title,"Miscellaneous Settings",
                         WA_ScreenTitle,Screen.ps_Title,
                         WA_Gadgets,GadList,
                         WA_IDCMP,BUTTONIDCMP|STRINGIDCMP|IDCMP_MENUPICK|IDCMP_CLOSEWINDOW|\
                                  IDCMP_REFRESHWINDOW|IDCMP_VANILLAKEY,
                         WA_Flags,WFLG_DRAGBAR|WFLG_CLOSEGADGET|WFLG_DEPTHGADGET|\
                                  WFLG_NEWLOOKMENUS|WFLG_ACTIVATE,
                         WA_AutoAdjust,TRUE,
                         WA_Zoom,WZoom,
                         WA_PubScreen,Screen.ps_Screen,
                         TAG_DONE))
      {
        DEBUG_PRINTF("  MiscSetWin opened\n");

        /* MenuStrip ans Window anhängen */
        SetMenuStrip(MiscSetWin,Menus);
        DEBUG_PRINTF("  MenuStrip set at MiscSetWin\n");

        GT_RefreshWindow(MiscSetWin,NULL);
        DrawSeparators(MiscSetWin,&SepD,1);
        DEBUG_PRINTF("  GadList refreshed\n");

        MiscSetBit=1UL<<MiscSetWin->UserPort->mp_SigBit;
        AGDPrefsP.MiscSetWin=TRUE;

        ProgScreenToFront();

        /* Ok zurückgeben */
        DEBUG_PRINTF("  -- returning --\n\n");
        return(TRUE);
      }
      else
        EasyRequestAllWins("Error on opening Miscellaneous Settings Window",
                           "Ok",
                           NULL);
    }
    else
      EasyRequestAllWins("Error on creating gadgets for\n"
                         "Miscellaeous Settings Window",
                         "Ok",
                         NULL);

    DEBUG_PRINTF("  Error\n");
    CloseMiscSetWin();

    DEBUG_PRINTF("  -- returning --\n\n");
    return(FALSE);
  }
  else
  {
    ActivateWindow(MiscSetWin);
    WindowToFront(MiscSetWin);
  }

  DEBUG_PRINTF("  MiscSetWin already opened\n  -- returning --\n\n");
  return(TRUE);
}

/* ================================================================================== GetMiscSetWinPos
** speichert die aktuelle Windowposition in der WinPosP-Struktur ab
*/
void GetMiscSetWinPos(void)
{
  if (MiscSetWin)
  {
    AGDPrefsP.MiscSetWLeft=MiscSetWin->LeftEdge;
    AGDPrefsP.MiscSetWTop =MiscSetWin->TopEdge;
  }
}

/* ================================================================================== UpdateMiscSetWin
** setzt die Gadgets im MiscSetWin auf die Werte im MiscP
*/
void UpdateMiscSetWin(void)
{
  /* wird aus anderen Modulen aufgerufen */
  if (MiscSetWin)
  {
    RTFileReq=MiscP.RTFileReq;
    RTFontReq=MiscP.RTFontReq;
    RTEasyReq=MiscP.RTEasyReq;

    SetStrGad(GD_EDITOR_STR,MiscP.Editor);
    SetStrGad(GD_TMPDOCFN_STR,MiscP.TmpDocFileName);
    SetCycleGad(GD_FILERLIB_CYC,RTFileReq);
    SetCycleGad(GD_FONTRLIB_CYC,RTFontReq);
    SetCycleGad(GD_EASYRLIB_CYC,RTEasyReq);
    SetCheckBoxGad(GD_CRICONS_CKB,MiscP.CrIcons);
  }
}

/* ==================================================================================== CopyMiscSetWin
** kopiert die Werte der Gadgets im MiscSetWin
*/
void CopyMiscSetWin(void)
{
  MiscP.RTFileReq=RTFileReq;
  MiscP.RTFontReq=RTFontReq;
  MiscP.RTEasyReq=RTEasyReq;
  if (GadDat[GD_CRICONS_CKB].Gadget->Flags&GFLG_SELECTED)
    MiscP.CrIcons=TRUE;
  else
    MiscP.CrIcons=FALSE;


  DoStringCopy(&MiscP.Editor,GadDat[GD_EDITOR_STR].Gadget);
  DoStringCopy(&MiscP.TmpDocFileName,GadDat[GD_TMPDOCFN_STR].Gadget);
}

/* ===================================================================================== SetMiscStrGad
** setzt das Misc-String-Gadget im MiscSetWin
*/
static
void SetStrGad(UBYTE gdnum,char *str)
{
  GT_SetGadgetAttrs(GadDat[gdnum].Gadget,
                    MiscSetWin,NULL,
                    GTST_String,str,
                    TAG_DONE);
}

/* ======================================================================================= SetCycleGad
** setzt ein Cycle-Gadget im MiscSetWin
*/
static
void SetCycleGad(UBYTE gdnum,UBYTE active)
{
  GT_SetGadgetAttrs(GadDat[gdnum].Gadget,
                    MiscSetWin,NULL,
                    GTCY_Active,active,
                    TAG_DONE);
}

/* ==================================================================================== SetCheckBoxGad
** setzt ein CheckBox-Gadget im MiscSetWin
*/
static
void SetCheckBoxGad(UBYTE gdnum,BOOL state)
{
  GT_SetGadgetAttrs(GadDat[gdnum].Gadget,
                    MiscSetWin,NULL,
                    GTCB_Checked,state,
                    TAG_DONE);
}

/* ====================================================================================== DoPathSelect
** Pfad-Auswahl per ASL-Requester und autom. Setzen des Windows
*/
static
void DoPathSelect(UBYTE gdnum)
{
  FileRD.Path     =GetString(GadDat[gdnum].Gadget);
  FileRD.Title    ="Pfad wählen";
  FileRD.Flags1   =FRF_DOPATTERNS;
  FileRD.Flags2   =0;

  /* FileRequester öffnen */
  if (OpenFileRequester())
  {
    SetStrGad(gdnum,FileRD.Path);
    if (FileRD.Path) FreeVec(FileRD.Path);
  }
}

/* ================================================================================ HandleMiscSetWinIDCMP
** IDCMP-Message auswerten
*/
void HandleMiscSetWinIDCMP(void)
{
  struct IntuiMessage *imsg;
  struct Gadget *gad;
  ULONG class;
  UWORD code;
  APTR  iaddr;

  DEBUG_PRINTF("\n  -- Invoking HandleMiscSetWinIDCMP-function --\n");

  /* Message auslesen */
  while (MiscSetWin && (imsg=GT_GetIMsg(MiscSetWin->UserPort)))
  {
    DEBUG_PRINTF("  Got Message from MiscSetWin->UserPort\n");

    class=imsg->Class;
    code =imsg->Code;
    iaddr=imsg->IAddress;

    /* antworten */
    GT_ReplyIMsg(imsg);
    DEBUG_PRINTF("  Message replyed\n");

    /* Welche Art Event? */
    switch (class)
    {
      /* muß Window neu gezeichnet werden ? */
      case IDCMP_REFRESHWINDOW:
        GT_BeginRefresh(MiscSetWin);
        DrawSeparators(MiscSetWin,&SepD,1);
        GT_EndRefresh(MiscSetWin,TRUE);
        DEBUG_PRINTF("  MiscSetWin refreshed\n");
        break;

      /* Window geschlossen? */
      case IDCMP_CLOSEWINDOW:
        GetMiscSetWinPos();
        CloseMiscSetWin();
        SetProgMenusStates();
        DEBUG_PRINTF("  MiscSetWin closed\n");

        break;

      /* Menu angewählt? */
      case IDCMP_MENUPICK:
        HandleProgMenus(code);
        DEBUG_PRINTF("  Menus handled\n");
        break;

      /* Gadget angeklickt? */
      case IDCMP_GADGETUP:
      {
        gad=(struct Gadget *)iaddr;

        /* welches Gadget */
        switch (gad->GadgetID)
        {
          case GD_EDITOR_SEL:
            DoPathSelect(GD_EDITOR_STR);
            DEBUG_PRINTF("  GD_EDITOR_SEL processed\n");
            break;

          case GD_TMPDOCFN_SEL:
            DoPathSelect(GD_TMPDOCFN_STR);
            DEBUG_PRINTF("  GD_TMPDOCFN_SEL processed\n");
            break;

          case GD_FILERLIB_CYC:
            RTFileReq=code;
            DEBUG_PRINTF("  GD_FILERLIB_CYC procesed\n");
            break;

          case GD_FONTRLIB_CYC:
            RTFontReq=code;
            DEBUG_PRINTF("  GD_FONTRLIB_CYC procesed\n");
            break;

          case GD_EASYRLIB_CYC:
            RTEasyReq=code;
            DEBUG_PRINTF("  GD_EASYRLIB_CYC procesed\n");
            break;

          case GD_USE_BUT:
            CopyMiscSetWin();
            DEBUG_PRINTF("  GD_USE_BUT processed\n");

          case GD_CANCEL_BUT:
            if (AGDPrefsP.ReqMode)
            {
              GetMiscSetWinPos();
              CloseMiscSetWin();
              SetProgMenusStates();
            }
            else
              UpdateMiscSetWin();

            DEBUG_PRINTF("  GD_CANCEL_BUT processed\n");
            break;
        }

        DEBUG_PRINTF("  Gadgets processed\n");
        break;
      }

      /* VanillaKey? */
      case IDCMP_VANILLAKEY:
      {
        /* welches Gadget */
        switch (MatchVanillaKey(code,VanKeys))
        {
          case KEY_EDITOR_LWR:
            ActivateGadget(GadDat[GD_EDITOR_STR].Gadget,MiscSetWin,NULL);
            DEBUG_PRINTF("  KEY_EDITOR_LWR processed\n");
            break;

          case KEY_EDITOR_UPR:
            DoPathSelect(GD_EDITOR_STR);
            DEBUG_PRINTF("  KEY_EDITOR_UPR processed\n");
            break;

          case KEY_TMPDOCFN_LWR:
            ActivateGadget(GadDat[GD_TMPDOCFN_STR].Gadget,MiscSetWin,NULL);
            DEBUG_PRINTF("  KEY_TMPDOCFN_LWR processed\n");
            break;

          case KEY_TMPDOCFN_UPR:
            DoPathSelect(GD_TMPDOCFN_STR);
            DEBUG_PRINTF("  KEY_TMPDOCFN_UPR processed\n");
            break;

          case KEY_FILERLIB:
            RTFileReq=RTFileReq?0:1;
            SetCycleGad(GD_FILERLIB_CYC,RTFileReq);
            DEBUG_PRINTF("  KEY_FILERLIB processed\n");
            break;

          case KEY_FONTRLIB:
            RTFontReq=RTFontReq?0:1;
            SetCycleGad(GD_FONTRLIB_CYC,RTFontReq);
            DEBUG_PRINTF("  KEY_FONTRLIB processed\n");
            break;

          case KEY_EASYRLIB:
            RTEasyReq=RTEasyReq?0:1;
            SetCycleGad(GD_EASYRLIB_CYC,RTEasyReq);
            DEBUG_PRINTF("  KEY_EASYRLIB processed\n");
            break;

          case KEY_CRICONS:
            SetCheckBoxGad(GD_CRICONS_CKB,!(GadDat[GD_CRICONS_CKB].Gadget->Flags&GFLG_SELECTED));
            DEBUG_PRINTF("  KEY_CRICONS processed\n");
            break;

          case KEY_USE:
            CopyMiscSetWin();
            DEBUG_PRINTF("  KEY_USE processed\n");

          case KEY_CANCEL:
            if (AGDPrefsP.ReqMode)
            {
              GetMiscSetWinPos();
              CloseMiscSetWin();
              SetProgMenusStates();
            }
            else
              UpdateMiscSetWin();

            DEBUG_PRINTF("  KEY_CANCEL processed\n");
            break;
        }

        DEBUG_PRINTF("  VanillaKeys processed\n");
        break;
      }
    }
  }

  /* Programm beendet? */
  DEBUG_PRINTF("  -- returning --\n\n");
}

/* ======================================================================================= End of File
*/
