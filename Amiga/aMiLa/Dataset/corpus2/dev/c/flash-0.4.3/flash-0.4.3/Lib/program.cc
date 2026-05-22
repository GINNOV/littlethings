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

#include <stdio.h>
#include <string.h>
#include "program.h"
#include "displaylist.h"
#include "graphic.h"
#include "sound.h"

#define NOTHING  0x0
#define WAKEUP   0x1
#define GOTO     0x2
#define REFRESH  0x4

static char *rcsid = "$Id: program.cc,v 1.17 1999/02/14 22:05:15 olivier Exp $";

#define PRINT 0

int debug = 0;

Program::Program(long n)
{
	long f;

	dl = new DisplayList;

	nbFrames = n;
	frames = new Frame[n];
	currentFrame = 0;
	nextFrame = currentFrame;
	getUrl = ( void (*)(char *,char *, void *))0;
	getUrlClientData = 0;
	for(f = 0; f < n; f++)
	{
		frames[f].controls = 0;
		frames[f].label = "";
	}

	movieStatus = MoviePlay;
	refresh = 1;
	sprite = 0;
	settings = 0;
}

Program::~Program()
{
	delete dl;
	delete frames;
}

Frame	*
Program::getFrames()
{
	return frames;
}

long
Program::getNbFrames()
{
	return nbFrames;
}

DisplayList *
Program::getDisplayList()
{
	return dl;
}

void
Program::gotoFrame(long frame)
{
	long f;

	dl->clearList();

	for(f=0; f <= frame; f++) {
		runFrame(0, 0, f, 0);
	}
}

long
Program::runFrame(GraphicDevice *gd, SoundMixer *sm, long f, long action)
{
	Control		*ctrl;
	Character	*character;
	Matrix		*matrix;
	Cxform		*cxform;
	long		 status = NOTHING;
	long		 update = 0;

#if PRINT&1
	if (action) printf("Prog %x : Frame N° %d\n", this, f);
#endif
	for(ctrl = frames[f].controls; ctrl; ctrl = ctrl->next)
	{
		switch (ctrl->type)
		{
			case ctrlPlaceObject:
			case ctrlPlaceObject2:
				character = 0;
				matrix = 0;
				cxform = 0;
				if (ctrl->flags & placeHasCharacter) {
					character = ctrl->character;
				}
				if (ctrl->flags & placeHasMatrix) {
					matrix = &ctrl->matrix;
				}
				if (ctrl->flags & placeHasColorXform) {
					cxform = &ctrl->cxform;
				}
				if (!ctrl->clipDepth) {	// Ignore
					dl->placeObject(character, ctrl->depth, matrix, cxform);
					update = 1;
				}
				break;
			case ctrlRemoveObject:
				character = ctrl->character;

				if (!character) break;	// Should not happen

				dl->removeObject(character, ctrl->depth);
				if (action) {
					if (character->hasEventHandler()) {
						gd->clearHitTest(character->getTagId());
					}
					character->reset();
					update = 1;
				}
				break;
			case ctrlRemoveObject2:
				character = dl->removeObject(ctrl->depth);
				if (character && action) {
					if (character->hasEventHandler()) {
						gd->clearHitTest(character->getTagId());
					}
					character->reset();
					update = 1;
				}
				break;
		// Actions
			case ctrlDoAction:
				if (action) {
					status = doAction(ctrl->actionRecords, sm);
				}
				break;
			case ctrlStartSound:
				if (action && sm) {
					sm->startSound( (Sound *)ctrl->character );
				}
				break;
			case ctrlStopSound:
				if (action && sm) {
					sm->stopSounds();
				}
				break;
			case ctrlBackgroundColor:
				dl->setBackgroundColor(&ctrl->color);
				if (action) {
					gd->setBackgroundColor(ctrl->color);
				}
				break;
		}
	}
	if (status & GOTO) {
		gotoFrame(nextFrame);
		if (movieStatus == MoviePaused) runFrame(gd,sm,nextFrame);
		update = 1;
	}

#if PRINT&1
	if (action) printf("Frame N° %d ready\n", f);
#endif
	return update;
}

long
Program::nestedMovie(GraphicDevice *gd, SoundMixer *sm, Matrix *mat)
{
	if (movieStatus == MoviePlay) {
		// Movie Beeing Played
		advanceFrame();
		if (currentFrame == 0) {
			dl->clearList();
		}
		runFrame(gd, sm, currentFrame);
		if (nbFrames == 1) {
			pauseMovie();
		}
	}

	sprite = dl->render(gd,mat);

	return (sprite || movieStatus == MoviePlay);
}

long
Program::processMovie(GraphicDevice *gd, SoundMixer *sm )
{
	long	soundReady;

	soundReady = sm->playSounds();

#if PRINT&1
	printf("Prog %x : Current = %d     Next = %d\n", this, currentFrame, nextFrame);
#endif

	if (movieStatus == MoviePlay) {
		// Movie Beeing Played
		advanceFrame();
		if (currentFrame == 0) {
			gd->resetHitTest();
			dl->clearList();
		}
		refresh |= runFrame(gd, sm, currentFrame);
		if (nextFrame == nbFrames && ((settings & PLAYER_LOOP) == 0)) {
			pauseMovie();
		}
	}

	if (sprite || refresh) {
		gd->clearCanvas();
		sprite = dl->render(gd);
		refresh = 0;
		gd->displayCanvas();
	}

	return (sprite || movieStatus == MoviePlay || soundReady);
}

long
Program::handleEvent(GraphicDevice *gd, SoundMixer *sm, FlashEvent *event)
{
	ActionRecord	*action;
	long		 status = NOTHING;

	if (event) {
		if (event->type == FeRefresh) {
			gd->displayCanvas();
		} else
		if (event->type == FeNone) {
			return 0;
		} else {
			action = dl->processEvent(gd,event);
			status = doAction(action, sm);
			if (status & REFRESH) {
				status |= WAKEUP;
				refresh = 1;
			}
			if (status & GOTO) {
				gd->resetHitTest();
				gotoFrame(nextFrame);
				if (movieStatus == MoviePaused) runFrame(gd,sm,nextFrame);
				refresh = 1;
			}
		}
	}
	if (status) return processMovie(gd,sm);
	return 0;
}

long
Program::doAction(ActionRecord *action, SoundMixer *sm)
{
	long status = NOTHING;

	while(action)
	{
		switch (action->action)
		{
			case ActionPlaySound:
#if PRINT&2
				printf("Prog %x : PlaySound\n", this);
#endif
				sm->startSound(action->sound);
				status |= WAKEUP;
				break;
			case ActionRefresh:
#if PRINT&2
				printf("Prog %x : Refresh\n", this);
#endif
				status |= REFRESH;
				break;
			case ActionGotoFrame:
#if PRINT&2
				printf("Prog %x : GotoFrame %d\n", this, action->frameIndex);
#endif
				nextFrame = action->frameIndex;
				status |= WAKEUP|GOTO;
				break;
			case ActionGetURL:
#if PRINT&2
				printf("Prog %x : GetURL %s target = %s\n", this, action->url, action->target);
#endif
				if (getUrl) {
					getUrl(action->url, action->target, getUrlClientData);
				}
				break;
			case ActionNextFrame:
				nextFrame = currentFrame+1;
				status |= WAKEUP;
				break;
			case ActionPrevFrame:
				nextFrame = currentFrame-1;
				status |= WAKEUP|GOTO;
				break;
			case ActionPlay:
#if PRINT&2
				printf("Prog %x : Play\n", this);
#endif
				movieStatus = MoviePlay;
				if (currentFrame == nextFrame) advanceFrame();
				status |= WAKEUP;
				break;
			case ActionStop:
#if PRINT&2
				printf("Prog %x : Stop\n", this);
#endif
				movieStatus = MoviePaused;
				nextFrame = currentFrame;
				break;
			case ActionToggleQuality:
				break;
			case ActionStopSounds:
				sm->stopSounds();
				break;
			case ActionWaitForFrame:
				break;
			case ActionSetTarget:
				break;
			case ActionGoToLabel:
#if PRINT&2
				printf("Prog %x : GotoFrame '%s'\n", this, action->frameLabel);
#endif
				nextFrame = searchFrame(action->frameLabel);
				status |= WAKEUP|GOTO;
				break;
		}
		action = action->next;
	}
	return status;
}

void
Program::setCurrentFrameLabel(char *label)
{
	frames[currentFrame].label = label;
}

void
Program::rewindMovie()
{
	currentFrame = 0;
	nextFrame = 0;
}

void
Program::pauseMovie()
{
	movieStatus = MoviePaused;
	nextFrame = currentFrame;
}

void
Program::continueMovie()
{
	movieStatus = MoviePlay;
}

void
Program::nextStepMovie()
{
	if (movieStatus == MoviePaused) {
		advanceFrame();
	}
}

void
Program::advanceFrame()
{
	currentFrame = nextFrame;
	nextFrame = currentFrame+1;
	if (currentFrame == nbFrames) {
		currentFrame = 0;
		nextFrame = 1;
	}
}

void Program::setCurrentFrame(long n)
{
	currentFrame = n;
	nextFrame = n;
	refresh = 1;
}

long Program::getFrame()
{
	return currentFrame;
}

void
Program::addControlInCurrentFrame(Control *ctrl)
{
	Control *c;

	ctrl->next = 0;
	if (frames[currentFrame].controls == 0) {
		frames[currentFrame].controls = ctrl;
	} else {
		for(c = frames[currentFrame].controls; c->next; c = c->next);
		c->next = ctrl;
	}
}

void
Program::setGetUrlMethod( void (*func)(char *, char *, void *), void *clientData)
{
	getUrl = func;
	getUrlClientData = clientData;
}

void
Program::modifySettings(long flags)
{
	settings = flags;
}

long
Program::searchFrame(char *label)
{
	long f;

	for(f=0; f < nbFrames; f++)
	{
		if (frames[f].label && !strcmp(label,frames[f].label)) {
			return f;
		}
	}
	return 0;
}
