// INCLUDES ///////////////////////////////////////////////////////////////////

#include <cstdio>

#include "imagestack.h"
#include <SDL/SDL_image.h>
#include "globals.h"
#include "config.h"

////////////////////////////////////////////////////////////////////////////////

namespace eversion {

// GLOBALS ////////////////////////////////////////////////////////////////////

image_stack* image_stack::pimage_stack	= NULL;


// FUNCTIONS //////////////////////////////////////////////////////////////////

void image_info::load(char *_filename)
{
	free();

	filename=new char[strlen(_filename)+strlen(dataDir)+1];
	strcpy(filename,eversion::dataDir);	strcat(filename,_filename);
	surface=IMG_Load(filename);

	if(surface==NULL)
	{
		fprintf(stderr,"image_info::load: failed to load %s\n", filename);
		return;
	}
}

void image_info::setFileName(char* _filename)
{
#ifdef EVERSION__DEBUG
	if(filename)
	{
		fprintf(stderr, "image_info::setFilename: filename exists");
	}
#endif
	filename=new char[strlen(_filename)+1];	strcpy(filename,_filename);
}


image_info* image_stack::find(char *filename)
{
	//image already loaded?
	for(size_t i=0; i < images.size(); i++)
	{
		if(!strcmp(images[i]->getFileName(),filename))
		{
			return images[i];
		}
	}

	return NULL;
}

SDL_Surface* image_stack::load(char *filename)
{

	//image already loaded?
	image_info* imginf = find(filename);

	if(imginf)
	{
 #ifdef EVERSION__DEBUG
		fprintf(stderr,"image_stack::load: \"%s\" already loaded, returning existing pointer...\n",filename);
 #endif
		return imginf->getSurface();
	}
	else
	{
		image_info* img = new image_info;
		images.push_back(img);
		img->load(filename);

		return img->getSurface();
	}
}

image_stack* image_stack::instance()
{
	if(pimage_stack == NULL)
		pimage_stack = new image_stack;

	return pimage_stack;
}

image_stack::~image_stack()
{
	for(size_t i=0; i<images.size(); i++)
	{
		if(images[i])
		{
			delete images[i];
		}
	}
	images.clear();
}

///////////////////////////////////////////////////////////////////////////////

}

////////////////////////////////////////////////////////////////////////////////
