/*
-----------------------------------------------------------
   sgfx.h - Simple A graphics library for use with
                 svgalib and similar libraries and drivers
                 that present the video RAM as an array of
                 bytes.
-----------------------------------------------------------
 * © 2000-2001 David Olofson
 * Reologica Instruments AB
 */

/* TODO
	* Proper text clipping!

	* Support other pixel formats

	* Offset support for coordinate systems with origo
	  other than in the top-left corner.
*/

#ifndef _SGFX_H_
#define _SGFX_H_

#ifdef __cplusplus
extern "C" {
#endif

#ifndef	SG_PIXEL_SIZE
#define SG_PIXEL_SIZE	1
#endif

#ifndef	SG_PIXEL_BITS
#define SG_PIXEL_BITS	(8*SG_PIXEL_SIZE)
#endif

typedef unsigned char sg_pixel_8_t;
typedef unsigned short sg_pixel_16_t;
typedef struct sg_pixel_24_t
{
	unsigned char r,g,b;
} __attribute__ ((packed)) sg_pixel_24_t;
typedef unsigned int sg_pixel_32_t;

#if	SG_PIXEL_BITS == 8
typedef sg_pixel_8_t sg_pixel_t;
#elif	SG_PIXEL_BITS == 16
typedef sg_pixel_16_t sg_pixel_t;
#elif	SG_PIXEL_BITS == 24
typedef sg_pixel_24_t sg_pixel_t;
#elif	SG_PIXEL_BITS == 32
typedef sg_pixel_32_t sg_pixel_t;
#endif

typedef struct sg_pen_t
{
	int x, y;	/* position */
	int fgcolor;	/* foreground color */
	int fgmod;	/* fg color modifier */
	int bgcolor;	/* background color */
	int bgmod;	/* bg color modifier */
} sg_pen_t;

typedef struct sg_context_t
{
	sg_pixel_t	*buffer;	/* Buffer address */
	int		psize;		/* Bytesize of a pixel */
	int		pitch;		/* Buffer pitch */
	int		x, y;		/* For windows */
	int		w, h;
	sg_pen_t	pen;
} sg_context_t;

/*--------------------------------------------------------------------
	Control
--------------------------------------------------------------------*/
void sg_init(sg_context_t *sgc, void *buf, int ps, int pch, int w, int h);
void sg_init_window(sg_context_t *sgc, sg_context_t *from,
					int x, int y, int w, int h);
void sg_locate(sg_context_t *sgc, int x, int y);
void sg_bump(sg_context_t *sgc, int x, int y);
void sg_cls(sg_context_t *sgc);
void sg_capture(sg_context_t *sgc, sg_pen_t *pen);
void sg_restore(sg_context_t *sgc, sg_pen_t *pen);

/*--------------------------------------------------------------------
	Primitives
--------------------------------------------------------------------*/
void sg_pixel(sg_context_t *sgc, int x, int y);
void sg_line(sg_context_t *sgc, int x, int y);
void sg_bar(sg_context_t *sgc, int x1, int y1, int x2, int y2);
void sg_box(sg_context_t *sgc, int x1, int y1, int x2, int y2);
void sg_qdraw_v(sg_context_t *sgc, int x, int y);
void sg_qdraw_h(sg_context_t *sgc, int x, int y);
void sg_vline(sg_context_t *sgc, int y);
void sg_hline(sg_context_t *sgc, int x);

/*--------------------------------------------------------------------
	Text
--------------------------------------------------------------------*/
void sg_putc(sg_context_t *sgc, char c);
void sg_print(sg_context_t *sgc, const char *s);
void sg_print_rvs(sg_context_t *sgc, const char *s);
void sg_print_num(sg_context_t *sgc, double num);

/*--------------------------------------------------------------------
	Helpers
--------------------------------------------------------------------*/
/* Test if an area of a context is visible.
 *
 * Return:	all 0 = off-screen
 *
 *		bit 0 = visible
 *		bit 1 = clip at left edge
 *		bit 2 = clip at right edge
 *		bit 3 = clip at top edge
 *		bit 4 = clip at bottom edge	*/
int sg_visible(sg_context_t *sgc, int x1, int y1, int x2, int y2);

#ifdef __cplusplus
};
#endif

#endif
