#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#include <math.h>
#include <proto/intuition.h>
#include <proto/asl.h>
#include <libraries/asl.h>

#define RADIUS 200.0
#define CURVE_LEN 400

UBYTE Curve[300];

void main(void)
{
struct FileRequester *FileReq;
char FileName[256];
FILE *FileHandle;
ULONG i;
ULONG x;

  for(i=0; i<300; i++)
  {
    x = (ULONG)(RADIUS-RADIUS*cos((DOUBLE)i*PI/CURVE_LEN/2.0));

    printf("%d\n", x);
    Curve[i] = x;
  }

  if(FileReq = AllocAslRequestTags(ASL_FileRequest, TAG_DONE))
  {
    WBenchToFront();
    if(AslRequestTags(FileReq, ASLFR_PubScreenName, NULL,
                               ASLFR_SleepWindow, TRUE,
                               ASLFR_TitleText, "Save curve table!",
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
      fwrite(Curve, 300, 1, FileHandle);
      fclose(FileHandle);
    }
  }

  printf("All done!\n");
  exit(0);
}
