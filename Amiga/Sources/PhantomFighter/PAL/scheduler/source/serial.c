#include <stdio.h>

#include <exec/types.h>

void PHex(a)
ULONG a;
{
   printf("%c%c",((a>>4)&0xf)+48,(a&0xf)+48);
}

void main(argc,argv)
int argc;
char **argv;
{
   FILE *fp;
   int FileNo;
   int t;
   unsigned char CheckSum;
   for(FileNo=1;FileNo<argc;++FileNo) {
      printf("%s",argv[FileNo]);
      putchar((char)0);
      fp=fopen(argv[FileNo],"r");
      CheckSum=0;
      while(!feof(fp)) {
         t=fgetc(fp);
         CheckSum+=t;
         PHex(t);
      }
      fclose(fp);
      putchar((char)26);
      putchar(CheckSum);
   }
   putchar((char)0);
   fflush(stdout);
}
