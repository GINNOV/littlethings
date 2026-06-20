/******************************************************************************

Copyright © 1994 Jason Weber
All Rights Reserved

$Id: rgb.c,v 1.2.1.2 1994/12/09 05:29:56 jason Exp $

$Log: rgb.c,v $
 * Revision 1.2.1.2  1994/12/09  05:29:56  jason
 * added copyright
 *
 * Revision 1.2.1.1  1994/11/16  06:57:48  jason
 * added space diffusion
 *
 * Revision 1.2  1994/09/17  05:54:04  jason
 * initial revision
 *

******************************************************************************/


#ifndef NOT_EXTERN
#include"agl.h"
#endif

#define SPACE_DEBUG		FALSE


#define DISPERSION		0
#define SPACE_DIFFUSION	1

#define HALFTONE	SPACE_DIFFUSION


/* 5 planes, 16 lines */
#define PATTERNSIZE (5*16)


short Dispersion[4][4]=
	{
	 0, 12,  3, 15,
	 8,  4, 11,  7,
	 2, 14,  1, 13,
	10,  6,  9,  5,
	};


long SpaceDiffusion[8][8]=
	{
	21, 22, 25, 26, 37, 38, 41, 42,
	20, 23, 24, 27, 36, 39, 40, 43,
	19, 18, 29, 28, 35, 34, 45, 44,
	16, 17, 30, 31, 32, 33, 46, 47,
	15, 12, 11, 10, 53, 52, 51, 48,
	14, 13,  8,  9, 54, 55, 50, 49,
	 1,  2,  7,  6, 57, 56, 61, 62,
	 0,  3,  4,  5, 58, 59, 60, 63,
	};

short DitherMatrix[16][16];

float Index_Colors[16][3]=
	{
	 0/15.0,  0/15.0,  0/15.0,
	15/15.0,  0/15.0,  0/15.0,
	 0/15.0, 15/15.0,  0/15.0,
	15/15.0, 15/15.0,  0/15.0,
	 0/15.0,  0/15.0, 15/15.0,
	15/15.0,  0/15.0, 15/15.0,
	 0/15.0, 15/15.0, 15/15.0,
	15/15.0, 15/15.0, 15/15.0,

	 5/15.0,  5/15.0,  5/15.0,
	12/15.0,  7/15.0,  7/15.0,
	 7/15.0, 12/15.0,  7/15.0,
	 8/15.0,  8/15.0,  3/15.0,
	 7/15.0,  7/15.0, 12/15.0,
	 8/15.0,  3/15.0,  8/15.0,
	 3/15.0,  8/15.0,  8/15.0,
	10/15.0, 10/15.0, 10/15.0,
	};


UWORD RGBPattern[PATTERNSIZE];

long Expo[16];
long DotClass[64][2];


/******************************************************************************
void	initialize_RGB(void)

******************************************************************************/
/*PROTOTYPE*/
void initialize_RGB(void)
	{
	short x,y;

	for(y=0;y<8;y++)
		for(x=0;x<8;x++)
			{
			DotClass[SpaceDiffusion[y][x]][0]=x;
			DotClass[SpaceDiffusion[y][x]][1]=y;
			}

	for(y=0;y<16;y++)
		{
		for(x=0;x<16;x++)
			DitherMatrix[y][x]=Dispersion[y/4][x/4]+Dispersion[y&3][x&3]*16;

		Expo[y]=1<<y;
		}

	memset(RGBPattern,0,PATTERNSIZE*sizeof(UWORD));
	}


/******************************************************************************
void	c3f(float rgb[3])

******************************************************************************/
/*PROTOTYPE*/
void c3f(float rgb[3])
	{
	create_pattern(RGBPattern,rgb);
	activate_pattern(RGBPattern);
	}


/******************************************************************************
float	index_dist(short index,float rgb[3])

	return square of distance to index in color space

	Note: sqrt() unneccasary since just finding minimum
******************************************************************************/
/*PROTOTYPE*/
float index_dist(short index,float rgb[3])
	{
	float dx,dy,dz;

	dx=rgb[0]-Index_Colors[index][0];
	dy=rgb[1]-Index_Colors[index][1];
	dz=rgb[2]-Index_Colors[index][2];

	return	dx*dx+dy*dy+dz*dz;
	}


/******************************************************************************
void	create_pattern(UWORD *pattern,float rgb[3])

******************************************************************************/
/*PROTOTYPE*/
void create_pattern(UWORD *pattern,float rgb[3])
	{
	float mod[8][8][3],error[3];
	float add,total;
	float red,green,blue;
	float best_dist,new_dist;

	short class;
	short contribution;
	short best_index,new_index;
	short plane,x,y,i,j,m,pass;
	short component;
	
	if(HALFTONE==SPACE_DIFFUSION)
		{
		/* initialize */
		for(y=0;y<8;y++)
			for(x=0;x<8;x++)
				{
				mod[y][x][0]=rgb[0];
				mod[y][x][1]=rgb[1];
				mod[y][x][2]=rgb[2];
				}

		for(plane=0;plane<5;plane++)
			for(y=0;y<16;y++)
				pattern[plane*16+y]=0;

		for(class=0;class<64;class++)
			{
			x=DotClass[class][0];
			y=DotClass[class][1];

			if(SpaceDiffusion[y][x]!=class)
				GL_error("Class mismatch in create_pattern()");

			red=mod[y][x][0];
			green=mod[y][x][1];
			blue=mod[y][x][2];

			/* find nearest match */
			best_index= ((((blue>0.5)<<1)+(green>0.5))<<1) + (red>0.5);
			best_dist=index_dist(best_index,mod[y][x]);

#if SPACE_DEBUG
			printf("%d: %4.2f,%4.2f,%4.2f %d(%.6G) ",class,red,green,blue,best_index,best_dist);
#endif

			/* compare with middle colors */
			j=0;
			for(m=0;m<4;m++)
				{
				switch(m)
					{
					case 0:
						if(red>0.5)
							{
							new_index=PINK;
							j++;
							}
						else
							new_index=BLUEGREEN;
						break;
					case 1:
						if(green>0.5)
							{
							new_index=LIGHTGREEN;
							j++;
							}
						else
							new_index=PURPLE;
						break;
					case 2:
						if(blue>0.5)
							{
							new_index=LAVENDER;
							j++;
							}
						else
							new_index=OLIVE;
						break;
					case 3:
						if(j>1)
							new_index=LIGHTGREY;
						else
							new_index=DARKGREY;
						break;
					}

#if SPACE_DEBUG
				printf("%d.",new_index);
#endif

				new_dist=index_dist(new_index,mod[y][x]);
				if(best_dist>new_dist)
					{
					best_dist=new_dist;
					best_index=new_index;

#if SPACE_DEBUG
					printf("-> %d(%.6G) ",best_index,best_dist);
#endif
					}
				}

			/* set index */
			for(plane=0;plane<5;plane++)
				if(best_index&Expo[plane])
					{
					pattern[plane*16+y  ]+=Expo[x];
					pattern[plane*16+y+8]+=Expo[x];

					pattern[plane*16+y  ]+=Expo[x+8];
					pattern[plane*16+y+8]+=Expo[x+8];
					}

			error[0]= mod[y][x][0]-Index_Colors[best_index][0];
			error[1]= mod[y][x][1]-Index_Colors[best_index][1];
			error[2]= mod[y][x][2]-Index_Colors[best_index][2];

#if SPACE_DEBUG
			printf("e %4.2f,%4.2f,%4.2f\n",error[0],error[1],error[2]);
#endif
			
			total=0;
			for(pass=0;pass<2;pass++)
				for(j= -1;j<2;j++)
					for(i= -1;i<2;i++)
						if( !( (i==0 && j==0) ||	(i<0 && x==0) || (i>0 && x==7) ||
													(j<0 && y==0) || (j>0 && y==7) ||
													SpaceDiffusion[y+j][x+i]<class ) )
							{
							contribution= 1 + (i==0 || j==0);

							if(pass==0)
								total+=contribution;
							else
								for(m=0;m<3;m++)
									{
									add= error[m] * contribution/total;
									mod[y+j][x+i][m]+=add;
									}
							}
			}

#if SPACE_DEBUG
		exit(1);
#endif
		}
	else
		for(plane=0;plane<3;plane++)
			{
			component=255*rgb[plane];

			for(y=0;y<16;y++)
				{
				pattern[plane*16+y]=0;

				for(x=0;x<16;x++)
					if(DitherMatrix[y][x]<component)
						pattern[plane*16+y]+=Expo[x];
				}
			}
	}


/******************************************************************************
void	activate_pattern(UWORD *pattern)

	NULL pattern should deactivate current pattern
******************************************************************************/
/*PROTOTYPE*/
void activate_pattern(UWORD *pattern)
	{
	SetAfPt(DrawRPort,pattern,-4);
	SetAPen(DrawRPort,255);
	SetBPen(DrawRPort,0);
	SetDrMd(DrawRPort,JAM2);
	}
