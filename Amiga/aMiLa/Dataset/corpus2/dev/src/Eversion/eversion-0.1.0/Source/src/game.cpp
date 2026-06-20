// INCLUDES ///////////////////////////////////////////////////////////////////

#include "game.h"
#include "main.h"
#include "sdl.h"
#include "globals.h"
#include "macros.h"
#include "timer.h"


////////////////////////////////////////////////////////////////////////////////

namespace eversion {

// GLOBALS ////////////////////////////////////////////////////////////////////

game* game::lpGame	= NULL;


// FUNCTIONS //////////////////////////////////////////////////////////////////

// Returns the instance of game (singleton)
game* game::instance()
{
	if(lpGame == NULL)
		lpGame = new game;

	return lpGame;
}

void game::initScene(s32 w, s32 h)
{
	scene.x=(screenWidth-w)/2; scene.y=(screenHeight-h)/2;
	scene.w=w;	scene.h=h;

}

// All game initialization goes here.
void game::init()
{
	focus=0;
	initScene(mapwinx, mapwiny);

	thefont.load("font.png",16,16);
	themap.load("test.map");
	spawnEntity("dark.png",0,0,32,32,2);
	spawnEntity("angel.png",0,3);

	textWin.setCaption("into darkness i whisper a name, her name frightens the where i am...");
}

void game::drawScene()
{
	themap.draw(cam,scene);
	drawEntities();

	textWin.update();
	s32 y;
	y=10;
}

void game::drawEntities()
{
	for(size_t i=0; i<entities.size(); i++)
		entities[i]->draw(cam,scene);
}

void game::updateControls()
{
	updateKeyb();
	updateMouse();
}

void game::updateKeyb()
{
	//system
	if(devKeyb.key_pressed(SDLK_ESCAPE))
		endGame();

	if(devKeyb.key_pressed(SDLK_SPACE))
		themap.updateMovLayer(entities[focus]);

	if(devKeyb.key_pressed(SDLK_F8))
		::SDL_SaveBMP(eversion::screen,"screenshot.bmp");
	//////////////////

	//textbox
	if( textWin.getState() != textbox::dead )
	{
		if(textWin.getState() == textbox::hold )
		{
			static timer arrowTimer;
			static bool timerExec = false;

			if(timerExec)
			{
				if(arrowTimer.get()==0)
				{
					textWin.kill();
					timerExec = false;
				}
			}
			else if(devKeyb.key_pressed(io_device::control_device::a) || devKeyb.key_pressed(io_device::control_device::b) )
			{
				timerExec = true;

				if( !textWin.moreText() )
				{
					devKeyb.unpress_key(io_device::control_device::a);
					devKeyb.unpress_key(io_device::control_device::b);
					arrowTimer.set(200);
				}
				else
					arrowTimer.set(300);
			}
		}
		else
		{
			static bool speedAltered = false;
			static u8 textRate;
			//inc the textspeed
			if(devKeyb.key_pressed(io_device::control_device::a) || devKeyb.key_pressed(io_device::control_device::b))
			{
				if(!speedAltered)
				{
					textRate = textWin.getTextRate();
					textWin.setTextRate( --textRate );
					speedAltered=true;
					return;
				}
			}
			else if(speedAltered)
			{
				textWin.setTextRate( ++textRate );
				speedAltered = false;
			}
		}

		return;
	}

	//focus entities
	if(entities[focus]->getState() == entity::idle)
	{
		if(devKeyb.key_pressed(io_device::control_device::a))
		{
			switch( checkObstruction(entities[focus],entities[focus]->getDirection()) )
			{
			case -1:	//entities obstruction
				textWin.setCaption("into eternity we shed our tears...");
				devKeyb.unpress_key(io_device::control_device::a);
				break;
			}
		}

		if(devKeyb.key_pressed(io_device::control_device::right))
			entities[focus]->move(entity::right);
		if(devKeyb.key_pressed(io_device::control_device::left))
			entities[focus]->move(entity::left);
		if(devKeyb.key_pressed(io_device::control_device::up))
			entities[focus]->move(entity::up);
		if(devKeyb.key_pressed(io_device::control_device::down))
			entities[focus]->move(entity::down);
	}
}

void game::updateMouse()
{
}

void game::update()
{
	// Game logic update (function calls)
	updateControls();
	for(size_t i=0; i<entities.size(); i++)
		entities[i]->proc(entities[focus]);
}

game::~game()
{
	// call destructors and deallocate allocated memory
	for(size_t i=0; i<entities.size(); i++)
		delete entities[i];
	entities.clear();
}

void game::spawnEntity(char *img, s32 tx, s32 ty, s32 w, s32 h, s32 s, entity::direction_t d)
{
	entity *ent = new entity(img, tx,ty, w,h,s,d);
	entities.push_back(ent);
	//entities& ent = entities[entities.size()-1];
}

char game::checkObstruction(entity* ent, entity::direction_t d)
{
	point2D<s32> p = ent->getPos();

	//check for themap obstruction/bounds first
	{
		point2D<s32> n(p + (entity::moveVectors[d]*entity::moveDistance));
		n.x/=themap.getTileWidth();	n.y/=themap.getTileHeight();

		//check themap obstruction
		if(themap.thereObstruction(n.x,n.y))
			return -2;

		//inside themap?
		rect<s32> rm(0,0,themap.getWidth()-1,themap.getHeight()-1);
		if(!rm.isinside( ent->getPosTile()+entity::moveVectors[d] ))
			return -3;
	}

	//check for other entities
	for(size_t i=0; i<entities.size(); i++)
	{
		if( (ent != entities[i]) && entities[i]->isObstruction() )
		{
			s32 dist=-1;
			switch(d)
			{
			case entity::down:
				if(entities[i]->getPos().x == p.x)
					dist = entities[i]->getPos().y - p.y;
				break;

			case entity::up:
				if(entities[i]->getPos().x == p.x)
					dist = p.y - entities[i]->getPos().y;
				break;

			case entity::right:
				if(entities[i]->getPos().y == p.y)
					dist= entities[i]->getPos().x - p.x;
				break;

			case entity::left:
				if(entities[i]->getPos().y == p.y)
					dist = p.x - entities[i]->getPos().x;
				break;

			case entity::none:

				break;
			}

			if(dist>=0 && dist<entity::moveDistance*2)	// [0,movD*2)
				return -1;
		}
	}

	return 0;
}

bool game::thereEntity(s32 x, s32 y)
{
	point2D<s32> p;

	for(size_t i=0; i<entities.size(); i++)
	{
		p = entities[i]->getPosTile();

		if( p.x == x && p.y == y)
			return true;
	}

	return false;
}

void game::normalizeCam()
{
	if(cam.x<0) cam.x=0; else if(cam.x>(themap.getP_Width()-scene.w) ) cam.x=themap.getP_Width()-scene.w;
	if(cam.y<0) cam.y=0; else if(cam.y>(themap.getP_Height()-scene.h) ) cam.y=themap.getP_Height()-scene.h;
}


///////////////////////////////////////////////////////////////////////////////

}

////////////////////////////////////////////////////////////////////////////////
