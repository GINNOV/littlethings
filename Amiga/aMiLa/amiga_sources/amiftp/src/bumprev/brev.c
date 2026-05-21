#include <stdio.h>
#include <string.h>

void main()
{
    FILE *fh;
    long rev1=0,rev2=0;
    char buf[20];

    fh=fopen("VERSION","r");
    if (fh) {
	fscanf(fh,"%ld.%ld",&rev1,&rev2);
	fclose(fh);
	printf("Old rev: %ld.%ld\n",rev1,rev2);
    }

    rev2++;

    fh=fopen("VERSION","w");
    if (fh) {
	fprintf(fh,"%ld.%ld",rev1,rev2);
	fclose(fh);
/*	fh=fopen("AmiFTP_rev.h","w");
	if (fh) {
	    fprintf(fh,"#define VERSION        0\n");
	    fprintf(fh,"#define REVISION       %ld\n",rev);
	    fprintf(fh,"#define VERSTAG \"\\0$VER: AmiFTP 0.%ld\"\n",rev);
	    fprintf(fh,"#define SVERSION \"0.%ld\"\n",rev);
	    fclose(fh);
	}*/ 
    }

}
