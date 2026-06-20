#include <stdio.h>

int fgetc(fp)
	register FILE *fp;
	{
	register int c, f, m;

	f = (fp->_flag &= ~_IORW);
	if(!(f & _IOREAD) || (f & (_IOERR | _IOEOF)))
		return(EOF);
	if(fp->_base == NULL)	/* allocate a buffer if there wasn't one */
		_getbuf(fp);
_fgetc1:
	if(--(fp->_cnt) < 0)
		{
		m = read(fp->_file, fp->_base, fp->_bsiz);
		if(m <= 0)
			{
			fp->_flag |= ((m == 0) ? _IOEOF : _IOERR);
			c = EOF;
			goto _fgetc2;
			}
		fp->_cnt = (m - 1);
		fp->_ptr = fp->_base;
		}
	c = *(fp->_ptr)++;
_fgetc2:
	return(c);
	}

int fungetc(c, fp)
	char c;
	register FILE *fp;
	{
	if((fp->_flag & (_IOERR | _IOEOF))	/* error or eof */
	|| (fp->_ptr <= fp->_base))		/* or too many ungets */
		return(EOF);
	++(fp->_cnt);
	return(*--(fp->_ptr) = c);
	}
