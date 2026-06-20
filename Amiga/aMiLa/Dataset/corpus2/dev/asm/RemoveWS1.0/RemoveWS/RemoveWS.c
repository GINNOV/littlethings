
#include <stdio.h>
#include <string.h>

int lineread(char*,FILE*);
int linewrite(char*,FILE*);
int lineconvert(char*,char*);

main (int argc, char* argv[]){
char c;
char s[255],t[255];
int i,j;
FILE *fp1,*fp2;

	if (argc>=2){
		if (strcmp(argv[1],"?") == 0){
			printf("USAGE: %s InFile OutFile\n",argv[0]);
			exit(0);
		}
	}

	if (argc>=2){
		if ((fp1 = fopen(argv[1],"r")) == NULL){
			fputs("can`t open infile\n",stderr);
			exit(5);
		}
	}
	else{
	/*	fputs("use stdin\n",stderr);*/
		fp1=stdin;
	}

	if (argc>=3){
		if ((fp2 = fopen(argv[2],"w")) == NULL){
			fputs("can`t open outfile\n",stderr);
			fclose(fp1);
			exit(5);
		}
	}
	else{
	/*	fputs("use stdout\n",stderr);*/
		fp2=stdout;
	}

	while (lineread(s,fp1) == 0){
	lineconvert(s,t);
	linewrite(t,fp2);
	}

	fclose(fp1);
	fclose(fp2);

exit(0);
}

lineread(char s[255],FILE *fp1){
int i=0;
char c;
	while ((c = getc(fp1)) != EOF){
		if (c == 0x0a){
			s[i]=0;
			return(0);
		}
		else{
			if (i<255){
				s[i++]=c;
			}
			else{
				s[i]=0;
				return(0);
			}
		}
	}
	return(1);
}

linewrite(char t[255],FILE *fp2){
int i=0;

	if (t[0] != 0){
		while (t[i] != 0) putc(t[i++],fp2);
		putc(0x0a,fp2);
	}
}

lineconvert(char s[255],char t[255]){
int i=0,j=0;
char c;
int ws=0;	/* white spaces */

	if (s[0] == 0x2a){
		t[0]=0;
		return(0);
	}
	while (s[i] != 0){
		c=s[i];
		if (c == 0x3b){
			t[j]=0;
			return(0);
		}
		if (c <= 0x20) {ws=1;i++;}
		else {
			if (ws != 0) {ws=0;t[j]=0x20;j++;}
			t[j]=s[i];
			i++;j++;
		}
	}
	t[j]=0;
}
