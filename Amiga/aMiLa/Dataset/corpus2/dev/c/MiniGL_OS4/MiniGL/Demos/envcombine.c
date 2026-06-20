/*
 * Demonstration of GL_ARB_texture_env_combine
 */

#include <GL/glut.h>
#include <GL/glext.h>

#include <stdlib.h>
#include <string.h>
#include <stdio.h>
#include <assert.h>

#ifdef WIN32
PFNGLACTIVETEXTUREPROC glActiveTexture;
PFNGLMULTITEXCOORD2FPROC glMultiTexCoord2f;
#endif

GLubyte *LoadPPM(char *name, GLint *w, GLint *h)
{
	int i;
	unsigned long x,y;
	FILE *f;
	GLubyte *where;

    f = fopen(name, "rb");

	if (!f)
	{
		printf("PPM open failed\n");
		*w = 0; *h=0;
		return NULL;
	}
	i = fscanf(f, "P6\n");
	if(fgetc(f) == '#'){
		while(fgetc(f) != '\n' && !ferror(f)){
			;
		}
		if(ferror(f)){
			printf("PPM open failed\n");
			*w = 0; *h=0;
			return NULL;
		}
	}
	else{
		fseek(f, -1, SEEK_CUR);
	}
	i += fscanf(f,"%ld %ld\n255\n", &x, &y);

	*w = x;
	*h = y;

	where = (GLubyte *)malloc(x*y*3);
	if (!where)
	{
		printf("Error out of Memory\n");
		fclose(f);
		*w = 0; *h = 0;
		return NULL;
	}

	i = fread(where, 1, x*y*3, f);
	fclose(f);

	if (i != x*y*3)
	{
		printf("Error while reading file\n");
		free(where);
		*w = 0; *h = 0;
		return NULL;
	}

	return where;
}


/* GLUT callback Handlers */

static void 
resize(int width, int height)
{
    const float ar = (float) width / (float) height;
    
    glViewport(0, 0, width, height);
    glMatrixMode(GL_PROJECTION);
    glLoadIdentity();
    glFrustum(-ar, ar, -1.0, 1.0, 2.0, 100.0);
    
    glMatrixMode(GL_MODELVIEW);
    glLoadIdentity() ;
}

static void 
display(void)
{
	static float t = 0.0f;
    glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);
    glColor3f(1.0f, 1.0f, 1.0f);
    
    t += 0.01f;
    
    glPushMatrix();
    
    	glTranslated(0, 0, -6);
    	glRotated(-190+8.0*t,1,0,0);
    	glScalef(2.0f, 2.0f, 2.0f);
    	
    	glBegin(GL_QUADS);
    		glColor3f(1.0f, 0.0f, 0.0f);
	    	glMultiTexCoord2f(GL_TEXTURE0, 0.0f, 0.0f);
	    	glMultiTexCoord2f(GL_TEXTURE1, t+0.0f, t+0.0f);
    		glVertex2f(-1.0f, -1.0f);
    	
    		glColor3f(1.0f, 1.0f, 1.0f);
    		glMultiTexCoord2f(GL_TEXTURE0, 0.0f, 1.0f);
    		glMultiTexCoord2f(GL_TEXTURE1, t+0.0f, t+1.0f);
    		glVertex2f(-1.0f, 1.0f);
    	
    		glColor3f(1.0f, 1.0f, 1.0f);
    		glMultiTexCoord2f(GL_TEXTURE0, 1.0f, 1.0f);
    		glMultiTexCoord2f(GL_TEXTURE1, t+1.0f, t+1.0f);
    		glVertex2f(1.0f, 1.0f);
    		
    		glColor3f(0.0f, 0.0f, 0.0f);
    		glMultiTexCoord2f(GL_TEXTURE0, 1.0f, 0.0f);
    		glMultiTexCoord2f(GL_TEXTURE1, t+1.0f, t+0.0f);
    		glVertex2f(1.0f, -1.0f);
    	glEnd();
    
    glPopMatrix();

    glutSwapBuffers();
}


static void 
key(unsigned char key, int x, int y)
{
    switch (key) 
    {
        case 27 : 
        case 'q':
            exit(0);
            break;
        case '1':
			glActiveTexture(GL_TEXTURE0);
			break;
		case '2':
			glActiveTexture(GL_TEXTURE1);
			break;
		case 'a':
			glTexEnvi(GL_TEXTURE_ENV, GL_COMBINE_RGB, GL_ADD);
			break;
		case 's':
			glTexEnvi(GL_TEXTURE_ENV, GL_COMBINE_RGB, GL_ADD_SIGNED);
			break;
		case 'm':
			glTexEnvi(GL_TEXTURE_ENV, GL_COMBINE_RGB, GL_MODULATE);
			break;
		case 'n':
			glTexEnvi(GL_TEXTURE_ENV, GL_COMBINE_RGB, GL_SUBTRACT);
			break;
		case 'r':
			glTexEnvi(GL_TEXTURE_ENV, GL_COMBINE_RGB, GL_REPLACE);
			break;
		case 'o':
			glEnable(GL_TEXTURE_2D);
			break;
		case 'p':
			glDisable(GL_TEXTURE_2D);
			break;
		case '9':
			glEnable(GL_CULL_FACE);
			glFrontFace(GL_CCW);
			glCullFace(GL_BACK);
			break;
		case '8':
			glDisable(GL_CULL_FACE);
			glFrontFace(GL_CCW);
			glCullFace(GL_BACK);
			break;
    }

    glutPostRedisplay();
}

static void 
idle(void)
{
    glutPostRedisplay();
}

void
MakeTextures(void)
{
	GLint w,h;
	GLubyte *tex;
	GLuint t1,t2;
	
	tex = LoadPPM("data/door.ppm", &w, &h);
	//assert(tex != NULL);
	glGenTextures(1, &t1);
	
	glActiveTexture(GL_TEXTURE0);
	glBindTexture(GL_TEXTURE_2D, t1);
	glTexImage2D(GL_TEXTURE_2D, 0,
		GL_RGB, w, h, 0, GL_RGB, GL_UNSIGNED_BYTE,
		tex);
	free(tex);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_NEAREST);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_REPEAT);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_REPEAT);
		
	tex = LoadPPM("data/wall.ppm", &w, &h);
	//assert(tex != NULL);
	glGenTextures(1, &t2);
	
	glActiveTexture(GL_TEXTURE1);
	glBindTexture(GL_TEXTURE_2D, t2);
	glTexImage2D(GL_TEXTURE_2D, 0,
		GL_RGB, w, h, 0, GL_RGB, GL_UNSIGNED_BYTE,
		tex);
	free(tex);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_NEAREST);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_REPEAT);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_REPEAT);
    
	glActiveTexture(GL_TEXTURE0);
	
	glEnable(GL_TEXTURE_2D);	
	glTexEnvi(GL_TEXTURE_ENV, GL_TEXTURE_ENV_MODE, GL_COMBINE);
	
	glTexEnvi(GL_TEXTURE_ENV, GL_COMBINE_RGB, GL_MODULATE);
		glTexEnvi(GL_TEXTURE_ENV, GL_SOURCE1_RGB, GL_PREVIOUS);
		glTexEnvi(GL_TEXTURE_ENV, GL_OPERAND1_RGB, GL_SRC_COLOR);
		
		glTexEnvi(GL_TEXTURE_ENV, GL_SOURCE0_RGB, GL_TEXTURE);
		glTexEnvi(GL_TEXTURE_ENV, GL_OPERAND0_RGB, GL_SRC_COLOR);

	glTexEnvi(GL_TEXTURE_ENV, GL_COMBINE_ALPHA, GL_MODULATE);
		glTexEnvi(GL_TEXTURE_ENV, GL_SOURCE1_ALPHA, GL_PREVIOUS);
		glTexEnvi(GL_TEXTURE_ENV, GL_OPERAND1_ALPHA, GL_SRC_ALPHA);
		
		glTexEnvi(GL_TEXTURE_ENV, GL_SOURCE0_ALPHA, GL_TEXTURE);
		glTexEnvi(GL_TEXTURE_ENV, GL_OPERAND0_ALPHA, GL_SRC_ALPHA);
	
	glActiveTexture(GL_TEXTURE1);
	
	glEnable(GL_TEXTURE_2D);	
	glTexEnvi(GL_TEXTURE_ENV, GL_TEXTURE_ENV_MODE, GL_COMBINE);
	
	glTexEnvi(GL_TEXTURE_ENV, GL_COMBINE_RGB, GL_ADD);
		glTexEnvi(GL_TEXTURE_ENV, GL_SOURCE0_RGB, GL_PREVIOUS);
		glTexEnvi(GL_TEXTURE_ENV, GL_OPERAND0_RGB, GL_SRC_COLOR);
		
		glTexEnvi(GL_TEXTURE_ENV, GL_SOURCE1_RGB, GL_TEXTURE);
		glTexEnvi(GL_TEXTURE_ENV, GL_OPERAND0_RGB, GL_SRC_COLOR);

	glTexEnvi(GL_TEXTURE_ENV, GL_COMBINE_ALPHA, GL_ADD);
		glTexEnvi(GL_TEXTURE_ENV, GL_SOURCE0_ALPHA, GL_PREVIOUS);
		glTexEnvi(GL_TEXTURE_ENV, GL_OPERAND0_ALPHA, GL_SRC_ALPHA);
		
		glTexEnvi(GL_TEXTURE_ENV, GL_SOURCE1_ALPHA, GL_TEXTURE);
		glTexEnvi(GL_TEXTURE_ENV, GL_OPERAND0_ALPHA, GL_SRC_ALPHA);	
	glActiveTexture(GL_TEXTURE0);
	
	//assert(glGetError() == GL_NO_ERROR);
}

/* Program entry point */

int 
main(int argc, char *argv[])
{
	const char *extensions;
    glutInit(&argc, argv);
    glutInitWindowSize(640,480);
    glutInitWindowPosition(10,10);
    glutInitDisplayMode(GLUT_RGB | GLUT_DOUBLE | GLUT_DEPTH);

    glutCreateWindow("GL_ARB_texture_env_combine Demo");

    glutReshapeFunc(resize);
    glutDisplayFunc(display);
    glutKeyboardFunc(key);
    glutIdleFunc(idle);

	extensions = (char *)glGetString(GL_EXTENSIONS);
	if (strstr(extensions, "GL_ARB_texture_env_combine") == 0)
	{
		printf("Sorry, your graphics card does not support the extension" \
			"\"GL_ARB_texture_env_combine\" required for this demo\n");
		return 0;
	}

#ifdef WIN32
	glActiveTexture = (PFNGLACTIVETEXTUREPROC)
		glutGetProcAddress("glActiveTexture");
	glMultiTexCoord2f = (PFNGLMULTITEXCOORD2FPROC)
		glutGetProcAddress("glMultiTexCoord2f");
#endif

	MakeTextures();

    glClearColor(1,1,1,1);
    glDisable(GL_CULL_FACE);
    glCullFace(GL_BACK);

    glEnable(GL_DEPTH_TEST);
    glDepthFunc(GL_LESS);

    glutMainLoop();

    return EXIT_SUCCESS;
}

