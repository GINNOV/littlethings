#include <stdio.h>
#include <stdlib.h>

char *version="$VER: fd2monam 1.0 (12.10.1996)";
char *header="B\0\3\360\0\0\0\0";
char *footer="\0\0\0\0";
char *bias="##bias";
unsigned long total=0;
unsigned int offset=0;
FILE *out_fd;

void process(fdname,id)
char fdname[17];
unsigned char id;
{
  char line[257],lvo[257];
  unsigned int i;
  FILE *in_fd;
  if (in_fd=fopen(fdname,"r")) {
    printf("Processing %s file...\n",fdname);
    while (fgets(line,sizeof(line),in_fd)) {
      if (i=getbias(line)) offset=i;
      else if (*line!='*'&&*line!='#') putLVO(line,lvo,id);
    }
    fclose(in_fd);
  }
  else printf("Warning: %s not found\n",fdname);  
}

unsigned int getbias(line)
char line[];
{
  char *i;
  int r;
  i=bias;
  r=1;
  while (*i) if (*i++!=*line++) r=0;
  line+=1;
  if (r) return(-atoi(line));
  else return(0);
}

void putLVO(line,lvo,id)
char line[];
char lvo[];
unsigned char id;
{
  char *i;
  unsigned long l,m;
  i=lvo;
  while (*line!='(') *i++=*line++;
  *i++='\0';
  while (*i!='\0') *i++='\0';
  l=strlen(lvo)/4;
  if (strlen(lvo)%4) l+=1;
  fwrite(&l,4,1,out_fd);
  fwrite(lvo,4,l,out_fd);
  m=(id<<16)|(offset&0x0000FFFF);
  fwrite(&m,4,1,out_fd);
  total+=4*(l+2);
  offset-=6;
}

main (argc,argv)
int argc;
char *argv[];
{
  printf("fd2monam 1.0 (c) Marek Grodny\n");
  if (argc!=1) printf("Usage: fd2monam\n");
  else {
    if (out_fd=fopen("monam.libfile","w")) {
      fwrite(header,8,1,out_fd);
      process("exec_lib.fd",1);
      process("intuition_lib.fd",2);
      process("dos_lib.fd",3);
      process("graphics_lib.fd",4);
      fwrite(footer,4,1,out_fd);
      total+=4;
      fseek(out_fd,4,SEEK_SET);
      fwrite(&total,4,1,out_fd);
      fclose(out_fd);
    }
    else printf("Error: Cann't open monam.libfile\n");
  }
}
