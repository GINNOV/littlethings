#include <GL/glut.h>
#include <stdio.h>
#include <string.h>

void SetString(GLenum token, char target[])
{
	char *str = (char *)glGetString(token);
	
	if (str)
		strcpy(target, str);
	else
		strcpy(target, "<undefined>");
}
	
int main(int argc, char **argv)
{
	char renderer[100];
	char vendor[100];
	char version[100];
	char extensions[10000];
	
    glutInit(&argc, argv);
    glutInitDisplayMode (GLUT_SINGLE | GLUT_RGB | GLUT_DEPTH);
    glutInitWindowSize (500, 500);
    glutCreateWindow (argv[0]);
	
	SetString(GL_RENDERER, renderer);
	SetString(GL_VENDOR, vendor);
	SetString(GL_VERSION, version);
	SetString(GL_EXTENSIONS, extensions);
	
	
	printf("GL_RENDERER: %s\n", renderer);
	printf("GL_VENDOR: %s\n", vendor);
	printf("GL_VERSION: %s\n", version);
	printf("GL_EXTENSIONS: %s\n", extensions);
	
	return 0;
}
