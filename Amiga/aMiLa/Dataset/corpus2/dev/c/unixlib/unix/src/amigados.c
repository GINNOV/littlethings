#include "amiga.h"
#include "files.h"
#include "signals.h"
#include <exec/memory.h>
#include <fcntl.h>
#include <sys/termios.h>
#include <amiga/ioctl.h>
#include <string.h>

void _fail(char *format,...);

/* Code for fd's describing AmigaDOS files */

struct amigainfo {
    BPTR fh;
    BPTR lock;              /* A lock on the file (may be null) */
    long protection;        /* To be set when file is closed, -1 for none */
    char interactive;       /* True if file was interactive */
    char deleted;           /* True if file has been deleted but not closed */
};

static ULONG file_select_start(void *userinfo, int rd, int wr, int ex)
{
    /* If read or write, input always immediately available, gniark */
    if (rd || wr)
	return (ULONG) - 1;
    return 0;
}

static int file_select_poll(void *userinfo, int *rd, int *wr, int *ex)
{
    /* Input always immediately available, gniark */
    *ex = 0; /* we don't detect 'exceptional' conditions */
    return 0;
}

static int file_read(void *userinfo, void *buffer, unsigned int length)
{
    struct amigainfo *info = userinfo;
    BPTR fh = info->fh;
    LONG cnt;

    if (info->deleted)
	return 0;
    if ((cnt = Read(fh, buffer, length)) == -1)
	ERROR;
    return (int) cnt;
}

static int file_write(void *userinfo, void *buffer, unsigned int length)
{
    struct amigainfo *info = userinfo;
    BPTR fh = info->fh;
    int cnt;

    if (info->deleted)
	return 0;
    if (info->interactive) {
	char *bufend = (char *) buffer + length;

	/* Write by lines, more pleasant for user */
	cnt = 0;
	while (length) {
	    char *end = buffer;
	    long nb;
	    unsigned len;

	    while (end < bufend && *end != '\n')
		end++;

	    if (end == bufend)
		len = end - (char *) buffer;
	    else
		len = end + 1 - (char *) buffer;

	    if ((nb = Write(fh, buffer, len)) == -1)
		ERROR;

	    cnt += nb;
	    if (nb != len)
		break;

	    buffer = end + 1;
	    length -= nb;
	    /* Interrupt write ? */
	    if (_handle_signals(_check_signals(0)))
		break;
	}
    } else if ((cnt = Write(fh, buffer, length)) == -1)
	ERROR;
    return cnt;
}

static int file_lseek(void *userinfo, long rpos, int mode)
{
    struct amigainfo *info = userinfo;
    BPTR fh = info->fh;
    LONG pos, err;

    if (info->deleted)
	return 0;
    pos = Seek(fh, rpos, mode - 1);
    err = IoErr();
    if (pos == -1 || err) {
	errno = convert_oserr(err);
	return -1;
    }
    pos = Seek(fh, 0, OFFSET_CURRENT);
    if (pos == -1 || err) {
	errno = convert_oserr(err);
	return -1;
    }
    return pos;
}

static int file_close(void *userinfo, int internal)
{
    struct amigainfo *info = userinfo;
    BPTR fh = info->fh;
    long protection = info->protection;
    char name[256];
    int ok, deleted;

    if (info->lock)
	UnLock(info->lock);
    deleted = info->deleted;
    free(info);
    if (deleted)
	return 0;

    ok = NameFromFH(fh, name, 256);
    if (internal || Close(fh))
	if (!ok || protection == -1 || SetProtection(name, protection))
	    return 0;
    ERROR;
}

static int isfifo(BPTR fh)
/* Requires: IsInteractive(fh) */
/* Try & find out if fh is a fifo: file */
{
    WaitForChar(fh, 0);
    return (IoErr() == ERROR_ACTION_NOT_KNOWN);
}

static int GetWinBounds(BPTR fh, long *width, long *height)
{
    char buffer[16];
    int ok = 0;

    if (!isfifo(fh) && SetMode(fh, 1)) {
	if ((Write(fh, "\x9b" "0 q", 4) == 4) &&
	    WaitForChar(fh, 10000L) &&
	    (Read(fh, buffer, sizeof(buffer)) > 9) &&
	    (buffer[0] == '\x9b')) {
	    int y = StrToLong(buffer + 5, height);
	    int x = StrToLong(buffer + 5 + y + 1, width);
	    if ((x != -1) && (y != -1))
		ok = 1;
	}
	SetMode(fh, 0);
    }
    return ok;
}

int _do_truncate(BPTR fh, off_t length)
{
    int err, ret = -1;
    long oldsize, oldpos;

    oldpos = Seek(fh, 0, OFFSET_END);
    oldsize = Seek(fh, 0, OFFSET_END);

    if (!(err = IoErr()) &&
	SetFileSize(fh, length, OFFSET_BEGINNING) == length) {
	if (oldsize < length) {
	    /* Zero extra bytes */
	    off_t bufsize = length - oldsize, left = bufsize;
	    char *buf;
	    char reserve[512];

	    if (!(buf = AllocMem(bufsize, MEMF_CLEAR))) {
		bufsize = AvailMem(MEMF_LARGEST) / 2;

		if (bufsize < 512 || !(buf = AllocMem(bufsize, MEMF_CLEAR))) {
		    bufsize = 512;
		    buf = reserve;
		    memset(reserve, 0, 512);
		}
	    }
	    while (left > 0) {
		long count = left > bufsize ? bufsize : left;

		__chkabort();
		if (Write(fh, buf, count) != count) {
		    err = IoErr();
		    break;
		}
		left -= count;
	    }
	    if (buf != reserve)
		FreeMem(buf, bufsize);
	}
	if (!err)
	    ret = 0;
    }
    if (oldpos < length)
	Seek(fh, oldpos, OFFSET_BEGINNING);

    if (ret)
	errno = convert_oserr(err);
    return ret;
}

static int file_ioctl(void *userinfo, int request, void *data)
{
    struct amigainfo *info = userinfo;
    BPTR fh = info->fh;

    if (!info->deleted) {
	switch (request) {
	    case TIOCGWINSZ: {
		struct winsize *ws = data;
		long col, row;

		if (info->interactive && GetWinBounds(fh, &col, &row)) {
		    ws->ws_col = col;
		    ws->ws_row = row;
		    return 0;
		}
		errno = ENOTTY;
		return -1;
	    }
	    case _AMIGA_INTERACTIVE: {
		int *inter = data;

		*inter = IsInteractive(fh);
		return 0;
	    }
	    case _AMIGA_GET_FH: {
		BPTR *gotfh = data;

		*gotfh = fh;
		return 0;
	    }
	    case _AMIGA_FREE_FH:
		return 0;
	    case _AMIGA_TRUNCATE: {
		off_t length = *(off_t *) data;

		return _do_truncate(fh, length);
	    }
	    case _AMIGA_SETPROTECTION:
		info->protection = *(long *) data;
		return 0;
	    case _AMIGA_DELETE_IF_ME: {
		BPTR nlock = *(BPTR *) data;

		if (!info->lock)
		    info->lock = DupLockFromFH(info->fh);
		if (info->lock && SameLock(nlock,info->lock) == LOCK_SAME) {
		    char name[256];

		    if (NameFromFH(fh, name, 256)) {
			UnLock(nlock);
			UnLock(info->lock);
			Close(fh);
			SetProtection(name, 0);
			info->deleted = TRUE;
			info->lock = info->fh = 0;
			if (DeleteFile(name))
			    return 0;
		    }
		}
		ERROR;
	    }
	    case _AMIGA_IS_FIFO: {
	        int *is_fifo = data;

		*is_fifo = FALSE;
		return 0;
	    }
	    case _AMIGA_IS_SOCK: {
	        int *is_sock = data;

		*is_sock = FALSE;
		return 0;
	    }
	}
    }
    errno = EINVAL;
    return -1;
}

int _alloc_amigafd(BPTR fh, long protection, long flags)
{
    struct amigainfo *new = malloc(sizeof(struct amigainfo));
    int fd;

    if (!new) {
	errno = ENOMEM;
	return -1;
    }
    new->fh = fh;
    new->lock = NULL;
    new->protection = protection;
    new->deleted = FALSE;
    new->interactive = IsInteractive(fh);

    fd = _alloc_fd(new, flags,
		   file_select_start, file_select_poll, file_read, file_write,
		   file_lseek, file_close, file_ioctl);
    if (fd < 0)
	free(new);

    return fd;
}

void _init_unixio(BPTR in, int close_in, BPTR out, int close_out,
		  BPTR err, int close_err)
{
    if (_alloc_amigafd(in,  -1, FI_READ  | (close_in  ? 0 : O_NO_CLOSE)) == 0 &&
	_alloc_amigafd(out, -1, FI_WRITE | (close_out ? 0 : O_NO_CLOSE)) == 1 &&
	_alloc_amigafd(err, -1, FI_WRITE | (close_err ? 0 : O_NO_CLOSE)) == 2)
	return;

    _fail("Failed to initialise I/O");
}
