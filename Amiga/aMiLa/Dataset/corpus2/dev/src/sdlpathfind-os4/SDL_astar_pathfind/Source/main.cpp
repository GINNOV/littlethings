///////////////////////////////////////////////////////////////
// A* pathfind using "manhattan distance" heuristic
//
// This program is a simple example of pathfind based on A*
// algorithm.
// I have implemented the algorithm using linked list, this is
// not the best solution, because of the linear time need to access
// to the listes, but this is the simplest way, and this is just
// an example! ;)
// For a better implementation of A* give a look at Mars source
// code, when we will release it... :) 
//
// for info about A* algorithm and "manhattan distance" heuristic
// give a look at:
// - http://theory.stanford.edu/~amitp/GameProgramming/
// - http://www.policyalmanac.org/games/aStarTutorial.htm
// guys, thanx for your articles!
//
//
// To play with it, just select the grey "robot", it should (I hope :)) 
// became blue, now you can select a destination, the program will calculate
// the shortest path and move along it.
//
// During the "game" you could use these keys:
//
// - SPACEBAR -> change video mode (window/fullscreen)
// - p -> pause/restart the game
// - ESC -> exit
//
//
// This software is released under GPL license, you can find a 
// copy of this license at http://www.gnu.org/copyleft/gpl.html
// 
//
// Last update date: 
// 	2005-02-15 
//
// Author:
// 	Davide "M3xican" Coppola - dmc@dev-labs.net
//
// NOTE: 
// 
// This program is part of "Mars, Land of No Mercy" SDL examples, 
// you can find others examples on http://mars.sourceforge.net
//	
/////////////////////////////////////////////////////////////////
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <SDL/SDL.h>
#include "define.h"
#include "graphic.h"
#include "grind.h"
#include "pathfind.h"
#include "struct.h"

int main(int argc,char *argv[])
{
	//used surfaces
	SDL_Surface *screen;
	SDL_Surface *screen_backup;
	SDL_Surface *robot;
	SDL_Surface *bg_robot;

	//three SDL_Color structures 
	SDL_Color black = {0x00,0x00,0x00,0};
	SDL_Color light_grey = {0xDD,0xDD,0xDD,0};
	SDL_Color grey = {0x99,0x99,0x99,0};
	SDL_Color light_blue = {0x33,0x66,0x99,0};
	SDL_Color red = {0xFF,0x00,0x00,0};
	SDL_Color white = {0xFF,0xFF,0xFF,0};

	//the system video is initialized 
	if( SDL_Init(SDL_INIT_VIDEO) <0 )
	{
		//SDL_GetError() returns a description of the error
		printf("SDL Init Error: %s\n", SDL_GetError());
	        return 1;
	}

	//when exit, execute SDL_Quit to restore everything
	atexit(SDL_Quit);
	
	//a 32 bit integer used to store screen's flags 
	Uint32 flags = SDL_HWSURFACE|SDL_DOUBLEBUF;

	//SDL_SetVideoMode is used to have screen associated to the monitor 
	if(!( screen = SDL_SetVideoMode(DIM_H, DIM_V, 0,flags) ))
	{
		  printf("Screen Init Error : %s\n", SDL_GetError());
		  return 1;
	}

	//white background
	fill_square(screen, NULL, white);

	//screen_backup is a surface of the same dimensions of screen used  to save the image when the user
	//changes its form (window to full screen and vice versa). 
	screen_backup = SDL_CreateRGBSurface(flags,screen->w,screen->h,screen->format->BitsPerPixel,0,0,0,0);

	robot = SDL_CreateRGBSurface(flags,CELL_SIDE-ROBOT_DIST,CELL_SIDE-ROBOT_DIST,
								screen->format->BitsPerPixel,0,0,0,0);
	bg_robot = SDL_CreateRGBSurface(flags,CELL_SIDE-ROBOT_DIST,CELL_SIDE-ROBOT_DIST,
									screen->format->BitsPerPixel,0,0,0,0);

	//paint robot
	fill_square(robot, NULL, grey);
	
	//map rectangle
	SDL_Rect grind = {CELL_SIDE/2,CELL_SIDE/2,DIM_H-CELL_SIDE,DIM_V-CELL_SIDE};

 	//manual test map
 	int map[NUM_ROWS][NUM_COLS]={{1,1,1,1,0,1,1,1,0,0,0,1,1,1,1,1,1,1,1},
								 {1,1,1,1,0,1,1,1,0,1,0,1,1,1,1,0,0,0,1},
								 {1,1,1,1,1,1,1,1,1,1,0,1,1,1,1,1,1,1,1},
								 {1,1,1,1,1,1,1,1,1,1,0,1,1,1,1,1,1,1,1},
								 {1,0,0,0,0,0,1,1,1,1,0,1,1,1,1,1,1,1,1},
								 {1,1,1,1,1,1,1,1,1,1,1,1,0,0,0,1,1,1,1},
								 {1,1,1,1,1,1,1,1,1,1,1,1,1,0,1,1,1,1,1},
								 {1,1,1,1,1,1,1,1,0,0,1,1,1,1,1,1,1,1,1},
								 {1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1},
								 {0,1,1,1,1,1,0,1,1,1,1,1,1,1,1,1,1,1,1},
								 {0,0,0,0,1,1,0,1,1,1,1,1,1,1,1,1,0,1,1},
								 {1,1,1,1,1,1,0,1,1,1,1,1,1,1,1,1,0,1,1},
								 {1,1,1,1,1,1,1,1,1,1,1,0,0,1,0,1,0,1,1},
								 {1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1}};

	//secret MARS map :)
	/*
 	int map[NUM_ROWS][NUM_COLS]={{1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1},
								 {1,1,1,0,1,1,1,0,1,1,1,1,1,0,1,1,1,1,1},
								 {1,1,1,0,0,1,0,0,1,1,1,1,0,1,0,1,1,1,1},
								 {1,1,1,0,1,0,1,0,1,1,1,1,0,1,0,1,1,1,1},
								 {1,1,1,0,1,1,1,0,1,1,1,0,0,0,0,0,1,1,1},
								 {1,1,1,0,1,1,1,0,1,1,1,0,1,1,1,0,1,1,1},
								 {1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1},
								 {1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1},
								 {1,1,1,0,0,0,1,1,1,1,1,0,0,0,0,0,1,1,1},
								 {1,1,1,0,1,1,0,1,1,1,1,0,1,1,1,1,1,1,1},
								 {1,1,1,0,0,0,1,1,1,1,1,0,0,0,0,0,1,1,1},
								 {1,1,1,0,1,1,0,1,1,1,1,1,1,1,1,0,1,1,1},
								 {1,1,1,0,1,1,1,0,1,1,1,0,0,0,0,0,1,1,1},
								 {1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1}};
	*/

	//draw map on screen
	draw_map(screen,grind,map);

	//cell occupied by the robot
	cell_ind robot_cell;
	//robot is selected?
	bool robot_sel = false;
	//destination point
	point robot_dest;
	//path indexes 
	cell_ind * robot_path;
	//path lenghth
	int len_path = 0, bk_len = 0;
	int ind_path = 0;
	bool need_checkp = false;

	//get a free cell to place the robot on the map
	get_free_cell(map,&robot_cell);

	//robot rect
	SDL_Rect robot_rect = {grind.x + (robot_cell.col * CELL_SIDE) + ROBOT_DIST/2, 
			 				grind.y + (robot_cell.row * CELL_SIDE) + ROBOT_DIST/2, robot->w, robot->h};
	
	//upper left vertex of a cell 
	point cell_vert;

	//variables used to store row and column indexes of a cell
	cell_ind mouse_cell = {0,0}, old_cell = {0,0}, dest_cell;
	bool cell_sel = false;
	point mouse = {0,0};

	//SDL_Event struct used to manage events
	SDL_Event event;

	//variable used to control the game loop 
	bool done = false;
	bool paused = false;

	//game or main loop (as you prefer)
	while(!done)	
 	{
		//SDL_PollEvent manages user's events 
		while(SDL_PollEvent(&event))
		{
			
			//the program quits if someone press the x simbol of the window with the mouse 
			if(event.type == SDL_QUIT)  
				done = true;  

			if(event.type == SDL_KEYDOWN)
			{
				//it quits also if someone press ESC 
				if ( event.key.keysym.sym == SDLK_ESCAPE ) 
					done = true; 
				else if ( event.key.keysym.sym == SDLK_p ) 
					paused = !paused ;

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
				//robot cell clicked
				if(mouse_cell.row == robot_cell.row && mouse_cell.col == robot_cell.col)
				{
					//robot not yet selected
					if(!robot_sel)
					{		
						robot_sel = true;
						fill_square(robot, NULL, light_blue);
					}
					else	//robot selected
					{
						robot_sel = false;
						fill_square(robot, NULL, grey);
					}
				}
				//free cell clicked to move
				else if(map[mouse_cell.row][mouse_cell.col] && robot_sel && !len_path)	
				{
					cell_sel = true;

					dest_cell.row = mouse_cell.row;
					dest_cell.col = mouse_cell.col;

					len_path = pathfind(map,robot_cell,dest_cell,&robot_path);

					if(len_path)
					{
						//backup path lenght
						bk_len = len_path;
						need_checkp = true;
						//draw path
						colour_path(robot_path,len_path,screen,black,light_grey);
					}

				}
			}
	
			//moving with the mouse
			if(event.motion.type == SDL_MOUSEMOTION)
			{
				//coordinates of rectangle that contains the pointer are updated
				mouse.x = event.button.x;
				mouse.y = event.button.y;

				//horizontal bounds checks
				if(mouse.x >= DIM_H)
					mouse.x = DIM_H-1;
				else if(mouse.x < 0)
					mouse.x = 0;
			
				//vertical bound checks
				if(mouse.y >= DIM_V)
					mouse.y = DIM_V-1;
				else if(mouse.y < 0)
					mouse.y = 0;
				
				if(mouse.x >= (CELL_SIDE/2) && mouse.x <= (DIM_H - 1 - (CELL_SIDE/2)) && 
	   			mouse.y >= (CELL_SIDE/2) && mouse.y <= (DIM_V - 1 - (CELL_SIDE/2)))
				{
					//column and row indexes of the cell where the mouse is located
					mouse_cell.row = (mouse.y - grind.y) / CELL_SIDE;
					mouse_cell.col = (mouse.x - grind.x) / CELL_SIDE;
					
					//if the actual cell is different from the previous calculated we refresh 
					//the selection
					if((mouse_cell.row != old_cell.row || mouse_cell.col != old_cell.col) 
					&& map[mouse_cell.row][mouse_cell.col])
					{
						//old cell borders are colored of black 
						cell_vert.y = (old_cell.row * CELL_SIDE) + grind.y;	
						cell_vert.x = (old_cell.col * CELL_SIDE) + grind.x;
						draw_square(screen,cell_vert,CELL_SIDE,black);
	
						//new cell borders are colored of red 
						cell_vert.y = (mouse_cell.row * CELL_SIDE) + grind.y;
						cell_vert.x = (mouse_cell.col * CELL_SIDE) + grind.x;
						draw_square(screen,cell_vert,CELL_SIDE,red);
	
						//the old indexes are updated 
						old_cell.row = mouse_cell.row;
						old_cell.col = mouse_cell.col;
					}
				}
			}
		}

		//robot have to move
		if(len_path && !paused)
		{
			//get a new checkpoint
			if(need_checkp)
			{
				need_checkp = false;
				dest_point((*(robot_path+ind_path)),&robot_dest);
			}

			//move on!
			if(update_position(&robot_rect,robot_dest))
			{
				//update current robot position
				robot_cell.row = (robot_path+ind_path)->row;
				robot_cell.col = (robot_path+ind_path)->col;

				len_path--;
				ind_path++;	
				
				//another checkpoint
				if(len_path)
					need_checkp = true;
				//arrived to dest!
				else
				{
					ind_path = 0;	
					decolour_path(robot_path,bk_len,screen,black,white);
					free(robot_path);
				}
			}

		}

		//robot blit management
		SDL_BlitSurface(screen, &robot_rect, bg_robot, NULL); 
		SDL_BlitSurface(robot, NULL, screen, &robot_rect);
		
		//the screen is refreshed
		SDL_Flip(screen);
		
		//clear robot trail
		SDL_BlitSurface(bg_robot, NULL, screen, &robot_rect);

		//a minimum delay 
		SDL_Delay(1);
	}

	return 0;
}
