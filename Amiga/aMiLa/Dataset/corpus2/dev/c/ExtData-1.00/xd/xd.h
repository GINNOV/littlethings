/* Copyright © 1994 Cedric Beust. See file COPYRIGHT for more information */
/* 
 * xd.h
 *
 * $Id: xd.h,v 1.7 1994/01/27 22:13:40 beust Exp beust $
 */

/*
 ** Main include for the ExtData package.
 ** Functions start with xd_
 ** Types start with Xd_
 */

static char *version = "\0$VER: version 1.00 (27-01-94)";

/*===========================================================================
 ** Includes
 */

/* Prototypes */
#include <clib/iffparse_protos.h>
#include <clib/dos_protos.h>
#include <clib/exec_protos.h>
#include <clib/alib_protos.h>

/* Libraries definition */
#include <libraries/iffparse.h>

#include <exec/lists.h>
#include <stdlib.h>
#include <string.h>

/*===========================================================================
 ** Types
 */

          /* Flags for xd_Open() */
typedef enum { XD_READ, XD_WRITE }

                Xd_Mode;

          /* Flags for xd_DeclareType() */
typedef enum { XD_UNKNOWN_TYPE, XD_STRING, XD_INTEGER}

                Xd_Type; 

          /* The main type */
typedef struct _Xd_Database

                *Xd_Database;


          /* The possible errors */
typedef enum {
   XD_FIELD_ALREADY_EXISTS = 1,
   XD_NO_TYPE_XSHA = 2,
   XD_NO_ID_XINF = 3,
   XD_NO_ID_XFIE = 4,
   XD_NO_ID_XUSE = 5,
   XD_NO_IFFPARSE = 6,
   XD_NO_FILE_READ = 7,
   XD_NO_ALLOC_IFF = 8,
   XD_NO_VALID_FILETYPE = 9,
   XD_NO_OPENIFF_READ = 10,
   XD_NO_OPENIFF_WRITE = 11,
   XD_NO_NEW_FIELD_ALLOWED = 12,
   XD_UNKNOWN_FIELD_TYPE = 13,
   XD_UNKNOWN_FIELD = 14,
   XD_NO_TYPE_XCON = 15,
}

                *Xd_Error;

/*===========================================================================
 ** Function prototypes
 */

/*----------------------------------------------------------------------
 ** xd_Init
 ** Initialize xd. Must be called before using any other function
 ** Return 0 if successful.
 */
int
xd_Init(void);


/*---------------------------------------------------------------------------
 ** xd_Uninit
 ** Close xd and free its resources
 */
void
xd_Uninit(Xd_Database xd);


/*---------------------------------------------------------------------------
 ** xd_Open
 ** Open a file in XD_READ or XD_WRITE mode.
 ** fileType is the type of this file. In XD_WRITE mode, it will
 ** be written to the file. In XD_READ mode, it will be compared to the
 ** one read in the file and xd_Open will fail if both strings do not
 ** match exactly. fileType must be non NULL and non empty, or xd_Open will
 ** fail.
 ** Return descriptor of the xd base or NULL if an error occured.
 */
Xd_Database
xd_Open(char *filename, Xd_Mode mode, char *fileType);


/*---------------------------------------------------------------------------
 ** xd_Close
 ** Close the file
 */
void
xd_Close(Xd_Database xd);


/*---------------------------------------------------------------------------
 ** xd_ErrorCode
 ** Return the error code of latest function.
 */
Xd_Error
xd_ErrorCode(Xd_Database xd);


/*---------------------------------------------------------------------------
 ** xd_ErrorString
 ** Return the error string of latest function. This string is a pointer in
 ** my internal space, do NOT free it or alter it.
 */
char *
xd_ErrorString(Xd_Database xd);


/*---------------------------------------------------------------------------
 ** xd_DeclareAuthor
 ** Declare the author of this file
 */
void
xd_DeclareAuthor(Xd_Database xd, char *author);


/*---------------------------------------------------------------------------
 ** xd_DeclareApplication
 ** Declare the application for this file
 */
void
xd_DeclareApplication(Xd_Database xd, char *application);


/*---------------------------------------------------------------------------
 ** xd_DeclareVersion
 ** Declare the version of this file (or the program that can read it)
 */
void
xd_DeclareVersion(Xd_Database xd, char *version);


/*---------------------------------------------------------------------------
 ** xd_DeclareDate
 ** Declare the date for this file
 */
void
xd_DeclareDate(Xd_Database xd, char *date);


/*---------------------------------------------------------------------------
 ** xd_ReadType
 ** Return : the type this file (this is a pointer to my
 ** internal space, do NOT alter it or free it)
 */
char *
xd_ReadType(Xd_Database xd);


/*---------------------------------------------------------------------------
 ** xd_ReadApplication
 ** Return : the application name of this file (this is a pointer to my
 ** internal space, do NOT alter it or free it)
 */
char *
xd_ReadApplication(Xd_Database xd);


/*---------------------------------------------------------------------------
 ** xd_ReadAuthor
 ** Return : the author of this file (this is a pointer to my
 ** internal space, do NOT alter it or free it)
 */
char *
xd_ReadAuthor(Xd_Database xd);


/*---------------------------------------------------------------------------
 ** xd_ReadDate
 ** Return : the date of this file (this is a pointer to my
 ** internal space, do NOT alter it or free it)
 */
char *
xd_ReadDate(Xd_Database xd);


/*---------------------------------------------------------------------------
 ** xd_ReadVersion
 ** Return : the version of this file (this is a pointer to my
 ** internal space, do NOT alter it or free it)
 */
char *
xd_ReadVersion(Xd_Database xd);


/*---------------------------------------------------------------------------
 ** xd_DeclareSharedString
 ** Declare a pair key/value into the common pool of the file
 */
void
xd_DeclareSharedString(Xd_Database xd, char *field, char *value);


/*---------------------------------------------------------------------------
 ** xd_ReadSharedString
 ** Fill the value associated to the key in the common part
 ** of the file. *value will contain a pointer to our internal
 ** structure. Do NOT free it, or alter it. If this shared string
 ** doesn't exist, *value will contain NULL
 */
void
xd_ReadSharedString(Xd_Database xd, char *key, char **value);


/*---------------------------------------------------------------------------
 ** xd_DeclareField
 ** Declare a new field and its type (XD_INTEGER, XD_STRING, ...)
 ** Return 0 if successful.
 */
int
xd_DeclareField(Xd_Database xd, char *field, Xd_Type type);


/*---------------------------------------------------------------------------
 ** xd_AssignField
 ** Assign the given field with the value
 */
void
xd_AssignField(Xd_Database xd, char *field, void *value);


/*---------------------------------------------------------------------------
 ** xd_WriteRecord
 ** Write to the file the record as it is so far
 */
void
xd_WriteRecord(Xd_Database xd);


/*---------------------------------------------------------------------------
 ** xd_NextRecord
 ** Skip to next record in database xd
 ** Return 0 if EOF reached
 */
int
xd_NextRecord(Xd_Database xd);


/*---------------------------------------------------------------------------
 ** xd_EndOfFile
 ** Return 1 if the end of file is reached, 0 otherwise
 */
int
xd_EndOfFile(Xd_Database xd);


/*---------------------------------------------------------------------------
 ** xd_ReadField
 ** Read a field into the variable dest
 ** If type == STRING, this function will allocate a string to hold the
 ** result. The returned value must be freed with xd_Free()
 ** Return 1 if the field doesn't exist
 */
int
xd_ReadField(Xd_Database xd, char *field, Xd_Type type, void *dest);


/*---------------------------------------------------------------------------
 ** xd_Free
 ** Free a variable prealably allocated by xd
 */
void
xd_Free(void *var);


