#include <stdio.h>
#include <ctype.h>
#include <string.h>

main(argc,argv)
char **argv;
{
	FILE *in;
	FILE *out;
	char mystring[200],tempstring[200];
	int len,firstchar,label,comment,equal;
	register int i;
	register char ch;
	unsigned int li;
	
	printf ("SEKA to Metacomco translator\nBy J-F Stenuit\n");
	if (argc != 3) {
		printf ("Usage: %s infile outfile\n",argv[0]);
		exit(0);
	}
	if ((in = fopen(argv[1],"r")) == NULL) {
		printf ("Unable to open input file %s\n",argv[1]);
		_exit(0);
	}
	if ((out = fopen(argv[2],"w")) == NULL) {
		printf ("Unable to open output file %s\n",argv[2]);
		fclose (in);
		_exit(0);
	}
	li = 0;
	for (;;) {
		if (fgets(mystring,197,in)==NULL)
			break;
		len = -1;
		firstchar = -1;
		label = -1;
		comment = -1;
		equal = -1;
		 
		for (i=0 ; i<=198 ; i++) {
			ch = mystring[i];
			if ((firstchar == -1) && (isgraph(ch)))
				firstchar = i;
			if ((label == -1) && (ch == ':') && (comment == -1))
				label = i;
			if ((equal == -1) && (ch == '=') && (comment == -1) && (i > 0))
				equal = i; 
			if ((comment == -1) && (ch == ';'))
				comment = i;
			if (ch == 0)
				break;
		}
		len = i;
		
		/* add ";" on start of comment */
		ch = tolower(mystring[firstchar]);
		if (((ch<'a') || (ch>'z')) && (ch != ';')) {
			for (i=len+1 ; i>0 ; i--)
				mystring[i] = mystring[i-1];
			mystring[0] = ';';
			comment = 0;
			len++;
		}

		/* pad char before comment */
		if ((comment > 0) && (isgraph(mystring[comment-1]))) {
			for (i=len+1 ; i>comment ; i--)
				mystring[i] = mystring[i-1];
			mystring[comment] = ' ';
			len++;
		}
		
		/* convert blk to dcb */
		strcpy(tempstring,mystring);
		strlwr(tempstring);
		i = 0;
		if (label != -1)
			i = label;
		while ((i < len) && (tempstring[i] != ';')) {
			if (tempstring[i] == 'b')
				if (tempstring[i+1] == 'l')
					if (tempstring[i+2] == 'k')
						memcpy(&mystring[i],"dcb",3);
			i++;
		}
		
		/* pad char after label */
		if (label != -1)
			if (mystring[label+1] != ' ') {
				for (i=len+1 ; i>label ; i--)
					mystring[i] = mystring[i-1];
				mystring [label+1] = ' ';
			}
		
		/* pad char before instruction */
		if ((firstchar == 0) && (mystring[0] != ';') &&
		    (label == -1) && (equal == -1)) {
			for (i=len+1 ; i>0 ; i--)
				mystring[i] = mystring[i-1];
			mystring[0] = ' ';
		}
		
		
		/* write resulting string */
		if (fputs(mystring,out) == EOF) {
			printf ("Error writing to file %s\n",argv[2]);
			fclose(in);
			fclose(out);
			unlink(argv[2]);
			_exit(0);
		}
		printf ("\x0dline : %d",li);
		li++;
	}
	printf("\n");
	fclose(in);
	fclose(out);
}
