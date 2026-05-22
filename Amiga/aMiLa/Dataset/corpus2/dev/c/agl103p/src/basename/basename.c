/* equivalent of Unix's basename */

#include<stdlib.h>
#include<string.h>

int main(int argc,char **argv)
	{
	char *pointer,base[100];
	short baselength,taillength;

	if(argc<2 || argc>3)
		{
		printf("Usage: basename <filename> [tail]\n");
		exit(1);
		}

	pointer=strrchr(argv[1],'/');
	if(pointer==NULL)
		pointer=argv[1];
	else
		pointer++;

	strcpy(base,pointer);

	if(argc==3)
		{
		baselength=strlen(base);
		taillength=strlen(argv[2]);

		pointer=base+baselength-taillength;

		if( pointer>=base && !strcmp(pointer,argv[2]) )
			base[baselength-taillength]=0;
		}

	printf("%s\n",base);

	return 0;
	}
