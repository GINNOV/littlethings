/*
-----------------------------------------------------------
   vtkprims.c - The "Visualize" Toolkit primitives
-----------------------------------------------------------
 * (C) 2000 David Olofson
 * Reologica Instruments AB
 */

#include "vistk.h"
#include "sgfx.h"
#include "vtkprims.h"


/*-- Low level internals -------------------------------------------*/

inline void _vtk_3Dbox(sg_context_t *vgc, vis_rect_t r, int border,
			char dark, char light)
{
	vis_shrink(r, border);
	vgc->pen.fgcolor = light;
	sg_locate(vgc, r.x, r.y + r.h-1);
	sg_vline(vgc, r.y);
	sg_hline(vgc, r.x + r.w-1);
	vgc->pen.fgcolor = dark;
	sg_vline(vgc, r.y + r.h-1);
	sg_hline(vgc, r.x);
}

inline void _vtk_box(sg_context_t *vgc, vis_rect_t r, int border, char color)
{
	vis_shrink(r, border);
	vgc->pen.fgcolor = color;
	sg_box(vgc, r.x, r.y, r.x+r.w-1, r.y+r.h-1);
}

inline void _vtk_bar(sg_context_t *vgc, vis_rect_t r, int border, char color)
{
	vis_shrink(r, border);
	vgc->pen.fgcolor = color;
	sg_bar(vgc, r.x, r.y, r.x+r.w-1, r.y+r.h-1);
}

/*-- Mid level internals -------------------------------------------*/

inline void _vtk_3Dbox_fat(sg_context_t *vgc, vis_rect_t r, int border,
			vtk_colorspec_t *cs)
{
	_vtk_3Dbox(vgc, r, 0, cs->shadow_3D, cs->light_3D);
	_vtk_3Dbox(vgc, r, 1, cs->dark_3D, cs->highlight_3D);
}

inline void _vtk_3Ddepr_fat(sg_context_t *vgc, vis_rect_t r, int border,
			vtk_colorspec_t *cs)
{
	_vtk_3Dbox(vgc, r, 0, cs->highlight_3D, cs->dark_3D);
	_vtk_3Dbox(vgc, r, 1, cs->light_3D, cs->shadow_3D);
}


/*-- 2D stuff ------------------------------------------------------*/

void vtk_bar(sg_context_t *vgc, vis_rect_t r, char color)
{
	_vtk_bar(vgc, r, 0, color);
}

void vtk_box(sg_context_t *vgc, vis_rect_t r, char color)
{
	_vtk_box(vgc, r, 0, color);
}

void vtk_line_ddown(sg_context_t *vgc, vis_rect_t r, char color)
{
}

void vtk_line_dup(sg_context_t *vgc, vis_rect_t r, char color)
{
}
/*
void vtk_line_left(sg_context_t *vgc, vis_rect_t r, char color)
{
}

void vtk_line_right(sg_context_t *vgc, vis_rect_t r, char color)
{
}

void vtk_line_top(sg_context_t *vgc, vis_rect_t r, char color)
{
}

void vtk_line_bottom(sg_context_t *vgc, vis_rect_t r, char color)
{
}
*/


/*-- Normal 3D -----------------------------------------------------*/

void vtk_3Dbox(sg_context_t *vgc, vis_rect_t r, vtk_colorspec_t *cs)
{
	_vtk_3Dbox(vgc, r, 0, cs->dark_3D, cs->light_3D);
}

void vtk_3Dbar(sg_context_t *vgc, vis_rect_t r, vtk_colorspec_t *cs)
{
	_vtk_bar(vgc, r, 1, cs->face_3D);
	_vtk_3Dbox(vgc, r, 0, cs->dark_3D, cs->light_3D);
}

void vtk_3Ddbox(sg_context_t *vgc, vis_rect_t r, vtk_colorspec_t *cs)
{
	_vtk_3Dbox(vgc, r, 0, cs->light_3D, cs->shadow_3D);
}

void vtk_3Ddepr(sg_context_t *vgc, vis_rect_t r, vtk_colorspec_t *cs)
{
	_vtk_bar(vgc, r, 1, cs->face_3D);
	_vtk_3Dbox(vgc, r, 0, cs->light_3D, cs->dark_3D);
}


/*-- Fat 3D --------------------------------------------------------*/

void vtk_3Dbox_fat(sg_context_t *vgc, vis_rect_t r, vtk_colorspec_t *cs)
{
	_vtk_3Dbox_fat(vgc, r, 0, cs);
}

void vtk_3Dbar_fat(sg_context_t *vgc, vis_rect_t r, vtk_colorspec_t *cs)
{
	_vtk_bar(vgc, r, 2, cs->face_3D);
	_vtk_3Dbox_fat(vgc, r, 0, cs);
}

void vtk_3Ddbox_fat(sg_context_t *vgc, vis_rect_t r, vtk_colorspec_t *cs)
{
	_vtk_3Ddepr_fat(vgc, r, 0, cs);
}

void vtk_3Ddepr_fat(sg_context_t *vgc, vis_rect_t r, vtk_colorspec_t *cs)
{
	_vtk_bar(vgc, r, 2, cs->face_3D);
	_vtk_3Ddepr_fat(vgc, r, 0, cs);
}

/*------------------------------------------------------------------*/
