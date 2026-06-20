#include <stdio.h>
int
fwrite( buf, size, nitems, fp)
	char  *buf;
	int   size;
	int   nitems;
	register FILE  *fp;
{
	register long   w, rr, n;

	n = (fp->_flag |= _IORW);
	if (!(n & _IOWRT)			/* not opened for write? */
	|| (n & (_IOERR | _IOEOF)))		/* error/eof conditions? */
		return(EOF);
	if(fp->_base == NULL)	/* allocate a buffer if there wasn't one */
		_getbuf(fp);

	rr = 0;
	n  = nitems * size;
	for (;;) {
		w = fp->_bsiz - fp->_cnt;
		if ( w > n )
			w = n;
		(void)lmemcpy( fp->_ptr, buf, w ); 
		rr += w;
		n -= w;
		buf += w;
		fp->_cnt += w;

		if (n) {
			w = fflush(fp);
			if (w == EOF)
				return w;
			continue;
		}
		break;
	}
	fflush(fp);
	return (rr/size);
}

