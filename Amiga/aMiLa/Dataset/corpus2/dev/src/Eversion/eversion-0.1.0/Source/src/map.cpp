// INCLUDES ///////////////////////////////////////////////////////////////////

#include <fstream>
#include <iostream>

#include "map.h"
#include "game.h"
#include "globals.h"


////////////////////////////////////////////////////////////////////////////////

namespace eversion {


// FUNCTIONS //////////////////////////////////////////////////////////////////

void map::create(u32 _width, u32 _height, size_t layerCount)
{

	free();
	width = _width; height = _height;

	std::vector< layer<mapdata_t> >::iterator p = layerMap.end();
	layerMap.insert(p,layerCount,layer<mapdata_t>());

	for(u32 i=0; i<layerMap.size(); i++)
		layerMap[i].create(width,height);

	layerEvent.create(width,height);
	layerObstruction.create(width,height);
	layerMov.create(width,height);
}

bool map::load(char *filename)
{
	/**********************************************************
	MAP FORMAT:

	layerCount(1)  width(1)  height(1)  tilecount(1)  tilesize(v) layer_0(v) layer_1(v) ... layer_n(v) layer_obs(v)

	notes:
	<dataname><size_in_bytes>
	v (as size) = variable length
	**********************************************************/
	char* mapfile = new char[strlen(filename)+strlen(dataDir)+1];
	strcpy(mapfile,eversion::dataDir);	strcat(mapfile,filename);

	u8 c;
	std::ifstream input(mapfile);

	input.get((char&)c);
	size_t layerCount = c;

	input.get((char&)c);
	width = c;

	input.get((char&)c);
	height = c;

	input.get((char&)c);
	u32 tilecount = (u32)c;

	input.get((char&)c);
	u32 tilesize =  (u32)c;

	create(width,height,layerCount);
	p_width = width*tilesize;	p_height = height*tilesize;

	char* pTilesetFile = tilesetFile;

	do
	{
		input.get((char&)c);
		*(pTilesetFile++) = c;
	} while(c);

	//////////// LAYERS 0-9 ////////////
	for(u32 i=0; i<layerMap.size(); i++)
	{
		for(u32 y=0; y<height; y++)
			for(u32 x=0; x<width; x++)
			{
				input.get((char&)c);

				if(input.eof())
				{
					fprintf(stderr,"Unexpected file length in .map file\n");
					input.close();
					return false;
				}

				layerMap[i].set(x,y,c);
			}
	}

	/////////// OBSTRUCTION ///////////////
	for(u32 y=0; y<height; y++)
		for(u32 x=0; x<width; x++)
		{
			input.get((char&)c);
			layerObstruction.set(x,y,c?1:0);
		}

	input.close();

	delete [] mapfile;

	thetileset.load(tilesetFile,tilesize,tilesize,tilecount);
	flashTile.load("white.png");
	flashTile.setAlpha(100);

	return true;
}

void map::normalize(point2D<s32> &p)
{
	if(p.y<0)
		p.y=0;
	else if(p.y>height)
		p.y=height;
	if(p.x<0)
		p.x=0;
	else if(p.x>width)
		p.x=width;
}

bool map::draw(const point2D<s32> &p, const ::SDL_Rect &scene)
{
	point2D<s32> start(p.x/thetileset.getWidth(),p.y/thetileset.getHeight());
	point2D<s32> end(start.x + scene.w/thetileset.getWidth() + (p.x % thetileset.getWidth() ? 1 : 0),
				start.y + scene.h/thetileset.getHeight() + (p.y % thetileset.getHeight() ? 1 : 0) );

	normalize(start);	normalize(end);

	for(u32 i = 0; i < layerMap.size(); i++)
	{
		for(s32 y = start.y; y < end.y; y++)
		{
			for(s32 x = start.x; x < end.x; x++)
			{
				if(layerMap[i].get(x,y) != 0)
					thetileset.draw(layerMap[i].get(x,y)-1,
					x*thetileset.getWidth() - p.x, y*thetileset.getHeight() - p.y);
			}
		}
	}

	if(1)
	{
		for(s32 y = start.y; y < end.y; y++)
		{
			for(s32 x = start.x; x < end.x; x++)
			{
				if(layerMov.get(x,y))
					flashTile.draw(x*thetileset.getWidth() - p.x, y*thetileset.getHeight() - p.y);
			}
		}
	}

	return true;
}

void map::updateMovLayer(entity *focus)
{
	layer<s32> layerTemp(width,height);

	//set obstructions to -1
	{
		for (u32 y = 0; y < height; y++)
			for (u32 x = 0; x < width; x++)
			{
				if(layerObstruction.get(x,y) || game::instance()->thereEntity(x,y))
					layerTemp.set(x,y,-1);
			}
	}

	point2D<s32> pos = focus->getPosTile();
	layerTemp.set(pos.x,pos.y,1);	//set char's pos to 1

	//algorithm by Koshums
	for (s16 i = 1; i <= focus->getMov(); i++)   // loop through num of times equal to speed (max movememnt distance)
	{
		for (s32 y = 0; y < height; y++)
		{
			for (s32 x = 0; x < width; x++)
			{
			 if (layerTemp.get(x,y) == i)   // if it is set to the number we're looking for
			 {
				// check square above
				if (y && layerTemp.get(x,y-1) == 0)      // if not obstructed and we haven't already changed this value
				   layerTemp.set(x,y-1,i+1);      // set it to next number we're looking for

				// check down
				if (y<height-1 && layerTemp.get(x,y+1) == 0)      // do same for below left and right
				   layerTemp.set(x,y+1,i+1);
				// check left
				if (x && layerTemp.get(x-1,y) == 0)
				   layerTemp.set(x-1,y,i+1);

				// check right
				if (x<width-1 && layerTemp.get(x+1,y) == 0)
				   layerTemp.set(x+1,y,i+1);
			 }
		  }
	   }
	}


	{
		//layerMov.clear();

		for (s16 y = 0; y < height; y++)
			for (s16 x = 0; x < width; x++)
				layerMov.set(x,y,layerTemp.get(x,y)>0);
	}

}


///////////////////////////////////////////////////////////////////////////////

}

////////////////////////////////////////////////////////////////////////////////
