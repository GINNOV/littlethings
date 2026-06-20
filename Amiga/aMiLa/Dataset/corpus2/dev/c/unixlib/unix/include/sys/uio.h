#ifndef _SYS_UIO_H
#define _SYS_UIO_H
/*
 *      The struct iovec is normally found
 *      in Berkeley systems in <sys/uio.h>.
 *      See the readv(2) and writev(2)
 *      manual pages for details.
 */

#include <sys/types.h>

struct iovec {
    caddr_t iov_base;
    int iov_len;
};

#endif
