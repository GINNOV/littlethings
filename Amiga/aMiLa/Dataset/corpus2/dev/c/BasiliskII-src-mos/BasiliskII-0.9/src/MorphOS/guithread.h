/*
 *  guithread.h - MorphOS GUI threading
 *
 *  Basilisk II (C) 1997-2001 Christian Bauer
 *                  2005 Ilkka Lehtoranta
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
 *  Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
 */

#ifndef GUITHREAD_MORPHOS_H
#define GUITHREAD_MORPHOS_H

typedef enum
{
	GUICMD_Quit = 0,
	GUICMD_Prefs,
	GUICMD_InitVideo
} GUICMD;

struct GUI_Message
{
	struct Message Message;
	GUICMD			Command;
	LONG				Ok;
};

struct GUI_Info
{
	struct Message	Message;
	LONG				Ok;
};


int SendGUICmd(GUICMD cmd);
int InitGUIThread(void);
void FinishGUIThread(void);

#endif /* GUITHREAD_MORPHOS_H */