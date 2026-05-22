#include "graphic.h"

//this function draws a pixel of wanted color on a surface at (x,y) coordinate
void draw_pixel(SDL_Surface *surface, int x, int y, SDL_Color s_color)
{
	//SDL_MapRGB return a color map depending on bpp (definition)
	Uint32 color = SDL_MapRGB(surface->format, s_color.r, s_color.g, s_color.b);

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

//this function draws a line of wanted color on a surface from p0 point to p1 point
void draw_line(SDL_Surface *surface,point p0, point p1, SDL_Color color)
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
void draw_square(SDL_Surface *surface, point p, int lenght, SDL_Color color)
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

//this function uses previous draw_square to draw a square of border_color color and then
//fill it with fill_color using fill_square function
void draw_square(SDL_Surface *surface, SDL_Rect *rect , SDL_Color border_color, SDL_Color fill_color)
{
	SDL_Rect fill_rect = {rect->x + 1,rect->y + 1,rect->w - 1,rect->h - 1};
	point r = {rect->x,rect->y};

	draw_square(surface,r,rect->w,border_color);
	fill_square(surface, &fill_rect, fill_color);
}

//this function fills a rectangle area with fill_color
void fill_square(SDL_Surface *surface, SDL_Rect *rect, SDL_Color fill_color)
{
	//SDL_MapRGB return a color map depending on bpp (definition)
	Uint32 color = SDL_MapRGB(surface->format, fill_color.r, fill_color.g, fill_color.b);
	
	SDL_FillRect(surface, rect, color);
}

//this function colours all cells of a path using different color for the first and the last one
void colour_path(cell_ind path[], int num_cells, SDL_Surface *surface, SDL_Color border_color, SDL_Color fill_color)
{
	int i; 
	SDL_Rect cell;
	SDL_Color start = {0xFF, 0xFF, 0x00,0};
	SDL_Color end = {0xFF, 0x00, 0xFF,0};

	//colour first cell of yellow
	cell.y = (path[0].row * CELL_SIDE) + GRIND_Y;
	cell.x = (path[0].col * CELL_SIDE) + GRIND_X;
	cell.w = CELL_SIDE;
	cell.h = CELL_SIDE;
	draw_square(surface, &cell , border_color, start);

	//colour all others cells but last
	for(i = 1; i < num_cells-1; i++)
	{
		cell.y = (path[i].row * CELL_SIDE) + GRIND_Y;
		cell.x = (path[i].col * CELL_SIDE) + GRIND_X;
		cell.w = CELL_SIDE;
		cell.h = CELL_SIDE;
		draw_square(surface, &cell , border_color, fill_color);
	}

	//colour last cell of fuchsia
	cell.y = (path[i].row * CELL_SIDE) + GRIND_Y;
	cell.x = (path[i].col * CELL_SIDE) + GRIND_X;
	cell.w = CELL_SIDE;
	cell.h = CELL_SIDE;
	draw_square(surface, &cell , border_color, end);
}

//this function is used to colour all cells of a path with the same color
void decolour_path(cell_ind path[], int num_cells, SDL_Surface *surface, SDL_Color border_color, SDL_Color fill_color)
{
	int i; 
	SDL_Rect cell;

	for(i = 0; i < num_cells; i++)
	{
		cell.y = (path[i].row * CELL_SIDE) + GRIND_Y;
		cell.x = (path[i].col * CELL_SIDE) + GRIND_X;
		cell.w = CELL_SIDE;
		cell.h = CELL_SIDE;
		draw_square(surface, &cell , border_color, fill_color);
	}
}
