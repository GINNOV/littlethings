/*
-----------------------------------------------------------
   visualize.h - Simple GGI based visualization library.
-----------------------------------------------------------
 * (C) 2000 David Olofson
 * Reologica Instruments AB
 */

/* TODO:

	* Keep track of controller button states

*/

#ifndef _VISUALIZE_H_
#define _VISUALIZE_H_

#ifdef __cplusplus
extern "C" {
#endif

#include "sgfx.h"
#include "control.h"

/*----------------------------------------------------------
	Standard colors
----------------------------------------------------------*/

#define VISCL_BLACK		0
#define VISCL_WHITE		1
#define VISCL_RED		2
#define VISCL_GREEN		3
#define VISCL_BLUE		4
#define VISCL_YELLOW		5
#define VISCL_GRAY25		6
#define VISCL_GRAY50		7
#define VISCL_GRAY		VISCL_GRAY50
#define VISCL_GRAY75		8
#define VISCL_CYAN		9
#define VISCL_PURPLE		10
#define VISCL_BROWN		11
#define VISCL_TEAL		12

#define	VISCL_3D_TEXT		16
#define	VISCL_3D_HIGHLIGHT	17
#define	VISCL_3D_LIGHT		18
#define	VISCL_3D_FACE		19
#define	VISCL_3D_DARK		20
#define	VISCL_3D_SHADOW		21

#define	VISCL_3DP_TEXT		22
#define	VISCL_3DP_HIGHLIGHT	23
#define	VISCL_3DP_LIGHT		24
#define	VISCL_3DP_FACE		25
#define	VISCL_3DP_DARK		26
#define	VISCL_3DP_SHADOW	27

#define	VISCL_SELECTFG		28
#define	VISCL_SELECTBG		29

/*
 * Color modification codes (for vg_context_t.XXX_cmod)
 */
#define VISCMOD_NONE		0	/* Normal */
#define VISCMOD_HALFBRIGHT	64	/* Halfbrite */
#if 0
#define VISCMOD_HIGHLIGHT	128	/* Hightlight */
#define VISCMOD_GRAY		192	/* Grayed out */
#endif

/*----------------------------------------------------------
	Rectangle
----------------------------------------------------------*/
typedef struct vis_rect_t
{
	int	x, y;
	int	w, h;
} vis_rect_t;

#define vis_shrink(r, amount)			\
{						\
	r.x += amount;				\
	r.y += amount;				\
	r.w -= amount<<1;			\
	r.h -= amount<<1;			\
}

#define vis_expand(a,b) vis_shrink((a),-(b))

static inline vis_rect_t vis_rect(int x, int y, int w, int h)
{
	vis_rect_t r;
	r.x = x;
	r.y = y;
	r.w = w;
	r.h = h;
	return r;
}

static inline int vis_is_inside(vis_rect_t rect, int x, int y)
{
	if(x<rect.x)
		return 0;
	if(y<rect.y)
		return 0;
	if(x>rect.x+rect.w)
		return 0;
	if(y>rect.y+rect.h)
		return 0;
	return 1;
}


/*----------------------------------------------------------
	Events
----------------------------------------------------------*/

typedef enum vis_events_t
{
	viseRelMove = 0,
	viseAbsMove,

	viseButtonDown,
	viseButtonRepeat,
	viseButtonUp,
	viseButtonDouble,
	viseButtonTriple,
	viseButtonQuadruple,

	viseKeyDown,
	viseKeyRepeat,
	viseKeyUp,

	viseRepaint,

	viseVTK_first = 1024,
	viseVTK_last = 2047,

	viseUser_first = 32768,
	viseUser_last = 65535
} vis_events_t;

/*
 * Absolute or Relative move for mice, MIDI and other controllers
 */
typedef struct
{
	int	x;
	int	y;
	int	z;	/* digitizer: force */
	int	w;	/* mouse: wheel */
} vis_event_move_t;

/*
 * Buttons on mice and other controllers
 */
enum
{
	VISBTN_NONE		= 0,
	VISBTN_LEFT		= 1,
	VISBTN_MIDDLE		= 2,
	VISBTN_RIGHT		= 3,
	VISBTN_WHEELUP		= 4,
	VISBTN_WHEELDOWN	= 5
};
typedef struct
{
	int		button;
	int		velocity;	/* Yeah, MIDI... :-) */
	int		force;		/* aftertouch */
	int		offset;		/* position on pad */
} vis_event_button_t;

/*
 * Keyboard events
 */
typedef struct
{
	vtk_control_t	control;	/* control code */
	unsigned short	modifiers;	/* modifier mask */
	unsigned short	unicode;	/* unicode from the current map */
} vis_key_t;

#define	VIS_EVENT_HEADER		\
	vis_events_t	kind;

typedef struct
{
	VIS_EVENT_HEADER;
	int		channel;
	union
	{
		vis_event_move_t	move;
		vis_event_button_t	button;
		vis_key_t		key;
		vis_rect_t		rect;
	} data;
} vis_event_t;


/*----------------------------------------------------------
	The "Visual" object
----------------------------------------------------------*/

typedef struct vis_visual_t
{
	struct vis_visual_t	*parent;
/* TODO
	struct vis_visual_t	*next;
	struct vis_visual_t	*children;
*/
	vis_rect_t		rect;
	sg_context_t		*context;
	int			is_window;

	void			*vis_private;

	vis_key_t		last_key;
	struct
	{
		int	x, y;
		int	buttons;
	} pointer;

	void (*on_resize)(struct vis_visual_t *visual);
} vis_visual_t;

static inline vis_visual_t *vis_kludge_get_parent(vis_visual_t *vis)
{
	/*
	 * Temporary kludge to deal with windows
	 */
	while(vis->parent)
		vis = vis->parent;
	return vis;
}

static inline int vis_button_down(vis_visual_t *vis, int btn)
{
	if(!vis)
		return 0;
	vis = vis_kludge_get_parent(vis);
	return (vis->pointer.buttons & (1<<btn)) != 0;
}


/*----------------------------------------------------------
	Open/close
----------------------------------------------------------*/
#define	VIS_FULLSCREEN	0x00000001
#define	VIS_BORDERLESS	0x00000002
#define	VIS_RESIZABLE	0x00000004

vis_visual_t *vis_open(int w, int h, int flags);
vis_visual_t *vis_open_window(vis_visual_t *parent, vis_rect_t rect);
void vis_close(vis_visual_t *visual);

/*----------------------------------------------------------
	Display management
----------------------------------------------------------*/
void vis_cls(vis_visual_t *visual);
void vis_refresh(vis_visual_t *visual);

void vis_invalidate(vis_visual_t *visual, vis_rect_t rect);
void vis_update(vis_visual_t *visual);

void vis_set_black_palette(vis_visual_t *visual);
void vis_set_white_palette(vis_visual_t *visual);

/*----------------------------------------------------------
	Window management
----------------------------------------------------------*/
void vis_move_window(vis_visual_t *window, vis_rect_t rect);


#if 0
/*----------------------------------------------------------
	Simple Input
----------------------------------------------------------*/
/*
 * Extension to the key codes; these bits can
 * be strapped onto the GII codes to pass the
 * extra information from the GII events as a
 * single int.
 */
#define VISK_KEY_MASK		0x0000ffff
#define VISK_KEY(k)		(k)
#define VISK_GET_KEY(k)		((k) & VISK_KEY_MASK)

#define VISK_KIND_MASK		0x000f0000
#define VISK_KIND(k)		((k)<<16)
#define VISK_GET_KIND(k)	(((k) & VISK_KIND_MASK)>>16)
#	define VISK_PRESS	0
#	define VISK_REPEAT	1
#	define VISK_RELEASE	2

#define VISK_MOD_MASK		0xfff00000
#define VISK_MOD(k)		((k)<<20)
#define VISK_GET_MOD(k)		(((k) & VISK_MOD_MASK)>>20)


int vis_key_present(vis_visual_t *visual);

/*
 * timeout in ms, -1 ==> block "forever", 0 ==> don't block
 *
 * NOTE: This will add bits above the 16 bit GII codes
 *       to signal repeat keys and key releases.
 *	 (See VISK_xxx.)
 */
int vis_get_key_all(vis_visual_t *visual, int timeout);

/*
 * Clean version, no extra bits, and no key releases.
 */
int vis_get_key(vis_visual_t *visual, int timeout);
#endif


/*----------------------------------------------------------
	Event Based Input (The Real Thing)
------------------------------------------------------------
 NOTE: Checking events on any window, or the root visual
       on the same GGI visual steals ALL events from the
       GGI visual. Visualize doesn't do any routing, since
       Visualize cannot know the desired semantics, states
       (focus, mouse capture) etc of the application or
       toolkit using the visuals.
*/

int vis_wait_event(vis_visual_t *visual, int timeout);

/*
 * Waits for an event on the specified visual. Times out
 * and returns 0 after <timeout> ms (0 means don't block
 * at all; -1 means wait forever), or returns , after
 * filling in the event struct.
 */
int vis_get_event(vis_visual_t *visual, vis_event_t *event, int timeout);

/*
 * Read tick counter. One tick corresponds to one ms.
 */
int vis_get_ticks();

#ifdef __cplusplus
};
#endif

#endif
