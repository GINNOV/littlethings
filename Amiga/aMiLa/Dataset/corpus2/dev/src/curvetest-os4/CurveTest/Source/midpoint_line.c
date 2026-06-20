/**
 * \file midpoint_line.c
 * \brief Impliments the 'LINE' and 'CIRCLE' graphics primitives
 */
#include <string.h>
#include <SDL/SDL.h>

static int iabs(int i) { if(i<0) return(-i); else return(i); }

static inline int incdir(int a,int b)
{
  if(a>b) return(-1);
  else    return(1);
}

static inline void swap(int *a, int *b)
{
  int tmp=*a;
  *a=*b;
  *b=tmp;
}

/*
 * Set the pixel at (x, y) to the given value
 * NOTE: The surface must be locked before calling this!
 */
void putpixel(SDL_Surface *surface, int x, int y, Uint32 pixel)
{
    int bpp = surface->format->BytesPerPixel;
    /* Here p is the address to the pixel we want to set */
    Uint8 *p = (Uint8 *)surface->pixels + y * surface->pitch + x * bpp;

    if((x>surface->w)||(y>surface->h)||(x<0)||(y<0)) return;

    switch(bpp) {
    case 1:
        *p = pixel;
        break;

    case 2:
        *(Uint16 *)p = pixel;
        break;

    case 3:
        if(SDL_BYTEORDER == SDL_BIG_ENDIAN) {
            p[0] = (pixel >> 16) & 0xff;
            p[1] = (pixel >> 8) & 0xff;
            p[2] = pixel & 0xff;
        } else {
            p[0] = pixel & 0xff;
            p[1] = (pixel >> 8) & 0xff;
            p[2] = (pixel >> 16) & 0xff;
        }
        break;

    case 4:
        *(Uint32 *)p = pixel;
        break;
    }
}

/**
 * Quickly draws horizontal lines, taking advantage of the fact that
 * characters are grouped by horizontal line in image[][].  After 
 * checking for clipping it can simply fill x2-x characters in a row 
 * with cur_color by calling memset.
 */
void horiz_line(SDL_Surface *s, int x, int x2, int y, Uint32 color)
{
  SDL_Rect r;

  r.y=y;
  r.h=1;

  if(x2<x)
  {
    r.x=x2;
    r.w=x-x2;
  }
  else
  {
    r.x=x;
    r.w=x2-x;
  }
  SDL_FillRect(s,&r,color);
}

/*! \brief Converts one 1/8 of an arc into a full circle. */
/*void circlepoints(int x, int y, int xoff, int yoff)
{
  putpixel(x+xoff,y+yoff,cur_color*2);
  putpixel(x+xoff,y-yoff,cur_color*2);
  putpixel(x-xoff,y+yoff,cur_color*2);
  putpixel(x-xoff,y-yoff,cur_color*2);
  putpixel(x+yoff,y+xoff,cur_color*2);
  putpixel(x+yoff,y-xoff,cur_color*2);
  putpixel(x-yoff,y+xoff,cur_color*2);
  putpixel(x-yoff,y-xoff,cur_color*2);
}*/
/**
 * Calculates circle points with the integer midpoint algorithm.
 *
 * There are 8 reflections of the generated arc, 4 on the left
 * and for on the right.  Horizontal lines are drawn between
 * reflections of the same row to fill it.  Horizontal lines
 * are used because they are a special case that draws extremely
 * quickly.
 *
 * Overdraw is reduced by considering that the top-most and bottom-most 
 * reflections only need to be filled  when the row value changes;
 * when the column value alone changes, it just makes the line wider by
 * two pixels.
 */
void midpoint_circle(SDL_Surface *s, int xin, int yin, int rad, Uint32 color)
{
  int x=0,y=rad,d=1-rad,deltaE=3,deltaSE=5-(rad*2);

  if(rad<0) return; // sanity checking

  horiz_line(s,xin-y,xin+y,yin,color); // Center line

  while(y>x)
  {
    if(d<0)
    {
      d+=deltaE;
      deltaE+=2;
      deltaSE+=2;
    }
    else
    {
      // Only need to draw these lines when y changes
      horiz_line(s,xin-x,xin+x,yin+y,color); // Bottom-most reflections
      horiz_line(s,xin-x,xin+x,yin-y,color); // Top-most reflections
      d+=deltaSE;
      deltaE+=2;
      deltaSE+=4;
      y--;
    }

    x++;
    // These lines change y every time x increments.
    horiz_line(s,xin-y,xin+y,yin-x,color); // Upper middle reflections
    horiz_line(s,xin-y,xin+y,yin+x,color); // Lower middle reflections
  }
}

void midpoint_line(SDL_Surface *s, int x0, int y0, int x1, int y1, Uint32 color)
{
  // absolute values of dx and dy, so as to not screw up calculation
  int dx=iabs(x1-x0),dy=iabs(y1-y0),x=x0,y=y0;
  // When true, the loop will iterate through y instead of x
  int reverse=dy>dx;
  // These record which direction the line should go
  int xdir=incdir(x0,x1),ydir=incdir(y0,y1);
  int d,incrE,incrNE;

  // Swap dx and dy if reversed, so as to not fubar equation
  if(reverse) swap(&dy,&dx);

  // Initialize.  If 
  d=(dy*2)-dx;
  incrE=dy*2;
  incrNE=(dy-dx)*2;

  // Draw first pixel
  putpixel(s,x,y,color);
  if(reverse)
    while(y!=y1) // Iterate through y
    {
      y+=ydir;
      if(d<=0)
        d+=incrE;
      else
      {
        x+=xdir;
        d+=incrNE;
      }
      // Draw next pixel
      putpixel(s,x,y,color);
    }
  else
    while(x!=x1) // Iterate through x
    {
      x+=xdir;
      if(d<=0)
        d+=incrE;
      else
      {
        y+=ydir;
        d+=incrNE;
      }
      // Draw pixel
      putpixel(s,x,y,color);
    }
}
/* end of midpoint_line.c */
