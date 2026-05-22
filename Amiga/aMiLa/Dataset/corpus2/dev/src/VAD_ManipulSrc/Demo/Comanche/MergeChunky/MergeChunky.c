#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#include <proto/intuition.h>
#include <proto/asl.h>
#include <libraries/asl.h>


UBYTE Map[256*256];
UBYTE Texture[256*256];

UBYTE MergedMap[256*256*2];



void main(void)
{
ULONG i;
struct FileRequester *FileReq;
char FileName[256];
FILE *FileHandle;

  if(FileReq = AllocAslRequestTags(ASL_FileRequest, TAG_DONE))
  {
    WBenchToFront();
    if(AslRequestTags(FileReq, ASLFR_PubScreenName, NULL,
                               ASLFR_SleepWindow, TRUE,
                               ASLFR_TitleText, "Load VoxelSpace map!",
                               ASLFR_PositiveText, "Load",
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

    if(FileHandle = fopen((char const *)&FileName, "r"))
    {
      fread(Map, 256, 256, FileHandle);
      fclose(FileHandle);
    }
  }

  if(FileReq = AllocAslRequestTags(ASL_FileRequest, TAG_DONE))
  {
    WBenchToFront();
    if(AslRequestTags(FileReq, ASLFR_PubScreenName, NULL,
                               ASLFR_SleepWindow, TRUE,
                               ASLFR_TitleText, "Load VoxelSpace texture!",
                               ASLFR_PositiveText, "Load",
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

    if(FileHandle = fopen((char const *)&FileName, "r"))
    {
      fread(Texture, 256, 256, FileHandle);
      fclose(FileHandle);
    }
  }

  printf("Merge...\n");

  for(i=0; i<65536; i++)
  {
    MergedMap[i<<1] = Map[i];
    MergedMap[(i<<1)+1] = Texture[i];
  }

  if(FileReq = AllocAslRequestTags(ASL_FileRequest, TAG_DONE))
  {
    WBenchToFront();
    if(AslRequestTags(FileReq, ASLFR_PubScreenName, NULL,
                               ASLFR_SleepWindow, TRUE,
                               ASLFR_TitleText, "Save merged maps!",
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
      fwrite(MergedMap, 256*2, 256, FileHandle);
      fclose(FileHandle);
    }
  }

  printf("All done!\n");
  exit(0);
}
