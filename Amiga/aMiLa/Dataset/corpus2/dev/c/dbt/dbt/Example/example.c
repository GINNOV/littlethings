//
// example.c
// Version 1.0
// A demo of the DBTools library.
//
// ©1996 Henrik Isaksson.
// All Rights Reserved.
//

#include <exec/types.h>
#include <utility/tagitem.h>
#include <proto/exec.h>
#include <proto/dos.h>

#include <pragmas/dbtools_pragmas.h>
#include <libraries/dbtools.h>

#include <stdio.h>
#include <stdlib.h>

/* A macro to open dbtools.library */
#define OPENDBTOOLS	(DBToolsBase=OpenLibrary("dbtools.library",2))

struct Library *DBToolsBase;

void demo1(void);
void demo2(void);
void demo3(void);

void main(int argc, char *argv[])
{
 if(OPENDBTOOLS) {
	demo1();	/* Storing bases	*/
	demo2();	/* 'Dynamic structures'	*/
	demo3();	/* Searching		*/
 }
}

void demo1()
{
 DBase *db;	// The only variable we need

 db = DBT_MakeBase DBT_Demo		// Create a new demo base
	DBT_Node			// Add a node
		DBT_ULONG 123		// Add an integer to the node
		DBT_ULONG 321		// Add one more
	DBT_Node			// Add a new node
		DBT_ULONG 456		// Add '456'
    DBT_End;				// To be continued...

 DBT_ContBase db			// Continue on the old base db
		DBT_ULONG 654		// Add '654'
		DBT_STRING "string"	// Add a string

    DBT_Base DBT_Text			// Create a new text base (and end the demo base)
	DBT_Node
		DBT_STRING "text"	// Add some text
		DBT_STRING "more text"
    DBT_End;				// The End.

 // And if we want to extend the demo base:

 DBT_ContBase FindBase(db, DBT_Demo)
	DBT_Node
		DBT_STRING "more data"
    DBT_End;

 SaveBase("demo.testsave1",db);		// Save the base so we can look at it with DumpDB.
}

//
// Demo of 'dynamic structures'
//

#define Rect	1	// Name of the structure
#define Left	1
#define Top	2
#define Width	3
#define Height	4

#define Text	2	// The second structure
#define TextX	1
#define TextY	2
#define String	3

void demo2()
{
 /* First we have to declare the structures: */
 DBase *db=DBT_MakeBase DBT_Demo
		DBT_Node
			DBT_ULONG 0
			DBT_ULONG 0
			DBT_ULONG 0
			DBT_ULONG 0
		DBT_Node
			DBT_ULONG 0
			DBT_ULONG 0
			DBT_ULONG 0
	   DBT_End;

 /* Setting the fields can be done this way: */
 SetIntN(db, Rect, Left,   10);
 SetIntN(db, Rect, Top,    20);
 SetIntN(db, Rect, Width,  30);
 SetIntN(db, Rect, Height, 40);

 SetIntN(db, Text, TextX, 15);
 SetIntN(db, Text, TextY, 25);
 SetIntN(db, Text, String, (ULONG)"This is a test!");

 /* To read the fields, do like this... */
 printf("%s\n",GetIntN(db, Text, String));
 /* ...Or like this: */
 printf("%ld, %s\n",INT(Text,TextX),INT(Text,String));
 /* This macro will only work if the base is called 'db' */

 SaveBase("demo.testsave2",db);
}

//
// Demo of how to search and find
//

void demo3()
{
 DBase *sb=DBT_MakeBase DBT_Demo
		DBT_Node
			DBT_ULONG 77
		DBT_End;
 DBase *db=DBT_MakeBase DBT_Demo DBT_End;
 DNode *dn;
 int i;

 for(i=0;i<100;i++) {
	DBT_ContBase db
		DBT_Node
			DBT_ULONG i
	DBT_End;
 }
 /* Now we have a base with 100 nodes (0-99) */

 dn=FindNode(FIRST_NODE(db),FIRST_DATA(sb));

 if(dn) {
	printf("Found node: %ld\n",dn->Data->DInt.Int);
 } else {
	printf("Not found!\n");
 }
}
