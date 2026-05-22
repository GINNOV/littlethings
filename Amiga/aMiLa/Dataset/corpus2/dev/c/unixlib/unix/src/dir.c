#include "amiga.h"
#include "dir_data.h"
#include <string.h>

/* opendir/readdir/etc ... emulation w/ stat support hack */

static void free_entries(iDIR * info)
{
    struct idirect *scan = info->files;

    while (scan) {
	struct idirect *next = scan->next;

	free(scan);
	scan = next;
    }
}

static int gobble_dir(DIR * dir)
{
    iDIR *info = (iDIR *) dir->dd_buf;
    long ioerr;
    struct idirect **last = &info->files;

    free_entries(info);
    last_info = 0;
    info->files = 0;
    dir->dd_loc = 0;
    while (ExNext(dir->dd_fd, &info->fib)) {
	u_short namlen = strlen(info->fib.fib_FileName);
	u_short reclen = namlen + 1 + offsetof(struct idirect, entry.d_name);
	struct idirect *newentry = malloc(reclen);
	struct direct *entry;

	if (!newentry) {
	    errno = ENOMEM;
	    return 0;
	}
	newentry->next = 0;
	*last = newentry;
	last = &newentry->next;

	newentry->handler = (long)((struct FileLock *)((long)dir->dd_fd << 2))->fl_Task;
	newentry->numblocks = info->fib.fib_NumBlocks;
	newentry->size = info->fib.fib_Size;
	newentry->date = info->fib.fib_Date;
	newentry->type = info->fib.fib_DirEntryType;
	newentry->protection = info->fib.fib_Protection;

	entry = &newentry->entry;
	entry->d_ino = info->fib.fib_DiskKey;
	entry->d_reclen = reclen;
	entry->d_namlen = namlen;
	entry->d_off = dir->dd_loc++;
	strcpy(entry->d_name, info->fib.fib_FileName);
    }
    info->pos = info->files;
    dir->dd_loc = 0;
    ioerr = IoErr();
    if (ioerr == ERROR_NO_MORE_ENTRIES)
	return 1;

    errno = convert_oserr(ioerr);
    return 0;
}

DIR *opendir(const char *dirname)
{
    DIR *new = malloc(sizeof *new);
    iDIR *info = malloc(sizeof *info);
    char *dircopy = malloc(strlen(dirname) + 1);

    __chkabort();
    if (new && dircopy && info) {
	new->dd_buf = (char *) info;
	new->dd_size = sizeof *info;

	info->files = info->pos = 0;
	info->seeked = 0;
	info->dirname = dircopy;
	strcpy(dircopy, dirname);
	info->cdir = _get_cd();

	if ((new->dd_fd = Lock(dirname, ACCESS_READ)) &&
	    Examine(new->dd_fd, &info->fib)) {
	    if (gobble_dir(new))
		return new;
	} else
	    errno = convert_oserr(IoErr());
	closedir(new);
	return 0;
    }
    errno = ENOMEM;
    if (new)
	free(new);
    if (dircopy)
	free(dircopy);
    if (info)
	free(info);

    return 0;
}

void closedir(DIR * dir)
{
    iDIR *info = (iDIR *) dir->dd_buf;

    __chkabort();
    last_info = 0;
    free_entries(info);
    free(info->dirname);
    if (dir->dd_fd)
	UnLock(dir->dd_fd);
    free(dir->dd_buf);
    free(dir);
}

struct direct *readdir(DIR * dir)
{
    iDIR *info = (iDIR *) dir->dd_buf;
    struct direct *entry = 0;

    __chkabort();
    if (info->seeked) {
	long cloc = 0;
	struct idirect *pos;

	pos = info->files;

	while (cloc < dir->dd_loc && pos) {
	    cloc++;
	    pos = pos->next;
	}
	/*if (cloc != dir->dd_loc) error ...
	   This doesn't seem to be defined very precisely */
	info->pos = pos;
	info->seeked = 0;
    }
    if (info->pos) {
	entry = &info->pos->entry;

	last_info = info;
	last_entry = info->pos;

	info->pos = info->pos->next;
	dir->dd_loc++;
    }
    return entry;
}

long telldir(DIR * dir)
{
    __chkabort();
    return dir->dd_loc;
}

void seekdir(DIR * dir, long loc)
{
    iDIR *info = (iDIR *) dir->dd_buf;

    __chkabort();
    info->seeked = 1;
    dir->dd_loc = loc;
}

#if 0
void rewwinddir(DIR * dir)
{
    __chkabort();
    gobble_dir(dir);
}

#endif
