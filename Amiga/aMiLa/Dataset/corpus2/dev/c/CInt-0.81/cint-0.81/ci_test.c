;/* To compile, type
;
       sc ci_test
;
; or execute this file.
;
quit 0
*/

/******************************************************************************

    MODUL
	ci_test.c

    DESCRIPTION
	This is a short example for the usage of the C-Interpreter.
	Just call it with the name of one or more files. The files
	will all be converted to CInt-objects and executed one by one.

    NOTES

    BUGS

    TODO

    EXAMPLES

    SEE ALSO

    INDEX

    HISTORY
	29-05-95    digulla created

******************************************************************************/

/**************************************
		Includes
**************************************/
#ifndef IN_STDDEF_H
#   include <in_stddef.h>
#endif
#ifndef INTERPRETER_CINT_H
#   include <interpreter/cint.h>
#endif
#ifndef PROTO_CINT_H
#   include <proto/cint.h>
#endif
#ifndef CLIB_INTUITION_PROTOS_H
#   include <clib/intuition_protos.h>
#endif
#ifndef CLIB_ALIB_PROTOS_H
#   include <clib/alib_protos.h>
#endif
#ifndef PROTO_EXEC_H
#   include <proto/exec.h>
#endif
#ifndef PROTO_INTUITION_H
#   include <proto/intuition.h>
#endif


/**************************************
	    Globale Variable
**************************************/
struct CIntBase * CIntBase;
extern int errno;


/**************************************
      Interne Defines & Strukturen
**************************************/


/**************************************
	   Interne Prototypes
**************************************/
int PrintString P((char*str));
int lvl P((char*ptr));
void ShowError P((Object*ciobj));


/**************************************
	    Interne Variable
**************************************/
/* one user-defined function and a couple of variables */
SymDef testsyms[]=
{
    { "int PrintString (string);",              (APTR)PrintString   },
    { "string GlobalString; int GlobalInt;",    NULL                },
    { NULL,							    }
};


/*****************************************************************************

    NAME
	main

    SYNOPSIS
	int main (int argc, char ** argv)

    FUNCTION
	The main-function. Read in a number of files and execute them
	right away.

    INPUTS

    RESULT

    NOTES

    EXAMPLE

    BUGS

    SEE ALSO

    INTERNALS

    HISTORY
	29-05-95    digulla created

******************************************************************************/

int main PROTO2(int, argc, char **, argv)
{
    int rc;
    Object * ciobj;
    struct TagItem tags[2];
    FILE * fh;
    char   puffer[4096];
    int    len;
    Value  result;

    if (!(CIntBase = (struct CIntBase *) OpenLibrary (CINTNAME, 0)) )
    {
	fprintf (stderr, "OpenLibrary() failed.\n");
	rc = 10;
	goto exit;
    }

    if (argc == 1)
    {
	fprintf (stderr, "Usage: ci (option|file)*");
	rc = 5;
	goto exit;
    }

    argc --; argv ++;

    if (!(ciobj= CInt_NewObject (NULL, CINTCLASS, TAG_END)) )
    {
	fprintf (stderr, "Can't create CInt-object.\n");
	rc = 10;
	goto exit;
    }

    rc = CInt_AddGlobalSymbols (testsyms);

    if (rc>5)
    {
	fprintf (stderr, "CInt_AddGlobalSymbols returned %d\n",rc);
	ShowError (ciobj);
	goto exit;
    }

    for( ; argc; argc --, argv ++)
    {
	if(**argv=='-')
	    continue;

	if ( (fh = fopen (*argv, "r")) )
	{
	    len = fread (puffer, 1, sizeof (puffer), fh);
	    fclose (fh);

	    if (len <= 0)
	    {
		fprintf (stderr, "Fehler beim Lesen von %s: %s\n", *argv,
		    strerror (errno));
		len = 0;
	    }

	    puffer[len] = 0;
	}
	else
	{
	    fprintf (stderr, "Kann %s nicht lesen: %s\n", *argv,
		strerror (errno));
	    *puffer = 0;
	}

	if (*puffer)
	{
	    fprintf (stderr, "----- working on -----\n%s\n", puffer);

	    rc= CInt_SetAttrs (ciobj
		, CIA_Source, puffer
		, TAG_END
		);

	    if (rc > 5)
		ShowError (ciobj);
	    else
	    {
		fprintf (stderr, "----- OUTPUT ------\n");

		CInt_InitValueStruct (&result);
		rc = CInt_DoMethod (ciobj, CIM_Execute, &result);

		if (rc)
		    ShowError (ciobj);
		else
		{
		    fprintf (stderr,"----- Ok. -----\n");

		    switch (result.v_Type)
		    {
		    case VT_BOOL:
			fprintf (stderr, "Result = %s\n",
			    result.v_Bool ? "TRUE" : "FALSE");
			break;

		    case VT_CHAR:
			fprintf (stderr, "Result = (char) %d\n",
			    result.v_Char);
			break;

		    case VT_INT:
			fprintf (stderr, "Result = (int) %d\n",
			    result.v_Int);
			break;

		    case VT_DOUBLE:
			fprintf (stderr, "Result = (double) %g\n",
			    result.v_Double);
			break;

		    case VT_STRING:
			fprintf (stderr, "Result = (string) \"%s\"\n",
			    result.v_String);
			break;

		    } /* switch */
		} /* if (!rc) */
	    } /* if (!rc) */
	} /* if (puffer) */
    } /* for all args */

    CInt_DisposeObject (ciobj);

exit:
    if (CIntBase)
    {
	CloseLibrary ((struct Library *)CIntBase);
    }

    return rc;
} /* main */


/*****************************************************************************

    NAME
	PrintString

    SYNOPSIS
	int PrintString (char * str);

    FUNCTION
	User-Function, callable from the C-interpreter. It prints its
	single parameter and returns its length.

    INPUTS
	str - String to print.

    RESULT
	Length of string.

    NOTES

    EXAMPLE

    BUGS

    SEE ALSO

    INTERNALS

    HISTORY
	29-05-95    digulla created

******************************************************************************/

int PrintString PROTO1(char *,str)
{
    fputs (str, stdout);

    return (int) strlen (str);
} /* PrintString */


/*****************************************************************************

    NAME
	ShowError

    SYNOPSIS
	void ShowError (Object * ciobj);

    FUNCTION
	Prints all error-messages that are stored in an interpreter-object.

    INPUTS
	ciobj - The object for which an error occured.

    RESULT
	None.

    NOTES

    EXAMPLE

    BUGS

    SEE ALSO

    INTERNALS

    HISTORY
	29-05-95    digulla created

******************************************************************************/

void ShowError PROTO1(Object *, ciobj)
{
    STRPTR * msgs, * ptr;
    int count = 1;

    CInt_GetAttr (CIA_ErrorMessage, ciobj, (ULONG *) &msgs);

    for (ptr=msgs; *ptr; ptr++)
    {
	fprintf (stderr, "Error %d -----\n%s\n", count ++, (char *)*ptr);
    }

    if (*msgs)
	fprintf (stderr, "-----\n");

    CInt_FreeErrorMessages (msgs);
} /* ShowError */


/******************************************************************************
*****  ENDE ci_test.c
******************************************************************************/
