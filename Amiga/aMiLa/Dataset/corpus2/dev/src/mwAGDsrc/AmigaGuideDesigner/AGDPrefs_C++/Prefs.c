/*
** PROGRAMM:  AmigaGuideDesigner Preferences
** AUTOR:     Michael Weiser
** COPYRIGHT: ©1994 Michael Weiser (Giftware)
** COMPILER:  SAS/C 6.5
**
** MODUL:     Prefs.c
** FUNKTION:  Preferences-Routinen für AmigaGuideDesigner
**
*/

/*#define DEBUG*/
#include "AGDPrefs.h"

struct AGDPrefsP   AGDPrefsP;
struct ProjP       ProjP;
struct DocsP       DocsP;
struct CommP       CommP;
struct MiscP       MiscP;
struct ScrP        ScrP;

char              *PrefsName,*PrefsNameEnv,*PrefsNameEnvArc;

#define ID_AGDP MAKE_ID('A','G','D','P')

static LONG PrChunks[]={ID_PREF,ID_PRHD,
                        ID_PREF,ID_AGDP};

#define STRNUM 22

static char      **AGDPStrs[STRNUM];

struct AGDPVars {
                 UWORD          FontSize;
                 BOOL           WordWrap;
                 ULONG          Reserved2;

                 ULONG          CommTypeLVRows;
                 UBYTE          CommType;
                 UBYTE          CommFGPen;
                 UBYTE          CommBGPen;
                 UBYTE          CommStyle;
                 UWORD          Reserved3;

                 BOOL           CrIcons;
                 BOOL           RTFileReq;
                 BOOL           RTFontReq;
                 BOOL           RTEasyReq;
                 UWORD          Reserved4;

                 BOOL           CustomScreen;
                 ULONG          ScrDisplayID;
                 ULONG          ScrWidth;
                 ULONG          ScrHeight;
                 UWORD          ScrDepth;
                 UWORD          ScrOverscan;
                 BOOL           ScrAutoScroll;
                 ULONG          Reserved5[2];
                 UWORD          PrintAttrYSize;
                 UBYTE          PrintAttrStyle;
                 UBYTE          PrintAttrFlags;
                 UWORD          ScrAttrYSize;
                 UBYTE          ScrAttrStyle;
                 UBYTE          ScrAttrFlags;
                };

/* ====================================================================================== InitAGDPrefs
** setzt die AGDPrefs-Struktur-Elemente auf NULL
*/
void InitAGDPrefs(void)
{
  DEBUG_PRINTF("\n  -- Invoking InitAGDPrefs-function --\n");

  PrefsName              =NULL;
  PrefsNameEnv           ="ENV:AGD.prefs";
  PrefsNameEnvArc        ="ENVARC:AGD.prefs";

  AGDPrefsP.MainWin      =TRUE;
  AGDPrefsP.MainWLeft    =0;
  AGDPrefsP.MainWTop     =~0;
  AGDPrefsP.ProjSetWin   =FALSE;
  AGDPrefsP.ProjSetWLeft =0;
  AGDPrefsP.ProjSetWTop  =~0;
  AGDPrefsP.DocsSetWin   =FALSE;
  AGDPrefsP.DocsSetWLeft =0;
  AGDPrefsP.DocsSetWTop  =~0;
  AGDPrefsP.CommSetWin   =FALSE;
  AGDPrefsP.CommSetWLeft =0;
  AGDPrefsP.CommSetWTop  =~0;
  AGDPrefsP.MiscSetWin   =FALSE;
  AGDPrefsP.MiscSetWLeft =0;
  AGDPrefsP.MiscSetWTop  =~0;
  AGDPrefsP.ScrSetWin    =FALSE;
  AGDPrefsP.ScrSetWLeft  =0;
  AGDPrefsP.ScrSetWTop   =~0;

  AGDPrefsP.FileRLeft    =~0;
  AGDPrefsP.FileRTop     =~0;
  AGDPrefsP.FileRWidth   =~0;
  AGDPrefsP.FileRHeight  =~0;
  AGDPrefsP.FontRLeft    =~0;
  AGDPrefsP.FontRTop     =~0;
  AGDPrefsP.FontRWidth   =~0;
  AGDPrefsP.FontRHeight  =~0;
  AGDPrefsP.ScrMRLeft    =~0;
  AGDPrefsP.ScrMRTop     =~0;
  AGDPrefsP.ScrMRWidth   =~0;
  AGDPrefsP.ScrMRHeight  =~0;
  AGDPrefsP.ListRLeft    =30;
  AGDPrefsP.ListRTop     =20;
  AGDPrefsP.ListRWidth   =100;
  AGDPrefsP.ListRHeight  =200;

  AGDPrefsP.CrIcons      =FALSE;
  AGDPrefsP.ReqMode      =FALSE;

  AGDPrefsP.RTFileReq    =FALSE;
  AGDPrefsP.RTFontReq    =FALSE;
  AGDPrefsP.RTScrMReq    =FALSE;
  AGDPrefsP.RTEasyReq    =FALSE;

  AGDPrefsP.DefaultFont  =FALSE;

  AGDPrefsP.Pattern      =mstrdup("~(#?.info)");
  AGDPrefsP.PubScreenName=NULL;

  DEBUG_PRINTF("  -- returning --\n\n");
}

/* ====================================================================================== FreeAGDPrefs
** gibt die AGDPrefs-Struktur frei
*/
void FreeAGDPrefs(void)
{
  DEBUG_PRINTF("\n  -- Invoking FreeAGDPrefs-function --\n");

  if (AGDPrefsP.Pattern)
  {
    FreeVec(AGDPrefsP.Pattern);
    DEBUG_PRINTF("  AGDPrefsP.Pattern freed\n");
  }

  if (AGDPrefsP.PubScreenName)
  {
    FreeVec(AGDPrefsP.PubScreenName);
    DEBUG_PRINTF("  AGDPrefsP.PubScreenName freed\n");
  }

  if (PrefsName)
  {
    FreeVec(PrefsName);
    DEBUG_PRINTF("  PrefsName freed\n");
  }

  DEBUG_PRINTF("  -- returning --\n\n");
}

/* ========================================================================================= InitPrefs
** setzt die Prefs-Struktur-Elemente auf Null
*/
void InitPrefs(void)
{
  DEBUG_PRINTF("\n  -- Invoking InitPrefs-function --\n");

  ProjP.AGuidePath       =NULL;
  ProjP.Database         =NULL;
  ProjP.Master           =NULL;
  ProjP.Copyright        =NULL;
  ProjP.Index            =NULL;
  ProjP.Author           =NULL;
  ProjP.Version          =NULL;
  ProjP.FontName         =NULL;
  ProjP.Help             =NULL;
  ProjP.FontSize         =8;
  ProjP.WordWrap         =FALSE;

  DocsP.NodeName         =mstrdup("New Document");
  DocsP.WinTitle         =NULL;
  DocsP.NextNodeName     =NULL;
  DocsP.PrevNodeName     =NULL;
  DocsP.TOCNodeName      =NULL;
  DocsP.FileName         =NULL;

  CommP.CommTypeLVRows   =8;
  CommP.CommType         =COMT_LINK;
  CommP.FGPen            =COL_TEXT;
  CommP.BGPen            =COL_BG;
  CommP.Style            =FS_NORMAL;
  CommP.StrData          =NULL;

  MiscP.Editor           =mstrdup("run ed \"%\"");
  MiscP.TmpDocFileName   =mstrdup("T:AGDEditDoc");
  MiscP.CrIcons          =FALSE;
  MiscP.RTFileReq        =FALSE;
  MiscP.RTFontReq        =FALSE;
  MiscP.RTEasyReq        =FALSE;
  MiscP.Pattern          =mstrdup("~(#?.info)");

  ScrP.CustomScreen      =FALSE;
  ScrP.DisplayID         =HIRES_KEY;
  ScrP.Width             =STDSCREENWIDTH;
  ScrP.Height            =STDSCREENHEIGHT;
  ScrP.Depth             =2;
  ScrP.Overscan          =OSCAN_TEXT;
  ScrP.AutoScroll        =TRUE;
  ScrP.PubScreenName     =NULL;
  ScrP.PrintAttr.ta_Name =mstrdup(GfxBase->DefaultFont->tf_Message.mn_Node.ln_Name);
  ScrP.PrintAttr.ta_YSize=GfxBase->DefaultFont->tf_YSize;
  ScrP.PrintAttr.ta_Style=GfxBase->DefaultFont->tf_Style;
  ScrP.PrintAttr.ta_Flags=GfxBase->DefaultFont->tf_Flags;
  ScrP.ScrAttr.ta_Name   =mstrdup(GfxBase->DefaultFont->tf_Message.mn_Node.ln_Name);
  ScrP.ScrAttr.ta_YSize  =GfxBase->DefaultFont->tf_YSize;
  ScrP.ScrAttr.ta_Style  =GfxBase->DefaultFont->tf_Style;
  ScrP.ScrAttr.ta_Flags  =GfxBase->DefaultFont->tf_Flags;

  DEBUG_PRINTF("  all elements set\n");

  AGDPStrs[0] =&ProjP.AGuidePath;
  AGDPStrs[1] =&ProjP.Database;
  AGDPStrs[2] =&ProjP.Copyright;
  AGDPStrs[3] =&ProjP.Master;
  AGDPStrs[4] =&ProjP.Index;
  AGDPStrs[5] =&ProjP.Author;
  AGDPStrs[6] =&ProjP.Version;
  AGDPStrs[7] =&ProjP.FontName;
  AGDPStrs[8] =&ProjP.Help;

  AGDPStrs[9] =&DocsP.NodeName;
  AGDPStrs[10]=&DocsP.WinTitle;
  AGDPStrs[11]=&DocsP.NextNodeName;
  AGDPStrs[12]=&DocsP.PrevNodeName;
  AGDPStrs[13]=&DocsP.TOCNodeName;
  AGDPStrs[14]=&DocsP.FileName;

  AGDPStrs[15]=&CommP.StrData;

  AGDPStrs[16]=&MiscP.Editor;
  AGDPStrs[17]=&MiscP.TmpDocFileName;
  AGDPStrs[18]=&MiscP.Pattern;

  AGDPStrs[19]=&ScrP.PubScreenName;
  AGDPStrs[20]=&ScrP.ScrAttr.ta_Name;
  AGDPStrs[21]=&ScrP.PrintAttr.ta_Name;

  DEBUG_PRINTF("  -- returning --\n\n");
}

/* ========================================================================================= FreePrefs
** gibt die Prefs-Struktur frei
*/
void FreePrefs(void)
{
  DEBUG_PRINTF("\n  -- Invoking FreePrefs-function --\n");

  if (ProjP.AGuidePath)
  {
    FreeVec(ProjP.AGuidePath);
    DEBUG_PRINTF("  ProjP.AGuidePath freed\n");
  }

  if (ProjP.Database)
  {
    FreeVec(ProjP.Database);
    DEBUG_PRINTF("  ProjP.Database freed\n");
  }

  if (ProjP.Master)
  {
    FreeVec(ProjP.Master);
    DEBUG_PRINTF("  ProjP.Master freed\n");
  }

  if (ProjP.Copyright)
  {
    FreeVec(ProjP.Copyright);
    DEBUG_PRINTF("  ProjP.Copyright freed\n");
  }

  if (ProjP.Index)
  {
    FreeVec(ProjP.Index);
    DEBUG_PRINTF("  ProjP.Index freed\n");
  }

  if (ProjP.Author)
  {
    FreeVec(ProjP.Author);
    DEBUG_PRINTF("  ProjP.Author freed\n");
  }

  if (ProjP.Version)
  {
    FreeVec(ProjP.Version);
    DEBUG_PRINTF("  ProjP.Version freed\n");
  }

  if (ProjP.FontName)
  {
    FreeVec(ProjP.FontName);
    DEBUG_PRINTF("  ProjP.FontName freed\n");
  }

  if (ProjP.Help)
  {
    FreeVec(ProjP.Help);
    DEBUG_PRINTF("  ProjP.Help freed\n");
  }

  if (DocsP.NodeName)
  {
    FreeVec(DocsP.NodeName);
    DEBUG_PRINTF("  DocsP.NodeName freed\n");
  }

  if (DocsP.WinTitle)
  {
    FreeVec(DocsP.WinTitle);
    DEBUG_PRINTF("  DocsP.WinTitle freed\n");
  }

  if (DocsP.NextNodeName)
  {
    FreeVec(DocsP.NextNodeName);
    DEBUG_PRINTF("  DocsP.NextNodeName freed\n");
  }

  if (DocsP.PrevNodeName)
  {
    FreeVec(DocsP.PrevNodeName);
    DEBUG_PRINTF("  DocsP.PrevNodeName freed\n");
  }

  if (DocsP.TOCNodeName)
  {
    FreeVec(DocsP.TOCNodeName);
    DEBUG_PRINTF("  DocsP.TOCNodeName freed\n");
  }

  if (DocsP.FileName)
  {
    FreeVec(DocsP.FileName);
    DEBUG_PRINTF("  DocsP.FileName freed\n");
  }

  if (CommP.StrData)
  {
     FreeVec(CommP.StrData);
     DEBUG_PRINTF("  CommP.StrData freed\n");
   }

  if (MiscP.Editor)
  {
    FreeVec(MiscP.Editor);
    DEBUG_PRINTF("  MiscP.Editor freed\n");
  }

  if (MiscP.TmpDocFileName)
  {
    FreeVec(MiscP.TmpDocFileName);
    DEBUG_PRINTF("  MiscP.TmpDocFileName freed\n");
  }

  if (MiscP.Pattern)
  {
    FreeVec(MiscP.Pattern);
    DEBUG_PRINTF("  MiscP.Pattern freed\n");
  }

  if (ScrP.PrintAttr.ta_Name)
  {
    FreeVec(ScrP.PrintAttr.ta_Name);
    DEBUG_PRINTF("  ScrP.PrintAttr.ta_Name freed\n");
  }

  if (ScrP.ScrAttr.ta_Name)
  {
    FreeVec(ScrP.ScrAttr.ta_Name);
    DEBUG_PRINTF("  ScrP.ScrAttr.ta_Name freed\n");
  }

  if (ScrP.PubScreenName)
  {
    FreeVec(ScrP.PubScreenName);
    DEBUG_PRINTF("  ScrP.PubScreenName freed\n");
  }

  DEBUG_PRINTF("  -- returning --\n\n");
}

/* ========================================================================================= LoadPrefs
** lädt die Prefs
*/
BOOL LoadPrefs(char *pfile)
{
  BOOL  rc=TRUE;
  struct IFFHandle   *iff;

  DEBUG_PRINTF("\n  -- Invoking LoadPrefs-function --\n");

  /* IFFHandle anfordern */
  if (iff=AllocIFF())
  {
    DEBUG_PRINTF("    iff allocated\n");

    /* File öffnen */
    if (iff->iff_Stream=Open(pfile,MODE_OLDFILE))
    {
      DEBUG_PRINTF("    iff->iff_Stream opened\n");

      /* als DOS-Stream initialisieren */
      InitIFFasDOS(iff);
      DEBUG_PRINTF("    iff initialized as DOS\n");

      /* Iff öffnen */
      if (!OpenIFF(iff,IFFF_READ))
      {
        DEBUG_PRINTF("    iff opened with IFFF_READ\n");

        if (!ParseIFF(iff,IFFPARSE_STEP))
        {
          struct ContextNode    *cn;

          DEBUG_PRINTF("    first chunk parsed\n");

          if ((cn=CurrentChunk(iff)) && (cn->cn_ID==ID_FORM) && (cn->cn_Type==ID_PREF) &&
              !PropChunks(iff,PrChunks,2) &&
              !StopOnExit(iff,ID_PREF,ID_FORM) &&
              ParseIFF(iff,IFFPARSE_SCAN)==IFFERR_EOC)
          {
            struct StoredProperty *sp;

            DEBUG_PRINTF("    first chunk is ID_PREF+ID_FORM\n    PropChunks() and StopOnExit() set\n    iff parsed with IFFPARSE_SCAN\n");

            if ((sp=FindProp(iff,ID_PREF,ID_PRHD)) &&
                ((struct PrefHeader *)sp->sp_Data)->ph_Version==PREFSVERSION &&
                (sp=FindProp(iff,ID_PREF,ID_AGDP)))
            {
              struct AGDPVars *av=(struct AGDPVars *)sp->sp_Data;
              ULONG  i;
              char  *ptr;

              DEBUG_PRINTF("    ph_Version==PREFSVERSION\n    chunk ID_PREF+ID_AGDP found\n");

              ProjP.FontSize         =av->FontSize;
              ProjP.WordWrap         =av->WordWrap;

              CommP.CommTypeLVRows   =av->CommTypeLVRows;
              CommP.CommType         =av->CommType;
              CommP.FGPen            =av->CommFGPen;
              CommP.BGPen            =av->CommBGPen;
              CommP.Style            =av->CommStyle;

              MiscP.CrIcons          =av->CrIcons;
              MiscP.RTFileReq        =av->RTFileReq;
              MiscP.RTFontReq        =av->RTFontReq;
              MiscP.RTEasyReq        =av->RTEasyReq;

              ScrP.CustomScreen      =av->CustomScreen;
              ScrP.DisplayID         =av->ScrDisplayID;
              ScrP.Width             =av->ScrWidth;
              ScrP.Height            =av->ScrHeight;
              ScrP.Depth             =av->ScrDepth;
              ScrP.Overscan          =av->ScrOverscan;
              ScrP.AutoScroll        =av->ScrAutoScroll;
              ScrP.PrintAttr.ta_YSize=av->PrintAttrYSize;
              ScrP.PrintAttr.ta_Style=av->PrintAttrStyle;
              ScrP.PrintAttr.ta_Flags=av->PrintAttrFlags;
              ScrP.ScrAttr.ta_YSize  =av->ScrAttrYSize;
              ScrP.ScrAttr.ta_Style  =av->ScrAttrStyle;
              ScrP.ScrAttr.ta_Flags  =av->ScrAttrFlags;
              DEBUG_PRINTF("    vars read\n");

              ptr=(char *)sp->sp_Data+sizeof(struct AGDPVars);
              for (i=0;i<STRNUM;i++)
              {
                if (*AGDPStrs[i]) FreeVec(*AGDPStrs[i]);
                *AGDPStrs[i]=mstrdup(ptr);
                ptr+=strlen(ptr)+1;
              }
              DEBUG_PRINTF("    strings read\n");
            }
            else
            {
              DEBUG_PRINTF("    ph_Version!=PREFSVERSION or ID_PREF+ID_AGDP not found\n");
              rc=FALSE;
            }
          }
          else
          {
            DEBUG_PRINTF("    first chunk not ID_PREF+ID_FORM or error on setting PropChunks() and StopOnExit() or ParseIff()!=IFFERR_EOC\n");
            rc=FALSE;
          }
        }
        else
        {
          rc=FALSE;
          DEBUG_PRINTF("    error on parsing ID_PREF,ID_PRHD\n");
        }

        /* IFF schließen */
        CloseIFF(iff);
        DEBUG_PRINTF("    iff closed\n");
      }
      else
      {
        DEBUG_PRINTF("    error on opening iff\n");
        rc=FALSE;
      }

      /* File schließen */
      Close(iff->iff_Stream);
      DEBUG_PRINTF("    iff->iff_Stream closed\n");
    }
    else
    {
      DEBUG_PRINTF("    error on opening iff->iff_Stream\n");
      rc=FALSE;
    }

    /* IFFHandle freigeben */
    FreeIFF(iff);
    DEBUG_PRINTF("    iff freed\n");
  }
  else
  {
    DEBUG_PRINTF("    error on allocating iff\n");
    rc=FALSE;
  }

  DEBUG_PRINTF("  -- returning --\n\n");
  return(rc); 
}
    
/* ========================================================================================= SavePrefs
** speichert die Prefs
*/
BOOL SavePrefs(char *pfile)
{
  BOOL   rc=TRUE;
  struct IFFHandle  *iff;
  struct DiskObject *dobj;

  DEBUG_PRINTF("\n  -- Invoking SavePrefs-function --\n");

  /* IFFHandle anfordern */
  if (iff=AllocIFF())
  {
    DEBUG_PRINTF("    iff allocated\n");

    /* File öffnen */
    if (iff->iff_Stream=Open(pfile,MODE_NEWFILE))
    {
      DEBUG_PRINTF("    iff->iff_Stream opened\n");

      /* als DOS-Stream initialisieren */
      InitIFFasDOS(iff);
      DEBUG_PRINTF("    iff initialized as DOS\n");

      /* IFF öffnen */
      if (!OpenIFF(iff,IFFF_WRITE))
      {
        DEBUG_PRINTF("    iff opened with IFFF_WRITE\n");

        if (!PushChunk(iff,ID_PREF,ID_FORM,IFFSIZE_UNKNOWN))
        {
          DEBUG_PRINTF("    chunk ID_PREF,ID_FORM pushed with IFFSIZE_UNKNOWN\n");

          if (!PushChunk(iff,ID_PREF,ID_PRHD,IFFSIZE_UNKNOWN))
          {
            struct PrefHeader ph={PREFSVERSION,0,0};

            DEBUG_PRINTF("    chunk ID_PREF+ID_PRHD pushed with IFFSIZE_UNKNOWN\n");

            if (WriteChunkBytes(iff,&ph,sizeof(struct PrefHeader))==sizeof(struct PrefHeader) &&
                !PopChunk(iff))
            {
              char  *buf,*ptr;
              ULONG  bufsize;
              ULONG  i;

              DEBUG_PRINTF("    ID_PREF+ID_PRHD-data written\n");

              bufsize=sizeof(struct AGDPVars);
              for (i=0;i<=STRNUM;i++)
                if (*AGDPStrs[i])
                  bufsize+=strlen(*AGDPStrs[i])+1;
                else
                  bufsize+=1;

              DEBUG_PRINTF("    bufsize calculated\n");

              if (buf=(char *)
                  AllocMem(bufsize,MEMF_ANY|MEMF_PUBLIC|MEMF_CLEAR))
              {
                struct AGDPVars *av=(struct AGDPVars *)buf;
                DEBUG_PRINTF("    buf allocated\n");

                av->FontSize      =ProjP.FontSize;
                av->WordWrap      =ProjP.WordWrap;

                av->CommTypeLVRows=CommP.CommTypeLVRows;
                av->CommType      =CommP.CommType;
                av->CommFGPen     =CommP.FGPen;
                av->CommBGPen     =CommP.BGPen;
                av->CommStyle     =CommP.Style;

                av->CrIcons       =MiscP.CrIcons;
                av->RTFileReq     =MiscP.RTFileReq;
                av->RTFontReq     =MiscP.RTFontReq;
                av->RTEasyReq     =MiscP.RTEasyReq;

                av->CustomScreen  =ScrP.CustomScreen;
                av->ScrDisplayID  =ScrP.DisplayID;
                av->ScrWidth      =ScrP.Width;
                av->ScrHeight     =ScrP.Height;
                av->ScrDepth      =ScrP.Depth;
                av->ScrOverscan   =ScrP.Overscan;
                av->ScrAutoScroll =ScrP.AutoScroll;
                av->PrintAttrYSize=ScrP.PrintAttr.ta_YSize;
                av->PrintAttrStyle=ScrP.PrintAttr.ta_Style;
                av->PrintAttrFlags=ScrP.PrintAttr.ta_Flags;
                av->ScrAttrYSize  =ScrP.ScrAttr.ta_YSize;
                av->ScrAttrStyle  =ScrP.ScrAttr.ta_Style;
                av->ScrAttrFlags  =ScrP.ScrAttr.ta_Flags;
                DEBUG_PRINTF("    vars copied to buf\n");

                ptr=buf+sizeof(struct AGDPVars);
                for (i=0;i<STRNUM;i++)
                {
                  strcpy(ptr,*AGDPStrs[i]);
                  ptr+=strlen(ptr)+1;
                }
                DEBUG_PRINTF("    strings copied to buf\n");

                if (!PushChunk(iff,ID_PREF,ID_AGDP,IFFSIZE_UNKNOWN))
                {
                  DEBUG_PRINTF("    chunk ID_PREF,ID_AGDP pushed with IFFSIZE_UNKNOWN\n");

                  if (WriteChunkBytes(iff,buf,bufsize)!=bufsize || PopChunk(iff))
                  {
                    DEBUG_PRINTF("    error on writing buf to chunk ID_AGDP\n");
                    rc=FALSE;
                  }
                }
                else
                {
                  DEBUG_PRINTF("    error on pushing chunk ID_PREF,ID_AGDP\n");
                  rc=FALSE;
                }

                FreeMem(buf,bufsize);
              }
              else
              {
                DEBUG_PRINTF("    error on allocating buf\n");
                rc=FALSE; 
              }
            }
            else
            {
              DEBUG_PRINTF("    error on writing chunk ID_PRHD\n");
              rc=FALSE;
            }
          }
          else
          {
            DEBUG_PRINTF("    error on pushing chunk ID_PREF,ID_PRHD\n");
            rc=FALSE;
          }

          if (PopChunk(iff))
          {
            rc=FALSE;
            DEBUG_PRINTF("    error on poping chunk ID_PREF,ID_FORM\n");
          }
        }
        else
        {
          DEBUG_PRINTF("    error on pushing chunk ID_PREF,ID_FORM\n");
          rc=FALSE;
        }

        /* IFF schließen */
        CloseIFF(iff);
        DEBUG_PRINTF("    iff closed\n");
      }
      else
      {
        rc=FALSE;
        DEBUG_PRINTF("    error on opening iff\n");
      }

      /* File schließen */
      Close(iff->iff_Stream);
      DEBUG_PRINTF("    iff->iff_Stream closed\n");
    }
    else
    {
      rc=FALSE;
      DEBUG_PRINTF("    error on opening iff->iff_Stream\n");
    }

    /* IFFHandle freigeben */
    FreeIFF(iff);
    DEBUG_PRINTF("    iff freed\n");
  }
  else
  {
    DEBUG_PRINTF("    error on allocating iff\n");
    rc=FALSE;
  }

  /* Icon anlegen? */
  if (AGDPrefsP.CrIcons)
  {
    /* Project-DefaultIcon anfordern */
    if (dobj=GetDefDiskObject(WBPROJECT))
    {
      char *olddeftool=dobj->do_DefaultTool;

      DEBUG_PRINTF("    dobj got (default icon for WBPROJECT)\n");

      dobj->do_DefaultTool="AGDPrefs";

      /* Icon speichern */
      if (!PutDiskObject(pfile,dobj))
      {
        rc=FALSE;
        DEBUG_PRINTF("    error on putting dobj to pfile.info\n");
      }

      /* wieder auf Original zurücksetzen */
      dobj->do_DefaultTool=olddeftool;

      /* Icon freigeben */
      FreeDiskObject(dobj);
      DEBUG_PRINTF("    dobj freed\n");
    }
    else
    {
      rc=FALSE;
      DEBUG_PRINTF("    error on getting dobj\n");
    }
  }

  DEBUG_PRINTF("  -- returning --\n\n");
  return(rc); 
}
  
/* ======================================================================================= End of File
*/
