#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <math.h>

#include <proto/intuition.h>
#include <proto/asl.h>
#include <libraries/asl.h>

#define WIDTH 160
#define WIDTH2 (WIDTH>>1)

#define TURN_ANGLE 30
#define ANGLE_STEP 1
#define ANGLE_NUMBER (TURN_ANGLE*2/ANGLE_STEP +1)

WORD TurnTable[WIDTH*ANGLE_NUMBER];


void main(void)
{
struct FileRequester *FileReq;
char FileName[256];
FILE *FileHandle;
LONG i, j, index;
DOUBLE tmp;

  index = 0;
  for(i=-TURN_ANGLE; i<=TURN_ANGLE; i+=ANGLE_STEP)
  {
    printf("\rangle: %d  ", i);

    for(j=0; j<WIDTH; j++)
    {
      tmp = (DOUBLE)(j-WIDTH2)*(-sin(2.0*PI*i/360.0));
      TurnTable[index] = (WORD)tmp;
      index++;
    }
  }



  if(FileReq = AllocAslRequestTags(ASL_FileRequest, TAG_DONE))
  {
    WBenchToFront();
    if(AslRequestTags(FileReq, ASLFR_PubScreenName, NULL,
                               ASLFR_SleepWindow, TRUE,
                               ASLFR_TitleText, "Save turn table!",
                               ASLFR_PositiveText, "Save",
                               ASLFR_NegativeText, "Cancel",
                               TAG_DONE))
    {
      strcpy(&FileName[0], FileReq->fr_Drawer);
      if(FileName[strlen(FileName)-1] != ':')
      {
        FileName[strlen(FileName)+1] = '\0';
        FileName[strlen(FileName)] = '/';
      };
      strcpy(&FileName[strlen(FileName)], FileReq->fr_File);
    }
    else
      exit(0);

    if(FileHandle = fopen((char const *)&FileName, "w"))
    {
      fwrite(&TurnTable, WIDTH*2, ANGLE_NUMBER, FileHandle);
      fclose(FileHandle);
    }
    else
    {
      printf("Can't save table file: %s !\n", FileName);
      exit(0);
    }
  }
  else
  {
    printf("Can't allocated file requester!\n");
    exit(0);
  }

  FreeAslRequest(FileReq);

  printf("\nAll done!\n");
  exit(0);
}
