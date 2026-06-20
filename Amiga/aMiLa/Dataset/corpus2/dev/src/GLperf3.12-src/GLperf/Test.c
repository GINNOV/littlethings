/*
//   (C) COPYRIGHT International Business Machines Corp. 1993
//   All Rights Reserved
//   Licensed Materials - Property of IBM
//   US Government Users Restricted Rights - Use, duplication or
//   disclosure restricted by GSA ADP Schedule Contract with IBM Corp.
//

//
// Permission to use, copy, modify, and distribute this software and its
// documentation for any purpose and without fee is hereby granted, provided
// that the above copyright notice appear in all copies and that both that
// copyright notice and this permission notice appear in supporting
// documentation, and that the name of I.B.M. not be used in advertising
// or publicity pertaining to distribution of the software without specific,
// written prior permission. I.B.M. makes no representations about the
// suitability of this software for any purpose.  It is provided "as is"
// without express or implied warranty.
//
// I.B.M. DISCLAIMS ALL WARRANTIES WITH REGARD TO THIS SOFTWARE, INCLUDING ALL
// IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS, IN NO EVENT SHALL I.B.M.
// BE LIABLE FOR ANY SPECIAL, INDIRECT OR CONSEQUENTIAL DAMAGES OR ANY DAMAGES
// WHATSOEVER RESULTING FROM LOSS OF USE, DATA OR PROFITS, WHETHER IN AN ACTION
// OF CONTRACT, NEGLIGENCE OR OTHER TORTIOUS ACTION, ARISING OUT OF OR IN
// CONNECTION WITH THE USE OR PERFORMANCE OF THIS SOFTWARE.
//
// Author:  John Spitzer, IBM AWS Graphics Systems (Austin)
//
*/

#include <math.h>
#include "Test.h"
#include <malloc.h>

#ifdef OS2
static int hasWindow = 0;
#endif

void new_Test(TestPtr this)
{
    this->TimesRun = Test__TimesRun;
    this->clearBefore = True;
    NullEnvironmentData(&this->environ);
}

void delete_Test(TestPtr this)
{
    if (this->glperfVersion) {
	free(this->glperfVersion);
	this->glperfVersion = 0;
    }
    FreeEnvironmentData(&this->environ);
    delete_PrintfString(this->userString);
    if (this->fileName) free(this->fileName);
    free(this);
}

int Test__TimesRun(TestPtr this)
{
    return 1;
}

int Test__SetState(TestPtr this)
{
    GLenum windType = 0;
    int newWindow = 0;

    if (this->environ.bufConfig.rgba) {
        windType |= AUX_RGBA;
        if (this->environ.bufConfig.alphaSize) {
            windType |= AUX_ALPHA;
        }
    } else {
        windType |= AUX_INDEX;
    }

    if (this->environ.bufConfig.doubleBuffer) {
        windType |= AUX_DOUBLE;
    }
    else {
        windType |= AUX_SINGLE;
    }

    if (this->environ.directRender) {
        windType |= AUX_DIRECT;
    }
    else {
        windType |= AUX_INDIRECT;
    }

    if (this->environ.bufConfig.depthSize) {
        windType |= AUX_DEPTH;
    }

    if (this->environ.bufConfig.stencilSize) {
        windType |= AUX_STENCIL;
    }

    if (this->environ.bufConfig.accumRedSize   ||
        this->environ.bufConfig.accumGreenSize ||
        this->environ.bufConfig.accumBlueSize  ||
        this->environ.bufConfig.accumAlphaSize) {
        windType |= AUX_ACCUM;
    }

#ifdef GL_SGIS_multisample
    if (this->environ.bufConfig.sampleBuffers) {
	windType |= this->environ.bufConfig.numSamples * AUX_MULTISAMPLE;
    }
#endif

    this->windType = windType;

#ifdef OS2
    if (!hasWindow) newWindow = 1;
#endif

    if (this->previousWinW != this->environ.windowWidth  ||
        this->previousWinH != this->environ.windowHeight) {
        newWindow = 1;
    } 
#ifdef WIN32
    else if (this->environ.bufConfig.ipfd == NoVisual &&
        this->previousWindType != this->windType) {
        newWindow = 1;
    } else if (this->environ.bufConfig.ipfd != NoVisual &&
        this->previousVisual != this->environ.bufConfig.ipfd) {
        newWindow = 1;
    }
#elif __amigaos

#else
    else if (this->environ.bufConfig.visualId == NoVisual &&
        this->previousWindType != this->windType) {
        newWindow = 1;
    } else if (this->environ.bufConfig.visualId != NoVisual &&
        this->previousVisual != this->environ.bufConfig.visualId) {
        newWindow = 1;
    }
#endif


    /* Determine if we need to bring up a new window or not */
    if (newWindow) {
        if (this->previousVisual != NoVisual) {
            auxCloseWindow();
        }

        auxInitPosition(0, 0, this->environ.windowWidth, this->environ.windowHeight);
#ifdef WIN32
        if (this->environ.bufConfig.ipfd == NoVisual) {
            auxInitDisplayModePolicy(AUX_MINIMUM_CRITERIA);
            auxInitDisplayMode(windType);
        } else {
            auxInitDisplayModePolicy(AUX_USE_ID);
            auxInitDisplayModeID(this->environ.bufConfig.ipfd);
        }
#elif __amigaos

#else
        if (this->environ.bufConfig.visualId == NoVisual) {
#ifdef __OS2__
extern GLenum APIENTRY auxInitDisplayModePolicy(int);
extern GLint APIENTRY auxInitDisplayModeID(GLenum);
#endif
            auxInitDisplayModePolicy(AUX_MINIMUM_CRITERIA);
            auxInitDisplayMode(windType);
        } else {
            auxInitDisplayModePolicy(AUX_USE_ID);
            auxInitDisplayModeID(this->environ.bufConfig.visualId);
        }
#endif


        if (auxInitWindow("GLperf") == GL_FALSE) {
	    printf("GLperf: could not open window you wanted, check attributes\n");
	    exit(1);
        }

        /*
         * GetEnvironment sets the bufConfig, so GetEnvironment must be called
         * before using any of the environ or bufConfig members.
         */
        GetEnvironment(&this->environ);

	/*
	 * Check window size against screen size.
	 * If window is larger, resize window down to screen size.
	 */
        if (this->environ.windowWidth > this->environ.screenWidth ||
            this->environ.windowHeight > this->environ.screenHeight) {
	    auxCloseWindow();
	    auxInitPosition(0, 0, this->environ.screenWidth, this->environ.screenHeight);
#ifdef WIN32
            if (this->environ.bufConfig.ipfd == NoVisual) {
                auxInitDisplayModePolicy(AUX_MINIMUM_CRITERIA);
                auxInitDisplayMode(windType);
            } else {
                auxInitDisplayModePolicy(AUX_USE_ID);
                auxInitDisplayModeID(this->environ.bufConfig.ipfd);
            }
#elif __amigaos

#else
            if (this->environ.bufConfig.visualId == NoVisual) {
#ifdef __OS2__
extern GLenum APIENTRY auxInitDisplayModePolicy(int);
extern GLint APIENTRY auxInitDisplayModeID(GLenum);
#endif
                auxInitDisplayModePolicy(AUX_MINIMUM_CRITERIA);
                auxInitDisplayMode(windType);
            } else {
                auxInitDisplayModePolicy(AUX_USE_ID);
                auxInitDisplayModeID(this->environ.bufConfig.visualId);
            }
#endif

	    if (auxInitWindow("GLperf") == GL_FALSE) {
	        printf("GLperf: could not open window you wanted, check attributes\n");
	        exit(1);
	    }
            GetEnvironment(&this->environ);
        }

        if (!this->environ.bufConfig.rgba) {
            int i;
            int rampsize = 1 << this->environ.bufConfig.indexSize;
            GLfloat shade;
            for (i = 0; i < rampsize; i++) {
                shade = (GLfloat) i/(GLfloat) rampsize;
                auxSetOneColor((GLint)i, shade, shade, shade);
            }
            glIndexi(rampsize-1);
        } else {
            glColor4f(1., 1., 1., 1.);
        }
#ifdef OS2
        hasWindow = 1;
#endif
    } else {
        /* Get the visual and environment data */
        GetEnvironment(&this->environ);
    }
    return 0;
}

void Test__Calibrate(TestPtr this)
{
    GLfloat elapsed;

    /* if Iterations is set, this takes precedence over Time, so skidaddle */
    if (this->iterations != -1) return;
    this->iterations = 1;
    do {
	elapsed = Test__TimedRun(this);
	this->iterations *= 2;
    } while (elapsed < 1.0);
    this->iterations /= 2;
    this->iterations = (int)ceil(this->time * (GLfloat)this->iterations / elapsed);
}

void Test__ClearBuffers(TestPtr this)
{
    if (this->clearBefore) {
	glPushAttrib(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);
	if(this->environ.bufConfig.doubleBuffer)
	  glDrawBuffer(GL_FRONT_AND_BACK);
	else
	  glDrawBuffer(GL_FRONT);
	glColorMask(GL_TRUE, GL_TRUE, GL_TRUE, GL_TRUE);
	glClearColor(0x00, 0x00, 0x00, 0x00);
	glIndexMask(0xffff);
	glClearIndex(0x0);
	glDepthMask(GL_TRUE);
	glClearDepth(1.0);
	glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);
	glPopAttrib();
    }
    glFinish();
}

GLfloat Test__TimedRun(TestPtr this)
{
    int saveIterations;
    TimerPtr timer = new_Timer();
    GLfloat returnValue;
    int i;
    int base, list;

    switch (this->executeMode) {
	case Immediate:
	    Test__ClearBuffers(this);
	    Timer__Start(timer);
	    this->Execute(this);
	    if(this->environ.bufConfig.doubleBuffer)
	      auxSwapBuffers();
	    glFinish();
	    Timer__Stop(timer);
	    break;
	case Compile:
	    saveIterations = this->iterations;
	    this->iterations = 1;
	    base = glGenLists(saveIterations);
	    Timer__Start(timer);
	    for (i=base; i<base+saveIterations; i++) {
		glNewList(i, GL_COMPILE);
		this->Execute(this);
		glEndList();
	    }
	    glFinish();
	    Timer__Stop(timer);
	    glDeleteLists(base, saveIterations);
	    this->iterations = saveIterations;
	    break;
	case CallList:
	    saveIterations = this->iterations;
	    this->iterations = 1;
	    list = glGenLists(1);
	    glNewList(list, GL_COMPILE);
	    this->Execute(this);
	    glEndList();
	    /* Prime the pump with one invocation */
	    glCallList(list);
	    Test__ClearBuffers(this);
	    Timer__Start(timer);
	    for (i=0; i<saveIterations; i++) {
		glCallList(list);
	    }
	    if(this->environ.bufConfig.doubleBuffer)
	      auxSwapBuffers();
	    glFinish();
	    Timer__Stop(timer);
	    glDeleteLists(list, 1);
	    this->iterations = saveIterations;
	    break;
	case CompileExecute:
	    saveIterations = this->iterations;
	    this->iterations = 1;
	    base = glGenLists(saveIterations);
	    Test__ClearBuffers(this);
	    Timer__Start(timer);
	    for (i=base; i<base+saveIterations; i++) {
		glNewList(i, GL_COMPILE_AND_EXECUTE);
		this->Execute(this);
		glEndList();
	    }
	    if(this->environ.bufConfig.doubleBuffer)
	      auxSwapBuffers();
	    glFinish();
	    Timer__Stop(timer);
	    glDeleteLists(base, saveIterations);
	    this->iterations = saveIterations;
	    break;
	case DestroyList:
	    saveIterations = this->iterations;
	    this->iterations = 1;
	    base = glGenLists(saveIterations);
	    for (i=base; i<base+saveIterations; i++) {
		glNewList(i, GL_COMPILE);
		this->Execute(this);
		glEndList();
	    }
	    glFinish();
	    Timer__Start(timer);
	    glDeleteLists(base, saveIterations);
	    glFinish();
	    Timer__Stop(timer);
	    this->iterations = saveIterations;
	    break;
    }
    returnValue = Timer__Read(timer);
    delete_Timer(timer);
    return returnValue;
}

static void CheckForError( void)
{
    switch (glGetError()) {
    case GL_NO_ERROR: 
        break;
    case GL_INVALID_ENUM:
        printf("WARNING: An error (GL_INVALID_ENUM) has been recorded.  Results may be incorrect.\n");
        break;
    case GL_INVALID_VALUE:
        printf("WARNING: An error (GL_INVALID_VALUE) has been recorded.  Results may be incorrect.\n");
        break;
    case GL_INVALID_OPERATION:
        printf("WARNING: An error (GL_INVALID_OPERATION) has been recorded.  Results may be incorrect.\n");
        break;
    case GL_STACK_OVERFLOW:
        printf("WARNING: An error (GL_STACK_OVERFLOW) has been recorded.  Results may be incorrect.\n");
        break;
    case GL_STACK_UNDERFLOW:
        printf("WARNING: An error (GL_STACK_UNDERFLOW) has been recorded.  Results may be incorrect.\n");
        break;
    case GL_OUT_OF_MEMORY:
        printf("WARNING: An error (GL_OUT_OF_MEMORY) has been recorded.  Results may be incorrect.\n");
        break;
#ifdef GL_EXT_histogram
    case GL_TABLE_TOO_LARGE_EXT:
        printf("WARNING: An error (GL_TABLE_TOO_LARGE_EXT) has been recorded.  Results may be incorrect.\n");
        break;
#endif
#ifdef GL_EXT_texture
    case GL_TEXTURE_TOO_LARGE_EXT:
        printf("WARNING: An error (GL_TEXTURE_TOO_LARGE_EXT) has been recorded.  Results may be incorrect.\n");
        break;
#endif
    default:
        printf("WARNING: An error has been recorded.  Results may be incorrect.\n");
        break;
    }
}

int Test__SetupRunPrint(TestPtr this, TestPtr prevTest, int printMode)
{
    int i;
    GLint drawBuffer;

    if (this->SetState(this) == -1) return 0;
    glGetIntegerv(GL_DRAW_BUFFER, &drawBuffer);
    this->Initialize(this);
    this->SetExecuteFunc(this);
    Test__Calibrate(this);
    for (i=0; i<this->reps; i++) {
	glGetError();
	/* Run test, print results */
	PrintResults(this, prevTest, Test__TimedRun(this), printMode);
	prevTest = this;
	printf("\n");
	CheckForError();
	/* If drawing only to back buffer, show contents after test */
	if (drawBuffer == GL_BACK || 
            drawBuffer == GL_BACK_LEFT ||
            drawBuffer == GL_BACK_RIGHT)
	    auxSwapBuffers();
    }
    this->Cleanup(this);
    return 1;
}

/* This is for setting unsupported configs in the Execute routines */
void Noop(TestPtr thisTest)
{
}
