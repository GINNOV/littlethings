#include <stdio.h>
#ifdef WIN32
#include <windows.h>
#endif
#include <GL/gl.h>

#ifdef __cplusplus
extern "C" {
#endif
#ifndef TRUE
#define TRUE 1
#endif
#ifndef FALSE
#define FALSE 0
#endif

typedef unsigned int Visual_ID;
  

typedef struct {
  int doubleBuffer;     /* boolean, TRUE if double buffered */
  int stereo;           /* boolean, TRUE if stereo */
  int rgba;             /* boolean, TRUE if rgba, FALSE if color index */

  int indexSize;        /* if NOT rgba, depth of color index color buffer*/

  int redSize;          /* if rgba, depth of red   color buffer channel */
  int greenSize;        /* if rgba, depth of green color buffer channel */
  int blueSize;         /* if rgba, depth of blue  color buffer channel */
  int alphaSize;        /* if rgba, depth of alpha color buffer channel */

  int accumRedSize;     /* if rgba, depth of red   accum buffer channel */
  int accumGreenSize;   /* if rgba, depth of green accum buffer channel */
  int accumBlueSize;    /* if rgba, depth of blue  accum buffer channel */
  int accumAlphaSize;   /* if rgba, depth of alpha accum buffer channel */

  int depthSize;        /* depth of depth buffer (z buffer) */
  int stencilSize;      /* depth of stencil buffer */
#ifdef GL_SGIS_multisample
  int sampleBuffers;    /* number of multisample buffers */
  int numSamples;       /* number of multisamples per pixel */
#endif

  int auxBuffers;       /* number of auxiliary buffers */

  int level;            /* frame buffer level, <  0 implies underlay planes
                         *                     == 0 implies main planes
                         *                     >  0 implies overlay planes
                         */
#if defined(XWINDOWS)
  Visual_ID visualId;    /* visual ID, X handle to visual descriptor */
  int visualClass;      /* visual class, TrueColor, PseudoColor, etc. */
#elif defined(WIN32)
  int ipfd;             /* pixel format ID */
#elif defined(__OS2__)
  unsigned long visualId; /* pgl visual id */
#endif
} BufferConfig;

typedef struct {
  int month;            /* month test was run, in the range [1-12] */
  int day;              /* day   test was run, in the range [1-31] */
  int year;             /* year  test was run, as a four digit number */
  char *host;           /* what machine this test was run on */
  char *hostOperatingSystem; /* what OS this test was run under */
  char *hostOperatingSystemVersion; /* what OS version test was run under */
  char *hostVendor;     /* who manufactured machine test was run on */
  char *hostModel;      /* model designation of the host */
  char *hostCPU;        /* CPU in the host */
  char *hostCPUCount;   /* number of CPU's in host */
  int hostMemorySize;   /* number of MB of memory installed on test machine */
  char *hostPrimaryCacheSize; /* number of KB in primary cache */
  char *hostSecondaryCacheSize; /* number of KB in secondary cache */
  char *windowSystem;   /* name of target window system */
  char *driverVersion;  /* graphics driver version */
  char *glVendor;       /* OpenGL vendor name */
  char *glVersion;      /* OpenGL version */
  char *glExtensions;   /* OpenGL extension list */
  char *glRenderer;     /* OpenGL renderer name, e.g. graphics device */
  char *glClientVendor; /* OpenGL client vendor */
  char *glClientVersion; /* OpenGL client version */
  char *glClientExtensions; /* OpenGL client extensions */
  char *gluVersion;     /* GLU version */
  char *gluExtensions;  /* GLU extension list */
  int directRender;     /* boolean, TRUE if direct rendering connection */
  BufferConfig bufConfig; /* OpenGL buffer configuration, buffer depths etc. */
  int windowWidth;      /* width of the window in pixels */
  int windowHeight;     /* height of the window in pixels */
  int screenWidth;      /* width of the screen in pixels */
  int screenHeight;     /* height of the screen in pixels */

#if defined(XWINDOWS)
  char *display;        /* name of the display, e.g. what node server is on */
  char *glServerVendor; /* OpenGL server vendor */
  char *glServerVersion; /* OpenGL server version */
  char *glServerExtensions; /* OpenGL server extensions */
  char *glxVersion;     /* GLX version, effective connection version */
  char *glxExtensions;     /* GLX extensions, effective extension set */
  int screenNumber;     /* which screen of the X server */
  int sharedMemConnection;  /* boolean, TRUE if shared memory connection */
#endif
} EnvironmentInfo;

char *StringSearch(char *subject, char *pattern);
int GetDateTime(int *month, int *day, int *year, int *hour, int *minute);
int GetEnvironment(EnvironmentInfo *info);
void FreeEnvironmentData(EnvironmentInfo *info);
void NullEnvironmentData(EnvironmentInfo *info);
void PrintEnvironment(FILE *stream, EnvironmentInfo *info, char *title,
                      char *leader, int nameWidth, char *suffix);

#ifdef __cplusplus
}
#endif
