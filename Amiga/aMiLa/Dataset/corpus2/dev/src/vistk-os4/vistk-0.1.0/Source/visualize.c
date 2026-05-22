/*
-----------------------------------------------------------
   visualize.c - Simple GGI based visualization library.
-----------------------------------------------------------
 * (C) 2000 David Olofson
 * Reologica Instruments AB
 */

/*
TODO:
	* Refreshing of windows -> partial screen update
	
	* A visual should have a list of children visuals/windows
	
	* Virtual/offscreen windows; ie setting up the contexts properly.
	  x and y offsets are probably required as well...
*/

#define	DB(x)

#include <stdlib.h>
#include <string.h>

#include "visualize.h"


typedef struct __dirty_rect_t
{
	struct __dirty_rect_t	*next;
	vis_rect_t		rect;
} __dirty_rect_t;



#ifndef VISTK_USE_GGI
#ifndef VISTK_USE_SDL
#error You must define either VISTK_USE_GGI or VISTK_USE_SDL!
#endif
#endif

#ifdef VISTK_USE_GGI
#	include <ggi/ggi.h>
#endif
#ifdef VISTK_USE_SDL
#	include "SDL.h"
#endif

typedef struct
{
	__dirty_rect_t		*dirtyrects;
	int			rect_count;	/* Kludge... */
#ifdef VISTK_USE_GGI
 	ggi_visual_t		ggivis;
	ggi_mode		ggimode;	/* Huh? Why in here...!? */
#endif
#ifdef VISTK_USE_SDL
	SDL_Surface		*surface;
#endif
} __visual_private_t;

#ifdef VISTK_USE_GGI
#define __PRIV(x) ((__visual_private_t *)(x)->vis_private)
static inline ggi_visual_t *__VIS(vis_visual_t *v)
{
	__visual_private_t *p = __PRIV(v);
	return p->ggivis;
}
#endif
#ifdef VISTK_USE_SDL
#define __PRIV(x) ((__visual_private_t *)(x)->vis_private)
static inline SDL_Surface *__SURF(vis_visual_t *v)
{
	__visual_private_t *p = __PRIV(v);
	return p->surface;
}
#endif





#define	set3Dcolors						\
	setpalettecolor(VISCL_SELECTFG,		0, 0, 0);	\
	setpalettecolor(VISCL_SELECTBG,		63, 31, 0);	\
	setpalettecolor(VISCL_3D_TEXT,		63, 63, 60);	\
	setpalettecolor(VISCL_3D_HIGHLIGHT,	60, 55, 50);	\
	setpalettecolor(VISCL_3D_LIGHT,		50, 45, 40);	\
	setpalettecolor(VISCL_3D_FACE,		40, 35, 30);	\
	setpalettecolor(VISCL_3D_DARK,		25, 20, 15);	\
	setpalettecolor(VISCL_3D_SHADOW,	15, 10, 5);	\
	setpalettecolor(VISCL_3DP_TEXT,		60, 63, 63);	\
	setpalettecolor(VISCL_3DP_HIGHLIGHT,	50, 55, 60);	\
	setpalettecolor(VISCL_3DP_LIGHT,	40, 45, 50);	\
	setpalettecolor(VISCL_3DP_FACE,		30, 35, 40);	\
	setpalettecolor(VISCL_3DP_DARK,		15, 20, 25);	\
	setpalettecolor(VISCL_3DP_SHADOW,	5, 10, 15);

void vis_set_black_palette(vis_visual_t *visual)
{
#ifdef VISTK_USE_SDL
	SDL_Color pal[256];
#define setpalettecolor(_i,_r,_g,_b)			\
({							\
	pal[_i].r = (_r)<<2;				\
	pal[_i].g = (_g)<<2;				\
	pal[_i].b = (_b)<<2;				\
	pal[_i+VISCMOD_HALFBRIGHT].r = (_r)<<1;		\
	pal[_i+VISCMOD_HALFBRIGHT].g = (_g)<<1;		\
	pal[_i+VISCMOD_HALFBRIGHT].b = (_b)<<1;		\
})
#endif
#ifdef VISTK_USE_GGI
	ggi_color c;
#define setpalettecolor(_i,_r,_g,_b)			\
({							\
	c.r = (_r)<<10;					\
	c.g = (_g)<<10;					\
	c.b = (_b)<<10;					\
	ggiSetPalette(visual->ggivis, (_i), 1, &c);	\
	c.r >>= 1;					\
	c.g >>= 1;					\
	c.b >>= 1;					\
	ggiSetPalette(visual->ggivis, (_i+VISCMOD_HALFBRIGHT), 1, &c);	\
})
#endif
	setpalettecolor(VISCL_BLACK,	0, 0, 0);
	setpalettecolor(VISCL_WHITE,	63, 63, 63);
	setpalettecolor(VISCL_RED,	63, 0, 0);
	setpalettecolor(VISCL_GREEN,	0, 63, 0);
	setpalettecolor(VISCL_BLUE,	23, 23, 63);
	setpalettecolor(VISCL_YELLOW,	50, 50, 0);
	setpalettecolor(VISCL_GRAY25,	15, 15, 15);
	setpalettecolor(VISCL_GRAY50,	31, 31, 31);
	setpalettecolor(VISCL_GRAY75,	47, 47, 47);
	setpalettecolor(VISCL_CYAN,	0, 50, 50);
	setpalettecolor(VISCL_PURPLE,	50, 0, 63);
	setpalettecolor(VISCL_BROWN,	31, 15, 15);
	setpalettecolor(VISCL_TEAL,	0, 31, 31);

	set3Dcolors;
#undef setpalettecolor
#ifdef VISTK_USE_SDL
	SDL_SetColors(__SURF(visual), pal, 0, 256);
#endif
}

void vis_set_white_palette(vis_visual_t *visual)
{
#ifdef VISTK_USE_SDL
	SDL_Color pal[256];
#define setpalettecolor(_i,_r,_g,_b)			\
({							\
	pal[_i].r = (_r)<<2;				\
	pal[_i].g = (_g)<<2;				\
	pal[_i].b = (_b)<<2;				\
	pal[_i+VISCMOD_HALFBRIGHT].r = ((_r)<<1)+127;	\
	pal[_i+VISCMOD_HALFBRIGHT].g = ((_g)<<1)+127;	\
	pal[_i+VISCMOD_HALFBRIGHT].b = ((_b)<<1)+127;	\
})
#endif
#ifdef VISTK_USE_GGI
	ggi_color c;
#define setpalettecolor(_i,_r,_g,_b)			\
({							\
	c.r = (_r)<<10;					\
	c.g = (_g)<<10;					\
	c.b = (_b)<<10;					\
	ggiSetPalette(visual->ggivis, (_i), 1, &c);	\
	c.r >>= 1;					\
	c.g >>= 1;					\
	c.b >>= 1;					\
	c.r += 63<<9;					\
	c.g += 63<<9;					\
	c.b += 63<<9;					\
	ggiSetPalette(visual->ggivis, (_i+VISCMOD_HALFBRIGHT), 1, &c);	\
})
#endif
	setpalettecolor(VISCL_BLACK,	63, 63, 63);
	setpalettecolor(VISCL_WHITE,	0, 0, 0);
	setpalettecolor(VISCL_RED,	63, 0, 0);
	setpalettecolor(VISCL_GREEN,	0, 63, 0);
	setpalettecolor(VISCL_BLUE,	23, 23, 63);
	setpalettecolor(VISCL_YELLOW,	45, 45, 0);
	setpalettecolor(VISCL_GRAY25,	47, 47, 47);
	setpalettecolor(VISCL_GRAY50,	31, 31, 31);
	setpalettecolor(VISCL_GRAY75,	15, 15, 15);
	setpalettecolor(VISCL_CYAN,	0, 50, 50);
	setpalettecolor(VISCL_PURPLE,	50, 0, 63);
	setpalettecolor(VISCL_BROWN,	31, 15, 15);
	setpalettecolor(VISCL_TEAL,	0, 31, 31);

	set3Dcolors;
#undef setpalettecolor
#ifdef VISTK_USE_SDL
	SDL_SetColors(__SURF(visual), pal, 0, 256);
#endif
}


/*--------------------------------------------------------------------
	Open/close
--------------------------------------------------------------------*/

#ifdef VISTK_USE_GGI
static int open_visual(vis_visual_t *visual, const char *target)
{
	/* Open default visual */
	visual->ggivis = ggiOpen(target);
	if(!visual->ggivis)
	{
		fprintf(stderr, "visualize: Cannot open GGI visual!\n");
		return 0;
	}

	/* Set visual to async mode (drawing not immediate) */
	ggiSetFlags(visual->ggivis, GGIFLAG_ASYNC);

	ggiParseMode("640x480[8]", &visual->ggimode);
	visual->ggimode.visible.x = visual->rect.w;
	visual->ggimode.visible.y = visual->rect.h;
//	mode.frames = 2;

	if (ggiSetMode(visual->ggivis, &visual->ggimode))
	{
		fprintf(stderr, "visualize: Cannot set mode!\n");
		ggiClose(visual->ggivis);
		return 0;
	}

	visual->dirtyrect.x = visual->rect.w;
	visual->dirtyrect.y = visual->rect.h;
	visual->dirtyrect.w = -visual->rect.w;
	visual->dirtyrect.h = -visual->rect.h;

	return 1;
}

vis_visual_t *vis_open(int w, int h)
{
	char *vram;
	vis_visual_t *visual;

	visual = malloc(sizeof(vis_visual_t));
	memset(visual, 0, sizeof(vis_visual_t));
	vram = malloc(w*h);
	if(!vram || !visual)
	{
		perror("visualize: Cannot get memory!\n");
		free(vram);
		__free_visual(visual);
		return 0;
	}
	memset(vram, 0, w*h);
	visual->parent = 0;
	visual->rect = vis_rect(0, 0, w, h);

	visual->context = malloc(sizeof(sg_context_t));
	if(!visual->context)
	{
		perror("visualize: Cannot get memory for struct sg_context_t!\n");
		free(vram);
		__free_visual(visual);
		return 0;
	}

	/* Initialize libGGI */
	if(ggiInit())
	{
		fprintf(stderr, "visualize: Cannot initialize libGGI!\n");
		return 0;
	}

	if(!open_visual(visual, NULL))
	{
		fprintf(stderr, "visualize: Trying the palemu target...\n");
		if(!open_visual(visual, "palemu"))
		{
			ggiExit();
			return 0;
		}
	}

	vis_set_black_palette(visual);

	sg_init(visual->context, vram, 1, w, w, h);

	return visual;
}
#endif


static vis_visual_t *__alloc_visual()
{
	vis_visual_t *visual;
	visual = calloc(sizeof(vis_visual_t), 1);
	if(!visual)
		return NULL;
	visual->vis_private = (__visual_private_t *)
				calloc(sizeof(__visual_private_t), 1);
	if(!visual->vis_private)
	{
		free(visual);
		return NULL;
	}
	return visual;
}

static void __free_visual(vis_visual_t *visual)
{
	free(visual->vis_private);
	free(visual);
}


#ifdef VISTK_USE_SDL
vis_visual_t *vis_open(int w, int h, int flags)
{
	vis_visual_t *visual;
	int sdlflags = 	SDL_SWSURFACE | SDL_HWPALETTE;

	if(flags & VIS_FULLSCREEN)
		sdlflags |= SDL_FULLSCREEN;
	if(flags & VIS_BORDERLESS)
		sdlflags |= SDL_NOFRAME;
	if(flags & VIS_RESIZABLE)
		sdlflags |= SDL_RESIZABLE;

	visual = __alloc_visual();
	if(!visual)
	{
		perror("visualize: Cannot get memory!\n");
		return NULL;
	}
	visual->parent = NULL;
	visual->rect = vis_rect(0, 0, w, h);
/*
	visual->dirtyrect.x = visual->rect.w;
	visual->dirtyrect.y = visual->rect.h;
	visual->dirtyrect.w = -visual->rect.w;
	visual->dirtyrect.h = -visual->rect.h;
*/
	visual->context = calloc(sizeof(sg_context_t), 1);
	if(!visual->context)
	{
		perror("visualize: Cannot get memory for struct sg_context_t!\n");
		__free_visual(visual);
		return NULL;
	}

	/* Initialize SDL */
	if(SDL_Init(SDL_INIT_VIDEO) < 0)
	{
		fprintf(stderr, "visualize: Cannot initialize SDL!\n");
		free(visual->context);
		__free_visual(visual);
		return NULL;
	}

	__PRIV(visual)->surface = SDL_SetVideoMode(w, h, 8, sdlflags);
	if(!__SURF(visual))
	{
		SDL_Quit();
		free(visual->context);
		__free_visual(visual);
		return NULL;
	}

	SDL_EnableUNICODE(1);
	SDL_EnableKeyRepeat(200, 20);

	vis_set_black_palette(visual);

	sg_init(visual->context, __SURF(visual)->pixels,
			1, __SURF(visual)->pitch, w, h);
/*
printf("%p(%d) ", &visual->last_key, sizeof(visual->last_key));
printf("%p(%d): ", &visual->pointer, sizeof(visual->pointer));
printf("%p  ", &visual->pointer.x);
printf("%p  ", &visual->pointer.y);
printf("%p  ", &visual->pointer.dummy);
printf("%p\n", &visual->pointer.buttons);
*/
	return visual;
}
#endif

/*
FIXME: Resizable is broken; needs to store flags, palette etc... :-(
*/
void vis_resize(vis_visual_t *visual, int w, int h)
{
	__PRIV(visual)->surface = SDL_SetVideoMode(w, h, 8, SDL_RESIZABLE);
	visual->rect = vis_rect(0, 0, w, h);
	sg_init(visual->context, __SURF(visual)->pixels,
			1, __SURF(visual)->pitch, w, h);
	if(visual->on_resize)
		visual->on_resize(visual);
}

vis_visual_t *vis_open_window(vis_visual_t *parent, vis_rect_t rect)
{
	vis_visual_t *win;

	if(!parent)
	{
		fprintf(stderr, "visualize: No parent for window!\n");
		return 0;
	}

	if(!parent->context)
	{
		fprintf(stderr, "visualize: Parent has no drawing context!\n");
		return 0;
	}
	
	if(!parent->context->buffer)
	{
		fprintf(stderr, "visualize: Parent's drawing context has no buffer!\n");
		return 0;
	}
	
	win = __alloc_visual();
	if(!win)
	{
		perror("visualize: Cannot get memory for window!\n");
		return 0;
	}
	win->is_window = 1;
	win->parent = parent;
	win->rect = rect;
/*
	win->dirtyrect.x = win->rect.w;
	win->dirtyrect.y = win->rect.h;
	win->dirtyrect.w = -win->rect.w;
	win->dirtyrect.h = -win->rect.h;
*/
	win->context = malloc(sizeof(struct sg_context_t));
	if(!win->context)
	{
		perror("visualize: Cannot get memory for struct sg_context_t!\n");
		__free_visual(win);
		return 0;
	}

	sg_init_window(win->context, parent->context,
				rect.x, rect.y, rect.w, rect.h);

#ifdef VISTK_USE_GGI
	if(!parent->ggivis)
		fprintf(stderr, "visualize: warning: Parent has no GGI visual.\n");
	else
		win->ggivis = parent->ggivis;
#endif
#ifdef VISTK_USE_SDL
	if(!__SURF(win))
		fprintf(stderr, "visualize: warning: Parent has no SDL surface.\n");
	else
		__PRIV(win)->surface = __SURF(parent);
#endif
	return win;
}


void vis_close(vis_visual_t *visual)
{
	if(!visual)
		return;
	if(!visual->is_window)
	{
#ifdef VISTK_USE_GGI
		if(visual->ggivis)
		{
			ggiClose(visual->ggivis);
			ggiExit();
		}
		if(visual->context)
			free(visual->context->buffer);
#endif
#ifdef VISTK_USE_SDL
		if(__SURF(visual))
			SDL_Quit();
#endif
	}
	free(visual->context);
	__free_visual(visual);
}


/*--------------------------------------------------------------------
	Display management
--------------------------------------------------------------------*/

#ifdef VISTK_USE_GGI
void vis_refresh(vis_visual_t *visual)
{
	sg_context_t *vc;
	if(!visual)
		return;
	if(!visual->ggivis)
		return;
	vc = visual->context;
	if(!vc)
		return;
	ggiPutBox(visual->ggivis,
			vc->x, vc->y,
			vc->x + vc->w, vc->y + vc->h,
			vc->buffer);
	ggiFlushRegion(visual->ggivis,
			vc->x, vc->y,
			vc->x + vc->w, vc->y + vc->h);
	visual->dirtyrect.x = visual->rect.w;
	visual->dirtyrect.y = visual->rect.h;
	visual->dirtyrect.w = -visual->rect.w;
	visual->dirtyrect.h = -visual->rect.h;
}
#endif
#ifdef VISTK_USE_SDL
void vis_refresh(vis_visual_t *visual)
{
	if(!visual)
		return;
	if(!__SURF(visual))
		return;

	SDL_UpdateRect(__SURF(visual), 0, 0, 0, 0);

#ifdef VISTK_USE_SDL
	while(__PRIV(visual)->dirtyrects)
	{
		__dirty_rect_t *dr = __PRIV(visual)->dirtyrects;
		__PRIV(visual)->dirtyrects = dr->next;
		free(dr);
	}
#endif
/*
	visual->dirtyrect.x = visual->rect.w;
	visual->dirtyrect.y = visual->rect.h;
	visual->dirtyrect.w = -visual->rect.w;
	visual->dirtyrect.h = -visual->rect.h;
*/
}
#endif

void vis_update(vis_visual_t *visual)
{
#ifdef VISTK_USE_GGI
	sg_context_t *vc;
#endif
	if(!visual)
		return;

	if(__PRIV(visual)->rect_count > 100)
	{
		vis_refresh(visual);
		__PRIV(visual)->rect_count = 0;
		return;
	}

#ifdef VISTK_USE_GGI
	if(!visual->ggivis)
		return;
	vc = visual->context;
	if(!vc)
		return;
#endif
#ifdef VISTK_USE_SDL
	if(!__SURF(visual))
		return;
#endif

#ifdef VISTK_USE_SDL
	while(__PRIV(visual)->dirtyrects)
	{
		__dirty_rect_t *dr = __PRIV(visual)->dirtyrects;
		SDL_UpdateRect(__SURF(visual), dr->rect.x, dr->rect.y,
						dr->rect.w, dr->rect.h);
		__PRIV(visual)->dirtyrects = dr->next;
		free(dr);
	}
#endif

#if 0
	/*
	 * dirtyrect off-screen
	 */
	if(visual->dirtyrect.x >= visual->rect.w)
		return;
	if(visual->dirtyrect.y >= visual->rect.h)
		return;
	if(visual->dirtyrect.x + visual->dirtyrect.w < 0)
		return;
	if(visual->dirtyrect.y + visual->dirtyrect.h < 0)
		return;
	/*
	 * dirtyrect clipping
	 */
	if(visual->dirtyrect.x < 0)
		visual->dirtyrect.x = 0;
	if(visual->dirtyrect.y < 0)
		visual->dirtyrect.y = 0;
	if(visual->dirtyrect.w > visual->rect.w - visual->dirtyrect.x)
		visual->dirtyrect.w = visual->rect.w - visual->dirtyrect.x;
	if(visual->dirtyrect.y > visual->rect.h - visual->dirtyrect.y)
		visual->dirtyrect.h = visual->rect.h - visual->dirtyrect.y;

#ifdef VISTK_USE_SDL
/*visual->context->pen.fgcolor = rand() % 10;
sg_box(visual->context,
			visual->dirtyrect.x,
			visual->dirtyrect.y,
			visual->dirtyrect.x+visual->dirtyrect.w-1,
			visual->dirtyrect.y+visual->dirtyrect.h-1	);
*/
	DB(printf("ud(%d,%d,%d,%d)\n",
			visual->dirtyrect.x,
			visual->dirtyrect.y,
			visual->dirtyrect.w,
			visual->dirtyrect.h	));
	SDL_UpdateRect(__SURF(visual),
			visual->dirtyrect.x,
			visual->dirtyrect.y,
			visual->dirtyrect.w,
			visual->dirtyrect.h	);
#endif
#ifdef VISTK_USE_GGI
	ggiPutBox(visual->ggivis,
			vc->x + visual->dirtyrect.x,
			vc->y + visual->dirtyrect.y,
			vc->x + visual->dirtyrect.x + visual->dirtyrect.w,
			vc->y + visual->dirtyrect.y + visual->dirtyrect.h,
			vc->buffer);
	ggiFlushRegion(visual->ggivis,
			vc->x + visual->dirtyrect.x,
			vc->y + visual->dirtyrect.y,
			vc->x + visual->dirtyrect.x + visual->dirtyrect.w,
			vc->y + visual->dirtyrect.y + visual->dirtyrect.h);
#endif
	visual->dirtyrect.x = visual->rect.w;
	visual->dirtyrect.y = visual->rect.h;
	visual->dirtyrect.w = -visual->rect.w;
	visual->dirtyrect.h = -visual->rect.h;
#endif

	__PRIV(visual)->rect_count = 0;
}

void vis_invalidate(vis_visual_t *visual, vis_rect_t rect)
{
#ifdef VISTK_USE_SDL
	__dirty_rect_t *dr;
#endif
	if(!visual)
		return;

	/*
	 * off-screen
	 */
	if(rect.x >= visual->rect.w)
		return;
	if(rect.y >= visual->rect.h)
		return;
	if(rect.x + visual->rect.w < 0)
		return;
	if(rect.y + visual->rect.h < 0)
		return;

#ifdef VISTK_USE_SDL
	dr = malloc(sizeof(__dirty_rect_t));
	if(!dr)
		return;
	if(rect.x < 0)
		rect.x = 0;
	if(rect.y < 0)
		rect.y = 0;
	if(rect.x + rect.w > visual->rect.w)
		rect.w = visual->rect.w - rect.x;
	if(rect.y + rect.h > visual->rect.h)
		rect.h = visual->rect.h - rect.y;
	dr->rect = rect;
	dr->next = __PRIV(visual)->dirtyrects;
	__PRIV(visual)->dirtyrects = dr;
	++(__PRIV(visual)->rect_count);
#endif

/*
	if(visual->dirtyrect.x > rect.x)
	{
		visual->dirtyrect.w += visual->dirtyrect.x - rect.x;
		visual->dirtyrect.x = rect.x;
	}
	if(visual->dirtyrect.y > rect.y)
	{
		visual->dirtyrect.h += visual->dirtyrect.y - rect.h;
		visual->dirtyrect.y = rect.y;
	}

	if(visual->dirtyrect.w < rect.w + rect.x - visual->dirtyrect.x)
		visual->dirtyrect.w = rect.w + rect.x - visual->dirtyrect.x;
	if(visual->dirtyrect.h < rect.h + rect.y - visual->dirtyrect.y)
		visual->dirtyrect.h = rect.h + rect.y - visual->dirtyrect.y;
*/
}

void vis_cls(vis_visual_t *visual)
{
	if(!visual)
		return;
	memset(visual->context->buffer, 0,
			visual->context->w*visual->context->h);
	vis_refresh(visual);
}


/*--------------------------------------------------------------------
	Window management
--------------------------------------------------------------------*/

void vis_move_window(vis_visual_t *window, vis_rect_t rect)
{
	if(!window)
		return;
	window->rect = rect;
	if(!window->context)
		return;
	if(!window->parent)
		return;
	if(!window->parent->context)
		return;
	window->context->buffer = window->parent->context->buffer
			+ window->context->pitch * rect.y + rect.x;
}


#if 0
/*--------------------------------------------------------------------
	Input
--------------------------------------------------------------------*/
int vis_key_present(vis_visual_t *visual)
{
	struct timeval tv = {0,0};
	if(!visual)
		return 0;
	visual = vis_kludge_get_parent(visual);
	if(!visual->ggivis)
		return 0;
	return (ggiEventPoll(visual->ggivis, emKeyboard, &tv) != emZero);
}

int vis_get_key_all(vis_visual_t *visual, int timeout)
{
	int c = GIIK_VOID;
	ggi_event event;
	struct timeval tv;
	struct timeval *tvp;

	if(!visual)
		return 0;
	visual = vis_kludge_get_parent(visual);
	if(!visual->ggivis)
		return 0;

	if(timeout != -1)
	{
		timeout *= 1000;	/* ms s-> us */
		tv.tv_sec = timeout / 1000000;
		tv.tv_usec = timeout % 1000000;
		tvp = &tv;
	}
	else
		tvp = 0;

	if(ggiEventPoll(visual->ggivis, emKeyboard, tvp))
	{
		ggiEventRead(visual->ggivis, &event, emKeyboard);
		c = event.key.sym;
		c |= VISK_MOD(event.key.modifiers);
		switch(event.any.type)
		{
		  case evKeyPress:
			c |= VISK_KIND(VISK_PRESS);
		  	break;
		  case evKeyRepeat:
		  	c |= VISK_KIND(VISK_REPEAT);
		  	break;
		  case evKeyRelease:
		  	c |= VISK_KIND(VISK_RELEASE);
		  	break;
		}
		visual->last_key = c;
	}

	return c;
}

int vis_get_key(vis_visual_t *visual, int timeout)
{
	int c;
	while(1)
	{
		c = vis_get_key_all(visual, timeout);
		if(c == GIIK_VOID)
			return c;	/* Timeout! */
		switch(VISK_GET_KIND(c))
		{
		  case VISK_PRESS:
			return VISK_GET_KEY(c);
		  case VISK_REPEAT:
			return VISK_GET_KEY(c);
		  case VISK_RELEASE:
		  	/* Ignored; try again... */
		  	break;
		}
	}
}
#endif


/*----------------------------------------------------------
	Event Based Input (The Real Thing)
----------------------------------------------------------*/

static inline void _button_down(vis_visual_t *vis, int btn)
{
	if(btn>32)
		return;
	vis->pointer.buttons |= (1<<btn);
}

static inline void _button_up(vis_visual_t *vis, int btn)
{
	if(btn>32)
		return;
	vis->pointer.buttons &= ~(1<<btn);
}

#ifdef VISTK_USE_GGI
int vis_wait_event(vis_visual_t *visual, int timeout)
{
	struct timeval tv;
	struct timeval *tvp;

	if(!visual)
		return 0;
	visual = vis_kludge_get_parent(visual);
	if(!visual->ggivis)
		return 0;

	if(timeout != -1)
	{
		timeout *= 1000;	/* ms s-> us */
		tv.tv_sec = timeout / 1000000;
		tv.tv_usec = timeout % 1000000;
		tvp = &tv;
	}
	else
		tvp = 0;

	return (ggiEventPoll(visual->ggivis, emAll, tvp) != emZero);
}

int vis_get_event(vis_visual_t *visual, vis_event_t *event, int timeout)
{
	ggi_event giievent;
	struct timeval tv;
	struct timeval *tvp;

	if(!visual)
		return 0;
	visual = vis_kludge_get_parent(visual);
	if(!visual->ggivis)
		return 0;

	if(timeout != -1)
	{
		timeout *= 1000;	/* ms s-> us */
		tv.tv_sec = timeout / 1000000;
		tv.tv_usec = timeout % 1000000;
		tvp = &tv;
	}
	else
		tvp = 0;

	if(ggiEventPoll(visual->ggivis, emAll, tvp))
	{
		ggiEventRead(visual->ggivis, &giievent, emAll);
		DB(printf("Got ");)
		switch(giievent.any.type)
		{
		  case evCommand:
			DB(printf("evCommand\n");)
		  	break;

		  case evPtrRelative:
			event->kind = viseRelMove;
			event->channel = 0;
			event->data.move.x = giievent.pmove.x;
			event->data.move.y = giievent.pmove.y;
			event->data.move.z = giievent.pmove.z;
			event->data.move.w = giievent.pmove.wheel;
			DB(printf("evPtrRelative: x=%d, y=%d, z=%d, w=%d\n",
			event->data.move.x,
			event->data.move.y,
			event->data.move.z,
			event->data.move.w);)
			return 1;

		  case evPtrAbsolute:
			event->kind = viseAbsMove;
			event->channel = 0;
			event->data.move.x = giievent.pmove.x;
			event->data.move.y = giievent.pmove.y;
			visual->pointer.x = giievent.pmove.x;
			visual->pointer.y = giievent.pmove.y;
			if(visual->is_window)
			{
				event->data.move.x -= visual->rect.x;
				event->data.move.y -= visual->rect.y;
			}
			event->data.move.z = giievent.pmove.z;
			event->data.move.w = giievent.pmove.wheel;
			DB(printf("evPtrAbsolute: x=%d, y=%d, z=%d, w=%d\n",
			event->data.move.x,
			event->data.move.y,
			event->data.move.z,
			event->data.move.w);)
			return 1;

		  case evValRelative:
			DB(printf("evValRelative\n");)
//			event->kind = viseRelMove;
//			event->channel = 0;
//			return event;
			break;

		  case evValAbsolute:
			DB(printf("evValAbsolute\n");)
//			event->kind = viseAbsMove;
//			event->channel = 0;
//			return event;
			break;

		  case evPtrButtonPress:
			event->kind = viseButtonDown;
			event->channel = 0;
			event->data.button.button = giievent.pbutton.button;
			event->data.button.velocity = 0x40000000;
			event->data.button.force = 0x40000000;
			event->data.button.offset = 0;
			_button_down(visual, event->data.button.button);
			DB(printf("evPtrButtonPress: button=%d\n",
					event->data.button.button);)
			return 1;

		  case evPtrButtonRelease:
			event->kind = viseButtonUp;
			event->channel = 0;
			event->data.button.button = giievent.pbutton.button;
			event->data.button.velocity = 0x40000000;
			event->data.button.force = 0x40000000;
			event->data.button.offset = 0;
			_button_up(visual, event->data.button.button);
			DB(printf("evPtrButtonRelease: button=%d\n",
					event->data.button.button);)
			return 1;

		  case evKeyPress:
			DB(printf("evKeyPress\n");)
			event->kind = viseKeyDown;
			event->channel = 0;
			event->data.key.code = giievent.key.sym;
			event->data.key.modifiers =  giievent.key.modifiers;
			if(GII_UNICODE(giievent.key.sym))
				event->data.key.ascii = GII_KVAL(giievent.key.sym);
			else
				event->data.key.ascii = 0;
			visual->last_key = event->data.key.code
					| VISK_MOD(event->data.key.modifiers);
			return 1;

		  case evKeyRepeat:
			DB(printf("evKeyRepeat\n");)
			event->kind = viseKeyRepeat;
			event->channel = 0;
			event->data.key.code = giievent.key.sym;
			event->data.key.modifiers =  giievent.key.modifiers;
			if(GII_UNICODE(giievent.key.sym))
				event->data.key.ascii = GII_KVAL(giievent.key.sym);
			else
				event->data.key.ascii = 0;
			visual->last_key = event->data.key.code
					| VISK_MOD(event->data.key.modifiers);
			return 1;

		  case evKeyRelease:
			DB(printf("evKeyRelease\n");)
			event->kind = viseKeyUp;
			event->channel = 0;
			event->data.key.code = giievent.key.sym;
			event->data.key.modifiers =  giievent.key.modifiers;
			if(GII_UNICODE(giievent.key.sym))
				event->data.key.ascii = GII_KVAL(giievent.key.sym);
			else
				event->data.key.ascii = 0;
			visual->last_key = event->data.key.code
					| VISK_MOD(event->data.key.modifiers);
			return 1;
		}
	}
	return 0;
}

int vis_get_ticks()
{
	fprintf(stderr, "vis_get_ticks() not implemented for GGI!\n");
	return 0;
}

#endif

#ifdef VISTK_USE_SDL
int vis_wait_event(vis_visual_t *visual, int timeout)
{
	int t1;
	if(!visual)
		return 0;

	visual = vis_kludge_get_parent(visual);

	switch(timeout)
	{
	  case -1:
		return SDL_WaitEvent(NULL);
	  case 0:
		return SDL_PollEvent(NULL);
	  default:
		t1 = SDL_GetTicks() + timeout;
		while(SDL_GetTicks() < t1)
			if(SDL_PollEvent(NULL))
				return 1;

		return 0;
	}
}

/*
FIXME: This should be user configurable.
*/
static int __sdl2ctrl(SDL_keysym *ks)
{
	switch(ks->sym)
	{
	  case SDLK_BACKSPACE:	return VTKC_BACKSPACE;
	  case SDLK_DELETE:	return VTKC_DELETE;
	  case SDLK_INSERT:	return VTKC_INSERT;
	  case SDLK_CLEAR:	return VTKC_CLEAR;
	  case SDLK_RETURN:
	  case SDLK_KP_ENTER:
		return VTKC_ENTER;
	  case SDLK_ESCAPE:	return VTKC_ESCAPE;

	  case SDLK_PAUSE:	return VTKC_PAUSE;
	  case SDLK_HELP:	return VTKC_HELP;
	  case SDLK_PRINT:	return VTKC_PRINT;
	  case SDLK_SYSREQ:	return VTKC_SYSREQ;
	  case SDLK_BREAK:	return VTKC_BREAK;
	  case SDLK_MENU:	return VTKC_MENU;

	  case SDLK_UP:		return VTKC_UP;
	  case SDLK_DOWN:	return VTKC_DOWN;
	  case SDLK_RIGHT:	return VTKC_RIGHT;
	  case SDLK_LEFT:	return VTKC_LEFT;
	  case SDLK_TAB:
		if(ks->mod & KMOD_SHIFT)
			return VTKC_RETREAT;
		else
			return VTKC_ADVANCE;
	  case SDLK_HOME:	return VTKC_HOME;
	  case SDLK_END:	return VTKC_END;
	  case SDLK_PAGEUP:
		if(ks->mod & KMOD_SHIFT)
			return VTKC_FIRST;
		else
			return VTKC_PREV;
	  case SDLK_PAGEDOWN:
		if(ks->mod & KMOD_SHIFT)
			return VTKC_NEXT;
		else
			return VTKC_LAST;

	  case SDLK_F1:		return VTKC_F1;
	  case SDLK_F2:		return VTKC_F2;
	  case SDLK_F3:		return VTKC_F3;
	  case SDLK_F4:		return VTKC_F4;
	  case SDLK_F5:		return VTKC_F5;
	  case SDLK_F6:		return VTKC_F6;
	  case SDLK_F7:		return VTKC_F7;
	  case SDLK_F8:		return VTKC_F8;
	  case SDLK_F9:		return VTKC_F9;
	  case SDLK_F10:	return VTKC_F10;
	  case SDLK_F11:	return VTKC_F11;
	  case SDLK_F12:	return VTKC_F12;
	  case SDLK_F13:	return VTKC_F13;
	  case SDLK_F14:	return VTKC_F14;
	  case SDLK_F15:	return VTKC_F15;

	  default:
		return VTKC_NONE;
	}
}

static int __sdl2mod(SDL_keysym *ks)
{
	int ret = 0;
	if(ks->mod & KMOD_SHIFT)
		ret |= VTKCM_SHIFT;
	if(ks->mod & KMOD_CTRL)
		ret |= VTKCM_CTRL;
	if(ks->mod & KMOD_ALT)
		ret |= VTKCM_ALT;
	if(ks->mod & KMOD_META)
		ret |= VTKCM_META;
	if(ks->mod & KMOD_MODE)
		ret |= VTKCM_MODE;
	return ret;
}

static int __sdl2btn(SDL_MouseButtonEvent *mbe)
{
	return mbe->button;
}

int vis_get_event(vis_visual_t *visual, vis_event_t *event, int timeout)
{
	SDL_Event sdlev;

	if(!visual)
		return 0;

	visual = vis_kludge_get_parent(visual);

	if(!vis_wait_event(visual, timeout))
		return 0;

	if(SDL_PollEvent(&sdlev))
	{
		switch(sdlev.type)
		{
		  case SDL_MOUSEMOTION:
			event->kind = viseAbsMove;
			event->channel = 0;
			event->data.move.x = sdlev.motion.x;
			event->data.move.y = sdlev.motion.y;
			visual->pointer.x = sdlev.motion.x;
			visual->pointer.y = sdlev.motion.y;
			if(visual->is_window)
			{
				event->data.move.x -= visual->rect.x;
				event->data.move.y -= visual->rect.y;
			}
			event->data.move.z = 0;
			event->data.move.w = 0;
			return 1;

		  case SDL_MOUSEBUTTONDOWN:
			event->kind = viseButtonDown;
			event->channel = 0;
			event->data.button.button = __sdl2btn(&sdlev.button);
			event->data.button.velocity = 0x40000000;
			event->data.button.force = 0x40000000;
			event->data.button.offset = 0;
			_button_down(visual, event->data.button.button);
			return 1;

		  case SDL_MOUSEBUTTONUP:
			event->kind = viseButtonUp;
			event->channel = 0;
			event->data.button.button = __sdl2btn(&sdlev.button);
			event->data.button.velocity = 0x40000000;
			event->data.button.force = 0x40000000;
			event->data.button.offset = 0;
			_button_up(visual, event->data.button.button);
			return 1;

		  case SDL_KEYDOWN:
			event->kind = viseKeyDown;
			event->channel = 0;
			event->data.key.control = __sdl2ctrl(&sdlev.key.keysym);
			event->data.key.modifiers =  __sdl2mod(&sdlev.key.keysym);
			event->data.key.unicode = sdlev.key.keysym.unicode;
			visual->last_key = event->data.key;
			return 1;

		  case SDL_KEYUP:
			event->kind = viseKeyUp;
			event->channel = 0;
			event->data.key.control = __sdl2ctrl(&sdlev.key.keysym);
			event->data.key.modifiers =  __sdl2mod(&sdlev.key.keysym);
			event->data.key.unicode = sdlev.key.keysym.unicode;
			visual->last_key = event->data.key;
			return 1;

		  case SDL_VIDEORESIZE:
			vis_resize(visual, sdlev.resize.w, sdlev.resize.h);
			return 0;
		}
	}
	return 0;
}

int vis_get_ticks()
{
	return SDL_GetTicks();
}
#endif
