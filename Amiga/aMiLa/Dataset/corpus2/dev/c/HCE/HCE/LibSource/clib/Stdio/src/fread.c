#include <clib/stdio.h>

/* December 93. */
/* Modifications and Bug fixes by Jason Petty. Marked with VANSOFT. */

int fread(buf, size, number, fi)
char  *buf;
int   size;
int   number;
register FILE *fi;
{
	long r, rr, m, n;
        unsigned long bytesread = 0L; /* Added VANSOFT. */

	r = (fi->_flag &= ~_IORW);

	if(!(r & _IOREAD) || (r & (_IOERR | _IOEOF)))
		return(EOF);
	if(fi->_base == NULL)	/* allocate a buffer if there wasn't one */
		_getbuf(fi);

	rr = 0;
	n = size * number;

	for (;;) {
                  bytesread += fi->_cnt;  /* Added VANSOFT. */
                  r = fi->_cnt;
		if (r > n)
                    r = n;
		if (r) {
			(void)lmemcpy( buf, fi->_ptr, r );
                     if(bytesread < n)  /* Added VANSOFT. */
	                buf += r;
                        fi->_ptr += r;  /* Added VANSOFT. required else bug!*/
			n -= r;
			rr += r;
			fi->_cnt -= r;
		}

		if (n) {
			m = read(fi->_file, fi->_base, fi->_bsiz);
			if(m <= 0){
				fi->_flag |= ((m == 0) ? _IOEOF : _IOERR);
				if ( m < 0 )
					return EOF;
			}

			fi->_cnt = m;
			fi->_ptr = fi->_base;
			if ( m > 0 )
				continue;
		}
		break;
	}
	return (rr / size );
}
