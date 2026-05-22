#include <stdio.h>
#include <time.h>
#include <string.h>

int main(int cnt,char *arg[])
{
long	ver=0,rev=0;
char buf[255];
char buf2[255];
struct tm *timep;
time_t tim;
FILE *f;

tim = time(NULL);
timep = gmtime(&tim);

if((f=fopen("GAP_Version","rb"))!=NULL) {
	fscanf(f,"%d",&ver);
	fclose(f);
}

if((f=fopen("GAP_Revision","rb"))!=NULL) {
	fscanf(f,"%d",&rev);
	fclose(f);
}

if(cnt>1) {

	if(!strcmp(arg[1],"-h")) {
		strcpy(buf,"mkver c  - Make version string.\nmkver doc  - Make doc version info.\n");
	}

	if(!strcmp(arg[1],"c")) {
		strftime(buf2,255,"static const char *__v__ = \"$VER: GAP-Lib %%d.%%d (%d.%m.%y) ©1998-%Y Peter Bengtsson\";\n",timep);
		sprintf(buf,buf2,ver,rev);
	}

	if(!strcmp(arg[1],"doc")) {
		strftime(buf2,255,"\tThe current version as of %d-%b-%Y is %%d.%%d\n\t(Version %%d, Revision %%d).\n",timep);
		sprintf(buf,buf2,ver,rev,ver,rev);
	}
} else {
	sprintf(buf,"%d.%d",ver,rev);
}

printf(buf);

return(0);
}
