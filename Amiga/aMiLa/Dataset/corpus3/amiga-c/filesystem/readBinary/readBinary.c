#include <stdio.h>
#include <sys/stat.h>

int main () {
   FILE *fp;
   unsigned char buffer[10];
   int i;
   struct stat st;

   /* opening file for reading */
   fp = fopen("anoesh" , "rb");
   if(fp == NULL) {
      perror("Error opening file");
      return(-1);
   }
   puts("file open");

   // get File length
   // to get the length without opening in, use Lock() then Examine() because it's faster.
   fseek(fp,0,2);
   i=ftell(fp);
   printf("file is %d bytes\n", i);
   rewind(fp);
   
   fread(buffer,sizeof(buffer),1,fp);
   fclose(fp);
   puts("first 10 bytes:");
   for(i = 0; i<10; i++) printf("%u ", buffer[i]);
   return(0);
}