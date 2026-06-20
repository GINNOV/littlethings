// INCLUDES ///////////////////////////////////////////////////////////////////

#include "entity.h"
#include "game.h"

#include "config.h"


////////////////////////////////////////////////////////////////////////////////

namespace eversion {

u16 entity::moveDistance = 32;	//should be same with tilesize in usual
//down up left right
point2D<s32> entity::moveVectors[4] = {
									point2D<s32>(0,-1),	//up
									point2D<s32>(1,0),	//right
									point2D<s32>(0,1),	//down
									point2D<s32>(-1,0)	//left
								};
//(64,64,224,192)
rect<s32> entity::noCamMovArea[4] = {
	rect<s32>(0,0,320,64),		//up
	rect<s32>(224,0,320,288),	//right
	rect<s32>(0,192,320,288), 	//down
	rect<s32>(0,0,64,288),		//left
};

// FUNCTIONS //////////////////////////////////////////////////////////////////

entity::entity(char *imageFile, s32 tx, s32 ty, s32 _width, s32 _height, s32 _speed, entity::direction_t _dir)
{
	init();
	load(imageFile,tx,ty,_width,_height,_speed,_dir);
}

bool entity::load(char *imageFile, s32 tx, s32 ty, s32 _width, s32 _height, s32 _speed, entity::direction_t _dir)
{
	free();

	posTile.x=tx;	posTile.y=ty;
	pos.x=tx*moveDistance; pos.y=ty*moveDistance;

	width=_width;	height=_height;
	speed=_speed;	dir=_dir;

	return image.load(imageFile,width,height);
}

void entity::move(entity::direction_t d)
{
	if(state==idle)
	{
		dir = d;

		if(isObstructable())
		{
			if( !game::instance()->checkObstruction(this,d) )
			{
				setState(walk);
			}
		}
		else
		{
			setState(walk);
		}

	}
}

void entity::move(s32 tx, s32 ty)
{
	if(state==idle)
	{
		//moveDataPtr = moveData;

		// x-axis movement
		if(posTile.x>tx)	//move left
		{
			s32 dx = posTile.x-tx;
			for(s32 i=0; i<dx; i++)
				*moveDataPtr++ = left;
		}
		else				//move right
		{
			s32 dx = tx-posTile.x;
			for(s32 i=0; i<dx; i++)
				*moveDataPtr++ = right;
		}

		// y-axis movement
		if(posTile.y>ty)	//move up
		{
			s32 dy = posTile.y-ty;
			for(s32 i=0; i<dy; i++)
				*moveDataPtr++ = up;
		}
		else				//move down
		{
			s32 dy = ty-posTile.y;
			for(s32 i=0; i<dy; i++)
				*moveDataPtr++ = down;
		}

		*moveDataPtr = none;
		moveDataPtr = moveData;
	}
}

void entity::procMoveData()
{
	if((state == idle) && (*moveDataPtr != none))
	{
		move( *moveDataPtr );	//adv to next move
		moveDataPtr++;
		if( *moveDataPtr == none )
		{
			moveDataPtr = moveData;
			*moveDataPtr = none;
		}
	}
}

void entity::proc(entity *focus)
{
	procMoveData();
	bool focused = focus==this;

	////// UPDATE MOVEMENT /////////////////////////////////

	switch(state)
	{
	case walk:	//entity's walking
		{
			static u16 delta;	//distance taken

			//move cam
			if(focused)
			{
				rect<s32> rc = noCamMovArea[dir];
				rc+=game::instance()->getCam();
				if(rc.isinside(pos))
					game::instance()->moveCam(moveVectors[dir]*speed);
			}

			//move entity
			pos += moveVectors[dir]*speed;
			delta+=speed;

			if(delta>=moveDistance)	//move ends
			{
				delta=0;
				posTile+=moveVectors[dir];
				setState(idle);
			}

		}//case walk
		break;

		case idle:
			break;
	}//switch
	////////////////////////////////////////////////////////


	////// UPDATE FRAME ////////////////////////////////////
	//update counter
	switch(state)
	{
		case walk:
			frameCounter += 5;
			break;
		case idle:
			frameCounter += focused?4:2;
			break;
	}

	//set frame
	frame=dir*2 + (frameCounter/64 % 2);
	////////////////////////////////////////////////////////
}

void entity::init()
{
	width=height=0;
	frame=0;
	frameCounter=0;
	pos.set(0,0);	posTile.set(0,0);
	speed=0;
	flags=0x7;	//isobstruction,isobstructable,isvisible
	state=idle;
	moveDataPtr = moveData;
	*moveDataPtr = none;

	mov=5;
}

void entity::free()
{
	//image.~tileset();
	init();
}

entity::~entity()
{

}


///////////////////////////////////////////////////////////////////////////////

}

////////////////////////////////////////////////////////////////////////////////
