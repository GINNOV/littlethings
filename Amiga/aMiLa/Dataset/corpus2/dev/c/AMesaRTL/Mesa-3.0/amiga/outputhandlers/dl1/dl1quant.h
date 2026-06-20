/*
 * File: dl1quant.h
 *
 * Header file for dl1quant.c (DL1 Quantization)
 *
 * Copyright (C) 1993-1997 Dennis Lee
 */

/*
 * dl1quant.h
 *
 * Modified  04 Jul 1998
 * by Jarno van der Linden
 * jarno@kcbbs.gen.nz
 *
 * Some minor additions and changes to work with AmigaMesaRTL
 *
 */

#ifndef DL1QUANT_H
#define DL1QUANT_H

#include "basic.h"

GLOBAL int  dl1quant(uchar *inbuf, uchar *outbuf, int width, int height,
		     int quant_to, int dither, uchar userpal[3][256]);

#ifdef DL1SRC
typedef struct {
    ulong r, g, b;
    ulong pixel_count;
    ulong pixels_in_cube;
    uchar children;
    uchar palette_index;
    } CUBE;

typedef struct {
    uchar  level;
    ushort index;
    } FCUBE;

typedef struct {
    uchar palette_index,
	  red, green, blue;
    ulong distance;
    ulong squares[255+255+1];
    } CLOSEST_INFO;

LOCAL  void copy_pal(uchar userpal[3][256]);
LOCAL  void dlq_init(void);
LOCAL  int  dlq_start(void);
LOCAL  void reset(void);
LOCAL  void dlq_finish(void);
LOCAL  int  build_table(uchar *image, ulong pixels);
LOCAL  void fixheap(ulong id);
LOCAL  void reduce_table(int num_colors);
LOCAL  void set_palette(int index, int level);
LOCAL  void closest_color(int index, int level);
LOCAL  int  quantize_image(uchar *in, uchar *out, int width, int height,
			   int dither, int base);
LOCAL  int  bestcolor(int r, int g, int b);
#endif

#endif
