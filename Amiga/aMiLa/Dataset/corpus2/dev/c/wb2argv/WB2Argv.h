/*
 *  WB2Argv v1.2, Amiga Workbench argv/argc emulation routines.
 *  Copyright (C) 1995-96 Jens T. Berger Thielemann
 *
 *  This program is free software; you can redistribute it and/or modify
 *  it under the terms of the GNU General Public License as published by
 *  the Free Software Foundation; either version 2 of the License, or
 *  (at your option) any later version.
 *
 *  This program is distributed in the hope that it will be useful,
 *  but WITHOUT ANY WARRANTY; without even the implied warranty of
 *  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 *  GNU General Public License for more details.
 *
 *  You should have received a copy of the GNU General Public License
 *  along with this program; if not, write to the Free Software
 *  Foundation, Inc., 675 Mass Ave, Cambridge, MA 02139, USA.
 *
 *  Contact the author at:
 *		Jens Berger
 *		Spektrumvn. 4
 *		N-0666 Oslo
 *		Norway
 *		E-mail: <jensthi@ifi.uio.no>
 *
 *
 */

/*
 * These bits are intended for the WB2Argv Flags arg.
 *
 */

/* Make all options lower case. */
#define	W2A_LOWER			0

/* Make all options upper case. */
#define	W2A_UPPER			1

/* Keep case of all options. */
#define	W2A_KEEPCASE		2

#define W2A_CASEMASK		3



char **WB2Argv(struct WBStartup *WBMsg, LONGBITS Flags);
ULONG CountArgv(const char **argv);

