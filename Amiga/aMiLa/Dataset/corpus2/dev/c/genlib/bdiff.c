#include <stdlib.h>
#include <stdio.h>

typedef unsigned long  ulong;
typedef short word;
typedef unsigned short uword;
typedef unsigned char  ubyte;
typedef long bool;

FILE *FH1=NULL,*FH2=NULL;

int main(int argc,char *argv[])
{
long C1,C2;
long NumDiffs = 0;
long TotDiff = 0,TotDiffSqr=0;
long NumBytes = 0;
long NumDiffsOver128 = 0;
long NumDiffsOver64 = 0;
long MaxDiff = 0;
long CurDiff,AbsCurDiff;
long FirstDiffByte;

puts("Bdiff v2.0 by Charles Bloom");

if ( argc != 3 )
  {
  puts("USAGE: BDiff <file1> <file2>");
  exit(0);
  }

if ( (FH1 = fopen(argv[1],"rb")) == NULL )
  { puts("Couldn't open file1 !"); exit(10); }

if ( (FH2 = fopen(argv[2],"rb")) == NULL )
  { puts("Couldn't open file2 !"); exit(10); }

for(;;)
  {
  C1 = fgetc(FH1);
  C2 = fgetc(FH2);

  if ( C1 == EOF || C2 == EOF )
    break;

  if ( (CurDiff = C1 - C2) )
    {
    if ( NumDiffs == 0 )
      {
      FirstDiffByte = NumBytes;
      }
    NumDiffs++;
    AbsCurDiff = abs(CurDiff);
    TotDiff += AbsCurDiff;
    TotDiffSqr += AbsCurDiff*AbsCurDiff;
    if ( AbsCurDiff > MaxDiff ) MaxDiff = AbsCurDiff;
    if ( AbsCurDiff > 127 ) NumDiffsOver128++;
    if ( AbsCurDiff > 63 ) NumDiffsOver64++;
    }

  NumBytes++;
  if ( (NumBytes % 16384) == 0 )
    {
    printf("%ld / %ld diff\r",NumDiffs,NumBytes);
    fflush(stdout);
    }
  }
fclose(FH1);
fclose(FH2);

printf("%ld / %ld diff\r",NumDiffs,NumBytes);
printf("\n");

if ( C1 != C2 )
  {
  puts("Files are not same length; stopped at end of shorter file.");
  }

if ( NumDiffs > 0 )
  {
  printf("First byte different = %ld\n",FirstDiffByte);
  printf("%ld bytes different out of %ld bytes\n",NumDiffs,NumBytes);
  printf("%ld total value difference, %ld average\n",TotDiff,(long)(TotDiff/NumDiffs));
  printf("%ld total squared value difference, %ld average\n",TotDiffSqr,(long)(TotDiffSqr/NumDiffs));
  printf("%ld bytes different by more than 128, %ld over 64\n",NumDiffsOver128,NumDiffsOver64);
  printf("%ld maximum difference between two bytes\n",MaxDiff);
  }
else
  {
  puts("No difference between the two files.");
  }

}
