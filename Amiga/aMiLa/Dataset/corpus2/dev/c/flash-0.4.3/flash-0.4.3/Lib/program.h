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
#ifndef _PROGRAM_H_
#define _PROGRAM_H_

#ifdef DUMP
#include "bitstream.h"
#endif

#include "swf.h"
#include "character.h"
#include "displaylist.h"
#include "sound.h"
#include "flash.h"

enum ControlType {
	ctrlPlaceObject,
	ctrlPlaceObject2,
	ctrlRemoveObject,
	ctrlRemoveObject2,
	ctrlDoAction,
	ctrlStartSound,
	ctrlStopSound,
	ctrlBackgroundColor
};

enum PlaceFlags {
	placeIsMove		= 0x01,
	placeHasCharacter	= 0x02,
	placeHasMatrix		= 0x04,
	placeHasColorXform	= 0x08,
	placeHasRatio		= 0x10,
	placeHasName		= 0x20,
	placeHasClip		= 0x40
};

struct Control {
	ControlType	type;

	// Place, Remove, Sound
	Character	*character;
	long		 depth;

	// Place 1&2
	PlaceFlags	 flags;
	Matrix		 matrix;
	Cxform		 cxform;
	long		 ratio;
	long		 clipDepth;
	char		*name;

	// BackgroundColor
	Color		 color;

	// DoAction
	ActionRecord	*actionRecords;

	struct Control *next;


	// Methods

	void addActionRecord( ActionRecord   *ar)
	{
		ar->next = 0;

		if (actionRecords == 0) {
			actionRecords = ar;
		} else {
			ActionRecord *current;

			for(current = actionRecords; current->next; current = current->next);

			current->next = ar;
		}
	};

	Control()
	{
		actionRecords = 0;
		cxform.aa = 1.0; cxform.ab = 0;
		cxform.ra = 1.0; cxform.rb = 0;
		cxform.ga = 1.0; cxform.gb = 0;
		cxform.ba = 1.0; cxform.bb = 0;
		ratio = 0;
		clipDepth = 0;
	};

	~Control()
	{
		ActionRecord	*ar,*del;
		for(ar = actionRecords; ar;)
		{
			del = ar;
			ar = ar->next;
			delete del;
		}
	};
};

struct Frame {
	char *label;
	Control *controls;	// Controls for this frame
};

enum MovieStatus {
	MoviePaused,
	MoviePlay
};

class Program {

	DisplayList	*dl;
	Frame		*frames;	// Array
	long		 nbFrames;
	long  		 currentFrame;
	long  		 nextFrame;
	long		 refresh;
	int		 sprite;
	MovieStatus 	 movieStatus;
	void		(*getUrl)(char *,char *, void *);
	void		*getUrlClientData;
	Sound		*currentSound;
	long		 settings;

public:
	Program(long n);
	~Program();

	void	 rewindMovie();
	void	 pauseMovie();
	void	 continueMovie();
	void	 nextStepMovie();
	void	 gotoFrame(long f);

	long	 processMovie(GraphicDevice *, SoundMixer *);
	long	 nestedMovie(GraphicDevice *, SoundMixer *, Matrix *);
	long	 runFrame(GraphicDevice *, SoundMixer *, long f, long action=1);
	long	 handleEvent(GraphicDevice *, SoundMixer *, FlashEvent *);
	long	 doAction(ActionRecord *action, SoundMixer *);
	void	 setCurrentFrameLabel(char *label);
	void	 advanceFrame();
	long	 getFrame();
	void	 setCurrentFrame(long);
	void	 addControlInCurrentFrame(Control *ctrl);
	void	 setGetUrlMethod( void (*)(char *, char *, void *), void *);
	void	 modifySettings(long flags);
	long	 searchFrame(char *);

	Frame	*getFrames();
	long	 getNbFrames();

	DisplayList *getDisplayList();

#ifdef DUMP
	void	 dump(BitStream *bs);
static  void	 dumpActions(BitStream *bs, ActionRecord *actions);
#endif
};

#endif /* _PROGRAM_H_ */
