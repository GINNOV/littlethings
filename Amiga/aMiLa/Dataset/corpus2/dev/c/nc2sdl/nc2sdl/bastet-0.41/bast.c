#include <stdlib.h>
#include <stdio.h>
//#include <ncurses.h>
#include <pdcurses/curses.h>
#include <termio.h>
#include <assert.h>
#include <unistd.h>
#include <string.h>

#include "game.h"
#include "bastet.h"
#include "bast.h"

#define WELL_POS(y,x) (*yx2pointer(y,x))
#define WPOS(w,y,x) (*wyx2pointer(w,y,x))

extern const DOT block_data[BLOCK_TYPES][BLOCK_ORIENTS][BLOCK_DOTS];
extern int bl_next;
extern unsigned char *well_data;

extern WINDOW *well_win;
unsigned char *well_tmp=NULL;
int *col_hei;

long *bl_scores;
char debug_buf[100];

void bast_init()
{
	well_tmp=(unsigned char *)malloc(WELL_WIDTH*WELL_HEIGHT); if(well_tmp==NULL) assert(FALSE);
	col_hei= (int *)malloc(WELL_WIDTH*sizeof(int)); if(col_hei==NULL) assert(FALSE); 
	bl_scores=(long *)malloc(BLOCK_TYPES*sizeof(long)); if(bl_scores==NULL) assert(FALSE);
}

void bast_clear()
{
	free(well_tmp);
	free(col_hei);
	free(bl_scores);
}


inline unsigned char *wyx2pointer(char *well, int y, int x)
{
        return well + (y * WELL_WIDTH) + x;
}

long eval_pos(char *well) //the higher, the better your block is
{
	int i,j;
	long pos=0;

	//checks for completed lines
	for(i=0;i<WELL_HEIGHT;i++) {
			for(j=0;j<WELL_WIDTH;j++)
				if(WPOS(well,i,j)==0) break;
			if (j==WELL_WIDTH) { //if line is full
				pos+=5000;
				//remove the "full" line from the well, then goes on calculating this position's score
				memmove(well+WELL_WIDTH,well,WELL_WIDTH*i);
				//DBG:
				/*memcpy(well_data,well,WELL_WIDTH*WELL_HEIGHT);
				update_well(0,WELL_HEIGHT);
				sleep(1000);*/
			}
		}

	//height-based position score

	//calc col_heights
	for(j=0;j<WELL_WIDTH;j++) {
		i=0;
		while(WPOS(well,i,j)==0 && i<WELL_HEIGHT) i++;
		col_hei[j]=WELL_HEIGHT-i;
	}

	//brutally:
	for(j=0;j<WELL_WIDTH;j++) {
		pos-=5*col_hei[j];
	}
	
	return pos;
}

//straight from game.c

int wcheck_block_pos(int y, int x, int type, int orient)
{
        int i;
        DOT dot;
        for (i = 0; i < BLOCK_DOTS; i++) {
                dot = block_data[type][orient][i];
								if ((y + dot.y > WELL_HEIGHT - 1)              ||
										(x + dot.x < 0)                             ||
										(x + dot.x > WELL_WIDTH - 1)               ||
										(WPOS(well_data,y + dot.y, x + dot.x) > 0)) 
									return 0;
        }
        return 1;
}

/* Put the points a block occupies into well */
void wset_block(char *well, int y, int x, int type, int orient)
{
        int i;
        DOT dot;

        for (i = 0; i < BLOCK_DOTS; i++) {
					dot = block_data[type][orient][i];
								WPOS(well, y + dot.y, x + dot.x) = dot.color;
				}

				//DBG:
				//draw_block(well_win,y,x,type,orient,0);
				//usleep(5000);
				//draw_block(well_win,y,x,type,orient,1);
}

#define MIN(a,b) (a<b?a:b)
#define MAX(a,b) (a<b?b:a)

/*
 * chess engines-like heuristics: drops ("straight down") a block in every possible position,
 * evaluates a score for the resulting position (via eval_pos), then chooses the max value for
 * every block
 */

void minimax()
{
	int type,orient,x,y;
	long ev,this_score;
	//for each block...
	for(type=0;type<BLOCK_TYPES;type++)
		 {
			this_score=-32000;
			//for each possible positioning...
			for(orient=0;orient<BLOCK_ORIENTS;orient++)
				for(x=-2;x<WELL_WIDTH+2;x++) {
						//drops the block in a temporary well
						memcpy(well_tmp,well_data, WELL_WIDTH*WELL_HEIGHT);
						y=0;
						if(!wcheck_block_pos(y,x,type,orient)) continue; //block is outside borders
						while(wcheck_block_pos(y+1,x,type,orient)) y++;
						wset_block(well_tmp,y,x,type,orient);
						//evals position's score
						ev=eval_pos(well_tmp);

						this_score=MAX(this_score, ev);
					}
			bl_scores[type]=this_score;
		 }
	//Debug print on top of the screen
	snprintf(debug_buf,100,	"I:%3ld O:%3ld J:%3ld L:%3ld Z:%3ld S:%3ld T:%3ld              ",
           bl_scores[BL_I],bl_scores[BL_O],bl_scores[BL_J],bl_scores[BL_L],
					 bl_scores[BL_Z],bl_scores[BL_S],bl_scores[BL_T]);
	mvaddstr(0,0,debug_buf);
	wrefresh(stdscr);
}

int qsort_compar_func (const void* a, const void *b)
{
	int ia=*(int*)a; //little pointer hack
  int ib=*(int*)b;
  if (bl_scores[ia]==bl_scores[ib]) return 0;
  else if (bl_scores[ia]<bl_scores[ib]) return -1;
  else return 1;
}


int choose_piece()
{
  int bl_sort[BLOCK_TYPES];
  int i,rnd;
  const int bl_percent[BLOCK_TYPES]={75,92,98,100,100,100,100};

  minimax();

	//perturbe score (-2 to +2), to avoid stupid tie handling
	for(i=0;i<BLOCK_TYPES;i++)
		bl_scores[i]+=random() % 5 - 2;

  for(i=0;i<BLOCK_TYPES;i++) bl_sort[i]=i;
  qsort(bl_sort,BLOCK_TYPES,sizeof(int),&qsort_compar_func);

	//"next block" displayer
  bl_next=bl_sort[BLOCK_TYPES-1];
  
  rnd=random()%100; //0..99
  for(i=0;i<BLOCK_TYPES;i++)
    {
      if(rnd<bl_percent[i])
        return bl_sort[i];
    }
  return bl_sort[0]; //should not arrive here
}

