/*
** PROGRAMM:  AmigaGuideDesigner
** AUTOR:     Michael Weiser
** COPYRIGHT: ©1994 Michael Weiser (Giftware)
** COMPILER:  SAS/C 6.5
**
** MODUL:     ASCII.c
** FUNKTION:  ASCII-Routinen für AmigaGuideDesigner
**
*/

/*#define DEBUG*/
#include "AGD.h"

/* ===================================================================================== FreeASCIIText
** gibt den vom Texte eingenommenen Speicherplatz wieder frei
*/
void FreeASCIIText(struct Document *doc)
{
  DEBUG_PRINTF("\n    -- Invoking FreeASCIIText-function --\n");

  /* Pointer auf Satzanfänge freigeben */
  if (doc->doc_Lines)
  {
    FreeMem(doc->doc_Lines,doc->doc_LinesBufLen);
    doc->doc_Lines=NULL;
    doc->doc_LinesBufLen=0;
    doc->doc_NumLn=0;
    doc->doc_MaxCol=0;

    DEBUG_PRINTF("    doc->doc_Lines freed\n");
  }

  /* Text selbst freigeben */
  if (doc->doc_Buf)
  {
    FreeMem(doc->doc_Buf,doc->doc_BufLen);
    doc->doc_Buf   =NULL;
    doc->doc_BufEnd=NULL;
    doc->doc_BufLen=0;

    DEBUG_PRINTF("    doc->doc_Buf freed\n");
  }

  DEBUG_PRINTF("    -- returning --\n\n");
}

/* ===================================================================================== LoadASCIIText
** ließt einen ASCII-Text ein
*/
BOOL LoadASCIIText(struct Document *doc,char *fname)
{
  BOOL   rc=TRUE;
  BPTR   lock,file;
  LONG   numln=0;
  char  *buf,*bufend;
  ULONG  buflen,linesbuflen;
  struct ASCIILine *lines;
  struct FileInfoBlock *fib;

  DEBUG_PRINTF("\n    -- Invoking LoadASCIIText-function --\n");

  if (!fname) fname=doc->doc_FileName;

  /* File locken */
  if (lock=Lock(fname,SHARED_LOCK))
  {
    DEBUG_PRINTF("    fname locked as lock\n");

    /* TxtFile öffnen */
    if (file=Open(fname,MODE_OLDFILE))
    {
      DEBUG_PRINTF("    fname opened as file\n");

      /* Speicher für fib anfordern */
      if (fib=(struct FileInfoBlock *)
          AllocMem(sizeof(struct FileInfoBlock),MEMF_ANY|MEMF_PUBLIC|MEMF_CLEAR))
      {
        DEBUG_PRINTF("    memory for fib allocated\n");

        /* FileInfoBlock besorgen */
        if (Examine(lock,fib))
        {
          DEBUG_PRINTF("    fib examined from lock\n");

          buflen=fib->fib_Size;

          /* Speicher für Text anfordern */
          if (buf=(char *)
              AllocMem(buflen,MEMF_ANY|MEMF_PUBLIC))
          {
            DEBUG_PRINTF("    memory for buf allocated\n");

            bufend=buf+buflen;

            /* Text einlesen */
            if (Read(file,buf,buflen)!=buflen)
            {
              EasyRequestAllWins("Error on reading the ASCII text\n"
                                 "FileName: %s",
                                 "Ok",
                                 fname);
              rc=FALSE;
            }
          }
          else
          {
            EasyRequestAllWins("Error on allocating memory\n"
                               "for the ASCII text buffer\n"
                               "Bytes needed: %ld",
                               "Ok",
                               buflen);
            rc=FALSE;
          }
        }
        else
        {
          EasyRequestAllWins("Error on getting more informations\n"
                             "about the ASCII text",
                             "Ok");
          rc=FALSE;
        }

        /* fib freigeben */
        FreeMem(fib,sizeof(struct FileInfoBlock));
      }
      else
      {
        EasyRequestAllWins("Error getting more informations about\n"
                           "the ASCII text",
                           "Ok");
        rc=FALSE;
      }

      /* File schließen */
      Close(file);
      DEBUG_PRINTF("    fname closed from file\n");
    }
    else
    {
      EasyRequestAllWins("Error on opening the ASCII text\n"
                         "FileName: %s",
                         "Ok",
                         fname);
      rc=FALSE;
    }

    /* File unlocken */
    UnLock(lock);
    DEBUG_PRINTF("    fname unlocked from lock\n");
  }
  else
  {
    EasyRequestAllWins("Error on locking the ASCII text\n"
                       "FileName: %s",
                       "Ok",
                       fname);
    rc=FALSE;
  }

  /* Text parsen */
  if (rc)
  {
    char *curcr=buf;
    LONG curln;

    /* Anzahl der Zeilen ermitteln */
    while (curcr<=bufend)
    {
      if (*curcr==EOL)
      {
        numln++;
      }

      curcr++;
    }

    DEBUG_PRINTF("    numln calculated\n");

    /* noch `ne Zeile mehr, falls am Ende des Textes kein EOL steht */
    linesbuflen=(numln+1)*sizeof(struct ASCIILine);

    /* Speicher für Zeilenpointer anfordern */
    if (lines=(struct ASCIILine *)
        AllocMem(linesbuflen,MEMF_ANY|MEMF_PUBLIC|MEMF_CLEAR))
    {
      DEBUG_PRINTF("    memory for lines allocated\n");

      curln=1;
      curcr=lines[0].al_Line=buf;

      /* Zeilenanfänge ermitteln */
      while (curcr<=bufend && curln<numln)
      {
        if (*curcr==EOL)
        {
          lines[curln].al_Line=curcr+1;
          curln++;
        }

        curcr++;
      }


      /* Ende des Textes setzen */
      lines[numln].al_Line=bufend;

      for (curln=0;curln<numln;curln++)
        lines[curln].al_Len=lines[curln+1].al_Line-lines[curln].al_Line-1;

      lines[numln].al_Len=0;
    }
    else
    {
      rc=FALSE;
      EasyRequestAllWins("Error on allocating memory for\n"
                         "additional ASCII data\n"
                         "Bytes needed: %ld",
                         "Ok",
                         linesbuflen);
    }
  }

  /* CommVector */
  if (rc)
  {
    if (AllocCommVector(AGuide.gt_CurDoc,numln))
    {
      /* alle alten Puffer freigeben */
      FreeMem(doc->doc_Lines,doc->doc_LinesBufLen);
      FreeMem(doc->doc_Buf,doc->doc_BufLen);

      /* alle Werte nun fest übertragen */
      doc->doc_Buf        =buf;
      doc->doc_BufLen     =buflen;
      doc->doc_BufEnd     =bufend;
      doc->doc_Lines      =lines;
      doc->doc_LinesBufLen=linesbuflen;
      doc->doc_NumLn      =numln;

      DEBUG_PRINTF("    all new pointers copied to doc\n");
    }
    else
    {
      rc=FALSE;
      EasyRequestAllWins("Error on allocating memory for\n"
                         "Commands-list",
                         "Ok");
    }
  }

  DEBUG_PRINTF("    -- returning --\n\n");
  return(rc);
}

/* ===================================================================================== SaveASCIIText
** speichert einen ASCIIText
*/
BOOL SaveASCIIText(struct Document *doc,char *fname)
{
  BOOL rc=TRUE;
  BPTR file;

  DEBUG_PRINTF("\n    -- Invoking SaveASCIIText-function --\n");

  if (!fname) fname=doc->doc_FileName;

  /* TxtFile öffnen */
  if (file=Open(fname,MODE_NEWFILE))
  {
    DEBUG_PRINTF("    fname opened with MODE_NEWFILE\n");

    /* Text einlesen */
    if (Write(file,doc->doc_Buf,doc->doc_BufLen)!=doc->doc_BufLen)
    {
      EasyRequestAllWins("Error on saving the ASCII text\n"
                         "FileName: %s",
                         "Ok",
                         fname);
      rc=FALSE;
    }

    /* File schließen */
    Close(file);
    DEBUG_PRINTF("    fname closed from file\n");
  }
  else
  {
    EasyRequestAllWins("Error on opening the ASCII text file\n"
                       "FileName: %s",
                       "Ok",
                        fname);
    rc=FALSE;
  }

  DEBUG_PRINTF("    -- returning --\n\n");
  return(rc);
}

/* ===================================================================================== EditASCIIText
** übergibt den ASCII-Text an einen Text-Editor
*/
BOOL EditASCIIText(struct Document *doc,struct MsgPort *userport)
{
  BOOL  rc=TRUE;
  char *name;
  struct NotifyRequest nr;

  DEBUG_PRINTF("\n    -- Invoking EditASCIIText-function --\n");

  if (doc->doc_FileName)
    name=doc->doc_FileName;
  else
  {
    name=MiscP.TmpDocFileName;
    SaveASCIIText(doc,name);
  }

  /* NotifyRequest ausfüllen */
  nr.nr_Name =name;
  nr.nr_Flags=NRF_SEND_SIGNAL;
  nr.nr_stuff.nr_Signal.nr_Task=FindTask(NULL);

  /* Signal allokieren */
  if (~0!=(nr.nr_stuff.nr_Signal.nr_SignalNum=AllocSignal(-1)))
  {
    ULONG nrsigbit=1UL<<nr.nr_stuff.nr_Signal.nr_SignalNum;
    ULONG upsigbit=1UL<<userport->mp_SigBit;

    DEBUG_PRINTF("    nr.nr_stuff.nr_Signal.nr_SignalNum allocted\n");

    /* Notify starten */
    if (StartNotify(&nr))
    {
      BPTR input,output;

      DEBUG_PRINTF("    notify started with StartNotify()\n");

      /* inputkanal für Execute() öffnen */
      if (input=Open("NIL:",MODE_NEWFILE))
      {
        DEBUG_PRINTF("    input opened to NIL:\n");

        /* outputkanal für Execute() öffnen */
        if (output=Open("NIL:",MODE_NEWFILE))
        {
          char *exe=FormatPrefsString(MiscP.Editor,AGuide.gt_CurDoc,PSSEQF_NOTHING);

          DEBUG_PRINTF("    output opened to NIL:\n");

          /* mit Execute Editor (MiscP.Editor) starten */
          if (Execute(exe,input,output))
          {
            ULONG signalmask=SIGBREAKF_CTRL_C|nrsigbit|upsigbit,signals=0;
            BYTE  quit=FALSE;

            DEBUG_PRINTF("    MiscP.Editor started\n    waiting for signal from notify\n");

            /* auf Notify-Message warten */
            while(!quit)
            {
              signals=Wait(signalmask);

              if (signals&nrsigbit)
              {
                quit=TRUE;
                rc=LoadASCIIText(doc,name);
                DEBUG_PRINTF("    tried to reload text\n");
              }

              if (signals&SIGBREAKF_CTRL_C)
                quit=TRUE;

              if (signals&upsigbit)
              {
                struct IntuiMessage *imsg;

                while(imsg=(struct IntuiMessage *)GetMsg(userport))
                {
                  if (imsg->Class==IDCMP_GADGETUP)
                    quit=TRUE;

                  ReplyMsg((struct Message *)imsg);
                }
              }
            }

          }
          else
          {
            rc=FALSE;
            EasyRequestAllWins("Error on executing the editor\n"
                               "Path: %s",
                               "Ok",
                               exe);
          }

          /* Speicher für CommandLine freigeben */
          FreeVec(exe);
          DEBUG_PRINTF("    exe freed\n");

          /* outputkanal schließen */
          Close(output);
          DEBUG_PRINTF("    output closed\n");
        }
        else
        {
          rc=FALSE;
          EasyRequestAllWins("Error on opening NIL: for output",
                             "Ok");
        }

        /* inputkanal schließen */
        Close(input);
        DEBUG_PRINTF("    input closed\n");
      }
      else
      {
        rc=FALSE;
        EasyRequestAllWins("Error on opening NIL: for input",
                           "Ok");
      }

      /* Notify beenden */
      EndNotify(&nr);
      DEBUG_PRINTF("    notify stopped\n");
    }
    else
    {
      rc=FALSE;
      EasyRequestAllWins("Error on starting notify on file\n"
                         "%s",
                         "Ok",
                         name);
    }

    /* SignalNummer freigeben*/
    FreeSignal(nr.nr_stuff.nr_Signal.nr_SignalNum);
    DEBUG_PRINTF("    nr.nr_stuff.nr_Signal.nr_SignalNum freed\n");
  }
  else
  {
    rc=FALSE;
    EasyRequestAllWins("Error on allocating signal for\n"
                       "notifying",
                       "Ok");
  }

  DEBUG_PRINTF("    -- returning --\n\n");
  return(rc);
}

/* ======================================================================================= End Of File
*/
