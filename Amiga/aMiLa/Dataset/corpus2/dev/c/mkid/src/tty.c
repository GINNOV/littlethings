#ifdef TERMIO
#include	<sys/termio.h>
struct termio linemode, charmode, savemode;

void
savetty()
{
	ioctl(0, TCGETA, &savemode);
	charmode = linemode = savemode;

	charmode.c_lflag &= ~(ECHO|ICANON|ISIG);
	charmode.c_cc[VMIN] = 1;
	charmode.c_cc[VTIME] = 0;

	linemode.c_lflag |= (ECHO|ICANON|ISIG);
	linemode.c_cc[VEOF] = 'd'&037;
	linemode.c_cc[VEOL] = 0377;
}

void
restoretty()
{
	ioctl(0, TCSETA, &savemode);
}

void
linetty()
{
	ioctl(0, TCSETA, &linemode);
}

void
chartty()
{
	ioctl(0, TCSETA, &charmode);
}

#else
#ifdef LATTICE
/* send raw mode packet for raw mode - LATTICE is defined in dos.h */
/* see raw.c by cmcmanis */

#include <stdio.h>
#include <stdlib.h>

extern long raw(FILE *),cooked(FILE *);

static char savestate,state = 0,exitready = 0;

static void
cleanupfunc(void)
{
	if(state)
	{
		cooked(stdin);

		state = 0;
	}
}

void
restoretty(void)
{
	if (state != savestate)
	{
		if (savestate)
		{
			if(!exitready)
			{
				exitready = 1;

				atexit(cleanupfunc);
			}

			raw(stdin);
		}
		else
			cooked(stdin);
	}
}

void
savetty(void)
{
	savestate = state;
}

void
chartty(void)
{
	if(!raw(stdin))
	{
		state = 1;

		if(!exitready)
		{
			exitready = 1;

			atexit(cleanupfunc);
		}
	}
}

void
linetty(void)
{
	if(!cooked(stdin))
		state = 0;
}
/* aztec has sgtty */
#else

#include	<sgtty.h>

struct sgttyb linemode, charmode, savemode;

void
savetty()
{
#ifdef TIOCGETP
	ioctl(0, TIOCGETP, &savemode);
#else
	gtty(0, &savemode);
#endif
	charmode = linemode = savemode;

	charmode.sg_flags &= ~ECHO;
	charmode.sg_flags |= RAW;

	linemode.sg_flags |= ECHO;
	linemode.sg_flags &= ~RAW;
}

void
restoretty()
{
#ifdef TIOCSETP
	ioctl(0, TIOCSETP, &savemode);
#else
	stty(0, &savemode);
#endif
}

void
linetty()
{
#ifdef TIOCSETP
	ioctl(0, TIOCSETP, &linemode);
#else
	stty(0, &savemode);
#endif
}

void
chartty()
{
#ifdef TIOCSETP
	ioctl(0, TIOCSETP, &charmode);
#else
	stty(0, &savemode);
#endif
}
#endif /* LATTICE */
#endif
