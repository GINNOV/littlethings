#ifndef _AMIGA_H
#define _AMIGA_H

/* Amiga specific ioctl's */

#define _AMIGA_IOCTL_BASE 2048

#define _AMIGA_INTERACTIVE (_AMIGA_IOCTL_BASE + 0) /* Is file Interactive ? */
#define _AMIGA_GET_FH (_AMIGA_IOCTL_BASE + 1) /* Get an AmigaDOS fh for file */
#define _AMIGA_FREE_FH (_AMIGA_IOCTL_BASE + 2) /* Free a fh obtained by GET_FH */
#define _AMIGA_TRUNCATE (_AMIGA_IOCTL_BASE + 3) /* Truncate file to given size */
#define _AMIGA_SETPROTECTION (_AMIGA_IOCTL_BASE + 4) /* Set (amiga) protection on file */
#define _AMIGA_DELETE_IF_ME (_AMIGA_IOCTL_BASE + 5) /* Delete myself if I am the file whose lock is passed as parameter */

#endif
