/*
** PROGRAMM:  AmigaGuideDesigner Preferences
** AUTOR:     Michael Weiser
** COPYRIGHT: ©1994 Michael Weiser (Giftware)
** COMPILER:  SAS/C 6.5
**
** MODUL:     ReqFuncs.c
** FUNKTION:  Requester-Funktionen
**            (File-, Easy-, Font-, ScreenModeRequester etc.)
**
*/

/*#define DEBUG*/
#include "AGDPrefs.h"

struct FileRD      FileRD  ={0};
struct FontRD      FontRD  ={0};
struct ScreenRD    ScreenRD={0};

/* ================================================================================= OpenFileRequester
** ASL-FileRequester
*/
BOOL OpenFileRequester(void)
{
  BOOL    rc=TRUE;
  char   *oldfile   =NULL;
  char   *olddrawer =NULL;
  ULONG   len;

  DEBUG_PRINTF("\n    -- Invoking OpenFileRequester-function --\n");

  /* Alten Pfad in File und Drawer aufspalten */
  oldfile=FilePart(FileRD.Path);
  len    =strlen(FileRD.Path)-strlen(oldfile);
  DEBUG_PRINTF("    len calculated\n");

  /* speicher für altes Directory anfordern */
  if (olddrawer=(char *)AllocVec(len+1,MEMF_ANY|MEMF_PUBLIC|MEMF_CLEAR))
  {
    DEBUG_PRINTF("    oldrawer allocated\n");

    if (len>1) strncpy(olddrawer,FileRD.Path,len);
    olddrawer[len]='\0';
    DEBUG_PRINTF("    Directory-Part of FileRD.Path copied to olddrawer\n");

    /* ReqTools order ASL? */
    if (AGDPrefsP.RTFileReq)
    {
      struct rtFileRequester *freq;

      DEBUG_PRINTF("  using ReqTools for displaying requester\n");

      /* FileRequester initialisieren */
      if (ReqToolsBase &&
          (freq=rtAllocRequestA(RT_FILEREQ,NULL)))
      {
        char *file;
        ULONG len;
        struct ReqDefaults *fp=&ReqToolsBase->ReqToolsPrefs.ReqDefaults[RTPREF_FILEREQ];

        DEBUG_PRINTF("  freq allocated\n");

        /* Directory und Pattern setzen */
        rtChangeReqAttr(freq,
                        RTFI_Dir,olddrawer,
                        RTFI_MatchPat,AGDPrefsP.Pattern,
                        TAG_DONE);

        DEBUG_PRINTF("  olddrawer & FileRD.Pattern set in freq\n");

        len=strlen(oldfile);
        if (len<120) len=120;

        DEBUG_PRINTF("  len calculated\n");

        /* Speicher für extra Dateinamen anfordern, da
        ** ReqTools mindesten 108 buchstaben braucht und
        ** den Puffer verändert */
        if (file=(char *)
            AllocVec(len,MEMF_ANY|MEMF_PUBLIC))
        {
          ULONG flags=0;

          DEBUG_PRINTF("  file allocated\n");

          strcpy(file,oldfile);

          /* Flags `übersetzen` */
          if (FileRD.Flags1&FRF_DOSAVEMODE) flags|=FREQF_SAVE;
          if (FileRD.Flags1&FRF_DOPATTERNS) flags|=FREQF_PATGAD;

          /* Window sperren */
          DisableAllWindows();
          DEBUG_PRINTF("    all Windows disabled\n");

          /* Requester öffnen */
          if (rtFileRequest(freq,file,FileRD.Title,
                            RT_Window,GetValidWindow(),
                            RT_ReqPos,fp->ReqPos,
                            RT_LeftOffset,fp->LeftOffset,
                            RT_TopOffset,fp->TopOffset,
                            RT_ScreenToFront,TRUE,
                            RT_TextAttr,&Screen.ps_ScrAttr,
                            RTFI_Flags,flags,
                            RTFI_AllowEmpty,TRUE,
                            TAG_DONE))
          {
            DEBUG_PRINTF("  freq opened\n");

            /* wieder kompletten Pfad bauen */
            len=strlen(freq->Dir)+strlen(file)+10;
            DEBUG_PRINTF("    len calculated\n");

            /* Speicher für neuen Pfad anfordern */
            if (FileRD.Path=(char *)
                AllocVec(len,MEMF_ANY|MEMF_PUBLIC|MEMF_CLEAR))
            {
              DEBUG_PRINTF("    memory for FileRD.Path allocated\n");

              /* Directory und Dateinamen verbinden */
              strcpy(FileRD.Path,freq->Dir);
              AddPart(FileRD.Path,file,len);
              DEBUG_PRINTF("    FileRD.Path built\n");
            }
            else
            {
              EasyRequestAllWins("Error on allocating memory for"
                                 "building the new path",
                                 "Ok",
                                 NULL);
              rc=FALSE;
            }
          }
          else
            rc=FALSE;

          /* neues Pattern kopieren */
          if (AGDPrefsP.Pattern) FreeVec(AGDPrefsP.Pattern);
          AGDPrefsP.Pattern=mstrdup(freq->MatchPat);

          /* Window freigeben */
          EnableAllWindows();
          DEBUG_PRINTF("    all Windows enabled\n");

          /* extra puffer freigeben */
          FreeVec(file);
          DEBUG_PRINTF("  file freed\n");
        }
        else
          rc=FALSE;

        /* freq-Struktur freigeben */
        rtFreeRequest(freq);
        DEBUG_PRINTF("  freq freed\n");
      }
      else
      {
        EasyRequestAllWins("Error on creating the RTFileRequester","Ok",NULL);
        rc=FALSE;
      }
    }
    else
    {
      struct FileRequester *freq;

      DEBUG_PRINTF("  using ASL for displaying requester\n");

      /* FileRequester initialisieren */
      if (AslBase &&
          (freq=(struct FileRequester *)
           AllocAslRequestTags(ASL_FileRequest,
                               ASLFR_Window,GetValidWindow(),
                               ASLFR_TitleText,FileRD.Title,
                               ASLFR_InitialFile,oldfile,
                               ASLFR_InitialDrawer,olddrawer,
                               ASLFR_InitialPattern,AGDPrefsP.Pattern,
                               ASLFR_Flags1,FileRD.Flags1,
                               ASLFR_Flags2,FileRD.Flags2,
                               ASLFR_TextAttr,&Screen.ps_ScrAttr,
                               TAG_DONE)))
      {
        DEBUG_PRINTF("    freq allocated\n");

        /* Window sperren */
        DisableAllWindows();
        DEBUG_PRINTF("    all Windows disabled\n");

        /* Standard-Größe besorgen */
        if (AGDPrefsP.FileRLeft==~0)   AGDPrefsP.FileRLeft  =freq->fr_LeftEdge;
        if (AGDPrefsP.FileRTop==~0)    AGDPrefsP.FileRTop   =freq->fr_TopEdge;
        if (AGDPrefsP.FileRWidth==~0)  AGDPrefsP.FileRWidth =freq->fr_Width;
        if (AGDPrefsP.FileRHeight==~0) AGDPrefsP.FileRHeight=freq->fr_Height;

        /* FileRequester aufrufen */
        if (AslRequestTags(freq,
                           ASLFR_InitialLeftEdge,AGDPrefsP.FileRLeft,
                           ASLFR_InitialTopEdge,AGDPrefsP.FileRTop,
                           ASLFR_InitialWidth,AGDPrefsP.FileRWidth,
                           ASLFR_InitialHeight,AGDPrefsP.FileRHeight,
                           TAG_DONE))
        {
          DEBUG_PRINTF("    Requester opened\n");

          /* wieder kompletten Pfad bauen */
          len=strlen(freq->fr_Drawer)+strlen(freq->fr_File)+10;
          DEBUG_PRINTF("    len calculated\n");

          if (FileRD.Path=(char *)AllocVec(len,MEMF_ANY|MEMF_PUBLIC|MEMF_CLEAR))
          {
            DEBUG_PRINTF("    memory for FileRD.Path allocated\n");

            /* Dir und Dateinamen zusammenfügen */
            strcpy(FileRD.Path,freq->fr_Drawer);
            AddPart(FileRD.Path,freq->fr_File,len);
            DEBUG_PRINTF("    FileRD.Path built\n");
          }
          else
          {
            EasyRequestAllWins("Error on allocating memory for\n"
                               "building the new path",
                               "Ok",NULL);
            rc=FALSE;
          }
        }
        else
          rc=FALSE;

        /* neues Pattern kopieren */
        if (AGDPrefsP.Pattern) FreeVec(AGDPrefsP.Pattern);
        AGDPrefsP.Pattern=mstrdup(freq->fr_Pattern);

        /* neue Größe besorgen */
        AGDPrefsP.FileRLeft  =freq->fr_LeftEdge;
        AGDPrefsP.FileRTop   =freq->fr_TopEdge;
        AGDPrefsP.FileRWidth =freq->fr_Width;
        AGDPrefsP.FileRHeight=freq->fr_Height;
        DEBUG_PRINTF("    got new Requester-Dimensions\n");

        /* Window freigeben */
        EnableAllWindows();
        DEBUG_PRINTF("    all Windows enabled\n");

        /* FileRequester freigeben */
        FreeAslRequest(freq);
        DEBUG_PRINTF("    freq freed\n");
      }
      else
      {
        EasyRequestAllWins("Error on creating the ASLFileRequester","Ok",NULL);
        rc=FALSE;
      }
    }

    /* Speicher freigeben */
    FreeVec(olddrawer);
    DEBUG_PRINTF("    olddrawer freed\n");
  }
  else
  {
    EasyRequestAllWins("Error on allocating memory for\n"
                       "processing the old drawer",
                       "Ok",NULL);
    rc=FALSE;
  }

  /* Erfolg zurückbegen */
  DEBUG_PRINTF("    -- returning --\n\n");
  return(rc);
}

/* ================================================================================= OpenFontRequester
** ASL-Font-Requester
*/
BOOL OpenFontRequester(void)
{
  struct FontRequester *freq;
  BOOL rc=TRUE;

  DEBUG_PRINTF("\n    -- Invoking OpenFontRequester-function --\n");

  if (AGDPrefsP.RTFontReq)
  {
    struct rtFontRequester *freq;

    DEBUG_PRINTF("  using ReqTools for displaying requester\n");

    /* FontRequester initialisieren */
    if (ReqToolsBase &&
        (freq=rtAllocRequestA(RT_FONTREQ,NULL)))
    {
      struct ReqDefaults *fp=&ReqToolsBase->ReqToolsPrefs.ReqDefaults[RTPREF_FONTREQ];
      ULONG flags=FREQF_COLORFONTS|FREQF_SCALE;

      DEBUG_PRINTF("  freq allocated\n");

      /* Font-Werte setzen */
      rtChangeReqAttr(freq,
                      RTFO_FontName,FontRD.Font.ta_Name,
                      RTFO_FontHeight,FontRD.Font.ta_YSize,
                      RTFO_FontStyle,FontRD.Font.ta_Style,
                      RTFO_FontFlags,FontRD.Font.ta_Flags,
                      TAG_DONE);

      DEBUG_PRINTF("  Font-data set in freq\n");

      /* Flags `übersetzen` */
      if (FontRD.Flags&FOF_DOSTYLE)        flags|=FREQF_STYLE;
      if (FontRD.Flags&FOF_FIXEDWIDTHONLY) flags|=FREQF_FIXEDWIDTH;

      /* Window sperren */
      DisableAllWindows();
      DEBUG_PRINTF("    all Windows disabled\n");

      /* Requester öffnen */
      if (rtFontRequest(freq,FontRD.Title,
                        RT_Window,GetValidWindow(),
                        RT_ReqPos,fp->ReqPos,
                        RT_LeftOffset,fp->LeftOffset,
                        RT_TopOffset,fp->TopOffset,
                        RT_ScreenToFront,TRUE,
                        RT_TextAttr,&Screen.ps_ScrAttr,
                        RTFO_Flags,flags,
                        TAG_DONE))
      {
        DEBUG_PRINTF("  freq opened\n");

        FontRD.Font.ta_Name =mstrdup(freq->Attr.ta_Name);
        FontRD.Font.ta_YSize=freq->Attr.ta_YSize;
        FontRD.Font.ta_Style=freq->Attr.ta_Style;
        FontRD.Font.ta_Flags=freq->Attr.ta_Flags;
      }
      else
        rc=FALSE;

      /* Window freigeben */
      EnableAllWindows();
      DEBUG_PRINTF("    all Windows enabled\n");

      /* freq-Struktur freigeben */
      rtFreeRequest(freq);
      DEBUG_PRINTF("  freq freed\n");
    }
    else
    {
      EasyRequestAllWins("Error on creating the RTFontRequester","Ok",NULL);
      rc=FALSE;
    }
  }
  else
  {
    DEBUG_PRINTF("  using ASL for displaying requester\n");

    /* FontRequester initilaisieren */
    if (AslBase &&
        (freq=(struct FontRequester *)
         AllocAslRequestTags(ASL_FontRequest,
                             ASLFO_Window,GetValidWindow(),
                             ASLFO_TitleText,FontRD.Title,
                             ASLFO_InitialName,FontRD.Font.ta_Name,
                             ASLFO_InitialSize,FontRD.Font.ta_YSize,
                             ASLFO_InitialStyle,FontRD.Font.ta_Style,
                             ASLFO_InitialFlags,FontRD.Font.ta_Flags,
                             ASLFO_Flags,FontRD.Flags,
                             ASLFO_TextAttr,&Screen.ps_ScrAttr,
                             TAG_DONE)))
    {
      DEBUG_PRINTF("    freq allocated\n");

      /* Window sperren */
      DisableAllWindows();
      DEBUG_PRINTF("    all Windows disabled\n");

      if (AGDPrefsP.FontRLeft==~0)   AGDPrefsP.FontRLeft  =freq->fo_LeftEdge;
      if (AGDPrefsP.FontRTop==~0)    AGDPrefsP.FontRTop   =freq->fo_TopEdge;
      if (AGDPrefsP.FontRWidth==~0)  AGDPrefsP.FontRWidth =freq->fo_Width;
      if (AGDPrefsP.FontRHeight==~0) AGDPrefsP.FontRHeight=freq->fo_Height;

      /* FontRequester aufrufen */
      if (AslRequestTags(freq,
                         ASLFO_InitialLeftEdge,AGDPrefsP.FontRLeft,
                         ASLFO_InitialTopEdge,AGDPrefsP.FontRTop,
                         ASLFO_InitialWidth,AGDPrefsP.FontRWidth,
                         ASLFO_InitialHeight,AGDPrefsP.FontRHeight,
                         TAG_DONE))
      {
        DEBUG_PRINTF("    Requester opened\n");

        FontRD.Font.ta_Name =mstrdup(freq->fo_Attr.ta_Name);
        FontRD.Font.ta_YSize=freq->fo_Attr.ta_YSize;
        FontRD.Font.ta_Style=freq->fo_Attr.ta_Style;
        FontRD.Font.ta_Flags=freq->fo_Attr.ta_Flags;
      }
      else
        rc=FALSE;

      AGDPrefsP.FontRLeft  =freq->fo_LeftEdge;
      AGDPrefsP.FontRTop   =freq->fo_TopEdge;
      AGDPrefsP.FontRWidth =freq->fo_Width;
      AGDPrefsP.FontRHeight=freq->fo_Height;
      DEBUG_PRINTF("    got new Requester-Dimensions\n");

      /* Window freigeben */
      EnableAllWindows();
      DEBUG_PRINTF("    all Windows enabled\n");

      /* FontRequester freigeben */
      FreeAslRequest(freq);
      DEBUG_PRINTF("    freq freed\n");
    }
    else
    {
      EasyRequestAllWins("Error on creating the ASLFontRequester","Ok",NULL);
      rc=FALSE;
    }
  }

  /* neuen Pfad zurückgeben */
  DEBUG_PRINTF("    -- returning --\n\n");
  return(rc);
}

/* ============================================================================== OpenScrModeRequester
** ASL-Screen-Requester
*/
BOOL OpenScrModeRequester(void)
{
  BOOL rc=TRUE;

  DEBUG_PRINTF("\n    -- Invoking OpenScreenRequester-function --\n");

  if (AGDPrefsP.RTScrMReq || AslBase->lib_Version<38L)
  {
    struct rtScreenModeRequester *sreq;

    DEBUG_PRINTF("  using ReqTools for displaying requester\n");

    /* FontRequester initialisieren */
    if (ReqToolsBase &&
        (sreq=rtAllocRequestA(RT_SCREENMODEREQ,NULL)))
    {
      struct ReqDefaults *sp=&ReqToolsBase->ReqToolsPrefs.ReqDefaults[RTPREF_SCREENMODEREQ];

      DEBUG_PRINTF("  sreq allocated\n");

      /* Font-Werte setzen */
      rtChangeReqAttr(sreq,
                      RTSC_DisplayID,ScreenRD.DisplayID,
                      RTSC_DisplayWidth,ScreenRD.Width,
                      RTSC_DisplayHeight,ScreenRD.Height,
                      RTSC_DisplayDepth,ScreenRD.Depth,
                      RTSC_OverscanType,ScreenRD.Overscan,
                      RTSC_AutoScroll,ScreenRD.AutoScroll,
                      TAG_DONE);

      DEBUG_PRINTF("  Font-data set in sreq\n");

      /* Window sperren */
      DisableAllWindows();
      DEBUG_PRINTF("    all Windows disabled\n");

      /* Requester öffnen */
      if (rtScreenModeRequest(sreq,ScreenRD.Title,
                              RT_Window,GetValidWindow(),
                              RT_ReqPos,sp->ReqPos,
                              RT_LeftOffset,sp->LeftOffset,
                              RT_TopOffset,sp->TopOffset,
                              RT_ScreenToFront,TRUE,
                              RT_TextAttr,&Screen.ps_ScrAttr,
                              RTSC_Flags,SCREQF_OVERSCANGAD|SCREQF_AUTOSCROLLGAD|\
                                         SCREQF_SIZEGADS|SCREQF_DEPTHGAD,
                              RTSC_MinWidth,640,
                              RTSC_MinHeight,200,
                              TAG_DONE))
      {
        DEBUG_PRINTF("  sreq opened\n");

        ScreenRD.DisplayID =sreq->DisplayID;
        ScreenRD.Width     =sreq->DisplayWidth;
        ScreenRD.Height    =sreq->DisplayHeight;
        ScreenRD.Depth     =sreq->DisplayDepth;
        ScreenRD.AutoScroll=sreq->AutoScroll;
        ScreenRD.Overscan  =sreq->OverscanType;
      }
      else
        rc=FALSE;

      /* Window freigeben */
      EnableAllWindows();
      DEBUG_PRINTF("    all Windows enabled\n");

      /* sreq-Struktur freigeben */
      rtFreeRequest(sreq);
      DEBUG_PRINTF("  sreq freed\n");
    }
    else
    {
      EasyRequestAllWins("Error on creating the RTFontRequester","Ok",NULL);
      rc=FALSE;
    }
  }
  else
  {
    struct ScreenModeRequester *sreq;

    /* ScreenRequester initilaisieren */
    if (AslBase &&
        (sreq=(struct ScreenModeRequester *)
         AllocAslRequestTags(ASL_ScreenModeRequest,
                             ASLSM_Window,GetValidWindow(),
                             ASLSM_TitleText,ScreenRD.Title,
                             ASLSM_InitialDisplayID,ScreenRD.DisplayID,
                             ASLSM_InitialDisplayWidth,ScreenRD.Width,
                             ASLSM_InitialDisplayHeight,ScreenRD.Height,
                             ASLSM_InitialDisplayDepth,ScreenRD.Depth,
                             ASLSM_InitialOverscanType,ScreenRD.Overscan,
                             ASLSM_InitialAutoScroll,ScreenRD.AutoScroll,
                             ASLSM_DoWidth,TRUE,
                             ASLSM_DoHeight,TRUE,
                             ASLSM_DoDepth,TRUE,
                             ASLSM_DoOverscanType,TRUE,
                             ASLSM_DoAutoScroll,TRUE,
                             ASLSM_MinWidth,640,
                             ASLSM_MinHeight,200,
                             ASLSM_MinDepth,2,
                             ASLSM_TextAttr,&Screen.ps_ScrAttr,
                             TAG_DONE)))
    {
      DEBUG_PRINTF("    sreq allocated\n");

      /* Window sperren */
      DisableAllWindows();
      DEBUG_PRINTF("    all Windows disabled\n");

      if (AGDPrefsP.ScrMRLeft==~0)   AGDPrefsP.ScrMRLeft  =sreq->sm_LeftEdge;
      if (AGDPrefsP.ScrMRTop==~0)    AGDPrefsP.ScrMRTop   =sreq->sm_TopEdge;
      if (AGDPrefsP.ScrMRWidth==~0)  AGDPrefsP.ScrMRWidth =sreq->sm_Width;
      if (AGDPrefsP.ScrMRHeight==~0) AGDPrefsP.ScrMRHeight=sreq->sm_Height;

      /* FontRequester aufrufen */
      if (AslRequestTags(sreq,
                         ASLSM_InitialLeftEdge,AGDPrefsP.ScrMRLeft,
                         ASLSM_InitialTopEdge,AGDPrefsP.ScrMRTop,
                         ASLSM_InitialWidth,AGDPrefsP.ScrMRWidth,
                         ASLSM_InitialHeight,AGDPrefsP.ScrMRHeight,
                         TAG_DONE))
      {
        DEBUG_PRINTF("    Requester opened\n");

        ScreenRD.DisplayID =sreq->sm_DisplayID;
        ScreenRD.Width     =sreq->sm_DisplayWidth;
        ScreenRD.Height    =sreq->sm_DisplayHeight;
        ScreenRD.Depth     =sreq->sm_DisplayDepth;
        ScreenRD.AutoScroll=sreq->sm_AutoScroll;
        ScreenRD.Overscan  =sreq->sm_OverscanType;
      }
      else
        rc=FALSE;

      AGDPrefsP.ScrMRLeft  =sreq->sm_LeftEdge;
      AGDPrefsP.ScrMRTop   =sreq->sm_TopEdge;
      AGDPrefsP.ScrMRWidth =sreq->sm_Width;
      AGDPrefsP.ScrMRHeight=sreq->sm_Height;
      DEBUG_PRINTF("    got new Requester-Dimensions\n");

      /* Window freigeben */
      EnableAllWindows();
      DEBUG_PRINTF("    all Windows enabled\n");

      /* ScreenModeRequester freigeben */
      FreeAslRequest(sreq);
      DEBUG_PRINTF("    sreq freed\n");
    }
    else
    {
      EasyRequestAllWins("Error on creating the ASLScreenModeRequester","Ok",NULL);
      rc=FALSE;
    }
  }

  /* neuen Pfad zurückgeben */
  DEBUG_PRINTF("    -- returning --\n\n");
  return(rc);
}

/* ===================================================================================== EasyRequester
** öffnet einen Intuition-EasyRequester
*/
ULONG EasyRequester(struct Window *win,char *text,char *gadgets,APTR args)
{
  ULONG rc;

  /* EasyRequester anzeigen */
  if (AGDPrefsP.RTEasyReq && ReqToolsBase)
  {
    struct rtReqInfo *es;

    if (es=rtAllocRequestA(RT_REQINFO,NULL))
    {
      struct ReqDefaults *ep=&ReqToolsBase->ReqToolsPrefs.ReqDefaults[RTPREF_OTHERREQ];

      rc=rtEZRequestTags(text,gadgets,es,args,
                         RT_Window,win,
                         RT_ReqPos,ep->ReqPos,
                         RT_LeftOffset,ep->LeftOffset,
                         RT_TopOffset,ep->TopOffset,
                         RT_ScreenToFront,TRUE,
                         RTEZ_ReqTitle,PROGNAME,
                         RTEZ_Flags,EZREQF_LAMIGAQUAL,
                         TAG_DONE);

      rtFreeRequest(es);
    }
  }
  else
  {
    struct EasyStruct es={sizeof(struct EasyStruct),
                          0,
                          PROGNAME,
                          NULL,
                          NULL};

    es.es_TextFormat=text;
    es.es_GadgetFormat=gadgets;

    rc=EasyRequestArgs(win,&es,NULL,args);
  }

  /* und raus */
  return(rc);
}

/* ================================================================================ EasyRequestAllWins
** öffnet einen Intuition-EasyRequester per EasyRequester() sperrt aber vorher alle Windows
*/
ULONG EasyRequestAllWins(char *text,char *gadgets,APTR args)
{
  ULONG rc;

  DisableAllWindows();

  /* EasyRequester anzeigen */
  rc=EasyRequester(GetValidWindow(),text,gadgets,args);

  EnableAllWindows();

  /* und raus */
  return(rc);
}

/* ======================================================================================= End of File
*/
