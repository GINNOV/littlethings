/*
** PROGRAMM:  AmigaGuideDesigner
** AUTOR:     Michael Weiser
** COPYRIGHT: ©1994 Michael Weiser (Giftware)
** COMPILER:  SAS/C 6.5
**
** MODUL:     Project.c
** FUNKTION:  Project-Funktionen für AmigaGuideDesigner
**
*/

/*#define DEBUG*/
#include "AGD.h"

#define ID_AGDP MAKE_ID('A','G','D','P')
#define ID_AGUI MAKE_ID('A','G','U','I')
#define ID_DOC  MAKE_ID('D','O','C',' ')
#define ID_COMM MAKE_ID('C','O','M','M')
#define ID_TEXT MAKE_ID('T','E','X','T')

       char         *ProjectName=NULL;

struct AGuideVars {
                   UWORD FontSize;
                   BOOL  WordWrap;
                  };

struct CommVars {
                 LONG  Line;
                 WORD  Char;
                 WORD  Len;
                 UBYTE Type;
                 UBYTE FGPen;
                 UBYTE BGPen;
                 UBYTE Style;
                };

static
void GetProjStr(char **ptr,char **buf)
{
  if (*buf) FreeVec(*buf);
  *buf=mstrdup(*ptr);
  *ptr+=strlen(*ptr)+1;
}

static
void PutProjStr(char **ptr,char *buf)
{
  strcpy(*ptr,buf);
  *ptr+=strlen(*ptr)+1;
}
              
/* ======================================================================================= LoadProject
** lädt das Project
*/
BOOL LoadProject(void)
{
  BOOL   rc=TRUE;
  struct IFFHandle *iff;

  DEBUG_PRINTF("\n    -- Invoking LoadProject-function --\n");

  /* IFFHandle anfordern */
  if (iff=AllocIFF())
  {
    DEBUG_PRINTF("    iff allocated\n");

    /* File öffnen */
    if (iff->iff_Stream=Open(ProjectName,MODE_OLDFILE))
    {
      DEBUG_PRINTF("    iff->iff_Stream opened\n");

      /* als DOS-Stream initialisieren */
      InitIFFasDOS(iff);
      DEBUG_PRINTF("    iff initialized as DOS\n");

      /* IFF öffnen */
      if (!OpenIFF(iff,IFFF_READ))
      {
        struct ContextNode *cn;

        DEBUG_PRINTF("    iff opened with IFFF_READ\n");

        if (!ParseIFF(iff,IFFPARSE_STEP) &&
            (cn=CurrentChunk(iff)) && (cn->cn_ID==ID_FORM) && (cn->cn_Type==ID_AGDP) &&
            !ParseIFF(iff,IFFPARSE_STEP) &&
            (cn=CurrentChunk(iff)) && (cn->cn_ID==ID_AGUI) && (cn->cn_Type==ID_AGDP))
        {
          char  *buf;
          ULONG  bufsize=cn->cn_Size;

          DEBUG_PRINTF("    chunk ID_AGDP,ID_FORM found\n"
                       "    chunk ID_AGDP,ID_AGUI found\n");

          if ((buf=(char *)
              AllocMem(bufsize,MEMF_ANY||MEMF_PUBLIC)) &&
              ReadChunkBytes(iff,buf,bufsize)==bufsize)
          {
            struct AGuideVars *av=(struct AGuideVars *)buf;
            char *ptr=buf+sizeof(struct AGuideVars);

            DEBUG_PRINTF("    buf allocated\n");

            AGuide.gt_FoSize  =av->FontSize;
            AGuide.gt_WordWrap=av->WordWrap;
            DEBUG_PRINTF("    Vars copied\n");

            GetProjStr(&ptr,&AGuide.gt_Database);
            GetProjStr(&ptr,&AGuide.gt_Author);
            GetProjStr(&ptr,&AGuide.gt_Copyright);
            GetProjStr(&ptr,&AGuide.gt_Version);
            GetProjStr(&ptr,&AGuide.gt_Master);
            GetProjStr(&ptr,&AGuide.gt_Font);
            GetProjStr(&ptr,&AGuide.gt_Index);
            GetProjStr(&ptr,&AGuide.gt_Help);
            DEBUG_PRINTF("    Strings copied\n");

            FreeMem(buf,bufsize);
            DEBUG_PRINTF("    buf freed\n");

            ParseIFF(iff,IFFPARSE_STEP);

            while ((cn=CurrentChunk(iff)) && (cn->cn_ID==ID_DOC) && (cn->cn_Type==ID_AGDP))
            {
              struct Document *curdoc=(struct Document *)&AGuide.gt_Docs,*newdoc=NULL;

              DEBUG_PRINTF("    chunk ID_AGDP,ID_DOC found\n");

              bufsize=cn->cn_Size;

              if ((buf=(char *)
                  AllocMem(bufsize,MEMF_ANY|MEMF_PUBLIC)) &&
                  ReadChunkBytes(iff,buf,bufsize)==bufsize &&
                  (newdoc=InsertDoc(curdoc)))
              {
                DEBUG_PRINTF("    newdoc inserted\n");

                ptr=buf;
                GetProjStr(&ptr,&newdoc->doc_FileName);
                GetProjStr(&ptr,&newdoc->doc_Node.ln_Name);
                GetProjStr(&ptr,&newdoc->doc_WinTitle);
                GetProjStr(&ptr,&newdoc->doc_NextNode);
                GetProjStr(&ptr,&newdoc->doc_PrevNode);
                GetProjStr(&ptr,&newdoc->doc_TOCNode);
                DEBUG_PRINTF("    strings copied\n");

                FreeMem(buf,bufsize);
                DEBUG_PRINTF("    buf freed\n");

                ParseIFF(iff,IFFPARSE_STEP);

                while ((cn=CurrentChunk(iff)) && (cn->cn_ID==ID_COMM) && (cn->cn_Type==ID_AGDP) &&
                       rc)
                {
                  char  *buf;
                  ULONG  bufsize=cn->cn_Size;

                  DEBUG_PRINTF("    chunk ID_AGDP,ID_AGD_COMM found\n");

                  if ((buf=(char *)
                      AllocMem(bufsize,MEMF_ANY|MEMF_PUBLIC)) &&
                      ReadChunkBytes(iff,buf,bufsize)==bufsize)
                  {
                    struct CommVars *cv=(struct CommVars *)buf;
                    struct Command *curcom;

                    DEBUG_PRINTF("    data read from chunk\n");

                    if (curcom=InsertComm(curdoc,cv->Line,cv->Char,cv->Len))
                    {
                      DEBUG_PRINTF("    a new command inserted\n");

                      curcom->com_Type =cv->Type;
                      curcom->com_FGPen=cv->FGPen;
                      curcom->com_BGPen=cv->BGPen;
                      curcom->com_Style=cv->Style;
                      DEBUG_PRINTF("    vars copied\n");

                      ptr=buf+sizeof(struct CommVars);
                      GetProjStr(&ptr,&curcom->com_StrData);
                      DEBUG_PRINTF("    string copied\n");
                    }
                    else
                    {
                      rc=FALSE;
                      DEBUG_PRINTF("    error on inserting a new command\n");
                    }

                    FreeMem(buf,bufsize);
                    DEBUG_PRINTF("    buf freed\n");
                  }
                  else
                  {
                    rc=FALSE;
                    DEBUG_PRINTF("    error on reading data from chunk\n");
                  }

                  ParseIFF(iff,IFFPARSE_STEP);
                }

                if ((cn=CurrentChunk(iff)) && (cn->cn_ID==ID_TEXT) && (cn->cn_Type==ID_AGDP))
                {
                  DEBUG_PRINTF("    chunk ID_AGDP,ID_TEXT found\n");
                  ParseIFF(iff,IFFPARSE_STEP);
                }
              }
              else
              {
                rc=FALSE;
                DEBUG_PRINTF("    error on allocating buf and/or reading data from chunk\n");
              }
            }
          }
          else
          {
            DEBUG_PRINTF("    error on allocating buf and/or reading data from chunk\n");
            rc=FALSE;
          }
        }
        else
        {
          DEBUG_PRINTF("    error on searching ID_AGDP,ID_AGUI chunk\n");
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

  DEBUG_PRINTF("    -- returning --\n\n");
  return(rc);
}
/* ======================================================================================= SaveProject
** sichert das Project
*/
BOOL SaveProject(void)
{
  BOOL   rc=TRUE;
  struct IFFHandle *iff;

  DEBUG_PRINTF("\n    -- Invoking SaveProject-function --\n");

  /* IFFHandle anfordern */
  if (iff=AllocIFF())
  {
    DEBUG_PRINTF("    iff allocated\n");

    /* File öffnen */
    if (iff->iff_Stream=Open(ProjectName,MODE_NEWFILE))
    {
      DEBUG_PRINTF("    iff->iff_Stream opened\n");

      /* als DOS-Stream initialisieren */
      InitIFFasDOS(iff);
      DEBUG_PRINTF("    iff initialized as DOS\n");

      /* IFF öffnen */
      if (!OpenIFF(iff,IFFF_WRITE))
      {
        DEBUG_PRINTF("    iff opened with IFFF_WRITE\n");

        if (!PushChunk(iff,ID_AGDP,ID_FORM,IFFSIZE_UNKNOWN))
        {
          DEBUG_PRINTF("    chunk ID_AGDP,ID_FORM pushed with IFFSIZE_UNKNOWN\n");

          if (!PushChunk(iff,ID_AGDP,ID_AGUI,IFFSIZE_UNKNOWN))
          {
            char *buf;
            ULONG bufsize;

            DEBUG_PRINTF("    chunk ID_AGDP,ID_AGUI pushed with IFFSIZE_UNKNOWN\n");

            bufsize=sizeof(struct AGuideVars);
            bufsize+=strlen(AGuide.gt_Database);
            bufsize+=strlen(AGuide.gt_Author);
            bufsize+=strlen(AGuide.gt_Copyright);
            bufsize+=strlen(AGuide.gt_Version);
            bufsize+=strlen(AGuide.gt_Master);
            bufsize+=strlen(AGuide.gt_Font);
            bufsize+=strlen(AGuide.gt_Index);
            bufsize+=strlen(AGuide.gt_Help)+8;

            if (buf=(char *)
                AllocMem(bufsize,MEMF_ANY|MEMF_PUBLIC))
            {
              struct AGuideVars *av=(struct AGuideVars *)buf;
              char *ptr=buf+sizeof(struct AGuideVars);

              DEBUG_PRINTF("    buf allocated\n");

              av->FontSize=AGuide.gt_FoSize;
              av->WordWrap=AGuide.gt_WordWrap;

              PutProjStr(&ptr,AGuide.gt_Database);
              PutProjStr(&ptr,AGuide.gt_Author);
              PutProjStr(&ptr,AGuide.gt_Copyright);
              PutProjStr(&ptr,AGuide.gt_Version);
              PutProjStr(&ptr,AGuide.gt_Master);
              PutProjStr(&ptr,AGuide.gt_Font);
              PutProjStr(&ptr,AGuide.gt_Index);
              PutProjStr(&ptr,AGuide.gt_Help);

              if (WriteChunkBytes(iff,buf,bufsize)==bufsize && !PopChunk(iff))
              {
                struct Document *curdoc=(struct Document *)AGuide.gt_Docs.lh_Head;

                DEBUG_PRINTF("    buf written\n");

                while (curdoc->doc_Node.ln_Succ && rc)
                {
                  if (!PushChunk(iff,ID_AGDP,ID_DOC,IFFSIZE_UNKNOWN))
                  {
                    char  *buf;
                    ULONG  bufsize;

                    DEBUG_PRINTF("    chunk ID_AGDP,ID_DOC pushed with IFFSIZE_UNKNOWN\n");

                    bufsize=strlen(curdoc->doc_FileName);
                    bufsize+=strlen(curdoc->doc_Node.ln_Name);
                    bufsize+=strlen(curdoc->doc_WinTitle);
                    bufsize+=strlen(curdoc->doc_NextNode);
                    bufsize+=strlen(curdoc->doc_PrevNode);
                    bufsize+=strlen(curdoc->doc_TOCNode)+6;

                    if (buf=(char *)
                        AllocMem(bufsize,MEMF_ANY|MEMF_PUBLIC))
                    {
                      DEBUG_PRINTF("    buf allocated\n");

                      ptr=buf;
                      PutProjStr(&ptr,curdoc->doc_FileName);
                      PutProjStr(&ptr,curdoc->doc_Node.ln_Name);
                      PutProjStr(&ptr,curdoc->doc_WinTitle);
                      PutProjStr(&ptr,curdoc->doc_NextNode);
                      PutProjStr(&ptr,curdoc->doc_PrevNode);
                      PutProjStr(&ptr,curdoc->doc_TOCNode);

                      if (WriteChunkBytes(iff,buf,bufsize)==bufsize && !PopChunk(iff))
                      {
                        DEBUG_PRINTF("    buf written\n");

                        if (curdoc->doc_Comms)
                        {
                          LONG curln=0;

                          DEBUG_PRINTF("    curdoc->doc_Comms valid\n");

                          while (curln<curdoc->doc_NumLn)
                          {
                            struct Command *curcom=GetCommVecLnHead(curdoc,curln);

                            while (curcom->com_Node.mln_Succ && rc)
                            {
                              if (!PushChunk(iff,ID_AGDP,ID_COMM,IFFSIZE_UNKNOWN))
                              {
                                char  *buf;
                                ULONG  bufsize;

                                DEBUG_PRINTF("    chunk ID_AGDP,ID_COMM pushed with IFFSIZE_UNKNOWN\n");

                                bufsize=sizeof(struct CommVars);
                                bufsize+=strlen(curcom->com_StrData)+1;

                                if (buf=(char *)
                                    AllocMem(bufsize,MEMF_ANY|MEMF_PUBLIC))
                                {
                                  struct CommVars *cv=(struct CommVars *)buf;

                                  DEBUG_PRINTF("    buf allocated\n");

                                  cv->Line =curln;
                                  cv->Char =curcom->com_Char;
                                  cv->Len  =curcom->com_Len;
                                  cv->Type =curcom->com_Type;
                                  cv->FGPen=curcom->com_FGPen;
                                  cv->BGPen=curcom->com_BGPen;
                                  cv->Style=curcom->com_Style;

                                  ptr=buf+sizeof(struct CommVars);
                                  PutProjStr(&ptr,curcom->com_StrData);

                                  if (WriteChunkBytes(iff,buf,bufsize)!=bufsize || PopChunk(iff))
                                  {
                                    rc=FALSE;
                                    DEBUG_PRINTF("    error on writing chunkbytes to chunk ID_AGDP,ID_COMM\n");
                                  }

                                  FreeMem(buf,bufsize);
                                  DEBUG_PRINTF("    buf freed\n");
                                }
                                else
                                {
                                  rc=FALSE;
                                  DEBUG_PRINTF("    error on allocating buf\n");
                                }
                              }
                              else
                              {
                                rc=FALSE;
                                DEBUG_PRINTF("    error on pushing chunk ID_AGDP,ID_COMM with IFFSIZE_UNKNOWN\n");
                              }

                              curcom=(struct Command *)curcom->com_Node.mln_Succ;
                              DEBUG_PRINTF("    curcom=curcom->Succ\n");
                            }

                            curln++;
                            DEBUG_PRINTF("    curln++\n");
                          }
                        }

                        if (!curdoc->doc_FileName && curdoc->doc_Buf)
                        {
                          DEBUG_PRINTF("    curdoc->doc_FileName not valid\n");

                          if (PushChunk(iff,ID_AGDP,ID_TEXT,IFFSIZE_UNKNOWN) ||
                              WriteChunkBytes(iff,curdoc->doc_Buf,curdoc->doc_BufLen)!=curdoc->doc_BufLen ||
                              PopChunk(iff))
                          {
                            rc=FALSE;
                            DEBUG_PRINTF("    error on pushing/writing/poping chunk ID_AGDP,ID_TEXT\n");
                          }
                        }
                      }
                      else
                      {
                        rc=FALSE;
                        DEBUG_PRINTF("    error on writing buf to chunk ID_AGDP,ID_DOC\n");
                      }

                      FreeMem(buf,bufsize);
                      DEBUG_PRINTF("    buf freed\n");
                    }
                    else
                    {
                      rc=FALSE;
                      DEBUG_PRINTF("    error on allocating buf\n");
                    }
                  }
                  else
                  {
                    DEBUG_PRINTF("    error on pushing chunk ID_AGDP,ID_DOC\n");
                    rc=FALSE;
                  }

                  curdoc=(struct Document *)curdoc->doc_Node.ln_Succ;
                  DEBUG_PRINTF("    curdoc=curdoc->Succ\n");
                }
              }
              else
              {
                rc=FALSE;
                DEBUG_PRINTF("    error on writing to chunk ID_AGDP,ID_AGUI\n");
              }

              FreeMem(buf,bufsize);
              DEBUG_PRINTF("    buf freed\n");
            }
            else
            {
              rc=FALSE;
              DEBUG_PRINTF("    error on allocating buf\n");
            }
          }
          else
          {
            DEBUG_PRINTF("    error on bushing chunk ID_AGDP,ID_AGUI\n");
            rc=FALSE;
          }

          if (PopChunk(iff))
          {
            rc=FALSE;
            DEBUG_PRINTF("    error on poping chunk ID_AGDP,ID_FORM\n");
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

  DEBUG_PRINTF("    -- returning --\n\n");
  return(rc);
}

/* ======================================================================================= End of File
*/
