///////////////////////////////////////////////////////////////
// iso_mouse.cpp
// 
// This program draws a white grid using graphic primitives as 
// points, lines and squares. The grid is used to simulate a 
// landscape made of isometric tiles.
// Then the program manages mouse events recognizing where the 
// mouse pointer is located and colouring red the actual cell 
// borders, when the user push the left mouse button a yellow
// cross is drawn.
// Obviously the real scope of the program is to show how to 
// calculate the cell cordinates of a grid of isometric tiles.
// 
//
// This software is released under GPL license, you can find a 
// copy of this license at http://www.gnu.org/copyleft/gpl.html
// 
// 
// Last update date: 
// 	2005-07-03 
//
// Author:
// 	Davide Coppola - dmc@dev-labs.net
//
// NOTE: 
// 
// This program is part of "Mars, Land of No Mercy" SDL examples, 
// you can find others examples on http://mars.sourceforge.net
//	
/////////////////////////////////////////////////////////////////
#include <stdio.h>
#include <stdlib.h>
#include <math.h>
#include <SDL/SDL.h>
#include <SDL/SDL_image.h>

#define DIM_H	800
#define DIM_V	600
#define BUTTON_SX 1

//rows of our grid
#define ROWS 6

//iso cell dimension
#define ISO_WIDTH 128
#define ISO_HEIGHT 64 

//sin(-45°) & cos(-45°)
#define SIN_MIN_45 -0.707106
#define COS_MIN_45 0.707106
//sqrt(2)
#define SQRT2 1.414213

//used structures
typedef struct point
{
	int x;
	int y;
} point;

typedef struct float_point
{
	float x;
	float y;
} f_point;


typedef struct RGB
{
	Uint8 R;
	Uint8 G;
	Uint8 B;
} RGB_Color;
	
//used functions
void draw_pixel(SDL_Surface *surface, int x, int y, RGB_Color s_color);
void draw_cross(SDL_Surface *surface, point p, RGB_Color c_color);
void draw_line(SDL_Surface *surface, point p0, point p1, RGB_Color color);
void draw_iso_square(SDL_Surface *surface,point p, int len, RGB_Color color);
SDL_Surface * init_img(char img[], RGB_Color trans);
f_point * iso2scr(point scr, point start);

int main()
{
	//used surfaces
	SDL_Surface *screen;
	SDL_Surface *screen_backup;
	SDL_Surface *cursor;
	SDL_Surface *bg_cursor;

	//used colors
	RGB_Color fuchsia = {0xFF,0x0,0xFF};
	RGB_Color red = {0xFF,0x0,0x0};
	RGB_Color yellow = {0xFF,0xFF,0x0};
	RGB_Color white = {0xFF,0xFF,0xFF};

	//video system init
	if( SDL_Init(SDL_INIT_VIDEO) <0 )
	{
		printf("SDL Error: %s\n", SDL_GetError());
	        return 1;
	}

	//SQL_Quit will manage the exit
	atexit(SDL_Quit);

	//a 32 bit integer used to store screen's flags 
	Uint32 flags = SDL_HWSURFACE|SDL_DOUBLEBUF;

	//SDL_SetVideoMode is used to have screen associated to the monitor 
	if(!( screen = SDL_SetVideoMode(DIM_H, DIM_V, 0,flags) ))
	{
		  printf("SDL error: %s\n", SDL_GetError());
		  return 1;
	}

	//the original cursor must be turned off
	SDL_ShowCursor(0);

	//cursor image is initialized
	cursor=init_img("img/m_pointer.png",fuchsia);

	//these flags are used by others surfaces
	flags = SDL_HWSURFACE|SDL_SRCCOLORKEY;
	//bg_cursor is a surface of the same dimensions of cursor, it covers the trail leaved by the 
	//motion of the sight
	bg_cursor=SDL_CreateRGBSurface(flags,cursor->w,cursor->h,cursor->format->BitsPerPixel,0,0,0,0);
	//screen_backup is a surface of the same dimensions of screen used  to save the image when the user
	//changes its form (window to full screen and vice versa). 
	screen_backup=SDL_CreateRGBSurface(flags,screen->w,screen->h,screen->format->BitsPerPixel,0,0,0,0);

	//variable used to control the game loop 
	int done = 0;
	
	//A SDL_rect struct initialized with cursor dimensions, it is used to Blit surfaces and 
	//to store cursor coordinate
	SDL_Rect rect_cur; 
	rect_cur.x = 0; 
	rect_cur.y = 0; 
	rect_cur.w = cursor->w; 
	rect_cur.h = cursor->h; 

	//the point where the first iso square is drawn
	point start;
	//a temp point	
	point p;

	start.x = (DIM_H - ISO_WIDTH)/2;
	start.y = 0;

	//side lenght of an iso square
	float iso_side = (float) (ISO_HEIGHT * SQRT2);
	//DEBUG
	printf("ISO_SIDE: %f\n\n", iso_side);

	//counters
	int k,z;

	//the grid 
	for(k=0;k<ROWS;k++)
	{
		for(z=0;z<ROWS;z++)
		{
			//these formulas convert the screen coordinates to isometric coordinates
			p.x = (z-k)*(ISO_HEIGHT)+start.x;
			p.y = (z+k)*(ISO_HEIGHT/2)+start.y;
			//draw an isometic square
			draw_iso_square(screen,p,ISO_WIDTH,white);
		}
	}

	//the screen is updated
	SDL_Flip(screen);
	
	//screen coordinates
	point s_cord;
	//iso (0,0)
	point i_start;
	i_start.x=start.x+ISO_HEIGHT;
	i_start.y=start.y;

	//variables used to store row and column indexes of a cell
	int row, col, old_row=0,old_col=0;

	//SDL_Event struct used to manage events
	SDL_Event event;

	//an isometric point
	f_point * iso;

	//game or main loop (as you prefer)
	while(!done)	
 	{
		
		//SDL_WaitEvent waits the next event 
		while(SDL_PollEvent(&event))
		{
		
			//the program quits if someone press the x simbol of the window with the mouse 
			if(event.type == SDL_QUIT)  
				done = 1;  

			if(event.type == SDL_KEYDOWN)
			{
				//it quits also if someone press ESC 
				if(event.key.keysym.sym == SDLK_ESCAPE) 
					done = 1; 

				//visualization mode is changed if someone press SPACE 
				//(from window to full screen and vice versa)
				if (event.key.keysym.sym == SDLK_SPACE) 
				{
					//the actual screen is saved in screen_backup
					SDL_BlitSurface(screen,NULL,screen_backup,NULL);
					//visualization form is changed
					flags^=SDL_FULLSCREEN;
					screen = SDL_SetVideoMode(DIM_H, DIM_V, 0,flags);
					//the original image is reBlitted
					SDL_BlitSurface(screen_backup,NULL,screen,NULL);
				}
			}

			//a point is selected when the left mouse button is pressed
			if(event.button.button == BUTTON_SX && event.button.type == SDL_MOUSEBUTTONDOWN)
			{
				//screen coordinates
				s_cord.x=event.button.x;
				s_cord.y=event.button.y;

				//DEBUG
				printf("ISO: x = %d | y = %d\n",s_cord.x,s_cord.y); 
				
				draw_cross(screen,s_cord,yellow);

				//iso coordinates
				iso = iso2scr(s_cord,i_start);

				//column and row indexes of the cell where the mouse is located
				row = (int)(iso->x/iso_side);
				col = (int)(iso->y/iso_side);

				if(iso->x < 0 & iso->x >= -iso_side)
						row = -1;
				if(iso->y < 0 & iso->y >= -iso_side)
						col = -1;

				//DEBUG
				printf("ORTHO: x = %f | y = %f\n",iso->x,iso->y); 
				printf("CELL: (%d,%d)\n\n",row,col);

				free(iso);
			}
	
			//moving with the mouse
			if(event.motion.type == SDL_MOUSEMOTION)
			{
				//coordinates of rectangle that contains the pointer are updated
				rect_cur.x = event.button.x;
				rect_cur.y = event.button.y;
				rect_cur.w = cursor->w; 
				rect_cur.h = cursor->h; 

				//these are screen coordinates
				s_cord.x=event.button.x;
				s_cord.y=event.button.y;
				//convert to iso
				iso = iso2scr(s_cord,i_start);
	
				//column and row indexes of the cell where the mouse is located
				row = (int)(iso->x/iso_side);
				col = (int)(iso->y/iso_side);

				//row = -1 & col = -1 requires a special management
				if(iso->x < 0 & iso->x >= -iso_side)
						row = -1;
				if(iso->y < 0 & iso->y >= -iso_side)
						col = -1;

				//if the actual cell is different from the previous calculated we refresh 
				//the selection
				if((row!=old_row || col!=old_col))
				{

					//old cell borders are colored of white if the cell is inside the grid
					if(old_row >= 0 & old_col >= 0 & old_row < ROWS & old_col < ROWS)	
					{
						p.x = (old_row-old_col)*(ISO_HEIGHT)+start.x;
						p.y = (old_row+old_col)*(ISO_HEIGHT/2)+start.y;
						draw_iso_square(screen,p,ISO_WIDTH,white);
					}

					//new cell borders are colored of red if the cell is inside the grid
					if(row >= 0 & col >= 0 & row < ROWS & col < ROWS)	
					{
						p.x = (row-col)*(ISO_HEIGHT)+start.x;
						p.y = (row+col)*(ISO_HEIGHT/2)+start.y;
						draw_iso_square(screen,p,ISO_WIDTH,red);
					}

					//the old indexes are updated 
					old_row = row;
					old_col = col;
				}

				free(iso);
			}

		}

		//the rectangular area of screen where is located the mouse cursor is 
		//saved into bg_cursor
		SDL_BlitSurface(screen, &rect_cur, bg_cursor, NULL); 
			
		//the cursor is blitted on its new position
		SDL_BlitSurface(cursor, NULL, screen, &rect_cur);
		
		//the screen is refreshed
		SDL_Flip(screen);
		
		//bg_cursor is drawed to cover the trail leaved by the motion of the mouse pointer 
		SDL_BlitSurface(bg_cursor, NULL, screen, &rect_cur);

		//a minimum delay
		SDL_Delay(1);
	}

	return 0;
}

//this function draws a pixel of wanted color on a surface at (x,y) coordinate
void draw_pixel(SDL_Surface *surface, int x, int y, RGB_Color s_color)
{
	//SDL_MapRGB return a color map depending on bpp (definition)
	Uint32 color = SDL_MapRGB(surface->format, s_color.R, s_color.G, s_color.B);

	//byte per pixel
	int bpp = surface->format->BytesPerPixel;

	//the selected pixel 
	Uint8 *pixel = (Uint8 *)surface->pixels + y * surface->pitch + x * bpp;

	//here is checked the number of byte used by our surface
	switch (bpp)
	{
		case 1: // 1 byte =>  8-bpp
			*pixel = color;
		        break;
	        case 2: // 2 byte => 16-bpp
      			*(Uint16 *)pixel = color;
			break;
    		case 3: // 3 byte => 24-bpp
			if(SDL_BYTEORDER == SDL_BIG_ENDIAN) 
			{
				pixel[0] = (color >> 16) & 0xff;
			        pixel[1] = (color >> 8) & 0xff;
				pixel[2] = color & 0xff;
			} 
			else 
			{
			        pixel[0] = color & 0xff;
				pixel[1] = (color >> 8) & 0xff;
				pixel[2] = (color >> 16) & 0xff;
			}
	      		break;
    		case 4: // 4 byte => 32-bpp
			*(Uint32 *)pixel = color;
      			break;
  	}
}

//this function draws a 5 pixel cross of wanted color on a surface at (x,y) coordinate
void draw_cross(SDL_Surface *surface, point p, RGB_Color c_color)
{
	//the surface is locked
	if ( SDL_MUSTLOCK(surface) )
		SDL_LockSurface(surface);

	//pixels are drawn
	//NOTE: none boundary checks are executed
	draw_pixel(surface,p.x,p.y,c_color);
	draw_pixel(surface,p.x+1,p.y,c_color);
	draw_pixel(surface,p.x-1,p.y,c_color);
	draw_pixel(surface,p.x,p.y+1,c_color);
	draw_pixel(surface,p.x,p.y-1,c_color);

	//the surface is unlocked
	if ( SDL_MUSTLOCK(surface) )
       		SDL_UnlockSurface(surface);
}

//this function draws a line of wanted color on a surface from p0 point to p1 point
void draw_line(SDL_Surface *surface,point p0, point p1, RGB_Color color)
{
	int i;
	int comp;
	int d_a,d_b;
	int a,b;
	int inc;

	//the surface is locked
	if ( SDL_MUSTLOCK(surface) )
		SDL_LockSurface(surface);

	//just one point
	if(p0.x==p1.x && p0.y==p1.y)
		  draw_pixel(surface,p0.x,p0.y,color);
	//the line is drawn along horizontal direction
	else if(abs(p1.x-p0.x)>=abs(p1.y-p0.y))
	{
		d_a=p1.x-p0.x;
		d_b=p1.y-p0.y;
		a=p0.x;
		b=p1.x;
		
		//from left to right 
		if(p0.x<p1.x)
			inc=1;
		//from right to left
		else
			inc=-1;

		//this draws also the last pixel
		b+=inc;

		for(i=a;i!=b;i=i+inc)
		{
			//y is calculated
			comp=(d_b*(i-a))/(d_a)+p0.y;	
			//calculated pixel is drawn
		  	draw_pixel(surface,i,comp,color);
		}

	}
	//the line is drawn along vertical direction
	else
	{
		d_a=p1.y-p0.y;
		d_b=p1.x-p0.x;
		a=p0.y;
		b=p1.y;
		
		//from down to up 
		if(p0.y<p1.y)
			inc=1;
		//from up to down
		else
			inc=-1;

		//this draws also the last pixel
		b+=inc;
		
		for(i=a;i!=b;i=i+inc)
		{
			//x is calculated
			comp=(d_b*(i-a))/(d_a)+p0.x;	
			//calculated pixel is drawn
		       	draw_pixel(surface,comp,i,color);
		}
	}

	//the surface is unlocked
	if ( SDL_MUSTLOCK(surface) )
       		SDL_UnlockSurface(surface);
}

//this function draw an isometric square into a cell with upper left point at p, 
//lenght len and of color color
void draw_iso_square(SDL_Surface *surface,point p, int len, RGB_Color color)
{
	point temp;

	temp.x=p.x+(len/2);
	temp.y=p.y;
	p.y+=(len/4);
	draw_line(surface,p,temp,color);

	
	temp.y+=(len/2);
	draw_line(surface,p,temp,color);

	temp.y-=(len/2);
	p.x+=len;
	draw_line(surface,p,temp,color);

	temp.y+=(len/2);
	draw_line(surface,p,temp,color);
	
}

//init an image and return a surface
SDL_Surface * init_img(char img[], RGB_Color trans)
{
 	SDL_Surface *good;
	SDL_Surface *temp;
  
  	//the image is loaded on a temporary surface
	if((temp = IMG_Load(img))==NULL)
	{
		printf("SDL error: %s\n",IMG_GetError());
	   	exit(1);
	}
	
  	//the  image is adapted to local display so that it can obtains better graphics performance 
  	good = SDL_DisplayFormat(temp);

	//color is setted as transparent
  	SDL_SetColorKey(good, SDL_SRCCOLORKEY|SDL_RLEACCEL, SDL_MapRGB(good->format, trans.R, trans.G, trans.B));

	//temp surface deallocated
	SDL_FreeSurface(temp);

  	return good;
}

//return orthogonal coordinates from isometric ones
f_point * iso2scr(point scr, point start)
{
	f_point * iso = (f_point *)malloc(sizeof(point));

	//initial translation
	scr.x -= start.x;
	scr.y -= start.y;
	
	//back to 45°
	scr.y *= 2;

	//back to orthogonal
	iso->x = (scr.x*COS_MIN_45-scr.y*SIN_MIN_45);
	iso->y = (scr.x*SIN_MIN_45+scr.y*COS_MIN_45);
	
	return iso;
}
