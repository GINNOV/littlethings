#ifndef __SAGA_H
#define __SAGA_H

#include <stdlib.h>

#define READ16(a) (*(volatile UWORD*)a)
#define READ32(a) (*(volatile ULONG*)a)

#define WRITE16(a, b) *(volatile UWORD*)(a) = (b)
#define WRITE32(a, b) *(volatile ULONG*)(a) = (b)

// SAGA Video

#define SAGA_VID_BPLPTR     0xDFF1EC	// ULONG SAGA Frame Buffer
#define SAGA_VID_PIXFMT     0xDFF1F4	// UWORD SAGA Pixel Format

// SAGA PiP

#define SAGA_PIP_DELTAX     16
#define SAGA_PIP_DELTAY     0

#define SAGA_PIP_X0         0xDFF3D0	// UWORD SAGA PiP Window X Start
#define SAGA_PIP_Y0         0xDFF3D2	// UWORD SAGA PiP Window Y Start
#define SAGA_PIP_X1         0xDFF3D4	// UWORD SAGA PiP Window X Stop
#define SAGA_PIP_Y1         0xDFF3D6	// UWORD SAGA PiP Window Y Stop
#define SAGA_PIP_BPLPTR     0xDFF3D8	// ULONG SAGA PiP Frame Buffer
#define SAGA_PIP_PIXFMT     0xDFF3DC	// UWORD SAGA PiP Pixel Format
#define SAGA_PIP_MODULO     0xDFF3DE	// UWORD SAGA PiP Modulo
#define SAGA_PIP_COLORKEY   0xDFF3E0	// UWORD SAGA PiP ColorKey (ie. 0x8F0F)
#define SAGA_PIP_COLOR0     0xDFFC00	// ULONG SAGA PiP Colors (256 colors)

#define SAGA_VIDEO_CLUT_CHUNKY  0xDFF388
#define SAGA_VIDEO_CLUT_PIP     0xDFF38C

// SAGA Formats

#define SAGAF_OFF           0x0000
#define SAGAF_CLUT          0x0001
#define SAGAF_RGB16         0x0002
#define SAGAF_RGB15         0x0003
#define SAGAF_RGB24         0x0004
#define SAGAF_RGB32         0x0005
#define SAGAF_YUV422        0x0006

#endif
