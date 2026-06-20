/*
 * Amiga specific support code for cxref
 *
 * Written by Olaf Barthel <olsen@sourcery.han.de>
 *     Public Domain
 *
 * :ts=4
 */

#if defined(__SASC) && defined (AMIGA)

/******************************************************************************/

#define CXREF_CPP "cxref-cpp -C -dD -dI"

/******************************************************************************/

#define fopen(name,mode) amiga_fopen(name,mode)
#define stat(name,statstruct) amiga_stat(name,statstruct)
#define lstat(name,statstruct) amiga_lstat(name,statstruct)
#define mkdir(name,mode) amiga_mkdir(name)
#define rename(old,new) amiga_rename(old,new)
#define unlink(name) amiga_unlink(name)

extern FILE *amiga_fopen(char *name,const char *mode);
extern int amiga_stat(char *, struct stat *);
extern int amiga_lstat(char *, struct stat *);
extern int amiga_mkdir(char *);
extern int amiga_rename(char *,char *);
extern int amiga_unlink(char *);

/******************************************************************************/

extern FILE * popen_execvp(char** command);
extern int pclose_execvp(FILE* f);

/******************************************************************************/

extern int expand_args(int argc,char **argv,
                       int *_argc,char ***_argv,
                       int all,int sort);

/******************************************************************************/

extern void * alloca (unsigned int size);

/******************************************************************************/

#endif /* defined(__SASC) && defined (AMIGA) */
