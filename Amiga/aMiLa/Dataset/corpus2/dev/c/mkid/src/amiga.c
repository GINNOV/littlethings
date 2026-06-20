/* amiga.c
 * support routines for mkid to make Lattice (and probably Aztec) work
 * properly on the amiga
 *
 * Written by Randell Jesup, Commodore-Amiga Inc (before I came here).
 * This routine is public domain.
 */

#ifdef fseek	/* so I can #define fseek unixfseek */
#undef fseek
#define fseek fseek
#endif

#include <stdio.h>

/* fseek() on the amiga stops at end of file, instead of extending it */

int
unixfseek (FILE *fp,long rpos,int mode)
{
	long oldpos = 0,newpos,endpos;

	if (mode == 1 && (oldpos = ftell(fp)) == -1L)
		return -1;

	if (fseek(fp,rpos,mode) == 0)
		return 0;	/* fseek succeeded - returns -1 if past end */

	if ((newpos = ftell(fp)) == -1L)
		return 0;	/* this is wierd, but fseek didn't error */

	switch (mode) {
	case 2:	/* no extension possible */
		return 0;
	case 1:
	case 0:
		if (newpos == oldpos + rpos)	/* if mode = 0, oldpos = 0 */
			return 0;
		break;	/* may need to extend */
	default:
		return -1;
	}

	/* since we got here, we didn't get where we thought */
	/* see if file needs extending */
	if (mode == 1 && rpos <= 0)	/* if negative seek, ignore */
		return 0;		/* might be seek to < 0     */

	if (fseek(fp,0L,2) == -1)	/* to end of file */
		return -1;

	if ((endpos = ftell(fp)) == -1L)
		return -1;

	if (endpos >= oldpos + rpos)	/* if mode = 0, oldpos = 0 */
		return 0;

	/* EXTEND! (albeit slowly - I don't care enough) */
	do {
		(void) putc('\0',fp);
/*		fseek(fp,0L,2);
 *		endpos = ftell(fp);
 */
	} while (++endpos < oldpos + rpos);	/* if ftell above, no ++ */

        return fseek(fp,rpos,mode);
}
