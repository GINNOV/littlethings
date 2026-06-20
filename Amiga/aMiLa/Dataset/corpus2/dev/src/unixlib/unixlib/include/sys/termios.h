#ifndef _TERMIOS_H
#define _TERMIOS_H

struct winsize {
  unsigned short ws_row;	/* rows, in characters */
  unsigned short ws_col;	/* columns, in characters */
  unsigned short ws_xpixel;	/* horizontal size, pixels - not used */
  unsigned short ws_ypixel;	/* vertical size, pixels - not used */
};

#define _TERMIO_IOCTL_BASE 1024

#define TIOCGWINSZ (_TERMIO_IOCTL_BASE + 0)

#endif
