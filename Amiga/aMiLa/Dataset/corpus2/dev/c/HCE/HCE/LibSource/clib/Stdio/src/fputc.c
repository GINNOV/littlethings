#include <stdio.h>

int fputc(c, fp)
	register unsigned char c;
	register FILE *fp;
	{
	register int f, m, mustflush, rv;

	f = (fp->_flag |= _IORW);
	if(!(f & _IOWRT)			/* not opened for write? */
	|| (f & (_IOERR | _IOEOF)))		/* error/eof conditions? */
		return(EOF);
	if(fp->_base == NULL)	/* allocate a buffer if there wasn't one */
		_getbuf(fp);
_fputc:
	*(fp->_ptr)++ = c;
	mustflush = (fp->_flag & _IODEV) && (c == '\n');
	if((++(fp->_cnt)) >= fp->_bsiz || mustflush)
		{
		fp->_ptr = fp->_base;
		m = fp->_cnt;
		if((rv = write(fp->_file, fp->_base, m)) != m)
			{
			fp->_flag |= _IOERR;
			return(EOF);
			}
		fp->_cnt = 0;
		}
	return(c);
	}
