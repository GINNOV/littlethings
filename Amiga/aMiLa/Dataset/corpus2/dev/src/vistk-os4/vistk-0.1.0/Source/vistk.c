/*
-----------------------------------------------------------
   vtk.c - The "Visualize" Toolkit library
-----------------------------------------------------------
 * (C) 2000 David Olofson
 * Reologica Instruments AB
 */

/* FIXME: Where should VTK get font size, string extents etc from? */
#define FONT_W	6
#define FONT_H	8

#define	DB(x)

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <math.h>

#include "vistk.h"
#include "sgfx.h"
#include "vtkprims.h"

static int do_process_event(vtk_object_t *object, vis_event_t *event);
static int __event_handler(vtk_object_t *object, vis_event_t *event);
static int __event_hook(vtk_object_t *object, vis_event_t *event);

vtk_colorspec_t default_active_colors =
{
	VISCL_WHITE,
	VISCL_BLACK,
	VISCL_YELLOW,
	VISCL_RED,

	VISCL_SELECTFG,
	VISCL_SELECTBG,

	VISCL_3D_SHADOW,
	VISCL_3D_DARK,
	VISCL_3D_FACE,
	VISCL_3D_LIGHT,
	VISCL_3D_HIGHLIGHT,

	VISCL_3D_TEXT,
	VISCL_SELECTFG,
	VISCL_SELECTBG
};

vtk_colorspec_t default_passive_colors =
{
	VISCL_WHITE,
	VISCL_BLACK,
	VISCL_YELLOW,
	VISCL_RED,

	VISCL_SELECTFG,
	VISCL_SELECTBG,

	VISCL_3DP_SHADOW,
	VISCL_3DP_DARK,
	VISCL_3DP_FACE,
	VISCL_3DP_LIGHT,
	VISCL_3DP_HIGHLIGHT,

	VISCL_3DP_TEXT,
	VISCL_SELECTFG,
	VISCL_SELECTBG
};

vtk_colorspec_t gray_colors =
{
	VISCL_BLACK,
	VISCL_GRAY50,
	VISCL_WHITE,
	VISCL_GRAY25,

	VISCL_WHITE,
	VISCL_BLACK,

	VISCL_BLACK,
	VISCL_GRAY25,
	VISCL_GRAY50,
	VISCL_GRAY75,
	VISCL_WHITE,

	VISCL_BLACK,
	VISCL_WHITE,
	VISCL_BLACK
};

/*
!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
NOTE:	This will leak! There's no reference counting
	system or anything...
!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
 */
vtk_colorspec_t *vtk_create_colorspec(char face3d, char text3d)
{
	vtk_colorspec_t *cs = malloc(sizeof(vtk_colorspec_t));
	if(!cs)
		return NULL;

	memcpy(cs, &default_active_colors, sizeof(vtk_colorspec_t));
	cs->face_3D = face3d;
	cs->text_3D = text3d;

	return cs;
}


void vtk_invalidate(vtk_object_t *object)
{
	if(!object)
		return;
	object->render_flags |= VRF_UPDATE;
}

void vtk_update(vtk_object_t *object)
{
	if(!object)
		return;

	if(object->render_flags & VRF_UPDATE)
		vtk_render(object);
	else
	{
		vtk_object_t *o = object->children;
		while(o)
		{
			vtk_update(o);
			o = o->next;
		}
	}
	vis_update(object->visual);
}


/*----------------------------------------------------------
	GUI building
----------------------------------------------------------*/

static void _vtk_init_object(vtk_object_t *o, vis_rect_t rect, vtk_objects_t kind)
{
	/*
	 * Defaults
	 */
	o->kind = kind;
	o->render_rect = o->rect = rect;
	o->align = VA_NONE;
	o->colors = &default_passive_colors;

	switch(kind)
	{
	  case vtkoNone:
	  case vtkoRoot:
	  case vtkoContainer:
	  	o->border = 0;
		break;
	  case vtkoPanel:
	  	o->border = 2;
		break;
	  case vtkoWindow:
	  	o->border = 3;
		o->flags = VOF_CAN_FOCUS;
		o->colors = &default_active_colors;
		break;
	  case vtkoLabel:
	  case vtkoImage:
	  	o->border = 0;
		break;
	  case vtkoDisplay:
	  	o->border = 2;
		break;
	  case vtkoSpinEdit:
		if(!o->value.text)
			o->value.text = calloc(20, 1);
	  case vtkoEditor:
	  case vtkoButton:
	  case vtkoToggle:
	  case vtkoRadio:
	  	o->border = 2;
		o->flags = VOF_CAN_FOCUS;
		o->colors = &default_active_colors;
		break;
	  case vtkoBevel:
	  	o->border = 2;
		break;
	  default:
	  	o->border = 0;
	}

	o->flags |= VOF_CAN_CAPTURE;
	o->state = VS_ENABLED | VS_VISIBLE;

	o->value.value = 0.0;
	o->value.max = 0.0;
	o->value.min = 0.0;
}

/*------------------------------------------------------------------*/

vtk_object_t *vtk_new(vtk_object_t *parent, vis_rect_t rect, vtk_objects_t kind)
{
	vtk_object_t *co;
	vtk_object_t *object;

	if(!parent)
		return 0;

	object = calloc(sizeof(vtk_object_t), 1);
	if(!object)
		return 0;

	_vtk_init_object(object, rect, kind);

	object->parent = parent;

	/*
	 * Add as last child
	 */
	co = parent->children;
	if(co)
	{
		while(co->next)
			co = co->next;
		co->next = object;
	}
	else
		parent->children = object;

	return object;
}

/*------------------------------------------------------------------*/

vtk_object_t *vtk_new_window(vtk_object_t *parent, vis_rect_t rect)
{
	vtk_object_t *co;
	vtk_object_t *object;
//	vis_visual_t *wvis;

	if(!parent)
		return NULL;

	object = calloc(sizeof(vtk_object_t), 0);
	if(!object)
		return NULL;

	_vtk_init_object(object, rect, vtkoWindow);
	object->align = VA_NONE;
	object->parent = parent;

/* FIXME: vtk_new_window doesn't really create that... */
#if 0
	rect.x += 6;
	rect.y += 6+10;
	rect.w -= 12;
	rect.h -= 12-10;
	wvis = vis_open_window(parent->visual, rect.x, rect.y, rect.w, rect.h);
	if(!wvis)
	{
		vtk_free(object);
		return NULL;
	}

	rect.x = 0;
	rect.y = 0;
	co = vtk_new_root(wvis, rect);
	if(!co)
	{
		vis_close(wvis);
		vtk_free(object);
		return NULL;
	}
	/*
	 * Add workspace as first child
	 */
	object->children = co;

	/*
	 * This is the fundamental difference between
	 * a true root, and the work space of a window;
	 * a window has a parent object.
	 */
	co->parent = object;
#endif
	/*
	 * Add as last child
	 */
	co = parent->children;
	if(co)
	{
		while(co->next)
			co = co->next;
		co->next = object;
	}
	else
		parent->children = object;

	return object;
}

/*------------------------------------------------------------------*/

vtk_object_t *vtk_new_root(vis_visual_t *vis, vis_rect_t rect)
{
	vtk_object_t *object;

	object = calloc(sizeof(vtk_object_t), 1);
	if(!object)
		return NULL;

	_vtk_init_object(object, rect, vtkoRoot);

	object->visual = vis;

	return object;
}

/*------------------------------------------------------------------*/

void vtk_free(vtk_object_t *object)
{
	vtk_object_t *o, *o2;

	if(!object)
		return;

	if(object->parent)
	{
		/*
		 * Find "self" and unchain
		 */
		o = object->parent->children;
		o2 = 0;
		while(o)
		{
			if(o == object)
			{
				/* Yeah, this is me! :-) */
				if(o2)
					o2->next = object->next;
				break;
			}
			o2 = o;	/* Save as "last" for next round */
			o = o->next;
		}

		/*
		 * Clear focus and capture
		 */
		object->parent->focused_child = 0;
		object->parent->capture_child = 0;
	}

	o = object->children;
	while(o)
	{
		/*
		 * NOTE: This recursive call will
		 *       unchain the object from
		 *       THIS object's child list!
		 */
		o2 = o->next;
		vtk_free(o);
		o = o2;
	}

	/*
	 * Delete any special kind specific stuff
	 */
	switch(object->kind)
	{
	  case vtkoNone:
	  case vtkoRoot:
	  case vtkoContainer:
		break;
	  case vtkoPanel:
		break;
	  case vtkoWindow:
		break;
	  case vtkoLabel:
	  case vtkoImage:
		break;
	  case vtkoDisplay:
		break;
	  case vtkoSpinEdit:
		if(object->value.text)
			free(object->value.text);
	  case vtkoEditor:
	  case vtkoButton:
	  case vtkoToggle:
	  case vtkoRadio:
		break;
	  case vtkoBevel:
		break;
	  default:
		break;
	}

	/*
	 * Fine. Now, let's disappear!
	 */
	free(object);
}


/*----------------------------------------------------------
	Rendering control
----------------------------------------------------------*/

/* FIXME: This align_cursor_t thing won't work. */
typedef struct align_cursor_t
{
	int x, y;
} align_cursor_t;

/* FIXME: align() is only partially implemented */
static void align(vtk_object_t *con, vtk_object_t *obj, int is_first)
{
	static int lastw, lasth;
	static int wrap_htoggle;
	static int wrap_vtoggle;
	static int stack_htoggle;
	static int stack_vtoggle;
	static align_cursor_t cursors[4];
	int hclip = 0;
	int vclip = 0;
	int x, y;
	int ax, ay;
	int cursor = 0;

	if(con->align == VA_NONE)
		return;

	/*
	 * Calculate what the aligned coordinates would be.
	 */
	if((con->align & _VA_ALIGN_HCENTER) == _VA_ALIGN_HCENTER)
		ax = (con->rect.w - obj->rect.w) / 2;
	else if(con->align & VA_ALIGN_RIGHT)
		ax = con->rect.w - con->border - obj->rect.w;
	else if(con->align & VA_ALIGN_LEFT)
		ax = con->border;
	else
		ax = obj->rect.x;

	if((con->align & _VA_ALIGN_VCENTER) == _VA_ALIGN_VCENTER)
		ay = (con->rect.h - obj->rect.h) / 2;
	else if(con->align & VA_ALIGN_BOTTOM)
		ay = con->rect.h - con->border - obj->rect.h;
	else if(con->align & VA_ALIGN_TOP)
		ay = con->border;
	else
		ay = obj->rect.y;

	if(con->align & VA_STACK_)
	{
		if((con->align & _VA_STACK_HALTERNATE) == _VA_STACK_HALTERNATE)
			cursor |= (stack_htoggle>0)<<1;
		if((con->align & _VA_STACK_VALTERNATE) == _VA_STACK_VALTERNATE)
			cursor |= stack_vtoggle>0;

		if(is_first)
		{
			int c;
			for(c=0; c<4; ++c)
			{
				cursors[c].x = ax;
				cursors[c].y = ay;
			}
			x = ax;
			y = ay;
			lastw = 0;
			lasth = 0;
			wrap_htoggle = 1;
			wrap_vtoggle = 1;
			stack_htoggle = 1;
			stack_vtoggle = 1;
		}
		else
		{
			x = cursors[cursor].x;
			y = cursors[cursor].y;
		}
	}
	else
	{
		x = ax;
		y = ay;
	}

	if(con->align & VA_WRAP_)
	{
		hclip = (x + obj->rect.w > con->rect.w - con->border)
				|| (x < con->border);
		vclip = (y + obj->rect.h > con->rect.h - con->border)
				|| (y < con->border);
		if(hclip)
		{
			int sw;
			if((con->align & _VA_WRAP_VALTERNATE) == _VA_WRAP_VALTERNATE)
				sw = wrap_vtoggle;
			else if(con->align & VA_WRAP_UP)
				sw = -1;
			else if(con->align & VA_WRAP_DOWN)
				sw = 1;
			else
				sw = 0;
			switch(sw)
			{
			  case -1:
				x = ax;
				y -= obj->rect.h;
				lasth = 0;
				break;
			  case 1:
				x = ax;
				y += lasth;
				lasth = 0;
				break;
			}
		}
		if(vclip)
		{
			int sw;
			if((con->align & _VA_WRAP_HALTERNATE) == _VA_WRAP_HALTERNATE)
				sw = wrap_htoggle;
			else if(con->align & VA_WRAP_LEFT)
				sw = -1;
			else if(con->align & VA_WRAP_RIGHT)
				sw = 1;
			else
				sw = 0;
			switch(sw)
			{
			  case -1:
				y = ay;
				x -= obj->rect.w;
				lastw = 0;
				break;
			  case 1:
				y = ay;
				x += lastw;
				lastw = 0;
				break;
			}
		}
		if((con->align & _VA_WRAP_ALTERNATE) == _VA_WRAP_ALTERNATE)
		{
			wrap_vtoggle = -wrap_vtoggle;
			if(wrap_vtoggle > 0)
				wrap_htoggle = -wrap_htoggle;
		}
		else
		{
			wrap_vtoggle = -wrap_vtoggle;
			wrap_htoggle = -wrap_htoggle;
		}
	}

	if(con->align & VA_STACK_)
	{
		if(obj->rect.w > lastw)
			lastw = obj->rect.w;
		if(obj->rect.h > lasth)
			lasth = obj->rect.h;
	}

	obj->rect.x = x;
	obj->rect.y = y;

	if(con->align & VA_STACK_)
	{
		int sign;
		/*
		 * Move the stacking "cursor"
		 */
		if((con->align & _VA_STACK_HALTERNATE) == _VA_STACK_HALTERNATE)
			sign = stack_htoggle;
		else if(con->align & VA_STACK_RIGHT)
			sign = 1;
		else if(con->align & VA_STACK_LEFT)
			sign = -1;
		else
			sign = 0;
		x += sign*obj->rect.w;

		if((con->align & _VA_STACK_VALTERNATE) == _VA_STACK_VALTERNATE)
			sign = stack_vtoggle;
		else if(con->align & VA_STACK_UP)
			sign = -1;
		else if(con->align & VA_STACK_DOWN)
			sign = 1;
		else
			sign = 0;
		y += sign*obj->rect.h;

		if((con->align & _VA_STACK_ALTERNATE) == _VA_STACK_ALTERNATE)
		{
			stack_vtoggle = -stack_vtoggle;
			if(stack_vtoggle > 0)
				stack_htoggle = -stack_htoggle;
		}
		else
		{
			stack_vtoggle = -stack_vtoggle;
			stack_htoggle = -stack_htoggle;
		}

		cursors[cursor].x = x;
		cursors[cursor].y = y;
	}
}


/*------------------------------------------------------------------*/
/*
 * Transform alignment data and logic position/size
 * data into real coordinates.
 */
static void rethink_logic(vtk_object_t *container)
{
	vtk_object_t *child;

	/*
	 * Roots have to rethink their own render_rect
	 */
	if(container->kind == vtkoRoot)
	{
		/*
		 * So we're a Root object. Unless we
		 * belong to a Window, we have no parent
		 * that will set up our coords.
		 */
		if(!container->parent)
		{
			container->rect.x = 0;
			container->rect.y = 0;
			container->rect.w = container->visual->rect.w;
			container->rect.h = container->visual->rect.h;
		}
	}

	/*
	 * Rethink all children
	 */
	child = container->children;
	while(child)
	{
		/*
		 * Recursive call!
		 */
		rethink_logic(child);
		child = child->next;
	}

	/*
	 * Arrange all children
	 */
	child = container->children;
	if(child)
	{
		align(container, child, 1);
		child = child->next;
		while(child)
		{
			align(container, child, 0);
			child = child->next;
		}
	}
}


/*------------------------------------------------------------------*/
/*
 * Calculate physic coordinates for the target contexts
 * of the referenced object and (recursively) all children.
 */
static void rethink_render(vtk_object_t *object)
{
	vtk_object_t *child;
	vis_rect_t conrr;
 	int bd;

	object->render_flags &= ~VRF_CLIP_;

	if(object->kind != vtkoRoot)
		if(object->parent)
		{
			object->visual = object->parent->visual;
		}

	/*
	 * Roots always have their own visuals!
	 * (A window needs a private visual with
	 * context and all, so the work area is
	 * actually a vtkoRoot object nested as
	 * a child to the vtkoWindow.)
	 */
	if(object->kind == vtkoRoot)
	{
		if(!object->parent)
		{
			/*
			 * This is The Root; not a window
			 */
			object->render_rect = object->rect;
		}
		else
			vis_move_window(object->visual, object->render_rect);
	}
	
	/*
	 * Calculate rendering stuff for all children
	 */
	child = object->children;
	conrr = object->render_rect;
	bd = object->border;
	while(child)
	{
		vis_rect_t *rr;
		rr = &child->render_rect;
		/*
		 * Start out with the logic rect
		 */
		*rr = child->rect;
		/*
		 * Transform to streen coords
		 */
		rr->x += conrr.x;
		rr->y += conrr.y;
		/*
		 * Recursive call!
		 */
		rethink_render(child);
		child = child->next;
	}
}

/*------------------------------------------------------------------*/

void vtk_rethink(vtk_object_t *object)
{
	if(!object)
		return;
	rethink_logic(object);
	rethink_render(object);
}

/*------------------------------------------------------------------*/

/* NOTE: This has very little to do with vtk_invalidate()! */
void __invalidate(vtk_object_t *object)
{
	if(!object)
		return;
	vis_invalidate(object->visual, object->render_rect);
}

void vtk_render(vtk_object_t *object)
{
	vtk_object_t	*co;
	vis_rect_t	rr;
	sg_context_t	*vgc;
	sg_pen_t	psave;
	int ox, oy;

	if(!object)
		return;
	if(!object->visual)
		return;

	object->render_flags &= ~VRF_UPDATE;

	/*
	 * Send a viseRepaint event to the event *hook*.
	 *
	 * Weird? Well, it might be handy for visual GUI
	 * editors and stuff, as it bypasses all HIDDEN/
	 * VISIBLE/... flags.
	 *
	 * Note, that it also comes *before* the default
	 * graphics of the object (if any) is drawn.
	 */
	{
		vis_event_t	event;
		event.kind = vtkeRender;
		event.channel = 0;	/* Use for pre/post default gfx? */
		event.data.rect.x = 0;	/* This is an event: Local coords! */
		event.data.rect.y = 0;
		event.data.rect.w = object->rect.w;
		event.data.rect.h = object->rect.h;
		__event_hook(object, &event);
	}

	if(object->render_flags & VRF_HIDDEN)
		return;
	if(!(object->state & VS_VISIBLE))
		return;

	vgc = object->visual->context;
	rr = object->render_rect;
	if(object->state & VS_ENABLED)
	{
		vgc->pen.fgmod = 0;
		vgc->pen.bgmod = 0;
	}
	else
	{
		vgc->pen.fgmod = VISCMOD_HALFBRIGHT;
		vgc->pen.bgmod = VISCMOD_HALFBRIGHT;
	}
	switch(object->kind)
	{
	  case vtkoNone:
	  case vtkoRoot:
	  case vtkoContainer:
		/*
		 * NOTE: Logic only; no rendering.
		 */
		DB(vtk_bar(vgc, rr, VISCL_GRAY25));
		break;
	  case vtkoPanel:
		vtk_3Dbar_fat(vgc, rr, object->colors);
		__invalidate(object);
		break;
	  case vtkoWindow:
		/*
		 * NOTE: Nothing but the 3D outline here!
		 * The rest is child objects.
		 */
		if(object->state & VS_FOCUSED)
			vtk_box(vgc, rr, VISCL_RED);
		else
			vtk_box(vgc, rr, VISCL_BLACK);
		vis_shrink(rr,1);
		vtk_3Dbar_fat(vgc, rr, object->colors);
		__invalidate(object);
		break;
	  case vtkoLabel:
		sg_locate(vgc, rr.x+5, rr.y+5);
		vgc->pen.fgcolor = object->colors->shadow_3D;
		sg_capture(vgc, &psave);
		sg_print(vgc, object->value.text);
		sg_restore(vgc, &psave);
		sg_bump(vgc, -1, -1);
		vgc->pen.fgcolor = object->colors->text_3D;
		sg_print(vgc, object->value.text);
		__invalidate(object);
		break;
	  case vtkoImage:
/* FIXME: vtkoImage rendering not implemented */
	  	vtk_bar(vgc, rr, VISCL_WHITE);
		vtk_line_ddown(vgc, rr, VISCL_GRAY50);
		vtk_line_dup(vgc, rr, VISCL_GRAY50);
	  	vtk_box(vgc, rr, VISCL_BLACK);
		__invalidate(object);
		break;
	  case vtkoDisplay:
	  	vtk_box(vgc, rr, object->colors->face_3D);
		vis_shrink(rr, 1);
		vtk_3Ddepr(vgc, rr, object->colors);
		vgc->pen.fgcolor = object->colors->shadow_3D;
		sg_locate(vgc, rr.x+3, rr.y+3);
		sg_print(vgc, object->value.text);
		__invalidate(object);
		break;
	  case vtkoSpinEdit:
		snprintf(object->value.text, 20, "%d", (int)object->value.value);
	  case vtkoEditor:
		{
			int maxx = object->rect.w/FONT_W - 8;
			if(object->scroll_x > object->position_x)
				object->scroll_x = object->position_x;
			if(object->scroll_x > maxx - object->position_x)
				object->scroll_x = object->position_x - maxx;
			if(object->scroll_x < 0)
				object->scroll_x = 0;
			if(object->scroll_x > object->value.end)
				object->scroll_x = object->value.end;
		}
		vtk_3Dbox(vgc, rr, object->colors);
		vis_shrink(rr, 1);
		vtk_3Ddbox_fat(vgc, rr, object->colors);
		vis_shrink(rr, 2);
		//vtk_3Ddbox_fat(vgc, rr, object->colors);
		//vis_shrink(rr, 2);
	  	vtk_bar(vgc, rr, object->colors->back);
		vgc->pen.fgcolor = object->colors->text;
		{
			sg_context_t win;
			sg_init_window(&win, vgc, rr.x, rr.y, rr.w, rr.h);
			sg_locate(&win, 1, 1);
			sg_print(&win, object->value.text + object->scroll_x);
			if(object->state & VS_FOCUSED)
			{
				rr.y = 0;
				rr.x = FONT_W * (object->position_x - object->scroll_x);
				rr.w = FONT_W + 1;
				rr.h = FONT_H + 2;
				vtk_bar(&win, rr, object->colors->cursor_back);
				sg_locate(&win, rr.x+1, rr.y+1);
				win.pen.fgcolor = object->colors->cursor_text;
				sg_putc(&win, object->value.text[object->position_x]);
			}
		}
		__invalidate(object);
		break;
	  case vtkoButton:
		if(object->state & VS_FOCUSED)
		{
			if((object->state & VS_CAPTURE) || object->value.value)
			{
				ox = oy = 6;
				vtk_box(vgc, rr, VISCL_RED);
				vis_shrink(rr,1);
				vtk_3Ddepr(vgc, rr, object->colors);
			}
			else
			{
				ox = oy = 5;
				vtk_box(vgc, rr, VISCL_RED);
				vis_shrink(rr,1);
				vtk_3Dbar(vgc, rr, object->colors);
			}
			vis_expand(rr,1);
		}
		else
		{
			if((object->state & VS_CAPTURE) || object->value.value)
			{
				ox = oy = 6;
				vtk_3Ddepr_fat(vgc, rr, object->colors);
			}
			else
			{
				ox = oy = 5;
				vtk_3Dbar_fat(vgc, rr, object->colors);
			}
		}
		sg_locate(vgc, rr.x+ox, rr.y+oy);
		vgc->pen.fgcolor = object->colors->shadow_3D;
		sg_capture(vgc, &psave);
		sg_print(vgc, object->value.text);
		sg_restore(vgc, &psave);
		sg_bump(vgc, -1, -1);
		vgc->pen.fgcolor = object->colors->text_3D;
		sg_print(vgc, object->value.text);
		__invalidate(object);
		break;
	  case vtkoToggle:
/* FIXME: vtkoToggle rendering not implemented */
		break;
	  case vtkoRadio:
/* FIXME: vtkoRadio rendering not implemented */
		break;
	  case vtkoBevel:
		/* Outer bevel edge */
		switch(object->mod[0])
		{
		  case 0:
			vtk_3Dbox(vgc, rr, object->colors);
			break;
		  case 1:
			vtk_3Ddbox(vgc, rr, object->colors);
			break;
		  case 2:
			vtk_3Dbox_fat(vgc, rr, object->colors);
			break;
		  case 3:
			vtk_3Ddbox_fat(vgc, rr, object->colors);
			break;
		}
		/* Inner bevel edge + surface/hole */
		if(object->mod[1])
		{
			switch(object->mod[0])
			{
			  case 0:
				vtk_3Ddbox(vgc, rr, object->colors);
				vis_shrink(rr, 1);
				break;
			  case 1:
				vis_shrink(rr, 1);
				break;
			  case 2:
				vtk_3Ddbox_fat(vgc, rr, object->colors);
				vis_shrink(rr, 2);
				break;
			  case 3:
				vis_shrink(rr, 2);
				break;
			}
			vtk_bar(vgc, rr, object->colors->back);
		}
		__invalidate(object);
		break;
	  default:
		vtk_3Dbar(vgc, rr, &gray_colors);
		__invalidate(object);
		break;
	}
	vgc->pen.fgmod = 0;
	vgc->pen.bgmod = 0;

	DB(
		rr = object->render_rect;
//		vis_shrink(rr,1);
//		if(object->focused_child)
//			vtk_box(vgc, rr, VISCL_YELLOW);
		vis_shrink(rr,1);
		if(object->state & VS_FOCUSED)
			vtk_box(vgc, rr, VISCL_YELLOW);
		else if(object->state & VS_SOFT_FOCUS)
			vtk_box(vgc, rr, VISCL_RED);
	)

	/*
	 * Send a viseRepaint event, in case someone
	 * wants to do some custom rendering, and have
	 * it working properly without silly hacks...
	 */
	{
		vis_event_t	event;
		event.kind = vtkeRender;
		event.channel = 0;	/* Use for pre/post default gfx? */
		event.data.rect.x = 0;	/* This is an event: Local coords! */
		event.data.rect.y = 0;
		event.data.rect.w = object->rect.w;
		event.data.rect.h = object->rect.h;
		__event_handler(object, &event);
	}

	/*
	 * Render all children
	 */
	co = object->children;
	while(co)
	{
		vtk_render(co);
		co = co->next;
	}
}


/*--------------------------------------------------------------------
	Object Specific Functions
--------------------------------------------------------------------*/

/* FIXME: the vtk_editor_ stuff belongs elsewhere... */

int vtk_editor_ins(vtk_object_t *object, char ch)
{
	if(object->value.end >= object->value.size-1)
		return 0;
	if(object->position_x < object->value.size)
		memmove(object->value.text+object->position_x+1,
				object->value.text+object->position_x,
				object->value.end-object->position_x);
	object->value.text[object->position_x] = ch;
	++object->position_x;
	++object->value.end;
	object->value.text[object->value.end] = 0;
	return 1;
}

int vtk_editor_del(vtk_object_t *object)
{
	if(!object->value.end)
		return 0;
	if(object->position_x < object->value.end)
		memmove(object->value.text+object->position_x,
				object->value.text+object->position_x+1,
				object->value.end-object->position_x-1);
	else
		return 0;
	--object->value.end;
	object->value.text[object->value.end] = 0;
	return 1;
}

int vtk_editor_left(vtk_object_t *object)
{
	if(object->position_x <= 0)
		return 0;
	--object->position_x;
	return 1;
}

int vtk_editor_right(vtk_object_t *object)
{
	if(object->position_x >= object->value.end)
		return 0;
	++object->position_x;
	return 1;
}

VTK_H(vtk_eh_editor)
  case viseButtonUp:
  	break;
  case viseButtonDown:
  	break;
  case viseKeyDown:
  case viseKeyRepeat:
	switch(event->data.key.control)
	{
	  case VTKC_LEFT:
		vtk_editor_left(object);
		vtk_invalidate(object);
		break;
	  case VTKC_RIGHT:
		vtk_editor_right(object);
		vtk_invalidate(object);
		break;
	  case VTKC_HOME:
		object->position_x = 0;
		vtk_invalidate(object);
	  	break;
	  case VTKC_END:
		object->position_x = object->value.end;
		vtk_invalidate(object);
	  	break;
	  case VTKC_DELETE:
		vtk_editor_del(object);
		vtk_invalidate(object);
	  	break;
	  case VTKC_BACKSPACE:
		if(vtk_editor_left(object))
		{
			vtk_editor_del(object);
			vtk_invalidate(object);
		}
	  	break;
	  default:
	  	if( (event->data.key.unicode >= ' ') &&
				(event->data.key.unicode <= 255) )
		{
			vtk_editor_ins(object, event->data.key.unicode);
			vtk_invalidate(object);
		}
		break;
	}
	break;
  case viseKeyUp:
  	break;
VTK_ENDH


VTK_H(vtk_eh_spinedit)
  case viseButtonDown:
  {
	double val = object->value.value;
	double step, step1;
	/* Middle button multiplies everything by 10 */
  	if(vtk_button_down(object, VISBTN_MIDDLE))
		step = step1 = 10.0;
	else
		step = step1 = 1.0;

	/* Value scales wheel */
	if(fabs(val) >= 1000.0)
		step *= 100.0;
	else if(fabs(val) >= 100.0)
		step *= 10.0;
	else if(fabs(val) >= 10.0)
		step *= 5.0;

	switch(event->data.button.button)
	{
	  case VISBTN_LEFT:
		val += step1;
		break;
	  case VISBTN_RIGHT:
		val -= step1;
		break;
	  case VISBTN_WHEELUP:
		val += step;
		break;
	  case VISBTN_WHEELDOWN:
		val -= step;
		break;
	  default:
		break;
	}
	vtk_set_value(object, val);
	break;
  }
VTK_ENDH


int vtk_default_handler(vtk_object_t *object, vis_event_t *event)
{
	int ret = 1;
	switch(object->kind)
	{
	  case vtkoNone:
		return 0;
	  case vtkoRoot:
	  case vtkoContainer:
	  case vtkoPanel:
	  case vtkoWindow:
		break;
	  case vtkoLabel:
	  case vtkoImage:
		ret = 0;
		break;
	  case vtkoDisplay:
		break;
	  case vtkoSpinEdit:
		return vtk_eh_spinedit(object, event);
	  case vtkoEditor:
		return vtk_eh_editor(object, event);
	  case vtkoButton:
	  case vtkoToggle:
	  case vtkoRadio:
		break;
	  case vtkoBevel:
		ret = 0;
		break;
	  default:
		break;
	}

	return ret;
}



/*
 * Internal vtkeStateChange handler for *all* objects.
 */
void __handle_state_change(vtk_object_t *object, int set, int clear)
{
	int ch, flags;

	ch = set | clear;
	flags = 0;

	switch(object->kind)
	{
	  case vtkoNone:
	  case vtkoRoot:
	  case vtkoContainer:
	  case vtkoPanel:
	  case vtkoLabel:
	  case vtkoImage:
	  case vtkoBevel:
		return;
	  case vtkoWindow:
		flags |= VS_SOFT_FOCUS | VS_FOCUSED;
		break;
	  case vtkoButton:
	  case vtkoToggle:
	  case vtkoRadio:
		flags |= VS_ENABLED | VS_SELECTED | VS_FOCUSED | VS_CAPTURE;
		break;
	  case vtkoDisplay:
	  case vtkoSpinEdit:
	  case vtkoEditor:
		flags |= VS_ENABLED | VS_SELECTED | VS_FOCUSED;
		break;
	  default:
		return;
	}

	if(ch & flags)
		vtk_invalidate(object);
}

void __change_state(vtk_object_t *object, int set, int clear)
{
	/* Calculate the *actual* changes */
	int do_set = set & ~object->state;
	int do_clear = clear & object->state;

	if(do_set || do_clear)
	{
		vis_event_t event;

		/* Apply changes */
		object->state |= do_set;
		object->state &= ~do_clear;

		/* Call event handler (or built-in default) */
		event.kind = vtkeStateChange;
		event.data.move.x = do_set;
		event.data.move.y = do_clear;
		__event_handler(object, &event);

		/* Perform internal actions */
		__handle_state_change(object, do_set, do_clear);
	}
}



/*--------------------------------------------------------------------
	Event handling
--------------------------------------------------------------------*/

/* FIXME: I have bad feelings about the focus and capture stuff. It works...!? */

static void set_focus(vtk_object_t *object)
{
	if(!object)
		return;
	DB(printf("Focus at %d\n", object->tag);)
	if(object->flags & VOF_CAN_FOCUS)
	{
		/*
		 * Focus on *this* object!
		 */
		__change_state(object, VS_FOCUSED, 0);
		object->focused_child = 0;
	}
	else
	{
		vtk_object_t *o;
		int found_focus = 0;

		__change_state(object, VS_SOFT_FOCUS, 0);

		/*
		 * Let focus fall through to
		 * last focused child, if any.
		 */
		o = object;
		while(o)
		{
			if(o->focused_child)
				__change_state(o, VS_SOFT_FOCUS, 0);
			else
			{
				if(o->flags & VOF_CAN_FOCUS)
					__change_state(o, VS_FOCUSED, 0);
				found_focus = 1;
				break;
			}
			o = o->focused_child;
		}
//		if(!found_focus)
//		{
//			remove_focus(object);
//			return;
//		}
	}
	/*
	 * Tell everyone above that we (or a child of ours) got the focus!
	 */
	while(object->parent)
	{
		object->parent->focused_child = object;
		__change_state(object->parent, VS_SOFT_FOCUS, 0);
		object = object->parent;
	}
}

/*
FIXME: Soft focus...?
FIXME:	We should really have a way of telling which status
FIXME:	changes actually affect the rendering of every object.
FIXME:
FIXME:	How about simply sending an event and let the actual
FIXME:	implementation deal with it, rather than worrying
FIXME:	about it here? Not terribly efficient, though...
*/
static void remove_focus(vtk_object_t *object)
{
	if(!object)
		return;
	DB(printf("Unfocusing\n");)
	while(object->parent)
		object = object->parent;
	while(object)
	{
		DB(printf("  (Unfocused %d)\n", object->tag);)
		__change_state(object, 0, VS_FOCUSED | VS_SOFT_FOCUS);
		object = object->focused_child;
	}

}

static void set_capture(vtk_object_t *object)
{
	if(!object)
		return;
	DB(printf("Captured by %d\n", object->tag);)
	__change_state(object, VS_CAPTURE, 0);
	object->capture_child = 0;
	while(object->parent)
	{
		object->parent->capture_child = object;
		DB(printf("  (Captured %d)\n", object->tag);)
		__change_state(object->parent, 0, VS_CAPTURE);
		object = object->parent;
	}
}

static void remove_capture(vtk_object_t *object)
{
	vtk_object_t *nexto;
	if(!object)
		return;
	DB(printf("Uncapturing\n");)
	while(object->parent)
		object = object->parent;
	while(object)
	{
		__change_state(object, 0, VS_CAPTURE);
		DB(printf("  (Uncaptured %d)\n", object->tag);)
		nexto = object->capture_child;
		object->capture_child = 0;
		object = nexto;
	}
}

static vtk_object_t *find_next(vtk_object_t *object)
{
	if(object->children)
	{
		while(object->children)
			object = object->children;	
		return object;
	}
	else
	{
		if(object->next)
			return object->next;
		else
		{
			while(object->parent)
			{
				if(object->parent->next)
					return object->parent->next;
				else
					object = object->parent;
			}
			return object;
		}
	}
}

/* - - - - - - - - - - - - - - - - - - - - - - */

static void check_focus(vtk_object_t *object, vis_event_t *event)
{
	switch(event->kind)
	{
	  case viseKeyDown:
	  case viseKeyRepeat:
	  	switch(event->data.key.control)
		{
		  case VTKC_ADVANCE:
		  {
			vtk_object_t *o = object;
			/*
			 * Scan forward until a focusable
			 * object is found, or we get back
			 * to where we started.
			 */
			do {
				o = find_next(o);
				if(o->flags & VOF_CAN_FOCUS)
					break;
			} while(o != object);
			remove_capture(object);
			remove_focus(object);
			if(o != object)
			{
				o->focused_child = o->children;
				set_focus(o);
			}
			break;
		  }
		  case VTKC_ESCAPE:
			remove_focus(object);
			break;
		  default:
			break;
		}
		break;

		break;
	  case viseButtonDown:
		remove_capture(object);
		if(object->flags & VOF_CAN_CAPTURE)
			set_capture(object);
		if(object->flags & VOF_CAN_FOCUS)
			if(event->data.button.button == VISBTN_LEFT)
			{
				remove_focus(object);
				set_focus(object);
			}
		break;
	  case viseButtonUp:
		remove_capture(object);
	  	break;
	  default:
	  	break;
	}
}

/* - - - - - - - - - - - - - - - - - - - - - - */

#if 0
/*
 * Non-recursive version. Checks objects in the wrong order,
 * because the list isn't doubly linked...
 */
static int deliver_pointer_event(vtk_object_t *object, vis_event_t *event)
{
	vtk_object_t *child;
	int stop = 0;
	int x, y;
	if(!object)
		return 0;
	if(!object->visual)
		return 0;
	x = object->visual->pointer.x;
	y = object->visual->pointer.y;
	child = object->children;
	while(child)
	{
		if(vis_is_inside(child->render_rect, x, y))
		{
			vis_event_t ev;
			ev = *event;
			if(ev.kind == viseAbsMove)
			{
				ev.data.move.x -= child->render_rect.x;
				ev.data.move.y -= child->render_rect.y;
			}
			stop = do_process_event(child, &ev);
		}
		if(stop)
			break;
		child = child->next;
	}
	return stop;
}
#else
static int do_deliver_pointer_event(vtk_object_t *object, vis_event_t *event,
						int x, int y)
{
	if(!object)
		return 0;
	if(!object->visual)
		return 0;
	if(vis_is_inside(object->render_rect, x, y))
	{
		vis_event_t ev = *event;
		return do_process_event(object, &ev);
	}
	return 0;
}

static int recurse_pointer_event(vtk_object_t *object, vis_event_t *event,
						int x, int y)
{
	if(!object)
		return 0;
	/* First recurse down... */
	if(recurse_pointer_event(object->next, event, x, y))
		return 1;
	/* ...then do the work for this object. */
	return do_deliver_pointer_event(object, event, x, y);
}

static int deliver_pointer_event(vtk_object_t *object, vis_event_t *event)
{
	int x, y;
	if(!object)
		return 0;
	x = object->visual->pointer.x;
	y = object->visual->pointer.y;
	return recurse_pointer_event(object->children, event, x, y);
}
#endif

/* - - - - - - - - - - - - - - - - - - - - - - */

typedef enum vtk_dispatchclass_t
{
	vtkdcRootOnly = 0,
	vtkdcBroadcast,
	vtkdcPointer,
	vtkdcFocused
} vtk_dispatchclass_t;

static inline vtk_dispatchclass_t vtk_dispatch_class(vis_event_t *event)
{
	switch(event->kind)
	{
	  case viseRelMove:
	  case viseAbsMove:
	  case viseButtonDown:
	  case viseButtonRepeat:
	  case viseButtonUp:
	  case viseButtonDouble:
	  case viseButtonTriple:
	  case viseButtonQuadruple:
	  	return vtkdcPointer;
	  case viseKeyDown:
	  case viseKeyRepeat:
	  case viseKeyUp:
	  	return vtkdcFocused;
	  default:
	  	return vtkdcRootOnly;
	}
}

/* - - - - - - - - - - - - - - - - - - - - - - */

static int __event_handler(vtk_object_t *object, vis_event_t *event)
{
	int stop;
	if(event->kind == viseAbsMove)
	{
		event->data.move.x -= object->render_rect.x;
		event->data.move.y -= object->render_rect.y;
	}
	if(object->event_handler)
		stop = (object->event_handler)(object, event);
	else
		stop = vtk_default_handler(object, event);
	if(event->kind == viseAbsMove)
	{
		event->data.move.x += object->render_rect.x;
		event->data.move.y += object->render_rect.y;
	}
	return stop;
}

/* - - - - - - - - - - - - - - - - - - - - - - */

static int __event_hook(vtk_object_t *object, vis_event_t *event)
{
	int stop;
	if(!object->event_hook)
		return 0;	/* Note: No default hooks. */

	if(event->kind == viseAbsMove)
	{
		event->data.move.x -= object->render_rect.x;
		event->data.move.y -= object->render_rect.y;
	}
	DB(printf("Calling event_hook() for %d\n",object->tag);)
	stop = (object->event_hook)(object, event);
	if(event->kind == viseAbsMove)
	{
		event->data.move.x += object->render_rect.x;
		event->data.move.y += object->render_rect.y;
	}
	return stop;
}

/* - - - - - - - - - - - - - - - - - - - - - - */

static int do_process_event(vtk_object_t *object, vis_event_t *event)
{
	int stop = 0;
	int dc;
	vtk_object_t *child;

	if(!object)
		return 0;

	/* FIXME: Why not process events for objects w/o a visual!? */
	if(!object->visual)
		return 0;

	dc = vtk_dispatch_class(event);

	stop = __event_hook(object, event);

	if(dc != vtkdcBroadcast)
		if(object->capture_child)
			stop = do_process_event(object->capture_child, event);

	/*
	 * Deliver events to children
	 */
	if(!stop)
	{
		switch(dc)
		{
		  case vtkdcBroadcast:
			child = object->children;
			while(child)
			{
				do_process_event(child, event);
				child = child->next;
			}
			stop = 0;
			break;
		  case vtkdcFocused:
		  	if(object->focused_child)
			{
				DB(printf("Passing event directly to focused object %d\n",
							object->focused_child->tag);)
				stop = do_process_event(object->focused_child, event);
			}
			else
				/*
				 * Ok, no focused object pointer here, so either
				 * we're it, or we just got this event anyhow.
				 */
				stop = 0;
			break;
		  case vtkdcPointer:
			stop = deliver_pointer_event(object, event);
			break;
		  default:
			stop = 0;
			break;
		}
	}

	if(!stop)
	{
		stop = __event_handler(object, event);
		if(stop)	/* Check focus only if we ate the event! */
			check_focus(object, event);
	}

	if(dc == vtkdcRootOnly)
		stop = 1;
	return stop;
}

/* - - - - - - - - - - - - - - - - - - - - - - */

int vtk_process_event(vtk_object_t *object, vis_event_t *event)
{
	int ret;
	if(!object)
		return 0;

	/* FIXME: Digging down to the deepest root... Caused by a design flaw. */
	while(object->parent)
		object = object->parent;

	/*
	 * Some general preprocessing...
	 */
	switch(event->kind)
	{
	  case viseButtonDown:
	  	/*
		 * Top level GUI rules:
		 *	* LMB can change focus if the object that eats it
		 *	  wants to take focus.
		 *	* LMB will *always* unfocus, so that the user doesn't
		 *	  get the impression of stale or trapped focus.
		 */
		if(event->data.button.button == VISBTN_LEFT)
			remove_focus(object);
		break;
	  default:
		break;
	}

	/*
	 * Now, continue with the recursive part.
	 */
	ret = do_process_event(object, event);

	return ret;
}

/*------------------------------------------------------------------*/

int vtk_wait_event(vtk_object_t *object, int timeout)
{
	if(!object)
		return 0;
	if(!object->visual)
		return 0;
	return vis_wait_event(object->visual, timeout);
}

/*------------------------------------------------------------------*/

int vtk_get_event(vtk_object_t *object, vis_event_t *event, int timeout)
{
	if(!object)
		return 0;
	if(!object->visual)
		return 0;
	return vis_get_event(object->visual, event, timeout);
}

/*------------------------------------------------------------------*/

void vtk_process_events(vtk_object_t *object)
{
	vis_event_t e;
	while(1)
	{
		if(vtk_get_event(object, &e, 0))
			vtk_process_event(object, &e);
		else
			return;
	}
}

/*------------------------------------------------------------------*/

int vtk_get_ticks()
{
	return vis_get_ticks();
}

/*------------------------------------------------------------------*/

void vtk_show(vtk_object_t *object)
{
	__change_state(object, VS_VISIBLE, 0);
}

void vtk_hide(vtk_object_t *object)
{
	__change_state(object, 0, VS_VISIBLE);
}

/*------------------------------------------------------------------*/

int vtk_button_down(vtk_object_t *object, int btn)
{
	if(!object)
		return 0;
	if(!object->visual)
		return 0;
	return vis_button_down(object->visual, btn);
}

/*------------------------------------------------------------------*/

void vtk_set_value(vtk_object_t *object, double val)
{
	if(object->value.min != object->value.max)
	{
		if(val < object->value.min)
			val = object->value.min;
		if(val > object->value.max)
			val = object->value.max;
	}
	if(val == object->value.value)
		return;
	object->value.value = val;
	vtk_invalidate(object);
}
