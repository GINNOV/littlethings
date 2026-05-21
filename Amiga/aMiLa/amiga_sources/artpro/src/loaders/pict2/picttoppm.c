/*
 * picttoppm.c -- convert a MacIntosh PICT file to PPM format.
 *
 * This program is normally part of the PBM+ utilities, but you
 * can compile a slightly crippled version without PBM+ by
 * defining STANDALONE (e.g., cc -DSTANDALONE picttoppm.c).
 * However, if you want this you probably want PBM+ sooner or
 * later so grab it now.
 *
 * Copyright 1989,1992,1993 George Phillips
 *
 * Permission to use, copy, modify, and distribute this software and its
 * documentation for any purpose and without fee is hereby granted, provided
 * that the above copyright notice appear in all copies and that both that
 * copyright notice and this permission notice appear in supporting
 * documentation.  This software is provided "as is" without express or
 * implied warranty.
 *
 * George Phillips <phillips@cs.ubc.ca>
 * Department of Computer Science
 * University of British Columbia
 *
 * $Id: picttoppm.c,v 1.7 1993/10/26 22:40:31 phillips Exp phillips $
 */

#ifdef STANDALONE

#include <stdio.h>
#ifdef __STDC__
#define ARGS(x) x
#else
#define ARGS(x) ()
#endif /* __STDC__ */
#define PPM_ASSIGN(p, R, G, B) (p).r = R; (p).g = G; (p).b = B
#define max(x, y) ((x) > (y) ? (x) : (y))
#define min(x, y) ((x) < (y) ? (x) : (y))
typedef unsigned char pixval;
typedef struct { pixval r, g, b; } pixel;
void ppm_init();
FILE* pm_openr();
void pm_usage();
void pm_message();
void pm_error();
int pm_keymatch();
void ppm_writeppminit();
void ppm_writeppmrow();
void pm_close();
pixel* ppm_allocrow();

#else

#include "ppm.h"

#endif /* STANDALONE */

#include "pbmfont.h"

/*
 * Typical byte, 2 byte and 4 byte integers.
 */
typedef unsigned char byte;
typedef char signed_byte; /* XXX */
typedef unsigned short word;
typedef unsigned long longword;

/*
 * Data structures for QuickDraw (and hence PICT) stuff.
 */

struct Rect {
	word top;
	word left;
	word bottom;
	word right;
};

struct pixMap {
	struct Rect Bounds;
	word version;
	word packType;
	longword packSize;
	longword hRes;
	longword vRes;
	word pixelType;
	word pixelSize;
	word cmpCount;
	word cmpSize;
	longword planeBytes;
	longword pmTable;
	longword pmReserved;
};

struct RGBColour {
	word red;
	word green;
	word blue;
};

struct Point {
	word x;
	word y;
};

struct Pattern {
	byte pix[64];
};

typedef void (*transfer_func) ARGS(( struct RGBColour* src, struct RGBColour* dst ));

static char* stage;
static struct Rect picFrame;
static word* red;
static word* green;
static word* blue;
static word rowlen;
static word collen;
static longword planelen;
static int verbose;
static int fullres;
static int recognize_comment;

static struct RGBColour black = { 0, 0, 0 };
static struct RGBColour white = { 0xffff, 0xffff, 0xffff };

/* various bits of drawing state */
static struct RGBColour foreground = { 0, 0, 0 };
static struct RGBColour background = { 0xffff, 0xffff, 0xffff };
static struct RGBColour op_colour;
static struct Pattern bkpat;
static struct Pattern fillpat;
static struct Rect clip_rect;
static struct Rect cur_rect;
static struct Point current;
static struct Pattern pen_pat;
static word pen_width;
static word pen_height;
static word pen_mode;
static transfer_func pen_trf;
static word text_font;
static byte text_face;
static word text_mode;
static transfer_func text_trf;
static word text_size;
static struct font* tfont;

/* state for magic printer comments */
static int ps_text;
static byte ps_just;
static byte ps_flip;
static word ps_rotation;
static byte ps_linespace;
static int ps_cent_x;
static int ps_cent_y;
static int ps_cent_set;

struct opdef {
	char* name;
	int len;
	void (*impl) ARGS((int));
	char* description;
};

struct blit_info {
	struct Rect	srcRect;
	struct Rect	srcBounds;
	int		srcwid;
	byte*		srcplane;
	int		pixSize;
	struct Rect	dstRect;
	struct RGBColour* colour_map;
	int		mode;
	struct blit_info* next;
};

static struct blit_info* blit_list = 0;
static struct blit_info** last_bl = &blit_list;

#define WORD_LEN (-1)

static void interpret_pict ARGS(( void ));
static void alloc_planes ARGS(( void ));
static void compact_plane ARGS(( word* plane, int planelen ));
static void output_ppm ARGS(( int version ));
static void Opcode_9A ARGS(( int version ));
static void BitsRect ARGS(( int version ));
static void BitsRegion ARGS(( int version ));
static void do_bitmap ARGS(( int version, int rowBytes, int is_region ));
static void do_pixmap ARGS(( int version, word rowBytes, int is_region ));
static transfer_func transfer ARGS(( int ));
static void draw_pixel ARGS (( int, int, struct RGBColour*, transfer_func ));
static int blit ARGS((
    struct Rect* srcRect, struct Rect* srcBounds, int srcwid, byte* srcplane,
    int pixSize, struct Rect* dstRect, struct Rect* dstBounds, int dstwid,
    struct RGBColour* colour_map, int mode ));
static struct blit_info* add_blit_list ARGS(( void ));
static void do_blits ARGS(( void ));
static byte* unpackbits ARGS(( struct Rect* bounds, word rowBytes, int pixelSize ));
static byte* expand_buf ARGS(( byte* buf, int* len, int bits_per_pixel ));
static void Clip ARGS(( int version ));
static void read_pixmap ARGS(( struct pixMap* p, word* rowBytes ));
static struct RGBColour* read_colour_table ARGS(( void ));
static void BkPixPat ARGS(( int version ));
static void PnPixPat ARGS(( int version ));
static void FillPixPat ARGS(( int version ));
static void read_pattern ARGS(( void ));
static void read_8x8_pattern ARGS(( struct Pattern* ));
static void BkPat ARGS(( int version ));
static void PnPat ARGS(( int version ));
static void FillPat ARGS(( int version ));
static void PnSize ARGS(( int version ));
static void PnMode ARGS(( int version ));
static void OpColor ARGS(( int version ));
static void RGBFgCol ARGS(( int version ));
static void RGBBkCol ARGS(( int version ));

static void Line ARGS(( int version ));
static void LineFrom ARGS(( int version ));
static void ShortLine ARGS(( int version ));
static void ShortLineFrom ARGS(( int version ));

static void PnLocHFrac ARGS(( int version ));
static void TxFont ARGS(( int version ));
static void TxFace ARGS(( int version ));
static void TxMode ARGS(( int version ));
static void TxSize ARGS(( int version ));
static void skip_text ARGS(( void ));
static void LongText ARGS(( int version ));
static void DHText ARGS(( int version ));
static void DVText ARGS(( int version ));
static void DHDVText ARGS(( int version ));
static void do_text ARGS(( word x, word y ));
static void do_ps_text ARGS(( word x, word y ));
static void rotate ARGS(( int* x, int* y));
static void skip_poly_or_region ARGS(( int version ));
static void LongComment ARGS(( int version ));
static void ShortComment ARGS(( int version ));

static int rectwidth ARGS(( struct Rect* r ));
static int rectheight ARGS(( struct Rect* r ));
static int rectsamesize ARGS(( struct Rect* r1, struct Rect* r2 ));
static void rectinter ARGS(( struct Rect* r1, struct Rect* r2, struct Rect* r3 ));
static void rectscale ARGS(( struct Rect* r, double xscale, double yscale ));

static void read_rect ARGS(( struct Rect* r ));
static void dump_rect ARGS(( char* s, struct Rect* r ));

static void do_paintRect ARGS(( struct Rect* r ));
static void paintRect ARGS(( int version ));
static void paintSameRect ARGS(( int version ));
static void do_frameRect ARGS(( struct Rect* r ));
static void frameRect ARGS(( int version ));
static void frameSameRect ARGS(( int version ));
static void paintPoly ARGS(( int version ));

static word get_op ARGS(( int version ));

static longword read_long ARGS(( void ));
static word read_word ARGS(( void ));
static byte read_byte ARGS(( void ));
static signed_byte read_signed_byte ARGS(( void ));

static void skip ARGS(( int n ));
static void read_n ARGS(( int n, char* buf ));

static struct font* get_font ARGS(( int font, int size, int style ));

static int load_fontdir ARGS((char *file));
static void read_rgb ARGS((struct RGBColour *rgb));
static void draw_pen_rect ARGS((struct Rect *r));
static void draw_pen ARGS((int x, int y));
static void read_point ARGS((struct Point *p));
static void read_short_point ARGS((struct Point *p));
static void scan_line ARGS((short x1, short y1, short x2, short y2));
static void scan_poly ARGS((int np, struct Point pts[]));
static void poly_sort ARGS((int sort_index, struct Point points[]));
static void picComment ARGS((word type, int length));
static int abs_value ARGS((int x));
/*
 * a table of the first 194(?) opcodes.  The table is too empty.
 *
 * Probably could use an entry specifying if the opcode is valid in version
 * 1, etc.
 */

/* for reserved opcodes of known length */
#define res(length) \
{ "reserved", (length), NULL, "reserved for Apple use" }

/* for reserved opcodes of length determined by a function */
#define resf(skipfunction) \
{ "reserved", NA, (skipfunction), "reserved for Apple use" }

/* seems like RGB colours are 6 bytes, but Apple says they're variable */
/* I'll use 6 for now as I don't care that much. */
#define RGB_LEN (6)

#define NA (0)

static struct opdef optable[] = {
/* 0x00 */	{ "NOP", 0, NULL, "nop" },
/* 0x01 */	{ "Clip", NA, Clip, "clip" },
/* 0x02 */	{ "BkPat", 8, BkPat, "background pattern" },
/* 0x03 */	{ "TxFont", 2, TxFont, "text font (word)" },
/* 0x04 */	{ "TxFace", 1, TxFace, "text face (byte)" },
/* 0x05 */	{ "TxMode", 2, TxMode, "text mode (word)" },
/* 0x06 */	{ "SpExtra", 4, NULL, "space extra (fixed point)" },
/* 0x07 */	{ "PnSize", 4, PnSize, "pen size (point)" },
/* 0x08 */	{ "PnMode", 2, PnMode, "pen mode (word)" },
/* 0x09 */	{ "PnPat", 8, PnPat, "pen pattern" },
/* 0x0a */	{ "FillPat", 8, FillPat, "fill pattern" },
/* 0x0b */	{ "OvSize", 4, NULL, "oval size (point)" },
/* 0x0c */	{ "Origin", 4, NULL, "dh, dv (word)" },
/* 0x0d */	{ "TxSize", 2, TxSize, "text size (word)" },
/* 0x0e */	{ "FgColor", 4, NULL, "foreground color (longword)" },
/* 0x0f */	{ "BkColor", 4, NULL, "background color (longword)" },
/* 0x10 */	{ "TxRatio", 8, NULL, "numerator (point), denominator (point)" },
/* 0x11 */	{ "Version", 1, NULL, "version (byte)" },
/* 0x12 */	{ "BkPixPat", NA, BkPixPat, "color background pattern" },
/* 0x13 */	{ "PnPixPat", NA, PnPixPat, "color pen pattern" },
/* 0x14 */	{ "FillPixPat", NA, FillPixPat, "color fill pattern" },
/* 0x15 */	{ "PnLocHFrac", 2, PnLocHFrac, "fractional pen position" },
/* 0x16 */	{ "ChExtra", 2, NULL, "extra for each character" },
/* 0x17 */	res(0),
/* 0x18 */	res(0),
/* 0x19 */	res(0),
/* 0x1a */	{ "RGBFgCol", RGB_LEN, RGBFgCol, "RGB foreColor" },
/* 0x1b */	{ "RGBBkCol", RGB_LEN, RGBBkCol, "RGB backColor" },
/* 0x1c */	{ "HiliteMode", 0, NULL, "hilite mode flag" },
/* 0x1d */	{ "HiliteColor", RGB_LEN, NULL, "RGB hilite color" },
/* 0x1e */	{ "DefHilite", 0, NULL, "Use default hilite color" },
/* 0x1f */	{ "OpColor", NA, OpColor, "RGB OpColor for arithmetic modes" },
/* 0x20 */	{ "Line", 8, Line, "pnLoc (point), newPt (point)" },
/* 0x21 */	{ "LineFrom", 4, LineFrom, "newPt (point)" },
/* 0x22 */	{ "ShortLine", 6, ShortLine, "pnLoc (point, dh, dv (-128 .. 127))" },
/* 0x23 */	{ "ShortLineFrom", 2, ShortLineFrom, "dh, dv (-128 .. 127)" },
/* 0x24 */	res(WORD_LEN),
/* 0x25 */	res(WORD_LEN),
/* 0x26 */	res(WORD_LEN),
/* 0x27 */	res(WORD_LEN),
/* 0x28 */	{ "LongText", NA, LongText, "txLoc (point), count (0..255), text" },
/* 0x29 */	{ "DHText", NA, DHText, "dh (0..255), count (0..255), text" },
/* 0x2a */	{ "DVText", NA, DVText, "dv (0..255), count (0..255), text" },
/* 0x2b */	{ "DHDVText", NA, DHDVText, "dh, dv (0..255), count (0..255), text" },
/* 0x2c */	res(WORD_LEN),
/* 0x2d */	res(WORD_LEN),
/* 0x2e */	res(WORD_LEN),
/* 0x2f */	res(WORD_LEN),
/* 0x30 */	{ "frameRect", 8, frameRect, "rect" },
/* 0x31 */	{ "paintRect", 8, paintRect, "rect" },
/* 0x32 */	{ "eraseRect", 8, NULL, "rect" },
/* 0x33 */	{ "invertRect", 8, NULL, "rect" },
/* 0x34 */	{ "fillRect", 8, NULL, "rect" },
/* 0x35 */	res(8),
/* 0x36 */	res(8),
/* 0x37 */	res(8),
/* 0x38 */	{ "frameSameRect", 0, frameSameRect, "rect" },
/* 0x39 */	{ "paintSameRect", 0, paintSameRect, "rect" },
/* 0x3a */	{ "eraseSameRect", 0, NULL, "rect" },
/* 0x3b */	{ "invertSameRect", 0, NULL, "rect" },
/* 0x3c */	{ "fillSameRect", 0, NULL, "rect" },
/* 0x3d */	res(0),
/* 0x3e */	res(0),
/* 0x3f */	res(0),
/* 0x40 */	{ "frameRRect", 8, NULL, "rect" },
/* 0x41 */	{ "paintRRect", 8, NULL, "rect" },
/* 0x42 */	{ "eraseRRect", 8, NULL, "rect" },
/* 0x43 */	{ "invertRRect", 8, NULL, "rect" },
/* 0x44 */	{ "fillRRrect", 8, NULL, "rect" },
/* 0x45 */	res(8),
/* 0x46 */	res(8),
/* 0x47 */	res(8),
/* 0x48 */	{ "frameSameRRect", 0, NULL, "rect" },
/* 0x49 */	{ "paintSameRRect", 0, NULL, "rect" },
/* 0x4a */	{ "eraseSameRRect", 0, NULL, "rect" },
/* 0x4b */	{ "invertSameRRect", 0, NULL, "rect" },
/* 0x4c */	{ "fillSameRRect", 0, NULL, "rect" },
/* 0x4d */	res(0),
/* 0x4e */	res(0),
/* 0x4f */	res(0),
/* 0x50 */	{ "frameOval", 8, NULL, "rect" },
/* 0x51 */	{ "paintOval", 8, NULL, "rect" },
/* 0x52 */	{ "eraseOval", 8, NULL, "rect" },
/* 0x53 */	{ "invertOval", 8, NULL, "rect" },
/* 0x54 */	{ "fillOval", 8, NULL, "rect" },
/* 0x55 */	res(8),
/* 0x56 */	res(8),
/* 0x57 */	res(8),
/* 0x58 */	{ "frameSameOval", 0, NULL, "rect" },
/* 0x59 */	{ "paintSameOval", 0, NULL, "rect" },
/* 0x5a */	{ "eraseSameOval", 0, NULL, "rect" },
/* 0x5b */	{ "invertSameOval", 0, NULL, "rect" },
/* 0x5c */	{ "fillSameOval", 0, NULL, "rect" },
/* 0x5d */	res(0),
/* 0x5e */	res(0),
/* 0x5f */	res(0),
/* 0x60 */	{ "frameArc", 12, NULL, "rect, startAngle, arcAngle" },
/* 0x61 */	{ "paintArc", 12, NULL, "rect, startAngle, arcAngle" },
/* 0x62 */	{ "eraseArc", 12, NULL, "rect, startAngle, arcAngle" },
/* 0x63 */	{ "invertArc", 12, NULL, "rect, startAngle, arcAngle" },
/* 0x64 */	{ "fillArc", 12, NULL, "rect, startAngle, arcAngle" },
/* 0x65 */	res(12),
/* 0x66 */	res(12),
/* 0x67 */	res(12),
/* 0x68 */	{ "frameSameArc", 4, NULL, "rect, startAngle, arcAngle" },
/* 0x69 */	{ "paintSameArc", 4, NULL, "rect, startAngle, arcAngle" },
/* 0x6a */	{ "eraseSameArc", 4, NULL, "rect, startAngle, arcAngle" },
/* 0x6b */	{ "invertSameArc", 4, NULL, "rect, startAngle, arcAngle" },
/* 0x6c */	{ "fillSameArc", 4, NULL, "rect, startAngle, arcAngle" },
/* 0x6d */	res(4),
/* 0x6e */	res(4),
/* 0x6f */	res(4),
/* 0x70 */	{ "framePoly", NA, skip_poly_or_region, "poly" },
/* 0x71 */	{ "paintPoly", NA, paintPoly, "poly" },
/* 0x72 */	{ "erasePoly", NA, skip_poly_or_region, "poly" },
/* 0x73 */	{ "invertPoly", NA, skip_poly_or_region, "poly" },
/* 0x74 */	{ "fillPoly", NA, skip_poly_or_region, "poly" },
/* 0x75 */	resf(skip_poly_or_region),
/* 0x76 */	resf(skip_poly_or_region),
/* 0x77 */	resf(skip_poly_or_region),
/* 0x78 */	{ "frameSamePoly", 0, NULL, "poly (NYI)" },
/* 0x79 */	{ "paintSamePoly", 0, NULL, "poly (NYI)" },
/* 0x7a */	{ "eraseSamePoly", 0, NULL, "poly (NYI)" },
/* 0x7b */	{ "invertSamePoly", 0, NULL, "poly (NYI)" },
/* 0x7c */	{ "fillSamePoly", 0, NULL, "poly (NYI)" },
/* 0x7d */	res(0),
/* 0x7e */	res(0),
/* 0x7f */	res(0),
/* 0x80 */	{ "frameRgn", NA, skip_poly_or_region, "region" },
/* 0x81 */	{ "paintRgn", NA, skip_poly_or_region, "region" },
/* 0x82 */	{ "eraseRgn", NA, skip_poly_or_region, "region" },
/* 0x83 */	{ "invertRgn", NA, skip_poly_or_region, "region" },
/* 0x84 */	{ "fillRgn", NA, skip_poly_or_region, "region" },
/* 0x85 */	resf(skip_poly_or_region),
/* 0x86 */	resf(skip_poly_or_region),
/* 0x87 */	resf(skip_poly_or_region),
/* 0x88 */	{ "frameSameRgn", 0, NULL, "region (NYI)" },
/* 0x89 */	{ "paintSameRgn", 0, NULL, "region (NYI)" },
/* 0x8a */	{ "eraseSameRgn", 0, NULL, "region (NYI)" },
/* 0x8b */	{ "invertSameRgn", 0, NULL, "region (NYI)" },
/* 0x8c */	{ "fillSameRgn", 0, NULL, "region (NYI)" },
/* 0x8d */	res(0),
/* 0x8e */	res(0),
/* 0x8f */	res(0),
/* 0x90 */	{ "BitsRect", NA, BitsRect, "copybits, rect clipped" },
/* 0x91 */	{ "BitsRgn", NA, BitsRegion, "copybits, rgn clipped" },
/* 0x92 */	res(WORD_LEN),
/* 0x93 */	res(WORD_LEN),
/* 0x94 */	res(WORD_LEN),
/* 0x95 */	res(WORD_LEN),
/* 0x96 */	res(WORD_LEN),
/* 0x97 */	res(WORD_LEN),
/* 0x98 */	{ "PackBitsRect", NA, BitsRect, "packed copybits, rect clipped" },
/* 0x99 */	{ "PackBitsRgn", NA, BitsRegion, "packed copybits, rgn clipped" },
/* 0x9a */	{ "Opcode_9A", NA, Opcode_9A, "the mysterious opcode 9A" },
/* 0x9b */	res(WORD_LEN),
/* 0x9c */	res(WORD_LEN),
/* 0x9d */	res(WORD_LEN),
/* 0x9e */	res(WORD_LEN),
/* 0x9f */	res(WORD_LEN),
/* 0xa0 */	{ "ShortComment", 2, ShortComment, "kind (word)" },
/* 0xa1 */	{ "LongComment", NA, LongComment, "kind (word), size (word), data" }
};

struct const_name {
	int	value;
	char* name;
};

static char* const_name ARGS(( struct const_name* table, int ct));

struct const_name transfer_name[] = {
	{ 0,	"srcCopy" },
	{ 1,	"srcOr" },
	{ 2,	"srcXor" },
	{ 3,	"srcBic" },
	{ 4,	"notSrcCopy" },
	{ 5,	"notSrcOr" },
	{ 6,	"notSrcXor" },
	{ 7,	"notSrcBic" },
	{ 32,	"blend" },
	{ 33,	"addPin" },
	{ 34,	"addOver" },
	{ 35,	"subPin" },
	{ 36,	"transparent" },
	{ 37,	"adMax" },
	{ 38,	"subOver" },
	{ 39,	"adMin" },
	{ -1,	0 }
};

struct const_name font_name[] = {
	{ 0,	"systemFont" },
	{ 1,	"applFont" },
	{ 2,	"newYork" },
	{ 3,	"geneva" },
	{ 4,	"monaco" },
	{ 5,	"venice" },
	{ 6,	"london" },
	{ 7,	"athens" },
	{ 8,	"sanFran" },
	{ 9,	"toronto" },
	{ 11,	"cairo" },
	{ 12,	"losAngeles" },
	{ 20,	"times" },
	{ 21,	"helvetica" },
	{ 22,	"courier" },
	{ 23,	"symbol" },
	{ 24,	"taliesin" },
	{ -1,	0 }
};

struct const_name ps_just_name[] = {
	{ 0,	"no" },
	{ 1,	"left" },
	{ 2,	"center" },
	{ 3,	"right" },
	{ 4,	"full" },
	{ -1,	0 }
};

struct const_name ps_flip_name[] = {
	{ 0,	"no" },
	{ 1,	"horizontal" },
	{ 2,	"vertical" },
	{ -1,	0 }
};

#define FNT_BOLD	(1)
#define FNT_ITALIC	(2)
#define FNT_ULINE	(4)
#define FNT_OUTLINE	(8)
#define FNT_SHADOW	(16)
#define FNT_CONDENSE	(32)
#define FNT_EXTEND	(64)

static int align = 0;
static FILE* ifp;

int
main(argc, argv)
int argc;
char* argv[];
{
	int argn;
	int header;
	char* usage =
"[-verbose] [-fullres] [-noheader] [-quickdraw] [-fontdir file] [pictfile]";

	ppm_init( &argc, argv );

	argn = 1;
	verbose = 0;
	fullres = 0;
	header = 1;
	recognize_comment = 1;

	while (argn < argc && argv[argn][0] == '-' && argv[argn][1] != '\0') {
		if (pm_keymatch(argv[argn], "-verbose", 2))
			verbose++;
		else if (pm_keymatch(argv[argn], "-fullres", 3))
			fullres = 1;
		else if (pm_keymatch(argv[argn], "-noheader", 2))
			header = 0;
		else if (pm_keymatch(argv[argn], "-quickdraw", 2))
			recognize_comment = 0;
		else if (pm_keymatch(argv[argn], "-fontdir", 3)) {
			argn++;
			if (!argv[argn])
				pm_usage(usage);
			else
				load_fontdir(argv[argn]);
		}
		else
			pm_usage(usage);
		++argn;
	}

	if (load_fontdir("fontdir") < 0)
		pm_message("warning: can't load font directory 'fontdir'\n", 0,0,0,0);

	if (argn < argc) {
		ifp = pm_openr(argv[argn]);
		++argn;
	} else
		ifp = stdin;

	if (argn != argc)
		pm_usage(usage);

	if (header) {
		stage = "Reading 512 byte header";
		skip(512);
	}

	interpret_pict();
	exit(0);
}

static void
interpret_pict()
{
	byte ch;
	word picSize;
	word opcode;
	word len;
	int version;
	int i;

	for (i = 0; i < 64; i++)
		pen_pat.pix[i] = bkpat.pix[i] = fillpat.pix[i] = 1;
	pen_width = pen_height = 1;
	pen_mode = 0; /* srcCopy */
	pen_trf = transfer(pen_mode);
	text_mode = 0; /* srcCopy */
	text_trf = transfer(text_mode);

	stage = "Reading picture size";
	picSize = read_word();

	if (verbose)
		pm_message("picture size = %d (0x%x)", picSize, picSize, 0, 0, 0);

	stage = "reading picture frame";
	read_rect(&picFrame);

	if (verbose) {
		dump_rect("Picture frame:", &picFrame);
		pm_message("Picture size is %d x %d",
			picFrame.right - picFrame.left,
			picFrame.bottom - picFrame.top, 0, 0, 0);
	}

	if (!fullres)
		alloc_planes();

	while ((ch = read_byte()) == 0)
		;
	if (ch != 0x11)
		pm_error("No version number");

	switch (read_byte()) {
	case 1:
		version = 1;
		break;
	case 2:
		if (read_byte() != 0xff)
			pm_error("can only do version 2, subcode 0xff");
		version = 2;
		break;
	default:
		pm_error("Unknown version");
	}

	if (verbose)
		pm_message("PICT version %d", version, 0, 0, 0, 0);

	while((opcode = get_op(version)) != 0xff) {
		if (opcode < 0xa2) {
			if (verbose) {
				stage = optable[opcode].name;
				if (!strcmp(stage, "reserved"))
					pm_message("reserved opcode=0x%x", opcode, 0, 0, 0, 0);
				else
					pm_message("%s", stage = optable[opcode].name, 0, 0, 0, 0);
			}

			if (optable[opcode].impl != NULL)
				(*optable[opcode].impl)(version);
			else if (optable[opcode].len >= 0)
				skip(optable[opcode].len);
			else switch (optable[opcode].len) {
			case WORD_LEN:
				len = read_word();
				skip(len);
				break;
			default:
				pm_error("can't do length of %d",
					optable[opcode].len);
			}
		}
		else if (opcode == 0xc00) {
			if (verbose)
				pm_message("HeaderOp", 0, 0, 0, 0, 0);
			stage = "HeaderOp";
			skip(24);
		}
		else if (opcode >= 0xa2 && opcode <= 0xaf) {
			stage = "skipping reserved";
			if (verbose)
				pm_message("%s 0x%x", stage, opcode, 0, 0, 0);
			skip(read_word());
		}
		else if (opcode >= 0xb0 && opcode <= 0xcf) {
			/* just a reserved opcode, no data */
			if (verbose)
				pm_message("reserved 0x%x", opcode, 0, 0, 0);
		}
		else if (opcode >= 0xd0 && opcode <= 0xfe) {
			stage = "skipping reserved";
			if (verbose)
				pm_message("%s 0x%x", stage, opcode, 0, 0, 0);
			skip(read_long());
		}
		else if (opcode >= 0x100 && opcode <= 0x7fff) {
			stage = "skipping reserved";
			if (verbose)
				pm_message("%s 0x%x", stage, opcode, 0, 0, 0);
			skip((opcode >> 7) & 255);
		}
		else if (opcode >= 0x8000 && opcode <= 0x80ff) {
			/* just a reserved opcode */
			if (verbose)
				pm_message("reserved 0x%x", opcode, 0, 0, 0, 0);
		}
		else if (opcode >= 8100 && opcode <= 0xffff) {
			stage = "skipping reserved";
			if (verbose)
				pm_message("%s 0x%x", stage, opcode, 0, 0, 0);
			skip(read_long());
		}
		else
			pm_error("can't handle opcode of %x", opcode);
	}
	output_ppm(version);
}

/* allocation is same for version 1 or version 2.  We are super-duper
 * wasteful of memory for version 1 picts.  Someday, we'll separate
 * things and only allocate a byte per pixel for version 1 (or heck,
 * even only a bit, but that would require even more extra work).
 */

static void alloc_planes()
{
	rowlen = picFrame.right - picFrame.left;
	collen = picFrame.bottom - picFrame.top;

	clip_rect.top = picFrame.top;
	clip_rect.left = picFrame.left;
	clip_rect.bottom = picFrame.bottom;
	clip_rect.top = picFrame.top;

	planelen = rowlen * collen;
	if ((red = (word*)malloc(planelen * sizeof(word))) == NULL ||
		(green = (word*)malloc(planelen * sizeof(word))) == NULL ||
		(blue = (word*)malloc(planelen * sizeof(word))) == NULL)
	{

		pm_error("not enough memory to hold picture");
	}
	/* initialize background to white */
	memset(red, 255, planelen * sizeof(word));
	memset(green, 255, planelen * sizeof(word));
	memset(blue, 255, planelen * sizeof(word));
}

static void
compact_plane(plane, planelen)
register word* plane;
register int planelen;
{
	register byte* p;

	for (p = (byte*)plane; planelen-- > 0; )
		*p++ = (*plane++ >> 8) & 255;
}

static void
output_ppm(version)
int version;
{
	int width;
	int height;
	register char* r;
	register char* g;
	register char* b;
	pixel* pixelrow;
	register pixel* pP;
	int row;
	register int col;

	if (fullres)
		do_blits();

	stage = "writing PPM";

	width = picFrame.right - picFrame.left;
	height = picFrame.bottom - picFrame.top;
	r = (char*) red;
	compact_plane((word*) r, width * height);
	g = (char*) green;
	compact_plane((word*) g, width * height);
	b = (char*) blue;
	compact_plane((word*) b, width * height);

	ppm_writeppminit(stdout, width, height, (pixval) 255, 0 );
	pixelrow = ppm_allocrow(width);
	for (row = 0; row < height; ++row) {
		for (col = 0, pP = pixelrow; col < width;
		     ++col, ++pP, ++r, ++g, ++b) {
			PPM_ASSIGN(*pP, *r, *g, *b);
		}

		ppm_writeppmrow(stdout, pixelrow, width, (pixval) 255, 0 );
	}
	pm_close(stdout);
}

static void
do_blits()
{
	struct blit_info* bi;
	int	srcwidth, dstwidth, srcheight, dstheight;
	double	scale, scalelow, scalehigh;
	double	xscale = 1.0;
	double	yscale = 1.0;
	double	lowxscale, highxscale, lowyscale, highyscale;
	int		xscalecalc = 0, yscalecalc = 0;

	if (!blit_list) return;

	fullres = 0;

	for (bi = blit_list; bi; bi = bi->next) {
		srcwidth = rectwidth(&bi->srcRect);
		dstwidth = rectwidth(&bi->dstRect);
		srcheight = rectheight(&bi->srcRect);
		dstheight = rectheight(&bi->dstRect);
		if (srcwidth > dstwidth) {
			scalelow  = (double)(srcwidth      ) / (double)dstwidth;
			scalehigh = (double)(srcwidth + 1.0) / (double)dstwidth;
			switch (xscalecalc) {
			case 0:
				lowxscale = scalelow;
				highxscale = scalehigh;
				xscalecalc = 1;
				break;
			case 1:
				if (scalelow < highxscale && scalehigh > lowxscale) {
					if (scalelow > lowxscale) lowxscale = scalelow;
					if (scalehigh < highxscale) highxscale = scalehigh;
				}
				else {
					scale = (lowxscale + highxscale) / 2.0;
					xscale = (double)srcwidth / (double)dstwidth;
					if (scale > xscale) xscale = scale;
					xscalecalc = 2;
				}
				break;
			case 2:
				scale = (double)srcwidth / (double)dstwidth;
				if (scale > xscale) xscale = scale;
				break;
			}
		}

		if (srcheight > dstheight) {
			scalelow =  (double)(srcheight      ) / (double)dstheight;
			scalehigh = (double)(srcheight + 1.0) / (double)dstheight;
			switch (yscalecalc) {
			case 0:
				lowyscale = scalelow;
				highyscale = scalehigh;
				yscalecalc = 1;
				break;
			case 1:
				if (scalelow < highyscale && scalehigh > lowyscale) {
					if (scalelow > lowyscale) lowyscale = scalelow;
					if (scalehigh < highyscale) highyscale = scalehigh;
				}
				else {
					scale = (lowyscale + highyscale) / 2.0;
					yscale = (double)srcheight / (double)dstheight;
					if (scale > yscale) yscale = scale;
					yscalecalc = 2;
				}
				break;
			case 2:
				scale = (double)srcheight / (double)dstheight;
				if (scale > yscale) yscale = scale;
				break;
			}
		}
	}

	if (xscalecalc == 1) {
		if (1.0 >= lowxscale && 1.0 <= highxscale)
			xscale = 1.0;
		else
			xscale = lowxscale;
	}
	if (yscalecalc == 1) {
		if (1.0 >= lowyscale && 1.0 <= lowyscale)
			yscale = 1.0;
		else
			yscale = lowyscale;
	}

	if (xscale != 1.0 || yscale != 1.0) {
		for (bi = blit_list; bi; bi = bi->next)
			rectscale(&bi->dstRect, xscale, yscale);

		pm_message("Scaling output by %f in X and %f in Y",
			xscale, yscale, 0, 0, 0);
		rectscale(&picFrame, xscale, yscale);
	}

	alloc_planes();

	for (bi = blit_list; bi; bi = bi->next) {
		blit(&bi->srcRect, &bi->srcBounds, bi->srcwid, bi->srcplane,
		     bi->pixSize,
		     &bi->dstRect, &picFrame, rowlen,
		     bi->colour_map,
		     bi->mode);
	}
}

/*
 * This could use read_pixmap, but I'm too lazy to hack read_pixmap.
 */

static void
Opcode_9A(version)
int version;
{
#ifdef DUMP
	FILE *fp = fopen("data", "w");
	int ch;
	if (fp == NULL) exit(1);
	while ((ch = fgetc(ifp)) != EOF) fputc(ch, fp);
	exit(0);
#else
	struct pixMap	p;
	struct Rect		srcRect;
	struct Rect		dstRect;
	byte*			pm;
	int				pixwidth;
	word			mode;

	/* skip fake len, and fake EOF */
	skip(4);
	read_word();	/* version */
	read_rect(&p.Bounds);
	pixwidth = p.Bounds.right - p.Bounds.left;
	p.packType = read_word();
	p.packSize = read_long();
	p.hRes = read_long();
	p.vRes = read_long();
	p.pixelType = read_word();
	p.pixelSize = read_word();
	p.pixelSize = read_word();
	p.cmpCount = read_word();
	p.cmpSize = read_word();
	p.planeBytes = read_long();
	p.pmTable = read_long();
	p.pmReserved = read_long();

	if (p.pixelSize == 16)
		pixwidth *= 2;
	else if (p.pixelSize == 32)
		pixwidth *= 3;

	read_rect(&srcRect);
	if (verbose)
		dump_rect("source rectangle:", &srcRect);

	read_rect(&dstRect);
	if (verbose)
		dump_rect("destination rectangle:", &dstRect);

	mode = read_word();
	if (verbose)
		pm_message("transfer mode = %s", const_name(transfer_name, mode),0,0,0,0);

	pm = unpackbits(&p.Bounds, 0, p.pixelSize);

	if (blit(&srcRect, &(p.Bounds), pixwidth, pm, p.pixelSize,
		 &dstRect, &picFrame, rowlen,
		 (struct RGBColour*)0,
		 mode))
	{
		free(pm);
	}
#endif
}

static void
BitsRect(version)
int version;
{
	word rowBytes;

	stage = "Reading rowBytes for bitsrect";
	rowBytes = read_word();

	if (verbose)
		pm_message("rowbytes = 0x%x (%d)", rowBytes, rowBytes & 0x7fff, 0, 0, 0);

	if (rowBytes & 0x8000)
		do_pixmap(version, rowBytes, 0);
	else
		do_bitmap(version, rowBytes, 0);
}

static void
BitsRegion(version)
int version;
{
	word rowBytes;

	stage = "Reading rowBytes for bitsregion";
	rowBytes = read_word();

	if (rowBytes & 0x8000)
		do_pixmap(version, rowBytes, 1);
	else
		do_bitmap(version, rowBytes, 1);
}

static void
do_bitmap(version, rowBytes, is_region)
int version;
int rowBytes;
int is_region;
{
	struct Rect Bounds;
	struct Rect srcRect;
	struct Rect dstRect;
	word mode;
	byte* pm;
	static struct RGBColour colour_table[] = { {65535L, 65535L, 65535L}, {0, 0, 0} };

	read_rect(&Bounds);
	read_rect(&srcRect);
	read_rect(&dstRect);
	mode = read_word();
	if (verbose)
		pm_message("transfer mode = %s", const_name(transfer_name, mode),0,0,0,0);

	if (is_region)
		skip_poly_or_region(version);

	stage = "unpacking rectangle";

	pm = unpackbits(&Bounds, rowBytes, 1);

	if (blit(&srcRect, &Bounds, Bounds.right - Bounds.left, pm, 8,
		 &dstRect, &picFrame, rowlen,
		 colour_table,
		 mode))
	{
		free(pm);
	}
}

#if __STDC__
static void
do_pixmap( int version, word rowBytes, int is_region )
#else /*__STDC__*/
static void
do_pixmap(version, rowBytes, is_region)
int version;
word rowBytes;
int is_region;
#endif /*__STDC__*/
{
	word mode;
	struct pixMap p;
	word pixwidth;
	byte* pm;
	struct RGBColour* colour_table;
	struct Rect srcRect;
	struct Rect dstRect;

	read_pixmap(&p, NULL);

	pixwidth = p.Bounds.right - p.Bounds.left;

	if (verbose)
		pm_message("%d x %d rectangle", pixwidth,
			p.Bounds.bottom - p.Bounds.top, 0, 0, 0);

	colour_table = read_colour_table();

	read_rect(&srcRect);

	if (verbose)
		dump_rect("source rectangle:", &srcRect);

	read_rect(&dstRect);

	if (verbose)
		dump_rect("destination rectangle:", &dstRect);

	mode = read_word();

	if (verbose)
		pm_message("transfer mode = %s", const_name(transfer_name, mode),0,0,0,0);

	if (is_region)
		skip_poly_or_region(version);

	stage = "unpacking rectangle";

	pm = unpackbits(&p.Bounds, rowBytes, p.pixelSize);

	if (blit(&srcRect, &(p.Bounds), pixwidth, pm, 8,
		 &dstRect, &picFrame, rowlen,
		 colour_table,
		 mode))
	{
		free(colour_table);
		free(pm);
	}
}

static struct blit_info* add_blit_list()
{
	struct blit_info* bi;

	if (!(bi = (struct blit_info*)malloc(sizeof(struct blit_info))))
		pm_error("out of memory for blit list");
	
	bi->next = 0;
	*last_bl = bi;
	last_bl = &(bi->next);

	return bi;
}

/* Various transfer functions for blits.
 *
 * Note src[Not]{Or,Xor,Copy} only work if the source pixmap was originally
 * a bitmap.
 * There's also a small bug that the foreground and background colours
 * are not used in a srcCopy; this wouldn't be hard to fix.
 * It IS a problem since the foreground and background colours CAN be changed.
 */

#define rgb_all_same(x, y) \
	((x)->red == (y) && (x)->green == (y) && (x)->blue == (y))
#define rgb_is_white(x) rgb_all_same((x), 0xffff)
#define rgb_is_black(x) rgb_all_same((x), 0)

static void srcCopy(src, dst)
struct RGBColour*	src;
struct RGBColour*	dst;
{
	if (rgb_is_black(src))
		*dst = foreground;
	else
		*dst = background;
}

static void srcOr(src, dst)
struct RGBColour*	src;
struct RGBColour*	dst;
{
	if (rgb_is_black(src))
		*dst = foreground;
}

static void srcXor(src, dst)
struct RGBColour*	src;
struct RGBColour*	dst;
{
	dst->red ^= ~src->red;
	dst->green ^= ~src->green;
	dst->blue ^= ~src->blue;
}

static void srcBic(src, dst)
struct RGBColour*	src;
struct RGBColour*	dst;
{
	if (rgb_is_black(src))
		*dst = background;
}

static void notSrcCopy(src, dst)
struct RGBColour*	src;
struct RGBColour*	dst;
{
	if (rgb_is_white(src))
		*dst = foreground;
	else if (rgb_is_black(src))
		*dst = background;
}

static void notSrcOr(src, dst)
struct RGBColour*	src;
struct RGBColour*	dst;
{
	if (rgb_is_white(src))
		*dst = foreground;
}

static void notSrcBic(src, dst)
struct RGBColour*	src;
struct RGBColour*	dst;
{
	if (rgb_is_white(src))
		*dst = background;
}

static void notSrcXor(src, dst)
struct RGBColour*	src;
struct RGBColour*	dst;
{
	dst->red ^= src->red;
	dst->green ^= src->green;
	dst->blue ^= src->blue;
}

static void addOver(src, dst)
struct RGBColour*	src;
struct RGBColour*	dst;
{
	dst->red += src->red;
	dst->green += src->green;
	dst->blue += src->blue;
}

static void addPin(src, dst)
struct RGBColour*	src;
struct RGBColour*	dst;
{
	if ((long)dst->red + (long)src->red > (long)op_colour.red)
		dst->red = op_colour.red;
	else
		dst->red = dst->red + src->red;

	if ((long)dst->green + (long)src->green > (long)op_colour.green)
		dst->green = op_colour.green;
	else
		dst->green = dst->green + src->green;

	if ((long)dst->blue + (long)src->blue > (long)op_colour.blue)
		dst->blue = op_colour.blue;
	else
		dst->blue = dst->blue + src->blue;
}

static void subOver(src, dst)
struct RGBColour*	src;
struct RGBColour*	dst;
{
	dst->red -= src->red;
	dst->green -= src->green;
	dst->blue -= src->blue;
}

/* or maybe its src - dst; my copy of Inside Mac is unclear */
static void subPin(src, dst)
struct RGBColour*	src;
struct RGBColour*	dst;
{
	if ((long)dst->red - (long)src->red < (long)op_colour.red)
		dst->red = op_colour.red;
	else
		dst->red = dst->red - src->red;

	if ((long)dst->green - (long)src->green < (long)op_colour.green)
		dst->green = op_colour.green;
	else
		dst->green = dst->green - src->green;

	if ((long)dst->blue - (long)src->blue < (long)op_colour.blue)
		dst->blue = op_colour.blue;
	else
		dst->blue = dst->blue - src->blue;
}

static void adMax(src, dst)
struct RGBColour*	src;
struct RGBColour*	dst;
{
	if (src->red > dst->red) dst->red = src->red;
	if (src->green > dst->green) dst->green = src->green;
	if (src->blue > dst->blue) dst->blue = src->blue;
}

static void adMin(src, dst)
struct RGBColour*	src;
struct RGBColour*	dst;
{
	if (src->red < dst->red) dst->red = src->red;
	if (src->green < dst->green) dst->green = src->green;
	if (src->blue < dst->blue) dst->blue = src->blue;
}

static void blend(src, dst)
struct RGBColour*	src;
struct RGBColour*	dst;
{
#define blend_component(cmp)	\
	((long)src->cmp * (long)op_colour.cmp) / 65536 +	\
	((long)dst->cmp * (long)(65536 - op_colour.cmp) / 65536)

	dst->red = blend_component(red);
	dst->green = blend_component(green);
	dst->blue = blend_component(blue);
}

static void transparent(src, dst)
struct RGBColour*	src;
struct RGBColour*	dst;
{
	if (src->red != background.red || src->green != background.green ||
		src->blue != background.blue)
	{
		*dst = *src;
	}
}

static transfer_func transfer(mode)
int mode;
{
	switch (mode) {
	case  0: return srcCopy;
	case  1: return srcOr;
	case  2: return srcXor;
	case  3: return srcBic;
	case  4: return notSrcCopy;
	case  5: return notSrcOr;
	case  6: return notSrcXor;
	case  7: return notSrcBic;
	case 32: return blend;
	case 33: return addPin;
	case 34: return addOver;
	case 35: return subPin;
	case 36: return transparent;
	case 37: return adMax;
	case 38: return subOver;
	case 39: return adMin;
	default:
		if (mode != 0)
			pm_message("no transfer function for code %s, using srcCopy",
				const_name(transfer_name, mode), 0, 0, 0, 0);
		return srcCopy;
	}
}

static int
blit(srcRect, srcBounds, srcwid, srcplane, pixSize, dstRect, dstBounds, dstwid, colour_map, mode)
struct Rect* srcRect;
struct Rect* srcBounds;
int srcwid;
byte* srcplane;
int pixSize;
struct Rect* dstRect;
struct Rect* dstBounds;
int dstwid;
struct RGBColour* colour_map;
int mode;
{
	struct Rect clipsrc;
	struct Rect clipdst;
	register byte* src;
	register word* reddst;
	register word* greendst;
	register word* bluedst;
	register int i;
	register int j;
	int dstoff;
	int xsize;
	int ysize;
	int srcadd;
	int dstadd;
	struct RGBColour* ct;
	int pkpixsize;
	struct blit_info* bi;
	struct RGBColour src_c, dst_c;
	transfer_func trf;

	if (ps_text)
		return;

	/* almost got it.  clip source rect with source bounds.
	 * clip dest rect with dest bounds.  if source and
	 * destination are not the same size, use pnmscale
	 * to get a nicely sized rectangle.
	 */
	rectinter(srcBounds, srcRect, &clipsrc);
	rectinter(dstBounds, dstRect, &clipdst);

	if (fullres) {
		bi = add_blit_list();
		bi->srcRect = clipsrc;
		bi->srcBounds = *srcBounds;
		bi->srcwid = srcwid;
		bi->srcplane = srcplane;
		bi->pixSize = pixSize;
		bi->dstRect = clipdst;
		bi->colour_map = colour_map;
		bi->mode = mode;
		return 0;
	}

	if (verbose) {
		dump_rect("copying from:", &clipsrc);
		dump_rect("to:          ", &clipdst);
		pm_message("a %d x %d area to a %d x %d area",
			rectwidth(&clipsrc), rectheight(&clipsrc),
			rectwidth(&clipdst), rectheight(&clipdst), 0);
	}

	pkpixsize = 1;
	if (pixSize == 16)
		pkpixsize = 2;

	src = srcplane + (clipsrc.top - srcBounds->top) * srcwid +
		(clipsrc.left - srcBounds->left) * pkpixsize;
	xsize = clipsrc.right - clipsrc.left;
	ysize = clipsrc.bottom - clipsrc.top;
	srcadd = srcwid - xsize * pkpixsize;

	dstoff = (clipdst.top - dstBounds->top) * dstwid +
		(clipdst.left - dstBounds->left);
	reddst = red + dstoff;
	greendst = green + dstoff;
	bluedst = blue + dstoff;
	dstadd = dstwid - (clipdst.right - clipdst.left);

	/* get rid of Text mask mode bit, if (erroneously) set */
	if ((mode & ~64) == 0)
		trf = 0;	/* optimized srcCopy */
	else
		trf = transfer(mode & ~64);

	if (!rectsamesize(&clipsrc, &clipdst)) {
#ifdef STANDALONE
		fprintf(stderr,
		  "picttoppm: standalone version can't scale rectangles yet, sorry.\n");
		fprintf(stderr, "picttoppm: skipping this rectangle.\n");
		return;
#else
		FILE*	pnmscale;
		char*	tmpfile = tmpnam((char*)0);
		char	command[1024];
		register byte* redsrc;
		register byte* greensrc;
		register byte* bluesrc;
		int	greenpix;
		FILE*	scaled;
		int	cols, rows, format;
		pixval maxval;
		pixel* row;
		pixel* rowp;

#if (defined(AMIGA) || defined(VMS))
                char ami_tmpfile[L_tmpnam];
                int ami_result;
                tmpnam(ami_tmpfile);
                if (!(pnmscale = fopen(ami_tmpfile, "w")))
                        pm_error("cannot create temporary file '%s'", ami_tmpfile);
#else /* AMIGA or VMS */
		sprintf(command, "pnmscale -xsize %d -ysize %d > %s",
			rectwidth(&clipdst), rectheight(&clipdst), tmpfile);
		
		pm_message("running 'pnmscale -xsize %d -ysize %d' on a %d x %d image",
			rectwidth(&clipdst), rectheight(&clipdst),
			rectwidth(&clipsrc), rectheight(&clipsrc), 0);

		if (!(pnmscale = popen(command, "w"))) {
			pm_message("cannot execute command '%s'", command, 0, 0, 0, 0);
			pm_perror("popen");
		}
#endif /* AMIGA or VMS */

/* This should really be PPM_MAXMAXVAL, but that can be big, and then
 * I'd have to conditionally output raw/not-raw PPM, which is a pain.
 */
#define MY_MAXVAL (255)

		fprintf(pnmscale, "P6\n%d %d\n%d\n",
			rectwidth(&clipsrc), rectheight(&clipsrc), MY_MAXVAL);

#define REDEPTH(c, oldmax)  ((c) * ((MY_MAXVAL) + 1) / (oldmax + 1))

		switch (pixSize) {
		case 8:
			for (i = 0; i < ysize; ++i) {
				for (j = 0; j < xsize; ++j) {
					ct = colour_map + *src++;
					fputc(REDEPTH(ct->red, 65535L), pnmscale);
					fputc(REDEPTH(ct->green, 65535L), pnmscale);
					fputc(REDEPTH(ct->blue, 65535L), pnmscale);
				}
				src += srcadd;
			}
			break;
		case 16:
			for (i = 0; i < ysize; ++i) {
				for (j = 0; j < xsize; ++j) {
					fputc(REDEPTH((*src & 0x7c) >> 2, 32), pnmscale);
					greenpix = (*src++ & 3) << 3;
					greenpix |= (*src & 0xe0) >> 5;
					fputc(REDEPTH(greenpix, 32), pnmscale);
					fputc(REDEPTH((*src++ & 0x1f) << 11, 32), pnmscale);
				}
				src += srcadd;
			}
			break;
		case 32:
			srcadd = srcwid - xsize;
			redsrc = src;
			greensrc = src + (srcwid / 3);
			bluesrc = greensrc + (srcwid / 3);

			for (i = 0; i < ysize; ++i) {
				for (j = 0; j < xsize; ++j) {
					fputc(REDEPTH(*redsrc++, 256), pnmscale);
					fputc(REDEPTH(*greensrc++, 256), pnmscale);
					fputc(REDEPTH(*bluesrc++, 256), pnmscale);
				}
				redsrc += srcadd;
				greensrc += srcadd;
				bluesrc += srcadd;
			}
		}

#if (defined(AMIGA) || defined(VMS))
                if( fclose(pnmscale) != 0 ) {
                    unlink(ami_tmpfile);
                    pm_perror("write error");
                }
                sprintf(command, "pnmscale -xsize %d -ysize %d %s > %s",
                        rectwidth(&clipdst), rectheight(&clipdst), ami_tmpfile, tmpfile);
                pm_message("running 'pnmscale -xsize %d -ysize %d' on a %d x %d image",
                        rectwidth(&clipdst), rectheight(&clipdst),
                        rectwidth(&clipsrc), rectheight(&clipsrc), 0);
                ami_result = system(command);
                unlink(ami_tmpfile);
#ifndef VMS
                if( ami_result != 0 ) {
#else
                if( ami_result == 0 ) {
#endif
                    unlink(tmpfile);
                    pm_perror("pnmscale failed");
                }
#else /* AMIGA or VMS */
		if (pclose(pnmscale)) {
			pm_message("pnmscale failed", 0, 0, 0, 0, 0);
			pm_perror("pclose");
		}
#endif /* AMIGA or VMS */
		ppm_readppminit(scaled = pm_openr(tmpfile), &cols, &rows,
			&maxval, &format);
		row = ppm_allocrow(cols);
		/* couldn't hurt to assert cols, rows and maxval... */	

		if (trf == 0) {
			while (rows-- > 0) {
				ppm_readppmrow(scaled, row, cols, maxval, format);
				for (i = 0, rowp = row; i < cols; ++i, ++rowp) {
					*reddst++ = PPM_GETR(*rowp) * 65536L / (maxval + 1); 
					*greendst++ = PPM_GETG(*rowp) * 65536L / (maxval + 1); 
					*bluedst++ = PPM_GETB(*rowp) * 65536L / (maxval + 1); 
				}
				reddst += dstadd;
				greendst += dstadd;
				bluedst += dstadd;
			}
		}
		else {
			while (rows-- > 0) {
				ppm_readppmrow(scaled, row, cols, maxval, format);
				for (i = 0, rowp = row; i < cols; i++, rowp++) {
					dst_c.red = *reddst;
					dst_c.green = *greendst;
					dst_c.blue = *bluedst;
					src_c.red = PPM_GETR(*rowp) * 65536L / (maxval + 1); 
					src_c.green = PPM_GETG(*rowp) * 65536L / (maxval + 1); 
					src_c.blue = PPM_GETB(*rowp) * 65536L / (maxval + 1); 
					(*trf)(&src_c, &dst_c);
					*reddst++ = dst_c.red;
					*greendst++ = dst_c.green;
					*bluedst++ = dst_c.blue;
				}
				reddst += dstadd;
				greendst += dstadd;
				bluedst += dstadd;
			}
		}

		pm_close(scaled);
		ppm_freerow(row);
		unlink(tmpfile);
		return;
#endif /* STANDALONE */
	}

	if (trf == 0) {
		/* optimized srcCopy blit ('cause it was implemented first) */
		switch (pixSize) {
		case 8:
			for (i = 0; i < ysize; ++i) {
				for (j = 0; j < xsize; ++j) {
					ct = colour_map + *src++;
					*reddst++ = ct->red;
					*greendst++ = ct->green;
					*bluedst++ = ct->blue;
				}
				src += srcadd;
				reddst += dstadd;
				greendst += dstadd;
				bluedst += dstadd;
			}
			break;
		case 16:
			for (i = 0; i < ysize; ++i) {
				for (j = 0; j < xsize; ++j) {
					*reddst++ = (*src & 0x7c) << 9;
					*greendst = (*src++ & 3) << 14;
					*greendst++ |= (*src & 0xe0) << 6;
					*bluedst++ = (*src++ & 0x1f) << 11;
				}
				src += srcadd;
				reddst += dstadd;
				greendst += dstadd;
				bluedst += dstadd;
			}
			break;
		case 32:
			srcadd = (srcwid / 3) - xsize;
			for (i = 0; i < ysize; ++i) {
				for (j = 0; j < xsize; ++j)
					*reddst++ = *src++ << 8;

				reddst += dstadd;
				src += srcadd;

				for (j = 0; j < xsize; ++j)
					*greendst++ = *src++ << 8;

				greendst += dstadd;
				src += srcadd;

				for (j = 0; j < xsize; ++j)
					*bluedst++ = *src++ << 8;

				bluedst += dstadd;
				src += srcadd;
			}
		}
	}
	else {
#define grab_destination()		\
		dst_c.red = *reddst;		\
		dst_c.green = *greendst;	\
		dst_c.blue = *bluedst

#define put_destination()		\
		*reddst++ = dst_c.red;	\
		*greendst++ = dst_c.green;	\
		*bluedst++ = dst_c.blue

		/* generalized (but slow) blit */
		switch (pixSize) {
		case 8:
			for (i = 0; i < ysize; ++i) {
				for (j = 0; j < xsize; ++j) {
					grab_destination();
					(*trf)(colour_map + *src++, &dst_c);
					put_destination();
				}
				src += srcadd;
				reddst += dstadd;
				greendst += dstadd;
				bluedst += dstadd;
			}
			break;
		case 16:
			for (i = 0; i < ysize; ++i) {
				for (j = 0; j < xsize; ++j) {
					grab_destination();
					src_c.red = (*src & 0x7c) << 9;
					src_c.green = (*src++ & 3) << 14;
					src_c.green |= (*src & 0xe0) << 6;
					src_c.blue = (*src++ & 0x1f) << 11;
					(*trf)(&src_c, &dst_c);
					put_destination();
				}
				src += srcadd;
				reddst += dstadd;
				greendst += dstadd;
				bluedst += dstadd;
			}
			break;
		case 32:
			srcadd = srcwid / 3;
			for (i = 0; i < ysize; i++) {
				for (j = 0; j < xsize; j++) {
					grab_destination();
					src_c.red = *src << 8;
					src_c.green = src[srcadd] << 8;
					src_c.blue = src[srcadd * 2] << 8;
					(*trf)(&src_c, &dst_c);
					put_destination();
					src++;
				}
				src += srcwid - xsize;
				reddst += dstadd;
				greendst += dstadd;
				bluedst += dstadd;
			}
		}
	}
	return 1;
}

#if __STDC__
static byte*
unpackbits( struct Rect* bounds, word rowBytes, int pixelSize )
#else /*__STDC__*/
static byte*
unpackbits(bounds, rowBytes, pixelSize)
struct Rect* bounds;
word rowBytes;
int pixelSize;
#endif /*__STDC__*/
{
	byte* linebuf;
	byte* pm;
	byte* pm_ptr;
	register int i,j,k,l;
	word pixwidth;
	int linelen;
	int len;
	byte* bytepixels;
	int buflen;
	int pkpixsize;
	int rowsize;

	if (pixelSize <= 8)
		rowBytes &= 0x7fff;

	stage = "unpacking packbits";

	pixwidth = bounds->right - bounds->left;

	pkpixsize = 1;
	if (pixelSize == 16) {
		pkpixsize = 2;
		pixwidth *= 2;
	}
	else if (pixelSize == 32)
		pixwidth *= 3;
	
	if (rowBytes == 0)
		rowBytes = pixwidth;

	rowsize = pixwidth;
	if (rowBytes < 8)
		rowsize = 8 * rowBytes;	/* worst case expansion factor */

	/* we're sloppy and allocate some extra space because we can overshoot
	 * by as many as 8 bytes when we unpack the raster lines.  Really, I
	 * should be checking to see if we go over the scan line (it is
	 * possible) and complain of a corrupt file.  That fix is more complex
	 * (and probably costly in CPU cycles) and will have to come later.
	 */
	if ((pm = (byte*)malloc((rowsize * (bounds->bottom - bounds->top) + 8) * sizeof(byte))) == NULL)
		pm_error("no mem for packbits rectangle");

	/* Sometimes we get rows with length > rowBytes.  I'll allocate some
	 * extra for slop and only die if the size is _way_ out of wack.
	 */
	if ((linebuf = (byte*)malloc(rowBytes + 100)) == NULL)
		pm_error("can't allocate memory for line buffer");

	if (rowBytes < 8) {
		/* ah-ha!  The bits aren't actually packed.  This will be easy */
		for (i = 0; i < bounds->bottom - bounds->top; i++) {
			pm_ptr = pm + i * pixwidth;
			read_n(buflen = rowBytes, (char*) linebuf);
			bytepixels = expand_buf(linebuf, &buflen, pixelSize);
			for (j = 0; j < buflen; j++)
				*pm_ptr++ = *bytepixels++;
		}
	}
	else {
		for (i = 0; i < bounds->bottom - bounds->top; i++) {
			pm_ptr = pm + i * pixwidth;
			if (rowBytes > 250 || pixelSize > 8)
				linelen = read_word();
			else
				linelen = read_byte();

			if (verbose > 1)
				pm_message("linelen: %d", linelen, 0, 0, 0, 0);

			if (linelen > rowBytes) {
				pm_message("linelen > rowbytes! (%d > %d) at line %d",
					linelen, rowBytes, i, 0, 0);
			}

			read_n(linelen, (char*) linebuf);

			for (j = 0; j < linelen; ) {
				if (linebuf[j] & 0x80) {
					len = ((linebuf[j] ^ 255) & 255) + 2;
					buflen = pkpixsize;
					bytepixels = expand_buf(linebuf + j+1, &buflen, pixelSize);
					for (k = 0; k < len; k++) {
						for (l = 0; l < buflen; l++)
							*pm_ptr++ = *bytepixels++;
						bytepixels -= buflen;
					}
					j += 1 + pkpixsize;
				}
				else {
					len = (linebuf[j] & 255) + 1;
					buflen = len * pkpixsize;
					bytepixels = expand_buf(linebuf + j+1, &buflen, pixelSize);
					for (k = 0; k < buflen; k++)
						*pm_ptr++ = *bytepixels++;
					j += len * pkpixsize + 1;
				}
			}
		}
	}

	free(linebuf);

	return pm;
}

static byte*
expand_buf(buf, len, bits_per_pixel)
byte* buf;
int* len;
int bits_per_pixel;
{
	static byte pixbuf[256 * 8];
	register byte* src;
	register byte* dst;
	register int i;

	src = buf;
	dst = pixbuf;

	switch (bits_per_pixel) {
	case 8:
	case 16:
	case 32:
		return buf;
	case 4:
		for (i = 0; i < *len; i++) {
			*dst++ = (*src >> 4) & 15;
			*dst++ = *src++ & 15;
		}
		*len *= 2;
		break;
	case 2:
		for (i = 0; i < *len; i++) {
			*dst++ = (*src >> 6) & 3;
			*dst++ = (*src >> 4) & 3;
			*dst++ = (*src >> 2) & 3;
			*dst++ = *src++ & 3;
		}
		*len *= 4;
		break;
	case 1:
		for (i = 0; i < *len; i++) {
			*dst++ = (*src >> 7) & 1;
			*dst++ = (*src >> 6) & 1;
			*dst++ = (*src >> 5) & 1;
			*dst++ = (*src >> 4) & 1;
			*dst++ = (*src >> 3) & 1;
			*dst++ = (*src >> 2) & 1;
			*dst++ = (*src >> 1) & 1;
			*dst++ = *src++ & 1;
		}
		*len *= 8;
		break;
	default:
		pm_error("bad bits per pixel in expand_buf");
	}
	return pixbuf;
}

static void
Clip(version)
int version;
{
	word len;

	len = read_word();

	if (len == 0x000a) {	/* null rgn */
		read_rect(&clip_rect);
		/* XXX should clip this by picFrame */
		if (verbose)
			dump_rect("clipping to", &clip_rect);
	}
	else
		skip(len - 2);
}

static void
read_pixmap(p, rowBytes)
struct pixMap* p;
word* rowBytes;
{
	stage = "getting pixMap header";

	if (rowBytes != NULL)
		*rowBytes = read_word();

	read_rect(&p->Bounds);
	p->version = read_word();
	p->packType = read_word();
	p->packSize = read_long();
	p->hRes = read_long();
	p->vRes = read_long();
	p->pixelType = read_word();
	p->pixelSize = read_word();
	p->cmpCount = read_word();
	p->cmpSize = read_word();
	p->planeBytes = read_long();
	p->pmTable = read_long();
	p->pmReserved = read_long();

	if (verbose) {
		pm_message("pixelType: %d", p->pixelType, 0, 0, 0, 0);
		pm_message("pixelSize: %d", p->pixelSize, 0, 0, 0, 0);
		pm_message("cmpCount:  %d", p->cmpCount, 0, 0, 0, 0);
		pm_message("cmpSize:   %d", p->cmpSize, 0, 0, 0, 0);
	}

	if (p->pixelType != 0)
		pm_error("sorry, I only do chunky format");
	if (p->cmpCount != 1)
		pm_error("sorry, cmpCount != 1");
	if (p->pixelSize != p->cmpSize)
		pm_error("oops, pixelSize != cmpSize");
}

static struct RGBColour*
read_colour_table()
{
	longword ctSeed;
	word ctFlags;
	word ctSize;
	word val;
	int i;
	struct RGBColour* colour_table;

	stage = "getting color table info";

	ctSeed = read_long();
	ctFlags = read_word();
	ctSize = read_word();

	if (verbose) {
		pm_message("ctSeed:  %d", ctSeed, 0, 0, 0, 0);
		pm_message("ctFlags: %d", ctFlags, 0, 0, 0, 0);
		pm_message("ctSize:  %d", ctSize, 0, 0, 0, 0);
	}

	stage = "reading colour table";

	if ((colour_table = (struct RGBColour*) malloc(sizeof(struct RGBColour) * (ctSize + 1))) == NULL)
		pm_error("no memory for colour table");

	for (i = 0; i <= ctSize; i++) {
		val = read_word();
		/* The indicies in a device colour table are bogus and usually == 0.
		 * so I assume we allocate up the list of colours in order.
		 */
		if (ctFlags & 0x8000)
			val = i;
		if (val > ctSize)
			pm_error("pixel value greater than colour table size");
		colour_table[val].red = read_word();
		colour_table[val].green = read_word();
		colour_table[val].blue = read_word();

		if (verbose > 1)
			pm_message("%d: [%d,%d,%d]", val,
				colour_table[val].red,
				colour_table[val].green,
				colour_table[val].blue, 0);
	}

	return colour_table;
}

static void
OpColor(version)
int version;
{
	op_colour.red = read_word();
	op_colour.green = read_word();
	op_colour.blue = read_word();
}

/* these 3 do nothing but skip over their data! */
static void
BkPixPat(version)
int version;
{
	read_pattern();
}

static void
PnPixPat(version)
int version;
{
	read_pattern();
}

static void
FillPixPat(version)
int version;
{
	read_pattern();
}

/* this just skips over a version 2 pattern.  Probabaly will return
 * a pattern in the fabled complete version.
 */
static void
read_pattern()
{
	word PatType;
	word rowBytes;
	struct pixMap p;
	byte* pm;
	struct RGBColour* ct;

	stage = "Reading a pattern";

	PatType = read_word();

	switch (PatType) {
	case 2:
		skip(8); /* old pattern data */
		skip(5); /* RGB for pattern */
		break;
	case 1:
		skip(8); /* old pattern data */
		read_pixmap(&p, &rowBytes);
		ct = read_colour_table();
		pm = unpackbits(&p.Bounds, rowBytes, p.pixelSize);
		free(pm);
		free(ct);
		break;
	default:
		pm_error("unknown pattern type in read_pattern");
	}
}

static void BkPat(version)
int version;
{
	read_8x8_pattern(&bkpat);
}

static void PnPat(version)
int version;
{
	read_8x8_pattern(&pen_pat);
}

static void FillPat(version)
int version;
{
	read_8x8_pattern(&fillpat);
}

static void
read_8x8_pattern(pat)
struct Pattern* pat;
{
	byte buf[8], *exp;
	int len, i;

	read_n(len = 8, (char*)buf);
	if (verbose) {
		pm_message("pattern: %02x%02x%02x%02x",
			buf[0], buf[1], buf[2], buf[3], 0);
		pm_message("pattern: %02x%02x%02x%02x",
			buf[4], buf[5], buf[6], buf[7], 0);
	}
	exp = expand_buf(buf, &len, 1);
	for (i = 0; i < 64; i++)
		pat->pix[i] = *exp++;
}

static void PnSize(version)
int version;
{
	pen_height = read_word();
	pen_width = read_word();
	if (verbose)
		pm_message("pen size %d x %d", pen_width, pen_height, 0, 0, 0);
}

static void PnMode(version)
int version;
{
	pen_mode = read_word();

	if (pen_mode >= 8 && pen_mode < 15)
		pen_mode -= 8;
	if (verbose)
		pm_message("pen transfer mode = %s",
			const_name(transfer_name, pen_mode), 0, 0, 0, 0);
	
	pen_trf = transfer(pen_mode);
}

static void read_rgb(rgb)
struct RGBColour* rgb;
{
	rgb->red = read_word();
	rgb->green = read_word();
	rgb->blue = read_word();
}

static void RGBFgCol(v)
int v;
{
	read_rgb(&foreground);
	if (verbose)
		pm_message("foreground now [%d,%d,%d]", 
			foreground.red, foreground.green, foreground.blue, 0, 0);
}

static void RGBBkCol(v)
int v;
{
	read_rgb(&background);
	if (verbose)
		pm_message("background now [%d,%d,%d]", 
			background.red, background.green, background.blue, 0, 0);
}

static void read_point(p)
struct Point* p;
{
	p->y = read_word();
	p->x = read_word();
}

static void read_short_point(p)
struct Point* p;
{
	p->x = read_signed_byte();
	p->y = read_signed_byte();
}

#define PIXEL_INDEX(x,y) ((y) - picFrame.top) * rowlen + (x) - picFrame.left

static void draw_pixel(x, y, clr, trf)
int x, y;
struct RGBColour* clr;
transfer_func trf;
{
	register i;
	struct RGBColour dst;

	if (x < clip_rect.left || x >= clip_rect.right ||
		y < clip_rect.top || y >= clip_rect.bottom)
	{
		return;
	}

	i = PIXEL_INDEX(x, y);
	dst.red = red[i];
	dst.green = green[i];
	dst.blue = blue[i];
	(*trf)(clr, &dst);
	red[i] = dst.red;
	green[i] = dst.green;
	blue[i] = dst.blue;
}

static void draw_pen_rect(r)
struct Rect* r;
{
	register i = PIXEL_INDEX(r->left, r->top);
	register int x, y;
	struct RGBColour dst;
	int rowadd = rowlen - (r->right - r->left);

	for (y = r->top; y < r->bottom; y++) {
		for (x = r->left; x < r->right; x++) {
			dst.red = red[i];
			dst.green = green[i];
			dst.blue = blue[i];
			if (pen_pat.pix[(x & 7) + (y & 7) * 8])
				(*pen_trf)(&black, &dst);
			else
				(*pen_trf)(&white, &dst);
			red[i] = dst.red;
			green[i] = dst.green;
			blue[i] = dst.blue;

			i++;
		}
		i += rowadd;
	}
}

static void draw_pen(x, y)
int x, y;
{
	struct Rect penrect;

	penrect.left = x;
	penrect.right = x + pen_width;
	penrect.top = y;
	penrect.bottom = y + pen_height;

	rectinter(&penrect, &clip_rect, &penrect);

	draw_pen_rect(&penrect);
}

/*
 * Digital Line Drawing
 * by Paul Heckbert
 * from "Graphics Gems", Academic Press, 1990
 */

/* absolute value of a */
#define ABS(a)		(((a)<0) ? -(a) : (a))
/* take binary sign of a, either -1, or 1 if >= 0 */
#define SGN(a)		(((a)<0) ? -1 : 1)

/*
 * digline: draw digital line from (x1,y1) to (x2,y2),
 * calling a user-supplied procedure at each pixel.
 * Does no clipping.  Uses Bresenham's algorithm.
 *
 * Paul Heckbert	3 Sep 85
 */
static void scan_line(x1,y1,x2,y2)
     short x1,y1,x2,y2;
{
    int d, x, y, ax, ay, sx, sy, dx, dy;

	if (pen_width == 0 && pen_height == 0)
		return;

    dx = x2-x1;  ax = ABS(dx)<<1;  sx = SGN(dx);
    dy = y2-y1;  ay = ABS(dy)<<1;  sy = SGN(dy);

    x = x1;
    y = y1;
    if (ax>ay) {		/* x dominant */
	d = ay-(ax>>1);
	for (;;) {
	    draw_pen(x, y);
	    if (x==x2) return;
	    if ((x > rowlen) && (sx > 0)) return;
	    if (d>=0) {
		y += sy;
		d -= ax;
	    }
	    x += sx;
	    d += ay;
	}
    }
    else {			/* y dominant */
	d = ax-(ay>>1);
	for (;;) {
	    draw_pen(x, y);
	    if (y==y2) return;
	    if ((y > collen) && (sy > 0)) return;
	    if (d>=0) {
		x += sx;
		d -= ay;
	    }
	    y += sy;
	    d += ax;
	}
    }
}

static void Line(v)
     int v;
{
  struct Point p1;
  read_point(&p1);
  read_point(&current);
  if (verbose)
    pm_message("(%d,%d) to (%d, %d)",
	       p1.x,p1.y,current.x,current.y, 0);
  scan_line(p1.x,p1.y,current.x,current.y);
}

static void LineFrom(v)
     int v;
{
  struct Point p1;
  read_point(&p1);
  if (verbose)
    pm_message("(%d,%d) to (%d, %d)",
	       current.x,current.y,p1.x,p1.y, 0);

  if (!fullres)
	  scan_line(current.x,current.y,p1.x,p1.y);

  current.x = p1.x;
  current.y = p1.y;
}

static void ShortLine(v)
     int v;
{
  struct Point p1;
  read_point(&p1);
  read_short_point(&current);
  if (verbose)
    pm_message("(%d,%d) delta (%d, %d)",
	       p1.x,p1.y,current.x,current.y, 0);
  current.x += p1.x;
  current.y += p1.y;

  if (!fullres)
	  scan_line(p1.x,p1.y,current.x,current.y);
}

static void ShortLineFrom(v)
     int v;
{
  struct Point p1;
  read_short_point(&p1);
  if (verbose)
    pm_message("(%d,%d) delta (%d, %d)",
	       current.x,current.y,p1.x,p1.y, 0);
  p1.x += current.x;
  p1.y += current.y;
  if (!fullres)
	  scan_line(current.x,current.y,p1.x,p1.y);
  current.x = p1.x;
  current.y = p1.y;
}

static void paintRect(v)
int v;
{
	read_rect(&cur_rect);
	do_paintRect(&cur_rect);
}

static void paintSameRect(v)
int v;
{
	do_paintRect(&cur_rect);
}

static void do_paintRect(prect)
struct Rect* prect;
{
	struct Rect rect;
  
	if (fullres)
		return;

	if (verbose)
		dump_rect("painting", prect);

	rectinter(&clip_rect, prect, &rect);

	draw_pen_rect(&rect);
}

static void frameRect(v)
int v;
{
	read_rect(&cur_rect);
	do_frameRect(&cur_rect);
}

static void frameSameRect(v)
int v;
{
	do_frameRect(&cur_rect);
}

static void do_frameRect(rect)
struct Rect* rect;
{
	register int x, y;

	if (fullres)
		return;
  
	if (verbose)
		dump_rect("framing", rect);

	if (pen_width == 0 || pen_height == 0)
		return;

	for (x = rect->left; x <= rect->right - pen_width; x += pen_width) {
		draw_pen(x, rect->top);
		draw_pen(x, rect->bottom - pen_height);
	}

	for (y = rect->top; y <= rect->bottom - pen_height ; y += pen_height) {
		draw_pen(rect->left, y);
		draw_pen(rect->right - pen_width, y);
	}
}

/* a stupid shell sort - I'm so embarassed  */

static void poly_sort(sort_index, points)
     int sort_index;
     struct Point points[];
{
  int d,i,j,k,temp;

  /* initialize and set up sort interval */
  d = 4;
  while (d<=sort_index) d <<= 1;
  d -= 1;

  while (d > 1) {
    d >>= 1;
    for (j = 0; j <= (sort_index-d); j++) {
      for(i = j; i >= 0; i -= d) {
	if ((points[i+d].y < points[i].y) ||
	    ((points[i+d].y == points[i].y) &&
	     (points[i+d].x <= points[i].x))) {
	  /* swap x1,y1 with x2,y2 */
	  temp = points[i].y;
	  points[i].y = points[i+d].y;
	  points[i+d].y = temp;
	  temp = points[i].x;
	  points[i].x = points[i+d].x;
	  points[i+d].x = temp;
	}
      }
    }
  }
}

/* Watch out for the lack of error checking in the next two functions ... */

static void scan_poly(np, pts)
     int np;
     struct Point pts[];
{
  int dx,dy,dxabs,dyabs,i,scan_index,j,k,px,py;
  int sdx,sdy,x,y,toggle,old_sdy,sy0;

  /* This array needs to be at least as large as the largest dimension of
     the bounding box of the poly (but I don't check for overflows ...) */
  struct Point coord[5000];

  scan_index = 0;

  /* close polygon */
  px = pts[np].x = pts[0].x;
  py = pts[np].y = pts[0].y;

  /*  This section draws the polygon and stores all the line points
   *  in an array. This doesn't work for concave or non-simple polys.
   */
  /* are y levels same for first and second points? */
  if (pts[1].y == pts[0].y) {
    coord[scan_index].x = px;
    coord[scan_index].y = py;
    scan_index++;
  }

#define sign(x) ((x) > 0 ? 1 : ((x)==0 ? 0:(-1)) )   

  old_sdy = sy0 = sign(pts[1].y - pts[0].y);
  for (j=0; j<np; j++) {
    /* x,y difference between consecutive points and their signs  */
    dx = pts[j+1].x - pts[j].x;
    dy = pts[j+1].y - pts[j].y;
    sdx = SGN(dx);
    sdy = SGN(dy);
    dxabs = abs(dx);
    dyabs = abs(dy);
    x = y = 0;

    if (dxabs >= dyabs)
      {
	for (k=0; k < dxabs; k++) {
	  y += dyabs;
	  if (y >= dxabs) {
	    y -= dxabs;
	    py += sdy;
	    if (old_sdy != sdy) {
	      old_sdy = sdy;
	      scan_index--;
	    }
	    coord[scan_index].x = px+sdx;
	    coord[scan_index].y = py;
	    scan_index++;
	  }
	  px += sdx;
	  draw_pen(px, py);
	}
      }
    else
      {
	for (k=0; k < dyabs; k++) {
	  x += dxabs;
	  if (x >= dyabs) {
	    x -= dyabs;
	    px += sdx;
	  }
	  py += sdy;
	  if (old_sdy != sdy) {
	    old_sdy = sdy;
	    if (sdy != 0) scan_index--;
	  }
	  draw_pen(px,py);
	  coord[scan_index].x = px;
	  coord[scan_index].y = py;
	  scan_index++;
	}
      }
  }

  /* after polygon has been drawn now fill it */

  scan_index--;
  if (sy0 + sdy == 0) scan_index--;

  poly_sort(scan_index, coord);
  
  toggle = 0;
  for (i = 0; i < scan_index; i++) {
    if ((coord[i].y == coord[i+1].y) && (toggle == 0))
      {
	for (j = coord[i].x; j <= coord[i+1].x; j++)
	  draw_pen(j, coord[i].y);
	toggle = 1;
      }
    else
      toggle = 0;
  }
}
  
  
static void paintPoly(v)
     int v;
{
  struct Rect bb;
  struct Point pts[100];
  int i, np = (read_word() - 10) >> 2;

  read_rect(&bb);
  for (i=0; i<np; ++i)
    read_point(&pts[i]);

  /* scan convert poly ... */
  if (!fullres)
	  scan_poly(np, pts);
}

static void PnLocHFrac(version)
int version;
{
	word frac = read_word();

	if (verbose)
		pm_message("PnLocHFrac = %d", frac, 0, 0, 0, 0);
}

static void TxMode(version)
int version;
{
	text_mode = read_word();

	if (text_mode >= 8 && text_mode < 15)
		text_mode -= 8;
	if (verbose)
		pm_message("text transfer mode = %s",
			const_name(transfer_name, text_mode), 0, 0, 0, 0);
	
	/* ignore the text mask bit 'cause we don't handle it yet */
	text_trf = transfer(text_mode & ~64);
}

static void TxFont(version)
int version;
{
	text_font = read_word();
	if (verbose)
		pm_message("text font %s", const_name(font_name, text_font), 0, 0, 0, 0);
}

static void TxFace(version)
int version;
{
	text_face = read_byte();
	if (verbose)
		pm_message("text face %d", text_face, 0, 0, 0, 0);
}

static void TxSize(version)
int version;
{
	text_size = read_word();
	if (verbose)
		pm_message("text size %d", text_size, 0, 0, 0, 0);
}

static void
skip_text()
{
	skip(read_byte());
}

static void
LongText(version)
int version;
{
	struct Point p;

	read_point(&p);
	do_text(p.x, p.y);
}

static void
DHText(version)
int version;
{
	current.x += read_byte();
	do_text(current.x, current.y);
}

static void
DVText(version)
int version;
{
	current.y += read_byte();
	do_text(current.x, current.y);
}

static void
DHDVText(version)
int version;
{
	byte dh, dv;

	dh = read_byte();
	dv = read_byte();

	if (verbose)
		pm_message("dh, dv = %d, %d", dh, dv, 0, 0, 0);

	current.x += dh;
	current.y += dv;
	do_text(current.x, current.y);
}

static void
#ifdef __STDC__
do_text(word x, word y)
#else
do_text(x, y)
word x;
word y;
#endif
{
	int len, dy, w, h;
	struct glyph* glyph;

	if (fullres) {
		skip_text();
		return;
	}

	if (!(tfont = get_font(text_font, text_size, text_face)))
		tfont = pbm_defaultfont("bdf");

	if (ps_text) {
		do_ps_text(x, y);
		return;
	}

	for (len = read_byte(); len > 0; len--) {
		if (!(glyph = tfont->glyph[read_byte()]))
			continue;
		
		dy = y - glyph->height - glyph->y;
		for (h = 0; h < glyph->height; h++) {
			for (w = 0; w < glyph->width; w++) {
				if (glyph->bmap[h * glyph->width + w])
					draw_pixel(x + w + glyph->x, dy, &black, text_trf);
				else
					draw_pixel(x + w + glyph->x, dy, &white, text_trf);
			}
			dy++;
		}
		x += glyph->xadd;
	}


	current.x = x;
	current.y = y;
}

static void
#ifdef __STDC__
do_ps_text(word tx, word ty)
#else
do_ps_text(tx, ty)
word tx;
word ty;
#endif
{
	int len, width, i, w, h, x, y, rx, ry, o;
	byte str[256], ch;
	struct glyph* glyph;

	current.x = tx;
	current.y = ty;

	if (!ps_cent_set) {
		ps_cent_x += tx;
		ps_cent_y += ty;
		ps_cent_set = 1;
	}

	len = read_byte();

	/* XXX this width calculation is not completely correct */
	width = 0;
	for (i = 0; i < len; i++) {
		ch = str[i] = read_byte();
		if (tfont->glyph[ch])
			width += tfont->glyph[ch]->xadd;
	}

	if (verbose) {
		str[len] = '\0';
		pm_message("ps text: %s", str);
	}

	/* XXX The width is calculated in order to do different justifications.
	 * However, I need the width of original text to finish the job.
	 * In other words, font metrics for Quickdraw fonts
	 */

	x = tx;

	for (i = 0; i < len; i++) {
		if (!(glyph = tfont->glyph[str[i]]))
			continue;
		
		y = ty - glyph->height - glyph->y;
		for (h = 0; h < glyph->height; h++) {
			for (w = 0; w < glyph->width; w++) {
				rx = x + glyph->x + w;
				ry = y;
				rotate(&rx, &ry);
				if ((rx >= picFrame.left) && (rx < picFrame.right) &&
					(ry >= picFrame.top) && (ry < picFrame.bottom))
				{
					o = PIXEL_INDEX(rx, ry);
					if (glyph->bmap[h * glyph->width + w]) {
						red[o] = foreground.red;
						green[o] = foreground.green;
						blue[o] = foreground.blue;
					}
				}
			}
			y++;
		}
		x += glyph->xadd;
	}
}

/* This only does 0, 90, 180 and 270 degree rotations */

static void rotate(x, y)
int *x;
int *y;
{
	int tmp;

	if (ps_rotation >= 315 || ps_rotation <= 45)
		return;

	*x -= ps_cent_x;
	*y -= ps_cent_y;

	if (ps_rotation > 45 && ps_rotation < 135) {
		tmp = *x;
		*x = *y;
		*y = tmp;
	}
	else if (ps_rotation >= 135 && ps_rotation < 225) {
		*x = -*x;
	}
	else if (ps_rotation >= 225 && ps_rotation < 315) {
		tmp = *x;
		*x = *y;
		*y = -tmp;
	}
	*x += ps_cent_x;
	*y += ps_cent_y;
}

static void
skip_poly_or_region(version)
int version;
{
	stage = "skipping polygon or region";
	skip(read_word() - 2);
}

static
void picComment(type, length)
word type;
int length;
{
	switch (type) {
	case 150:
		if (verbose) pm_message("TextBegin");
		if (length < 6)
			break;
		ps_just = read_byte();
		ps_flip = read_byte();
		ps_rotation = read_word();
		ps_linespace = read_byte();
		length -= 5;
		if (recognize_comment)
			ps_text = 1;
		ps_cent_set = 0;
		if (verbose) {
			pm_message("%s justification, %s flip, %d degree rotation, %d/2 linespacing",
				const_name(ps_just_name, ps_just),
				const_name(ps_flip_name, ps_flip),
				ps_rotation, ps_linespace, 0);
		}
		break;
	case 151:
		if (verbose) pm_message("TextEnd");
		ps_text = 0;
		break;
	case 152:
		if (verbose) pm_message("StringBegin");
		break;
	case 153:
		if (verbose) pm_message("StringEnd");
		break;
	case 154:
		if (verbose) pm_message("TextCenter");
		if (length < 8)
			break;
		ps_cent_y = read_word();
		if (ps_cent_y > 32767)
			ps_cent_y -= 65536;
		skip(2); /* ignore fractional part */
		ps_cent_x = read_word();
		if (ps_cent_x > 32767)
			ps_cent_x -= 65536;
		skip(2); /* ignore fractional part */
		length -= 8;
		if (verbose)
			pm_message("offset %d %d", ps_cent_x, ps_cent_y);
		break;
	case 155:
		if (verbose) pm_message("LineLayoutOff");
		break;
	case 156:
		if (verbose) pm_message("LineLayoutOn");
		break;
	case 160:
		if (verbose) pm_message("PolyBegin");
		break;
	case 161:
		if (verbose) pm_message("PolyEnd");
		break;
	case 163:
		if (verbose) pm_message("PolyIgnore");
		break;
	case 164:
		if (verbose) pm_message("PolySmooth");
		break;
	case 165:
		if (verbose) pm_message("picPlyClo");
		break;
	case 180:
		if (verbose) pm_message("DashedLine");
		break;
	case 181:
		if (verbose) pm_message("DashedStop");
		break;
	case 182:
		if (verbose) pm_message("SetLineWidth");
		break;
	case 190:
		if (verbose) pm_message("PostScriptBegin");
		break;
	case 191:
		if (verbose) pm_message("PostScriptEnd");
		break;
	case 192:
		if (verbose) pm_message("PostScriptHandle");
		break;
	case 193:
		if (verbose) pm_message("PostScriptFile");
		break;
	case 194:
		if (verbose) pm_message("TextIsPostScript");
		break;
	case 195:
		if (verbose) pm_message("ResourcePS");
		break;
	case 200:
		if (verbose) pm_message("RotateBegin");
		break;
	case 201:
		if (verbose) pm_message("RotateEnd");
		break;
	case 202:
		if (verbose) pm_message("RotateCenter");
		break;
	case 210:
		if (verbose) pm_message("FormsPrinting");
		break;
	case 211:
		if (verbose) pm_message("EndFormsPrinting");
		break;
	default:
		if (verbose) pm_message("%d", type);
		break;
	}
	if (length > 0)
		skip(length);
}

static void
ShortComment(version)
int version;
{
	picComment(read_word(), 0);
}

static void
LongComment(version)
int version;
{
	word type;

	type = read_word();
	picComment(type, read_word());
}

static int
rectwidth(r)
struct Rect* r;
{
	return r->right - r->left;
}

static int
rectheight(r)
struct Rect* r;
{
	return r->bottom - r->top;
}

static int
rectequal(r1, r2)
struct Rect* r1;
struct Rect* r2;
{
	return r1->top == r2->top &&
		   r1->bottom == r2->bottom &&
		   r1->left == r2->left &&
		   r1->right == r2->right;
}

static int
rectsamesize(r1, r2)
struct Rect* r1;
struct Rect* r2;
{
	return r1->right - r1->left == r2->right - r2->left &&
		   r1->bottom - r1->top == r2->bottom - r2->top ;
}

static void
rectinter(r1, r2, r3)
struct Rect* r1;
struct Rect* r2;
struct Rect* r3;
{
	r3->left = max(r1->left, r2->left);
	r3->top = max(r1->top, r2->top);
	r3->right = min(r1->right, r2->right);
	r3->bottom = min(r1->bottom, r2->bottom);
}

static void
rectscale(r, xscale, yscale)
struct Rect* r;
double	     xscale;
double	     yscale;
{
	r->left *= xscale;
	r->right *= xscale;
	r->top *= yscale;
	r->bottom *= yscale;
}

static void
read_rect(r)
struct Rect* r;
{
	r->top = read_word();
	r->left = read_word();
	r->bottom = read_word();
	r->right = read_word();
}

static void
dump_rect(s, r)
char* s;
struct Rect* r;
{
	pm_message("%s (%d,%d) (%d,%d)",
		s, r->left, r->top, r->right, r->bottom);
}

static char*
const_name(table, ct)
struct const_name* table;
int ct;
{
	static char numbuf[32];
	int i;

	for (i = 0; table[i].name; i++)
		if (table[i].value == ct)
			return table[i].name;
	
	sprintf(numbuf, "%d", ct);
	return numbuf;
}

/*
 * All data in version 2 is 2-byte word aligned.  Odd size data
 * is padded with a null.
 */
static word
get_op(version)
int version;
{
	if ((align & 1) && version == 2) {
		stage = "aligning for opcode";
		read_byte();
	}

	stage = "reading opcode";

	if (version == 1)
		return read_byte();
	else
		return read_word();
}

static longword
read_long()
{
	word i;

	i = read_word();
	return (i << 16) | read_word();
}

static word
read_word()
{
	byte b;

	b = read_byte();

	return (b << 8) | read_byte();
}

static byte
read_byte()
{
	int c;

	if ((c = fgetc(ifp)) == EOF)
		pm_error("EOF / read error while %s", stage);

	++align;
	return c & 255;
}

static signed_byte
read_signed_byte()
{
	return (signed_byte)read_byte();
}

static void
skip(n)
int n;
{
	static byte buf[1024];

	align += n;

	for (; n > 0; n -= 1024)
		if (fread(buf, n > 1024 ? 1024 : n, 1, ifp) != 1)
			pm_error("EOF / read error while %s", stage);
}

static void
read_n(n, buf)
int n;
char* buf;
{
	align += n;

	if (fread(buf, n, 1, ifp) != 1)
		pm_error("EOF / read error while %s", stage);
}

#ifdef STANDALONE

/* glue routines if you don't have PBM+ handy; these are only good enough
 * for picttoppm's purposes!
 */

static char* outfile;

void pm_message(fmt, p1, p2, p3, p4, p5)
char* fmt;
int p1, p2, p3, p4, p5;
{
	fprintf(stderr, "picttoppm: ");
	fprintf(stderr, fmt, p1, p2, p3, p4, p5);
	fprintf(stderr, "\n");
}

void pm_error(fmt, p1, p2, p3, p4, p5)
char* fmt;
int p1, p2, p3, p4, p5;
{
	pm_message(fmt, p1, p2, p3, p4, p5);
	exit(1);
}

int pm_keymatch(arg, opt, minlen)
char* arg, *opt;
int minlen;
{
	for (; *arg && *arg == *opt; arg++, opt++)
		minlen--;
	return !*arg && minlen <= 0;
}

void ppm_init(argc, argv)
int* argc;
char** argv;
{
	outfile = "standard output";
}

FILE* pm_openr(file)
char* file;
{
	FILE* fp;

	if (!(fp = fopen(file, "rb"))) {
		fprintf(stderr, "picttoppm: can't read file %s\n", file);
		exit(1);
	}
	outfile = file;
	return fp;
}

void writerr()
{
	fprintf(stderr, "picttoppm: write error on %s\n", outfile);
	exit(1);
}

void pm_usage(u)
char* u;
{
	fprintf(stderr, "usage: picttoppm %s\n", u);
	exit(1);
}

void ppm_writeppminit(fp, width, height, maxval, forceplain)
FILE* fp;
int width, height, maxval, forceplain;
{
	if (fprintf(fp, "P6\n%d %d\n%d\n", width, height, maxval) == EOF)
		writerr();
}

pixel* ppm_allocrow(width)
int width;
{
	pixel* r;
	
	if (!(r = (pixel*)malloc(width * sizeof(pixel)))) {
		fprintf(stderr, "picttoppm: out of memory\n");
		exit(1);
	}
	return r;
}

void ppm_writeppmrow(fp, row, width, maxval, forceplain)
FILE* fp;
pixel* row;
int width, maxval, forceplain;
{
	while (width--) {
		if (fputc(row->r, fp) == EOF) writerr();
		if (fputc(row->g, fp) == EOF) writerr();
		if (fputc(row->b, fp) == EOF) writerr();
		row++;
	}
}

void pm_close(fp)
FILE* fp;
{
	if (fclose(fp) == EOF)
		writerr();
}

#endif /* STANDALONE */

/* Some font searching routines */

struct fontinfo {
	int font;
	int size;
	int style;
	char* filename;
	struct font* loaded;
	struct fontinfo* next;
};

static struct fontinfo* fontlist = 0;
static struct fontinfo** fontlist_ins = &fontlist;

int load_fontdir(dirfile)
char* dirfile;
{
	FILE* fp;
	int n, nfont;
	char* arg[5], line[1024];
	struct fontinfo* fontinfo;

	if (!(fp = fopen(dirfile, "r")))
		return -1;
	
	nfont = 0;
	while (fgets(line, 1024, fp)) {
		if ((n = mk_argvn(line, arg, 5)) == 0 || arg[0][0] == '#')
			continue;
		if (n != 4)
			continue;
		if (!(fontinfo = (struct fontinfo*)malloc(sizeof(struct fontinfo))) ||
			!(fontinfo->filename = (char*)malloc(strlen(arg[3]) + 1)))
		{
			pm_error("out of memory for font information");
		}

		fontinfo->font = atoi(arg[0]);
		fontinfo->size = atoi(arg[1]);
		fontinfo->style = atoi(arg[2]);
		strcpy(fontinfo->filename, arg[3]);
		fontinfo->loaded = 0;

		fontinfo->next = 0;
		*fontlist_ins = fontinfo;
		fontlist_ins = &fontinfo->next;
		nfont++;
	}

	return nfont;
}

static int abs_value(x)
int x;
{
	if (x < 0)
		return -x;
	else
		return x;
}

static struct font* get_font(font, size, style)
int font;
int size;
int style;
{
	int closeness, bestcloseness;
	struct fontinfo* fi, *best;

	best = 0;
	for (fi = fontlist; fi; fi = fi->next) {
		closeness = abs_value(fi->font - font) * 10000 +
			abs_value(fi->size - size) * 100 +
			abs_value(fi->style - style);
		if (!best || closeness < bestcloseness) {
			best = fi;
			bestcloseness = closeness;
		}
	}

	if (best) {
		if (best->loaded)
			return best->loaded;

		if (best->loaded = pbm_loadbdffont(best->filename))
			return best->loaded;
	}

	/* It would be better to go looking for the nth best font, really */
	return 0;
}

#ifdef VMS
unlink(p)
     char *p;
{delete(p);}
#endif
