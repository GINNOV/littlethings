#ifndef _INCLUDE_STRING_H
#define _INCLUDE_STRING_H

/*
**  $VER: string.h 1.1 (13.6.96)
**  StormC Release 1.1
**
**  '(C) Copyright 1995 Haage & Partner Computer GmbH'
**	 All Rights Reserved
*/

#ifdef __cplusplus
extern "C" {
#endif

#ifndef NULL
#define NULL 0
#endif

typedef unsigned int size_t;

#ifdef _INLINE_INCLUDES
__inline char *strcpy (char *d, const char *s)
{
	char *e = d;
	while ((*(e++) = *(s++)))
		;
	return d;
}
#else
char *strcpy (char *, const char *);
#endif

char *strncpy(char *, const char *, size_t);

#ifdef _INLINE_INCLUDES
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
#else
char *strcat (char *, const char *);
#endif

char *strncat(char *, const char *, size_t);

#ifdef _INLINE_INCLUDES
__inline int strcmp(const char *s1, const char *s2)
{
	int retval = 0;
	char ch1,ch2;
	while ((ch1 = *(s1++)) && ch1 == *(s2++))
		;
	return ch1 ? ((ch2 = *(s2-1)) == ch1 ? 0 : (ch1 < ch2 ? -1 : 1)) : (*s2 ? -1 : 0);
}
#else
int strcmp (const char *, const char *);
#endif

int strncmp(const char *, const char *, size_t);
char *strchr (const char *, int);
char *strrchr(const char *, int);
size_t strspn (const char *, const char *);
size_t strcspn(const char *, const char *);
char *strpbrk(const char *, const char *);
char *strstr(const char *, const char *);

#ifdef _INLINE_INCLUDES
__inline size_t strlen(const char *s)
{
	const char *t = s;
	while (*(t++))
		;
	return (size_t) (t - s - 1);
}
#else
size_t strlen(const char *);
#endif

char *strerror(int);
char *strtok(char *, const char *);

int stricmp(const char *, const char *);
char *strlwr(char *);
char *strupr(char *);

#ifdef _INLINE_INCLUDES
__inline void *memcpy(void *d, const void *s, size_t n)
{
	void *r = d;
	n++;
	while (--n > 0)
	{
		*(((unsigned char *) d)++) = *(((unsigned char *) s)++);
	};
	return r;
}
#else
void *memcpy(void *, const void *, size_t);
#endif

#ifdef _INLINE_INCLUDES
__inline void *memmove(void *d, const void *s, size_t n)
{
	void *r = d;
	if ((unsigned char *) d > (unsigned char *) s)
	{
		n++;
		while (--n > 0)
		{
			*(((unsigned char *) d)++) = *(((unsigned char *) s)++);
		};
	}
	else
	{
		(unsigned char *) d += n;
		(unsigned char *) s += n;
		n++;
		while (--n > 0)
			*(--((unsigned char *) d)) = *(--((unsigned char *) s));
	};
	return r;
}
#else
void *memmove(void *, const void *, size_t);
#endif

int memcmp(const void *, const void *, size_t);
void *memchr(const void *, int, size_t);

#ifdef _INLINE_INCLUDES
__inline void *memset(void *m, int c, size_t n)
{
	void *r = m;
	n++;
	while (--n > 0)
		*(((unsigned char *) m)++) = (unsigned char) c;
	return r;
}
#else
void *memset(void *, int, size_t);
#endif

#define bzero(a,b) memset(a,0,b)

#ifdef __cplusplus
}
#endif

#endif
