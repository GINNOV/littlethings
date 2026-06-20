//
// DBTools.h
// Version 2.0
// Shared library with linked-list functions.
//
// History
//
// Date	     Version	Changes
// ---------------------------------------------------------------	
// 17/3	1996	1	First release
// 8/6	1996	2	Searching function added.
//
// ©1996 Henrik Isaksson
// All Rights Reserved.
//
// EMail: henriki@pluggnet.se
//

#ifndef DBTOOLS_H
#define DBTOOLS_H

//
// Structs
//

//
// DBase --- DBase --- DBase ...
//   |         |         |
//   |         |         |
// NList ... NList ... NList---DNode---DNode---DNode ...
//                               |       |       |
//                             DData   DData   DData
// How theese structures         |       |      ...
// are connected in the lists  DData    ...
//                              ...
//

struct DData {
 struct DData *Next;
 UWORD Type;
 union {
  struct DStr {
   APTR String;
  } DStr;
  struct DInt {
   ULONG Int;
  } DInt;
  struct DRaw {
   APTR RawData;
  } DRaw;
 };
};

struct DNode {
 struct DNode *Prev;	// Previous DNode in the node list
 struct DNode *Next;	// Next DNode in the node list
 struct DData *Data;	// First DData in the data list
 struct DData *Last;	// Last DData in the data list
};

struct DNList {
 struct DNode *First;	// First DNode in this data base
 struct DNode *Current;	// Currently used DNode
 struct DNode *Last;	// Last DNode in this base
};

struct DBase {
 struct DBase *Prev;	// Previous DataBase
 struct DBase *Next;	// Next DataBase
 struct DNList NList;	// List of nodes
 ULONG ID;
 UWORD LastError;
};

struct RawData {
 ULONG Size;
/*
 * BYTE Data[Size];
 */
};

typedef struct DBase DBase;
typedef struct DNList DNList;
typedef struct DNode DNode;
typedef struct DData DData;
typedef struct RawData RawData;

//
// Tags
//

// Tags for CreateBase

#define DBT_PrevBase		(TAG_USER+1)	// (DBase *db) Previous base that this one should be linked to.
#define DBT_NewBase		(TAG_USER+2)	// (ULONG ID) Create a new base.
#define DBT_NewNode		(TAG_USER+3)	// (BOOL) Create a new node. ti_Data shuold always be TRUE.
#define DBT_NewIntData		(TAG_USER+4)	// (ULONG Data) Create a new integer data field.
#define DBT_NewStrData		(TAG_USER+5)	// (STRPTR Data) Create a new string data field.
#define DBT_NewRawData		(TAG_USER+6)	// (RawData *cpd) Create a new field for raw data.
#define DBT_OldBase		(TAG_USER+7)	// (DBase *db) Continue on an old base.

//
// Field types
//

#define FTYPE_INT	1
#define FTYPE_STR	2
#define FTYPE_RAW	3

//
// Error codes
//

enum DBTErrors {
 DBT_NO_ERROR=0,
 DBT_ERR_NOMEM,		// Out of memory
 DBT_ERR_OPENOLD,	// Could not open an old file
 DBT_ERR_OPENNEW,	// Could not create a new file
 DBT_ERR_NOTFOUND,	// The last function did not find what it was supposed to look for.
 DBT_ERR_LOWMEM,	// Something could not be allocated but it is not fatal
 DBT_ERR_MOVE		// Move data unknown or out of range
};

//
// Macros
//

#define DBT_MakeBase	CreateBaseTags(DBT_NewBase,
#define DBT_ContBase	CreateBaseTags(DBT_OldBase, (ULONG)
#define DBT_Base	,DBT_NewBase,
#define DBT_Struct	,DBT_NewNode,	TRUE
#define DBT_Node	DBT_Struct
#define DBT_ULONG	,DBT_NewIntData,
#define DBT_STRING	,DBT_NewStrData,
#define DBT_End		,TAG_DONE)

#define INT(x,y)	GetIntN(db, x, y)
#define STR(x,y)	GetStrN(db, x, y)

#define FIRST_NODE(db)	(db->NList.First)
#define FIRST_DATA(db)	(db->NList.First->Data)

//
// Movements
//

#define MOVE_BASE	(1L<<31)

#define MOVE_NEXT	(MOVE_BASE+1)
#define MOVE_PREV	(MOVE_BASE+2)
#define MOVE_FIRST	(MOVE_BASE+3)
#define MOVE_LAST	(MOVE_BASE+4)

//
// Defines for file I/O
//

#define FILE_ID		"DBTDAT"	// Fixed to 6 bytes
#define END_OF_FILE	"EOF!"		// 4 bytes
#define BASE		"BASE"		// 4 bytes
#define NODE		"NODE"		// 4 bytes
#define INTDATA		"IDAT"		// 4 bytes
#define STRDATA		"SDAT"		// 4 bytes

//
// Base types
//

enum DBT_BaseTypes {
 /*

  If you want to register a base type send me the name of your
  application, your name and address and a description of what
  your program does. Then I will send you a new header file
  with the defines. 

  EMail: henriki@pluggnet.se

 */
 DBT_Demo=1,	// For the demo application
 DBT_Text,	// A database with strings only
 DBT_Phone1,	// Phone numbers
 // A database were each node looks like this:
 //
 // DBT_STRING	Name
 // DBT_STRING	Number
 // DBT_STRING	Comment
 DBT_Phone2,	// Phone numbers
 // DBT_STRING	Name
 // DBT_STRING	Number
 // DBT_STRING	Comment
 // DBT_ULONG	Number of calls
 // DBT_ULONG	Total time of calls in seconds
 // DBT_ULONG	Cost ($,kr...)
 // DBT_ULONG	Cost (¢,öre...)
 DBT_Address,	// Address register
 // DBT_STRING	Name
 // DBT_STRING	Address
 // DBT_STRING	City
 // DBT_STRING	Zip Code (postnummer)
 // DBT_STRING	Phone
 // DBT_STRING	Extra Info
 DBT_TimeLog,	// Program that logs time periods
 // DBT_ULONG	Starttime
 // DBT_ULONG	Endtime
 DBT_UltraBaseHdr,	// UltraBase ©1996 Henrik Isaksson
 DBT_UltraBaseFields,	// UltraBase ©1996 Henrik Isaksson
 DBT_UltraBaseData,	// UltraBase ©1996 Henrik Isaksson
};

//
// Prototypes
//

DBase *CreateBase(struct TagItem *Tags);
DBase *CreateBaseTags(ULONG tag, ...);

void DeleteBase(DBase *db);

BOOL DoBaseMove(DBase *db,ULONG pos);

ULONG GetInt(DBase *db,int data);
STRPTR GetStr(DBase *db,int data);

ULONG GetIntN(DBase *db,int node,int data);
STRPTR GetStrN(DBase *db,int node, int data);

DBase *FindBase(DBase *db, ULONG id);

DBase *LoadBase(STRPTR file);
DBase *LoadBaseID(STRPTR file, ULONG id);
BOOL SaveBase(STRPTR file, DBase *db);

STRPTR AllocString(STRPTR str);
APTR AllocRaw(APTR rawdata);

DNode *AddNode(DBase *db);

BOOL SetInt(DBase *db,int data,ULONG value);
BOOL SetStr(DBase *db,int data,STRPTR value);

BOOL SetIntN(DBase *db,int node,int data,ULONG value);
BOOL SetStrN(DBase *db,int node,int data,STRPTR value);

DNode *FindNode(DNode *dn, DData *dd);

#endif
