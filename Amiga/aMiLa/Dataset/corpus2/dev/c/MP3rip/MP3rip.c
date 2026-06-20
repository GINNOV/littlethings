#include <stdio.h>              // file functions
#include <string.h>             // string functions
#include <clib/exec_protos.h>   // AllocMem() and FreeMem()
#include <exec/memory.h>        // declaration of MEMF_PUBLIC
#include <ctype.h>              // toupper()

int main(int argc, char *argv[])
{
   FILE *in_file;
   char *opt = "rb";

   char *wavename;
   long mpSize;
   char *data;

   int i;


   printf("\n\n");

   if (strcmp(argv[1], "") == 0)
   {
      printf("RIFF-WAVE header ripper for MP3 files.\n");
      printf("Lame-coded by Bedazzle from -=AMIGA POWER=- 30.10.1999\n\n");
      printf("Usage: Mp3rip <filename>\n");
      printf("Where <filename> is MP3 file with ###ng WAVE-header\n\n");
      printf("If <filename> doesn't have an '.wav' extension, original\n");
      printf("file will be replaced. Otherwise you get new file with\n");
      printf("'.mp3' extension.\n\n");
      return 0;
   }

   if ((wavename = (char *)AllocMem(300, MEMF_PUBLIC)) == NULL)
   {
      printf("Not enough memory for filename???\n");
      return 1;
   }

   strcpy(wavename, argv[1]);

   if ((in_file = fopen (wavename, opt)) == NULL)
   {
      printf ("Can't open file for load\n");
      FreeMem(wavename, 300);
      return 1;
   }

   printf("Open %s...\n", wavename);
   fseek(in_file, 0x0L, SEEK_END);
   mpSize = ftell(in_file);
   mpSize -= 64;
   fseek(in_file, 0x0L, SEEK_SET);

   printf("mp3 length - %d\n", mpSize);

   if ((data = (char *)AllocMem(mpSize, MEMF_PUBLIC)) == NULL)
   {
      printf("Not enough memory for buffer.\n");
      FreeMem(wavename, 300);
      return 1;
   }
   if((fread(data, 1, 64, in_file)) != 64)
   {
      printf("Error reading header\n");
      FreeMem(data, mpSize);
      FreeMem(wavename, 300);
      return 1;
   }
   if((fread(data, 1, mpSize, in_file)) != mpSize)
   {
      printf("Error reading buffer\n");
      FreeMem(data, mpSize);
      FreeMem(wavename, 300);
      return 1;
   }
   fclose(in_file);

   opt = "wb";
   for(i=0; i<300; i++)
   {
      if((wavename[i] == '.') && (toupper(wavename[i+1]) == 'W') &&
                                 (toupper(wavename[i+2]) == 'A') &&
                                 (toupper(wavename[i+3]) == 'V'))
      {
          wavename[i+1] = 'm';
          wavename[i+2] = 'p';
          wavename[i+3] = '3';
          break;
      }
   }

   printf("Save %s...\n", wavename);

   if ((in_file = fopen (wavename, opt)) == NULL)
   {
      printf ("Can't open file for save\n");
      FreeMem(data, mpSize);
      FreeMem(wavename, 300);
      return 1;
   }
   if((fwrite(data, 1, mpSize, in_file)) != mpSize)
   {
      printf("Error writing buffer data\n");
      FreeMem(data, mpSize);
      FreeMem(wavename, 300);
      return 1;
   }

   fclose(in_file);
   printf("OK.\n");
}
