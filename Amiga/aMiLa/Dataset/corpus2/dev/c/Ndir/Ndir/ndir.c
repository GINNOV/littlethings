/*
 * ndir - routines to simulate the 4BSD new directory code for AmigaDOS.
 */
#include <dir.h>

DIR *
opendir(dirname) char *dirname; {
	register DIR	*my_dir, *AllocMem(int, int) ;
	struct FileLock	*Lock(char *, int), *CurrentDir(struct FileLock *) ;

	if ((my_dir = AllocMem(sizeof(DIR), 0)) == NULL) return NULL ;


	if (((my_dir -> d_lock = Lock(dirname, ACCESS_READ)) == NULL)
	/* If we can't examine it */
	||  !Examine(my_dir -> d_lock, &(my_dir -> d_info))
	/* Or it's not a directory */
	||  (my_dir -> d_info . fib_DirEntryType < 0)) {
		FreeMem(my_dir, sizeof(DIR)) ;
		return NULL ;
		}
	return my_dir ;
	}

struct direct *
readdir(my_dir) DIR *my_dir; {
	static struct direct	result ;

	if (!ExNext(my_dir -> d_lock, &(my_dir -> d_info))) return NULL ;

	result . d_reclen = result . d_ino = 1 ;	/* Not NULL! */
	(void) strcpy(result . d_name, my_dir -> d_info . fib_FileName) ;
	result . d_namlen = strlen(result . d_name) ;
	return &result ;
	}

void
closedir(my_dir) DIR *my_dir; {

	UnLock(my_dir -> d_lock) ;
	FreeMem(my_dir, sizeof(DIR)) ;
	}
/*
 * telldir and seekdir don't work quite right. The problem is that you have
 * to save more than a long's worth of stuff to indicate position, and it's
 * socially unacceptable to alloc stuff that you don't free later under
 * AmigaDOS. So we fake it - you get one level of seek, and dat's all.
 * As of now, these things are untested.
 */
#define DIR_SEEK_RETURN		((long) 1)	/* Not 0! */
long
telldir(my_dir) DIR *my_dir; {

	my_dir -> d_seek = my_dir -> d_info ;
	return (long) DIR_SEEK_RETURN ;
	}

void
seekdir(my_dir, where) DIR *my_dir; long where; {

	if (where == DIR_SEEK_RETURN)
		my_dir -> d_info = my_dir -> d_seek ;
	else	/* Makes the next readdir fail */
		setmem((char *) my_dir, sizeof(DIR), 0) ;
	}

void
rewinddir(my_dir) DIR *my_dir; {

	if (!Examine(my_dir -> d_lock, &(my_dir -> d_info)))
		setmem((char *) my_dir, sizeof(DIR), 0) ;
	}
#ifdef	TEST
/*
 * Simple code to list the files in the argument directory,
 *	lifted straight from the man page.
 */
#include <stdio.h>
void
main(argc, argv) int argc; char **argv; {
	register DIR		*dirp ;
	register struct direct	*dp ;
	register char		*name ;

	if (argc < 2) name = "" ;
	else name = argv[1] ;

	if ((dirp = opendir(name)) == NULL) {
		fprintf(stderr, "Bogus! Can't opendir %s\n", name) ;
		exit(1) ;
		}

	for (dp = readdir(dirp); dp != NULL; dp = readdir(dirp))
		printf("%s ", dp -> d_name) ;
	closedir(dirp);
	putchar('\n') ;
	}
#endif	TEST

