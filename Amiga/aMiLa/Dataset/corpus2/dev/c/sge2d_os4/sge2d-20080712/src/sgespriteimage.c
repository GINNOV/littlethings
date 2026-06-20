#include <sge.h>

SGESPRITEIMAGE *sgeSpriteImageNew() {
	SGESPRITEIMAGE *ret;
	sgeNew(ret, SGESPRITEIMAGE);
	ret->image=NULL;
	ret->useAlpha=1;
	ret->x=0;
	ret->y=0;
	ret->w=0;
	ret->h=0;
	return ret;
}

SGESPRITEIMAGE *sgeSpriteImageNewFile(SGEFILE *f, const char *name) {
	SGESPRITEIMAGE *ret;
	SDL_Surface *img=sgeReadImage(f,name);
	sgeNew(ret, SGESPRITEIMAGE);
	sgeSpriteImageSetImage(ret, img);
	return ret;
}

void sgeSpriteImageDestroy(SGESPRITEIMAGE *s) {
	if (s->image!=NULL) SDL_FreeSurface(s->image);
	sgeFree(s);
}

void sgeSpriteImageSetImage(SGESPRITEIMAGE *s, SDL_Surface *image) {
	if (s->image!=NULL) SDL_FreeSurface(s->image);
	s->image=image;
	s->w=image->w;
	s->h=image->h;
	if (image->format->BitsPerPixel==32) {
		s->useAlpha=1;
	} else {
		sgeSpriteImageSetCollisionColor(s, 0, 0, 0, 0xff);
	}
}

void sgeSpriteImageDraw(SGESPRITEIMAGE *s, SDL_Surface *dest) {
	SDL_Rect r;
	r.x=s->x;
	r.y=s->y;
	SDL_BlitSurface(s->image,NULL,dest,&r);
}

void sgeSpriteImageDrawXY(SGESPRITEIMAGE *s, int x, int y, SDL_Surface *dest) {
	SDL_Rect r;
	r.x=x;
	r.y=y;
	SDL_BlitSurface(s->image,NULL,dest,&r);
}

int sgeSpriteImageBoxCollide(SGESPRITEIMAGE *a, SGESPRITEIMAGE *b) {
	Sint32 axaw, bxbw;
	Sint32 ayah, bybh;

	axaw=a->x+a->w;
	bxbw=b->x+b->w;

	if (
			( (axaw>=b->x) && (axaw<=bxbw) ) ||
			( (a->x<=b->x) && (axaw>=b->x) ) ||
			( (b->x<=a->x) && (bxbw>=a->x) )
	) {
		ayah=a->y+a->h;
		bybh=b->y+b->h;
		if ( (ayah>=b->y) && (ayah<=bybh) ) {
			return 1;
		}
		if ( (a->y>=b->y) && (a->y<=bybh) ) {
			return 1;
		}
		if ( (b->y<=a->y) && (bybh>=a->y) ) {
			return 1;
		}
		if ( (a->y<=b->y) && (ayah>=b->y) ) {
			return 1;
		}
		return 0;
	}
	if ( (a->x>=b->x) && (a->x<=bxbw) ) {
		ayah=a->y+a->h;
		bybh=b->y+b->h;
		if ( (ayah>=b->y) && (ayah<=bybh) ) {
			return 1;
		}
		if ( (a->y>=b->y) && (a->y<=bybh) ) {
			return 1;
		}
		if ( (b->y<=a->y) && (bybh>=a->y) ) {
			return 1;
		}
		if ( (a->y<=b->y) && (ayah=b->y) ) {
			return 1;
		}
		return 0;
	}
	return 0;
}

int sgeSpriteImageCollide(SGESPRITEIMAGE *a, SGESPRITEIMAGE *b) {
	int ax, ay;
	int bx, by;
	int cw, ch;
	int x,y;
	Uint32 *a32, *b32;
	Uint16 *a16, *b16;
	Uint8 *a8, *b8;
	Uint32 pa, pb, tmpcola, tmpcolb;
	Uint8 ra,ga,ba,aa,rb,gb,bb,ab;
	if (sgeSpriteImageBoxCollide(a,b)) {
		if (a->x>b->x) {
			ax=0;
			bx=a->x-b->x;
			cw=MIN(MIN(b->w-(a->x-b->x),a->w),b->w);
		} else {
			ax=b->x-a->x;
			bx=0;
			cw=MIN(MIN(a->w-(b->x-a->x),a->w),b->w);
		}
		if (a->y>b->y) {
			ay=0;
			by=a->y-b->y;
			ch=MIN(MIN(b->h-(a->y-b->y),a->h),b->h);
		} else {
			ay=b->y-a->y;
			by=0;
			ch=MIN(MIN(a->h-(b->y-a->y),a->h),b->h);
		}
		if (ch<1 || cw<1) {
			return 0;
		}
		a32=(Uint32 *)a->image->pixels;
		b32=(Uint32 *)b->image->pixels;
		a16=(Uint16 *)a->image->pixels;
		b16=(Uint16 *)b->image->pixels;
		a8=(Uint8 *)a->image->pixels;
		b8=(Uint8 *)b->image->pixels;
		for (x=0;x<cw;x++) {
			for (y=0;y<ch;y++) {
				if (a->image->format->BitsPerPixel==32||a->image->format->BitsPerPixel==24) {
					pa=a32[(y+ay)*a->w+x+ax];
					pb=b32[(y+by)*b->w+x+bx];
				} else if (a->image->format->BitsPerPixel==16) {
					pa=a16[(y+ay)*a->w+x+ax];
					pb=b16[(y+by)*b->w+x+bx];
				} else {
					pa=a8[(y+ay)*a->w+x+ax];
					pb=b8[(y+by)*b->w+x+bx];
				}
				SDL_GetRGBA(pa, a->image->format, &ra, &ga, &ba, &aa);
				SDL_GetRGBA(pb, b->image->format, &rb, &gb, &bb, &ab);
				if (a->useAlpha==1 && b->useAlpha==1 && aa!=0 && ab!=0) return 1;
				if (a->useAlpha==0 && b->useAlpha==0) {
					tmpcola=SDL_MapRGB(a->image->format,ra,ga,ba);
					tmpcolb=SDL_MapRGB(b->image->format,rb,gb,bb);
					if (tmpcola!=a->collisionColor && tmpcolb!=b->collisionColor) return 1;
				}
			}
		}
	}
	return 0;
}

void sgeSpriteImageUseAlpha(SGESPRITEIMAGE *s) {
	sgeUseAlpha(s->image);
	s->useAlpha=1;
}

void sgeSpriteImageIgnoreAlpha(SGESPRITEIMAGE *s) {
	sgeIgnoreAlpha(s->image);
	s->useAlpha=0;
}

void sgeSpriteImageSetCollisionColor(SGESPRITEIMAGE *s, int r, int g, int b, int a) {
	Uint32 col;
	if (a<0) {
		col=SDL_MapRGB(s->image->format, r, g, b);
	} else {
		col=SDL_MapRGBA(s->image->format, r, g, b, a);
	}
	s->collisionColor=col;
}

SGESPRITEIMAGE *sgeSpriteImageDuplicate(SGESPRITEIMAGE *s) {
	SGESPRITEIMAGE *ret=sgeSpriteImageNew();
	ret->x=s->x;
	ret->y=s->y;
	ret->useAlpha=s->useAlpha;
	ret->collisionColor=s->collisionColor;
	ret->w=s->w;
	ret->h=s->h;
	ret->image=SDL_ConvertSurface(s->image, s->image->format, s->image->flags);
	return ret;
}

