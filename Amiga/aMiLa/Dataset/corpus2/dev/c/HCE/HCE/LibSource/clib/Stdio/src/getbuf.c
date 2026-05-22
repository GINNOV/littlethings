#include <stdio.h>
#include <malloc.h>

extern void (*_fcloseall)();
void closeall();

_getbuf(fp)		/* allocate a buffer for a stream */
	register FILE *fp;
	{
	if((fp->_flag & _IONBF)
	|| ((fp->_base = (unsigned char *)malloc(fp->_bsiz = BUFSIZ)) == NULL))
		{
		fp->_flag &= ~(_IOFBF | _IOLBF | _IONBF);
		fp->_flag |= _IONBF;
		fp->_base = &(fp->_ch);			/* use tiny buffer */
		fp->_bsiz = 1;
		}
	else
		fp->_flag |= _IOMYBUF;			/* use big buffer */
	fp->_ptr = fp->_base;
	fp->_cnt = 0;		/* start out with an empty buffer */
	_fcloseall = closeall;
	}

/*
 * The logical place for this is in fopen.c.  However, since both fopen.c
 * and fdopen.c allow for two independent paths to open a second level
 * stream file, the next best choice seems to be in this routine.
 */

static void closeall(){
	register int i, f;

	for(i=0; i<OPEN_MAX; ++i){
		f = _iob[i]._flag;
		if(f & (_IOREAD | _IOWRT))
			fclose(&_iob[i]);
	}
}
