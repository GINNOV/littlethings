/////////////////////////////////////////////////////////////
// Flash Plugin and Player
// Copyright (C) 1998,1999 Olivier Debon
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

#include "script.h"
#include "graphic.h"
#include "flash.h"
#include "sound.h"

static char *rcsid = "$Id: flash.cc,v 1.19 1999/01/31 20:18:39 olivier Exp $";

struct PrvFlashHandle {
	CInputScript * pInputScript;
	long msPerFrame;
	GraphicDevice *gd;
	SoundMixer    *sm;

	PrvFlashHandle() {
		pInputScript = new CInputScript;
		gd = 0;
		sm = 0;
	};

	~PrvFlashHandle() {
		delete pInputScript;
		delete gd;
		delete sm;
	};
};

// Interface with standard C
extern "C" {

FlashHandle
FlashParse(char *data, long size)
{
	PrvFlashHandle *fh;

	fh = new PrvFlashHandle;

	if (fh->pInputScript->ParseData(data, size)) {
		fh->msPerFrame = 1000/fh->pInputScript->frameRate;
		fh->pInputScript->program->rewindMovie();

		return (FlashHandle)fh;
	}

	delete fh;

	return 0;
}

void
FlashGetInfo(FlashHandle flashHandle, struct FlashInfo *fi)
{
	PrvFlashHandle *fh;

	fh = (PrvFlashHandle *)flashHandle;

	fi->version = fh->pInputScript->m_fileVersion;
	fi->frameRate = fh->pInputScript->frameRate;
	fi->frameCount = fh->pInputScript->frameCount;
	fi->frameWidth = fh->pInputScript->frameRect.xmax - fh->pInputScript->frameRect.xmin;
	fi->frameHeight = fh->pInputScript->frameRect.ymax - fh->pInputScript->frameRect.ymin;
}

long
FlashGraphicInit(FlashHandle flashHandle,Display *dpy, Window target)
{
	PrvFlashHandle *fh;

	fh = (PrvFlashHandle *)flashHandle;

	fh->gd = new GraphicDevice(dpy, target);

	fh->gd->setMovieDimension(fh->pInputScript->frameRect.xmax - fh->pInputScript->frameRect.xmin,
				  fh->pInputScript->frameRect.ymax - fh->pInputScript->frameRect.ymin);

	return 1;	// Ok
}

void
FlashSoundInit(FlashHandle flashHandle, char *device)
{
	PrvFlashHandle *fh;

	fh = (PrvFlashHandle *)flashHandle;

	fh->sm = new SoundMixer(device);
}

void
FlashZoom(FlashHandle flashHandle, int zoom)
{
	PrvFlashHandle *fh;

	fh = (PrvFlashHandle *)flashHandle;

	fh->gd->setMovieZoom(zoom);
}

void
FlashOffset(FlashHandle flashHandle, int x, int y)
{
	PrvFlashHandle *fh;

	fh = (PrvFlashHandle *)flashHandle;

	fh->gd->setMovieOffset(x,y);
}

long
FlashExec(FlashHandle flashHandle,long flag, XEvent *event, struct timeval *wakeDate)
{
	PrvFlashHandle *fh;
	long wakeUp = 0;
	long geturl;

	fh = (PrvFlashHandle *)flashHandle;

	switch (flag & FLASH_CMD_MASK) {
		case FLASH_STOP:
			fh->pInputScript->program->pauseMovie();
			wakeUp = 0;
			break;
		case FLASH_CONT:
			fh->pInputScript->program->continueMovie();
			wakeUp = 1;
			break;
		case FLASH_REWIND:
			fh->pInputScript->program->rewindMovie();
			wakeUp = 0;
			break;
		case FLASH_STEP:
			fh->pInputScript->program->nextStepMovie();
			wakeUp = 0;
			break;
	}

	if (flag & FLASH_WAKEUP) {
		// Compute next wakeup time
		gettimeofday(wakeDate,0);
		wakeDate->tv_usec += fh->msPerFrame*1000;
		if (wakeDate->tv_usec > 1000000) {
			wakeDate->tv_usec -= 1000000;
			wakeDate->tv_sec++;
		}

		// Play frame
		wakeUp = fh->pInputScript->program->processMovie(fh->gd, fh->sm);
	}

	if (flag & FLASH_EVENT) {
		FlashEvent fe;

		// X to Flash event structure conversion
		switch (event->type) {
			case ButtonPress:
				fe.type = FeButtonPress;
				break;
			case ButtonRelease:
				fe.type = FeButtonRelease;
				break;
			case MotionNotify:
				fe.type = FeMouseMove;
				fe.x = event->xmotion.x;
				fe.y = event->xmotion.y;
				break;
			case Expose:
				fe.type = FeRefresh;
				break;
		}

		if (fh->pInputScript->program->handleEvent(fh->gd, fh->sm, &fe)) {
			gettimeofday(wakeDate,0);	// Wake up at once !!!
			wakeUp = 1;
		}
	}

	return wakeUp;
}

void
FlashSetGetUrlMethod(FlashHandle flashHandle, void (*getUrl)(char *, char *, void *), void *clientData)
{
	PrvFlashHandle *fh;

	fh = (PrvFlashHandle *)flashHandle;

	fh->pInputScript->program->setGetUrlMethod( getUrl, clientData );
}

void
FlashClose(FlashHandle flashHandle)
{
	PrvFlashHandle *fh;

	fh = (PrvFlashHandle *)flashHandle;

	delete fh;
}

void
FlashSettings(FlashHandle flashHandle, long settings)
{
	PrvFlashHandle *fh;

	fh = (PrvFlashHandle *)flashHandle;

	fh->pInputScript->program->modifySettings( settings );
}

}; /* end of extern C */
