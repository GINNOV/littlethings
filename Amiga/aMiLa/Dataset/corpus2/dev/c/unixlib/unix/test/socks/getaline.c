#include <stdio.h>
#include <dos/dosextens.h>
#include <proto/dos.h>

int
main(void)
{
	char userinput[256];
	int howmany = 0;
	BPTR dos_fh;

	dos_fh = Open("CON:10/10/500/150/New Window",MODE_NEWFILE);
	Write(dos_fh,"Please type an input line, then press RETURN\n",45);
	while(howmany != 1) {
	    howmany = Read(dos_fh,userinput,255);
	    userinput[howmany] = '\0';
	    printf("%s",userinput);
	    fflush(stdout);
	}
	Close(dos_fh);
	return 0;
}
