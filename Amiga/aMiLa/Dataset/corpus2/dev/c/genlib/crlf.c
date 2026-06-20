#include <stdio.h>
#include <stdlib.h>

void main(int argc,char *argv[])
{
FILE * InF, * OutF;
int AddFlag;
int GotC;
const int LF = '\n',CR = '\r';

puts("CRLF v1.0 by Charles Bloom.");

if ( argc != 4 )
  {
  puts("Usage: CRLF <infile> <outfile> <add/remove flag>");
  puts(" <add/remove flag> = 1 to add CR");
  puts(" <add/remove flag> = 0 to cut CR");
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

AddFlag = atoi(argv[3]);

if (AddFlag)
  {
  puts("Adding CR to LF");

  while ( ( GotC = fgetc(InF) ) != EOF )
    {
    if ( GotC == LF )
      {
      fputc(CR,OutF);
      fputc(LF,OutF);
      }
    else
      {
      fputc(GotC,OutF);
      }
    }
  }
else
  {
  puts("Cutting CR");

  while ( ( GotC = fgetc(InF) ) != EOF )
    {
    if ( GotC != CR )
      {
      fputc(GotC,OutF);
      }
    }
  }

puts("Done.");

fclose(InF);
fflush(OutF);
fclose(OutF);

exit(0);
}
