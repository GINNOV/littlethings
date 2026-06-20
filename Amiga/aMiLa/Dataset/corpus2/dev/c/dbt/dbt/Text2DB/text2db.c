//
// Text2DB.c
// Version 1.0
// Convert a text file to DBTools format.
//
// ©1996 Henrik Isaksson
// All Rights Reserved.
//
// EMail: henriki@pluggnet.se
//

#include <exec/types.h>

#include <utility/tagitem.h>

#include <proto/exec.h>
#include <proto/dos.h>

#include "dbtools_pragmas.h"
#include "dbtools.h"

#include <stdio.h>
#include <string.h>
#include <stdlib.h>

struct Library *DBToolsBase;

char *ver="$VER: [32mText2DB[31m V1.0";

main(int argc,char *argv[])
{
 DBase *db=NULL;

 if(argc!=2) {
	printf("USAGE: %s <FILE>\n",argv[0]);
	printf("Converts a text file to DBTools format.\n");
	printf("The output will be stored in a file with\n");
	printf("the extension '.dbt'.\n");
	printf("[32mDBTools[31m ©1996 Henrik Isaksson\n");
	printf("All Rights Reserved.");
	exit(0);
 }

 DBToolsBase = OpenLibrary("dbtools.library",0);
 if(DBToolsBase) {
	FILE *fp;

	fp=fopen(argv[1],"r");
	if(fp) {
		char buffer[256],*x;
		BOOL n=FALSE;

		db=DBT_MakeBase DBT_Text	// Use some macros and build a text data base
			DBT_Node
			DBT_End;

		if(db) {
			while(!feof(fp)) {
				if(fgets(buffer,sizeof(buffer),fp)) {
					if(buffer[strlen(buffer)-1]=='\n') buffer[strlen(buffer)-1]='\0';
					x=stpblk(buffer);
					if(x[0]) {
						DBT_ContBase db			// Continue on the old base
							DBT_STRING buffer	// And add some text
							DBT_End;
						n=TRUE;
					} else {
						if(n) DBT_ContBase db		// Make a new node when we strike
							DBT_Node		// one or many empty lines
							DBT_End;
						n=FALSE;
					}
				}
			}
		}
		fclose(fp);
	}

	if(db) {
		char name[256];

		sprintf(name,"%s.dbt",argv[1]);
		SaveBase(name,db);
		DeleteBase(db);
	} else printf("I can't open \"%s\"!\n",argv[1]);
	CloseLibrary(DBToolsBase);
 } else printf("I couldn't open DBTools.library!\n");
}

/* !THE END! */
