/******************************************************************************

Copyright © 1994 Jason Weber
All Rights Reserved

$Id: matrix.c,v 1.2.1.6 1994/12/09 05:29:56 jason Exp $

$Log: matrix.c,v $
 * Revision 1.2.1.6  1994/12/09  05:29:56  jason
 * added copyright
 *
 * Revision 1.2.1.5  1994/11/18  07:49:22  jason
 * added matrix load and get
 *
 * Revision 1.2.1.4  1994/09/13  03:48:33  jason
 * added fixed-point test
 *
 * Revision 1.2.1.3  1994/04/06  02:39:10  jason
 * Separate rotation for X, Y, and Z axes
 *
 * Revision 1.2.1.2  1994/04/02  03:33:11  jason
 * acceleration matrix operations: no more 4D arrays
 * needs cleaning and further optimizations
 *
 * Revision 1.2.1.1  1994/03/29  05:41:32  jason
 * Added RCS Header

******************************************************************************/


#ifndef NOT_EXTERN
#include"agl.h"
#endif

/*
 *  near and far cutting planes are included, but have no effect
 */

#define	MATRIX_DEBUG		FALSE
#define	VERTEX_DEBUG		FALSE

#define	CLEAR_PROJECTION	TRUE
#define	FAST_PUSH			TRUE
#define	FAST_ROT			TRUE
#define SINE_TABLE			TRUE
#define FIXED_POINT			FALSE


/* ProjectionType enumeration */
#define PROJ_ORTHO			0
#define PROJ_PERSPECTIVE	1
#define PROJ_CUSTOM			2


/* MACRO'S */
#define PROJECTION(Y,X)	ProjectionPointer[(Y<<2)+X]
#define TRANSLATION(X)	TranslatePointer[X]
#define ROTATION(Y,X)	RotatePointer[(Y<<2)+X]

#if FIXED_POINT

	#define FIXING_POINT	10000

	#define FIXVALUE(x)		(x*FIXING_POINT)
	#define FIXBACK(x)		(x/(float)FIXING_POINT)
	#define FIXMULT(x,y)	(x*y/FIXING_POINT)
	#define FIXDIVIDE(x,y)	(FIXING_POINT*x/y)

	#define FIXTYPE			long long

#else

	#define FIXVALUE(x)		x
	#define FIXBACK(x)		x
	#define FIXMULT(x,y)	(x*y)
	#define FIXDIVIDE(x,y)	(x/y)

	#define FIXTYPE			float

#endif


/* isolated prototypes */
void rotate_translate_position(FIXTYPE vert[3],FIXTYPE rvert[3]);
void rotate_position(FIXTYPE vert[3],FIXTYPE rvert[3]);
void project_vertex(FIXTYPE in[3],FIXTYPE out[3]);


static Matrix IdentityMatrix=
	{
	1.0, 0.0, 0.0, 0.0,
	0.0, 1.0, 0.0, 0.0,
	0.0, 0.0, 1.0, 0.0,
	0.0, 0.0, 0.0, 1.0,
	};

short MatrixLevel[MAX_WINDOWS];
short ProjectionType[MAX_WINDOWS];
short OrthoAligned[MAX_WINDOWS];
short MatrixMode=MSINGLE;

FIXTYPE Projection[MAX_WINDOWS][4][4];
FIXTYPE Transformation[MAX_WINDOWS][MATRIXSTACKDEPTH][4][4];

FIXTYPE Sine[3600];

FIXTYPE *RotatePointer,*TranslatePointer,*ProjectionPointer;


/******************************************************************************
void	init_matrices(void)

******************************************************************************/
/*PROTOTYPE*/
void init_matrices(void)
	{
	long wid;
	short x,y;

#if MATRIX_DEBUG
	printf("init_matrices()\n");
#endif

	/* create sin table */
	for(x=0;x<3600;x++)
		Sine[x]=FIXVALUE(sin(x/10.0*DEG));

	for(wid=0;wid<MAX_WINDOWS;wid++)
		{
		MatrixLevel[wid]=0;

		for(x=0;x<4;x++)
			for(y=0;y<4;y++)
				if(x==y)
					Transformation[wid][0][y][x]=FIXVALUE(1.0);
				else
					Transformation[wid][0][y][x]=FIXVALUE(0.0);
		}
	}


/******************************************************************************
void	reset_matrix_pointers(void)

	call from winset() to reset pointers to transform structures

******************************************************************************/
/*PROTOTYPE*/
void reset_matrix_pointers(void)
	{
	short m;

	m=MatrixLevel[CurrentWid];

	RotatePointer= &(Transformation[CurrentWid][m][0][0]);
	TranslatePointer= &(Transformation[CurrentWid][m][3][0]);
	ProjectionPointer= &(Projection[CurrentWid][0][0]);
	}


/******************************************************************************
void pushmatrix(void)

******************************************************************************/
/*PROTOTYPE*/
void pushmatrix(void)
	{
/* 	short x,y; */
	short m;

#if MATRIX_DEBUG
	printf("pushmatrix() -> %d\n",MatrixLevel[CurrentWid]+1);
#endif

	if(MatrixLevel[CurrentWid]==MATRIXSTACKDEPTH-1)
		GL_error("Too many matrices pushed");
	else
		{
		m= ++MatrixLevel[CurrentWid];

#if FAST_PUSH

		memcpy(RotatePointer+16,RotatePointer,16*sizeof(FIXTYPE));

#else
		for(y=0;y<3;y++)
			{
			Translation[CurrentWid][m][y]=Translation[CurrentWid][m-1][y];
			for(x=0;x<3;x++)
				Rotate[CurrentWid][m][y][x]=Rotate[CurrentWid][m-1][y][x];
			}
#endif

		/* move up pointers */
		RotatePointer+=16;
		TranslatePointer+=16;
		}
	}


/******************************************************************************
void	popmatrix(void)

******************************************************************************/
/*PROTOTYPE*/
void popmatrix(void)
	{
#if MATRIX_DEBUG
	printf("popmatrix() -> %d\n",MatrixLevel[CurrentWid]-1);
#endif

	if(MatrixLevel[CurrentWid]==0)
		GL_error("Too many matrices popped");
	else
		{
		MatrixLevel[CurrentWid]--;

		/* move up pointers */
		RotatePointer-=16;
		TranslatePointer-=16;
		}

	if(MatrixLevel[CurrentWid]==0)	/* gotta have some way to go back */
		Dimensions[CurrentWid]=2;
	}


/******************************************************************************
void	mmode(short mode)

	set matrix mode:
		MSINGLE
		MVIEWING
		MPROJECTION
		MTEXTURE

******************************************************************************/
/*PROTOTYPE*/
void mmode(short mode)
	{
	if(mode!=MSINGLE && mode!=MVIEWING && mode!=MPROJECTION && mode!=MTEXTURE )
		{
		GL_error("(INTERNAL) getmatrix: illegal MatrixMode");
		}
	else
		{
		MatrixMode=mode;

		if(mode==MSINGLE)
			GL_error("MSINGLE obsolete: using MVIEWING");
		
		if(mode==MTEXTURE)
			GL_error("MTEXTURE not supported");
		}
	}


/******************************************************************************
long	getmmode(void)

******************************************************************************/
/*PROTOTYPE*/
long getmmode(void)
	{
	return MatrixMode;
	}


/******************************************************************************
void	getmatrix(Matrix  m)

	give user the current transform

******************************************************************************/
/*PROTOTYPE*/
void getmatrix(Matrix  m)
	{
	switch(MatrixMode)
		{
		case MSINGLE:
		case MVIEWING:
			memcpy(m,RotatePointer,sizeof(Matrix));
			break;

		case MPROJECTION:
			memcpy(m,ProjectionPointer,sizeof(Matrix));
			break;

		case MTEXTURE:
			memset(m,0,sizeof(Matrix));
			break;

		default:
			GL_error("(INTERNAL) getmatrix: illegal MatrixMode");
			break;
		}
	}


/******************************************************************************
void	loadmatrix(Matrix  m)

	use the users custom matrix

******************************************************************************/
/*PROTOTYPE*/
void loadmatrix(Matrix  m)
	{
	switch(MatrixMode)
		{
		case MSINGLE:
		case MVIEWING:
			memcpy(RotatePointer,m,sizeof(Matrix));
			break;

		case MPROJECTION:
			memcpy(ProjectionPointer,m,sizeof(Matrix));
			ProjectionType[CurrentWid]=PROJ_CUSTOM;
			break;

		case MTEXTURE:
			GL_error("loadmatrix: MTEXTURE matrix mode not supported -> can't load matrix");
			break;

		default:
			GL_error("(INTERNAL) loadmatrix: illegal MatrixMode");
			break;
		}

	OneToOne[CurrentWid]=is_one_to_one(RotatePointer);
	}


/******************************************************************************
void	multmatrix(Matrix  m)

	pre-multiply current matrix by user's custom transform

******************************************************************************/
/*PROTOTYPE*/
void multmatrix(Matrix  m)
	{
	Matrix temp;

	short x,y;
	short n;

	memcpy(temp,RotatePointer,sizeof(Matrix));

	for(y=0;y<4;y++)
		for(x=0;x<4;x++)
			{
			ROTATION(y,x)=0;

			for(n=0;n<4;n++)
				ROTATION(y,x)+=m[y][n]*temp[n][x];
			}

	OneToOne[CurrentWid]=is_one_to_one(RotatePointer);
	}


/******************************************************************************
long	is_one_to_one(Matrix m)

	returns TRUE if given 4x4 matrix is an identity

******************************************************************************/
/*PROTOTYPE*/
long is_one_to_one(Matrix m)
	{
	return OrthoAligned[CurrentWid] && viewport_aligned() &&
												memcmp(RotatePointer,IdentityMatrix,sizeof(Matrix))==0;
	}


/******************************************************************************
void	project_vertex(FIXTYPE in[3],FIXTYPE out[3])

	applies perspective on transformed vertex
******************************************************************************/
/*NO PROTOTYPE*/
void project_vertex(FIXTYPE in[3],FIXTYPE out[3])
	{
#if !FAST_PROJECTION

	short x,m;
	float sum,before[4],mid[4];

	switch(ProjectionType[CurrentWid])
		{
		case PROJ_ORTHO:
			/* fast: compute only x and y for ortho projection */

			out[0]=FIXMULT(PROJECTION(0,0),in[0])+PROJECTION(3,0);
			out[1]=FIXMULT(PROJECTION(1,1),in[1])+PROJECTION(3,1);
			break;

		case PROJ_PERSPECTIVE:
			/* fast: compute only x and y for perspective projection */

			/* mult and divide cancel fixed point effect */

			out[0]= -PROJECTION(0,0)*in[0]/in[2];
			out[1]= -PROJECTION(1,1)*in[1]/in[2];
			break;

		case PROJ_CUSTOM:
			/* complete: general purpose, any transform matrix */

			for(x=0;x<3;x++)
				before[x]=in[x];
			before[3]=1.0;

			for(x=0;x<4;x++)
				{
				sum=0.0;
				for(m=0;m<4;m++)
					sum+=PROJECTION(m,x)*before[m];

				mid[x]=sum;
				}

			/* divide out range factor */
			for(x=0;x<3;x++)
				out[x]= -mid[x]/mid[3];

/* 				out[y]=PROJECTION(3,2)*mid[y]/mid[3]; */

/*
			for(m=0;m<4;m++)
				{
				for(x=0;x<4;x++)
					printf("%8.2f ",PROJECTION(m,x));

				printf("\n");
				}

			printf("\nbefore\n");
			for(x=0;x<4;x++)
				printf("%8.2f ",before[x]);

			printf("\nmid\n");
			for(x=0;x<4;x++)
				printf("%8.2f ",mid[x]);

			printf("\nout\n");
			for(x=0;x<4;x++)
				printf("%8.2f ",out[x]);
*/
			break;
		}
	}


/******************************************************************************
void	perspective(long angle,float aspect,float near,float far)

	angle in integer number of tenths of degrees

	sets Projection[][]
******************************************************************************/
/*PROTOTYPE*/
void perspective(long angle,float aspect,float near,float far)
	{
	float fovy,cot;

#if MATRIX_DEBUG
	printf("perspective()\n");
#endif

	OneToOne[CurrentWid]=FALSE;
	OrthoAligned[CurrentWid]=FALSE;
	Dimensions[CurrentWid]=3;
	ProjectionType[CurrentWid]=PROJ_PERSPECTIVE;

	fovy=angle*DEG/10.0;
	cot=1.0/tan(fovy/2.0);

#if CLEAR_PROJECTION
	memset(&Projection[CurrentWid][0][0],0,sizeof(Matrix));
#endif

	Projection[CurrentWid][0][0]=FIXVALUE(cot/aspect);
	Projection[CurrentWid][1][1]=FIXVALUE(cot);
	Projection[CurrentWid][2][2]=FIXVALUE(     -(far+near)/(far-near));
	Projection[CurrentWid][2][3]=FIXVALUE( -1.0);
	Projection[CurrentWid][3][2]=FIXVALUE( -(2.0*far*near)/(far-near));

/*
	printf("angle=%d fovy=%.2f cot=%.2f Proj=%.2f %.2f\n",angle,fovy,cot,
											Projection[CurrentWid][0][0],Projection[CurrentWid][1][1]);
*/
	}


/******************************************************************************
void	ortho(float left,float right,float bottom,float top,
														float near,float far)

******************************************************************************/
/*PROTOTYPE*/
void ortho(float left,float right,float bottom,float top,float near,float far)
	{
	ortho2(left,right,bottom,top);

	Projection[CurrentWid][2][2]=FIXVALUE( -2.0/(far-near));
	Projection[CurrentWid][3][2]=FIXVALUE( -(far+near)/(far-near));
	}


/******************************************************************************
void	ortho2(float left,float right,float bottom,float top)

******************************************************************************/
/*PROTOTYPE*/
void ortho2(float left,float right,float bottom,float top)
	{
#if MATRIX_DEBUG
	printf("ortho2()\n");
#endif

#if CLEAR_PROJECTION
	memset(&Projection[CurrentWid][0][0],0,16*4);
#endif

	Projection[CurrentWid][0][0]=FIXVALUE(2.0/(right-left));
	Projection[CurrentWid][1][1]=FIXVALUE(2.0/(top-bottom));
	Projection[CurrentWid][2][2]=FIXVALUE( -1.0);
	Projection[CurrentWid][3][0]=FIXVALUE( -(right+left)/(right-left));
	Projection[CurrentWid][3][1]=FIXVALUE( -(top+bottom)/(top-bottom));
	Projection[CurrentWid][3][3]=FIXVALUE(1.0);

	ProjectionType[CurrentWid]=PROJ_ORTHO;

	OrthoAligned[CurrentWid]= ( left==(-0.5) && right==(CurrentWidth-0.5) &&
														 bottom==(-0.5) && top==(CurrentHeight-0.5) );

	OneToOne[CurrentWid]=is_one_to_one(RotatePointer);
	}


/******************************************************************************
void	viewport(Screencoord left,Screencoord right,
										Screencoord bottom,Screencoord top)
******************************************************************************/
/*PROTOTYPE*/
void viewport(Screencoord left,Screencoord right,Screencoord bottom,Screencoord top)
	{
	ViewPort[CurrentWid][0]=left;
	ViewPort[CurrentWid][1]=right-left+1;
	ViewPort[CurrentWid][2]=bottom;
	ViewPort[CurrentWid][3]=top-bottom+1;

	scrmask(left,right,bottom,top);

	OneToOne[CurrentWid]=is_one_to_one(RotatePointer);
	}


/******************************************************************************
long	viewport_aligned(void)

******************************************************************************/
/*PROTOTYPE*/
long viewport_aligned(void)
	{
	return (ViewPort[CurrentWid][0]==0 && ViewPort[CurrentWid][1]==CurrentWidth &&
									ViewPort[CurrentWid][2]==0 && ViewPort[CurrentWid][3]==CurrentHeight );
	}


/******************************************************************************
void	v2i(long lvert[2])

******************************************************************************/
/*PROTOTYPE*/
void v2i(long lvert[2])
	{
	short svert[2];
	float fvert[3];

	if(OneToOne[CurrentWid])	/* bypass transforms if no effect */
		{
		svert[0]=lvert[0];
		svert[1]=lvert[1];
		render_vertex(svert);
		}
	else
		{
		fvert[0]=lvert[0];
		fvert[1]=lvert[1];
		fvert[2]=0.0;

		v3f(fvert);
		}
	}


/******************************************************************************
void	v3i(long lvert[3])

******************************************************************************/
/*PROTOTYPE*/
void v3i(long lvert[3])
	{
	float fvert[3];

	fvert[0]=lvert[0];
	fvert[1]=lvert[1];
	fvert[2]=lvert[2];

	v3f(fvert);
	}


/******************************************************************************
void	v2s(short svert[2])

******************************************************************************/
/*PROTOTYPE*/
void v2s(short svert[2])
	{
	float fvert[3];

	if(OneToOne[CurrentWid])	/* bypass transforms if no effect */
		render_vertex(svert);
	else
		{
		fvert[0]=svert[0];
		fvert[1]=svert[1];
		fvert[2]=0.0;

		v3f(fvert);
		}
	}


/******************************************************************************
void	v3s(short svert[3])

******************************************************************************/
/*PROTOTYPE*/
void v3s(short svert[3])
	{
	float fvert[3];

	fvert[0]=svert[0];
	fvert[1]=svert[1];
	fvert[2]=svert[2];

	v3f(fvert);
	}


/******************************************************************************
void	v2f(float fvert2[2])

******************************************************************************/
/*PROTOTYPE*/
void v2f(float fvert2[2])
	{
	short svert[2];
	float fvert[3];

	if(OneToOne[CurrentWid])	/* bypass transforms if no effect */
		{
		svert[0]=fvert2[0];
		svert[1]=fvert2[1];
		render_vertex(svert);
		}
	else
		{
		fvert[0]=fvert2[0];
		fvert[1]=fvert2[1];
		fvert[2]=0.0;

		v3f(fvert);
		}
	}


/******************************************************************************
void	v3f(float vert[3])

******************************************************************************/
/*PROTOTYPE*/
void v3f(float vert[3])
	{
	short svert[2];
	FIXTYPE fvert[3],rvert[3],pvert[3];

#if FIXED_POINT

	fvert[0]=FIXVALUE(vert[0]);
	fvert[1]=FIXVALUE(vert[1]);
	fvert[2]=FIXVALUE(vert[2]);
	rotate_translate_position(fvert,rvert);

#else

	rotate_translate_position(vert,rvert);

#endif

	project_vertex(rvert,pvert);

/*
	svert[0]=CurrentWidth  * FIXBACK(FIXDIVIDE((pvert[0]+1.0),2.0)) + 0.5;
	svert[1]=CurrentHeight * FIXBACK(FIXDIVIDE((pvert[1]+1.0),2.0)) + 0.5;
*/

	svert[0]=ViewPort[CurrentWid][0]+ ViewPort[CurrentWid][1] * FIXBACK(FIXDIVIDE((pvert[0]+1.0),2.0));
	svert[1]=ViewPort[CurrentWid][2]+ ViewPort[CurrentWid][3] * FIXBACK(FIXDIVIDE((pvert[1]+1.0),2.0));

	render_vertex(svert);

#if VERTEX_DEBUG
	if(CurrentWid==1)
		{
		for(y=0;y<4;y++)
			{
			for(x=0;x<4;x++)
				printf("%5.2f ",Projection[CurrentWid][y][x]);

			printf(" ");

			for(x=0;x<4;x++)
				printf("%5.2f ",PROJECTION(y,x));

			printf(" ");

			for(x=0;x<4;x++)
				printf("%4.1f ",Transformation[CurrentWid][MatrixLevel[CurrentWid]][y][x]);

			printf(" ");

			if(y<3)
				{
				for(x=0;x<3;x++)
					printf("%4.1f ",ROTATION(y,x));

				printf("%4.1f\n",TRANSLATION(y));
				}

			printf("\n");
			}

		printf("%d %d  %d %d  %d\n",	&Projection[CurrentWid][0][0],
									ProjectionPointer,
									&Transformation[CurrentWid][MatrixLevel[CurrentWid]][0][0],
									RotatePointer,
									TranslatePointer);
		printf("W%d M%d ",CurrentWid,MatrixLevel[CurrentWid]);
		printf("%5.3f %5.3f %5.3f -> ",vert[0],vert[1],vert[2]);
		printf("%5.3f %5.3f %5.3f -> ",rvert[0],rvert[1],rvert[2]);
		printf("%5.3f %5.3f -> ",pvert[0],pvert[1]);
		printf("%4d %4d\n",svert[0],svert[1]);
		}
#endif
	}


/******************************************************************************
void	rotate_translate_position(FIXTYPE vert[3],FIXTYPE rvert[3])

	calls rotate_position()
	adds Translation[]
******************************************************************************/
/*NO PROTOTYPE*/
void rotate_translate_position(FIXTYPE vert[3],FIXTYPE rvert[3])
	{
/* 	short y,m; */

	rotate_position(vert,rvert);

#if FALSE
	m=MatrixLevel[CurrentWid];

	/* the original (keep for reference) */
	for(y=0;y<3;y++)
		rvert[y]+=Translation[CurrentWid][m][y];
#endif

	rvert[0]+=TRANSLATION(0);
	rvert[1]+=TRANSLATION(1);
	rvert[2]+=TRANSLATION(2);
	}


/******************************************************************************
void	rotate_position(FIXTYPE vert[3],FIXTYPE rvert[3])

	premultiplies vector to rotational matrix transform
******************************************************************************/
/*NO PROTOTYPE*/
void rotate_position(FIXTYPE vert[3],FIXTYPE rvert[3])
	{
	short d;
/* 	short x,y,m; */

	d=Dimensions[CurrentWid];

#if FALSE
	m=MatrixLevel[CurrentWid];

	/* the original (keep for reference) */
	for(x=0;x<d;x++)
		{
		rvert[x]=0.0;
		for(y=0;y<d;y++)
			rvert[x]+=vert[y]*Rotate[CurrentWid][m][y][x];
		}
#endif

	/* unrolled and optimised */
	if(d==3)
		{
		rvert[0]=	FIXMULT(vert[0],ROTATION(0,0))
				+	FIXMULT(vert[1],ROTATION(1,0))
				+	FIXMULT(vert[2],ROTATION(2,0));

		rvert[1]=	FIXMULT(vert[0],ROTATION(0,1))
				+	FIXMULT(vert[1],ROTATION(1,1))
				+	FIXMULT(vert[2],ROTATION(2,1));

		rvert[2]=	FIXMULT(vert[0],ROTATION(0,2))
				+	FIXMULT(vert[1],ROTATION(1,2))
				+	FIXMULT(vert[2],ROTATION(2,2));
		}
	else
		{
		rvert[0]=	FIXMULT(vert[0],ROTATION(0,0))
				+	FIXMULT(vert[1],ROTATION(1,0));

		rvert[1]=	FIXMULT(vert[0],ROTATION(0,1))
				+	FIXMULT(vert[1],ROTATION(1,1));

		rvert[2]=	vert[2];
		}
	}


/******************************************************************************
void	translate(float fx,float fy,float fz)

******************************************************************************/
/*PROTOTYPE*/
void translate(float fx,float fy,float fz)
	{
	FIXTYPE vert[3],rvert[3];
/* 	short y,m; */

	OneToOne[CurrentWid]=FALSE;

#if MATRIX_DEBUG
	printf("translate(%.2f %.2f %.2f)\n",fx,fy,fz);
#endif

	vert[0]=FIXVALUE(fx);
	vert[1]=FIXVALUE(fy);
	vert[2]=FIXVALUE(fz);

	rotate_position(vert,rvert);

#if FALSE
	m=MatrixLevel[CurrentWid];

	/* the original (keep for reference) */
	for(y=0;y<3;y++)
		Translation[CurrentWid][m][y]+=rvert[y];
#endif

	/* unrolled and optimised */
	TRANSLATION(0)+=rvert[0];
	TRANSLATION(1)+=rvert[1];
	TRANSLATION(2)+=rvert[2];
	}


/******************************************************************************
void	rot(float angle,long axis)

	angle in degrees

	rotates current matrix transform about an axis
******************************************************************************/
/*PROTOTYPE*/
void rot(float angle,long axis)
	{
	short i,j;
	short angle1,angle2;

	FIXTYPE b,c;
	FIXTYPE sina,cosa;

	OneToOne[CurrentWid]=FALSE;

#if MATRIX_DEBUG
	printf("rot(%.2f,%c)\n",angle,axis);
#endif

#if SINE_TABLE

	if(angle<0.0)
		{
		angle1=(long)(-angle*10.0)%3600;
		sina= -Sine[angle1];
		}
	else
		{
		angle1=(long)(angle*10.0)%3600;
		sina=Sine[angle1];
		}

	angle2=(abs((long)(angle*10.0))+900)%3600;
	cosa=Sine[angle2];

#else

	angle*=DEG;

	sina=sin(angle);
	cosa=cos(angle);

#endif

	switch(axis)
		{
		case 'x':
			Dimensions[CurrentWid]=3;
#if FAST_ROT
			b=ROTATION(1,0);
			c=ROTATION(2,0);
			ROTATION(1,0)= FIXMULT( b,cosa) + FIXMULT(c,sina);
			ROTATION(2,0)= FIXMULT(-b,sina) + FIXMULT(c,cosa);

			b=ROTATION(1,1);
			c=ROTATION(2,1);
			ROTATION(1,1)= FIXMULT( b,cosa) + FIXMULT(c,sina);
			ROTATION(2,1)= FIXMULT(-b,sina) + FIXMULT(c,cosa);

			b=ROTATION(1,2);
			c=ROTATION(2,2);
			ROTATION(1,2)= FIXMULT( b,cosa) + FIXMULT(c,sina);
			ROTATION(2,2)= FIXMULT(-b,sina) + FIXMULT(c,cosa);
#else
			i=1;
			j=2;
#endif
			break;

		case 'y':
			Dimensions[CurrentWid]=3;
#if FAST_ROT
			b=ROTATION(2,0);
			c=ROTATION(0,0);
			ROTATION(2,0)= FIXMULT( b,cosa) + FIXMULT(c,sina);
			ROTATION(0,0)= FIXMULT(-b,sina) + FIXMULT(c,cosa);

			b=ROTATION(2,1);
			c=ROTATION(0,1);
			ROTATION(2,1)= FIXMULT( b,cosa) + FIXMULT(c,sina);
			ROTATION(0,1)= FIXMULT(-b,sina) + FIXMULT(c,cosa);

			b=ROTATION(2,2);
			c=ROTATION(0,2);
			ROTATION(2,2)= FIXMULT( b,cosa) + FIXMULT(c,sina);
			ROTATION(0,2)= FIXMULT(-b,sina) + FIXMULT(c,cosa);
#else
			i=2;
			j=0;
#endif
			break;

		case 'z':
#if FAST_ROT
			b=ROTATION(0,0);
			c=ROTATION(1,0);
			ROTATION(0,0)= FIXMULT( b,cosa) + FIXMULT(c,sina);
			ROTATION(1,0)= FIXMULT(-b,sina) + FIXMULT(c,cosa);

			b=ROTATION(0,1);
			c=ROTATION(1,1);
			ROTATION(0,1)= FIXMULT( b,cosa) + FIXMULT(c,sina);
			ROTATION(1,1)= FIXMULT(-b,sina) + FIXMULT(c,cosa);

			b=ROTATION(0,2);
			c=ROTATION(1,2);
			ROTATION(0,2)= FIXMULT( b,cosa) + FIXMULT(c,sina);
			ROTATION(1,2)= FIXMULT(-b,sina) + FIXMULT(c,cosa);
#else
			i=0;
			j=1;
#endif
			break;

		default:
			return;
		}

#if FALSE
	m=MatrixLevel[CurrentWid];

	/* the original (keep for reference) */
	for(x=0;x<3;x++)
		{
		b=Rotate[CurrentWid][m][i][x];
		c=Rotate[CurrentWid][m][j][x];
		Rotate[CurrentWid][m][i][x]=  b*cosa+c*sina;
		Rotate[CurrentWid][m][j][x]= -b*sina+c*cosa;
		}
#endif

#if !FAST_ROT

	/* unrolled and optimised (general case) */
	b=ROTATION(i,0);
	c=ROTATION(j,0);
	ROTATION(i,0)= FIXMULT( b,cosa) + FIXMULT(c,sina);
	ROTATION(j,0)= FIXMULT(-b,sina) + FIXMULT(c,cosa);

	b=ROTATION(i,1);
	c=ROTATION(j,1);
	ROTATION(i,1)= FIXMULT( b,cosa) + FIXMULT(c,sina);
	ROTATION(j,1)= FIXMULT(-b,sina) + FIXMULT(c,cosa);

	b=ROTATION(i,2);
	c=ROTATION(j,2);
	ROTATION(i,2)= FIXMULT( b,cosa) + FIXMULT(c,sina);
	ROTATION(j,2)= FIXMULT(-b,sina) + FIXMULT(c,cosa);

#endif
	}


/******************************************************************************
void	scale(float sx,float sy,float sz)

******************************************************************************/
/*PROTOTYPE*/
void scale(float sx,float sy,float sz)
	{
/* 	short x,m; */

#if FIXED_POINT
	FIXTYPE sx2,sy2,sz2;

	sx2=FIXVALUE(sx);
	sy2=FIXVALUE(sy);
	sz2=FIXVALUE(sz);

	/* unrolled and optimised */
	ROTATION(0,0)*=sx2/FIXING_POINT;
	ROTATION(1,0)*=sy2/FIXING_POINT;
	ROTATION(2,0)*=sz2/FIXING_POINT;

	ROTATION(0,1)*=sx2/FIXING_POINT;
	ROTATION(1,1)*=sy2/FIXING_POINT;
	ROTATION(2,1)*=sz2/FIXING_POINT;

	ROTATION(0,2)*=sx2/FIXING_POINT;
	ROTATION(1,2)*=sy2/FIXING_POINT;
	ROTATION(2,2)*=sz2/FIXING_POINT;
#else
	/* unrolled and optimised */
	ROTATION(0,0)*=sx;
	ROTATION(1,0)*=sy;
	ROTATION(2,0)*=sz;

	ROTATION(0,1)*=sx;
	ROTATION(1,1)*=sy;
	ROTATION(2,1)*=sz;

	ROTATION(0,2)*=sx;
	ROTATION(1,2)*=sy;
	ROTATION(2,2)*=sz;
#endif

	OneToOne[CurrentWid]=FALSE;

#if MATRIX_DEBUG
	printf("scale(%.2f %.2f %.2f )\n",sx,sy,sz);
#endif

#if FALSE
	m=MatrixLevel[CurrentWid];

	/* the original (keep for reference) */
	for(x=0;x<3;x++)
		{
		Rotate[CurrentWid][m][0][x]*=sx;
		Rotate[CurrentWid][m][1][x]*=sy;
		Rotate[CurrentWid][m][2][x]*=sz;
		}
#endif

	}
