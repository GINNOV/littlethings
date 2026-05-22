///////////////////////////////////////////////////////////////
// mouse_tile.cpp
// 
// This program draws a white grind using graphic primitives as 
// points, lines and squares. The grind is used to simulate a 
// landscape made of tiles.
// Then the program manages mouse events recognizing where the 
// mouse pointer is located and colouring red the actual cell 
// borders, when the user push the left mouse button a yellow
// cross il drawn at the center of the actual cell.
// Obviously the real scope of the program is to show how to 
// calculate the cell cordinates of a grind of tiles.
// 
//
// This software is released under GPL license, you can find a 
// copy of this license at http://www.gnu.org/copyleft/gpl.html
// 
// 
// Last update date: 
// 	2004-10-25 
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
#include <SDL/SDL.h>
#include <SDL/SDL_image.h>

#define DIM_H	800
#define DIM_V	600
#define BUTTON_SX 1
#define BUTTON_DX 3

//used structures
typedef struct point
{
	int x;
	int y;
} point;

typedef struct RGB
{
	Uint8 R;
	Uint8 G;
	Uint8 B;
} RGB_Color;
	
//graphic functions 
void draw_pixel(SDL_Surface *surface, int x, int y, RGB_Color s_color);
void draw_cross(SDL_Surface *surface, point p, RGB_Color c_color);
void draw_line(SDL_Surface *surface, point p0, point p1, RGB_Color color);
void draw_square(SDL_Surface *surface, point p, int lato, RGB_Color color);

int main()
{
	//used surfaces
	SDL_Surface *screen;
	SDL_Surface *screen_backup;
	SDL_Surface *cursor;
	SDL_Surface *bg_cursor;
	SDL_Surface *temp;

	//the system video is initialized 
	if( SDL_Init(SDL_INIT_VIDEO) <0 )
	{
		//SDL_GetError() returns a description of the error
		printf("Errore init SDL: %s\n", SDL_GetError());
	        return 1;
	}

	//when exit, execute SDL_Quit to restore everything
	atexit(SDL_Quit);

	//a 32 bit integer used to store screen's flags 
	Uint32 flags = SDL_HWSURFACE|SDL_DOUBLEBUF;

	//SDL_SetVideoMode is used to have screen associated to the monitor 
	if(!( screen = SDL_SetVideoMode(DIM_H, DIM_V, 0,flags) ))
	{
		  printf("Problemi con il settaggio dello schermo: %s\n", SDL_GetError());
		  return 1;
	}

	//the original cursor must be turned off
	SDL_ShowCursor(0);
	
	//the sight's image is associated to a temporany surface 
	if((temp = IMG_Load("sight.png"))==NULL)
    	{
		printf("Errore caricamento mirino: %s\n",IMG_GetError());
		return 1;
	}
	
	//the cursor image is adapted to local display so that it can obtains better graphics performance 
	cursor = SDL_DisplayFormat(temp);

	//temp surface deallocated
	SDL_FreeSurface(temp);
	
	//the color #000000 of cursor surface is setted as transparent
    	SDL_SetColorKey(cursor, SDL_SRCCOLORKEY|SDL_RLEACCEL, SDL_MapRGB(cursor->format, 0x0, 0x0, 0x0));

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
	//counter
	int i;
	
	//window bounds 
	int x_limit = DIM_H-cursor->w;
	int y_limit = DIM_V-cursor->h;

	//A SDL_rect struct initialized with cursor dimensions, it is used to Blit surfaces and 
	//to store cursor coordinate
	SDL_Rect rect_cur; 
	rect_cur.x = 0; 
	rect_cur.y = 0; 
	rect_cur.w = cursor->w; 
	rect_cur.h = cursor->h; 

	//two struct point to define a grid side
	point p1,p2;
	//three RGC_Color structures 
	RGB_Color red = {0xFF,0x0,0x0};
	RGB_Color yellow = {0xFF,0xFF,0x0};
	RGB_Color white = {0xFF,0xFF,0xFF};

	//side dimension of a cell
	int cell_side=50;
	
	//horizontal lines of the grind are drawed
	p1.x=0;
	p1.y=0;
	p2.x=DIM_H-1;
	p2.y=0;
	
	for(i=0;i<=DIM_V/cell_side;i++)
	{
		draw_line(screen,p1, p2, white);
		p1.y+=cell_side;
		p2.y+=cell_side;
	}
	
	//last horizontal line
	p1.x=0;
	p1.y=DIM_V-1;
	p2.x=DIM_H-1;
	p2.y=DIM_V-1;
	draw_line(screen,p1, p2, white);

	//vertical lines of the grind are drawed
	p1.x=0;
	p1.y=0;
	p2.x=0;
	p2.y=DIM_V-1;

	for(i=0;i<DIM_H/cell_side;i++)
	{
		draw_line(screen,p1, p2, white);
		p1.x+=cell_side;
		p2.x+=cell_side;
	}
	
	//last vertical line
	p1.x=DIM_H-1;
	p1.y=0;
	p2.x=DIM_H-1;
	p2.y=DIM_V-1;
	draw_line(screen,p1, p2, white);

	//upper left vertex of a cell 
	point cel;
	//variables used to store row and column indexes of a cell
	int row, col, old_row=0,old_col=0;

	//SDL_Event struct used to manage events
	SDL_Event event;

	//game or main loop (as you prefer)
	while(!done)	
 	{
		//SDL_PollEvent manages user's events 
		while(SDL_PollEvent(&event))
		{
			
			//the program quits if someone press the x simbol of the window with the mouse 
			if(event.type == SDL_QUIT)  
				done = 1;  

			if(event.type == SDL_KEYDOWN)
			{
				//it quits also if someone press ESC 
				if ( event.key.keysym.sym == SDLK_ESCAPE ) 
					done = 1; 

				//visualization form is changed if someone press SPACE 
				//(from window to full screen and vice versa)
				if(event.key.keysym.sym == SDLK_SPACE ) 
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

				//column and row indexes of the cell where the mouse is located
				row=(rect_cur.x+(cursor->w)/2)/cell_side;
				col=(rect_cur.y+(cursor->h)/2)/cell_side;

				//coordinates of the center of the selected cell
				cel.x=(row*cell_side)+(cell_side/2);
				cel.y=(col*cell_side)+(cell_side/2);

				//a point is drawed at the calculated center of the selected cell
				draw_cross(screen,cel,yellow);
			}
	
			//moving with the mouse
			if(event.motion.type == SDL_MOUSEMOTION)
			{
				//coordinates of rectangle that contains the pointer are updated
				rect_cur.x=event.button.x;
				rect_cur.y=event.button.y;
				rect_cur.w = cursor->w; 
				rect_cur.h = cursor->h; 

				//horizontal bounds checks
				if(rect_cur.x >= x_limit)
					rect_cur.x = x_limit;
				else if(rect_cur.x < 0)
					rect_cur.x = 0;
			
				//vertical bound checks
				if(rect_cur.y >= y_limit)
					rect_cur.y = y_limit;
				else if(rect_cur.y < 0)
					rect_cur.y = 0;

				//column and row indexes of the cell where the mouse is located
				row=(rect_cur.x+(cursor->w)/2)/cell_side;
				col=(rect_cur.y+(cursor->h)/2)/cell_side;
				
				//if the actual cell is different from the previous calculated we refresh 
				//the selection
				if(row!=old_row || col!=old_col)
				{
					//old cell borders are colored of white 
					cel.x=old_row*cell_side;
					cel.y=old_col*cell_side;
					draw_square(screen,cel,cell_side,white);

					//new cell borders are colored of red 
					cel.x=row*cell_side;
					cel.y=col*cell_side;
					draw_square(screen,cel,cell_side,red);

					//the old indexes are updated 
					old_row=row;
					old_col=col;
				}
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

//this function draws a square of wanted color on a surface having side lenght, 
//p is the upper left vertex of the square 
void draw_square(SDL_Surface *surface, point p, int lenght, RGB_Color color)
{
	point temp;

	//up side 
	if(p.x+lenght<DIM_H)
		temp.x=p.x+lenght;
	else
		temp.x=DIM_H-1;
	temp.y=p.y;
	draw_line(surface,p,temp,color);
	
	//left side
	temp.x=p.x;
	if(p.y+lenght<DIM_V)
		temp.y=p.y+lenght;
	else
		temp.y=DIM_V-1;
	draw_line(surface,p,temp,color);
	
	//down side 
	if(p.y+lenght<DIM_V)
		p.y+=lenght;
	else
		p.y=DIM_V-1;
	if(p.x+lenght<DIM_H)
		temp.x=p.x+lenght;
	else
		temp.x=DIM_H-1;
	temp.y=p.y;
	draw_line(surface,p,temp,color);
	
	//right side
	if(p.x+lenght<DIM_H)
		p.x+=lenght;
	else
		p.x=DIM_H-1;
	temp.x=p.x;
	temp.y=p.y-lenght;
	draw_line(surface,p,temp,color);
}
