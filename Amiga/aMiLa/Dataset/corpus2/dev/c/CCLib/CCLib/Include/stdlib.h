#ifndef STDLIB_H
#define STDLIB_H 1


#define EXIT_SUCCESS 0L
#define EXIT_FAILURE 20L

#ifndef __SIZE_T
#define __SIZE_T 1
typedef unsigned long size_t;
#endif

#ifdef ANSIC

double atof(char *);
long atoi(char *);
long atol(char *);

void *malloc(unsigned long);
void *calloc(unsigned long, unsigned long);
void *realloc(void *,unsigned long);
void free(void *);

void exit(long);
extern void (*exit_fcn)(void);
void qsort(void *,unsigned long,unsigned long,long (*)(void *,void *));
long setenv(char *name, char *value);
char *getenv(char *name);
#else

double atof();
short atoi();
long atol();
void *malloc();
void *calloc();
void *realloc();
void free();
void exit();
extern void (*exit_fcn)();
void qsort();
long setenv();
char *getenv();

#endif

#define abs(X) (((X) < 0) ? -(X) : (X))
#define lbs(X) (((X) < 0) ? -(X) : (X))
#define atexit(FUNC) (exit_fcn = (FUNC))
#define system(COMMAND) (Execute(COMMAND,0L,0L))
#define abort() (exit(EXIT_FAILURE))

/*------------------------ TBD -----------------------------------
 *
 * double strtod(char *, char **);
 * long strtol(char *, char **, int);
 * unsigned long strtoul(char *,char **,int);
 * int rand();
 * void srand();
 * void *bsearch(void *,void *,long,long, int (*)(void *, void *);
 * div_t div(int,int);
 * ldiv_t ldiv(long, long);
 *-----------------------------------------------------------------*/

#endif

