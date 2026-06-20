#ifndef _STDLIB_H
#define _STDLIB_H

#include <stddef.h> /* for size_t, wchar_t, NULL */

#define	EXIT_FAILURE	1	/* Failing exit status.  */
#define	EXIT_SUCCESS	0	/* Successful exit status.  */

/* Numeric conversion functions */
int atoi(const char *nptr);
long int strtol(const char *nptr, char **endptr, int base);
long long int strtoll(const char *nptr, char **endptr, int base);
unsigned long int strtoul(const char *nptr, char **endptr, int base);
unsigned long long int strtoull(const char *nptr, char **endptr, int base);

/* Memory management functions */
void *calloc(size_t nmemb, size_t size);
void free(void *ptr);
void *malloc(size_t size);
void *realloc(void *ptr, size_t size);

/* Communication with the environment */
void exit(int status);
char *getenv(const char *name);
int system(const char *command);

/* Searching and sorting utilities */
void *bsearch(const void *key, const void *base, size_t nmemb, size_t size, int (*compar)(const void *, const void *));
void qsort(void *base, size_t nmemb, size_t size, int (*compar)(const void *, const void *));

/* POSIX */
long int random(void);
void srandom(unsigned int seed);

#endif
