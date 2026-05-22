/* $Id: strconcat.c,v 2.0.1.1 1993/05/17 02:12:09 greyham Exp $
 * concatenate a list of strings, storing them in a malloc'ed region
 */
#include "c2man.h"
#include "strconcat.h"

#ifdef I_STDARG
#include <stdarg.h>
#endif
#ifdef I_VARARGS
#include <varargs.h>
#endif

extern void outmem();

#ifdef I_STDARG
char *strconcat(const char *first, ...)
#else
char *strconcat(va_alist)
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
#ifdef DEBUG
    fprintf(stderr,"strconcat: \"%s\"",first);
#endif
    totallen = strlen(first);
    while ((s = va_arg(argp,char *)) != NULL)
    {
	totallen += strlen(s);
#ifdef DEBUG
	fprintf(stderr,",\"%s\"",s);
#endif
    }
#ifdef DEBUG
    fprintf(stderr,"\nstrlen = %ld\n",(long)totallen);
#endif
    va_end(argp);
    
    /* malloc the memory */
    if ((retstring = malloc(totallen + 1)) == 0)
	outmem();
	
#ifdef I_STDARG
    va_start(argp,first);
#else
    va_start(argp);
    first = va_arg(argp, char *);
#endif
    /* copy the stuff in */
    strcpy(retstring,first);

    while ((s = va_arg(argp,char *)) != NULL)
	strcat(retstring,s);

    va_end(argp);

#ifdef DEBUG
    fprintf(stderr,"strconcat returns \"%s\"\n",retstring);
#endif
    return retstring;
}
