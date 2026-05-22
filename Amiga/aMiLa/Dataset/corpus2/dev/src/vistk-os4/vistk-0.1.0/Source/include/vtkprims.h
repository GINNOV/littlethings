/*
-----------------------------------------------------------
   vtkprims.h - The "Visualize" Toolkit primitives
-----------------------------------------------------------
 * (C) 2000 David Olofson
 * Reologica Instruments AB
 */

#ifndef _VTKPRIMS_H_
#define _VTKPRIMS_H_

#ifdef __cplusplus
extern "C" {
#endif

#include "vistk.h"
#include "sgfx.h"

void vtk_box(sg_context_t *vgc, vis_rect_t r, char color);
void vtk_bar(sg_context_t *vgc, vis_rect_t r, char color);
void vtk_line_ddown(sg_context_t *vgc, vis_rect_t r, char color);
void vtk_line_dup(sg_context_t *vgc, vis_rect_t r, char color);
void vtk_line_left(sg_context_t *vgc, vis_rect_t r, char color);
void vtk_line_right(sg_context_t *vgc, vis_rect_t r, char color);
void vtk_line_top(sg_context_t *vgc, vis_rect_t r, char color);
void vtk_line_bottom(sg_context_t *vgc, vis_rect_t r, char color);

void vtk_3Dbox(sg_context_t *vgc, vis_rect_t r, vtk_colorspec_t *cs);
void vtk_3Dbar(sg_context_t *vgc, vis_rect_t r, vtk_colorspec_t *cs);

void vtk_3Ddbox(sg_context_t *vgc, vis_rect_t r, vtk_colorspec_t *cs);
void vtk_3Ddepr(sg_context_t *vgc, vis_rect_t r, vtk_colorspec_t *cs);

void vtk_3Dbox_fat(sg_context_t *vgc, vis_rect_t r, vtk_colorspec_t *cs);
void vtk_3Dbar_fat(sg_context_t *vgc, vis_rect_t r, vtk_colorspec_t *cs);

void vtk_3Ddbox_fat(sg_context_t *vgc, vis_rect_t r, vtk_colorspec_t *cs);
void vtk_3Ddepr_fat(sg_context_t *vgc, vis_rect_t r, vtk_colorspec_t *cs);

#ifdef __cplusplus
};
#endif

#endif
