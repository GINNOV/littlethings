/*
** PROGRAMM:  AmigaGuideDesigner
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
#include "AGD.h"

struct FileRD      FileRD  ={0};
struct FontRD      FontRD  ={0};

/* ================================================================================= OpenFileRequester
** FileRequester
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
    if (MiscP.RTFileReq)
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
                        RTFI_MatchPat,MiscP.Pattern,
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
                            RT_TextAttr,&ScrP.ScrAttr,
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
              EasyRequestAllWins("Error allocating memory for"
                                 "building the new path",
                                 "Ok");
              rc=FALSE;
            }
          }
          else
            rc=FALSE;

          /* neues Pattern kopieren */
          if (MiscP.Pattern) FreeVec(MiscP.Pattern);
          MiscP.Pattern=mstrdup(freq->MatchPat);

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
        EasyRequestAllWins("Error creating the RTFileRequester","Ok");
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
                               ASLFR_InitialPattern,MiscP.Pattern,
                               ASLFR_Flags1,FileRD.Flags1,
                               ASLFR_Flags2,FileRD.Flags2,
                               ASLFR_TextAttr,&ScrP.ScrAttr,
                               TAG_DONE)))
      {
        DEBUG_PRINTF("    freq allocated\n");

        /* Window sperren */
        DisableAllWindows();
        DEBUG_PRINTF("    all Windows disabled\n");

        /* Standard-Größe besorgen */
        if (WinPosP.FileRLeft==~0)   WinPosP.FileRLeft  =freq->fr_LeftEdge;
        if (WinPosP.FileRTop==~0)    WinPosP.FileRTop   =freq->fr_TopEdge;
        if (WinPosP.FileRWidth==~0)  WinPosP.FileRWidth =freq->fr_Width;
        if (WinPosP.FileRHeight==~0) WinPosP.FileRHeight=freq->fr_Height;

        /* FileRequester aufrufen */
        if (AslRequestTags(freq,
                           ASLFR_InitialLeftEdge,WinPosP.FileRLeft,
                           ASLFR_InitialTopEdge,WinPosP.FileRTop,
                           ASLFR_InitialWidth,WinPosP.FileRWidth,
                           ASLFR_InitialHeight,WinPosP.FileRHeight,
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
            EasyRequestAllWins("Error allocating memory for\n"
                               "building the new path",
                               "Ok");
            rc=FALSE;
          }
        }
        else
          rc=FALSE;

        /* neues Pattern kopieren */
        if (MiscP.Pattern) FreeVec(MiscP.Pattern);
        MiscP.Pattern=mstrdup(freq->fr_Pattern);

        /* neue Größe besorgen */
        WinPosP.FileRLeft  =freq->fr_LeftEdge;
        WinPosP.FileRTop   =freq->fr_TopEdge;
        WinPosP.FileRWidth =freq->fr_Width;
        WinPosP.FileRHeight=freq->fr_Height;
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
        EasyRequestAllWins("Error creating the ASLFileRequester","Ok");
        rc=FALSE;
      }
    }

    /* Speicher freigeben */
    FreeVec(olddrawer);
    DEBUG_PRINTF("    olddrawer freed\n");
  }
  else
  {
    EasyRequestAllWins("Error allocating memory for\n"
                       "processing the old drawer",
                       "Ok");
    rc=FALSE;
  }

  /* Erfolg zurückbegen */
  DEBUG_PRINTF("    -- returning --\n\n");
  return(rc);
}

/* ================================================================================= OpenFontRequester
** FontRequester
*/
BOOL OpenFontRequester(void)
{
  struct FontRequester *freq;
  BOOL rc=TRUE;

  DEBUG_PRINTF("\n    -- Invoking OpenFontRequester-function --\n");

  if (MiscP.RTFontReq)
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
                        RT_TextAttr,&ScrP.ScrAttr,
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
      EasyRequestAllWins("Error on creating the RTFontRequester","Ok");
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
                             ASLFO_TextAttr,&ScrP.ScrAttr,
                             TAG_DONE)))
    {
      DEBUG_PRINTF("    freq allocated\n");

      /* Window sperren */
      DisableAllWindows();
      DEBUG_PRINTF("    all Windows disabled\n");

      if (WinPosP.FontRLeft==~0)   WinPosP.FontRLeft  =freq->fo_LeftEdge;
      if (WinPosP.FontRTop==~0)    WinPosP.FontRTop   =freq->fo_TopEdge;
      if (WinPosP.FontRWidth==~0)  WinPosP.FontRWidth =freq->fo_Width;
      if (WinPosP.FontRHeight==~0) WinPosP.FontRHeight=freq->fo_Height;

      /* FontRequester aufrufen */
      if (AslRequestTags(freq,
                         ASLFO_InitialLeftEdge,WinPosP.FontRLeft,
                         ASLFO_InitialTopEdge,WinPosP.FontRTop,
                         ASLFO_InitialWidth,WinPosP.FontRWidth,
                         ASLFO_InitialHeight,WinPosP.FontRHeight,
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

      WinPosP.FontRLeft  =freq->fo_LeftEdge;
      WinPosP.FontRTop   =freq->fo_TopEdge;
      WinPosP.FontRWidth =freq->fo_Width;
      WinPosP.FontRHeight=freq->fo_Height;
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
      EasyRequestAllWins("Error on creating the ASLFontRequester","Ok");
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
  if (MiscP.RTEasyReq && ReqToolsBase)
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
ULONG EasyRequestAllWins(char *text,char *gadgets,...)
{
  ULONG rc;
  va_list args;

  DisableAllWindows();
  va_start(args,gadgets);
  rc=EasyRequester(GetValidWindow(),text,gadgets,args);
  va_end(args);
  EnableAllWindows();

  return(rc);
}

/* ======================================================================================= End of File
*/
