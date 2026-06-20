/* $Id: strappend.c,v 2.0.1.2 1994/01/07 07:05:39 greyham Exp $
 */
#include "c2man.h"
#include "strappend.h"

#ifdef I_STDARG
#include <stdarg.h>
#endif
#ifdef I_VARARGS
#include <varargs.h>
#endif

extern void outmem();

/*
 * append a list of strings to another, storing them in a malloc'ed region.
 * The first string may be NULL, in which case the rest are simply concatenated.
 */
#ifdef I_STDARG
char *strappend(char *first, ...)
#else
char *strappend(va_alist)
    va_dcl
#endif
{
    size_t totallen;
    va_list argp;
    char *s, *retstring;
#ifndef I_STDARG
    char *first;
#endif    
    /* add up the total length */
#ifdef I_STDARG
    va_start(argp,first);
#else
    va_start(argp);
    first = va_arg(argp, char *);
#endif
    totallen = first ? strlen(first) : 0;
    while ((s = va_arg(argp,char *)) != NULL)
	totallen += strlen(s);
    va_end(argp);
    
    /* malloc the memory */
    totallen++;	/* add space for the nul terminator */
    if ((retstring = first ? realloc(first,totallen) : malloc(totallen)) == 0)
	outmem();

    if (first == NULL)	*retstring = '\0';

#ifdef I_STDARG
    va_start(argp,first);
#else
    va_start(argp);
    first = va_arg(argp, char *);	/* skip the first arg */
#endif

    while ((s = va_arg(argp,char *)) != NULL)
	strcat(retstring,s);

    va_end(argp);

    return retstring;
}
