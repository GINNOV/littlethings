/*
-----------------------------------------------------------
   visplot.h - Plotting Toolkit for "Visualize"
-----------------------------------------------------------
 * (C) 2000 David Olofson
 * Reologica Instruments AB
 */

#ifndef _VISPLOT_H_
#define _VISPLOT_H_

#include "visualize.h"

#define	VP_PENS		12
#define	VP_MARKERS	12

/*------------------------------------------------------------*/

typedef struct vp_pen_t
{
	int selected;
	int visible;
	int offsx, offsy;
	int scx, scy;
	int yshift;
	int color;
} vp_pen_t;

typedef enum vp_marker_kind_t
{
	MK_NONE,
	MK_HORIZONTAL,
	MK_VERTICAL
} vp_marker_kind_t;

typedef struct vp_marker_t
{
	int selected;
	int visible;
	vp_marker_kind_t kind;
	int pen;	/* Scale + color from this pen */
	int pos;	/* x or y in real units */
} vp_marker_t;

/*typedef struct vp_plotter_t
{
	vp_pen_t *pens;
	vp_marker_t *markers;
	vis_visual_t *visual;
} vp_plotter_t;
*/

typedef struct vp_file_header_t
{
	int		version;	/* file format version */
	int		channels;
	int		markers;
	vp_pen_t	pen[VP_PENS];
	vp_marker_t	marker[VP_MARKERS];
	int		datasize[VP_PENS];
} vp_file_header_t;

/*------------------------------------------------------------*/

extern int vp_timediv;

/*------------------------------------------------------------*/

int vp_init(int frames);
void vp_reset();
//void vp_set_visual(vp_plotter_t *plotter, vis_visual_t *vis);
void vp_close();
void vp_save(const char *filename);
void vp_save_ascii(const char *filename);
void vp_load(const char *filename);

vp_pen_t *vp_get_pen(int pen);
vp_marker_t *vp_get_marker(int mrk);

/*
 * Recording some data
 */
void vp_record(int dat, int pen);
void vp_record_buffer(int *dat, int frames, int pen);
int vp_get_position(int pen);

/*
 * Displaying the data
 */
void vp_plot(vis_visual_t *vis);
void vp_plot_pen(vis_visual_t *vis, int pen);
void vp_plot_time(vis_visual_t *vis);
void vp_plot_markers(vis_visual_t *vis);

/*
 * UI
 */
int vp_process_key(vis_key_t k);
int vp_process_event(vis_event_t *event);

/*
 * Pen functions
 */
void vp_init_pen(int pen, int scx, int scy, int shy);

/*
 * Marker functions
 */
void vp_init_marker(int mrk, vp_marker_kind_t kind, int pen, int pos);
void vp_locate_marker(int mrk, int pos);
void vp_place_marker(int mrk, int pen, int offset);

/*------------------------------------------------------------*/

#endif
