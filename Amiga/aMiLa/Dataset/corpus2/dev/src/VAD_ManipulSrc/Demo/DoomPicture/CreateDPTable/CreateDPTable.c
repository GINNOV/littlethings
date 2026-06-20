#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#include <math.h>
#include <proto/intuition.h>
#include <proto/asl.h>
#include <libraries/asl.h>

#define ANGLE_STEP 5

ULONG DPOffset[90/ANGLE_STEP+2];
ULONG DPTable[90/ANGLE_STEP*64*5];
ULONG TmpTable[90/ANGLE_STEP*64*5];

#define SIGN(x) ((x==0) ? 0 : x/fabs(x))

void main(void)
{
ULONG i, j, index, index1, index2;
struct FileRequester *FileReq;
char FileName[256];
FILE *FileHandle;
DOUBLE TmpCos;
ULONG tmp, old_tmp;
ULONG src, old_src, dest, aux;

  index = 0;
  old_tmp = 1000;

  for(j=ANGLE_STEP; j<=90; j+=ANGLE_STEP)
  {
    printf("\r%d", j);
    TmpCos = cos(PI*(DOUBLE)(90-j)/180.0);

    for(i=0; i<64; i++)
    {
      tmp = (ULONG)(31.5+((DOUBLE)i-31.5)*TmpCos+(0.5*SIGN(TmpCos)));

      if(tmp != old_tmp)
      {
        TmpTable[index] = i*640;
        TmpTable[index+1] = tmp*640;
        TmpTable[index+2] = 0x02040007;
        index += 3;
        old_tmp = tmp;
      }
    }
    TmpTable[index] = 0xffffffff;
    index++;
  }

  index = 0;
  index1 = 0;
  index2 = 0;
  DPOffset[0] = 0;

  old_src = 0xffffffff;

  do
  {
    src = TmpTable[index];
    index++;

    if(src == 0xffffffff)
    {
      DPTable[index1] = 0xffffffff;
      index1++;
      index2++;
      DPOffset[index2] = index1*4;
      old_src = 0xffffffff;
    }
    else
    {
      dest = TmpTable[index];
      aux = TmpTable[index+1];
      index += 2;

      if(src == old_src)
      {
        DPTable[index1-1] += 0x02000008;
        old_src += 640;
      }
      else
      {
        DPTable[index1] = src;
        DPTable[index1+1] = dest;
        DPTable[index1+2] = aux;
        index1 += 3;
        old_src = src+640;
      }
    }

  }
  while(index2 < (90/ANGLE_STEP));

  if(FileReq = AllocAslRequestTags(ASL_FileRequest, TAG_DONE))
  {
    WBenchToFront();
    if(AslRequestTags(FileReq, ASLFR_PubScreenName, NULL,
                               ASLFR_SleepWindow, TRUE,
                               ASLFR_TitleText, "Save DPOffset!",
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
      fwrite(DPOffset, 4, 90/ANGLE_STEP, FileHandle);
      fclose(FileHandle);
    }
  }

  if(FileReq = AllocAslRequestTags(ASL_FileRequest, TAG_DONE))
  {
    WBenchToFront();
    if(AslRequestTags(FileReq, ASLFR_PubScreenName, NULL,
                               ASLFR_SleepWindow, TRUE,
                               ASLFR_TitleText, "Save DPTable!",
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
      fwrite(DPTable, 4, index1, FileHandle);
      fclose(FileHandle);
    }
  }

  printf("All done!\n");
  exit(0);
}
