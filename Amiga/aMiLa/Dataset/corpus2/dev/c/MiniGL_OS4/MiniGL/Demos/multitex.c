#include <GL/glut.h>
#include <stdlib.h>
#include <stdio.h>
#include <string.h>

GLint texture;
GLint lightmap;
GLfloat off = 0.0;

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

	where = malloc(x*y*3);
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


GLint TexInit(char *name)
{
	GLubyte *tmap;
	GLint x,y;
	GLuint texture;

	glPixelStorei(GL_UNPACK_ALIGNMENT, 1);
	glPixelStorei(GL_PACK_ALIGNMENT, 1);

	if (!name)
		return 0;
	else
		tmap = LoadPPM(name, &x, &y);

	if (!tmap)
		return 0;


	glGenTextures(1, &texture);
	glBindTexture(GL_TEXTURE_2D, texture);
	glTexImage2D(GL_TEXTURE_2D, 0, 3,
		x,y, 0, GL_RGB, GL_UNSIGNED_BYTE, tmap);
	free(tmap);

	glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR);
	glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);

	glEnable(GL_TEXTURE_2D);
	
	return (GLint)texture;
}

void init()
{
	texture = TexInit("data/door.ppm");
	lightmap = TexInit("data/lmap.ppm");
	printf("texture=%d, lightmap=%d\n", texture, lightmap);

	glActiveTexture(GL_TEXTURE0);
  	glEnable(GL_TEXTURE_2D);
   	glBindTexture(GL_TEXTURE_2D, texture);
	glTexEnvf(GL_TEXTURE_ENV, GL_TEXTURE_ENV_MODE, GL_REPLACE);
  	glActiveTexture(GL_TEXTURE1);
  	glEnable(GL_TEXTURE_2D);
   	glBindTexture(GL_TEXTURE_2D, lightmap);
	glTexEnvf(GL_TEXTURE_ENV, GL_TEXTURE_ENV_MODE, GL_MODULATE);
	glActiveTexture(GL_TEXTURE0);

}

void display(void)
{
	glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);

	glMatrixMode(GL_TEXTURE);
		
	glActiveTexture(GL_TEXTURE0);
	glPushMatrix();
	glRotated(off, 0.0, 0.0, 1.0);
	
	glActiveTexture(GL_TEXTURE1);
	glPushMatrix();
	glLoadIdentity();
	glTranslatef(0.0, off, 0.0);
	
	glColor4f(1.0, 1.0, 1.0, 1.0);
	glBegin(GL_QUADS);
		glMultiTexCoord2f(GL_TEXTURE0, 0.0, 0.0); 
		glMultiTexCoord2f(GL_TEXTURE1, 0.0, 0.0); 
		glVertex3f(-2.0, -1.0, 0.0);
		
		glMultiTexCoord2f(GL_TEXTURE0, 0.0, 1.0); 
		glMultiTexCoord2f(GL_TEXTURE1, 0.0, 1.0); 
		glVertex3f(-2.0, 1.0, 0.0);
		
		glMultiTexCoord2f(GL_TEXTURE0, 1.0, 1.0); 
		glMultiTexCoord2f(GL_TEXTURE1, 1.0, 1.0); 
		glVertex3f(0.0, 1.0, 0.0);
		
		glMultiTexCoord2f(GL_TEXTURE0, 1.0, 0.0); 
		glMultiTexCoord2f(GL_TEXTURE1, 1.0, 0.0); 
		glVertex3f(0.0, -1.0, 0.0);


		glMultiTexCoord2f(GL_TEXTURE0, 0.0, 0.0); 
		glMultiTexCoord2f(GL_TEXTURE1, 0.0, 0.0); 
		glVertex3f(1.0, -1.0, 0.0);
		
		glMultiTexCoord2f(GL_TEXTURE0, 0.0, 1.0); 
		glMultiTexCoord2f(GL_TEXTURE1, 0.0, 1.0); 
		glVertex3f(1.0, 1.0, 0.0);
		
		glMultiTexCoord2f(GL_TEXTURE0, 1.0, 1.0); 
		glMultiTexCoord2f(GL_TEXTURE1, 1.0, 1.0); 
		glVertex3f(2.41421, 1.0, -1.41421);
		
		glMultiTexCoord2f(GL_TEXTURE0, 1.0, 0.0); 
		glMultiTexCoord2f(GL_TEXTURE1, 1.0, 0.0); 
		glVertex3f(2.41421, -1.0, -1.41421);
   glEnd();
   
   glActiveTexture(GL_TEXTURE0);
   glPopMatrix();
   glActiveTexture(GL_TEXTURE1);
   glPopMatrix();
   
   glFlush();

   mglSwitchDisplay();
}

void reshape(int w, int h)
{
   glViewport(0, 0, (GLsizei) w, (GLsizei) h);
   glMatrixMode(GL_PROJECTION);
   glLoadIdentity();
   gluPerspective(60.0, (GLfloat) w/(GLfloat) h, 1.0, 30.0);
   glMatrixMode(GL_MODELVIEW);
   glLoadIdentity();
   glTranslatef(0.0, 0.0, -3.6);
}

void keyboard (unsigned char key, int x, int y)
{
   switch (key) 
   {
		case 27:
			exit(0);
			break;
   }
}


void idle(void)
{
	off += 0.01;
	display();
}

int main(int argc, char *argv[])
{
	GLint width=640; GLint height=480;
	int i;

	for (i=1; i<argc; i++)
	{
	if (0 == strcasecmp(argv[i], "-width"))
	{
		i++;
		width = atoi(argv[i]);
	}
	if (0 == strcasecmp(argv[i], "-height"))
	{
		i++;
		height = atoi(argv[i]);
	}
	}

	glutInit(&argc, argv);
 	glutInitDisplayMode(GLUT_DOUBLE | GLUT_RGB | GLUT_DEPTH);
 	glutInitWindowSize(width, height);
 	glutCreateWindow("Texsub");

	mglEnableSync(GL_TRUE);

	init();

	glDisable(GL_BLEND);
	glClearColor(0.2, 0.2, 0.2, 1.0);

	reshape(width,height);
	mglLockMode(MGL_LOCK_SMART);
	glutIdleFunc(idle);
	glutKeyboardFunc(keyboard);
	glutMainLoop();

	return 0;             /* ANSI C requires main to return int. */
}
