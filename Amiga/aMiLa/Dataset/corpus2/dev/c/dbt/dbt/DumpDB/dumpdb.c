//
// DumpDB.c
// Version 1.0
// Dumps a DBTools database to the screen.
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
#include <stdlib.h>

char *ver="$VER: [32mDumpDB[31m 1.0";

struct Library *DBToolsBase;

main(int argc,char *argv[])
{
 DBase *db,*b;
 DNode *n;
 DData *d;

 if(argc!=2) {
	printf("USAGE: %s <FILE>\n",argv[0]);
	printf("[32mDBTools[31m ©1996 Henrik Isaksson\n");
	printf("All Rights reserved.\n");
	exit(0);
 }

 DBToolsBase = OpenLibrary("dbtools.library",0);	// Any version will do this...
 if(DBToolsBase) {
	db=LoadBase(argv[1]);	// Load the base
	if(db) {		// Is it loaded?
		b=db;
		while(b) {	// Scan through the bases
			n=b->NList.First;
			printf("BASE:\t");
			while(n) {	// Scan through the nodes
				d=n->Data;
				printf("NODE:\t");
				while(d) {	// Print all data
					switch(d->Type) {
						case FTYPE_INT:
							printf("Integer: %ld (0x%08lx)\n",d->DInt.Int,d->DInt.Int);
							break;
						case FTYPE_STR:
							if(d->DStr.String) printf("String: \"%s\"\n",d->DStr.String);
							else printf("String: NULL\n");
							break;
						default:
							printf("Unknown data type\n");
					}
					d=d->Next;
					printf("\t\t");
				}
				printf("\n\t");
				n=n->Next;
			}
			printf("\n");
			b=b->Next;
		}

		printf("END\n");

		DeleteBase(db);	// We must always clean up when we exit...
	} else {
		printf("I can't find the file \"%s\"!\n",argv[1]);
	}
	CloseLibrary(DBToolsBase);
 } else {
	printf("I can't open \"dbtools.library\"!\n");
 }
}