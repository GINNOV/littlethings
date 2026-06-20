#include <libraries/dos.h>
#include <stdio.h>
#include <fcntl.h>
#include <errno.h>

extern struct _device *_devtab[];
extern void (*_closeall)();
void closeall(); /* foreward reference */

int open(filename, iomode, pmode)
register char *filename;
register int iomode, pmode;
{

	register struct _device *p;
	register int rv, h;
	register long dosrv;
	long Open(), DeleteFile(), IoErr();
	long mode;

	Chk_Abort();

	/*
	 * Find the first empty entry in the device table.
	 */

	p = &((*_devtab)[0]);
	for ( h=0; h<OPEN_MAX; h++ ) {
		if ( !p[h].fileHandle )
			break;
	}

	if ( h >= OPEN_MAX )
		return (errno = EMFILE);

	if(!access(filename, 0x00)){		/* file exists */
		if((iomode & (O_CREAT | O_EXCL)) == (O_CREAT | O_EXCL))
			return(errno = EEXIST);

		if ( !(iomode & O_TRUNC) )
			mode = MODE_OLDFILE;
		else{
			if ( !DeleteFile( filename ) )
				goto dos_err;
			mode = MODE_NEWFILE;
		}

		dosrv = Open(filename, mode);
		if ( dosrv == 0 )
			goto dos_err;
	} else {				/* file doesn't exist */
		if(iomode & O_CREAT){
			dosrv = Open(filename, MODE_NEWFILE);
			if ( dosrv == 0 )
				goto dos_err;
		}
		else
			return (errno = ENOENT);
		}

	p = &((*_devtab)[h]);
	p->fileHandle = dosrv;
	p->mode = iomode;

	if( iomode & O_APPEND )
		lseek(h, 0L, SEEK_END);

	_closeall = closeall;
	return(h);

dos_err:
	errno = IoErr();
	return -1;

}

int close(handle)
unsigned int handle;
{
	void Close();
	register struct _device *p;

	if ( handle >= OPEN_MAX )
		return ( errno = EBADF ); 
	p = &((*_devtab)[handle]);
	if ( !(p->mode & O_STDIO) && p->fileHandle != 0 ) {
		Close( p->fileHandle );
		p->fileHandle = 0;
		p->mode = 0;
	}

	return 0;
}

static void closeall()
{
	int fd;

	for (fd = 0 ; fd < OPEN_MAX ; ++fd)
		close( fd );
	free( *_devtab );

}
