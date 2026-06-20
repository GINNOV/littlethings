#include <sge.h>

SGEPOSITION *sgePositionNew(int x, int y) {
	SGEPOSITION *ret;

	sgeNew(ret, SGEPOSITION);
	ret->x=x;
	ret->y=y;
	return ret;
}

void sgePositionDestroy(SGEPOSITION *p) {
	sgeFree(p);
}

SGEPIXELINFO *sgePixelInfoNew(Uint8 r, Uint8 g, Uint8 b, Uint8 a) {
	SGEPIXELINFO *ret;

	sgeNew(ret, SGEPIXELINFO);
	ret->r=r;
	ret->g=g;
	ret->b=b;
	ret->a=a;

	return ret;
}

void sgePixelInfoDestroy(SGEPIXELINFO *i) {
	sgeFree(i);
}

inline Uint32 sgeMakeColor(int r, int g, int b, int a) {
	Uint32 color;
	if (a<0) {
		color=SDL_MapRGB(screen->format,r,g,b);
	} else {
		color=SDL_MapRGBA(screen->format,r,g,b,a);
	}
	return color;
}

inline void sgeFillRect(SDL_Surface *dest, int x, int y, int w, int h, Uint32 color) {
	SDL_Rect rect;
	rect.x=x;
	rect.y=y;
	rect.w=w;
	rect.h=h;
	SDL_FillRect(dest, &rect, color);
}

inline void sgeDrawRect(SDL_Surface *dest, int x, int y, int w, int h, int linewidth, Uint32 color) {
	sgeFillRect(dest, x, y, w, linewidth, color);
	sgeFillRect(dest, x, y, linewidth, h, color);
	sgeFillRect(dest, x+w-linewidth, y, linewidth, h, color);
	sgeFillRect(dest, x, y+h-linewidth, w, linewidth, color);
}

inline void sgeDrawPixel(SDL_Surface *dest, int x, int y, Uint32 color) {
	Uint8 *buf8=NULL;
	Uint16 *buf16=NULL;
	Uint32 *buf32=NULL;

	if (x<0 || y<0) return;
	if (x>=dest->w || y>=dest->h) return;

	switch (dest->format->BitsPerPixel) {
		case 8:
			buf8=(Uint8 *)dest->pixels+y*dest->w+x;
			*buf8=(Uint8)color;
			break;
		case 16:
			buf16=(Uint16 *)dest->pixels+y*dest->w+x;
			*buf16=(Uint16)color;
			break;
		default:
			buf32=(Uint32 *)dest->pixels+y*dest->w+x;
			*buf32=color;
			break;
	}
}

inline SGEPIXELINFO *sgeGetPixel(SDL_Surface *dest, int x, int y) {
	Uint8 p8, *buf8;
	Uint16 p16, *buf16;
	Uint32 p32, *buf32;
	SGEPIXELINFO *ret;

	switch (dest->format->BitsPerPixel) {
		case 8:
			buf8=(Uint8 *)dest->pixels;
			p8=buf8[y*dest->w+x];
			p32=p8;
			break;
		case 16:
			buf16=(Uint16 *)dest->pixels;
			p16=buf16[y*dest->w+x];
			p32=p16;
			break;
		default:
			buf32=(Uint32 *)dest->pixels;
			p32=buf32[y*dest->w+x];
			break;
	}
	sgeNew(ret, SGEPIXELINFO);
	SDL_GetRGBA(p32, dest->format, &ret->r, &ret->g, &ret->b, &ret->a);
	return ret;
}

inline void sgeDrawLine(SDL_Surface *dest, int x, int y, int x2, int y2, Uint32 color) {
	int steep=0;
	int tmp=0;
	int dx=0;
	int dy=0;
	int err=0;
	int ystep=1;
	int yy=0;
	int xx=0;

	if (abs(y2-y)>abs(x2-x)) steep=1;
	if (steep) {
		tmp=x;
		x=y;
		y=tmp;
		tmp=x2;
		x2=y2;
		y2=tmp;
	}
	if (x>x2) {
		tmp=x;
		x=x2;
		x2=tmp;
		tmp=y;
		y=y2;
		y2=tmp;
	}
	
	if (y>y2) {
		ystep=-1;
	}

	dx=x2-x;
	dy=abs(y2-y);
	err=-dx>>1;
	yy=y;
	
	for (xx=x;xx<=x2;xx++) {
		if (!steep) {
			sgeDrawPixel(dest, xx, yy, color);
		} else {
			sgeDrawPixel(dest, yy, xx, color);
		}
		err+=dy;
		if (err>0) {
			yy+=ystep;
			err-=dx;
		}
	}
}

inline void sgeDrawImage(SDL_Surface *dest, SDL_Surface *image, int x, int y) {
	SDL_Rect r;
	r.w=image->w;
	r.h=image->h;
	r.x=x;
	r.y=y;
	SDL_BlitSurface(image, NULL, dest, &r);
}

void sgeIgnoreAlpha(SDL_Surface *s) {
	SDL_SetAlpha(s, 0, SDL_ALPHA_OPAQUE);
}

void sgeUseAlpha(SDL_Surface *s) {
	SDL_SetAlpha(s, SDL_SRCALPHA, SDL_ALPHA_OPAQUE);
}

SDL_Surface *sgeRotoZoom(SDL_Surface *source, float rotation, float zoom) {
	Uint32 *src32=(Uint32*)source->pixels;
	Uint16 *src16=(Uint16*)source->pixels;
	Uint8 *src8=(Uint8*)source->pixels;
	SDL_Surface *ret;
	SDL_Surface *target=SDL_CreateRGBSurface(
			source->flags,
			(int)((float)source->w*zoom)*3,
			(int)((float)source->h*zoom)<<1,
			source->format->BitsPerPixel,
			source->format->Rmask,
			source->format->Gmask,
			source->format->Bmask,
			source->format->Amask
	);
	SDL_Rect r;
	Uint32 *dst32=(Uint32*)target->pixels;
	Uint16 *dst16=(Uint16*)target->pixels;
	Uint8 *dst8=(Uint8*)target->pixels;

	int sinfp=(int)((sin(rotation)*65536.0)/zoom);
	int cosfp=(int)((cos(rotation)*65536.0)/zoom);

	int xc;
	int yc;

	int tx,ty;
	int x,y;
	int tempx,tempy;

	int targetpitch;
	int sourcepitch;
	int divider;

	int minx=target->w;
	int miny=target->h;
	int maxx=0;
	int maxy=0;

	switch (source->format->BitsPerPixel) {
		case 8:
			divider=0;
			break;
		case 16:
			divider=1;
			break;
		default:
			divider=2;
			break;
	}

	targetpitch=target->pitch>>divider;
	sourcepitch=source->pitch>>divider;
	xc=(source->w<<15) - ((target->w>>1)*(cosfp+sinfp));
	yc=(source->h<<15) - ((target->h>>1)*(cosfp-sinfp));

	sgeLock(target);
	for ( y=0; y<target->h; y++ ) {

		tx=xc;
		ty=yc;

		for( x=0; x<target->w; x++ ) {


			tempx=(tx>>16);
			tempy=(ty>>16);

			if( (tempx>=0) && (tempx<source->w) && (tempy>=0) && (tempy<source->h) ) {
				if (x>maxx) {
					maxx=x;
				}
				if (y>maxy) {
					maxy=y;
				}
				if (x<minx) {
					minx=x;
				}
				if (y<miny) {
					miny=y;
				}
				switch (source->format->BitsPerPixel) {
					case 8:
						*(dst8+x+y*targetpitch) = *(src8+tempx+tempy*sourcepitch);
						break;
					case 16:
						*(dst16+x+y*targetpitch) = *(src16+tempx+tempy*sourcepitch);
						break;
					default:
						*(dst32+x+y*targetpitch) = *(src32+tempx+tempy*sourcepitch);
						break;
				}
			}

			tx+=cosfp;
			ty-=sinfp;
		}
		xc+=sinfp;
		yc+=cosfp;
	}
	sgeUnlock(target);

	r.x=minx;
	r.y=miny;
	r.w=maxx-minx;
	r.h=maxy-miny;

	ret=SDL_CreateRGBSurface(
			source->flags,
			r.w,
			r.h,
			source->format->BitsPerPixel,
			source->format->Rmask,
			source->format->Gmask,
			source->format->Bmask,
			source->format->Amask
	);

	SDL_SetAlpha(target, 0, 0);

	SDL_BlitSurface(target, &r, ret, NULL);
	SDL_FreeSurface(target);

	return ret;
}
