#include "amiga.h"
#include "files.h"
#include "amigados.h"
#include <fcntl.h>
#include <string.h>

#undef ERROR
#define ERROR do { _seterr(); return(NULL); } while(0)

FILE *popen(const char *path, const char *mode)
{
    int fd;
    BPTR fh;
    long fdflags, fhflags;
    char *apipe = malloc(strlen(path)+7);

    __chkabort();

    if (!apipe) {
	errno = ENOMEM;
	return(NULL);
    }

    strcpy(apipe, "APIPE:");
    strcat(apipe, path);

    if (*mode == 'w') {
	fdflags = FI_WRITE;
	fhflags = MODE_NEWFILE;
    } else {
	fdflags = FI_READ;
	fhflags = MODE_OLDFILE;
    }

    if (!(fh = Open(apipe, fhflags)))
	ERROR;

    fd = _alloc_amigafd(fh, -1, fdflags);
    if (fd < 0) {
	Close(fh);
	return(NULL);
    }
    return(fdopen(fd, mode));
}

int pclose(FILE *stream)
{
    return(fclose(stream));
}

