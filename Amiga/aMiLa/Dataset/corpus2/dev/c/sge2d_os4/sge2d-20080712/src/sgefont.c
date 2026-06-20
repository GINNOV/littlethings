#include <sge.h>

typedef struct {
	int offset;
	int width;
} SGEBITMAPFONTINFO;

SGEFONT *sgeFontNew(int type) {
	SGEFONT *ret;
	sgeNew(ret, SGEFONT);
	ret->type=type;
	ret->data=NULL;
	return ret;
}

SGEFONT *sgeFontNewFileBitmap(SGEFILE *f, const char *filename) {
	SGEFONT *ret=sgeFontNew(SGEFONT_BITMAP);
	SGEBITMAPFONT *data;
	int i=0;
	char *tmp;
	SGEPIXELINFO *pi;
	SGEBITMAPFONTINFO *fi;
	int offset=0;

	sgeMalloc(tmp,char,strlen(filename)+5);
	strcpy(tmp, filename);
	strcat(tmp,".map");

	sgeNew(data, SGEBITMAPFONT);
	data->bitmap=sgeReadImage(f,filename);
	data->charmap=(unsigned char *)sgeReadFile(f, tmp);
	data->info=sgeArrayNew();

	for (i=0;i<data->bitmap->w;i++) {
		pi=sgeGetPixel(data->bitmap, i, 0);
		if (
				(
				 (pi->r==255) &&
				 (pi->g==0) &&
				 (pi->b==255)
				) ||
				(i==data->bitmap->w-1)
		) {
			sgeNew(fi,SGEBITMAPFONTINFO);
			fi->offset=offset;
			fi->width=i-offset-1;
			sgeArrayAdd(data->info,fi);
			offset=i+1;
		}
		sgePixelInfoDestroy(pi);
	}

	ret->data=data;
	return ret;
}

SGEFONT *sgeFontNewFile(SGEFILE *f, int type, const char *filename) {
	switch (type) {
		case SGEFONT_BITMAP:
			return sgeFontNewFileBitmap(f, filename);
	}
	return NULL;
}

static void sgeFontDestroyBitmap(SGEFONT *f) {
	SGEBITMAPFONT *bfont;
	SGEBITMAPFONTINFO *bfi;

	bfont=(SGEBITMAPFONT *)f->data;
	SDL_FreeSurface(bfont->bitmap);
	sgeFree(bfont->charmap);
	while (bfont->info->numberOfElements>0) {
		bfi=sgeArrayGet(bfont->info,0);
		sgeFree(bfi);
		sgeArrayRemove(bfont->info,0);
	}
	sgeArrayDestroy(bfont->info);
	sgeFree(bfont);
}

void sgeFontDestroy(SGEFONT *f) {

	if (f->data!=NULL) {
		switch (f->type) {
			case SGEFONT_BITMAP:
				sgeFontDestroyBitmap(f);
				break;
		}
	}
	sgeFree(f);
}

int sgeFontGetLineHeightBitmap(SGEFONT *f) {
	SGEBITMAPFONT *bfont;
	bfont=(SGEBITMAPFONT *)f->data;
	return bfont->bitmap->h;
}

int sgeFontGetLineHeight(SGEFONT *f) {
	if (f->data==NULL) return -1;

	switch (f->type) {
		case SGEFONT_BITMAP:
			return sgeFontGetLineHeightBitmap(f);
	}
	return -1;
}

int sgeFontPrintBitmap(SGEFONT *f, SDL_Surface *dest, int x, int y, const char *text) {
	SGEBITMAPFONT *bfont;
	SGEBITMAPFONTINFO *bfi;
	int i;
	int xx=x;
	int c, idx;
	char *pos;
	SDL_Rect src, dst;

	bfont=(SGEBITMAPFONT *)f->data;

	dst.y=y;
	src.h=bfont->bitmap->h;
	src.y=0;

	for (i=0;i<strlen(text);i++) {
		c=text[i];
		pos=strchr((const char *)bfont->charmap, c);
		if (pos!=NULL) {
			idx=pos-(char *)bfont->charmap;
			bfi=sgeArrayGet(bfont->info, idx);

			dst.x=xx;
			src.x=bfi->offset;
			src.w=bfi->width;
			xx+=bfi->width;

			SDL_BlitSurface(bfont->bitmap, &src, dest, &dst);
		}
	}
	return xx-x;
}

int sgeFontPrint(SGEFONT *f, SDL_Surface *dest, int x, int y, const char *text) {
	switch (f->type) {
		case SGEFONT_BITMAP:
			return sgeFontPrintBitmap(f, dest, x, y, text);
	}
	return 0;
}

int sgeFontGetWidth(SGEFONT *f, const char *text) {
	switch (f->type) {
		case SGEFONT_BITMAP:
			return sgeFontGetWidthBitmap(f, text);
	}
	return 0;
}

int sgeFontGetWidthBitmap(SGEFONT *f, const char *text) {
	SGEBITMAPFONT *bfont;
	SGEBITMAPFONTINFO *bfi;
	int i;
	int c, idx;
	char *pos;
	int ret=0;

	bfont=(SGEBITMAPFONT *)f->data;

	for (i=0;i<strlen(text);i++) {
		c=text[i];
		pos=strchr((const char *)bfont->charmap, c);
		if (pos!=NULL) {
			idx=pos-(char *)bfont->charmap;
			bfi=sgeArrayGet(bfont->info, idx);
			ret+=bfi->width;
		}
	}
	return ret;
}

