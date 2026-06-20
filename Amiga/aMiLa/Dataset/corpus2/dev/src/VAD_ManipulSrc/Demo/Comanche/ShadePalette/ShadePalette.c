#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#include <proto/intuition.h>
#include <proto/asl.h>
#include <libraries/asl.h>


UBYTE Palette[256][4];
UBYTE SPalette[128][256];
ULONG Fit;


UBYTE BestFitColor(UBYTE r, UBYTE g, UBYTE b)
{
ULONG i;
UBYTE color;
ULONG current_fit;

  Fit = 0xffffffff;
  for(i=0; i<256; i++)
  {
    current_fit = (ULONG)(Palette[i][1]-r) * (ULONG)(Palette[i][1]-r)+
                  (ULONG)(Palette[i][2]-g) * (ULONG)(Palette[i][2]-g)+
                  (ULONG)(Palette[i][3]-b) * (ULONG)(Palette[i][3]-b);
    if(current_fit<Fit)
    {
      Fit = current_fit;
      color = i;
    }
  }

  return color;
}


void ShadingPalette(void)
{
ULONG i, j;
UBYTE c, r, g, b;

  for(i=0; i<256; i++)
  {
    printf("\rColor: %d", i);
    r = Palette[i][1];
    g = Palette[i][2];
    b = Palette[i][3];
    for(j=0; j<128; j++)
    {
      c = BestFitColor(r*j/127, g*j/127, b*j/127);
      SPalette[127-j][i] = c;
    }
  }
  printf("\n");
}





void main(void)
{
struct FileRequester *FileReq;
char FileName[256];
FILE *FileHandle;

  printf("PaletteShading for VoxelTerain written by Noe/Venus Art  ©1995 by VenusArt Inc.\n\n");

  if(FileReq = AllocAslRequestTags(ASL_FileRequest, TAG_DONE))
  {
    WBenchToFront();
    if(AslRequestTags(FileReq, ASLFR_PubScreenName, NULL,
                               ASLFR_SleepWindow, TRUE,
                               ASLFR_TitleText, "Load raw 24-bit palette!",
                               ASLFR_PositiveText, "Load",
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
      printf("You must load any palette!\n");
      exit(0);
    }

    if(FileHandle = fopen((char const *)&FileName, "r"))
    {
      fread(&Palette, 4, 256, FileHandle);
      fclose(FileHandle);
    }
    else
    {
      printf("Can't load palette file: %s !\n", FileName);
      exit(0);
    }
  }
  else
  {
    printf("Can't allocated file requester!\n");
    exit(0);
  }

  printf("Shading palette...\n\n");

  ShadingPalette();

  WBenchToFront();
  if(AslRequestTags(FileReq, ASLFR_PubScreenName, NULL,
                             ASLFR_SleepWindow, TRUE,
                             ASLFR_TitleText, "Save shading palette!",
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

    if(FileHandle = fopen((char const *)&FileName, "w"))
    {
      fwrite(&SPalette, 128, 256, FileHandle);
      fclose(FileHandle);
    }
    else
    {
      printf("Can't save shading palette file: %s !\n", FileName);
      exit(0);
    }
  }

  FreeAslRequest(FileReq);

  printf("All done!\n");
  exit(0);
}
