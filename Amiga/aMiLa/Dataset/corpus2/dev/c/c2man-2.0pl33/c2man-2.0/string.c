/* $Id: string.c,v 2.0.1.2 1994/01/07 07:05:10 greyham Exp $
 *
 * Some string handling routines
 */
#include "c2man.h"
#include <ctype.h>

/* Copy the string into an allocated memory block.
 * Return a pointer to the copy.
 */
char *
strduplicate (s)
const char *s;	/* The string to copy. May be NULL */
{
    char *dest;

    if (!s)	return NULL;
    
    if ((dest = malloc((unsigned)(strlen(s)+1))) == NULL)
	outmem();

    strcpy(dest, s);
    return dest;
}

#ifndef HAS_STRSTR

/* Return a pointer to the first occurence of the substring 
 * within the string, or NULL if not found.
 */
char *
strstr (src, key)
const char *src, *key;
{
    char *s;
    int keylen;

    keylen = strlen(key);
    s = strchr(src, *key);
    while (s != NULL) {
	if (strncmp(s, key, keylen) == 0)
	    return s;
	s = strchr(s+1, *key);
    }
    return NULL;
}

#endif

/* compare two strings case insensitively, for up to n chars */
int strncmpi(s1, s2, n)
const char *s1, *s2;
size_t n;
{
    while(n--)
    {
	char c1 = *s1, c2 = *s2;

	if (c1 == '\0' && c2 == '\0')	break;

	if (isalpha(c1) && isupper(c1))	c1 = tolower(c1);
	if (isalpha(c2) && isupper(c2))	c2 = tolower(c2);

	if (c1 < c2)	return -1;
	if (c1 > c2)	return 1;
	s1++; s2++;
    }
    return 0;
}

/* convert string to upper case */
char *strtoupper(in)
char *in;
{
    char *s;

    for (s = in; *s; s++)
    {
	if (islower(*s))	*s = toupper(*s);
    }
    return in;
}
