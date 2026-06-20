/* This code was created by Jeff Molofee '99 (ported to Linux/GLUT by Kah-Wah Tang 2002 */
/* with help from the lesson 1 basecode for Linux by Richard Campbell)*/
/* If you've found this code useful, please let me know.*/
/* Visit me at www.xs4all.nl/~chtang */
/*(email Kah-Wah Tang at tombraider28@hotmail.com)*/

/* modifications from Alain Thellier - 2010 :		*/
/* now draw the black outlining as bigger triangles	*/
/* now draw with a TEXTURE2D					*/
/* now object's color is builtin in texture		*/
/* colors changed (background,model,shades)		*/
/* code clean-up & ported to Amiga OS3/StormMesa	*/

#include <GL/glut.h>	/* Header File For The GLUT Library */
#include <GL/gl.h>	/* Header File For The OpenGL32 Library*/
#include <GL/glu.h>	/* Header File For The GLu32 Library*/
#include <unistd.h>	 /* Header file for sleeping.*/
#include <stdio.h>
#include <stdlib.h>
#include <math.h>
/* ascii code for the escape key */
#define ESCAPE 27
#define REM(message) printf(#message"\n");

#define FALSE 0
#define TRUE	1

int WindowWidth=640;
int WindowHeight=480;

/* The number of our GLUT window */
int window;

/* User Defined Structures */

struct vector3D				/*	A Structure To Hold A Single Vector ( NEW ) */
{
	float x, y, z;			/*	The Components Of The Vector ( NEW ) */
};

struct point3D				/*	A Structure To Hold A Single Vertex ( NEW ) */
{
	float nx,ny,nz,x,y,z;		/*	Vertex Position & Normal( NEW ) */
};

struct triangle3D				/*	A Structure To Hold A Single Polygon ( NEW ) */
{
	struct point3D P[3];		/*	Array Of 3 point3D Structures ( NEW ) */
};

/* User Defined Variables*/
int	outlineDraw		= TRUE;			/* Flag To Draw The Outline ( NEW ) */
int	flatDraw		= TRUE;			/* Flag To Draw The Outline ( NEW ) */
int	outlineWidth	= 3;				/* Width Of The Lines ( NEW ) */
unsigned char outlineRGB[3]	={0,0,0};		/* Color Of The Lines ( NEW ) */
unsigned char colorRGB[3]	={255,160,80};	/* Color Of The model ( NEW ) */
unsigned char whiteRGB[3]	={255,255,255};	

struct vector3D	lightAngle;				/* The Direction Of The Light ( NEW ) */
int	lightRotate	= FALSE;				/* Flag To See If We Rotate The Light ( NEW ) */

float	modelAngle	= 0.0f;				/* y-Axis Angle Of The Model ( NEW ) */
int		modelRotate	= TRUE;			/* Flag To Rotate The Model ( NEW ) */

struct triangle3D	*TRIS	= NULL;			/* Polygon Data ( NEW ) */
struct vector3D	*OUTLINE= NULL;			/* Polygon Data ( NEW ) */
int	trisNum		= 0;				/* Number Of Polygons ( NEW ) */

GLuint	shaderTexture[1];				/* Storage For One Texture ( NEW ) */
unsigned char *texData= NULL;
float xoutline,youtline,zoutline;

/*==========================================================================*/
void reorderPt4(void *pt)
{
#define SWAP(x,y) {temp=x;x=y;y=temp;}
register unsigned char *ub=(unsigned char *)pt;
register unsigned char temp;

	SWAP(ub[0],ub[3])
	SWAP(ub[1],ub[2])
}
/*==========================================================================*/
/* File Functions*/
int ReadMesh(void)	/* Reads The Contents Of The "model.txt" File ( NEW ) */
{
FILE *fp;	
float *pt;
long int size,i,j;

	fp=fopen ("Data/Model.bin", "rb");				/* Open The File ( NEW ) */
	if (!fp)
		return FALSE;			/*	Return FALSE If File Not Opened ( NEW ) */
	fread (&trisNum, sizeof(int), 1, fp);			/* Read The Header (i.e. Number Of Polygons) ( NEW ) */
	reorderPt4(&trisNum);
	size=sizeof(struct triangle3D) * trisNum;
	TRIS = malloc(size);					/* Allocate The Memory ( NEW ) */
	pt=(float *) TRIS;
	fread (&TRIS[0],size,1,fp);				/* Read fp All Polygon Data ( NEW ) */

	size=size/4;
	for (i = 0; i < size; i++)
		reorderPt4(&pt[i]);

	fclose (fp);				/*	Close The File ( NEW ) */

	size=sizeof(struct vector3D) * trisNum*3;
	OUTLINE = malloc(size);

	return TRUE;				/*	It Worked ( NEW ) */
}
/*==========================================================================*/
/* Math Functions*/
float DotProduct (struct vector3D *a, struct vector3D *b)		/* Calculate The Angle Between The 2 Vectors ( NEW ) */
{
	return a->x * b->x + a->y * b->y + a->z * b->z;		/* Return The Angle ( NEW ) */
}
/*==========================================================================*/
void Normalize (struct vector3D *v)		/*	Creates A Vector With A Unit Length Of 1 ( NEW ) */
{
register float d;	

	d=sqrt (v->x * v->x + v->y * v->y + v->z * v->z);		/* Calculate The Length Of The Vector	( NEW ) */
	if (d != 1.0f)
	if (d != 0.0f)				/*	Make Sure We Don't Divide By 0	( NEW ) */
	{
		v->x=v->x/d;			/*	Normalize The 3 Components	( NEW ) */
		v->y=v->y/d;
		v->z=v->z/d;
	}
}
/*==========================================================================*/
void RotateVector (float *M, struct vector3D *v)		/* Rotate A Vector Using The Supplied Matrix ( NEW ) */
{
register float x,y,z;

	x=v->x;	y=v->y;	z=v->z;
	v->x = M[0]*x + M[4]*y + M[8 ]*z;	/* Rotate Around The x Axis ( NEW ) */
	v->y = M[1]*x + M[5]*y + M[9 ]*z;	/* Rotate Around The y Axis ( NEW ) */
	v->z = M[2]*x + M[6]*y + M[10]*z;	/* Rotate Around The z Axis ( NEW ) */
}
/*==========================================================================*/
/* A general OpenGL initialization function.	Sets all of the initial parameters. */
int InitGL()				/* We call this right after our OpenGL window is created. */
{
float shade[16]={0.3,0.3,0.3,0.5,0.5,0.5,0.5,1.0,1.0,1.0,1.0,1.0,1.0,1.0,1.0,1.0};
int i,j;								/*	 Looping Variable ( NEW ) */

/* Select type of Display mode: Double buffer + RGBA color + Alpha components supported + Depth buffer */
/*	glutInitDisplayMode(GLUT_RGBA | GLUT_DOUBLE | GLUT_ALPHA | GLUT_DEPTH); */
	glutInitDisplayMode(GLUT_RGBA | GLUT_DOUBLE | GLUT_DEPTH);

/* get a 640 x 480 window */
	glutInitWindowSize(WindowWidth,WindowHeight);

/* the window starts at the upper left corner of the screen */
	glutInitWindowPosition(0, 0);

/* Open a window */
	window = glutCreateWindow("Jeff Molofee's GL Code Tutorial ... NeHe '99");
/* Start Of User Initialization */
	glEnable (GL_DEPTH_TEST);					/* Enable Depth Testing */
	glDepthFunc (GL_LESS);						/* The Type Of Depth Test To Do */
	glClearDepth (0.99f);						/* Depth Buffer Setup */
	glClearColor (0.3f,0.2f,0.9f,0.0f);				/* Light blue Background */
	glShadeModel (GL_FLAT);						/* Disable Smooth Color Shading ( NEW ) */
	glEnable (GL_CULL_FACE);					/* Enable OpenGL Face Culling ( NEW ) */
	glDisable (GL_LIGHTING);					/* Disable OpenGL Lighting ( NEW ) */
	glDisable (GL_BLEND);		

	glGenTextures (1, &shaderTexture[0]);			/* Get A Free Texture ID ( NEW ) */
	glBindTexture (GL_TEXTURE_2D, shaderTexture[0]);	/* Bind This Texture. From Now On It Will Be 2D ( NEW ) */
	texData = malloc(16*16*3);
/* Thellier: use a 2D texture so hardware accelerated */
		for (i = 0; i < 16; i++)				/* Loop Though The 16 Greyscale Values ( NEW ) */
		for (j = 0; j < 16; j++)				/* Loop Though The 16 Greyscale Values ( NEW ) */
			{
			texData[i*16*3+j*3+0] =shade[i]*(float)colorRGB[0];
			texData[i*16*3+j*3+1] =shade[i]*(float)colorRGB[1];
			texData[i*16*3+j*3+2] =shade[i]*(float)colorRGB[2];
			}

	glTexImage2D(GL_TEXTURE_2D,0,24/8,16,16,0,GL_RGB,GL_UNSIGNED_BYTE,texData);		
	glTexParameterf(GL_TEXTURE_2D,GL_TEXTURE_MIN_FILTER, GL_LINEAR);
	glTexParameterf(GL_TEXTURE_2D,GL_TEXTURE_MAG_FILTER, GL_LINEAR);

	lightAngle.x = 0.0f;		/*	Set The x Direction ( NEW ) */
	lightAngle.y = 0.0f;		/*	Set The y Direction ( NEW ) */
	lightAngle.z = 1.0f;		/*	Set The z Direction ( NEW ) */
	Normalize (&lightAngle);	/*	Normalize The Light Direction ( NEW ) */

	return ReadMesh ();
}
/*==========================================================================*/
/* The function called when our window is resized (which shouldn't happen, because we're fullscreen) */
void ReshapeFunc(int Width, int Height)
{
	if (Height==0)			/*	Prevent A Divide By Zero If The Window Is Too Small */
		Height=1;
	if (Width==0)			/*	Prevent A Divide By Zero If The Window Is Too Small */
		Width=1;

	WindowWidth=Width;
	WindowHeight=Height;
	glViewport(0, 0, Width, Height);				/* Reset The Current Viewport And Perspective Transformation */

	glMatrixMode(GL_PROJECTION);
	glLoadIdentity();

	gluPerspective(45.0f,(GLfloat)Width/(GLfloat)Height,0.1f,100.0f);
	glMatrixMode(GL_MODELVIEW);
}
/*==========================================================================*/
/* The main drawing function. */
void DisplayFunc()
{
int i, j;							/*	Looping Variables ( NEW ) */
float Shade;						/*	Temporary Shader Value ( NEW ) */
float ViewMatrix[16];						/*	Temporary float Structure ( NEW ) */
struct vector3D TmpVector, normal;				/*	Temporary struct vector3D Structures ( NEW ) */
float x,y,z,xmed,ymed,zmed;

	glClear (GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);		/* Clear The Buffers */
	glLoadIdentity ();					/* Reset The Matrix */

	glTranslatef (0.0f, 0.0f, -2.0f);			/* Move 2 Units Away From The Screen ( NEW ) */
	glRotatef (modelAngle, 0.0f, 1.0f, 0.0f);		/* Rotate The Model On It's y-Axis ( NEW ) */

	glGetFloatv (GL_MODELVIEW_MATRIX,ViewMatrix);	/* Get The Generated Matrix ( NEW ) */

/* Cel-Shading Code */
	if(flatDraw)
	{
	glEnable (GL_TEXTURE_2D);					/* Enable 2D Texturing ( NEW ) */
	glBindTexture (GL_TEXTURE_2D, shaderTexture[0]);	/* Bind Our Texture ( NEW ) */
	glCullFace(GL_BACK);						/* Reset The Face To Be Culled ( NEW ) */
	glColor3bv(whiteRGB);						/* tex only */
	glTexEnvf(GL_TEXTURE_ENV,GL_TEXTURE_ENV_MODE,GL_REPLACE);
	glHint(GL_PERSPECTIVE_CORRECTION_HINT, GL_FASTEST);

	glBegin (GL_TRIANGLES);						/* Tell OpenGL That We're Drawing Triangles */
		for (i = 0; i < trisNum; i++)				/* Loop Through Each Polygon ( NEW ) */
		{
			for (j = 0; j < 3; j++)				/* Loop Through Each Vertex ( NEW ) */
			{
				normal.x = TRIS[i].P[j].nx;		/* Fill Up The normal Structure With */
				normal.y = TRIS[i].P[j].ny;		/* The Current Vertices' Normal Values ( NEW ) */
				normal.z = TRIS[i].P[j].nz;

				RotateVector (ViewMatrix, &normal);				/* Rotate This By The Matrix ( NEW ) */
				Normalize (&normal);						/* Normalize The New Normal ( NEW ) */
				Shade = DotProduct (&normal, &lightAngle);		/* Calculate The Shade Value ( NEW ) */

				if (Shade < 0.0f)
					Shade = 0.0f;						/* Clamp The Value to 0 If Negative ( NEW ) */
				if (1.0f <= Shade)
					Shade = 0.99f;						/* Clamp The Value  ( NEW ) */

				glTexCoord2f (0.0,Shade);						/* Set The Texture Co-ordinate As The Shade Value ( NEW ) */
				glVertex3f(TRIS[i].P[j].x,TRIS[i].P[j].y,TRIS[i].P[j].z);	/* Send The Vertex Position ( NEW ) */
				}
		}
	glEnd ();									/*	Tell OpenGL To Finish Drawing */
	}


/* Outline Code */
	if (outlineDraw)								/* Check To See If We Want To Draw The Outline ( NEW ) */
	{
	xoutline=(float)outlineWidth/(float)WindowWidth;
	youtline=(float)outlineWidth/(float)WindowHeight;
	zoutline=xoutline;
	for (i = 0; i < trisNum; i++)				/* Loop Through Each Polygon ( NEW ) */
		{
		xmed=(TRIS[i].P[0].x+TRIS[i].P[1].x+TRIS[i].P[2].x)/3.0;
		ymed=(TRIS[i].P[0].y+TRIS[i].P[1].y+TRIS[i].P[2].y)/3.0;
		zmed=(TRIS[i].P[0].z+TRIS[i].P[1].z+TRIS[i].P[2].z)/3.0;

		for (j = 0; j < 3; j++)				/* Loop Through Each Vertex ( NEW ) */
			{
			x=TRIS[i].P[j].x;					/* redo as bigger triangles ( NEW ) */
			y=TRIS[i].P[j].y;
			z=TRIS[i].P[j].z;
			if(xmed<x) x=x+xoutline;
			if(x<xmed) x=x-xoutline;
			if(ymed<y) y=y+youtline;
			if(y<ymed) y=y-youtline;
			if(zmed<z) z=z+zoutline;
			if(z<zmed) z=z-zoutline;
			OUTLINE[i*3+j].x=x;				
			OUTLINE[i*3+j].y=y;				
			OUTLINE[i*3+j].z=z;			
			}
		}

		glColor3bv (outlineRGB);					/* Set The Outline Color ( NEW ) */
		glDisable (GL_TEXTURE_2D);					/* Disable 2D Textures ( NEW ) */
		glCullFace (GL_FRONT);						/* Don't Draw Any Front-Facing Polygons ( NEW ) */

		glBegin (GL_TRIANGLES);						/* Tell OpenGL What We Want To Draw */
			for (i = 0; i < trisNum*3; i++)			/* Loop Through Each Polygon ( NEW ) */
				glVertex3f(OUTLINE[i].x,OUTLINE[i].y,OUTLINE[i].z);		/* Draw Backfacing Polygons As bigger triangles ( NEW ) */
		glEnd ();								/*	Tell OpenGL We've Finished */
	}


/* since this is double buffered, swap the buffers to display what just got drawn.*/
	glutSwapBuffers();
	if (modelRotate)				/*	Check To See If Rotation Is Enabled ( NEW ) */
		modelAngle += 2.0f;
}
/*==========================================================================*/
void CloseAll (void)			/*	Any User DeInitialization Goes Here */
{
	glDeleteTextures (1, &shaderTexture[0]);			/* Delete The Shader Texture ( NEW ) */
	free(texData);
	free(TRIS);								/* Delete The Polygon Data ( NEW ) */
	free(OUTLINE);							/* Delete The outline Data ( NEW ) */
	glutDestroyWindow(window);	/* shut down our window */
}
/*==========================================================================*/
/* The function called whenever a key is pressed. */
void KeyboardFunc(unsigned char key, int x, int y)
{
	/* avoid thrashing this procedure */
	usleep(100);

	/* If escape is pressed, kill everything. */

	switch (key) {

		case ESCAPE: 				/* kill everything. */
			CloseAll();		
			exit(1);				/* exit the program...normal termination. */
			break; 				/* redundant. */

		case 'r':
		case 'R':
			modelRotate = !modelRotate;
			break;

		case 'o':
		case 'O':
			outlineDraw = !outlineDraw;
			printf("outline draw %d\n",outlineDraw);
			break;

		case 'f':
		case 'F':
			flatDraw = !flatDraw;
			printf("flat draw %d\n",flatDraw);
			break;

		case '+':
			if(outlineWidth<50)
			outlineWidth= outlineWidth++;
			printf("outline width %d\n",outlineWidth);
			break;

		case '-':
			if(1<outlineWidth)
			outlineWidth= outlineWidth--;
			printf("outline width %d\n",outlineWidth);
			break;

		default:
			break;
		}

}
/*==========================================================================*/
void SpecialFunc(int key, int x, int y)
{
		/* avoid thrashing this procedure */
		usleep(100);

		switch (key) {

		case GLUT_KEY_UP: /* decrease x rotation speed;*/
			if(outlineWidth<50)
			outlineWidth= outlineWidth++;
			printf("outline width %d\n",outlineWidth);
			break;

		case GLUT_KEY_DOWN: /* increase x rotation speed;*/
			if(1<outlineWidth)
			outlineWidth= outlineWidth--;
			printf("outline width %d\n",outlineWidth);
			break;

		default:
			break;
		}
}
/*==========================================================================*/
int main(int argc, char **argv)
{
/* Initialize GLUT state - glut will take any command line arguments that pertain to it or 		*/
/*		 x Windows - look at its documentation at http:/*reality.sgi.com/mjk/spec3/spec3.html	*/
	glutInit(&argc, argv);

/* Initialize our window. */
	InitGL(640,480);

/* Register the function to do all our OpenGL drawing. */
	glutDisplayFunc(&DisplayFunc);

/* Even if there are no events, redraw our gl scene. */
	glutIdleFunc(&DisplayFunc);

/* Register the function called when our window is resized. */
	glutReshapeFunc(&ReshapeFunc);

/* Register the function called when the keyboard is pressed. */
	glutKeyboardFunc(&KeyboardFunc);
	glutSpecialFunc(&SpecialFunc);

/* Start Event Processing Engine */
	glutMainLoop();
	return 1;
}
