#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <math.h>
#include <exec/types.h>

#define ANGLE_NUMBER 360
#define ANGLE_NUM (ANGLE_NUMBER+(ANGLE_NUMBER>>2))

WORD RotXTable[ANGLE_NUM*160];
WORD RotYTable[ANGLE_NUM*160];

VOID main(VOID)
{
FILE *FileHandle;
LONG i, j, a, tmp;
DOUBLE angle;

  a = 0;
  for(j=0; j<ANGLE_NUM; j++)
  {
    angle = (DOUBLE)(PI*2.0*(DOUBLE)j/(DOUBLE)ANGLE_NUMBER);
    for(i=-79; i<=80; i++)
    {
      tmp  = ((LONG)(sin(angle)*(DOUBLE)i));
      RotXTable[a] = (WORD)tmp;
      RotYTable[a] = (WORD)(tmp*128);
      a++;
    }
    printf("\r%d", j);
  }

  FileHandle = fopen("demo:data/WTX2.data", "w");
  fwrite(RotXTable, ANGLE_NUM*160, 2, FileHandle);
  fclose(FileHandle);

  FileHandle = fopen("demo:data/WTY2.data", "w");
  fwrite(RotYTable, ANGLE_NUM*160, 2, FileHandle);
  fclose(FileHandle);

  printf("All done!\n");
  exit(0);
}
