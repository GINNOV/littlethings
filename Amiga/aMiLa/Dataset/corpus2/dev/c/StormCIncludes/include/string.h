#ifndef _INCLUDE_STRING_H
#define _INCLUDE_STRING_H

/*
**  $VER: string.h 1.3 (21.07.2000)
**  StormC Release 4.0
**
**  '(C) Copyright 1995-2000 Haage & Partner Computer GmbH'
**   All Rights Reserved
*/

#ifndef _INCLUDE_STDDEF_H
#include <stddef.h>
#endif

#ifdef __cplusplus
extern "C" {
#endif

#ifndef NULL
#define NULL 0
#endif


char *strncpy(char *, const char *, size_t);
char *strncat(char *, const char *, size_t);

int strncmp(const char *, const char *, size_t);
char *strchr (const char *, int);
char *strrchr(const char *, int);
size_t strspn (const char *, const char *);
size_t strcspn(const char *, const char *);
char *strpbrk(const char *, const char *);
char *strstr(const char *, const char *);

char *strerror(int);
char *strtok(char *, const char *);

int stricmp(const char *, const char *);
int strnicmp(const char *, const char *, size_t);
char *strlwr(char *);
char *strupr(char *);

int memcmp(const void *, const void *, size_t);
void *memchr(const void *, int, size_t);
void *memcpy(void *, const void *, size_t);
void *memmove(void *, const void *, size_t);
void *memset(void *, int, size_t);

#ifndef _ANSI_SOURCE
int	 bcmp (const void *, const void *, size_t);
void bcopy (const void *, void *, size_t);
void bzero (void *, size_t);
int  ffs (int);
char *index (const char *, int);
char *rindex (const char *, int);
int  strcasecmp (const char *, const char *);
char *strdup (const char *);
void strmode (int, char *);
int  strncasecmp (const char *, const char *, size_t);
char *strsep (char **, const char *);
void swab (const void *, void *, size_t);
#endif

#ifndef _INLINE_INCLUDES
char *strcpy (char *, const char *);
char *strcat (char *, const char *);
int strcmp (const char *, const char *);
size_t strlen(const char *);
#endif


#ifdef __cplusplus
}
#endif


#ifdef _INLINE_INCLUDES
__inline char *strcpy (char *d, const char *s)
{
    char *e = d;
    while ((*(e++) = *(s++)))
        ;
    return d;
}
__inline char *strcat (char *d, const char *s)
{
    char *e = d;
    while (*(e++))
        ;
    e--;
    while ((*(e++) = *(s++)))
        ;
    return d;
}
__inline int strcmp(const char *s1, const char *s2)
{
    char ch1,ch2;
    while ((ch1 = *(s1++)) && ch1 == *(s2++))
        ;
    return ch1 ? ((ch2 = *(s2-1)) == ch1 ? 0 : (ch1 < ch2 ? -1 : 1)) : (*s2 ? -1 : 0);
}
__inline size_t strlen(const char *s)
{
    const char *t = s;
    while (*(t++))
        ;
    return (size_t) (t - s - 1);
}
#endif	/* _INLINE_INCLUDES */

#endif	/* _INCLUDE_STRING_H */
