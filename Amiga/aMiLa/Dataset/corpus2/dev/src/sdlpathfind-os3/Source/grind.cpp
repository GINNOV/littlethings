#include "grind.h"

//this function generates a random map with few (<= 10%) not walkable cells
void generate_map(int map[][NUM_COLS])
{
	//init rand seed using current time
	time_t t;
	time(&t);
	srand(t);

	int i,k;

	for(i = 0; i < NUM_ROWS; i++)
	{
		for(k = 0; k< NUM_COLS; k++)
		{
			//walkable	cell
			if((rand() % 100) > 10)
				map[i][k] = 1;
			else
			{
				//first and last row and col are all walkable
				if(k != 0 && i != 0 && k < NUM_COLS-1 && i < NUM_ROWS-1)
					map[i][k] = 0;
				else
					map[i][k] = 1;
			}
		}
	}
}

//this function draw a black/white map on screen
void draw_map(SDL_Surface *surface, SDL_Rect grind, int map[][NUM_COLS])
{
	//counters
	int i, k;

	SDL_Color black = {0x00,0x00,0x00,0};
	SDL_Color white = {0xFF,0xFF,0xFF,0};

	SDL_Rect cell = {grind.x,grind.y,CELL_SIDE,CELL_SIDE};

	for(i = 0; i < NUM_ROWS; i++)
	{
		for(k = 0; k < NUM_COLS; k++)
		{
			if(map[i][k])
				draw_square(surface, &cell , black, white);
			else
				draw_square(surface, &cell , black, black);
			
			//next col
			cell.x += CELL_SIDE;
		}
		
		//next row
		cell.y += CELL_SIDE;
		cell.x = grind.x;
	}
}

//this function llok for the first free cell starting from (0,0)
void get_free_cell(int map[][NUM_COLS], cell_ind * ind)
{
	int i,k;

	for(i = 0; i < NUM_ROWS; i++)
	{
			for(k = 0; k < NUM_COLS; k++)
			{
					if(map[i][k])
					{
						ind->row = i;
						ind->col = k;

						return ;
					}
			}
	}
}

//this function calculates the destination point for a robot that want to 
//move on a cell
void dest_point(cell_ind dest_i, point * dest_p)
{
	dest_p->y = (dest_i.row * CELL_SIDE) + GRIND_Y + ROBOT_DIST/2;
	dest_p->x = (dest_i.col * CELL_SIDE) + GRIND_X + ROBOT_DIST/2;
}

//this functions updates a rectangle moving it toward a destination point
bool update_position(SDL_Rect * pos, point dest)
{
	//orizzontal movement
	if(dest.x > pos->x) 
		pos->x += ROBOT_SPEED;
	else if(dest.x < pos->x) 
		pos->x -= ROBOT_SPEED;

	//vertical movement
	if(dest.y > pos->y) 
		pos->y += ROBOT_SPEED;
	else if(dest.y < pos->y) 
		pos->y -= ROBOT_SPEED;
			
	//check for arrival
	if(dest.x == pos->x && dest.y == pos->y)
		return true;
	else
		return false;
}
