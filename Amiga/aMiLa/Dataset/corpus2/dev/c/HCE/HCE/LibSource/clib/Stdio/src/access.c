/*
 * access.c: Check file accessibility.
 *	     15May89 - Created by Jeff Lydiatt.
 * mode:
 *	0: exists?
 *	1:  __E
 *	2:  _W_
 *	3:  _WE
 *	4:  R__
 *	5:  R_E
 *	6:  RW_
 *	7:  RWE
 */
#include <errno.h>
#include <libraries/dos.h>

   int
access(filename, mode)
char *filename;
int mode;
{
	long	Lock();
	void	UnLock();
	long	lock, testmode;

	if ( (lock = Lock(filename, ACCESS_READ)) == 0 ){
		errno = ENOENT;
		return -1;
	}

	switch(mode){
		case 2: /* _W_ */
		case 3: /* _WE */
		case 6: /* RW_ */
		case 7: /* RWE */
			UnLock(lock);
			testmode = ACCESS_WRITE; 
			break;
			if ( (lock = Lock(filename, ACCESS_WRITE)) == 0 ){
				errno = EACCES;
				return -1;
			}
	}

	UnLock(lock);
	return	0;
}
