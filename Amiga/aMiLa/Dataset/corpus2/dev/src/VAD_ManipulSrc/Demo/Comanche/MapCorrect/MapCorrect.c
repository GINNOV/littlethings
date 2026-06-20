#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#include <math.h>
#include <proto/intuition.h>
#include <proto/asl.h>
#include <libraries/asl.h>


UBYTE Sine[960+240];


void main(void)
{
ULONG i;
struct FileRequester *FileReq;
char FileName[256];
FILE *FileHandle;
DOUBLE tmp;
LONG correct;

  printf("Enter correct value: ");
  scanf("%d", &correct);

  for(i=0; i<1200; i++)
  {
    tmp = sin(2.0*PI*(DOUBLE)i/960.0)*(DOUBLE)correct;
    if(tmp < 0)
      tmp += 256.0;
    Sine[i] = (UBYTE)tmp;
  }

  if(FileReq = AllocAslRequestTags(ASL_FileRequest, TAG_DONE))
  {
    WBenchToFront();
    if(AslRequestTags(FileReq, ASLFR_PubScreenName, NULL,
                               ASLFR_SleepWindow, TRUE,
                               ASLFR_TitleText, "Save correct table!",
                               ASLFR_PositiveText, "Save",
                               ASLFR_NegativeText, "Cancel",
                               TAG_DONE))
    {
      strcpy(&FileName[0], FileReq->fr_Drawer);
      if(FileName[strlen(FileName)-1] != ':')
      {
        FileName[strlen(FileName)+1] = '\0';
        FileName[strlen(FileName)] = '/';
      }
      strcpy(&FileName[strlen(FileName)], FileReq->fr_File);
    }
    FreeAslRequest(FileReq);

    if(FileHandle = fopen((char const *)&FileName, "w"))
    {
      fwrite(Sine, 1, 1200, FileHandle);
      fclose(FileHandle);
    }
  }

  printf("All done!\n");
  exit(0);
}
