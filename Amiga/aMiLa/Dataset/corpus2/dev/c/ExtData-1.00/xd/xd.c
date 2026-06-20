/* Copyright © 1994 Cedric Beust. See file COPYRIGHT for more information */
/* 
 * xd.c
 *
 * $Id: xd.c,v 1.15 1994/01/27 22:56:35 beust Exp beust $
 */

/*
 ** Do not rely on this format, it might evolve in future versions.
 ** It is presented here for a simple personal reminder purpose .
 **
 ** All strings are written as "BSTR" (i.e. preceded by their size
 ** on a LONG byte).

 LIST XDAT
   PROP XSHA            Hold all the shared information
     XINF               Information on this file
       typeSize type
       applicationSize application
       authorSize author
       versionSize version
       dateSize date
     XFIE                       Give all fields with their types (private)
       fieldType fieldSize fieldName
       fieldType fieldSize fieldName
       ...
     XUSE                       User-defined key/value pairs (public)
       key valueSize value
       ...
   FORM XCON                       Contents of the records
       XREC fieldSize fieldValue fieldSize fieldValue ...    a record
       XREC fieldSize fieldValue fieldSize fieldValue ...    another record
 */


#include "xd.h"

#define MWDEBU

#define NEW(v, t) v = (t *) malloc(sizeof(t))
#define STREQUAL(s1, s2) (strcmp(s1, s2) == 0)


/**********************************************************************/

/* Associate a field name and its type */
struct TypeAssoc {
   struct Node node;
   Xd_Type type;
   void *value;
};

/* Structure for the database */
typedef struct _Xd_Database {
   struct IFFHandle *iff;   /* the iff handle */
   struct List *ltypes;    /* list of types */
   struct List *lshared;  /* list of shared keys/values */
   int writeOccured;     /* if 1, a write has occured, can't declare more */
   char *fileType;
   char *application;
   char *author;
   char *version;
   char *date;
   Xd_Error errorNumber;
   char *errorInfo;
};

/*
 ** Here are all the new chunk names we use.
 **
 ** XDAT (xdata)    is the main type of our IFF chunk
 ** XSHA (xshared   is the id of the PROP (shared) chunk
 **   XINF (xinfo)  is used in the PROP chunk to hold information about the file
 **   XFIE (xfield)   is used in the PROP chunk to give names and types to fields
 **   XUSE (xuser)    is used in the PROP chunk for user-defined keys/values
 ** XCON (xcontent) introduces the chunk containing all the records
 **   XREC (xrecord)  introduces a new record
 */

#define ID_XDAT MAKE_ID('X', 'D', 'A', 'T')
#define ID_XSHA MAKE_ID('X', 'S', 'H', 'A')
#define ID_XINF MAKE_ID('X', 'I', 'N', 'F')
#define ID_XFIE MAKE_ID('X', 'F', 'I', 'E')
#define ID_XUSE MAKE_ID('X', 'U', 'S', 'E')
#define ID_XCON MAKE_ID('X', 'C', 'O', 'N')
#define ID_XREC MAKE_ID('X', 'R', 'E', 'C')

struct IFFParseBase *IFFParseBase = NULL;

/***********************************************************************
 * Private
 ***********************************************************************/

#define SAFEFREE(p) if (p != NULL) free(p)

static void
xd_error(Xd_Database xd, int err, char *info)
{
   xd -> errorNumber = (Xd_Error) err;
   SAFEFREE(xd -> errorInfo);
   if (info != NULL)
     xd -> errorInfo = strdup(info);
   else
     xd -> errorInfo = NULL;
}

#ifdef A
static void
xd_displayList(struct List *list)
{
   struct  Node *node;

   printf("content of list %x\n-----\n", list);
   for (node = list -> lh_Head; node -> ln_Succ; node = node -> ln_Succ) {
      struct TypeAssoc *ta = (struct TypeAssoc *) node;
      if (ta) {
	 printf("'%s' -> ", ta -> node.ln_Name);
	 if (ta -> value && ta -> type == XD_STRING)
	   printf("'%s'\n", ta -> value);
	 else if (ta -> value && ta -> type == XD_INTEGER)
	   printf("$%x\n", ta -> value);
      }
   }
   printf("-----\n");
}
#endif

static void
xd_freeList(struct List *list)
/* Free a list of TypeAssoc nodes */
{
   struct Node *node;
   for (node = list -> lh_Head; node -> ln_Succ; node = node -> ln_Succ) {
      struct TypeAssoc *ta = (struct TypeAssoc *) node;
      if (ta != NULL) {
	 SAFEFREE(ta -> value);
	 SAFEFREE(ta -> node.ln_Name);
	 free(ta);
      }
   }
   free(list);
}

static long
xd_makeId(char *name)
{
   int i, j;
   char chunk[4];
   long result;

   if (strlen(name) >= 4) {
      for (i=0; i<4; i++) chunk[i] = name[i];
   }
   else {
      for (i=0; i<4-strlen(name); i++) chunk[i] = name[0];
      for (j = 0; i<4; i++, j++) chunk[i] = name[j];
   }

   result = MAKE_ID(chunk[0], chunk[1], chunk[2], chunk[3]);
   return result;
}

static int
xd_declareTypeAssoc(Xd_Database xd, char *field, char *value,
		    Xd_Type type, struct List *list)
{
   struct TypeAssoc *ta;
   int result = 0;

   /* Check if this new field won't collide with another one */
   if (FindName(list, field)) {
      xd_error(xd, XD_FIELD_ALREADY_EXISTS, field);
      result = 1;
   }

   else {
      if (! xd -> writeOccured) {
	 NEW(ta, struct TypeAssoc);
	 ta -> node.ln_Name = strdup(field);
	 ta -> type = type;
	 ta -> value = value;
	 AddTail(list, (struct Node *) ta);
      }
      else
	result = 1;
   }

   return result;
}

static int
xd_declareShared(Xd_Database xd, char *key, char *value)
{
   return xd_declareTypeAssoc(xd, key, value, XD_STRING, xd -> lshared);
}

static void
xd_writeChunk(struct IFFHandle *iff, void *bytes, int l)
/* Write the size, then the bytes, and the possible pad bytes */
{
   char pad[4];

   pad[0] = pad[1] = pad[2] = pad[3] = 0;

   if (bytes == NULL) l = 0;
   WriteChunkBytes(iff, (char *) & l, sizeof(l));
   if (bytes) WriteChunkBytes(iff, bytes, l);
   if (l % 4) {
      WriteChunkBytes(iff, pad, 4 - (l % 4));
  }
}

static struct TypeAssoc *
xd_findType(struct List *ltypes, char *field)
{
   struct TypeAssoc *result = NULL;

   result = (struct TypeAssoc *) FindName(ltypes, field);
   return result;
}

static int
xd_skipToId(Xd_Database xd, long id)
/* Skip to next hunk of id 'id' */
/* Return : 1 if found */
{
   int running = 1;
   int result = 0, error;
   struct ContextNode *cn;

   while (running) {
      error = ParseIFF(xd -> iff, IFFPARSE_RAWSTEP);
      if (error == IFFERR_EOF) {
	 result = 0;
	 running = 0;
      }
      else {
	 cn = CurrentChunk(xd -> iff);
	 if (! cn) {
	    result = 0;
	    running = 0;
	 }
	 else if (cn -> cn_ID == id) {
	    result = 1;
	    running = 0;
	 }
      }
   }

   return result;
}

static int
xd_skipToType(Xd_Database xd, long type)
/* Skip to next hunk of id 'id' */
/* Return : 1 if found */
{
   int running = 1;
   int result = 0, error;
   struct ContextNode *cn;

   while (running) {
      error = ParseIFF(xd -> iff, IFFPARSE_RAWSTEP);
      if (error == IFFERR_EOF) {
	 result = 0;
	 running = 0;
      }
      else {
	 cn = CurrentChunk(xd -> iff);
	 if (! cn) {
	    result = 0;
	    running = 0;
	 }
	 else if (cn -> cn_Type == type) {
	    result = 1;
	    running = 0;
	 }
      }
   }

   return result;
}

static void
xd_writeHeader(Xd_Database xd)
/* Write the header of the file */
{
   struct List *list;
   struct Node *node;

   /*
    ** The XINF chunk.
    ** This is the constant part of the file where the program stores
    ** its main information : fileType, application, author, version, date
    ** in that order.
    */

   PushChunk(xd -> iff, ID_XSHA, ID_XINF, IFFSIZE_UNKNOWN);
   xd_writeChunk(xd -> iff, xd -> fileType, strlen(xd -> fileType));
   xd_writeChunk(xd -> iff, xd -> application, strlen(xd -> application));
   xd_writeChunk(xd -> iff, xd -> author, strlen(xd -> author));
   xd_writeChunk(xd -> iff, xd -> version, strlen(xd -> version));
   xd_writeChunk(xd -> iff, xd -> date, strlen(xd -> date));
   PopChunk(xd -> iff);   /* pop XINF chunk */

   /*
    ** The XFIE chunk.
    ** Here we give all the names of the fields, preceded by their
    ** type.
    */

   PushChunk(xd -> iff, ID_XSHA, ID_XFIE, IFFSIZE_UNKNOWN);
   list = xd -> ltypes;
   for (node = list -> lh_Head; node -> ln_Succ; node = node -> ln_Succ) {
      struct TypeAssoc *ta = (struct TypeAssoc *) node;
      WriteChunkBytes(xd -> iff, & ta -> type, sizeof(ta -> type));
      xd_writeChunk(xd -> iff, ta -> node.ln_Name, strlen(ta -> node.ln_Name));
   }
   PopChunk(xd -> iff);   /* pop XFIE chunk */

   /*
    ** The XUSE chunk
    */

   PushChunk(xd -> iff, ID_XSHA, ID_XUSE, IFFSIZE_UNKNOWN);/*start XUSE chunk*/
   list = xd -> lshared;
   for (node = list -> lh_Head; node -> ln_Succ; node = node -> ln_Succ) {
      struct TypeAssoc *ta = (struct TypeAssoc *) node;
      xd_writeChunk(xd -> iff, ta -> node.ln_Name, strlen(ta -> node.ln_Name));
      xd_writeChunk(xd -> iff, ta -> value, strlen(ta -> value));
   }
   PopChunk(xd -> iff);

   /*
    ** Start the XCON chunk
    */

   PushChunk(xd -> iff, ID_XCON, ID_FORM, IFFSIZE_UNKNOWN);  /* start XCON */
}

static Xd_Database
xd_readHeader(Xd_Database xd, char *fileType)
/* Read the header of the file and put it into our lists */
/* Compare the fileType read with the one given */
/* as parameter and return NULL if they don't match exactly */
{
   Xd_Database result = xd;
   if (! xd_skipToType(xd, ID_XSHA)) {
      xd_error(xd, XD_NO_TYPE_XSHA, NULL);
      result = NULL;
   }
   else {
      char devNull[10];   /* buffer to hold pad bytes */

      /*
       ** Read the XINF chunk
       ** fileType, application, author, version, date
       ** in that order.
       */
      if (xd_skipToId(xd, ID_XINF)) {
	 struct ContextNode *cn = CurrentChunk(xd -> iff);
	 int i = 0;

	 if (! cn) {
	    xd_error(xd, XD_NO_ID_XINF, NULL);
	    result = NULL;
	 }
	 else {
	    int n, size;
	    char *name;
	    void *info[5];

	    info[0] = & xd -> fileType;
	    info[1] = & xd -> application;
	    info[2] = & xd -> author;
	    info[3] = & xd -> version;
	    info[4] = & xd -> date;

	    n = cn -> cn_Size - 4;
	    while (n > 0) {
	       ReadChunkBytes(xd -> iff, & size, sizeof(APTR));
	       n -= sizeof(APTR);
	       name = (char *) malloc(size + 1);
	       ReadChunkBytes(xd -> iff, name, size);
	       name[size] = '\0';
	       n -= size;
	       if (size % 4 != 0) {
		  ReadChunkBytes(xd -> iff, devNull, 4 - (size % 4));
		  n -= 4 - (size % 4);
	       }

	       *((char **) info[i]) = strdup(name);
	       free(name);
	       i++;
	    }
	 }
      }
      else {
	 xd_error(xd, XD_NO_ID_XINF, NULL);
      }

      /*
       ** Read the XINF chunk
       */
      if (xd_skipToId(xd, ID_XFIE)) {
	 struct ContextNode *cn = CurrentChunk(xd -> iff);
	 if (! cn) {
	    xd_error(xd, XD_NO_ID_XFIE, NULL);
	    result = NULL;
	 }
	 else {
	    int n, size;
	    Xd_Type type;
	    char *name;
	    n = cn -> cn_Size - 4;
	    while (n > 0) {
	       ReadChunkBytes(xd -> iff, & type, sizeof(APTR));
	       n -= sizeof(APTR);
	       ReadChunkBytes(xd -> iff, & size, sizeof(APTR));
	       n -= sizeof(APTR);
	       name = (char *) malloc(size + 1);
	       ReadChunkBytes(xd -> iff, name, size);
	       name[size] = '\0';
	       n -= size;
	       if (size % 4 != 0) {
		  ReadChunkBytes(xd -> iff, devNull, 4 - (size % 4));
		  n -= 4 - (size % 4);
	       }

	       xd_declareTypeAssoc(xd, name, NULL, type, xd -> ltypes);
	       free(name);
	    }
	 }
      }
      else {
	 xd_error(xd, XD_NO_ID_XFIE, NULL);
      }


      /*
       ** Read the XUSE chunk
       */
      if (xd_skipToId(xd, ID_XUSE)) {
	 struct ContextNode *cn = CurrentChunk(xd -> iff);
	 if (! cn) {
	    xd_error(xd, XD_NO_ID_XUSE, NULL);
	    result = NULL;
	 }
	 else {
	    int n, length;
	    char *key, *value;
	    n = cn -> cn_Size - 4;
	    while (n > 0) {
	       /*
		** Read the key...
		*/ 
	       ReadChunkBytes(xd -> iff, & length, sizeof(length));
	       n -= sizeof(length);
	       key = (char *) malloc(length + 1);
	       ReadChunkBytes(xd -> iff, key, length);
	       n -= length;
	       key[length] = '\0';
	       if (length % 4 != 0) {
		 ReadChunkBytes(xd -> iff, devNull, 4 - (length % 4));
		 n -= 4 - (length % 4);
	      }

	       /*
		** ... and the value
		*/ 
	       ReadChunkBytes(xd -> iff, & length, sizeof(length));
	       n -= sizeof(length);
	       value = (char *) malloc(length + 1);
	       ReadChunkBytes(xd -> iff, value, length);
	       n -= length;
	       value[length] = '\0';
	       if (length % 4 != 0) {
		  ReadChunkBytes(xd -> iff, devNull, 4 - (length % 4));
		  n -= 4 - (length % 4);
	       }
	       xd_declareShared(xd, key, value);
	    }  /* while n > 0 */
	 }
      }
      else {
	 xd_error(xd, XD_NO_ID_XUSE, NULL);
      }
   }
   return result;
}


/***********************************************************************
 * Public
 ***********************************************************************/

int
xd_Init(void)
{
   int result = 0;

   IFFParseBase = (struct IFFParseBase *) OpenLibrary("iffparse.library", 0L);
   if (IFFParseBase == NULL) {
      result = 1;
   }

   return result;
}

void
xd_Uninit(Xd_Database xd)
{
   if (xd != NULL) {
      xd_freeList(xd -> ltypes);
      xd_freeList(xd -> lshared);
      SAFEFREE(xd -> fileType);
      SAFEFREE(xd -> application);
      SAFEFREE(xd -> author);
      SAFEFREE(xd -> version);
      SAFEFREE(xd -> date);
      SAFEFREE(xd);
   }
   if (IFFParseBase != NULL) {
      CloseLibrary((struct Library *) IFFParseBase);
      IFFParseBase = NULL;
   }
}

Xd_Error
xd_ErrorCode(Xd_Database xd)
{
   return xd -> errorNumber;
}

char *
xd_ErrorString(Xd_Database xd)
{
   return "An error occured\n";
}

void
xd_Close(Xd_Database xd)
{
   PopChunk(xd -> iff);    /* pop the XCON chunk */
   CloseIFF(xd -> iff);
   Close(xd -> iff -> iff_Stream);
   FreeIFF(xd -> iff);
}

void
xd_DeclareApplication(Xd_Database xd, char *application)
{
   xd -> application = strdup(application);
}

void
xd_DeclareAuthor(Xd_Database xd, char *author)
{
   xd -> author = strdup(author);
}

void
xd_DeclareVersion(Xd_Database xd, char *version)
{
   xd -> version = strdup(version);
}

void
xd_DeclareDate(Xd_Database xd, char *date)
{
   xd -> date = strdup(date);
}


char *
xd_ReadType(Xd_Database xd)
{
   return xd -> fileType;
}

char *
xd_ReadApplication(Xd_Database xd)
{
   return xd -> application;
}

char *
xd_ReadAuthor(Xd_Database xd)
{
   return xd -> author;
}

char *
xd_ReadDate(Xd_Database xd)
{
   return xd -> date;
}

char *
xd_ReadVersion(Xd_Database xd)
{
   return xd -> version;
}


Xd_Database
xd_Open(char *filename, Xd_Mode mode, char *fileType)
{
   BPTR f;
   struct IFFHandle *iff;
   Xd_Database result;

   /* Try to open the file */
   f = Open(filename, (mode == XD_WRITE ? MODE_NEWFILE : MODE_OLDFILE));
   if (f == NULL) {
      return NULL;
   }

   /* Allocate the value we will return */
   NEW(result, struct _Xd_Database);
   memset(result, 0, sizeof(*result));

   /* ... and fill it */
   NEW(result -> ltypes, struct List);
   NEW(result -> lshared, struct List);
   NewList(result -> ltypes);
   NewList(result -> lshared);

   iff = result -> iff = AllocIFF();
   if (iff == NULL) {
      xd_error(result, XD_NO_ALLOC_IFF, NULL);
      result = NULL;
   }
   else {
      iff -> iff_Stream = f;

      InitIFFasDOS(iff);

      if (fileType == NULL || fileType[0] == '\0') {
	 xd_error(result, XD_NO_VALID_FILETYPE, NULL);
	 result = NULL;
      }
      else {
	 result -> fileType = strdup(fileType);
	 if (mode == XD_READ) {
	    if (OpenIFF(iff, IFFF_READ)) {
	       xd_error(result, XD_NO_OPENIFF_READ, NULL);
	       result = NULL;
	    }
	    else {
	      result = xd_readHeader(result, fileType);
	   }
	 }
	 
	 else if (mode == XD_WRITE) {
	    if (OpenIFF(iff, IFFF_WRITE)) {
	       xd_error(result, XD_NO_OPENIFF_WRITE, NULL);
	       result =  NULL;
	    }
	    else {
	       PushChunk(iff, ID_XDAT, ID_LIST, IFFSIZE_UNKNOWN);
	       PushChunk(iff, ID_XSHA, ID_PROP, IFFSIZE_UNKNOWN);
	    }
	 }
      }
   }
   
   return result;
}

void
xd_DeclareSharedString(Xd_Database xd, char *field, char *value)
{
   struct TypeAssoc *ta;
   NEW(ta, struct TypeAssoc);
   ta -> node.ln_Name = strdup(field);
   ta -> type = XD_STRING;
   ta -> value = strdup(value);
   AddTail(xd -> lshared, (struct Node *) ta);
}

void
xd_ReadSharedString(Xd_Database xd, char *field, char **value)
{

   struct TypeAssoc *ta = (struct TypeAssoc *) FindName(xd -> lshared, field);
   if (ta)
     *value = ta -> value;
   else
     *value = NULL;
}

int
xd_DeclareField(Xd_Database xd, char *field, Xd_Type type)
{
   int result = 0;

   if (! xd_declareTypeAssoc(xd, field, NULL, type, xd -> ltypes)) {
      xd_error(xd, XD_NO_NEW_FIELD_ALLOWED, field);
      result = 1;
   }

   return result;

}

void
xd_AssignField(Xd_Database xd, char *field, void *value)
/**@@**/
{
   struct TypeAssoc *type = xd_findType(xd -> ltypes, field);

   if (type) {
      if (type -> type == XD_STRING)
        type -> value = strdup((char *) value);
      else if (type -> type == XD_INTEGER)
        type -> value = value;
      else
	xd_error(xd, XD_UNKNOWN_FIELD_TYPE, NULL);
   }
   else
     xd_error(xd, XD_UNKNOWN_FIELD, field);
}

void
xd_WriteRecord(Xd_Database xd)
{
   struct Node *node;
   struct List *list;
   int size = 0;

   if (xd -> writeOccured == 0) {
      xd_writeHeader(xd);
      xd -> writeOccured = 1;
   }

   /*
    ** Writing the record means opening an XREC chunk and
    ** dumping the data
    */

   PushChunk(xd -> iff, ID_XCON, ID_XREC, IFFSIZE_UNKNOWN);
   list = xd -> ltypes;
   for (node = list -> lh_Head; node -> ln_Succ; node = node -> ln_Succ) {
      struct TypeAssoc *ta = (struct TypeAssoc *) node;

      /* Calculate the size to put here */
      if (ta -> type == XD_STRING) size = strlen(ta -> value);
      else if (ta -> type == XD_INTEGER) size = sizeof(int);

      /* ... and then write the chunk */
      xd_writeChunk(xd -> iff, ta -> value, size);

   }
   PopChunk(xd -> iff);   /* popping xrec */
}


int
xd_NextRecord(Xd_Database xd)
{
   struct Node *node;
   struct List *list = xd -> ltypes;
   int error;
   int result;

/*
 ** Basically, this function skips to the next XREC chunk. It
 ** reads its length, and then the fields in the same order as
 ** they were found declared in the XFIE chunk. They are stored
 ** in the xd -> ltypes list variable, where they can be retrieved
 ** individually later on with xd_ReadField()
 */

   /* First skip to first XREC hunk */
   if (! xd_skipToType(xd, ID_XCON)) {
      xd_error(xd, XD_NO_TYPE_XCON, NULL);
      return 0;
   }

   StopChunk(xd -> iff, ID_XCON, ID_XREC);
   error = ParseIFF(xd -> iff, IFFPARSE_SCAN);
   if (error == IFFERR_EOF) {
      result = 0;
   }
   else {
      char devNull[10];   /* buffer to hold pad bytes */
      result = 1;
      for (node = list -> lh_Head; node -> ln_Succ; node = node -> ln_Succ) {
	 struct TypeAssoc *ta = (struct TypeAssoc *) node;
	 int n;
	 void *value;
	 ReadChunkBytes(xd -> iff, & n, sizeof(n));
	 value = malloc(n + 1);
	 ReadChunkBytes(xd -> iff, value, n);
	 if (n % 4 != 0)
	   ReadChunkBytes(xd -> iff, devNull, 4 - (n % 4));
	 if (ta -> value) free(ta -> value);   /* free previous value */
	 ta -> value = value;
	 if (ta -> type == XD_STRING)
	   ((char *) ta -> value)[n] = '\0';
      }
   }

   return result;
}

int
xd_EndOfFile(Xd_Database xd)
/* Return 1 if the end of file is reached, 0 otherwise */
{
   return (ParseIFF(xd -> iff, IFFPARSE_RAWSTEP) == IFFERR_EOF);
}

int
xd_ReadField(Xd_Database xd, char *field, Xd_Type type, void *dest)
/* Read a field into the variable dest */
/* Return : 1 if the field doesn't exist */
{
   int result = 0;
   struct TypeAssoc *ta;

   ta = (struct TypeAssoc *) FindName(xd -> ltypes, field);
   if (ta == NULL) {
      xd_error(xd, XD_UNKNOWN_FIELD, field);
      result = 1;
   }
     else {
      type = ta -> type;
      if (type == XD_INTEGER) {
	 int n = * (int *) ta -> value;
	 * (int *) dest = n;
      }
      else if (type == XD_STRING) {
	 char *string = strdup(ta -> value);
	 * (char **) dest = string;
      }
   }

   return result;
}
