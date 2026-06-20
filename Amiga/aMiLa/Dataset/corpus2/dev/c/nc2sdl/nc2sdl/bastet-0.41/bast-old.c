/* the old version of bast.c
 * rename it to bast.c to play using the 0.37 block chooser engine
 */



#include <stdlib.h>
#include <stdio.h>
#include <ncurses.h>

#include "game.h"
#include "bastet.h"
#include "bast.h"

#define WELL_POS(y,x) (*yx2pointer(y,x))

extern char *well_data;
int *col_hei; //0..W+1, 0 and W+1 are the borders, cols start at 1
int *col_delta; //0..W: col_delta[0] is AFTER column 0
int *col_mult2; //0..W-1
#define col_mult (col_mult2-1)
//^^^small hack so that col_mult go from 1 (first column) to W (last)
//to be coherent with col_hei
int bl_points[BLOCK_TYPES]; //wantedness: higher if you *want* that block!

char debug_buf[100];

void bast_init()
{
  col_hei=(int *)malloc((WELL_WIDTH+2)*sizeof(int));
  col_hei[0]=col_hei[WELL_WIDTH+1]=1000; //"large enough"
  col_delta=(int *)malloc((WELL_WIDTH+1)*sizeof(int));
  col_mult2=(int *)malloc((WELL_WIDTH)*sizeof(int));
}

void calc_ratings()
{
  int i,j,meanhei;

  //fills in col_height \& col_delta
  for(i=0;i<WELL_WIDTH;i++)
    {
      j=0;
      while(WELL_POS(j,i)==0 && j<WELL_HEIGHT) j++;
      col_hei[i+1]=WELL_HEIGHT-j;
    }
  for(i=0;i<WELL_WIDTH+1;i++)
    col_delta[i]=col_hei[i+1]-col_hei[i];

  //evaluates column multipliers based on mean height
  meanhei=0;
  for(i=1;i<=WELL_WIDTH;i++) meanhei+=col_hei[i];
  meanhei/=WELL_WIDTH; //integer division
  for(i=1;i<=WELL_WIDTH;i++)
    {
      int dh=col_hei[i]-meanhei;
      const int mults[]={90,85,80,75,70, 65, 60,50,40,30,20};
      if(dh<-5) //line is LOW
        col_mult[i]=100;
      else if (dh>5) //line is HI
        col_mult[i]=15;
      else col_mult[i]=mults[dh+5];
    }
  //XXX: +/- to mults for holes in columns

  //single-piece job
  for(i=0;i<BLOCK_TYPES;i++) bl_points[i]=0;

  //BL_I is the easiest:
  //BL_I is easy to place everywhere, let's set his score higher
  bl_points[BL_I]+=col_mult[1]+col_mult[WELL_WIDTH];

  for(i=1;i<=WELL_WIDTH;i++)
    if(col_delta[i-1]<=-3 && col_delta[i]>=3) //the typical case
      bl_points[BL_I]+=col_mult[i]*20;
    else if(col_delta[i-1]<=2 && col_delta[i]>=2)
      bl_points[BL_I]+=col_mult[i]*2;

  //horizontally (to complete a row):
  for(i=1;i<=WELL_WIDTH-2;i++)
    if(col_delta[i-1]<0 && col_delta[i]==0 &&
       col_delta[i+1]==0 && col_delta[i+2]==0 && col_delta[i+3]>0)
      bl_points[BL_I]+=col_mult[i]; //XXX:mean?

  //BL_O:
  {
    char found=0;
    for(i=1;i<WELL_WIDTH;i++)
        if(col_delta[i]==0)
          {
            char s=1;
            found=1;
            if(col_delta[i-1]<0) s++; //the square fits well
            if(col_delta[i+1]>0) s++;
            bl_points[BL_O]+=col_mult[i]*s;
          }
    if(found==0)
      bl_points[BL_O]-=1000; //no proper place to put it!
  }

  //BL_J:
  {
    char found=0;
    for(i=0;i<=WELL_WIDTH;i++)
      {
        if(col_delta[i]==2)
          {
            bl_points[BL_J]+=col_mult[i]*2;
            found=1;
          }
        else if (col_delta[i]==0 && col_delta[i+1]>=0)
          {
            bl_points[BL_J]+=col_mult[i];
            found=1;
          }
      }
    if(found==0) bl_points[BL_J]-=100;
  }

    //BL_L:
  {
    char found=0;
    for(i=0;i<=WELL_WIDTH;i++) {
        if(col_delta[i]==-2)
          {
            bl_points[BL_L]+=col_mult[i]*2;
            found=1;
          }
        else if (col_delta[i]==0 && col_delta[i-1]>=0)
          {
            bl_points[BL_L]+=col_mult[i];
            found=1;
          }
      }
    if(found==0) bl_points[BL_L]-=100;
  }

  //BL_Z:
  {
    char found=0;
    bl_points[BL_Z]+=100; //was too frequent
    for(i=1;i<=WELL_WIDTH;i++) {
        if(col_delta[i]==1)
          {
            bl_points[BL_Z]+=col_mult[i]*2;
            found=1;
          }
        else if (col_delta[i-1]==-1 && col_delta[i]==0)
          {
            bl_points[BL_Z]+=col_mult[i];
            found=1;
          }
      }
    if(found==0) bl_points[BL_Z]-=800;
  }

  //BL_S:
  {
    char found=0;
    bl_points[BL_S]+=100; //was too frequent
    for(i=1;i<=WELL_WIDTH;i++) {
        if(col_delta[i]==-1)
          {
            bl_points[BL_S]+=col_mult[i]*2;
            found=1;
          }
        else if (col_delta[i-1]==0 && col_delta[i]==1)
          {
            bl_points[BL_S]+=col_mult[i];
            found=1;
          }
      }
    if(found==0) bl_points[BL_S]-=800;
  }
  //BL_T: most difficult, fits everywhere!
  {
    char found=0;
    //    bl_points[BL_T]+=150; //with this on, BL_T hardly ever appears!
    for(i=1;i<=WELL_WIDTH;i++)
      {
        if(col_delta[i]==1 ||col_delta[i]==-1)
          {
            found=1;
            bl_points[BL_T]+=col_mult[i];
          }
        else if (col_delta[i]==0 && col_delta[i+1]==0)
          {
            found=1;
            bl_points[BL_T]+=col_mult[i];
          }
      }
    if(found==0) bl_points[BL_T]-=200;
  }

  //DEBUG STUFF:
  //    snprintf(debug_buf,100,"%d %d %d %d                  ",
             //col_hei[0],col_hei[1],col_hei[9],col_hei[10]);
             //col_mult[0],col_mult[1],col_mult[10],col_mult[11]);
  //     bl_points[BL_J],bl_points[BL_L],bl_points[BL_Z],meanhei);

  snprintf(debug_buf,100,"I:%d O:%d J:%d L:%d Z:%d S:%d T:%d              ",
           bl_points[BL_I],bl_points[BL_O],bl_points[BL_J],bl_points[BL_L],
           bl_points[BL_Z],bl_points[BL_S],bl_points[BL_T]);

  mvaddstr(0,0,debug_buf);
  wrefresh(stdscr);
}


int qsort_compar_func (const void* a, const void *b)
{
  int ia=*((char*)a);
  int ib=*((char*)b);
  if (bl_points[ia]==bl_points[ib]) return 0;
  else if (bl_points[ia]<bl_points[ib]) return -1;
  else return 1;
}


int choose_piece()
{
  char bl_sort[BLOCK_TYPES];
  int i,rnd;
  const int bl_percent[BLOCK_TYPES]={85,95,98,99,100,100,100}; //*hard*

  calc_ratings();
  //return random() % BLOCK_TYPES;

  for(i=0;i<BLOCK_TYPES;i++) bl_sort[i]=i;
  qsort(bl_sort,BLOCK_TYPES,sizeof(char),&qsort_compar_func);
  rnd=random()%100; //0..99
  for(i=0;i<BLOCK_TYPES;i++)
    {
      if(rnd<bl_percent[i])
        return bl_sort[i];
    }
  return bl_sort[0]; //should not arrive here
}
