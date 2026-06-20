/*
 *
 * STDLIB_H.
 *
 * 1993.
 * Added by Jason Petty.
 * misc.lib prototypes.  
 * exit() defines.
 */

#ifndef STDLIB_H
#define STDLIB_H 1

#define EXIT_SUCCESS 0         /* Succes return value for exit(). */
#define EXIT_WARN    5         /* Warning only.                   */
#define EXIT_ERROR   10        /* Somethings wrong.               */
#define EXIT_FAILURE 20        /* Total or Partial failure.       */

extern void exit(), srand(), _cli_parse(), free();
extern void freall(), GetCurrentPath();

extern int catch();
extern int chdir();
extern int toupper();
extern int tolower();
extern int getopt();
extern int mkdir();
extern int rand();
extern int Err();

extern long _main();
extern long Chk_Abort();
extern long msize();
extern long julian_date();

extern char *getwd();
extern char *lfind();
extern char *lsearch();
extern char *lalloc();
extern char *malloc();
extern char *calloc();
extern char *_malloc();

#endif
