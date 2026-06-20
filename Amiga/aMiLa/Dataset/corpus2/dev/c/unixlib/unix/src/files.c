#include "amiga.h"
#include "files.h"
#include <string.h>

/* Unix low-level IO emulation */
/* --------------------------- */

/* First, fd definition & allocation */

static struct fileinfo **files = NULL;
static int max_files = 0;
#define FILE_STEP 32		/* No of file descriptors to allocate at once */

int _get_free_fd(int *nfd, struct fileinfo ***fpt)
{
    register int fd;
    register int i;
    register struct fileinfo *info;

    for (fd = 0; fd < max_files && files[fd] != NULL; fd++);

    if (fd == max_files) {
	register struct fileinfo **newfiles;
	register struct fileinfo *oldinfo;
	int old_max = max_files;

	/* Increase files array by FILE_STEP */
	max_files += FILE_STEP;
	newfiles = malloc(max_files * (sizeof(struct fileinfo *)
				       + sizeof(struct fileinfo)));
	if (!newfiles) {
	    errno = ENOMEM;
	    return -1;
	}
	info = (struct fileinfo *) &newfiles[max_files];
	if (files) {
	    oldinfo = (struct fileinfo *) &files[old_max];
	    memcpy(info, oldinfo, old_max * sizeof(struct fileinfo));
	}
	for (i = 0; i < max_files; i++) {
	    if (i < old_max)
		newfiles[i] = info + (files[i] - oldinfo);
	    else {
		newfiles[i] = NULL;
		info[i].userinfo = 0;
		info[i].count = 0;
	    }
	}
	if (files)
	    free(files);
	files = newfiles;
    }
    info = (struct fileinfo *) &files[max_files];
    for (i = 0; i < max_files; i++) {
	if (info[i].userinfo == 0) {
	    files[fd] = info + i;
	    break;
	}
    }
    *nfd = fd;
    *fpt = files;
    return 0;
}

int _alloc_fd(void *userinfo, int flags,
	      ULONG(*select_start) (void *userinfo, int rd, int wr, int ex),
	      int (*select_poll) (void *userinfo, int *rd, int *wr, int *ex),
	      int (*read) (void *userinfo, void *buffer, unsigned int length),
	      int (*write) (void *userinfo, void *buffer, unsigned int length),
	      int (*lseek) (void *userinfo, long rpos, int mode),
	      int (*close) (void *userinfo, int internal),
	      int (*ioctl) (void *userinfo, int request, void *data))
{
    struct fileinfo **dummy;
    int fd;

    if (_get_free_fd(&fd, &dummy) < 0)
	return -1;

    files[fd]->userinfo = userinfo;
    files[fd]->flags = flags;
    files[fd]->count = 1;
    files[fd]->select_start = select_start;
    files[fd]->select_poll = select_poll;
    files[fd]->read = read;
    files[fd]->write = write;
    files[fd]->lseek = lseek;
    files[fd]->close = close;
    files[fd]->ioctl = ioctl;

    return fd;
}

void _free_fd(int fd)
{
    if (0 <= fd && fd < max_files && files[fd] != NULL) {
	if (files[fd]->count == 0 || --files[fd]->count == 0)
	    files[fd]->userinfo = 0;
	files[fd] = NULL;
    }
}

struct fileinfo *_find_fd(int fd)
{
    if (0 <= fd && fd < max_files && files[fd] != NULL)
	return files[fd];
    errno = EBADF;
    return 0;
}

int _last_fd(void)
{
    return max_files;
}
