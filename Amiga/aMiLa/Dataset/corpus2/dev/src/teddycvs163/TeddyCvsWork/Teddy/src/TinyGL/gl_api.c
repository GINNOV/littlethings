
/*!
	\file
	\ingroup g_tiny_gl
	\author
	\brief
	\date    2001
*/


#include "TinyGL/gl_zgl.h"
#include <assert.h>
#include <stdio.h>


void glVertex4f( float x, float y, float z, float w ){
	GLParam p[5];

	p[0].op = OP_Vertex;
	p[1].f  = x;
	p[2].f  = y;
	p[3].f  = z;
	p[4].f  = w;

	gl_add_op( p );
}

void glVertex2f( float x,float y ){
	glVertex4f( x, y, 0, 1 );
}

void glVertex3f( float x, float y, float z ){
	glVertex4f( x, y, z, 1 );
}

void glVertex3fv( const float *v ){
	glVertex4f( v[0], v[1], v[2], 1 );
}

/* glNormal */

void glNormal3f( float x, float y, float z ){
	GLParam p[4];

	p[0].op = OP_Normal;
	p[1].f  = x;
	p[2].f  = y;
	p[3].f  = z;

	gl_add_op( p );
}

void glNormal3fv( const float *v ){
	glNormal3f( v[0], v[1], v[2] );
}

/* glColor */

void glColor4f( float r, float g, float b, float a ){
	GLParam p[8];

	p[0].op = OP_Color;
	p[1].f  = r;
	p[2].f  = g;
	p[3].f  = b;
	p[4].f  = a;
	/* direct convertion to integer to go faster if no shading */
	p[5].ui = (unsigned int) (r * (ZB_POINT_RED_MAX   - ZB_POINT_RED_MIN  ) + ZB_POINT_RED_MIN  );
	p[6].ui = (unsigned int) (g * (ZB_POINT_GREEN_MAX - ZB_POINT_GREEN_MIN) + ZB_POINT_GREEN_MIN);
	p[7].ui = (unsigned int) (b * (ZB_POINT_BLUE_MAX  - ZB_POINT_BLUE_MIN ) + ZB_POINT_BLUE_MIN );
	gl_add_op( p );
}

void glColor4fv( const float *v ){
	GLParam p[8];

	p[0].op = OP_Color;
	p[1].f  = v[0];
	p[2].f  = v[1];
	p[3].f  = v[2];
	p[4].f  = v[3];
	/* direct convertion to integer to go faster if no shading */
	p[5].ui = (unsigned int) (v[0] * (ZB_POINT_RED_MAX   - ZB_POINT_RED_MIN  ) + ZB_POINT_RED_MIN  );
	p[6].ui = (unsigned int) (v[1] * (ZB_POINT_GREEN_MAX - ZB_POINT_GREEN_MIN) + ZB_POINT_GREEN_MIN);
	p[7].ui = (unsigned int) (v[2] * (ZB_POINT_BLUE_MAX  - ZB_POINT_BLUE_MIN ) + ZB_POINT_BLUE_MIN );
	gl_add_op( p );
}

void glColor3f( float x, float y, float z ){
	glColor4f( x, y, z, 1 );
}

void glColor3fv( const float *v ){
	glColor4f( v[0], v[1], v[2], 1 );
}


/* TexCoord */

void glTexCoord4f( float s, float t, float r, float q ){
	GLParam p[5];

	p[0].op = OP_TexCoord;
	p[1].f  = s;
	p[2].f  = t;
	p[3].f  = r;
	p[4].f  = q;

	gl_add_op( p );
}

void glTexCoord2f( float s, float t ){
	glTexCoord4f( s, t, 0, 1 );
}

void glTexCoord2fv( const float *v ){
	glTexCoord4f( v[0], v[1], 0, 1 );
}

void glEdgeFlag( GLboolean flag ){
	GLParam p[2];

	p[0].op = OP_EdgeFlag;
	p[1].i  = flag;

	gl_add_op( p );
}

/* misc */

void glShadeModel( GLenum mode ){
	GLParam p[2];

	assert( mode == GL_FLAT || mode == GL_SMOOTH );

	p[0].op = OP_ShadeModel;
	p[1].i  = mode;

	gl_add_op( p );
}

void glCullFace( GLenum mode ){
	GLParam p[2];

	assert( mode == GL_BACK || mode == GL_FRONT || mode == GL_FRONT_AND_BACK );

	p[0].op = OP_CullFace;
	p[1].i  = mode;

	gl_add_op( p );
}

void glFrontFace( GLenum mode ){
	GLParam p[2];

	assert( mode == GL_CCW || mode == GL_CW );

	mode = (mode != GL_CCW);

	p[0].op = OP_FrontFace;
	p[1].i  = mode;

	gl_add_op( p );
}

void glPolygonMode( GLenum face, GLenum mode ){
	GLParam p[3];

	assert( face == GL_BACK || face == GL_FRONT || face == GL_FRONT_AND_BACK );
	assert( mode == GL_POINT || mode == GL_LINE || mode == GL_FILL );

	p[0].op = OP_PolygonMode;
	p[1].i  = face;
	p[2].i  = mode;

	gl_add_op( p );
}


/* glEnable / glDisable */
void glEnable( GLenum cap ){
	GLParam p[3];

	p[0].op = OP_EnableDisable;
	p[1].i  = cap;
	p[2].i  = 1;

	gl_add_op( p );
}

void glDisable( GLenum cap ){
	GLParam p[3];

	p[0].op = OP_EnableDisable;
	p[1].i  = cap;
	p[2].i  = 0;

	gl_add_op( p );
}


/* glBegin / glEnd */
void glBegin( GLenum mode ){
	GLParam p[2];

	p[0].op = OP_Begin;
	p[1].i  = mode;

	gl_add_op( p );
}

void glEnd( void ){
	GLParam p[1];

	p[0].op = OP_End;

	gl_add_op( p );
}

/* matrix */

void glMatrixMode( GLenum mode ){
	GLParam p[2];

	p[0].op = OP_MatrixMode;
	p[1].i  = mode;

	gl_add_op( p );
}

void glLoadMatrixf( const float *m ){
	GLParam p[17];
	int     i;

	p[0].op = OP_LoadMatrix;
	for( i=0; i<16; i++ ){
		p[i+1].f = m[i];
	}

	gl_add_op( p );
}

void glLoadIdentity( void ){
	GLParam p[1];

	p[0].op = OP_LoadIdentity;

	gl_add_op( p );
}

void glMultMatrixf( const float *m ){
	GLParam p[17];
	int     i;

	p[0].op = OP_MultMatrix;
	for( i=0; i<16; i++ ){
		p[i+1].f = m[i];
	}

	gl_add_op( p );
}

void glPushMatrix( void ){
	GLParam p[1];

	p[0].op = OP_PushMatrix;

	gl_add_op( p );
}

void glPopMatrix( void ){
	GLParam p[1];

	p[0].op = OP_PopMatrix;

	gl_add_op( p );
}

void glRotatef( float angle, float x, float y, float z ){
	GLParam p[5];

	p[0].op = OP_Rotate;
	p[1].f  = angle;
	p[2].f  = x;
	p[3].f  = y;
	p[4].f  = z;

	gl_add_op( p );
}

void glTranslatef( float x, float y, float z ){
	GLParam p[4];

	p[0].op = OP_Translate;
	p[1].f  = x;
	p[2].f  = y;
	p[3].f  = z;

	gl_add_op( p );
}

void glScalef( float x, float y, float z ){
	GLParam p[4];

	p[0].op = OP_Scale;
	p[1].f  = x;
	p[2].f  = y;
	p[3].f  = z;

	gl_add_op( p );
}

void glViewport( int x, int y, int width, int height ){
	GLParam p[5];

	p[0].op = OP_Viewport;
	p[1].i  = x;
	p[2].i  = y;
	p[3].i  = width;
	p[4].i  = height;

	gl_add_op( p );
}

void glFrustum( double left, double right, double bottom, double top, double near_, double farv ){
	GLParam p[7];

	p[0].op = OP_Frustum;
	p[1].f  = (float)left;
	p[2].f  = (float)right;
	p[3].f  = (float)bottom;
	p[4].f  = (float)top;
	p[5].f  = (float)near_;
	p[6].f  = (float)farv;

	gl_add_op( p );
}

/* lightening */

void glMaterialfv( GLenum mode, GLenum type,const float *v){
	GLParam p[7];
	int     i;
	int     n;

	assert( mode == GL_FRONT  || mode == GL_BACK || mode==GL_FRONT_AND_BACK );

	p[0].op = OP_Material;
	p[1].i  = mode;
	p[2].i  = type;
	n       = 4;

	if( type == GL_SHININESS ){
		n = 1;
	}

	for( i=0; i<4; i++ ){
		p[3+i].f = v[i];
	}
	for( i=n; i<4; i++ ){
		p[3+i].f = 0;
	}

	gl_add_op( p );
}

void glMaterialf( GLenum mode, GLenum type, float v ){
	GLParam p[7];
	int     i;

	p[0].op = OP_Material;
	p[1].i  = mode;
	p[2].i  = type;
	p[3].f  = v;
	for( i=0; i<3; i++ ){
		p[4+i].f = 0;
	}

	gl_add_op( p );
}

void glColorMaterial( GLenum mode, GLenum type ){
	GLParam p[3];

	p[0].op = OP_ColorMaterial;
	p[1].i  = mode;
	p[2].i  = type;

	gl_add_op( p );
}

void glLightfv( GLenum light, GLenum type, const float *v ){
	GLParam p[7];
	int     i;

	p[0].op = OP_Light;
	p[1].i  = light;
	p[2].i  = type;
	/* TODO: 3 composants ? */
	for( i=0; i<4; i++ ){
		p[3+i].f = v[i];
	}

	gl_add_op( p );
}

void glLightf( GLenum light, GLenum type, float v ){
	GLParam p[7];
	int     i;

	p[0].op = OP_Light;
	p[1].i  = light;
	p[2].i  = type;
	p[3].f  = v;
	for( i=0; i<3; i++){
		p[4+i].f = 0;
	}

	gl_add_op( p );
}

void glLightModeli( GLenum pname, GLint param ){
	GLParam p[6];
	int     i;

	p[0].op = OP_LightModel;
	p[1].i  = pname;
	p[2].f  = (float)param;
	for( i=0; i<4; i++ ){
		p[3+i].f = 0;
	}

	gl_add_op( p );
}

void glLightModelfv( GLenum pname, const float *param ){
	GLParam p[6];
	int     i;

	p[0].op = OP_LightModel;
	p[1].i  = pname;
	for( i=0; i<4; i++ ){
		p[2+i].f = param[i];
	}

	gl_add_op( p );
}


/* clear */
void glClear( GLenum mask ){
	GLParam p[2];

	p[0].op = OP_Clear;
	p[1].i  = mask;

	gl_add_op( p );
}

void glClearColor( float r, float g, float b, float a ){
	GLParam p[5];

	p[0].op = OP_ClearColor;
	p[1].f  = r;
	p[2].f  = g;
	p[3].f  = b;
	p[4].f  = a;

	gl_add_op( p );
}

void glClearDepth( double depth ){
	GLParam p[2];

	p[0].op = OP_ClearDepth;
	p[1].f  = (float)depth;

	gl_add_op( p );
}


/* textures */
void glTexImage2D(
	GLenum        target,
	int           level,
	int           components,
	int           width,
	int           height,
	int           border,
	GLenum        format,
	GLenum        type,
	const GLvoid *pixels
){
	GLParam p[10];

	p[0].op = OP_TexImage2D;
	p[1].i  = target;
	p[2].i  = level;
	p[3].i  = components;
	p[4].i  = width;
	p[5].i  = height;
	p[6].i  = border;
	p[7].i  = format;
	p[8].i  = type;
	p[9].p  = (void*)pixels;

	gl_add_op( p );
}


void glBindTexture( GLenum target, GLenum texture ){
	GLParam p[3];
	
	p[0].op = OP_BindTexture;
	p[1].i  = target;
	p[2].i  = texture;
	
	gl_add_op( p );
}

void glTexEnvi( GLenum target, GLenum pname, int param ){
	GLParam p[8];
	
	p[0].op = OP_TexEnv;
	p[1].i  = target;
	p[2].i  = pname;
	p[3].i  = param;
	p[4].f  = 0;
	p[5].f  = 0;
	p[6].f  = 0;
	p[7].f  = 0;
	
	gl_add_op( p );
}

void glTexParameteri( GLenum target, GLenum pname, int param ){
	GLParam p[8];
	
	p[0].op = OP_TexParameter;
	p[1].i  = target;
	p[2].i  = pname;
	p[3].i  = param;
	p[4].f  = 0;
	p[5].f  = 0;
	p[6].f  = 0;
	p[7].f  = 0;
	
	gl_add_op( p );
}

void glPixelStorei( GLenum pname, int param ){
	GLParam p[3];
	
	p[0].op = OP_PixelStore;
	p[1].i  = pname;
	p[2].i  = param;
	
	gl_add_op( p );
}


/* selection */
void glInitNames( void ){
	GLParam p[1];
	
	p[0].op = OP_InitNames;
	
	gl_add_op( p );
}

void glPushName( unsigned int name ){
	GLParam p[2];
	
	p[0].op = OP_PushName;
	p[1].i  = name;
	
	gl_add_op( p );
}

void glPopName( void ){
	GLParam p[1];
	
	p[0].op = OP_PopName;
	
	gl_add_op( p );
}

void glLoadName( unsigned int name ){
	GLParam p[2];
	
	p[0].op = OP_LoadName;
	p[1].i  = name;
	
	gl_add_op( p );
}

void glPolygonOffset( GLfloat factor, GLfloat units ){
	GLParam p[3];

	p[0].op = OP_PolygonOffset;
	p[1].f  = factor;
	p[2].f  = units;
}


/* Special Functions */
void glCallList( unsigned int list ){
	GLParam p[2];
	
	p[0].op = OP_CallList;
	p[1].i  = list;
	
	gl_add_op( p );
}

void glFlush( void ){
	/* nothing to do */
}

void glHint( GLenum target,GLenum mode ){
	GLParam p[3];
	
	p[0].op = OP_Hint;
	p[1].i  = target;
	p[2].i  = mode;
	
	gl_add_op( p );
}


/* Non standard functions */
void glDebug( int mode ){
	GLContext *c = gl_get_context();

	c->print_flag = mode;
}

