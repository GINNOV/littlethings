#include <string.h>
#include <ctype.h>
#include <stdio.h>

#define CHAR_COLS 14

int main(int argc, char *argv[])
{
  int n;

  if(argc<2)
  {
    fprintf(stderr,"bindata img1 [img2 ...]\n");
    return(1);
  }  

  for(n=1; n<argc; n++)
  {
    unsigned char c;
    FILE *fp;
    int m;
    char namein[256],*ptr;

    strcpy(namein,argv[n]);
    ptr=strrchr(namein,'.');
    if(ptr!=NULL) ptr[0]='\0';

    for(m=0; namein[m]!='\0'; m++)
    {
      if(!isalnum(namein[m])) namein[m]='_';
    }

    fp=fopen(argv[n],"rb");
    if(fp==NULL)
    {
      fprintf(stderr,"Couldn't open %s\n",argv[n]);
      continue;
    }

    printf("const unsigned char %s[]={",namein);   

    m=0;
    while(fread(&c,1,1,fp)>0)
    {
      if(m!=0) printf(",");
      if((m%CHAR_COLS)==0) printf("\n\t");
      printf("0x%02x",c);
      m++;
    }
    printf("\n\t};\n");
    printf("const unsigned int %s_length=%d;\n",namein,m);
    fclose(fp);
  }

  return(0);
}
