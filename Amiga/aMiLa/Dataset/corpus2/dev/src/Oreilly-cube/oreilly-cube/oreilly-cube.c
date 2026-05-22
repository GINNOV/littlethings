// ----------------------
// OpenGL cube demo.
//
// Written by Chris Halsall (chalsall@chalsall.com) for the
// O'Reilly Network on Linux.com (oreilly.linux.com).
// May 2000.
//
// Released into the Public Domain; do with it as you wish.
// We would like to hear about interesting uses.
//
// Coded to the groovy tunes of Yello: Pocket Universe.

#define PROGRAM_TITLE "O'Reilly Net: OpenGL Demo -- C.Halsall"

#include <stdio.h>   // Always a good idea.
#include <time.h>    // For our FPS stats.
#include <GL/glut.h> // GLUT support library.

// Some global variables.

// Window and texture IDs, window width and height.
int Texture_ID;
int Window_ID;
int Window_Width = 300;
int Window_Height = 300;

// Our display mode settings.
int Light_On = 0;
int Blend_On = 0;
int Texture_On = 0;
int Filtering_On = 0;
int Alpha_Add = 0;

int Curr_TexMode = 0;
char *TexModesStr[] = {"GL_DECAL","GL_MODULATE","GL_BLEND","GL_REPLACE"};
GLint TexModes[] = {GL_DECAL,GL_MODULATE,GL_BLEND,GL_REPLACE};

// Object and scene global variables.

// Cube position and rotation speed variables.
float X_Rot   = 0.9f;
float Y_Rot   = 0.0f;
float X_Speed = 0.0f;
float Y_Speed = 0.5f;
float Z_Off   =-5.0f;

// Settings for our light.  Try playing with these (or add more lights).
float Light_Ambient[]=  { 0.1f, 0.1f, 0.1f, 1.0f };
float Light_Diffuse[]=  { 1.2f, 1.2f, 1.2f, 1.0f };
float Light_Position[]= { 2.0f, 2.0f, 0.0f, 1.0f };


// ------
// Frames per second (FPS) statistic variables and routine.

#define FRAME_RATE_SAMPLES 100
int FrameCount=0;
long FrameRate=0;

static void ourDoFPS(
)
{
   static clock_t last=0;
   clock_t now;
   long delta;

   if (++FrameCount >= FRAME_RATE_SAMPLES) {
      now  = clock();
      delta= (now - last) / (long) CLOCKS_PER_SEC;
      last = now;

      FrameRate = FRAME_RATE_SAMPLES / delta;
      FrameCount = 0;
   }
}


// ------
// String rendering routine; leverages on GLUT routine.

static void ourPrintString(
   void *font,
   char *str
)
{
   int i,l=strlen(str);

   for(i=0;i<l;i++)
      glutBitmapCharacter(font,*str++);
}


// ------
// Routine which actually does the drawing

void cbRenderScene(
   void
)
{
   char buf[80]; // For our strings.

   // Enables, disables or otherwise adjusts as
   // appropriate for our current settings.

   if (Texture_On)
      glEnable(GL_TEXTURE_2D);
   else
      glDisable(GL_TEXTURE_2D);

   if (Light_On)
      glEnable(GL_LIGHTING);
   else
      glDisable(GL_LIGHTING);

    if (Alpha_Add)
       glBlendFunc(GL_SRC_ALPHA,GL_ONE);
    else
       glBlendFunc(GL_SRC_ALPHA,GL_ONE_MINUS_SRC_ALPHA);

    // If we're blending, we don't want z-buffering.
    if (Blend_On)
       glDisable(GL_DEPTH_TEST);
    else
       glEnable(GL_DEPTH_TEST);

    if (Filtering_On) {
       glTexParameterf(GL_TEXTURE_2D,GL_TEXTURE_MIN_FILTER,
                                           GL_LINEAR_MIPMAP_LINEAR);
       glTexParameterf(GL_TEXTURE_2D,GL_TEXTURE_MAG_FILTER,GL_LINEAR);
    } else {
       glTexParameterf(GL_TEXTURE_2D,GL_TEXTURE_MIN_FILTER,
                                           GL_NEAREST_MIPMAP_NEAREST);
       glTexParameterf(GL_TEXTURE_2D,GL_TEXTURE_MAG_FILTER,GL_NEAREST);
    }


   // Need to manipulate the ModelView matrix to move our model around.
   glMatrixMode(GL_MODELVIEW);

   // Reset to 0,0,0; no rotation, no scaling.
   glLoadIdentity();

   // Move the object back from the screen.
   glTranslatef(0.0f,0.0f,Z_Off);

   // Rotate the calculated amount.
   glRotatef(X_Rot,1.0f,0.0f,0.0f);
   glRotatef(Y_Rot,0.0f,1.0f,0.0f);


   // Clear the color and depth buffers.
   glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);


   // OK, let's start drawing our planer quads.
   glBegin(GL_QUADS);


   // Bottom Face.  Red, 75% opaque, magnified texture

   glNormal3f( 0.0f, -1.0f, 0.0f); // Needed for lighting
   glColor4f(0.9,0.2,0.2,.75); // Basic polygon color

   glTexCoord2f(0.800f, 0.800f); glVertex3f(-1.0f, -1.0f, -1.0f);
   glTexCoord2f(0.200f, 0.800f); glVertex3f( 1.0f, -1.0f, -1.0f);
   glTexCoord2f(0.200f, 0.200f); glVertex3f( 1.0f, -1.0f,  1.0f);
   glTexCoord2f(0.800f, 0.200f); glVertex3f(-1.0f, -1.0f,  1.0f);


   // Top face; offset.  White, 50% opaque.

   glNormal3f( 0.0f, 1.0f, 0.0f);  glColor4f(0.5,0.5,0.5,.5);

   glTexCoord2f(0.005f, 1.995f); glVertex3f(-1.0f,  1.3f, -1.0f);
   glTexCoord2f(0.005f, 0.005f); glVertex3f(-1.0f,  1.3f,  1.0f);
   glTexCoord2f(1.995f, 0.005f); glVertex3f( 1.0f,  1.3f,  1.0f);
   glTexCoord2f(1.995f, 1.995f); glVertex3f( 1.0f,  1.3f, -1.0f);


   // Far face.  Green, 50% opaque, non-uniform texture cooridinates.

   glNormal3f( 0.0f, 0.0f,-1.0f);  glColor4f(0.2,0.9,0.2,.5);

   glTexCoord2f(0.995f, 0.005f); glVertex3f(-1.0f, -1.0f, -1.3f);
   glTexCoord2f(2.995f, 2.995f); glVertex3f(-1.0f,  1.0f, -1.3f);
   glTexCoord2f(0.005f, 0.995f); glVertex3f( 1.0f,  1.0f, -1.3f);
   glTexCoord2f(0.005f, 0.005f); glVertex3f( 1.0f, -1.0f, -1.3f);


   // Right face.  Blue; 25% opaque

   glNormal3f( 1.0f, 0.0f, 0.0f);  glColor4f(0.2,0.2,0.9,.25);

   glTexCoord2f(0.995f, 0.005f); glVertex3f( 1.0f, -1.0f, -1.0f);
   glTexCoord2f(0.995f, 0.995f); glVertex3f( 1.0f,  1.0f, -1.0f);
   glTexCoord2f(0.005f, 0.995f); glVertex3f( 1.0f,  1.0f,  1.0f);
   glTexCoord2f(0.005f, 0.005f); glVertex3f( 1.0f, -1.0f,  1.0f);


   // Front face; offset.  Multi-colored, 50% opaque.

   glNormal3f( 0.0f, 0.0f, 1.0f);

   glColor4f( 0.9f, 0.2f, 0.2f, 0.5f);
   glTexCoord2f( 0.005f, 0.005f); glVertex3f(-1.0f, -1.0f,  1.3f);
   glColor4f( 0.2f, 0.9f, 0.2f, 0.5f);
   glTexCoord2f( 0.995f, 0.005f); glVertex3f( 1.0f, -1.0f,  1.3f);
   glColor4f( 0.2f, 0.2f, 0.9f, 0.5f);
   glTexCoord2f( 0.995f, 0.995f); glVertex3f( 1.0f,  1.0f,  1.3f);
   glColor4f( 0.1f, 0.1f, 0.1f, 0.5f);
   glTexCoord2f( 0.005f, 0.995f); glVertex3f(-1.0f,  1.0f,  1.3f);


   // Left Face; offset.  Yellow, varying levels of opaque.

   glNormal3f(-1.0f, 0.0f, 0.0f);

   glColor4f(0.9,0.9,0.2,0.0);
   glTexCoord2f(0.005f, 0.005f); glVertex3f(-1.3f, -1.0f, -1.0f);
   glColor4f(0.9,0.9,0.2,0.66);
   glTexCoord2f(0.995f, 0.005f); glVertex3f(-1.3f, -1.0f,  1.0f);
   glColor4f(0.9,0.9,0.2,1.0);
   glTexCoord2f(0.995f, 0.995f); glVertex3f(-1.3f,  1.0f,  1.0f);
   glColor4f(0.9,0.9,0.2,0.33);
   glTexCoord2f(0.005f, 0.995f); glVertex3f(-1.3f,  1.0f, -1.0f);


   // All polygons have been drawn.
   glEnd();

   // Move back to the origin (for the text, below).
   glLoadIdentity();

   // We need to change the projection matrix for the text rendering.
   glMatrixMode(GL_PROJECTION);

   // But we like our current view too; so we save it here.
   glPushMatrix();

   // Now we set up a new projection for the text.
   glLoadIdentity();
   glOrtho(0,Window_Width,0,Window_Height,-1.0,1.0);

   // Lit or textured text looks awful.
   glDisable(GL_TEXTURE_2D);
   glDisable(GL_LIGHTING);

   // We don't want depth-testing either.
   glDisable(GL_DEPTH_TEST);

   // But, for fun, let's make the text partially transparent too.
   glColor4f(0.6,1.0,0.6,.75);

   // Render our various display mode settings.
   sprintf(buf,"Mode: %s", TexModesStr[Curr_TexMode]);
   glRasterPos2i(2,2); ourPrintString(GLUT_BITMAP_HELVETICA_12,buf);

   sprintf(buf,"AAdd: %d", Alpha_Add);
   glRasterPos2i(2,14); ourPrintString(GLUT_BITMAP_HELVETICA_12,buf);

   sprintf(buf,"Blend: %d", Blend_On);
   glRasterPos2i(2,26); ourPrintString(GLUT_BITMAP_HELVETICA_12,buf);

   sprintf(buf,"Light: %d", Light_On);
   glRasterPos2i(2,38); ourPrintString(GLUT_BITMAP_HELVETICA_12,buf);

   sprintf(buf,"Tex: %d", Texture_On);
   glRasterPos2i(2,50); ourPrintString(GLUT_BITMAP_HELVETICA_12,buf);

   sprintf(buf,"Filt: %d", Filtering_On);
   glRasterPos2i(2,62); ourPrintString(GLUT_BITMAP_HELVETICA_12,buf);


   // Now we want to render the calulated FPS at the top.

   // To ease, simply translate up.  Note we're working in screen
   // pixels in this projection.

   glTranslatef(6.0f,Window_Height - 14,0.0f);

   // Make sure we can read the FPS section by first placing a
   // dark, mostly opaque backdrop rectangle.
   glColor4f(0.2,0.2,0.2,0.75);

   glBegin(GL_QUADS);
   glVertex3f(  0.0f, -2.0f, 0.0f);
   glVertex3f(  0.0f, 12.0f, 0.0f);
   glVertex3f(140.0f, 12.0f, 0.0f);
   glVertex3f(140.0f, -2.0f, 0.0f);
   glEnd();

   glColor4f(0.9,0.2,0.2,.75);
   sprintf(buf,"FPS: %d F: %2d", FrameRate, FrameCount);
   glRasterPos2i(6,0);
   ourPrintString(GLUT_BITMAP_HELVETICA_12,buf);

   // Done with this special projection matrix.  Throw it away.
   glPopMatrix();

   // All done drawing.  Let's show it.
   glutSwapBuffers();

   // Now let's do the motion calculations.
   X_Rot+=X_Speed;
   Y_Rot+=Y_Speed;

   // And collect our statistics.
   ourDoFPS();
}


// ------
// Callback function called when a normal key is pressed.

void cbKeyPressed(
   unsigned char key,
   int x, int y
)
{
   switch (key) {
      case 113: case 81: case 27: // Q (Escape) - We're outta here.
      glutDestroyWindow(Window_ID);
      exit(1);
      break; // exit doesn't return, but anyway...

   case 130: case 98: // B - Blending.
      Blend_On = Blend_On ? 0 : 1;
      if (!Blend_On)
         glDisable(GL_BLEND);
      else
         glEnable(GL_BLEND);
      break;

   case 108: case 76:  // L - Lighting
      Light_On = Light_On ? 0 : 1;
      break;

   case 109: case 77:  // M - Mode of Blending
      if ( ++ Curr_TexMode > 3 )
         Curr_TexMode=0;
      glTexEnvi(GL_TEXTURE_ENV,GL_TEXTURE_ENV_MODE,TexModes[Curr_TexMode]);
      break;

   case 116: case 84: // T - Texturing.
      Texture_On = Texture_On ? 0 : 1;
      break;

   case 97: case 65:  // A - Alpha-blending hack.
      Alpha_Add = Alpha_Add ? 0 : 1;
      break;

   case 102: case 70:  // F - Filtering.
      Filtering_On = Filtering_On ? 0 : 1;
      break;

   case 115: case 83: case 32:  // F (Space) - Freeze!
      X_Speed=Y_Speed=0;
      break;

   case 114: case 82:  // R - Reverse.
      X_Speed=-X_Speed;
          Y_Speed=-Y_Speed;
      break;

   default:
      printf ("KP: No action for %d.\n", key);
      break;
    }
}


// ------
// Callback Function called when a special key is pressed.

void cbSpecialKeyPressed(
   int key,
   int x,
   int y
)
{
   switch (key) {
   case GLUT_KEY_PAGE_UP: // move the cube into the distance.
      Z_Off -= 0.05f;
      break;

   case GLUT_KEY_PAGE_DOWN: // move the cube closer.
      Z_Off += 0.05f;
      break;

   case GLUT_KEY_UP: // decrease x rotation speed;
      X_Speed -= 0.01f;
      break;

   case GLUT_KEY_DOWN: // increase x rotation speed;
      X_Speed += 0.01f;
      break;

   case GLUT_KEY_LEFT: // decrease y rotation speed;
      Y_Speed -= 0.01f;
      break;

   case GLUT_KEY_RIGHT: // increase y rotation speed;
      Y_Speed += 0.01f;
      break;

   default:
      printf ("SKP: No action for %d.\n", key);
      break;
    }
}


// ------
// Function to build a simple full-color texture with alpha channel,
// and then create mipmaps.  This could instead load textures from
// graphics files from disk, or render textures based on external
// input.

void ourBuildTextures(
   void
)
{
   GLenum gluerr;
   GLubyte tex[128][128][4];
   int x,y,t;
   int hole_size = 3300; // ~ == 57.45 ^ 2.

   // Generate a texture index, then bind it for future operations.
   glGenTextures(1,&Texture_ID);
   glBindTexture(GL_TEXTURE_2D,Texture_ID);

   // Iterate across the texture array.

   for(y=0;y<128;y++) {
      for(x=0;x<128;x++) {

         // A simple repeating squares pattern.
         // Dark blue on white.

         if ( ( (x+4)%32 < 8 ) && ( (y+4)%32 < 8)) {
            tex[x][y][0]=tex[x][y][1]=0; tex[x][y][2]=120;
         } else {
            tex[x][y][0]=tex[x][y][1]=tex[x][y][2]=240;
         }

                 // Make a round dot in the texture's alpha-channel.

                 // Calculate distance to center (squared).
         t = (x-64)*(x-64) + (y-64)*(y-64) ;

         if ( t < hole_size) // Don't take square root; compare squared.
            tex[x][y][3]=255; // The dot itself is opaque.
         else if (t < hole_size + 100)
            tex[x][y][3]=128; // Give our dot an anti-aliased edge.
         else
            tex[x][y][3]=0;   // Outside of the dot, it's transparent.

      }
   }

   // The GLU library helps us build MipMaps for our texture.

   if ((gluerr=gluBuild2DMipmaps(GL_TEXTURE_2D, 4, 128, 128, GL_RGBA,
                 GL_UNSIGNED_BYTE, (void *)tex))) {

      fprintf(stderr,"GLULib%s\n",gluErrorString(gluerr));
      exit(-1);
   }

   // Some pretty standard settings for wrapping and filtering.
   glTexParameterf(GL_TEXTURE_2D,GL_TEXTURE_WRAP_S,GL_REPEAT);
   glTexParameterf(GL_TEXTURE_2D,GL_TEXTURE_WRAP_T,GL_REPEAT);

   // We start with GL_DECAL mode.
   glTexEnvf(GL_TEXTURE_ENV,GL_TEXTURE_ENV_MODE,GL_DECAL);
}


// ------
// Callback routine executed whenever our window is resized.  Lets us
// request the newly appropriate perspective projection matrix for
// our needs.  Try removing the gluPerspective() call to see what happens.

void cbResizeScene(
   int Width,
   int Height
)
{
   // Let's not core dump, no matter what.
   if (Height == 0)
      Height = 1;

   glViewport(0, 0, Width, Height);

   glMatrixMode(GL_PROJECTION);
   glLoadIdentity();
   gluPerspective(45.0f,(GLfloat)Width/(GLfloat)Height,0.1f,100.0f);

   glMatrixMode(GL_MODELVIEW);

   Window_Width  = Width;
   Window_Height = Height;
}


// ------
// Does everything needed before losing control to the main
// OpenGL event loop.

void ourInit(
  int Width,
  int Height
)
{
   ourBuildTextures();

   // Color to clear color buffer to.
   glClearColor(0.1f, 0.1f, 0.1f, 0.0f);

   // Depth to clear depth buffer to; type of test.
   glClearDepth(1.0);
   glDepthFunc(GL_LESS);

   // Enables Smooth Color Shading; try GL_FLAT for (lack of) fun.
   glShadeModel(GL_SMOOTH);

   // Load up the correct perspective matrix; using a callback directly.
   cbResizeScene(Width,Height);

   // Set up a light, turn it on.
   glLightfv(GL_LIGHT1, GL_POSITION, Light_Position);
   glLightfv(GL_LIGHT1, GL_AMBIENT,  Light_Ambient);
   glLightfv(GL_LIGHT1, GL_DIFFUSE,  Light_Diffuse);
   glEnable (GL_LIGHT1);

   // A handy trick -- have surface material mirror the color.
   glColorMaterial(GL_FRONT_AND_BACK,GL_AMBIENT_AND_DIFFUSE);
   glEnable(GL_COLOR_MATERIAL);
}

// ------
// The main() function.  Inits OpenGL.  Calls our own init function,
// then passes control onto OpenGL.

int main(
  int argc,
  char **argv
)
{
   glutInit(&argc, argv);

   // To see OpenGL drawing, take out the GLUT_DOUBLE request.
   glutInitDisplayMode(GLUT_RGBA | GLUT_DOUBLE | GLUT_DEPTH);
   glutInitWindowSize(Window_Width, Window_Height);

   // Open a window
   Window_ID = glutCreateWindow( PROGRAM_TITLE );

   // Register the callback function to do the drawing.
   glutDisplayFunc(&cbRenderScene);

   // If there's nothing to do, draw.
   glutIdleFunc(&cbRenderScene);

   // It's a good idea to know when our window's resized.
   glutReshapeFunc(&cbResizeScene);

   // And let's get some keyboard input.
   glutKeyboardFunc(&cbKeyPressed);
   glutSpecialFunc(&cbSpecialKeyPressed);

   // OK, OpenGL's ready to go.  Let's call our own init function.
   ourInit(Window_Width, Window_Height);

   // Print out a bit of help dialog.
   printf("\n" PROGRAM_TITLE "\n\n");
   printf("Use arrow keys to rotate, 'R' to reverse, 'S' to stop.\n");
   printf("Page up/down will move cube away from/towards camera.\n\n");
   printf("Use first letter of shown display mode settings to alter.\n\n");
   printf("Q or [Esc] to quit; OpenGL window must have focus for input.\n");

   // Pass off control to OpenGL.
   // Above functions are called as appropriate.
   glutMainLoop();

   return 1;
}
