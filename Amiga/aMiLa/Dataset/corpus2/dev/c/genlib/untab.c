#include <stdio.h>
#include <stdlib.h>

void main(int argc,char *argv[])
{
FILE * InF, * OutF;
int numspaces;
int GotC;
int LineCount;
const int TAB = 0x09;

puts("UnTab v1.0 by Charles Bloom.");

if ( argc != 4 )
  {
  puts("Usage: UnTab <infile> <outfile> <num_spaces_per_tab>");
  puts("UnTab changes tabs into the specified number of spaces.");
  exit(0);
  }

if ( (InF = fopen(argv[1],"rb")) == NULL )
  {
  puts("Error: couldn't open input file!");
  exit(10);
  }

if ( (OutF = fopen(argv[2],"wb")) == NULL )
  {
  puts("Error: couldn't create output file!");
  fclose(InF);
  exit(10);
  }

numspaces = atoi(argv[3]);
printf("Converting tabs to %d spaces...\n",numspaces);

LineCount=0;
while ( ( GotC = fgetc(InF) ) != EOF )
  {
  if ( GotC == TAB )
    {
    do
      {
      fputc(' ',OutF);
      LineCount++;
      } while( LineCount%numspaces != 0 );
    }
  else
    {
    fputc(GotC,OutF);
    if ( GotC == '\n' || GotC == '\r' ) LineCount = 0;
    else LineCount++;
    }
  }

puts("Done.");

fclose(InF);
fflush(OutF);
fclose(OutF);

exit(0);
}
