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
#include <assert.h>
#include "swf.h"
#include "button.h"
#include "graphic.h"

static char *rcsid = "$Id: button.cc,v 1.13 1999/02/14 21:59:28 olivier Exp $";

#define PRINT 0

#define Up		0x0
#define Down		0x1
#define Out		0x0
#define Over		0x2

#define Idle		(Up  | Out)
#define OutDown		(Out | Down)
#define OverUp		(Over| Up)
#define OverDown	(Over| Down)

static long old2current[] = {
	/* Idle to Idle         */	0,
	/* Idle to OutDown      */	0,
	/* Idle to OverUp       */	1,
	/* Idle to OverDown     */	128,
	/* OutDown to Idle      */	64,
	/* OutDown to OutDown   */	0,
	/* OutDown to OverUp    */	0,
	/* OutDown to OverDown  */	32,
	/* OverUp to Idle       */	2,
	/* OverUp to OutDown    */	0,
	/* OverUp to OverUp     */	0,
	/* OverUp to OverDown   */	4,
	/* OverDown to Idle     */	256,
	/* OverDown to OutDown  */	16,
	/* OverDown to OverUp   */	8,
	/* OverDown to OverDown */	0
};

// Contructor

Button::Button(long id, int level) : Character(ButtonType, id)
{
	defLevel = level;
	actionRecords = 0;
	buttonRecords = 0;
	conditionList = 0;
	reset();
	isMenu = 0;
	sound[0] = sound[1] = sound[2] = sound[3] = 0;
}

// Destructor

Button::~Button()
{
	if (actionRecords) {
		ActionRecord *ar,*del;
		for(ar = actionRecords; ar;) {
			del = ar;
			ar = ar->next;
			delete del;
		}
	}
	if (buttonRecords) {
		ButtonRecord *br,*del;
		for(br = buttonRecords; br;) {
			del = br;
			br = br->next;
			if (del->cxform)
				delete del->cxform;
			delete del;
		}
	}
	if (conditionList) {
		Condition *cond,*del;
		for(cond = conditionList; cond;) {
			ActionRecord *ar,*d;

			del = cond;
			for(ar = cond->actions; ar;) {
				d = ar;
				ar = ar->next;
				delete d;
			}

			cond = cond->next;
			delete cond;
		}
	}
}

ButtonRecord *
Button::getButtonRecords()
{
	return buttonRecords;
}

ActionRecord *
Button::getActionRecords()
{
	return actionRecords;
}

Sound **
Button::getSounds()
{
	return sound;
}

Condition *
Button::getConditionList()
{
	return conditionList;
}

void
Button::setButtonSound(Sound *s, int state)
{
	if (state >=0 && state < 4) {
		sound[state] = s;
	}
}

void
Button::setButtonMenu(int menu)
{
	isMenu = menu;
}

void
Button::addButtonRecord( ButtonRecord *br )
{
	br->next = 0;

	if (buttonRecords == 0) {
		buttonRecords = br;
	} else {
		ButtonRecord *current;

		for(current = buttonRecords; current->next; current = current->next);

		current->next = br;
	}
}

void
Button::addCondition( long transition )
{
	Condition *condition;

	condition = new Condition;

	condition->transition = transition; 
	condition->next = conditionList;

	// Move current actionRecords to this condition
	condition->actions = actionRecords;
	actionRecords = 0;

	conditionList = condition;
}

void
Button::addActionRecord( ActionRecord *ar )
{
	ar->next = 0;

	if (actionRecords == 0) {
		actionRecords = ar;
	} else {
		ActionRecord *current;

		for(current = actionRecords; current->next; current = current->next);

		current->next = ar;
	}
}

void
Button::getRegion(GraphicDevice *gd, Matrix *matrix, unsigned char id)
{
	ButtonRecord *br;

	for (br = buttonRecords; br; br = br->next)
	{
		if ((br->state & stateHitTest) && br->character /* Temporaire */) {
			Matrix mat;

			mat = (*matrix) * br->buttonMatrix;
			br->character->getRegion(gd, &mat, id);
		}
	}
}

int
Button::execute(GraphicDevice *gd, Matrix *matrix, Cxform *cxform)
{
	ButtonRecord *br;
	int sprite = 0;
	Cxform *cxf = 0;

#if PRINT==2
	printf("Rendering Button %d  for State(s) ", getTagId());
#endif
	for (br = buttonRecords; br; br = br->next)
	{
		if (br->state & renderState) {
			Matrix mat;
			
#if PRINT==2
		printf("%d ", br->state);
#endif
			mat = (*matrix) * br->buttonMatrix;
			if (br->cxform) {
				cxf = br->cxform;
			} else if (cxform) {
				cxf = cxform;
			}
			if (br->character->execute(gd, &mat, cxf)) {
				if (oldState != currentState) {
					br->character->reset();
				}
				sprite = 1;
			}
		}
	}
#if PRINT==2
	printf("\n");
#endif
	return sprite;
}

ActionRecord *
Button::getActionFromTransition(ButtonState old)
{
	Condition *cond;
	long mask, transition;

	if (old == currentState) return 0;

	// Build a fist transition mask
	mask = Idle;
	if (currentState & stateDown) {
		mask |= Down;
	}
	if (currentState & stateUp) {
		mask |= Up;
	}
	if (currentState & stateOver) {
		mask |= Over;
	} else {
		mask |= Out;
	}
	if (old & stateDown) {
		mask |= Down<<2;
	}
	if (old & stateUp) {
		mask |= Up<<2;
	}
	if (old & stateOver) {
		mask |= Over<<2;
	} else {
		mask |= Out<<2;
	}

	transition = old2current[mask];

	for (cond = conditionList; cond; cond = cond->next) {
		if (cond->transition & transition) {
			return cond->actions;
		}
	}
	return 0;
}

ActionRecord *
Button::eventHandler(GraphicDevice *gd, FlashEvent *event)
{
	oldState = currentState;

	static ActionRecord action;
	static ActionRecord soundFx;

	action.action = ActionRefresh;
	action.next = 0;

	soundFx.action = ActionPlaySound;
	soundFx.next = &action;

#if PRINT==1
	printf("Event Type = %d, Button %d  state = %d\n", event->type, getTagId(), currentState);
#endif

	switch(event->type)
	{
		case FeButtonRelease:
			if (currentState & stateOver) {
				if (currentState & stateDown) {
					// Action !!!
#if PRINT
					printf("Action id %d %s!!!\n", getTagId(), sound[2] ? "(with sound)":"");
					printf("\n");
#endif
					currentState = (ButtonState) (stateOver | stateUp);
					renderState = stateOver;

					if (conditionList) {
						action.next = getActionFromTransition(oldState);
					} else {
						action.next = actionRecords;
					}

					if (sound[0]) {
						soundFx.sound = sound[0];
						return &soundFx;
					} else {
						return &action;
					}
				} else {
					currentState = (ButtonState) (stateOver | stateUp);
				}
			}
			break;
		case FeButtonPress:
			if (currentState & stateOver) {
				currentState = (ButtonState) (currentState | stateDown);
				currentState = (ButtonState) (currentState & ~stateUp);
				renderState = stateDown;

				if (conditionList) {
					action.next = getActionFromTransition(oldState);
				}

				if (sound[2]) {
					soundFx.sound = sound[2];
					return &soundFx;
				} else {
					return &action;
				}
			}
			break;
		case FeMouseMove:
			if (gd->checkHitTest(getTagId(),event->x, event->y)) {
				currentState = (ButtonState)(currentState | stateOver);
				renderState = stateOver;
			} else {
				currentState = stateUp;
				currentState = (ButtonState)(currentState & ~stateOver);
				renderState = stateUp;
			}

			if (conditionList) {
				action.next = getActionFromTransition(oldState);
			}

			if (oldState != currentState) {
				if (currentState & stateOver) {
					gd->setHandCursor(1);
					if (sound[1]) {
						soundFx.sound = sound[1];
						return &soundFx;
					}
				} else {
					gd->setHandCursor(0);
				}
				return &action;
			}
			break;
	}

	return 0;
}

void
Button::reset()
{
	renderState = stateUp;
	currentState = stateUp;
	oldState = stateUp;
}
