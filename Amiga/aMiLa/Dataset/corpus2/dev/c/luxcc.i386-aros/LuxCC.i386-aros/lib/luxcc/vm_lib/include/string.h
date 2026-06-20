#ifndef _STRING_H
#define _STRING_H

#include <stddef.h> /* for size_t, NULL */

/* Copying functions */
void *memcpy(void *s1, const void *s2, size_t n);
void *memmove(void *s1, const void *s2, size_t n);
char *strcpy(char *s1, const char *s2);
char *strncpy(char *s1, const char *s2, size_t n);

/* Concatenation functions */
char *strcat(char *s1, const char *s2);
char *strncat(char *s1, const char *s2, size_t n);

/* Comparison functions */
int memcmp(const void *s1, const void *s2, size_t n);
int strcmp(const char *s1, const char *s2);
int strncmp(const char *s1, const char *s2, size_t n);

/* Search functions */
void *memchr(const void *s, int c, size_t n);
char *strchr(const char *s, int c);
char *strpbrk(const char *s1, const char *s2);
char *strrchr(const char *s, int c);
size_t strspn(const char *s1, const char *s2);
char *strstr(const char *s1, const char *s2);
char *strtok(char *s1, const char *s2);

/* Miscellaneous functions */
void *memset(void *s, int c, size_t n);
size_t strlen(const char *s);

/* POSIX */
char *strdup(const char *s);
size_t strnlen(const char *s, size_t maxlen);

#endif
