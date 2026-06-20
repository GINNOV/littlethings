#include <stdlib.h>
#include <stdio.h>
#include <string.h>
#include <errno.h>

const char amigaversion[] = "$VER: Warpcollect 0.3 (19.07.2000)";

char *progname;

/* From libnix */
static char *amigapath(const char *path)
{ static char *s1=NULL;
  char *s2,*s3;
  int c;

  if(s1!=NULL)
    free(s1);

  s1=strdup(path);
  if(s1==NULL)
  { errno=ENOMEM;
    return NULL; }
  
  s3=s2=s1; /* Replace multiple following '/' by single ones */
  do
  { if(*s2=='/')
      while(s2[1]=='/')
        s2++;
    *s3++=*s2;
  }while(*s2++);

  s3=s2=s1; /* Remove single dots '.' as directory names */
  c=1;
  do
  { while(c&&s2[0]=='.'&&(s2[1]=='/'||s2[1]=='\0'))
    { s2++;
      if(*s2=='/')
        s2++;
    }
    *s3++=*s2;
    c=0;
    if(*s2=='/')
      c=1;
  }while(*s2++);
  
  s3=s2=s1; /* Remove double dots '..' as directory names */
  c=1;
  do
  { if(c&&s2[0]=='.'&&s2[1]=='.')
    { if(s2[2]=='/')
        s2+=2; 
      else if(s2[2]=='\0')
      { *s3++='/';
        s2+=2; }
    }
    *s3++=*s2;
    c=0;
    if(*s2=='/')
      c=1;
  }while(*s2++);

  if(*s1=='/') /* Convert names beginning with '/' */
  { s3=s2=s1;
    s2++;
    if(*s2=='/'||*s2=='\0') /* The root directory */
      return "SYS:";
    while(*s2!='/'&&*s2!='\0')
      *s3++=*s2++;
    *s3++=':';
    if(*s2=='/')
      s2++;
    do
      *s3++=*s2;
    while(*s2++);
  }

  return s1;
}

static void copyfile(char *infile, char *outfile)
{
	FILE *in, *out;
	size_t len;
	int done = 0;
	char *buffer;

	in = fopen(infile, "rb");
	out = fopen(outfile, "wb");
	buffer = malloc(8192);

	if (buffer == NULL) {
		fprintf(stderr, "%s: Out of memory\n", progname);
		exit(20);
	}

	if (in == NULL || out == NULL) {
		fprintf(stderr, "%s: Warning, Can't copy ELF file\n", progname);
		return;
	}

	while(done == 0) {
		len = fread(buffer, 1, 8192, in);
		if (len !=0)
			fwrite(buffer, 1, len, out);
		else
			done = 1;
	}

	free(buffer);
	fclose(out);
	fclose(in);
}

int main(int argc, char **argv)
{
	int i, len = 0;
	char *temp, *outname;
	char *exec, *exec2;
	char *env;

	progname = argv[0];

	for(i = 1; i < argc; i++) {
		len = len + 1 + strlen(argv[i]);
	}

	exec = malloc(len + 256);
	exec2 = malloc(256 + 20);
	temp = malloc(256);

	if (temp == NULL || exec == NULL || exec2 == NULL) {
		fprintf(stderr, "%s: Out of memory\n", progname);
		return 20;
	}

	strcpy(temp, "a.out");
	strcpy(exec, "/ade/ppc-amigaos/bin/ld");

	/* Get the output file name and copy the commandline */
	for(i = 1; i < argc; i++) {
		sprintf(exec, "%s %s", exec, argv[i]);
		if (strcmp(argv[i], "-o") == 0 && argc-1 > 1)
			strcpy(temp, argv[i+1]);
	}

	/* elf2exe2 doesn't support unixpaths :( */
	outname = amigapath(temp);
	if (outname == NULL) {
		fprintf(stderr, "%s: Out of memory\n", progname);
		return 20;
	}

	sprintf(exec2, "elf2exe2 %s %s", outname, outname);
	sprintf(temp, "%s.warpelf", outname);

	i = system(exec); /* Execute the linker */
	if (i != 0)
		return errno;

	env = getenv("KEEPWARPELF");
	if (env != NULL && atoi(env) > 0)
		copyfile(outname, temp);

	i = system(exec2); /* Execute elf2exe2 */
	if (i != 0) {
		i = errno;
		remove(outname);
		remove(temp);
		return i;
	}

	return 0;
}
