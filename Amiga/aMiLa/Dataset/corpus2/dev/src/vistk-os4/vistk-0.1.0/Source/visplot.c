/*
-----------------------------------------------------------
   visplot.c - Plotting Toolkit for "Visualize"
-----------------------------------------------------------
 * (C) 2000 David Olofson
 * Reologica Instruments AB
 */

#include <stdio.h>
#include <unistd.h>
#include <string.h>
#include <stdlib.h>
#include <sys/types.h>
#include <sys/stat.h>
#include <fcntl.h>

#include "visplot.h"

#define VP_FILE_VERSION	1

/*- PUBLIC VARIABLES -----------------------------------------*/

int vp_timediv = 10;

/*- PRIVATE VARIABLES ----------------------------------------*/

static vp_pen_t pens[VP_PENS] =
{
/*	sel,vis	offset	scale  shift	color	*/
	{1,1,	0,0,	16,256, 0,	VISCL_RED},
	{1,1,	0,0,	16,128, 16,	VISCL_GREEN},
	{1,1,	0,0,	16,4, 0,	VISCL_YELLOW},
	{1,1,	0,0,	16,4, 0,	VISCL_CYAN},

	{1,1,	0,0,	16,4, 0,	VISCL_PURPLE},
	{1,1,	0,0,	16,16, 16,	VISCL_BLUE},
	{1,1,	0,0,	16,4, 0,	VISCL_BROWN},
	{1,1,	0,0,	16,4, 0,	VISCL_TEAL},

	{1,1,	0,0,	16,4, 0,	VISCL_WHITE},
	{1,1,	0,0,	16,4, 0,	VISCL_GRAY75},
	{1,1,	0,0,	16,4, 0,	VISCL_GRAY50},
	{1,1,	0,0,	16,4, 0,	VISCL_GRAY25}
};

static vp_marker_t markers[VP_MARKERS] =
{
/*	kind		pen	pos			*/
	{MK_HORIZONTAL,	0,	0},		/* start */
	{MK_HORIZONTAL,	0,	15000},		/* target */
	{MK_HORIZONTAL,	0,	15000+1500},	/* +10% */
	{MK_HORIZONTAL,	0,	15000-1500},	/* -10% */

	{MK_VERTICAL,	2,	50},		/* Time = 50 */
	{MK_VERTICAL,	2,	150},		/* Time = 150 ms */
	{MK_NONE,	0,	0},
	{MK_VERTICAL,	1,	0},		/* RAMP1 -> RAMP2 */

	{MK_NONE,	0,	0},
	{MK_NONE,	0,	0},
	{MK_NONE,	0,	0},
	{MK_NONE,	0,	0}
};

static int *rec_ch_buf[VP_PENS];
static int rec_ch_size[VP_PENS];
static int rec_ch_len[VP_PENS];

static int use_white_palette = 0;

static int cursor_pos = 0;
static int cursor_zero = 0;
static int cursor_visible = 1;

static int time_visible = 1;
static int markers_visible = 2;

static int draw_lines = 2;


/*------------------------------------------------------------*/

void vp_save(const char *filename)
{
	int f, i;
	vp_file_header_t hdr;

	hdr.version = VP_FILE_VERSION;
	hdr.channels = VP_PENS;
	hdr.markers = VP_MARKERS;
	for(i = 0; i<VP_PENS; ++i)
		hdr.pen[i] = pens[i];
	for(i = 0; i<VP_MARKERS; ++i)
		hdr.marker[i] = markers[i];
	for(i = 0; i<VP_PENS; ++i)
		hdr.datasize[i] = rec_ch_len[i];

	f = open(filename, O_WRONLY | O_CREAT);
	if(!f)
	{
		fprintf(stderr,"Failed to save curves!\n");
		return;
	}
	write(f, &hdr, sizeof(hdr));
	for(i = 0; i<VP_PENS; ++i)
		if(rec_ch_len[i])
			write(f, rec_ch_buf[i], rec_ch_len[i]*sizeof(rec_ch_buf[0]));
	close(f);
	fprintf(stderr,"Pens, channels and markers saved.\n");
}

void vp_save_ascii(const char *filename)
{
	FILE *f;
	int done = 0;
	int pos = 0;
	int i;
	f = fopen(filename, "w");
	if(!f)
	{
		fprintf(stderr,"Failed to save as ASCII!\n");
		return;
	}
	while(!done)
	{
		fprintf(f, "%d", pos);
		done = 1;
		for(i = 0; i<VP_PENS; ++i)
			if(pens[i].selected)
			{
				double val = 0;
				if(pos < rec_ch_len[i])
				{
					done = 0;
					val = rec_ch_buf[i][pos];
				}
				fprintf(f, "\t%.0f",val);
			}
		fprintf(f, "\n");
		++pos;
	}
	fclose(f);
	fprintf(stderr,"Selected channels saved as ASCII.\n");
}

void vp_load(const char *filename)
{
	int f, i;
	vp_file_header_t hdr;
	f = open(filename,O_RDONLY);
	if(!f)
	{
		fprintf(stderr,"Failed to read curves.dat!\n");
		return;
	}
	read(f,&hdr,sizeof(hdr));
	if(hdr.version != 1)
	{
		fprintf(stderr,"File format versions >1 not supported!\n");
		close(f);
		return;
	}
	for(i = 0; i<VP_PENS; ++i)
		pens[i] = hdr.pen[i];
	for(i = 0; i<VP_MARKERS; ++i)
		markers[i] = hdr.marker[i];
	for(i = 0; i<VP_PENS; ++i)
	{
		if(hdr.datasize[i])
		{
			if(rec_ch_size[i] < hdr.datasize[i])
			{
				void *newmem;
				rec_ch_size[i] = hdr.datasize[i];
				newmem = realloc(rec_ch_buf[i], rec_ch_size[i]);
				if(newmem)
					rec_ch_buf[i] = newmem;
				else
				{
					fprintf(stderr,"Couldn't get memory - channel %d will be truncated!\n", i);
					hdr.datasize[i] = rec_ch_size[i];
				}
			}
			read(f, rec_ch_buf[i], hdr.datasize[i]*sizeof(rec_ch_buf[0]));
		}
		rec_ch_len[i] = hdr.datasize[i];
	}
	close(f);
	fprintf(stderr,"Pens, channels and markers loaded.\n");
}

/*------------------------------------------------------------*/

vp_pen_t *vp_get_pen(int pen)
{
	return &pens[pen];
}

vp_marker_t *vp_get_marker(int mrk)
{
	return &markers[mrk];
}

/*------------------------------------------------------------*/

static void plot_pen(vis_visual_t *vis, int *dat, int frames, int pen)
{
	int s;
	int x, y;
	int xx;
	int ox, oy;
	if(!pens[pen].visible)
		return;
	ox = pens[pen].offsx;
	oy = pens[pen].offsy;
	if(draw_lines)
	{
		xx = 0;
		vis->context->pen.fgcolor = pens[pen].color;
		if(2 == draw_lines)
			vis->context->pen.fgmod = VISCMOD_HALFBRIGHT;
		else
			vis->context->pen.fgmod = VISCMOD_NONE;
		x = (xx + ox)/pens[pen].scx;
		y = ((dat[0]>>pens[pen].yshift) + oy)/pens[pen].scy;
		sg_locate(vis->context, x, vis->rect.h-y);
		for(s=1; s<frames; ++s)
		{
			xx += 16;
			x = (xx + ox)/pens[pen].scx;
			y = ((dat[s]>>pens[pen].yshift) + oy)/pens[pen].scy;
			sg_line(vis->context, x, vis->rect.h - y);
		}
		vis->context->pen.fgmod = VISCMOD_NONE;
	}
	if(draw_lines != 1)
	{
		xx = 0;
		for(s=0; s<frames; ++s)
		{
			x = (xx + ox)/pens[pen].scx;
			y = ((dat[s]>>pens[pen].yshift) + oy)/pens[pen].scy;
			if((x >= 0) && (x < vis->rect.w))
				if((y >= 0) && (y < vis->rect.h))
					vis->context->buffer[
							(vis->rect.h-y) * vis->rect.w + x
						] = pens[pen].color;
			xx += 16;
		}
	}
}

void vp_plot_time(vis_visual_t *vis)
{
	int xx = 0;
	vis->context->pen.fgcolor = VISCL_GRAY;
	vis->context->pen.fgmod = VISCMOD_HALFBRIGHT;
	while((xx<<4)/pens[0].scx < vis->rect.w)
	{
		sg_locate(vis->context, (xx<<4)/pens[0].scx, 0);
		sg_vline(vis->context, vis->rect.h);
		xx += vp_timediv;
	}
	vis->context->pen.fgmod = VISCMOD_NONE;
}

void vp_plot_markers(vis_visual_t *vis)
{
	int i;
	vp_pen_t *p;
	vp_marker_t *m;
	vis->context->pen.fgmod = VISCMOD_HALFBRIGHT;
	for(i = 0; i<8; ++i)
	{
		m = &markers[i];
		p = &pens[m->pen];
		vis->context->pen.fgcolor = p->color;
		switch(markers[i].kind)
		{
		  case MK_NONE:
		  	break;
		  case MK_HORIZONTAL:
			sg_locate(vis->context, 0,
					vis->rect.h
					-
					((m->pos + p->offsy) >> p->yshift)
					/ p->scy
				);
			sg_hline(vis->context, vis->rect.w);
		  	break;
		  case MK_VERTICAL:
			sg_locate(vis->context,
					((m->pos<<4) + p->offsx) / p->scx,
					0
				);
			sg_vline(vis->context, vis->rect.h);
		  	break;
		}
	}
	vis->context->pen.fgmod = VISCMOD_NONE;
}

void vp_plot_cursor(vis_visual_t *vis)
{
	sg_pen_t p;
	int xc = ((cursor_pos<<4) + pens[0].offsx) / pens[0].scx;
	int xz = ((cursor_zero<<4) + pens[0].offsx) / pens[0].scx;
	sg_context_t *con = vis->context;

	con->pen.fgcolor = VISCL_GRAY50;
	sg_locate(con, xz, 0);
	sg_vline(con, vis->rect.h);
	sg_bump(con, 1, -24);
	sg_capture(con, &p);
	con->pen.fgcolor = VISCL_GRAY25;
	sg_print_rvs(con, "\037Z");
	sg_restore(con, &p);
	con->pen.fgcolor = VISCL_YELLOW;
	sg_print(con, "\037Z");

	con->pen.fgcolor = VISCL_GRAY50;
	sg_locate(con, xc, 0);
	sg_vline(con, vis->rect.h);
	sg_bump(con, 1, -24);
	sg_capture(con, &p);
	con->pen.fgcolor = VISCL_YELLOW;
	sg_print_rvs(con, "\037C");
	sg_restore(con, &p);
	con->pen.fgcolor = VISCL_BLACK;
	sg_print(con, "\037C");
}

void vp_plot_cursor_info(vis_visual_t *vis)
{
	int i;
	char buf[80];
	sg_locate(vis->context, 4, 4);
	snprintf(buf,80,"\037 Cursor: %11d \n",cursor_pos);
	vis->context->pen.fgcolor = VISCL_GRAY50;
	sg_print_rvs(vis->context, buf);
	snprintf(buf,80,"\037   Zero: %11d \n",cursor_zero);
	sg_print_rvs(vis->context, buf);
	snprintf(buf,80,"\037   Dist: %11d \n",cursor_pos-cursor_zero);
	sg_print_rvs(vis->context, buf);
	sg_bump(vis->context, 0, 1);
	for(i=0; i<VP_PENS;  ++i)
	{
		char *cm;
		if(pens[i].visible)
			cm = " *";
		else
			cm = "  ";
		if(cursor_pos<rec_ch_len[i])
		{
			int y = rec_ch_buf[i][cursor_pos];
			snprintf(buf,80,"\037Ch %2d: %12d%s\n",i,y,cm);
		}
		else
			snprintf(buf,80,"\037Ch %2d:   <no data> %s\n",i,cm);
		vis->context->pen.fgcolor = pens[i].color;
		sg_print(vis->context, buf);
	}
}

void vp_plot_selector(vis_visual_t *vis)
{
	int i;
	char buf[10];
	sg_locate(vis->context, 4, vis->rect.h - 8 - 4);
	for(i=0; i<VP_PENS;  ++i)
	{
		snprintf(buf,10,"\037%2d",i);
		vis->context->pen.fgcolor = pens[i].color;
		if(pens[i].selected)
			sg_print_rvs(vis->context, buf);
		else
			sg_print(vis->context, buf);
		sg_bump(vis->context, 1, 0);
	}
}

void vp_plot_markers_info(vis_visual_t *vis)
{
	int i;
	char buf[80];
	sg_locate(vis->context, vis->rect.w - 4 - 6*19 - 1, 4);
	snprintf(buf,80,"\037 ---- Markers ---- \n");
	vis->context->pen.fgcolor = VISCL_GRAY50;
	sg_print_rvs(vis->context, buf);
	sg_bump(vis->context, 0, 1);
	for(i=0; i<VP_MARKERS;  ++i)
	{
		switch(markers[i].kind)
		{
		  case MK_NONE:
		  	continue;
		  case MK_VERTICAL:
			snprintf(buf,80,"\037M%2d: x=%12d\n",i,markers[i].pos);
			break;
		  case MK_HORIZONTAL:
			snprintf(buf,80,"\037M%2d: y=%12d\n",i,markers[i].pos);
			break;
		}
		vis->context->pen.fgcolor = pens[markers[i].pen].color;
		sg_print(vis->context, buf);
	}
}

void vp_plot_pen(vis_visual_t *vis, int pen)
{
	plot_pen(vis, rec_ch_buf[pen], rec_ch_len[pen], pen);
}

void vp_plot(vis_visual_t *vis)
{
	int p;
	if(use_white_palette >= 0)
	{
		if(use_white_palette)
			vis_set_white_palette(vis);
		else
			vis_set_black_palette(vis);
		use_white_palette = -1;
	}
	if(time_visible)
		vp_plot_time(vis);
	if(markers_visible)
		vp_plot_markers(vis);
	if(cursor_visible)
		vp_plot_cursor(vis);
	for(p=0; p<VP_PENS; ++p)
		vp_plot_pen(vis,p);
	if(cursor_visible)
		vp_plot_cursor_info(vis);
	if(2 == markers_visible)
		vp_plot_markers_info(vis);
	vp_plot_selector(vis);
}

/*------------------------------------------------------------*/

void vp_close()
{
	int i;
	for(i=0; i<VP_PENS; ++i)
		free(rec_ch_buf[i]);
}

int vp_init(int frames)
{
	int i;
	for(i=0; i<VP_PENS; ++i)
		rec_ch_buf[i] = 0;
	for(i=0; i<VP_PENS; ++i)
	{
		if(!(rec_ch_buf[i]=malloc(frames*sizeof(int))))
		{
			vp_close();
			return 0;
		}
		rec_ch_size[i] = frames;
		rec_ch_len[i] = 0;
	}
	return 1;
}

void vp_reset()
{
	int i;
	for(i=0; i<VP_PENS; ++i)
		rec_ch_len[i] = 0;
}

/*------------------------------------------------------------*/

void vp_record(int dat, int pen)
{
	if(!(rec_ch_size[pen]-rec_ch_len[pen]))
		return;
	if(rec_ch_size[pen]-rec_ch_len[pen] == 1)
		fprintf(stderr,"vp_record: Buffer full!\n");
	rec_ch_buf[pen][rec_ch_len[pen]] = dat;
	++rec_ch_len[pen];
}

void vp_record_buffer(int *dat, int frames, int pen)
{
	if(!(rec_ch_size[pen]-rec_ch_len[pen]))
		return;
	if(frames > rec_ch_size[pen]-rec_ch_len[pen])
	{
		frames = rec_ch_size[pen]-rec_ch_len[pen];
		fprintf(stderr,"vp_record_buffer: Buffer overflow!\n");
	}
	memcpy(rec_ch_buf[pen]+rec_ch_len[pen],dat,frames*sizeof(int));
	rec_ch_len[pen] += frames;
}

int vp_get_position(int pen)
{
	return rec_ch_len[pen];
}

/*------------------------------------------------------------*/

#define with_selected(ind)			\
	for(ind=0; ind<VP_PENS; ++ind)		\
		if(pens[ind].selected)

#define with_all(ind)				\
	for(ind=0; ind<VP_PENS; ++ind)

/*------------------------------------------------------------*/

int vp_process_event(vis_event_t *event)
{
	switch(event->kind)
	{
	  case viseKeyDown:
	  case viseKeyRepeat:
		return vp_process_key(event->data.key);
	  case viseKeyUp:
	  	return 0;
	  default:
	  	return 0;
	}
}

/*------------------------------------------------------------*/
int vp_process_key(vis_key_t k)
{
	int update = 0;
	int p;
	int pan_factor = 10;
	int shift = k.modifiers & VTKCM_SHIFT;
	int ctrl = k.modifiers & VTKCM_CTRL;
	int alt = k.modifiers & VTKCM_ALT;

#if 0
	switch(VISK_GET_KIND(c))
	{
	  case VISK_PRESS:
	  case VISK_REPEAT:
	  	break;
	  case VISK_RELEASE:
	  default:
		return 0;
	}
#endif

	if(shift)
		pan_factor = 100;
	else if(alt)
	  	pan_factor = 1;

	switch(k.control)
	{
	  /*
	   * Panning
	   */
	  case VTKC_UP:
		with_selected(p)
			pens[p].offsy -= pens[p].scy*pan_factor;
	  	update = 1;
	  	break;
	  case VTKC_DOWN:
		with_selected(p)
			pens[p].offsy += pens[p].scy*pan_factor;
	  	update = 1;
	  	break;
	  case VTKC_LEFT:
		with_all(p)
			pens[p].offsx += pens[p].scx*pan_factor;
	  	update = 1;
	  	break;
	  case VTKC_RIGHT:
		with_all(p)
			pens[p].offsx -= pens[p].scx*pan_factor;
	  	update = 1;
	  	break;

	  /*
	   * Cursor control
	   */
	  case VTKC_PREV:
	  	if(ctrl)
			cursor_zero -= pan_factor;
		else
			cursor_pos -= pan_factor;
	  	update = 1;
		break;
	  case VTKC_NEXT:
	  	if(ctrl)
			cursor_zero += pan_factor;
		else
			cursor_pos += pan_factor;
	  	update = 1;
		break;
	  default:
		break;
	}

	switch(k.unicode)
	{
	  /*
	   * Zooming
	   */
	  case '+':
		with_selected(p)
			if( !(pens[p].scy /= 2) )
				pens[p].scy = 1;
	  	update = 1;
	  	break;
	  case '-':
		with_selected(p)
			if(pens[p].scy<0x3fffffff)
				pens[p].scy *= 2;
	  	update = 1;
	  	break;
	  case '/':
		with_all(p)
			if(pens[p].scx<0x3fffffff)
				pens[p].scx *= 2;
	  	update = 1;
	  	break;
	  case '*':
		with_all(p)
			if( !(pens[p].scx /= 2) )
				pens[p].scx = 1;
	  	update = 1;
	  	break;
			
	  /*
	   * Cursor control
	   */
	  case 'c':
	  case 'C':
	  	if(shift)
		{
			int s = cursor_pos;
			cursor_pos = cursor_zero;
			cursor_zero = s;
		}
		else
			cursor_visible = !cursor_visible;
		update = 1;
		break;
	  case 'z':
	  case 'Z':
		if(shift)
			cursor_zero = 0;
		else
			cursor_zero = cursor_pos;
	  	update = 1;
		break;

	  /*
	   * Time grid control
	   */
	  case 't':
	  case 'T':
		time_visible = !time_visible;
		update = 1;
		break;

	  /*
	   * Marker control
	   */
	  case 'm':
	  case 'M':
		++markers_visible;
		if(markers_visible>2)
			markers_visible = 0;
	  	update = 1;
		break;

	  /*
	   * Lines/pixels drawing mode
	   */
	  case 'l':
	  case 'L':
		++draw_lines;
		if(draw_lines>2)
			draw_lines = 0;
	  	update = 1;
		break;

	  /*
	   * Color map selection
	   */
	  case 'b':
	  case 'B':
		use_white_palette = 0;
	  	update = 1;
	  	break;
	  case 'w':
	  case 'W':
		use_white_palette = 1;
	  	update = 1;
	  	break;
	}

	/*
	 * Handle function keys
	 */
	if((k.control >= VTKC_F1) && (k.control <= VTKC_F12))
	{
		int key = k.control - VTKC_F1;
		/*
		 * Visible switching
		 */
		if( k.modifiers &&(VTKCM_SHIFT | VTKCM_CTRL | VTKCM_ALT)
						== VTKCM_SHIFT )
			pens[key].visible = !pens[key].visible;
		else
			pens[key].selected = !pens[key].selected;
		  	update = 1;
	}

	return update;
}
/*------------------------------------------------------------*/

void vp_init_marker(int mrk, vp_marker_kind_t kind, int pen, int pos)
{
	markers[mrk].selected = 0;
	markers[mrk].visible = (kind != MK_NONE);
	markers[mrk].kind = kind;
	markers[mrk].pen = pen;
	markers[mrk].pos = pos;
}

void vp_locate_marker(int mrk, int pos)
{
	markers[mrk].pos = pos;
}

void vp_place_marker(int mrk, int pen, int offset)
{
	switch(markers[mrk].kind)
	{
	  case MK_NONE:
		markers[mrk].pos = offset;
	  	break;
	  case MK_HORIZONTAL:
	  	/*
		 * Grab current value from specified pen
		 */
		if(rec_ch_len[pen])
			markers[mrk].pos = rec_ch_buf[pen][rec_ch_len[pen]-1] + offset;
		else
			markers[mrk].pos = offset;
	  	break;
	  case MK_VERTICAL:
	  	/*
		 * Grab current time from specified pen
		 */
		markers[mrk].pos = rec_ch_len[pen] + offset;
	  	break;
	}
}

/*------------------------------------------------------------*/

void vp_init_pen(int pen, int scx, int scy, int shy)
{
	pens[pen].offsx = 0;
	pens[pen].offsy = 0;
	pens[pen].scx = scx;
	pens[pen].scy = scy;
	pens[pen].yshift = shy;
}

/*------------------------------------------------------------*/
