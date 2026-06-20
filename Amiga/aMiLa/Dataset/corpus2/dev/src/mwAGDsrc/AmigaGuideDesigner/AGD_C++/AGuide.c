/*
** PROGRAMM:  AmigaGuideDesigner
** AUTOR:     Michael Weiser
** COPYRIGHT: ©1994 Michael Weiser (Giftware)
** COMPILER:  SAS/C 6.5
**
** MODUL:     AGuide.c
** FUNKTION:  AmigaGuide-Funktionen für AmigaGuideDesigner
**
*/

/*#define DEBUG*/
#include "AGD.h"

struct AGuide      AGuide;

static BPTR File;

/* Codes */
#define COD_STR        0        /* String (") */
#define COD_EOL        1        /* End of File */
#define COD_SP         2        /* Space */
#define COD_BRA        3        /* Bracket = Klammer */
#define COD_LINKBEG    4        /* Anfang des Links */

static char *Codes[]={
                      "\"",
                      "\n",
                      " ",
                      "}",
                      "@{\""
                     };

#define COM_DATABASE   0
#define COM_AUTHOR     1
#define COM_COPYR      2
#define COM_VERSION    3
#define COM_MASTER     4
#define COM_FONT       5
#define COM_INDEX      6
#define COM_HELP       7
#define COM_WORDWRAP   8
#define COM_NODE       9
#define COM_NEXT      10
#define COM_PREV      11
#define COM_TOC       12
#define COM_KEYWORDS  13
#define COM_ENDNODE   14

static char *Commands[]={
                         "@DATABASE ",
                         "@AUTHOR ",
                         "@(C) ",
                         "@$VER: ",
                         "@MASTER ",
                         "@FONT ",
                         "@INDEX \"",
                         "@HELP ",
                         "@WORDWRAP\n",

                         "@NODE \"",
                         "@NEXT \"",
                         "@PREV \"",
                         "@TOC \"",
                         "@KEYWORDS ",
                         "@ENDNODE\n",
                        };

static char *CommTypes[]={
                          "LINK \"",
                          "ALINK \"",
                          "RX \"",
                          "RXS \"",
                          "SYSTEM \"",
                          "CLOSE",
                          "QUIT",
                         };

#define COLT_BOLD    0
#define COLT_UBOLD   1
#define COLT_ITALIC  2
#define COLT_UITALIC 3
#define COLT_ULINE   4
#define COLT_UULINE  5
#define COLT_FGPEN   6
#define COLT_BGPEN   7

static char *ColTypes[]={
                         "@{B}",
                         "@{UB}",
                         "@{I}",
                         "@{UI}",
                         "@{U}",
                         "@{UU}",
                         "@{FG ",
                         "@{BG "
                        };

static char *Colours[]={
                        "TEXT",
                        "SHINE",
                        "SHADOW",
                        "FILL",
                        "FILLTEXT",
                        "BACKGROUND",
                        "HIGHLIGHT"
                       };

/* ======================================================================================= WriteString
** schreibt einen String in ein File (!?)
*/
void WriteString(char *str)
{
  Write(File,str,strlen(str));
}

/* ========================================================================================= Writeable
** testet, ob der String vorhanden ist
*/
int Writeable(char *str)
{
  return(str && strlen(str));
}

/* ======================================================================================== InitAGuide
** setzt die Anfangswerte der AGuide-Struktur
*/
BOOL InitAGuide(void)
{
  DEBUG_PRINTF("\n  -- Invoking InitAGuide-function --\n");

  NewList(&AGuide.gt_Docs);
  DEBUG_PRINTF("  AGuide.gt_Docs prepared\n");

  AGuide.gt_Name     =mstrdup(ProjP.AGuidePath);
  AGuide.gt_Author   =mstrdup(ProjP.Author);
  AGuide.gt_Copyright=mstrdup(ProjP.Copyright);
  AGuide.gt_Version  =mstrdup(ProjP.Version);
  AGuide.gt_Font     =mstrdup(ProjP.FontName);
  AGuide.gt_FoSize   =ProjP.FontSize;
  AGuide.gt_Index    =mstrdup(ProjP.Index);
  AGuide.gt_Help     =mstrdup(ProjP.Help);
  AGuide.gt_WordWrap =ProjP.WordWrap;
  FormatAGuidePrefsStrings();

  AGuide.gt_CurSel   =0;
  DEBUG_PRINTF("  Initialisation done\n");

  /* erstes Document anfordern */
  if (AGuide.gt_CurDoc=
      InsertDoc((struct Document *)&AGuide.gt_Docs.lh_Head))
  {
    DEBUG_PRINTF("  AGuide.gt_CurDoc inserted\n");

    DEBUG_PRINTF("  -- returning --\n\n");
    return(TRUE);
  }
  else
    EasyRequestAllWins("Error on initializing the\n"
                       "AmigaGuide® Datas",
                       "Ok");

  FreeAGuide();

  DEBUG_PRINTF("  -- returning --\n\n");
  return(FALSE);
}

#define AGUIDEFPSFLAGS (PSSEQF_DATABASE|PSSEQF_NODENAME|PSSEQF_PREVNODE|PSSEQF_NEXTNODE|PSSEQF_FILENAME)

/* ========================================================================== FormatAGuidePrefsStrings
** setzt einige Strings im AGuide nach den Weren in ProjP
*/
void FormatAGuidePrefsStrings(void)
{

  AGuide.gt_Master   =FormatPrefsString(ProjP.Master,NULL,PSSEQF_MASTER|AGUIDEFPSFLAGS);
  AGuide.gt_Database =FormatPrefsString(ProjP.Database,NULL,AGUIDEFPSFLAGS);
}

/* ======================================================================================== FreeAGuide
** gibt alle Strukturen in der AGuide-Struktur frei
*/
void FreeAGuide(void)
{
  struct Document *doc;

  DEBUG_PRINTF("\n  -- Invoking FreeAGuide-function --\n");

  /* Database */
  if (AGuide.gt_Database)
  {
    FreeVec(AGuide.gt_Database);
    DEBUG_PRINTF("  AGuide.gt_Database freed\n");
  }

  /* Author */
  if (AGuide.gt_Author)
  {
    FreeVec(AGuide.gt_Author);
    DEBUG_PRINTF("  AGuide.gt_Author freed\n");
  }

  /* Copyright */
  if (AGuide.gt_Copyright)
  {
    FreeVec(AGuide.gt_Copyright);
    DEBUG_PRINTF("  AGuide.gt_Copyright freed\n");
  }

  /* Version */
  if (AGuide.gt_Version)
  {
    FreeVec(AGuide.gt_Version);
    DEBUG_PRINTF("  AGuide.gt_Version freed\n");
  }

  /* Master */
  if (AGuide.gt_Master)
  {
    FreeVec(AGuide.gt_Master);
    DEBUG_PRINTF("  AGuide.gt_Master freed\n");
  }

  /* Font */
  if (AGuide.gt_Font)
  {
    FreeVec(AGuide.gt_Font);
    DEBUG_PRINTF("  AGuide.gt_Font freed\n");
  }

  /* Index */
  if (AGuide.gt_Index)
  {
    FreeVec(AGuide.gt_Index);
    DEBUG_PRINTF("  AGuide.gt_Index freed\n");
  }

  /* Help */
  if (AGuide.gt_Help)
  {
    FreeVec(AGuide.gt_Help);
    DEBUG_PRINTF("  AGuide.gt_Help freed\n");
  }

  AGuide.gt_WordWrap=FALSE;
  DEBUG_PRINTF("  AGuide.gt_WordWrap set to FALSE\n");

  /* Documents */
  doc=(struct Document *)AGuide.gt_Docs.lh_Head;
  while (doc->doc_Node.ln_Succ) doc=DeleteDoc(doc);

  DEBUG_PRINTF("  Documents freed\n");

  DEBUG_PRINTF("  -- returning --\n\n");
}

/* ======================================================================================== SaveAGuide
** sichert den AmigaGuide Text
*/
BOOL SaveAGuide(void)
{
  BOOL   rc=TRUE;
  struct Document *curdoc;
  struct Command  *curcom,*lstcom;
  struct Command   defcom;
  LONG   curln;
  char  *curcr;
  WORD   len;

  DEBUG_PRINTF("\n    -- Invoking SaveAGuide-function --\n");

  /* File öffnen */
  if (File=Open(AGuide.gt_Name,MODE_NEWFILE))
  {
    DEBUG_PRINTF("    AGuide.gt_Name opened as File\n");

    /* Database */
    if (Writeable(AGuide.gt_Database))
    {
      WriteString(Commands[COM_DATABASE]);
      WriteString(AGuide.gt_Database);
      WriteString(Codes[COD_EOL]);
      DEBUG_PRINTF("    AGuide.gt_Database written\n");
    }

    /* Master */
    if (Writeable(AGuide.gt_Master))
    {
      WriteString(Commands[COM_MASTER]);
      WriteString(AGuide.gt_Master);
      WriteString(Codes[COD_EOL]);
      DEBUG_PRINTF("    AGuide.gt_Master written\n");
    }

    /* Version */
    if (Writeable(AGuide.gt_Version))
    {
      WriteString(Commands[COM_VERSION]);
      WriteString(AGuide.gt_Version);
      WriteString(Codes[COD_EOL]);
      DEBUG_PRINTF("    AGuide.gt_Version written\n");
    }

    /* Author */
    if (Writeable(AGuide.gt_Author))
    {
      WriteString(Commands[COM_AUTHOR]);
      WriteString(AGuide.gt_Author);
      WriteString(Codes[COD_EOL]);
      DEBUG_PRINTF("    AGuide.gt_Author written\n");
    }

    /* Copyright */
    if (Writeable(AGuide.gt_Copyright))
    {
      WriteString(Commands[COM_COPYR]);
      WriteString(AGuide.gt_Copyright);
      WriteString(Codes[COD_EOL]);
      DEBUG_PRINTF("    AGuide.gt_Copyright written\n");
    }

    /* Font */
    if (Writeable(AGuide.gt_Font))
    {
      char *tmp;

      WriteString(Commands[COM_FONT]);
      WriteString(AGuide.gt_Font);

      if (tmp=(char *)AllocMem(10,MEMF_ANY|MEMF_PUBLIC|MEMF_CLEAR))
      {
        stci_d(tmp,AGuide.gt_FoSize);
        WriteString(Codes[COD_SP]);
        WriteString(tmp);

        FreeMem(tmp,10);
      }

      WriteString(Codes[COD_EOL]);
      DEBUG_PRINTF("    AGuide.gt_Font written\n");
    }

    /* Help */
    if (Writeable(AGuide.gt_Help))
    {
      WriteString(Commands[COM_HELP]);
      WriteString(AGuide.gt_Help);
      WriteString(Codes[COD_EOL]);
      DEBUG_PRINTF("    AGuide.gt_Help written\n");
    }

    /* WordWrap */
    if (AGuide.gt_WordWrap)
    {
      WriteString(Commands[COM_WORDWRAP]);
      DEBUG_PRINTF("    @WORDWRAP written\n");
    }

    /* Index */
    if (Writeable(AGuide.gt_Index))
    {
      WriteString(Commands[COM_INDEX]);
      WriteString(AGuide.gt_Index);
      WriteString(Codes[COD_STR]);
      WriteString(Codes[COD_EOL]);
      DEBUG_PRINTF("    AGuide.gt_Index written\n");
    }

    /* Nodes */
    curdoc=(struct Document *)AGuide.gt_Docs.lh_Head;

    while (curdoc->doc_Node.ln_Succ)
    {
      /* Node */
      if (Writeable(curdoc->doc_Node.ln_Name))
      {
        WriteString(Commands[COM_NODE]);
        WriteString(curdoc->doc_Node.ln_Name);
        WriteString(Codes[COD_STR]);
        WriteString(Codes[COD_SP]);
        WriteString(Codes[COD_STR]);
        WriteString(curdoc->doc_WinTitle);
        WriteString(Codes[COD_STR]);
        WriteString(Codes[COD_EOL]);
        DEBUG_PRINTF("    curdoc->doc_Node.ln_Name & doc_WinTitle written\n");
      }

      /* Next */
      if (Writeable(curdoc->doc_NextNode))
      {
        WriteString(Commands[COM_NEXT]);
        WriteString(curdoc->doc_NextNode);
        WriteString(Codes[COD_STR]);
        WriteString(Codes[COD_EOL]);
        DEBUG_PRINTF("    curdoc->doc_NextNode written\n");
      }

      /* Prev */
      if (Writeable(curdoc->doc_PrevNode))
      {
        WriteString(Commands[COM_PREV]);
        WriteString(curdoc->doc_PrevNode);
        WriteString(Codes[COD_STR]);
        WriteString(Codes[COD_EOL]);
        DEBUG_PRINTF("    curdoc->doc_PrevNode written\n");
      }

      /* TOC */
      if (Writeable(curdoc->doc_TOCNode))
      {
        WriteString(Commands[COM_TOC]);
        WriteString(curdoc->doc_TOCNode);
        WriteString(Codes[COD_STR]);
        WriteString(Codes[COD_EOL]);
        DEBUG_PRINTF("    curdoc->doc_TOCNode written\n");
      }

      /* LINES */
      defcom.com_Type =COMT_STYLE;
      defcom.com_FGPen=COL_TEXT;
      defcom.com_BGPen=COL_BG;
      defcom.com_Style=FS_NORMAL;
      lstcom=&defcom;

      if (curdoc->doc_Lines)
      {
        curln=0;

        while (curln<curdoc->doc_NumLn)
        {
          curcom=GetCommVecLnHead(curdoc,curln);
          curcr =curdoc->doc_Lines[curln].al_Line;

          while (curcom->com_Node.mln_Succ)
          {
            /* normaler Teil der Zeile */
            len=curdoc->doc_Lines[curln].al_Line+curcom->com_Char-curcr;
            Write(File,curcr,len);
            curcr+=len;
            DEBUG_PRINTF("      Chars in Space between Comms written\n");

            if (curcom->com_Type>=COMT_LINK && curcom->com_Type<=COMT_QUIT)
            {
              WriteString(Codes[COD_LINKBEG]);
              DEBUG_PRINTF("      first part of Link-Button written\n");

              /* Inhalt des Buttons */
              Write(File,curcr,curcom->com_Len);
              curcr+=curcom->com_Len;
              DEBUG_PRINTF("      chars in Comm written\n");

              /* Ende des Buttons */
              WriteString(Codes[COD_STR]);
              WriteString(Codes[COD_SP]);
              DEBUG_PRINTF("      `\" ` written\n");

              /* jeweiliger Befehl */
              WriteString(CommTypes[curcom->com_Type]);
              DEBUG_PRINTF("      Command[curcom->com_VarData] written\n");

              /* Parameter der Befehle */
              if (curcom->com_Type!=COMT_CLOSE &&
                  curcom->com_Type!=COMT_QUIT)
              {
                WriteString(curcom->com_StrData);
                WriteString(Codes[COD_STR]);
              }

              /* Ende des Buttons */
              WriteString(Codes[COD_BRA]);
              DEBUG_PRINTF("      `}` written\n");
            }

            if (curcom->com_Type==COMT_STYLE)
            {
              if (curcom->com_FGPen!=lstcom->com_FGPen)
              {
                WriteString(ColTypes[COLT_FGPEN]);
                WriteString(Colours[curcom->com_FGPen]);
                WriteString(Codes[COD_BRA]);
              }

              if (curcom->com_BGPen!=lstcom->com_BGPen)
              {
                WriteString(ColTypes[COLT_BGPEN]);
                WriteString(Colours[curcom->com_BGPen]);
                WriteString(Codes[COD_BRA]);
              }

              if (curcom->com_Style!=lstcom->com_Style)
              {
                if ((curcom->com_Style&FSF_BOLD) && !(lstcom->com_Style&FSF_BOLD))
                  WriteString(ColTypes[COLT_BOLD]);

                if (!(curcom->com_Style&FSF_BOLD) && (lstcom->com_Style&FSF_BOLD))
                  WriteString(ColTypes[COLT_UBOLD]);

                if ((curcom->com_Style&FSF_ITALIC) && !(lstcom->com_Style&FSF_ITALIC))
                  WriteString(ColTypes[COLT_ITALIC]);

                if (!(curcom->com_Style&FSF_ITALIC) && (lstcom->com_Style&FSF_ITALIC))
                  WriteString(ColTypes[COLT_UITALIC]);

                if ((curcom->com_Style&FSF_UNDERLINED) && !(lstcom->com_Style&FSF_UNDERLINED))
                  WriteString(ColTypes[COLT_ULINE]);

                if (!(curcom->com_Style&FSF_UNDERLINED) && (lstcom->com_Style&FSF_UNDERLINED))
                  WriteString(ColTypes[COLT_UULINE]);
              }

              lstcom=curcom;
            }

            /* einen Comm weiter */
            curcom=(struct Command *)curcom->com_Node.mln_Succ;
          }

          /* letzter Teil der Zeile */
          len=curdoc->doc_Lines[curln].al_Line+curdoc->doc_Lines[curln].al_Len-curcr+1;
          Write(File,curcr,len);
          DEBUG_PRINTF("      Chars at End of Line written\n");

          curln++;
          DEBUG_PRINTF("    curln++\n");
        }
      }

      /* EndNode */
      WriteString(Commands[COM_ENDNODE]);
      DEBUG_PRINTF("    @ENDNODE written\n");

      curdoc=(struct Document *)curdoc->doc_Node.ln_Succ;
      DEBUG_PRINTF("    curdoc=curdoc->Succ\n");
    }

    Close(File);
    DEBUG_PRINTF("    File closed\n");
  }
  else
  {
    EasyRequestAllWins("Error on opening the AmigaGuide database file\n"
                       "Filename: %s",
                       "Ok",
                       AGuide.gt_Name);
    rc=FALSE;
  }

  DEBUG_PRINTF("    -- returning --\n\n");
  return(rc);
}

/* ======================================================================================= End of File
*/
