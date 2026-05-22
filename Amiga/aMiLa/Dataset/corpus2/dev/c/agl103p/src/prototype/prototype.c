#include<stdio.h>

#define AUTOLONG	0 /* TRUE = add long to prototype if type not recognized */

#define MATCH 13

void abort(void);
int readline(FILE *infile,char *line,char end);



/*PROTOTYPE*/
int main(long argc,char **argv)
	{
	FILE *outfile,*infile;
	char filename[50],proto[150],line[500];
	short filen,c,start=1;

	strcpy(proto,"/*PROTOTYPE*/");

	if(!strcmp(argv[1],"-o"))
		{
		if(argc<4)
			abort();

		start=3;

		outfile=fopen(argv[2],"w");
		if(outfile==NULL)
			{
			printf("\nError opening %s for save\n",argv[2]);
			abort();
			}
		}
	else
		outfile=stdout;

	if(start>=argc)
		abort();

	for(filen=start;filen<argc;filen++)
		{
		strcpy(filename,argv[filen]);
		fprintf(outfile,"/* %s */\n",filename);

		infile=fopen(filename,"r");
		if(infile==NULL)
			{
			fprintf(outfile,"\n/* ERROR: Unreadable */\n\n");
			}
		else
			{
			c=0;
			while(c!=EOF)
				{
				c=readline(infile,line,(char)'\n');
/*
fprintf(outfile,"SEARCH  %s\n",line);
*/
				if( c!=EOF && !strncmp(line,proto,MATCH) )
					{
					c=readline(infile,line,(char)'{');
/*
fprintf(outfile,"COMMENT %s\n",line);
fprintf(outfile,"	");
*/
					while(line[strlen(line)-1]==' ' || line[strlen(line)-1]=='	' || line[strlen(line)-1]=='\n')
						line[strlen(line)-1]=0;

					if(		!AUTOLONG ||				!strncmp(line,"int",3)  ||
							!strncmp(line,"char",4) ||	!strncmp(line,"short",5)  ||
							!strncmp(line,"void",4) ||	!strncmp(line,"double",6) ||
							!strncmp(line,"long",4) ||	!strncmp(line,"float",5)     )
						fprintf(outfile,"%s;\n",line);
					else
						fprintf(outfile,"long  %s;\n",line);
					}
				}
			fclose(infile);
			fprintf(outfile,"\n");
			}
		}

	return 0;
	}



/*PROTOTYPE*/
void abort(void)
	{
	printf("Usage: prototype [-o outfile] infile [...]\n");
	}



/*PROTOTYPE*/
int readline(FILE *infile,char *line,char end)
	{
	int n,c;

	c=0;
	n=0;
	while(c!=EOF && c!=end)
		{
		c=getc(infile);
		if(c!=EOF && c!=end)
			{
			line[n]=c;
			n++;
			}
		}
	line[n]=0;

	return c;
	}
