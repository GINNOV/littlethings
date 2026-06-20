/*
------------------------------------------------------------
	Smooth Scrolling
------------------------------------------------------------
 * Using OpenGL and sub-pixel accurate rendering.
 * Map editor included. :-)
 *
 * Copyright (c) David Olofson <david@olofson.net>, 2002
 *
 * This software is released under the terms of the GPL.
 */

#include <stdlib.h>
#include <string.h>
#include <math.h>

#include "SDL.h"

#if HAS_SDL_OPENGL_H
#include "SDL_opengl.h"
#else
#ifdef WIN32
#include <windows.h>
#endif
#if defined(__APPLE__) && defined(__MACH__)
#include <OpenGL/gl.h>
#include <OpenGL/glu.h>
#else
#include <GL/gl.h>
#include <GL/glu.h>
#endif
#endif

/* Screen size (unscaled) */
#define	SCREEN_W	320
#define	SCREEN_H	240

/* Tile size */
#define	TILE_W		32
#define	TILE_H		32

/* Tile palette size (pixels) */
#define	PALETTE_W	256
#define	PALETTE_H	256

/* Tile palette size (tiles) */
#define	PALETTE_TW	(PALETTE_W / TILE_W)
#define	PALETTE_TH	(PALETTE_H / TILE_H)

/* Map size (tiles) */
#define	MAP_W		32
#define	MAP_H		16


/*------------------------------------------------
	Common stuff
------------------------------------------------*/
void (*video_draw_tile)(float x, float y, int tile);
Uint32 (*video_map_rgb)(Uint8 r, Uint8 g, Uint8 b);
void (*video_fillrect)(SDL_Rect *r, Uint32 color);
void (*video_flip)(void);
void (*video_close)(void);
unsigned char	*map = NULL;
int		flags = 0;		/* SDL video flags */
int		bpp = 0;		/* Preferred screen bpp */

int		scale = -1;		/* Screen scale factor */
int		mscale;			/* Mouse scale factor */
int		screen_w, screen_h;	/* Actual screen size */
int		vscreen_w, vscreen_h;	/* Virtual screen size */


/*------------------------------------------------
	SDL mode
------------------------------------------------*/
SDL_Surface *screen = NULL;
SDL_Surface *tiles = NULL;

void draw_tile_sdl(float x, float y, int tile)
{
	SDL_Rect source_rect, dest_rect;

	source_rect.x = tile % PALETTE_TW * TILE_W;
	source_rect.y = tile / PALETTE_TW * TILE_H;
	source_rect.w = TILE_W;
	source_rect.h = TILE_H;

	dest_rect.x = (int)floor(x);
	dest_rect.y = (int)floor(y);

	SDL_BlitSurface(tiles, &source_rect, screen, &dest_rect);
}

Uint32 map_rgb_sdl(Uint8 r, Uint8 g, Uint8 b)
{
	return SDL_MapRGB(screen->format, r, g, b);
}

void fillrect_sdl(SDL_Rect *r, Uint32 color)
{
	SDL_FillRect(screen, r, color);
}

void flip_sdl(void)
{
	SDL_Flip(screen);
}

void close_sdl(void)
{
	SDL_FreeSurface(tiles);
	SDL_Quit();
}

int init_sdl(void)
{
	SDL_Surface *tmp = NULL;

	video_draw_tile = draw_tile_sdl;
	video_map_rgb = map_rgb_sdl;
	video_fillrect = fillrect_sdl;
	video_flip = flip_sdl;
	video_close = close_sdl;

	screen = SDL_SetVideoMode(screen_w, screen_h, bpp, flags);
	if(!screen)
	{
		fprintf(stderr, "Failed to open screen!\n");
		exit(-1);
	}

	tmp = SDL_LoadBMP("tiles.bmp");
	if(!tmp)
	{
		fprintf(stderr, "Could not load graphics!\n");
		return -1;
	}
	tiles = SDL_DisplayFormat(tmp);
	if(!tiles)
	{
		fprintf(stderr, "Could not convert graphics!\n");
		return -1;
	}
	SDL_FreeSurface(tmp);

	return 0;
}


/*------------------------------------------------
	OpenGL mode
------------------------------------------------*/
GLint gl_tiles;

/* OpenGL "state optimizer" hack from glSDL */
static struct
{
	int	do_blend;
	int	do_texture;
	GLint	texture;
	GLenum	sfactor, dfactor;
} glstate;

static void gl_reset(void)
{
	glstate.do_blend = -1;
	glstate.do_blend = -1;
	glstate.texture = -1;
	glstate.sfactor = 0xffffffff;
	glstate.dfactor = 0xffffffff;
}

static __inline__ void gl_do_blend(int on)
{
	if(glstate.do_blend == on)
		return;

	if(on)
		glEnable(GL_BLEND);
	else
		glDisable(GL_BLEND);
	glstate.do_blend = on;
}

static __inline__ void gl_do_texture(int on)
{
	if(glstate.do_texture == on)
		return;

	if(on)
		glEnable(GL_TEXTURE_2D);
	else
		glDisable(GL_TEXTURE_2D);
	glstate.do_texture = on;
}

static __inline__ void gl_blendfunc(GLenum sfactor, GLenum dfactor)
{
	if((sfactor == glstate.sfactor) && (dfactor == glstate.dfactor))
		return;

	glBlendFunc(sfactor, dfactor);

	glstate.sfactor = sfactor;
	glstate.dfactor = dfactor;
}

static __inline__ void gl_texture(GLuint tx)
{
	if(tx == glstate.texture)
		return;

	glBindTexture(GL_TEXTURE_2D, tx);
	glstate.texture = tx;
}

void draw_tile_gl(float x, float y, int tile)
{
	float tx1 = (float)(tile % PALETTE_TW) / PALETTE_TW;
	float ty1 = (float)(tile / PALETTE_TH) / PALETTE_TH;
	float tx2 = tx1 + ((float)TILE_W / PALETTE_W);
	float ty2 = ty1 + ((float)TILE_H / PALETTE_H);
	float x1 = x;
	float y1 = y;
	float x2 = x + TILE_W;
	float y2 = y + TILE_H;

	gl_do_texture(1);
	gl_do_blend(0);
	gl_texture(gl_tiles);

	glBegin(GL_QUADS);
	glColor4ub(255, 255, 255, 255);
	glTexCoord2f(tx1, ty1);	glVertex2f(x1, y1);
	glTexCoord2f(tx2, ty1);	glVertex2f(x2, y1);
	glTexCoord2f(tx2, ty2);	glVertex2f(x2, y2);
	glTexCoord2f(tx1, ty2);	glVertex2f(x1, y2);
	glEnd();
}


Uint32 map_rgb_gl(Uint8 r, Uint8 g, Uint8 b)
{
	return r<<16 | g<<8 | b;
}


void fillrect_gl(SDL_Rect *r, Uint32 color)
{
	int dx1, dy1, dx2, dy2;

	gl_do_texture(0);
	gl_do_blend(0);

	if(!r)
		r = &screen->clip_rect;

	dx1 = r->x;
	dy1 = r->y;
	dx2 = dx1 + r->w;
	dy2 = dy1 + r->h;

	glBegin(GL_QUADS);
	glColor3ub((color>>16) & 255, (color>>8) & 255, color & 255);
	glVertex2i(dx1, dy1);
	glVertex2i(dx2, dy1);
	glVertex2i(dx2, dy2);
	glVertex2i(dx1, dy2);
	glEnd();
}


void flip_gl(void)
{
	SDL_GL_SwapBuffers();
}


void close_gl(void)
{
	glDeleteTextures(1, &gl_tiles);
	SDL_Quit();
}


int init_gl(void)
{
	SDL_Surface *tmp, *tmp2;

	GLint gl_doublebuf;
	GLint maxtexsize;

	video_draw_tile = draw_tile_gl;
	video_map_rgb = map_rgb_gl;
	video_fillrect = fillrect_gl;
	video_flip = flip_gl;
	video_close = close_gl;

	flags |= SDL_OPENGL;

	gl_doublebuf = flags & SDL_DOUBLEBUF;
	if(bpp == 15)
	{
		SDL_GL_SetAttribute(SDL_GL_RED_SIZE, 5);
		SDL_GL_SetAttribute(SDL_GL_GREEN_SIZE, 5);
		SDL_GL_SetAttribute(SDL_GL_BLUE_SIZE, 5);
	}
	if(bpp == 16)
	{
		SDL_GL_SetAttribute(SDL_GL_RED_SIZE, 5);
		SDL_GL_SetAttribute(SDL_GL_GREEN_SIZE, 6);
		SDL_GL_SetAttribute(SDL_GL_BLUE_SIZE, 5);
	}
	else if(bpp >= 24)
	{
		SDL_GL_SetAttribute(SDL_GL_RED_SIZE, 8);
		SDL_GL_SetAttribute(SDL_GL_GREEN_SIZE, 8);
		SDL_GL_SetAttribute(SDL_GL_BLUE_SIZE, 8);
	}
	if(bpp)
		SDL_GL_SetAttribute(SDL_GL_DEPTH_SIZE, bpp);
	SDL_GL_SetAttribute(SDL_GL_DOUBLEBUFFER, gl_doublebuf);

	screen = SDL_SetVideoMode(screen_w, screen_h, bpp, flags);
	if(!screen)
	{
		fprintf(stderr, "Failed to open screen!\n");
		return -1;
	}

	/*
	 * Just because my driver f*cks up if there's console
	 * output when it's messing with textures... :-(
	 */
	SDL_Delay(1000);

	glGetIntegerv(GL_MAX_TEXTURE_SIZE, &maxtexsize);
	if(maxtexsize < 256)
	{
		fprintf(stderr, "Need at least 256x256 textures!\n");
		SDL_Quit();
		return -1;
	}

	tmp = SDL_LoadBMP("tiles.bmp");
	if(!tmp)
	{
		fprintf(stderr, "Could not load graphics!\n");
		SDL_Quit();
		return -1;
	}

	tmp2 = SDL_CreateRGBSurface(SDL_SWSURFACE, 256, 256, 24,
#if SDL_BYTEORDER == SDL_BIG_ENDIAN
			0x00ff0000, 0x0000ff00, 0x000000ff, 0);
#else
			0x000000ff, 0x0000ff00, 0x00ff0000, 0);
#endif
	if(!tmp2)
	{
		fprintf(stderr, "Failed to make texture from graphics!\n");
		SDL_FreeSurface(tmp);
		SDL_Quit();
		return -1;
	}

	SDL_BlitSurface(tmp, NULL, tmp2, NULL);
	SDL_FreeSurface(tmp);

	glGenTextures(1, &gl_tiles);
	glBindTexture(GL_TEXTURE_2D, gl_tiles);
	glPixelStorei(GL_UNPACK_ROW_LENGTH, tmp2->pitch /
			tmp2->format->BytesPerPixel);
	glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
	glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR);
	glTexImage2D(GL_TEXTURE_2D, 0, GL_RGB8, tmp2->w, tmp2->h, 0, GL_RGB,
			GL_UNSIGNED_BYTE, tmp2->pixels);
	glFlush();
	SDL_FreeSurface(tmp2);

	/*
	 * Set up OpenGL for 2D rendering.
	 */
	glDisable(GL_DEPTH_TEST);
	glDisable(GL_CULL_FACE);

	glViewport(0, 0, screen->w, screen->h);
	glMatrixMode(GL_PROJECTION);
	glLoadIdentity();
	glOrtho(0, vscreen_w, vscreen_h, 0, -1.0, 1.0);

	glMatrixMode(GL_MODELVIEW);
	glLoadIdentity();
	glTranslatef(0.0f, 0.0f, 0.0f);

	return 0;
}


/*------------------------------------------------
	Common functions
------------------------------------------------*/
int	maxx, maxy;
float	xpos = 0.0;
float	ypos = 0.0;
float	sx = 30.0;
float	sy = 30.0;

void video_bounce(float dt)
{
	int maxx = MAP_W * TILE_W - vscreen_w;
	int maxy = MAP_H * TILE_H - vscreen_h;

	if(xpos >= maxx)
	{
		sx = -sx;
		xpos = maxx * 2 - xpos;
	}
	else if(xpos <= 0)
	{
		sx = -sx;
		xpos = -xpos;
	}

	if(ypos >= maxy)
	{
		sy = -sy;
		ypos = maxy * 2 - ypos;
	}
	else if(ypos <= 0)
	{
		sy = -sy;
		ypos = -ypos;
	}
}


void video_limit(float dt)
{
	if(xpos >= maxx)
		xpos = maxx;
	else if(xpos < 0)
		xpos = 0;

	if(ypos >= maxy)
		ypos = maxy;
	else if(ypos < 0)
		ypos = 0;
}


void video_render(void)
{
	int map_x, map_y, map_x_loop;
	float fine_x, fine_y;
	float x, y;

	map_x = (int)xpos / TILE_W;
	map_y = (int)ypos / TILE_H;

	fine_x = (xpos / TILE_W - floor(xpos / TILE_W)) * TILE_W;
	fine_y = (ypos / TILE_H - floor(ypos / TILE_H)) * TILE_H;

	for (y = -fine_y; y < vscreen_h; y += TILE_H)
	{
		map_x_loop = map_x;
		for (x = -fine_x; x < vscreen_w; x += TILE_W)
		{
			if((map_y < MAP_H) && (map_x_loop < MAP_W))
				video_draw_tile(x, y, map[
						map_y * MAP_W + map_x_loop++]);
			else
				video_draw_tile(x, y, 0);
		}
		++map_y;
	}
}


unsigned char *new_map(void)
{
	unsigned char *map = calloc(MAP_W, MAP_H);
	if(!map)
	{
		fprintf(stderr, "Failed to allocate space for map!\n");
		return NULL;
	}
	return map;
}


unsigned char *load_map(const char *name)
{
	FILE *f;
	unsigned char *map = new_map();
	if(!map)
		return NULL;

	f = fopen(name, "rb");
	if(!f)
	{
		fprintf(stderr, "Failed to open map!\n");
		free(map);
		return NULL;
	}

	if(fread(map, MAP_W, MAP_H, f) != MAP_H)
	{
		fprintf(stderr, "Error while loading map!\n");
		free(map);
		fclose(f);
		return NULL;
	}

	fclose(f);

	printf("Map loaded.\n");
	return map;
}


int save_map(unsigned char *map, const char *name)
{
	FILE *f = fopen(name, "w+b");
	if(!f)
	{
		fprintf(stderr, "Failed to open map file for writing!\n");
		return -1;
	}

	if(fwrite(map, MAP_W, MAP_H, f) != MAP_H)
	{
		fprintf(stderr, "Error while saving map!\n");
		fclose(f);
		return -1;
	}

	fclose(f);

	printf("Map saved.\n");
	return 0;
}


/*------------------------------------------------
	Editor stuff
------------------------------------------------*/
const char *map_name = "demo.map";
int brushes[3] = { 0, 1, 2 };	/* One for each button... */
int drawing = -1;		/* Drawing what? (Brush index) */
int mousex, mousey;
int select_x, select_y;		/* Selector palette offset */

void edit_cursor(int select)
{
	int px, py;
	Uint32 color = video_map_rgb(255, 0, 255);
	SDL_Rect r;
	r.x = mousex;
	r.y = 0;
	r.w = 1;
	r.h = screen->h;
	video_fillrect(&r, color);
	r.x = 0;
	r.y = mousey;
	r.w = screen->w;
	r.h = 1;
	video_fillrect(&r, color);

	if(select)
	{
		px = (mousex - select_x) / (TILE_W+1) * (TILE_W+1) + select_x;
		py = (mousey - select_y) / (TILE_H+1) * (TILE_H+1) + select_y;
	}
	else
	{
		px = (mousex + (int)xpos) / TILE_W * TILE_W - (int)xpos;
		py = (mousey + (int)ypos) / TILE_H * TILE_H - (int)ypos;
	}
	switch((SDL_GetTicks() >> 6) & 3)
	{
	  case 0:
		r.x = px;
		r.y = py;
		r.w = TILE_W;
		r.h = 1;
		break;
	  case 1:
		r.x = px + TILE_W - 1;
		r.y = py;
		r.w = 1;
		r.h = TILE_H;
		break;
	  case 2:
		r.x = px;
		r.y = py + TILE_H - 1;
		r.w = TILE_W;
		r.h = 1;
		break;
	  case 3:
		r.x = px;
		r.y = py;
		r.w = 1;
		r.h = TILE_H;
		break;
	}
	video_fillrect(&r, color);
}


void edit_draw(void)
{
	int px, py;
	if(drawing < 0)
		return;
	if(drawing >= 3)
		return;
	px = (mousex + (int)xpos) / TILE_W;
	if(px >= MAP_W)
		return;
	py = (mousey + (int)ypos) / TILE_H;
	if(py >= MAP_H)
		return;
	map[py * MAP_W + px] = brushes[drawing];
}


void edit_palette(void)
{
	int x, y;
	SDL_Rect r;
	Uint32 color = video_map_rgb(64, 64, 64);
	r.x = 0;
	r.y = 0;
	r.w = screen->w;
	r.h = screen->h;
	video_fillrect(&r, color);
	select_x = (screen->w - PALETTE_TW * (TILE_W + 1)) / 2;
	select_y = (screen->h - PALETTE_TH * (TILE_H + 1)) / 2;
	select_x -= TILE_W;
	select_y -= TILE_H;
	if(select_x < 0)
		select_x = 2*select_x * mousex / screen->w;
	if(select_y < 0)
		select_y = 2*select_y * mousey / screen->h;
	select_x += TILE_W;
	select_y += TILE_H;
	for(y = 0; y < PALETTE_TH; ++y)
		for(x = 0; x < PALETTE_TW; ++x)
			video_draw_tile(select_x + x * (TILE_W+1),
					select_y + y * (TILE_H+1),
					y * PALETTE_TW + x);
}


void edit_select(void)
{
	while(1)
	{
		SDL_Event event;
		while(SDL_PollEvent(&event))
			switch(event.type)
			{
			  case SDL_MOUSEBUTTONDOWN:
			  {
				int px = (mousex - select_x) / (TILE_W + 1);
				int py = (mousey - select_y) / (TILE_W + 1);
				if(event.button.button > 3)
					break;
				if((px < 0) || (px >= PALETTE_TW) ||
						(py < 0) || (py >= PALETTE_TH))
					break;
				brushes[event.button.button - 1] =
						py * PALETTE_TW + px;
				break;
			  }
			  case SDL_MOUSEMOTION:
				mousex = event.motion.x / mscale;
				mousey = event.motion.y / mscale;
				break;
			  case SDL_KEYDOWN:
				switch(event.key.keysym.sym)
				{
				  case SDLK_SPACE:
				  case SDLK_ESCAPE:
					return;
				  default:
					break;
				}
				break;
			  case SDL_KEYUP:
				switch(event.key.keysym.sym)
				{
				  case SDLK_LCTRL:
				  case SDLK_RCTRL:
					return;
				  default:
					break;
				}
				break;
			  default:
				break;
			}
		edit_palette();
		edit_cursor(1);
		video_flip();
	}
}


void edit_event(SDL_Event *event)
{
	switch(event->type)
	{
	  case SDL_MOUSEBUTTONDOWN:
		mousex = event->button.x / mscale;
		mousey = event->button.y / mscale;
		drawing = event->button.button - 1;
		edit_draw();
		break;
	  case SDL_MOUSEBUTTONUP:
		drawing = -1;
		break;
	  case SDL_MOUSEMOTION:
		mousex = event->motion.x / mscale;
		mousey = event->motion.y / mscale;
		edit_draw();
		break;
	  case SDL_KEYDOWN:
		switch(event->key.keysym.sym)
		{
		  case SDLK_SPACE:
		  case SDLK_LCTRL:
		  case SDLK_RCTRL:
			edit_select();
			break;
		  case SDLK_s:
		  case SDLK_F2:
			save_map(map, map_name);
			break;
		  default:
			break;
		}
		break;
	  default:
		break;
	}
}


/*------------------------------------------------
	main
------------------------------------------------*/

int main(int argc, char* argv[])
{
	SDL_Event	event;
	Uint8		*keys;
	int		edit = 0;
	int		do_exit = 0;
	int		res, i;
	int		use_gl = 1;
	int		filter = 1;
	long		tick1, tick2;
	float		dt = 0.01;

	SDL_Init(SDL_INIT_VIDEO);
	atexit(SDL_Quit);

	flags |= SDL_FULLSCREEN;

	for(i = 1; i < argc; ++i)
	{
		if(strncmp(argv[i], "-sdl", 4) == 0)
			use_gl = 0;
		else if(strncmp(argv[i], "-gl", 3) == 0)
			use_gl = 1;
		else if(strncmp(argv[i], "-tf", 3) == 0)
			filter = 1;
		else if(strncmp(argv[i], "-ntf", 3) == 0)
			filter = 0;
		else if(strncmp(argv[i], "-f", 2) == 0)
			flags |= SDL_FULLSCREEN;
		else if(strncmp(argv[i], "-w", 2) == 0)
			flags &= ~SDL_FULLSCREEN;
		else if(strncmp(argv[i], "-s", 2) == 0)
			scale = atoi(&argv[i][2]);
		else if(strncmp(argv[i], "-e", 2) == 0)
			edit = 1;
		else if(strncmp(argv[i], "-m", 2) == 0)
		{
			++i;
			if(i >= argc)
			{
				fprintf(stderr, "'-m' must be followed by "
						"a file name!\n");
				exit(1);
			}
			map_name = argv[i];
		}
		else if(strncmp(argv[i], "-b", 2) == 0)
			bpp = atoi(&argv[i][2]);
		else
		{
			fprintf(stderr, "Unknown switch '%s'!\n", argv[i]);
			exit(1);
		}
	}

	if(edit)
	{
		if(scale < 0)
			scale = 1;
		mscale = 1;
		vscreen_w = SCREEN_W * scale;
		vscreen_h = SCREEN_H * scale;
	}
	else
	{
		if(use_gl)
		{
			if(scale < 0)
				scale = 2;
			mscale = scale;
			vscreen_w = SCREEN_W;
			vscreen_h = SCREEN_H;
		}
		else
		{
			if(scale < 0)
				scale = 1;
			mscale = 1;
			vscreen_w = SCREEN_W * scale;
			vscreen_h = SCREEN_H * scale;
		}
	}
	screen_w = SCREEN_W * scale;
	screen_h = SCREEN_H * scale;
	maxx = MAP_W * TILE_W - vscreen_w;
	maxy = MAP_H * TILE_H - vscreen_h;
	if(maxx < 0)
		maxx = 0;
	if(maxy < 0)
		maxy = 0;

	if(!use_gl && (scale != 1) && !edit)
		fprintf(stderr, "Warning: No scaling without OpenGL!\n");

	map = load_map(map_name);
	if(edit)
	{
		if(!map)
			map = new_map();
		if(!map)
			exit(1);
	}
	else if(!map)
		exit(1);

	flags |= SDL_DOUBLEBUF;

	if(use_gl)
		res = init_gl();
	else
		res = init_sdl();
	if(res < 0)
		exit(-1);

	if(use_gl)
		SDL_WM_SetCaption("OpenGL Smooth Scrolling", "SmoothScroll");
	else
		SDL_WM_SetCaption("Not All That Smooth Scrolling", "SmoothScroll");
	SDL_ShowCursor(0);

	if(edit)
		sx = sy = 0.0;

	gl_reset();
	keys = SDL_GetKeyState(&i);
	tick1 = SDL_GetTicks();
	while(!do_exit)
	{
		tick2 = SDL_GetTicks();
		if(filter)
			dt += ((tick2 - tick1) * 0.001f - dt) * 0.1;
		else
			dt = (tick2 - tick1) * 0.001f;
		tick1 = tick2;

		while(SDL_PollEvent(&event))
		{
			if(edit)
				edit_event(&event);
			else
				if(event.type == SDL_MOUSEBUTTONDOWN)
					do_exit = 1;
			if(keys[SDLK_ESCAPE])
			{
				do_exit = 1;
				break;
			}
			if(keys[SDLK_SPACE])
				sx = sy = 0.0;
		}

		if(edit)
		{
			if(keys[SDLK_UP] || (mousey < 10))
				ypos -= dt * 300.0;
			else if(keys[SDLK_DOWN] ||
					(mousey > screen_h - 10))
				ypos += dt * 300.0;

			if(keys[SDLK_LEFT] || (mousex < 10))
				xpos -= dt * 300.0;
			else if(keys[SDLK_RIGHT] ||
					(mousex > screen_w - 10))
				xpos += dt * 300.0;

			video_limit(dt);
		}
		else
		{
			if(keys[SDLK_UP])
				sy -= dt * 100.0;
			else if(keys[SDLK_DOWN])
				sy += dt * 100.0;

			if(keys[SDLK_LEFT])
				sx -= dt * 100.0;
			else if(keys[SDLK_RIGHT])
				sx += dt * 100.0;
			xpos += dt * sx;
			ypos += dt * sy;
			video_bounce(dt);
		}

		video_render();
		if(edit)
			edit_cursor(0);
		video_flip();
	}

	video_close();
	exit(0);
}
