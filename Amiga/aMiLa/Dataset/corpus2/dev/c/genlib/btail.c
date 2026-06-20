#include <stdlib.h>
#include <stdio.h>
#include <fcntl.h>

int main (int argc, char *argv[])
{
int NumBytes,FileH,OutFileH,ReadBytes;
char *InFile;
char *OutFile;
void *InBuf;

if (argc < 4)
  {
  fprintf(stderr,"USAGE: Tail <bytes> <infile> <outfile>");
  fprintf(stderr,"Tail copies the last <bytes> of <infile>");
  exit(0);
  }
  
NumBytes = atoi(argv[1]);
if (NumBytes < 1)
  {
  fprintf(stderr,"Invalid number of lines: %s\n",argv[1]);
  exit(10);
  }
InFile = argv[2];
OutFile = argv[3];

if ( (FileH = open(InFile,O_RDONLY,0)) == -1)
  {
  fprintf(stderr,"Could not open file: %s\n",InFile);
  exit(10);
  }
if ( (OutFileH = open(OutFile,O_WRONLY|O_TRUNC|O_CREAT,0)) == -1)
  {
  fprintf(stderr,"Could not open file: %s\n",OutFile);
  close(FileH);
  exit(10);
  }

ReadBytes=lseek(FileH,0,2);
ReadBytes-=lseek(FileH,-NumBytes,2);

if ( (InBuf=malloc(ReadBytes)) == NULL)
  {
  puts("Couldn't malloc buffer!");
  close(FileH);
  close(OutFileH);
  exit(10);
  }

read(FileH,InBuf,ReadBytes);
write(OutFileH,InBuf,ReadBytes);

free(InBuf);
close(OutFileH);
close(FileH);
}
