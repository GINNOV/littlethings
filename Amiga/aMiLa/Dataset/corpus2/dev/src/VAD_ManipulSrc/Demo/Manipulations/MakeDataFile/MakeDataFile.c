#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <exec/exec.h>
#include <dos/dos.h>
#include <libraries/ppbase.h>

#include <proto/exec.h>
#include <proto/dos.h>
#include <proto/asl.h>
#include <proto/intuition.h>
#include <proto/powerpacker.h>


typedef
  struct DataHeader
  {
    ULONG MemType;
    ULONG CrunchSize;
    ULONG Size;
  } DATA_HEADER;

const TEXT PublicConst[] = "PUBLIC\n\0";
const TEXT ChipConst[] = "CHIP\n\0";
const TEXT FastConst[] = "FAST\n\0";

const TEXT ClearConst[] = "CLEAR\n\0";
const TEXT EndConst[] = "END\n\0";
const TEXT EmptyConst[] = "\n\0";

struct PPBase *PPBase = NULL;

BPTR DataFile;
TEXT FileNameTable[128][256];
FILE *ReportFile;
ULONG FileSizeTable[128];
ULONG MemType;


BOOL __stdargs __saveds PercentCrunch(ULONG sofar, ULONG crunlen,
                                      ULONG totlen, APTR userdata)
{

  printf("\r%ld%% crunched", (sofar * 100) / totlen);

  return (TRUE);
}


#define DATA_HEADER_LEN 8

BOOL CreateData(ULONG n)
{
ULONG Size = 0;
ULONG i;
UBYTE *Buffer, *TmpBuffer;
FILE *TmpFile;
DATA_HEADER dh;
APTR ci;

  for(i=0; i<n; i++)
    Size += FileSizeTable[i];

  dh.Size = Size;
  dh.MemType = MemType;

  if(Buffer = malloc(Size))
  {
    TmpBuffer = Buffer;
    for(i=0; i<n; i++)
    {
      if(TmpFile = fopen(FileNameTable[i], "rb"))
      {
        fread(TmpBuffer, 1, FileSizeTable[i], TmpFile);
        fclose(TmpFile);
      }
      else
      {
        printf("Can't open file: %s\n", FileNameTable[i]);
        return FALSE;
      }

      fprintf(ReportFile, "Name: %s  Offset: %d  Size: %d\n",
              FileNameTable[i], TmpBuffer-Buffer, FileSizeTable[i]);
      TmpBuffer += FileSizeTable[i];
    }

    if(ci = ppAllocCrunchInfo(CRUN_BEST, SPEEDUP_BUFFLARGE, PercentCrunch, NULL))
    {
      printf("Size: %d\n", dh.Size);
      dh.CrunchSize = ppCrunchBuffer(ci, Buffer, Size) + DATA_HEADER_LEN;
      printf("\rCrunchSize: %d  (%d%% of Size)   \n", dh.CrunchSize,
              (dh.CrunchSize*100)/dh.Size);

      Write(DataFile, &dh, sizeof(DATA_HEADER));
      ppWriteDataHeader(DataFile, CRUN_BEST, FALSE, 0L);
      Write(DataFile, Buffer, dh.CrunchSize - DATA_HEADER_LEN);

      ppFreeCrunchInfo(ci);
    }
    else
    {
      printf("Can't alloc CrunchInfo!\n");
      free(Buffer);
      return FALSE;
    }

    free(Buffer);

    return TRUE;
  }
  else
  {
    printf("Can't alloc buffer!\n");
    return FALSE;
  }
}


VOID main(VOID)
{
FILE *ScriptFile;
FILE *TmpFile;
struct FileRequester *FileReq;
TEXT DataFileName[256];
TEXT ScriptFileName[256];
TEXT ReportFileName[256];
TEXT TextBuffer[256];
ULONG FileIndex;

  if(!(PPBase = (struct PPBase *)OpenLibrary ("powerpacker.library", 0L)))
  {
    printf("Can't open PowerPacker library!\n");
    exit(0);
  }


  if(!(FileReq = AllocAslRequestTags(ASL_FileRequest, TAG_DONE)))
  {
    printf("Can't open file requester!\n");
    CloseLibrary ((struct Library *)PPBase);
    exit(0);
  }

  WBenchToFront();
  if(AslRequestTags(FileReq, ASLFR_PubScreenName, NULL,
                             ASLFR_SleepWindow, TRUE,
                             ASLFR_TitleText, "Select output data file ...",
                             ASLFR_PositiveText, "Ok",
                             ASLFR_NegativeText, "Cancel",
                             TAG_DONE))
  {
    strcpy(&DataFileName[0], FileReq->fr_Drawer);
    if(DataFileName[strlen(DataFileName)-1] != ':')
    {
      DataFileName[strlen(DataFileName)+1] = '\0';
      DataFileName[strlen(DataFileName)] = '/';
    }
    strcpy(&DataFileName[strlen(DataFileName)], FileReq->fr_File);
  }
  else
  {
    printf("You must select file!\n");
    FreeAslRequest(FileReq);
    CloseLibrary ((struct Library *)PPBase);
    exit(0);
  }


  if(!(DataFile = Open(DataFileName, MODE_READWRITE)))
  {
    printf("Can't open output data file: %s!\n", DataFileName);
    FreeAslRequest(FileReq);
    CloseLibrary ((struct Library *)PPBase);
    exit(0);
  }

  Seek(DataFile, 0, OFFSET_END);

  for(;;)
  {
    if(AslRequestTags(FileReq, ASLFR_PubScreenName, NULL,
                               ASLFR_SleepWindow, TRUE,
                               ASLFR_TitleText, "Select script file ...",
                               ASLFR_PositiveText, "Ok",
                               ASLFR_NegativeText, "Cancel",
                               TAG_DONE))
    {
      strcpy(&ScriptFileName[0], FileReq->fr_Drawer);
      if(ScriptFileName[strlen(ScriptFileName)-1] != ':')
      {
        ScriptFileName[strlen(ScriptFileName)+1] = '\0';
        ScriptFileName[strlen(ScriptFileName)] = '/';
      }
      strcpy(&ScriptFileName[strlen(ScriptFileName)], FileReq->fr_File);
    }
    else
     break;

    strcpy(ReportFileName, ScriptFileName);
    strcpy(&ReportFileName[strlen(ReportFileName)], (char const *)".report");

    if(!(ScriptFile = fopen(ScriptFileName, "r")))
    {
      printf("Can't open script file: %s!\n", ScriptFileName);
      Close(DataFile);
      FreeAslRequest(FileReq);
      CloseLibrary ((struct Library *)PPBase);
      exit(0);
    }

    if(!(ReportFile = fopen(ReportFileName, "w")))
    {
      printf("Can't open report file: %s!\n", ReportFileName);
      Close(DataFile);
      fclose(ScriptFile);
      FreeAslRequest(FileReq);
      CloseLibrary ((struct Library *)PPBase);
      exit(0);
    }

    fprintf(ReportFile, "Report for script: %s\n", ScriptFileName);

    MemType = MEMF_PUBLIC;
    FileIndex = 0;

    for(;;)
    {
      do
        fgets(TextBuffer, 256, ScriptFile);
      while(!strcmp(TextBuffer, EmptyConst));

      if(!strcmp(TextBuffer, PublicConst))
      {
        if(FileIndex)
          CreateData(FileIndex);
        MemType = MEMF_PUBLIC;
        FileIndex = 0;
        fprintf(ReportFile, "\nTo PUBLIC ...\n");
      }
      else if(!strcmp(TextBuffer, ChipConst))
      {
        if(FileIndex)
          CreateData(FileIndex);
        MemType = MEMF_CHIP;
        FileIndex = 0;
        fprintf(ReportFile, "\nTo CHIP ...\n");
      }
      else if(!strcmp(TextBuffer, FastConst))
      {
        if(FileIndex)
          CreateData(FileIndex);
        MemType = MEMF_FAST;
        FileIndex = 0;
        fprintf(ReportFile, "\nTo FAST ...\n");
      }
      else if(!strcmp(TextBuffer, ClearConst))
      {
        MemType |= MEMF_CLEAR;
      }
      else if(!strcmp(TextBuffer, EndConst))
      {
        if(FileIndex)
        {
          CreateData(FileIndex);
          break;
        }
      }
      else
      {
        TextBuffer[strlen(TextBuffer)-1] = '\0';
        strcpy(FileNameTable[FileIndex], TextBuffer);
        if(!(TmpFile = fopen(FileNameTable[FileIndex], "r")))
        {
          printf("Can't open file: %s!\n", FileNameTable[FileIndex]);
          fclose(ScriptFile);
          fclose(ReportFile);
          Close(DataFile);
          FreeAslRequest(FileReq);
          CloseLibrary ((struct Library *)PPBase);
          exit(0);
        }

        fseek(TmpFile, 0, SEEK_END);
        FileSizeTable[FileIndex] = ftell(TmpFile);

        fclose(TmpFile);

        FileIndex++;
      }
    }

    fclose(ScriptFile);
    fclose(ReportFile);
  }

  Close(DataFile);
  FreeAslRequest(FileReq);
  CloseLibrary ((struct Library *)PPBase);
  printf("All done!\n");
  exit(0);
}
