/*
-----------------------------------------------------------
   vistk.h - The "Visualize" Toolkit library
-----------------------------------------------------------
 * (C) 2000 David Olofson
 * Reologica Instruments AB
 */

/*
FIXME:	* Finish window support.
FIXME:
FIXME:	* Implement Tk style relative/scaled coordinates.
FIXME:	  Possibly remove the center/left/right alignment
FIXME:	  stuff, since it's not needed if something like
FIXME:	  this is used.
FIXME:
FIXME:	* The alignment should probable work the other
FIXME:	  way around after all. The stacking features can
FIXME:	  be seen as just another alignment switch, like
FIXME:	  left, right, center etc, only stacked objects
FIXME:	  care about not overlapping other objects on the
FIXME:	  same parent.
FIXME:
FIXME:	  As other things may get in the way, and as there
FIXME:	  will be multiple stacking cursors, full collision
FIXME:	  checking should be done for every object.
FIXME:
FIXME:	* The stacking cursor should be related to the
FIXME:	  objects according to the alignment settings of
FIXME:	  the container, NOT fixed to top-left!
FIXME:
FIXME:	* Implement the alignment system fully
FIXME:	  Note: The VA_SIZE_xxx stuff breaks the semantics!
FIXME:	        Some bits affect the *object*, rather than
FIXME:		it's children...
*/


/*----------------------------------------------------------
	The basics of VTK
------------------------------------------------------------

VTK is an object oriented GUI toolkit designed for (in
approximate order of priority):

	1. Easy to use API
	2. Rendering speed
	3. Rendering semantics flexibility
	4. GUI flexibility
	5. System requirements
	6. Portability


Structure
---------
The central data type is vtk_object_t, which is a common
structure used for all kinds of visual objects. Fundamental
object kinds are:

	vtkoRoot:	A full screen or a window. A root
			objects has it's own visual for
			rendering; either a real visual,
			connected to a real rendering target,
			or a context describing a part of
			a rendering target, ie a window.

	vtkoContainer:	Invisible alignment container.
			This is a logic object that never
			produces visual output. The point
			is that it allows building multiple
			level nested alignment structures,
			allowing very flexible dynamic
			layouts.

	vtkoPanel:	Visible panel container. Basically
			a container that also renders as a
			surface with 3I beveled edges.			

	vtkoWindow:	Floating window. Basically a
			Panel with various objects that
			enable the user to move, drag,
			hide,... the window. It also
			contains a Root object that
			represents the workspace area of
			the window, ie where the contents
			are rendered.

Every object has a coordinate system of it's own, with origo
usually being in the top-left corner of the object. A Root
object has it's own target visual, and therefore clips at
it's bounding rectangle. The other kinds of objects clip
only an the bounding rectangle of the closest Root object
above them in the hierarchy.

(Technical version: At rethink time, an object gives all of
it's non-Root children it's own target visual, while Root
objects get their target visuals at initialization time.)


Semantics
---------
The first step in using VTK is to create a Root object that
renders to the desired target. The rendering target and a
vis_rect_t indicating the position and size of the Root
object, are passed as arguments to vtk_new_root(), which
returns your Root object, or NULL if there was a problem.

The next function you'll use is probably vtk_new(). This
takes an object (your Root object, for instance) to use as
parent, a vis_rect_t indicating the position and size inside
the parent, and the kind of object to create as arguments.
The return is the new object, connected and ready, or NULL
if there's a problem.

You may need overlapping windows in your application. A
window can be the child of any object, which opens up quite
a few interesting (and lots of weird...) possibilities. To
create a Window, use the vtk_new_window() function. It takes
a parent and a vis_rect_t as arguments, and returns, guess
what... The Window object! (Or NULL, if things went wrong.)

Objects can be connected to event handlers to deal with
user I/O. Use the event_handler field for this. VTK will
deal with mouse capture, focus and that kind of things.

You may also connect event handlers to event_hook. This is
a way to bypass the normal event routing, so that you can
preview (and if you want, steal) all events before they
reach the children of the object the hook handler is
connected to. May be useful for special tricks, but should
not be used in the normal case.

When you GUI has been constructed, it's time to run the
layout engine in order to give physical coordinates to all
objects. This is done with a call to vtk_rethink(), which
takes an object (makes most sense with a container...) as
it's only argument. Note that this won't affect the logic
coordinates (rect), alignment flags or any other
"description" data - the physical info is stored elsewhere.

Now, it's time to render the GUI to the display target.
This is done with vtk_render(), which also takes an object
as it's single argument. This object may be the Root, or
any other object for partial rendering.

Finally, when you're done, and wish to remove all objects,
just pass the Root object to vtk_free(). vtk_free() can
also be used to erase only parts of a GUI; it actually
disconnects and deletes any object you pass to it, and
recursively does the same with all children.

*/


#ifndef _VTK_H_
#define _VTK_H_

#ifdef __cplusplus
extern "C" {
#endif

#include "visualize.h"

struct vtk_object_t;
struct vtk_rect_t;
struct vtk_colorspec_t;
struct vtk_value_t;


/*----------------------------------------------------------
	Alignment
----------------------------------------------------------*/
#define	VA_NONE			0x00000000
/*
 * Alignment of contents or children
 *
 *	LEFT + RIGHT = center horiz,
 *	TOP + BOTTOM = center vert
 *	(Child coords are used for sorting order)
 *
 *	none = use default or child coords.
 */
#define	VA_ALIGN_		0x0000000f
#define	VA_ALIGN_NONE		0
#define	VA_ALIGN_LEFT		0x00000001
#define	VA_ALIGN_RIGHT		0x00000002
#define _VA_ALIGN_HCENTER	(VA_ALIGN_LEFT | VA_ALIGN_RIGHT)
#define	VA_ALIGN_TOP		0x00000004
#define	VA_ALIGN_BOTTOM		0x00000008
#define _VA_ALIGN_VCENTER	(VA_ALIGN_TOP | VA_ALIGN_BOTTOM)
#define _VA_ALIGN_CENTER	(_VA_ALIGN_HCENTER | _VA_ALIGN_VCENTER)


/*
 * Stacking control
 *
 *	Setting bits indicating opposite directions
 *	result in alternation between those directions,
 *	ie building around the first object.
 */
#define	VA_STACK_		0x000000f0
#define	VA_STACK_NONE		0
#define	VA_STACK_LEFT		0x00000010
#define	VA_STACK_RIGHT		0x00000020
#define	_VA_STACK_HALTERNATE	(VA_STACK_LEFT | VA_STACK_RIGHT)
#define	VA_STACK_UP		0x00000040
#define	VA_STACK_DOWN		0x00000080
#define	_VA_STACK_VALTERNATE	(VA_STACK_UP | VA_STACK_DOWN)
#define	_VA_STACK_ALTERNATE	(_VA_STACK_HALTERNATE | _VA_STACK_VALTERNATE)


/*
 * Wrapping control
 *
 *	Answers the question "What to do when stacking,
 *      and the bounding rectangle of the container is
 *      crossed?"
 */
#define VA_WRAP_		0x00000f00
#define VA_WRAP_NONE		0
#define VA_WRAP_LEFT		0x00000100
#define VA_WRAP_RIGHT		0x00000200
#define _VA_WRAP_HALTERNATE	(VA_WRAP_LEFT | VA_WRAP_RIGHT)
#define VA_WRAP_UP		0x00000400
#define VA_WRAP_DOWN		0x00000800
#define _VA_WRAP_VALTERNATE	(VA_WRAP_UP | VA_WRAP_DOWN)
#define _VA_WRAP_ALTERNATE	(_VA_WRAP_HALTERNATE | _VA_WRAP_VALTERNATE)


/*
 * Pack objects when wrapping, rather than working only
 * with the largest object of the previous row.
 */
#define VA_PACK_		0x0000f000
#define	VA_PACK_NONE		0
#define VA_PACK_SIMPLE		0x00001000


/*
 * Autosize this rect to minimum to fit contents
 * or children
 *
 * Note: VA_SIZE_AUTO_V/H will behave in not so obvious ways
 *       together with VA_WRAP_xxx. The container's
 *       original size will be tuned *after* aligning the
 *       children, resulting in a kind of snap-to-child
 *       effect.
 */
#define VA_SIZE_		0x000f0000
#define	VA_SIZE_NONE		0
#define VA_SIZE_AUTO_H		0x00010000
#define VA_SIZE_AUTO_V		0x00020000


/*----------------------------------------------------------
	State
----------------------------------------------------------*/
#define	VS_ENABLED	0x0000001
#define	VS_VISIBLE	0x0000002
#define	VS_SELECTED	0x0000004
#define	VS_FOCUSED	0x0000008
#define	VS_CAPTURE	0x0000010
#define	VS_SOFT_FOCUS	0x0000020


/*----------------------------------------------------------
	Object flags
----------------------------------------------------------*/
#define VOF_CAN_FOCUS		0x0000001
#define VOF_CAN_CAPTURE		0x0000002


/*----------------------------------------------------------
	Render Flags
----------------------------------------------------------*/
#define	VRF_CLIP_		0x00000ff
#define	VRF_CLIPPED		0x0000001
#define	VRF_HIDDEN		0x0000002
#define	VRF_OVERLAPPED		0x0000004
/* Assume that this object and it's children won't draw
 * outside the object. This allows the rendering engine to
 * disregard the entire object with children if it's rect is
 * outside the clipping rectangle of the target visual. */
#define	VRF_ASSUME_CLIPPED	0x0000100
#define	VRF_UPDATE		0x0001000


/*----------------------------------------------------------
	Color specification
----------------------------------------------------------*/
typedef struct vtk_colorspec_t
{
	/* Basic */
	char	text;
	char	back;
	char	cursor_text;
	char	cursor_back;
	/* Selection */
	char	mark_text;
	char	mark_back;
	/* 3D (gradient) */
	char	shadow_3D;
	char	dark_3D;
	char	face_3D;
	char	light_3D;
	char	highlight_3D;
	/* 3D text and selection */
	char	text_3D;
	char	mark_text_3D;
	char	mark_back_3D;
} vtk_colorspec_t;


/*----------------------------------------------------------
	Value
----------------------------------------------------------*/
typedef struct vtk_value_t
{
	double	value;
	double	max;
	double	min;
	char	*text;	/* ptr to text buffer */
	int	size;	/* size of text buffer */
	int	end;	/* end of text */
} vtk_value_t;

/*
 * Event handler callback
 *
 * Return 1 to "eat" the event, so that it doesn't fall through
 * to objects under us, 0 to let the event pass on. (Useful for
 * objects with non-rectangular active zones, and objects not
 * treating their full bounding rects as active.)
 *
 * The default action (taken if the pointer is NULL) for the
 * event_hook handler corresponds to a 0 (fall through) return.
 *
 * The default action for the after_children handler corresponds
 * to a 1 (intercept) return.
 */
typedef int (vtk_eventhandler_t)(struct vtk_object_t *object, vis_event_t *event);


/*----------------------------------------------------------
	Object Kinds
----------------------------------------------------------*/
typedef enum vtk_objects_t
{
	vtkoNone = 0,		/* Dummy object */

	vtkoRoot,		/* A full screen or window */

	vtkoContainer,		/* Invisible alignment container */
	vtkoPanel,		/* Visible panel container */
	vtkoWindow,		/* Floating window
				 * Has a few child objects + a
				 * container representing the
				 * window workspace
				 */

	vtkoLabel,		/* Simple text label */
	vtkoImage,		/* Simple image display */

	vtkoDisplay,		/* String display */
	vtkoSpinEdit,		/* Numeric "spin" editor */
	vtkoEditor,		/* String editor */

	vtkoButton,		/* Button w/ text and/or glyph */
	vtkoToggle,		/* Checkbox style toggle */
	vtkoRadio,		/* Radio style button */

	vtkoBevel		/* Bevel */
} vtk_objects_t;


/*----------------------------------------------------------
	Object
----------------------------------------------------------*/
typedef struct vtk_object_t
{
	/*
	 * Basic object management stuff
	 */
	struct vtk_object_t	*parent;	/* NULL for root */
	struct vtk_object_t	*children;	/* linked list */
	struct vtk_object_t	*next;		/* next in list */

	/*
	 * Description
	 */
	vtk_objects_t		kind;		/* Kind of object */
	int			mod[4];		/* Object modifier args */
	vis_rect_t		rect;		/* Logic pos & size */
	int			align;		/* Alignment */
	int			border;		/* Alignment border */
	vtk_colorspec_t		*colors;
	int			flags;		/* Various flags */

	/*
	 * State &  focus
	 */
	int			state;
	struct vtk_object_t	*focused_child;
	struct vtk_object_t	*capture_child;

	/*
	 * Data
	 */
	vtk_value_t		value;
	int			tag;
	int			position_x;
	int			position_y;
	int			scroll_x;
	int			scroll_y;

	/*
	 * Event callbacks
	 *
	 * Use event_hook when you want to see and possibly
	 * intercept events before the children gets to see them.
	 *
	 * Use event_handler to process events that no child
	 * captured. This is the slot to use for any normal event
	 * processing.
	 */
	vtk_eventhandler_t	*event_hook;
	vtk_eventhandler_t	*event_handler;

	/*
	 * Rendering stuff
	 */
	vis_rect_t		render_rect;	/* Actual rect on visual */
	int			render_flags;	/* clipping hints */
	vis_visual_t		*visual;	/* target visual */
} vtk_object_t;


/*----------------------------------------------------------
	Macros
----------------------------------------------------------*/
#define	VTK_FP2FIX(x)		((x) * 65536.0)
#define	VTK_FIX2FP(x)		((x) / 65536.0)
#define	VTK_FIXINT(x)		((x) >> 16)
#define	VTK_FIXFRAC(x)		((x) & 0x0000ffff)

static inline void vtk_set_alignment(vtk_object_t *object, int flags)
{
	object->align &= ~VA_ALIGN_;
	object->align |= flags & VA_ALIGN_;
}

static inline void vtk_set_stacking(vtk_object_t *object, int flags)
{
	object->align &= ~VA_STACK_;
	object->align |= flags & VA_STACK_;
}

static inline void vtk_set_wrapping(vtk_object_t *object, int flags)
{
	object->align &= ~VA_WRAP_;
	object->align |= flags & VA_WRAP_;
}

static inline void vtk_set_packing(vtk_object_t *object, int flags)
{
	object->align &= ~VA_PACK_;
	object->align |= flags & VA_PACK_;
}

static inline void vtk_set_sizing(vtk_object_t *object, int flags)
{
	object->align &= ~VA_SIZE_;
	object->align |= flags & VA_SIZE_;
}

void vtk_set_value(vtk_object_t *object, double val);
int vtk_button_down(vtk_object_t *object, int btn);

#define VTK_H(nm)					\
int nm(vtk_object_t *object, vis_event_t *event)	\
{							\
	int stop = 1;					\
	switch(event->kind)				\
	{

#define VTK_H_CHAIN(nm, preh)				\
int nm(vtk_object_t *object, vis_event_t *event)	\
{							\
	int stop = preh(object, event);			\
	switch(event->kind)				\
	{

#define VTK_ENDH					\
	  default:					\
	  	break;					\
	}						\
	return stop;					\
}

#define VTK_ENDH_CHAIN(posth)				\
	  default:					\
	  	break;					\
	}						\
	return posth(object, event);			\
}


/*----------------------------------------------------------
	GUI building
----------------------------------------------------------*/
vtk_object_t *vtk_new_root(vis_visual_t *vis, vis_rect_t rect);
vtk_object_t *vtk_new_window(vtk_object_t *parent, vis_rect_t rect);
vtk_object_t *vtk_new(vtk_object_t *parent, vis_rect_t rect, vtk_objects_t kind);
void vtk_free(vtk_object_t *object);

/*----------------------------------------------------------
	Color Management
----------------------------------------------------------*/
vtk_colorspec_t *vtk_create_colorspec(char face3d, char text3d);

/*----------------------------------------------------------
	Rendering control
----------------------------------------------------------*/
void vtk_rethink(vtk_object_t *container);
void vtk_render(vtk_object_t *object);

void vtk_invalidate(vtk_object_t *object);
void vtk_update(vtk_object_t *object);

void vtk_show(vtk_object_t *object);
void vtk_hide(vtk_object_t *object);

/*--------------------------------------------------------------------
	Object Specific Functions
--------------------------------------------------------------------*/
/*
 * Editor parts
 */
int vtk_editor_ins(vtk_object_t *object, char ch);
int vtk_editor_del(vtk_object_t *object);
int vtk_editor_left(vtk_object_t *object);
int vtk_editor_right(vtk_object_t *object);
int vtk_eh_editor(vtk_object_t *object, vis_event_t *event);

/*
 * Spin Editor parts
 */
int vtk_eh_spinedit(vtk_object_t *object, vis_event_t *event);

/*----------------------------------------------------------
	Event handling
----------------------------------------------------------*/
/*
 * Call default event handler for an object
 */
int vtk_default_handler(vtk_object_t *object, vis_event_t *event);

/*
 * VTK events (binary compatible with the Visualize event system)
 */
typedef enum vtk_events_t
{
	vtkeInit = viseVTK_first,
	vtkeExit,
	vtkeRender,
	vtkeStateChange	/* Uses the move variant; x=set, y=clr */
} vtk_events_t;

typedef struct vtk_event_t
{
	VIS_EVENT_HEADER;
	union
	{
		vis_rect_t		rect;
	} data;
} vtk_event_t;

/*
 * Wait until an event is queued, or until timeout.
 * Returns 1 if there are events.
 *
 * (Basically the same as the vis_wait_event().)
 */
int vtk_wait_event(vtk_object_t *object, int timeout);

/*
 * Waits for an event on the specified object's visual.
 * Times out and returns 0 after <timeout> ms (0 means don't
 * block at all; -1 means wait forever) or returns 1, after
 * filling in the event struct.
 *
 * (Basically the same as the vis_get_event().)
 */
int vtk_get_event(vtk_object_t *object, vis_event_t *event, int timeout);

/*
 * Throw events in here if you want to grab them directly from
 * Visualize. Application demo event streams and that kind of
 * things go here as well.
 *
 * The return works like that of the event handler callbacks;
 * 0 = continue (ie fall through), 1 = event intercepted.
 */
int vtk_process_event(vtk_object_t *object, vis_event_t *event);

/*
 * Process all event queued on the specified object's visual.
 * Use this if you just want to get the job done, and don't
 * care about the raw events.
 */
void vtk_process_events(vtk_object_t *object);

/*
 * Read tick counter. One tick corresponds to one ms.
 */
int vtk_get_ticks();

#ifdef __cplusplus
};
#endif

#endif
