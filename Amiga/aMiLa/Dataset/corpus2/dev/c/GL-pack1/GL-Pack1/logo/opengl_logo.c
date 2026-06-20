/*
 * Main.c
 *
 * This file is part of the openGL-logo demo.
 * (c) Henk Kok (kok@wins.uva.nl)
 *
 * Copying, redistributing, etc is permitted as long as this copyright
 * notice and the Dutch variable names :) stay in tact.
 */

#include <GL/glut.h>
#include <stdlib.h>
#include <stdio.h>
#include <math.h>

GLfloat lightpos[4] = { 1.0F,1.0F,1.0F,0.0F };
GLfloat lightamb[4] = { 0.3F,0.3F,0.3F,1.0F };
GLfloat lightdif[4] = { 0.8F,0.8F,0.8F,1.0F };
float speed=0,progress = 1;
void SetCamera(void);

extern void randomize(void);
extern void def_logo(void);
extern void draw_logo(void);

void do_display(void) {
  SetCamera();
  draw_logo();
  glFlush();
  glutSwapBuffers();
}

void display(void) {
  glClear(GL_COLOR_BUFFER_BIT|GL_DEPTH_BUFFER_BIT);
  do_display();
}

void myinit(void) {
  glShadeModel(GL_SMOOTH);
  glEnable(GL_DEPTH_TEST);
  glLightfv(GL_LIGHT0,GL_POSITION,lightpos);
  glLightfv(GL_LIGHT0,GL_AMBIENT,lightamb);
  glLightfv(GL_LIGHT0,GL_DIFFUSE,lightdif);
  glEnable(GL_LIGHTING);
  glEnable(GL_LIGHT0);
  glColor3f(1.0,1.0,1.0);
  glClearColor(0.0,0.0,0.0,1.0);
  glPolygonMode(GL_FRONT_AND_BACK,GL_FILL);
  glEnable(GL_NORMALIZE);
  def_logo();
  glCullFace(GL_BACK);
  glEnable(GL_CULL_FACE);
}

void parsekey(unsigned char key,int x,int y) {
  switch(key) {
    case 27  : exit(0); 
               break;
    case 13  : break;
    case ' ' : progress = 1; 
               randomize(); 
               break; }
}

void parsekey_special(int key,int x,int y) {
  switch(key) {
    case GLUT_KEY_UP    : break;
    case GLUT_KEY_DOWN  : break;
    case GLUT_KEY_RIGHT : break;
    case GLUT_KEY_LEFT  : break; }
}

void Animate(void) {
  speed = -0.95*speed + progress*0.05;
  if(progress > 0.0 && speed < 0.0003)
    speed = 0.0003F;
  if(speed > 0.01)
    speed = 0.01F;
  progress = progress - speed;
  if(progress < 0.0) {
    progress = 0.0;
    speed = 0; }
  glutPostRedisplay();
}

void myReshape(int w,int h) {
  glMatrixMode(GL_MODELVIEW);
  glViewport(0,0,w,h);
  glLoadIdentity();
  SetCamera();
}

void SetCamera(void) {
  glMatrixMode(GL_PROJECTION);
  glLoadIdentity();
  glFrustum(-0.1333,0.1333,-0.1,0.1,0.2,150.0);
  glMatrixMode(GL_MODELVIEW);
  glLoadIdentity();
  gluLookAt(0,1.5,2,0,1.5,0,0,1,0);
  glTranslatef(0.0,-8.0,-45.0);
  glRotatef(-progress*720,0.0,1.0,0.0);
}

int main(int argc, char **argv) {
// Corto : ajout glutInit()
glutInit(&argc, argv);

  glutInitDisplayMode(GLUT_DEPTH|GLUT_RGB|GLUT_DOUBLE|GLUT_MULTISAMPLE);
  glutInitWindowPosition(200,0);
  glutInitWindowSize(320,240);
  glutCreateWindow("Logo OpenGL");
myinit();
  glutDisplayFunc(display);
  glutKeyboardFunc(parsekey);
  glutSpecialFunc(parsekey_special);
  glutReshapeFunc(myReshape);
  glutIdleFunc(Animate);
  randomize();
//  myinit();
//  glutSwapBuffers();
  glutMainLoop();

  return 0;
}
