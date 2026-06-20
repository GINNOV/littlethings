/*
 *	$VER: stringlib.h V1.2 (11.12.98) for free use
 *
 *  #define VBCC needed for VBCC
 *  #define MANX needed for Aztec-C
 *
 *  
 *
 *	Include this file at your source and link the stringlib_(CPU).lib
 *	If nessasary add here your own ALIAS or anything else.
 *  All Lib-functions hast first char as uppercase.
 *  The following defines will change that to standardnames (lowercase).
 *
 *  You can delete all defines of functions that your compiler support
 *  to mix this functions with originals. You also can overwrite the
 *  compilerfunctions, if you really want that.
 *
 *  You will find functions that seems to be duplicate. This is not
 *  right. For example, take a look of strlower and strlwr. Shure,
 *  both functions take a string and change all chars to lowercase.
 *  One work with pointeroncrement, the other with the stringfield.
 *  Duplicates generell: Most, there is a fast and a secure version.
 *  Both must be work correct.But if not, take the other. In the future
 *  i will make a table with speedtest's and document that detailed.
 *
 *  IMPORTANT!
 *  **********
 *  To use the defines in this file the STRINGLIB.lib must be included
 *  bevor this file. Otherwise it can and will not work. It may be that
 *  your linker work of another way and you can include the lib later.
 *  Normally it will make problems. If your linker don't work correctly
 *  with this file you must use the internal names directly.
 *
 *	RELEASENOTES:
 *  -------------
 *
 *	VBCC: To use with vbcc you have two alternatives:
 *
 *       1.) don't include 'string.h', ignore original vbcc-functions.
 *
 *       2.) BETTER: define VBCC and include string.h. this will add all
 *           functions that not implemented but the duplicates will not
 *           the default. Use lib-functions with the first letter
 *           uppercase. 
 *
 * MANX: The define's are now obsolete, aztec has own lib-format and
 *       can not read actual release.
 *       If you work with Aztec: let me know, i can create the lib
 *       for Manx.
 *
 * other: correct ths file, best you lock in your string(s).h-include
 *        to see what your compiler support. If you send me this file
 *        updated back, i will include the defines for future use.
 */

#ifndef _STRING_LIB_DEF
#define _STRING_LIB_DEF 1

#include <ctype.h>
#include "proto/STRINGLIB_protos.h"	/* automatic generated from pmm */

	/* MANX Aztec named it swapmem...
     *
	 * ...and my own programs use swapmem
	 */

#ifndef MANX
#define		swapmem (register char *s1, register char *s2, register int n)\
			Swap (register char *s1, register char *s2, register int n)
#endif

	/* Alias-List for "normal" functionnames */

#define		bcmp (const char *s1, const char *s2, int length)\
			Bcmp (const char *s1, const char *s2, int length)
#define		bcopy (const char *src, char *dst, int length)\
			Bcopy (const char *src, char *dst, int length)
#define		bzero (char *dst, int length)\
			Bzero (char *dst, int length)

#ifndef MANX
#define		index (char *s, char charwanted)\
			Index (char *s, char charwanted)
#endif

#define		lmemmove (register char *dest, register char *source, register long len)\
			Lmemmove (register char *dest, register char *source, register long len)

#ifndef MANX
#define		memccpy (char *dst, const char *src, char ucharstop, int size)\
			Memccpy (char *dst, const char *src, char ucharstop, int size)
#ifndef VBCC
#define		memchr (char *s, register char uc, int size)\
			Memchr (char *s, register char uc, int size)
#define		memcmp (const char *s1, const char * s2, int size)\
			Memcmp (const char *s1, const char * s2, int size)
#define		memcpy (char *dst, const char * src, int size)\
			Memcpy (char *dst, const char * src, int size)
#endif
#endif

#define		memicmp (register char *mem1, register char *mem2, register int len)\
			Memicmp (register char *mem1, register char *mem2, register int len)

#ifndef MANX
#ifndef VBCC
#define		memmove (void *s1, const void *s2, int n)\
			Memmove (void *s1, const void *s2, int n)
#endif
#endif

#define		memncmp (char *a, char *b, int length)\
			Memncmp (char *a, char *b, int length)

#ifndef MANX
#ifndef VBCC
#define		memset (char *s, register char ucharfill, int size)\
			Memset (char *s, register char ucharfill, int size)
#endif
#define		rindex (char *s, char charwanted)\
			Rindex (char *s, char charwanted)
#endif

#define		stpchr (const char *str, char c)\
			Stpchr (const char *str, char c)
#define		stpcpy (char *d, const char *s)\
			Stpcpy (char *d, const char *s)
#define		stradj (register char *string, register int dir)\
			Stradj (register char *string, register int dir)
#define		strbpl (char **av, int max, char *sary)\
			Strbpl (char **av, int max, char *sary)
#define		strcasecmp (const char *s, const char *d)\
			Strcasecmp (const char *s, const char *d)

#ifndef MANX
#ifndef VBCC
#define		strcat (char *dst, const char *src)\
			Strcat (char *dst, const char *src)
#define		strchr (char *s, register char charwanted)\
			Strchr (char *s, register char charwanted)
#define		strcmp (const char *s1, const char *s2)\
			Strcmp (const char *s1, const char *s2)
#define		strcpy (char *dst, const char *src)\
			Strcpy (char *dst, const char *src)
#define		strcspn (const char *s, const char *reject)\
			Strcspn (const char *s, const char *reject)
#endif
#endif

#define		strdcat (char *s1, char *s2)\
			Strdcat (char *s1, char *s2)

#ifndef MANX
#ifndef VBCC
#define		strdup (char *string)\
			Strdup (char *string)
#endif
#define		stricmp (const char *str1, const char *str2)\
			Stricmp (const char *str1, const char *str2)
#endif

#define		strins (char *d, const char *s)\
			Strins (char *d, const char *s)
#define		strinstr (char *s, int c)\
			Strinstr (char *s, int c)
#define		strirpl (char *string, char *ptrn, register char *rpl, register int n)\
			Strirpl (char *string, char *ptrn, register char *rpl, register int n)
#define		stristr (register char *string, register char *pattern)\
			Stristr (register char *string, register char *pattern)

#ifndef MANX
#ifndef VBCC
#define		strlen (const char *s)\
			Strlen (const char *s)
#endif
#endif

#define		strlencmp (char *s, char *t, int n)\
			Strlencmp (char *s, char *t, int n)
#define		strlower (char *s)\
			Strlower (char *s)

#ifndef MANX
#define		strlwr (register char *string)\
			Strlwr (register char *string)
#endif

#define		strncasecmp (const char *s, const char *d, int n)\
			Strncasecmp (const char *s, const char *d, int n)

#ifndef MANX
#ifndef VBCC
#define		strncat (char *dst, const char *src, int n)\
			Strncat (char *dst, const char *src, int n)
#define		strncmp (const char *s1, const char *s2, int n)\
			Strncmp (const char *s1, const char *s2, int n)
#define		strncpy (char *dst, const char *src, int n)\
			Strncpy (char *dst, const char *src, int n)
#endif
#endif

#define		strndup (char *string, int n)\
			Strndup (char *string, int n)

#ifndef MANX
#define		strnicmp (const char *str1, const char *str2, int n)\
			Strnicmp (const char *str1, const char *str2, int n)
#endif

#define		strnset (char *string, register char c, register int n)\
			Strnset (char *string, register char c, register int n)

#ifndef MANX
#ifndef VBCC
#define		strpbrk (char *s, char *breakat)\
			Strpbrk (char *s, char *breakat)
#endif
#endif

#define		strpcpy (register char *dest, register char *start, register char *end)\
			Strpcpy (register char *dest, register char *start, register char *end)
#define		strpos (register char *string, register char symbol)\
			Strpos (register char *string, register char symbol)

#ifndef MANX
#ifndef VBCC
#define		strrchr (char *s, register char charwanted)\
			Strrchr (char *s, register char charwanted)
#endif
#endif

#define		strrev (char *string)\
			Strrev (char *string)
#define		strrpbrk (register char *string, register char *set)\
			Strrpbrk (register char *string, register char *set)
#define		strrpl (char *string, char *ptrn, register char *rpl, register int n)\
			Strrpl (char *string, char *ptrn, register char *rpl, register int n)
#define		strrpos (register char *string, register char symbol)\
			Strrpos (register char *string, register char symbol)
#define		strset (char *string, register char c)\
			Strset (char *string, register char c)

#ifndef MANX
#ifndef VBCC
#define		strspn (const char *s, const char *accept)\
			Strspn (const char *s, const char *accept)
#define		strstr (char *s, char *wanted)\
			Strstr (char *s, char *wanted)
#define		strtod (char *string, char **ptr)\
			Strtod (char *string, char **ptr)
#define		strtok (char *s, register const char *delim)\
			Strtok (char *s, register const char *delim)
#define		strtol (char *ptr, char **tail, int base)\
			Strtol (char *ptr, char **tail, int base)
#endif
#endif

#define		strtolong (char *string, long *value)\
			Strtolong (char *string, long *value)
#define		strtosd (char *string, char **ptr, double base)\
			Strtosd (char *string, char **ptr, double base)
#define		strtosud (char *string, char **ptr, double base)\
			Strtosud (char *string, char **ptr, double base)

#ifndef MANX
#ifndef VBCC
#define		strtoul (char *ptr,char **tail, int base)\
			Strtoul (char *ptr,char **tail, int base)
#endif
#endif

#define		strtrim (register char *string, register char *junk)\
			Strtrim (register char *string, register char *junk)
#define		strupp (char *pc)\
			Strupp (char *pc)
#define		strupper (char *s)\
			Strupper (char *s)

#ifndef MANX
#define		strupr (register char *string)\
			Strupr (register char *string)
#endif

#define		subnstr (register char *dest, register char *source, register int start, register int end,register int length)\
			Subnstr (register char *dest, register char *source, register int start, register int end,register int length)
#define		substr (register char *dest, register char *source, register int start, register int end)\
			Substr (register char *dest, register char *source, register int start, register int end)
#define		swap (register char *s1, register char *s2, register int n)\
			Swap (register char *s1, register char *s2, register int n)

#ifndef MANX
#ifndef VBCC
#define		tolower (char c)\
			Tolower (char c)
#define		toupper (char c)\
			Toupper (char c)
#endif
#endif

#endif

/*
 *  end of file
 */
