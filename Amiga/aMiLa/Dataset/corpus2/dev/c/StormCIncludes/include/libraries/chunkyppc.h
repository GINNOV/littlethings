#ifndef LIBRARIES_CHUNKPPC_H
#define LIBRARIES_CHUNKPPC_H

#ifndef EXEC_TYPES_H
#include <exec/types.h>
#endif

struct Soff
{
	int x;
	int y;
};

struct Buffers
{
	UBYTE *address;
	UBYTE *mask;
};

#define BIT16 1
#define BIT16_SWAP 2
#define BIT16_ROT 4
#define BIT16_SWAP_ROT 8
#define BIT24 16
#define BIT24_ROT 32
#define BIT32 64
#define BIT32_SWAP 128
#define BIT32_ROT 256
#define BIT32_SWAP_ROT 512
#define BIT32_ROT_REVERSE 1024
#define BIT32_SWAP_ROT_REVERSE 2048
#define BIT8 4096

struct Mode_Screen
{
	struct Screen *video_screen;
	struct Window *video_window;
	int bpr;
	int wb_int;
	int pip_int;
	int dbuf_int;
	int oldstyle_int;
	char pubscreenname[512];
	int mode;
	int SCREENWIDTH;
	int SCREENHEIGHT;
	int MS_MAXWIDTH;
	int MS_MAXHEIGHT;
	int MINDEPTH;
	int MAXDEPTH;
	int format;
	int video_depth;
	UWORD *emptypointer;
	struct BitMap *video_tmp_bm;
	int video_is_native_mode;
	int video_is_cyber_mode;
	unsigned char *screen;
	int video_oscan_height;
	int bufnum;
	struct RastPort *video_rastport;
	struct BitMap *bitmapa;
	struct BitMap *bitmapb;
	struct BitMap *bitmapc;
	struct BitMap *thebitmap;
	struct RastPort *video_temprp;
	struct ScreenModeRequester *video_smr;
	int ham_int;
	UBYTE *wbcolors;
	UBYTE *transtable;
	unsigned long *WBColorTable;
	unsigned long *ColorTable;
	int pal_changed;
	int pen_obtained;
	unsigned char *screenb;
	unsigned char *screenc;
	int numbuffers;
	int rtgm_int;
	struct ScreenBuffer *Buf1;
	struct ScreenBuffer *Buf2;
	struct ScreenBuffer *Buf3;
	void * (*algo)(struct Mode_Screen *ms,unsigned char *dest,unsigned char *src, int srcformat,void *(*hook68k)(unsigned char *data),unsigned char *data);
	void (*Internal1)(void);
	void (*Internal2)(void);
	int onlyptr;
	int likecgx;
};

#endif
