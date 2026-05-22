#ifndef EVERSION__IMAGESTACK_H
 #define EVERSION__IMAGESTACK_H


// INCLUDES ///////////////////////////////////////////////////////////////////

#include <cstring>
#include <vector>
#include <SDL/SDL.h>


////////////////////////////////////////////////////////////////////////////////

//these classes will prevent load of the same image more than once.

namespace eversion {

// CLASSES ////////////////////////////////////////////////////////////////////

struct image_info
{
private:
	char *filename;
	SDL_Surface *surface;

	void init() { surface=NULL; filename=NULL; }
	void free() { /*freeSurface();*/ if(filename) delete [] filename; init(); }

	void setFileName(char* _filename);

public:
	image_info() { init(); }
	image_info(char *_filename) { init(); load(_filename); }
	~image_info() { free(); }

	void freeSurface() { if(surface) SDL_FreeSurface(surface); }

	char* getFileName() { return filename; }	//insecure
	SDL_Surface* getSurface() { return surface; }

	void load(char *_filename);
};

///////////////////////////////////////////////////////////////////////////////

class image_stack
{
private:
	static image_stack *pimage_stack;
	std::vector<image_info*> images;

	image_stack() {}

public:
	~image_stack();
	static image_stack* instance();

	SDL_Surface* load(char* filename);
	image_info* find(char *filename);
	SDL_Surface* get(char *filename) { return find(filename)->getSurface(); }
};


////////////////////////////////////////////////////////////////////////////////

}

////////////////////////////////////////////////////////////////////////////////

#endif //EVERSION__IMAGESTACK_H
