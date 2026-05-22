
#include "amiga.h"
#include "files.h"

int __close(int fd);

static int do_dup(int oldd, int newd)
{
    int retd;
    struct fileinfo *fi;
    struct fileinfo **fdtab;

    if (_get_free_fd(&retd, &fdtab) < 0)
	return -1;

    if (newd < 0) {
	newd = retd;		/* it's a dup(), use retd as newd */
	retd = -1;
    } else {			/* it's a dup2(), we don't need a new fd */
	fdtab[retd] = NULL;	/* but only fdtab, so free the slot      */
    }

    if (!(fi = _find_fd(oldd)) || newd >= _last_fd()) {
	errno = EBADF;
	return -1;
    }
    if (retd >= 0) {		/* it's a dup2() */
	if (oldd == newd)
	    return (newd);	/* ignore the call: dup2(x, x) */
	__close(newd);		/* cannot fail */
    }
    fdtab[newd] = fi;
    fi->count++;
    return (newd);
}

int dup(int oldd)
{
    return (do_dup(oldd, -1));
}

int dup2(int oldd, int newd)
{
    if (newd < 0) {
	errno = EBADF;
	return -1;
    }
    return (do_dup(oldd, newd));
}
