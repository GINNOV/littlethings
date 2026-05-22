#ifndef EVERSION__ENTITY_H
#define EVERSION__ENTITY_H


// INCLUDES ///////////////////////////////////////////////////////////////////

#include "math.h"
#include "types.h"
#include "tileset.h"


////////////////////////////////////////////////////////////////////////////////

namespace eversion {

// CLASSES ////////////////////////////////////////////////////////////////////

class entity
{
public:
	//typedef enum { down=0, up, left, right, none } direction_t;	//0,1,2,3
	typedef enum { up=0, right, down, left, none } direction_t;
	typedef enum { idle, walk } state_t;

	static u16 moveDistance;
	static eversion::point2D<s32> moveVectors[4];
	static eversion::rect<s32> noCamMovArea[4];

private:
	tileset pictures;
	surface portrait;

	point2D<s32> pos;		//entity position in pixels
	point2D<s32> posTile;	//entity position in tiles
	s32 width, height;
	tileset image;
	s32 speed;
	direction_t dir;
	state_t state;

	u8 frame,frameCounter;

	/*u16 exp,level;
	u16 att,def,agi,mov;
	u16 hp,mp;*/
	//magic,inv
	u16 mov;

	u8 flags;

	/*
	FLAG FORMAT:

	bit		usage
	------------------
	0		isobstructable
	1		isobstruction
	2		isvisible
	3		--unused-- //ispersistent
	4		--unused--
	5		--unused--
	6		--unused--
	7		--unused--
	*/

	direction_t moveData[256];
	direction_t *moveDataPtr;

	void procMoveData();

	void setDirection(direction_t _dir) { dir = _dir; }
	void setState(state_t _state) { state = _state; }

	//entity& operator=(const entity&);

public:
	entity() { init(); }
	entity(char *imageFile, s32 tx, s32 ty, s32 _width, s32 _height, s32 _speed, direction_t _dir = down);
	~entity();

	//entity(const entity& ent);

	bool load(char *imageFile, s32 tx, s32 ty, s32 _width, s32 _height, s32 _speed, direction_t _dir = down);

	void init();
	void free();

	//virtual void draw() { image.draw(frame,pos.x,pos.y); }
	void draw(const point2D<s32> &p, const ::SDL_Rect &scene) { if(isVisible()) image.draw(frame,pos.x-p.x,pos.y-p.y); }

	direction_t getDirection() const { return dir; }
	state_t getState() const { return state; }
	point2D<s32> getPos() const { return pos; }
	point2D<s32> getPosTile() const { return posTile; }

	u16 getMov() const { return mov; }

	void move(direction_t d);
	void move(s32 tx, s32 ty);
	void moveRel(s32 tx, s32 ty) { move(posTile.x + tx, posTile.y + ty); }
	//virtual void move(char *movestr);

	bool isObstructable() { return (flags & 0x1)!=0; }
	bool isObstruction() { return (flags & 0x2)!=0; }
	bool isVisible() { return (flags & 0x4)!=0; }

	void setIsObstructable(bool set) { set?(flags |= 0x1):(flags &= ~0x1); }//FE
	void setIsObstruction(bool set) { set?(flags |= 0x2):(flags &= ~0x2);  }//FD
	void setIsVisible(bool set) { set?(flags |= 0x4):(flags &= ~0x4);  }//FB

	void proc(entity *focus=NULL);
};

////////////////////////////////////////////////////////////////////////////////

}

////////////////////////////////////////////////////////////////////////////////

#endif //EVERSION__ENTITY_H
