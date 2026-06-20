#include <stdio.h>
#include <stdlib.h>
#include <math.h>
#include <string.h>

#include <proto/intuition.h>
#include <proto/asl.h>
#include <libraries/asl.h>

#define RAY_LENGTH 128

UWORD *RayTable;
LONG ObserverDist;
LONG RayNumber;

void main(void)
{
struct FileRequester *FileReq;
char FileName[256];
FILE *FileHandle;
LONG ray, dist;
LONG x, y;
DOUBLE angle, Sine, Cosine;
LONG index;
LONG rx, ry;

  printf("Enter observer distance: ");
  scanf("%d", &ObserverDist);
  printf("Enter ray number: ");
  scanf("%d", &RayNumber);

  RayTable = malloc(RayNumber*RAY_LENGTH);

  index = 0;

  for(ray=0; ray<RayNumber; ray++)
  {
    printf("\rRay: %d", ray);

    angle = 2.0*PI*(DOUBLE)ray/(DOUBLE)RayNumber;
    Sine = sin(angle);
    Cosine = cos(angle);

    for(dist=ObserverDist; dist<(ObserverDist+RAY_LENGTH); dist++)
    {
      x = (LONG)(((DOUBLE)dist)*Sine);
      y = (LONG)(((DOUBLE)dist)*Cosine);

      rx = x%256;
      ry = y%256;

      if(rx < 0)
        rx += 256;

      if(ry < 0)
        ry += 256;

      RayTable[index] = (ry<<8)+rx;
      index++;
    }
  }

  if(FileReq = AllocAslRequestTags(ASL_FileRequest, TAG_DONE))
  {
    WBenchToFront();
    if(AslRequestTags(FileReq, ASLFR_PubScreenName, NULL,
                               ASLFR_SleepWindow, TRUE,
                               ASLFR_TitleText, "Save ray table!",
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
    {
      free(RayTable);
      exit(0);
    }

    if(FileHandle = fopen((char const *)&FileName, "w"))
    {
      fwrite(RayTable, 2, index, FileHandle);
      fclose(FileHandle);
    }
    else
    {
      printf("Can't save ray table: %s!\n", FileName);
      free(RayTable);
      exit(0);
    }
  }
  else
  {
    printf("Can't allocated file requester!\n");
    free(RayTable);
    exit(0);
  }


  free(RayTable);

  printf("\nDone!\n");
}
