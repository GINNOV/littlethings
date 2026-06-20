/////////////////////////////////////////////////////////////
// Flash Plugin and Player
// Copyright (C) 1998 Olivier Debon
// 
// This program is free software; you can redistribute it and/or
// modify it under the terms of the GNU General Public License
// as published by the Free Software Foundation; either version 2
// of the License, or (at your option) any later version.
// 
// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU General Public License for more details.
// 
// You should have received a copy of the GNU General Public License
// along with this program; if not, write to the Free Software
// Foundation, Inc., 59 Temple Place - Suite 330, Boston, MA  02111-1307, USA.
// 
///////////////////////////////////////////////////////////////
//  Author : Olivier Debon  <odebon@club-internet.fr>
//  

#include <stdio.h>
#include <stdlib.h>
#include <sys/time.h>
#include <sys/types.h>
#include <unistd.h>
#include "flash.h"
#include <X11/keysym.h>

static char *rcsid = "$Id: main.c,v 1.9 1998/12/27 23:07:18 olivier Exp $";

/*
 *	This file is the entry of a very simple Flash Player
 */

Display *dpy;
GC gc;
Window frame,movie,control;
struct FlashInfo fi;
char *filename;

readFile(char *filename, char **buffer, long *size)
{
	FILE *in;
	char *buf;
	long length;

	in = fopen(filename,"r");
	if (in == 0) {
		perror(filename);
		exit(2);
	}
	fseek(in,0,SEEK_END);
	length = ftell(in);
	rewind(in);
	buf = malloc(length);
	fread(buf,length,1,in);
	fclose(in);

	*size = length;
	*buffer = buf;
}

void drawInfo()
{
	char msg[1024];

	sprintf(msg,"%s (Flash %d)  - Frames = %d  - Rate = %d fps",
			filename,fi.version,fi.frameCount,fi.frameRate);

	XSetForeground(dpy,gc,WhitePixel(dpy, DefaultScreen(dpy)));
	XDrawString(dpy,control,gc,10,15,msg, strlen(msg));

	sprintf(msg, "  (Q)uit (R)eplay (P)ause (C)ontinue");
	XDrawString(dpy,control,gc,10,35,msg, strlen(msg));
	XFlush(dpy);
}

void playMovie(FlashHandle flashHandle, Display *dpy, Window movie)
{
	struct timeval wd,de,now;
	XEvent event;
	long evMask, cmd;
	fd_set fdset;
	int status;
	long delay = 0;
	long wakeUp = 1;
	long z = 1;
	long x = 0;
	long y = 0;

	cmd = FLASH_WAKEUP;
	wakeUp = FlashExec(flashHandle, cmd, 0, &wd);
	XSelectInput(dpy, movie, FLASH_XEVENT_MASK|KeyPressMask);
	XSync(dpy,False);

	while(1) {
		FD_ZERO(&fdset);
		FD_SET(ConnectionNumber(dpy),&fdset);

		/*printf("WakeUp = %d  Delay = %d\n", wakeUp, delay);*/
		if (delay < 0) {
			delay = 20;
		}

		if (wakeUp) {
			de.tv_sec = delay/1000;
			de.tv_usec = (delay%1000)*1000;
			status = select(ConnectionNumber(dpy)+1, &fdset, 0, 0, &de);
		} else {
			status = select(ConnectionNumber(dpy)+1, &fdset, 0, 0, 0);
		}

		if (status == 0) {
			cmd = FLASH_WAKEUP;
			wakeUp = FlashExec(flashHandle, cmd, 0, &wd);
		}
		if (status) {
			XNextEvent(dpy, &event);
			/* printf("Event %d (%d)\n",event.type,event.xany.serial); */

			if (event.xany.window == movie) {
				int keycode;
				KeySym keysym;

				switch (event.type) {
				case KeyPress:
					keycode = event.xkey.keycode;
					keysym = XLookupKeysym((XKeyEvent*)&event, 0);
					switch (keysym) {
						case XK_Up:
							y -= 10;
							FlashOffset(flashHandle,x,y);
							break;
						case XK_Down:
							y += 10;
							FlashOffset(flashHandle,x,y);
							break;
						case XK_Left:
							x -= 10;
							FlashOffset(flashHandle,x,y);
							break;
						case XK_Right:
							x += 10;
							FlashOffset(flashHandle,x,y);
							break;
						case XK_KP_Add:
							FlashZoom(flashHandle,++z);
							break;
						case XK_KP_Subtract:
							FlashZoom(flashHandle,--z);
							break;
						case XK_q:
							return;
							break;
						case XK_c:
							cmd = FLASH_CONT;
							wakeUp = FlashExec(flashHandle, cmd, 0, &wd);
							break;
						case XK_p:
							cmd = FLASH_STOP;
							wakeUp = FlashExec(flashHandle, cmd, 0, &wd);
							break;
						case XK_r:
							cmd = FLASH_REWIND;
							FlashExec(flashHandle, cmd, 0, &wd);
							cmd = FLASH_CONT;
							wakeUp = FlashExec(flashHandle, cmd, 0, &wd);
							break;
					}
					break;
				case NoExpose:
					break;
				default:
					cmd = FLASH_EVENT;
					if (FlashExec(flashHandle, cmd, &event, &wd))
						wakeUp = 1;
					break;
				}
			}
			if (event.xany.window == control) {
				if (event.type == Expose) {
					drawInfo();
				}
			}
		}

		/* Recompute delay */
		gettimeofday(&now,0);
		delay = (wd.tv_sec-now.tv_sec)*1000 + (wd.tv_usec-now.tv_usec)/1000;
	}
}

void
showUrl(char *url, char *target, void *client_data)
{
	printf("GetURL : %s\n", url);
}

main(int argc, char **argv)
{
	char *buffer;
	long size;
	FlashHandle flashHandle;

	if (argc < 2) {
		fprintf(stderr,"Usage : %s <file.swf>\n", argv[0]);
		exit(1);
	}

	dpy = XOpenDisplay(getenv("DISPLAY"));
	if (dpy == 0) {
		fprintf(stderr,"Can't open X display\n");
		exit(1);
	}
	gc = DefaultGC(dpy, DefaultScreen(dpy));

	filename = argv[1];
	readFile(filename, &buffer, &size);

	flashHandle = FlashParse(buffer, size);

	if (flashHandle == 0) {
		exit(1);
	}

	FlashGetInfo(flashHandle, &fi);

	frame = XCreateSimpleWindow(dpy, RootWindow(dpy, DefaultScreen(dpy)),
				    0, 0,
				    fi.frameWidth/20, fi.frameHeight/20+40,
				    0, WhitePixel(dpy, DefaultScreen(dpy)), BlackPixel(dpy, DefaultScreen(dpy))
				    );

	XMapWindow(dpy, frame);

	movie = XCreateSimpleWindow(dpy, frame, 0, 0, fi.frameWidth/20,fi.frameHeight/20,
				    0, WhitePixel(dpy, DefaultScreen(dpy)), BlackPixel(dpy, DefaultScreen(dpy))
				    );

	XMapWindow(dpy, movie);

	control = XCreateSimpleWindow(dpy, frame, 0, fi.frameHeight/20, fi.frameWidth/20,40,
				    0, BlackPixel(dpy, DefaultScreen(dpy)), BlackPixel(dpy, DefaultScreen(dpy))
				    );

	XMapWindow(dpy, control);
	XSelectInput(dpy, control, ExposureMask);
	drawInfo();

	XFlush(dpy);

	FlashGraphicInit(flashHandle, dpy, movie);

	FlashSoundInit(flashHandle, "/dev/dsp");

	FlashSetGetUrlMethod(flashHandle, showUrl, 0);

	playMovie(flashHandle, dpy, movie);

	exit(0);
}
