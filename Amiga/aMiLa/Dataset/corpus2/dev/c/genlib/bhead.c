#include <stdlib.h>
#include <stdio.h>
#include <fcntl.h>

int main (int argc, char *argv[])
{
int NumBytes,FileH,OutFileH,OffSet;
char *InFile;
char *OutFile;
void *InBuf;
int EndPos,StartPos;

if (argc < 4 || argc > 5)
  {
  fprintf(stderr,"USAGE: Head <bytes> <infilee> <outfile> [start pos]\n");
  fprintf(stderr,"Head copies the first <bytes> of <infile>\n");
  exit(0);
  }
if (argc == 5)  
  {
  OffSet=atoi(argv[4]);
  if (OffSet < 1)
    {
    fprintf(stderr,"Invalid starting offset!\n");
    fprintf(stderr,"Don't include a 4th parameter to set offset=0\n");
    exit(10);
    }
  }
else
  {
  OffSet=0;
  }

NumBytes = atoi(argv[1]);
if (NumBytes < 1)
  {
  fprintf(stderr,"Invalid number of lines: %s\n",argv[1]);
  exit(10);
  }
InFile = argv[2];
OutFile = argv[3];

if ( (InBuf=malloc(NumBytes)) == NULL)
  {
  puts("Not enough memory!");
  exit(10);
  }

if ( (FileH = open(InFile,O_RDONLY,0)) == -1)
  {
  free(InBuf);
  fprintf(stderr,"Could not open file: %s\n",InFile);
  exit(10);
  }
if ( (OutFileH = open(OutFile,O_WRONLY|O_TRUNC|O_CREAT,0)) == -1)
  {
  free(InBuf);
  fprintf(stderr,"Could not open file: %s\n",OutFile);
  close(FileH);
  exit(10);
  }

StartPos=lseek(FileH,0,0);
EndPos=lseek(FileH,0,2);
if (OffSet+NumBytes > EndPos-StartPos)
  {
  NumBytes = (EndPos-StartPos) - OffSet;
  if (NumBytes < 0) NumBytes = 0;
  }
lseek(FileH,OffSet,0);
if ( read(FileH,InBuf,NumBytes) > 0)
  {
  write(OutFileH,InBuf,NumBytes);
  }

free(InBuf);

close(OutFileH);
close(FileH);
}
