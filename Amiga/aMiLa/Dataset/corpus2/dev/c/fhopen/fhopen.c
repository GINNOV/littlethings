/* fhopen/fhclose - build file pointer from file handle (DICE)
 *
 * Copyright (C) 1993,1994 by Ingo Wilken (Ingo.Wilken@informatik.uni-oldenburg.de)
 *
 * Permission to use, copy, modify, and distribute this software and its
 * documentation for any purpose and without fee is hereby granted, provided
 * that the above copyright notice appear in all copies and that both that
 * copyright notice and this permission notice appear in supporting
 * documentation.  This software is provided "as is" without express or
 * implied warranty.
 *
 *  $VER: fhopen.c 2.0 (8.12.94)
 */
#include <exec/libraries.h>
#include <dos/dos.h>
#include <proto/dos.h>

#include <stdio.h>
#include <string.h>
#include <fcntl.h>
#include <lib/misc.h>


/* fhopen -
 * build stdio file pointer for an open AmigaDOS file handle
 */
FILE *
fhopen(fh, modes)
    BPTR fh;
    const char *modes;
{
    int fd;
    _IOFDS *d = _MakeFD(&fd);

    if( d ) {
        char *p;
        short fdmode = O_ISOPEN;

        for( p = modes; *p; p++ ) {
            switch( *p ) {
                case 'r':
                    fdmode |= O_RDONLY;
                    break;
                case 'w':
                    fdmode |= O_WRONLY; /* | O_CREAT | O_TRUNC */
                    break;
                case '+':
                    fdmode |= O_RDWR;
                    fdmode &= ~(O_RDONLY|O_WRONLY);
                    break;
                case 'b':
                    fdmode |= O_BINARY;
                    break;
                case 'a':
                    fdmode |= O_APPEND; /* | O_CREAT */
                    break;
            }
        }

        d->fd_Fh = fh;
        d->fd_FileName = NULL;
        d->fd_Flags |= fdmode;

        if( strlen(modes) < 14 ) {
            FILE *fp;
            char buf[16];

            buf[0] = 'F';
            strcpy(buf + 1, modes);
            if( fp = fopen((char *)fd, buf) ) {
                if( fp->sd_Flags & __SIF_APPEND )
                    Seek(fh, 0L, OFFSET_END);
            }
            return fp;
        }
    }
    return (FILE *)NULL;
}


/* fhclose -
 * close file pointer from fhopen() without Close()ing file handle
 */
int
fhclose(fp)
    FILE *fp;
{
    int err = EOF;
    _IOFDS *d;

    if( fp && (d = __getfh(fp->sd_Fd)) ) {
        d->fd_Flags |= O_NOCLOSE;
        err = fclose(fp);
    }
    return err;
}

