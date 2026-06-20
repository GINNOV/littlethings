/*
 *   (C) COPYRIGHT International Business Machines Corp. 1993
 *   All Rights Reserved
 *   Licensed Materials - Property of IBM
 *   US Government Users Restricted Rights - Use, duplication or
 *   disclosure restricted by GSA ADP Schedule Contract with IBM Corp.

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

#if (defined(INC_REASON)) && (INC_REASON == INFO_ITEM_STRUCT)
    InfoItemPtr infoItems;
    int testType;
    char *fileName;
    int executeMode;
    int iterations;
    int numObjects;
    int reps;
    int time;
    int loopFuncPtrs;   /* On or Off */
    int loopUnroll;     /* [1,8]     */
    int memAlignment;   /* Modulo 4096 value of the data alignment                        */
#ifdef environ
#undef environ
#endif
    EnvironmentInfo environ;
    char* glperfVersion;
    PrintfStringPtr userString;
    int printModeDelta;
    int printModeStateDelta;
    int printModeMicrosec;
    int printModePixels;
    /* Members below this line aren't user settable */
    char *usecPrint;
    char *ratePrint;
    char *usecPixelPrint;
    char *ratePixelPrint;
    Visual_ID previousVisual;
    GLenum windType;
    GLenum previousWindType;
    int previousWinW;
    int previousWinH;
    int clearBefore;
    /* Member functions */
    struct _Test * (*Copy)(struct _Test *); /* pure virtual function */
    void (*Execute)(struct _Test *);        /* pure virtual function */
    void (*Initialize)(struct _Test *);     /* pure virtual function */
    void (*Cleanup)(struct _Test *);        /* pure virtual function */
    void (*SetExecuteFunc)(struct _Test *); /* pure virtual function */
    int  (*SetState)(struct _Test *);       /* virtual function      */
    void (*delete)(struct _Test *);         /* virtual function      */
    float (*PixelSize)(struct _Test *);     /* virtual function      */
    int (*TimesRun)(struct _Test *);      /* virtual function      */
#elif (defined(INC_REASON)) && (INC_REASON == INFO_ITEM_ARRAY)
    {
        TestType,
        "Test Type",
        offset(testType),
        Enumerated | NotSettable,
        {
            { ClearTest, "ClearTest" },
            { TransformTest, "TransformTest" },
            { PointsTest, "PointsTest" },
            { LinesTest, "LinesTest" },
            { LineLoopTest, "LineLoopTest" },
            { LineStripTest, "LineStripTest" },
            { TrianglesTest, "TrianglesTest" },
            { TriangleStripTest, "TriangleStripTest" },
            { TriangleFanTest, "TriangleFanTest" },
            { QuadsTest, "QuadsTest" },
            { QuadStripTest, "QuadStripTest" },
            { PolygonTest, "PolygonTest" },
            { DrawPixelsTest, "DrawPixelsTest" },
            { CopyPixelsTest, "CopyPixelsTest" },
            { BitmapTest, "BitmapTest" },
            { TextTest, "TextTest" },
            { ReadPixelsTest, "ReadPixelsTest" },
            { TexImageTest, "TexImageTest" },
            { End }
        },
        { ClearTest }
    },
    {
        FileName,
        "GLperf Script File Name",
        offset(fileName),
        StringType,
        {
            { NotUsed }
        },
        { NotUsed, (GLfloat)NotUsed, (char*)"None" }
    },
    {
        UserString,
        "User Defined String",
        offset(userString),
        PrintfStringType | NoPrint,
        {
            { NotUsed }
        },
        { NotUsed, (GLfloat)NotUsed, (char*)"None" }
    },
    {
        PrintModeDelta,
        "Print Mode Delta",
        offset(printModeDelta),
        Enumerated,
        {
            { False,                    "False" },
            { True,                     "True" },
            { End }
        },
        { False }
    },
    {
        PrintModeStateDelta,
        "Print Mode Delta from Default State",
        offset(printModeStateDelta),
        Enumerated,
        {
            { False,                    "False" },
            { True,                     "True" },
            { End }
        },
        { False }
    },
    {
        PrintModeMicrosec,
        "Print Mode Microseconds",
        offset(printModeMicrosec),
        Enumerated,
        {
            { False,                    "False" },
            { True,                     "True" },
            { End }
        },
        { False }
    },
    {
        PrintModePixels,
        "Print Mode Pixels Per Second",
        offset(printModePixels),
        Enumerated,
        {
            { False,                    "False" },
            { True,                     "True" },
            { End }
        },
        { False }
    },
    {
        GLperfVersion,
        "GLperf Version",
        offset(glperfVersion),
        StringType | NotSettable,
        {
            { NotUsed }
        },
        { NotUsed, (GLfloat)NotUsed, (char*)"3.1.2" }
    },
    {
        ExecuteMode,
        "Execute Mode",
        offset(executeMode),
        Enumerated,
        {
            { Immediate,            "Immediate" },
            { Compile,              "Compile" },
            { CallList,             "CallList" },
            { CompileExecute,       "CompileExecute" },
            { DestroyList,          "DestroyList" },
            { End }
        },
        { Immediate }
    },
    {
        Objs,
        "Number of Objects",
        offset(numObjects),
        RangedInteger,
        {
            { 1 }, /* minimum value */
            { 1000000 }  /* maximum value */
        },
        { 1 }
    },
    {
        Iterations,
        "Iterations",
        offset(iterations),
        RangedInteger | NoPrint,
        {
            { 1 }, /* minimum value */
            { 100000 }, /* maximum value */
        },
        { -1 }
    },
    {
        Reps,
        "Repetitions",
        offset(reps),
        RangedInteger | NoPrint,
        {
            { 1 }, /* minimum value */
            { 100000 }, /* maximum value */
        },
        { 1 }
    },
    {
        MinimumTime,
        "Test Time",
        offset(time),
        RangedInteger | NoPrint,
        {
            { 1 }, /* minimum value */
            { 100000 }, /* maximum value */
        },
        { 5 }
    },
    {
        LoopUnroll,
        "Vertices Unrolled in Inner Loop",
        offset(loopUnroll),
        RangedInteger,
        {
            { 1 },
#ifdef FULL_UNROLL_PATHS
            { 8 }
#else
	    { 1 }
#endif
        },
        { 1 }
    },
    {
        LoopFuncPtrs,
        "Function Pointers Used in Inner Loop",
        offset(loopFuncPtrs),
        Enumerated,
        {
            { Off,                      "Off" },
#ifdef FULL_FUNCPTR_PATHS
            { On,                       "On" },
#endif
            { End }
        },
        { Off }
    },
    {
        DataAlignment,
        "Modulo 4096 of Data Alignment",
        offset(memAlignment),
        RangedInteger,
        {
	    { 0 },
	    { 4095 }
        },
        { 0 }
    },
    {
        Month,
        "Month",
        offset(environ.month),
        RangedInteger | NotSettable,
        {
          { 1 },
          { 12 }
        },
        { -1 }
    },
    {
        Day,
        "Day",
        offset(environ.day),
        RangedInteger | NotSettable,
        {
          { 1 },
          { 31 }
        },
        { -1 }
    },
    {
        Year,
        "Year",
        offset(environ.year),
        RangedInteger | NotSettable,
        {
          { 1994 },
          { 2010 }
        },
        { -1 }
    },
    {
        Host,
        "Host",
        offset(environ.host),
        StringType | NotSettable,
        {
            { NotUsed }
        },
        { NotUsed, (GLfloat)NotUsed, (char*)"unknown" }
    },
    {
        HostOperatingSystem,
        "Operating System",
        offset(environ.hostOperatingSystem),
        StringType | NotSettable,
        {
            { NotUsed }
        },
        { NotUsed, (GLfloat)NotUsed, (char*)"unknown" }
    },
    {
        HostOperatingSystemVersion,
        "Operating System Version",
        offset(environ.hostOperatingSystemVersion),
        StringType | NotSettable,
        {
            { NotUsed }
        },
        { NotUsed, (GLfloat)NotUsed, (char*)"unknown" }
    },
    {
        HostVendor,
        "Host Vendor",
        offset(environ.hostVendor),
        StringType | NotSettable,
        {
            { NotUsed }
        },
        { NotUsed, (GLfloat)NotUsed, (char*)"unknown" }
    },
    {
        HostModel,
        "Host Model",
        offset(environ.hostModel),
        StringType | NotSettable,
        {
            { NotUsed }
        },
        { NotUsed, (GLfloat)NotUsed, (char*)"unknown" }
    },
    {
        HostCPU,
        "Host CPU",
        offset(environ.hostCPU),
        StringType | NotSettable,
        {
            { NotUsed }
        },
        { NotUsed, (GLfloat)NotUsed, (char*)"unknown" }
    },
    {
        HostCPUCount,
        "Host CPU Count",
        offset(environ.hostCPUCount),
        StringType | NotSettable,
        {
            { NotUsed }
        },
        { NotUsed, (GLfloat)NotUsed, (char*)"unknown" }
    },
    {
        HostMemorySize,
        "Host Memory Size",
        offset(environ.hostMemorySize),
        UnrangedInteger | NotSettable,
        {
            { NotUsed }
        },
        { -1 }
    },
    {
        HostPrimaryCacheSize,
        "Host Primary Cache Size",
        offset(environ.hostPrimaryCacheSize),
        StringType | NotSettable,
        {
            { NotUsed }
        },
        { NotUsed, (GLfloat)NotUsed, (char*)"unknown" }
    },
    {
        HostSecondaryCacheSize,
        "Host Secondary Cache Size",
        offset(environ.hostSecondaryCacheSize),
        StringType | NotSettable,
        {
            { NotUsed }
        },
        { NotUsed, (GLfloat)NotUsed, (char*)"unknown" }
    },
    {
        WindowSystem,
        "Window System",
        offset(environ.windowSystem),
        StringType | NotSettable,
        {
            { NotUsed }
        },
        { NotUsed, (GLfloat)NotUsed, (char*)"unknown" }
    },
    {
        DriverVersion,
        "Driver Version",
        offset(environ.driverVersion),
        StringType | NotSettable,
        {
            { NotUsed }
        },
        { NotUsed, (GLfloat)NotUsed, (char*)"unknown" }
    },
    {
        OpenGLVendor,
        "OpenGL Vendor",
        offset(environ.glVendor),
        StringType | NotSettable,
        {
            { NotUsed }
        },
        { NotUsed, (GLfloat)NotUsed, (char*)"unknown" }
    },
    {
        OpenGLVersion,
        "OpenGL Version",
        offset(environ.glVersion),
        StringType | NotSettable,
        {
            { NotUsed }
        },
        { NotUsed, (GLfloat)NotUsed, (char*)"unknown" }
    },
    {
        OpenGLExtensions,
        "OpenGL Extensions",
        offset(environ.glExtensions),
        StringType | NotSettable,
        {
            { NotUsed }
        },
        { NotUsed, (GLfloat)NotUsed, (char*)"unknown" }
    },
    {
        OpenGLRenderer,
        "OpenGL Renderer",
        offset(environ.glRenderer),
        StringType | NotSettable,
        {
            { NotUsed }
        },
        { NotUsed, (GLfloat)NotUsed, (char*)"unknown" }
    },
    {
        OpenGLClientVendor,
        "OpenGL Client Vendor",
        offset(environ.glClientVendor),
        StringType | NotSettable,
        {
            { NotUsed }
        },
        { NotUsed, (GLfloat)NotUsed, (char*)"unknown" }
    },
    {
        OpenGLClientVersion,
        "OpenGL Client Version",
        offset(environ.glClientVersion),
        StringType | NotSettable,
        {
            { NotUsed }
        },
        { NotUsed, (GLfloat)NotUsed, (char*)"unknown" }
    },
    {
        OpenGLClientExtensions,
        "OpenGL Client Extensions",
        offset(environ.glClientExtensions),
        StringType | NotSettable,
        {
            { NotUsed }
        },
        { NotUsed, (GLfloat)NotUsed, (char*)"unknown" }
    },
    {
        GLUVersion,
        "GLU Version",
        offset(environ.gluVersion),
        StringType | NotSettable,
        {
            { NotUsed }
        },
        { NotUsed, (GLfloat)NotUsed, (char*)"unknown" }
    },
    {
        GLUExtensions,
        "GLU Extensions",
        offset(environ.gluExtensions),
        StringType | NotSettable,
        {
            { NotUsed }
        },
        { NotUsed, (GLfloat)NotUsed, (char*)"unknown" }
    },
    {
        DirectRender,
        "Direct Rendering",
        offset(environ.directRender),
        Enumerated,
        {
            { True,     "True" },
            { False,    "False" },
            { End }
        },
        { True }
    },
    {
        DoubleBuffer,
        "Double Buffer",
        offset(environ.bufConfig.doubleBuffer),
        Enumerated,
        {
            { True,     "True" },
            { False,    "False" },
            { End }
        },
        { True }
    },
    {
        Stereo,
        "Stereo",
        offset(environ.bufConfig.stereo),
        Enumerated,
        {
            { True,     "True" },
            { False,    "False" },
            { End }
        },
        { False }
    },
    {
        Rgba,
        "RGBA",
        offset(environ.bufConfig.rgba),
        Enumerated,
        {
            { True,     "True" },
            { False,    "False" },
            { End }
        },
        { True }
    },
    {
        IndexSize,
        "Color Index Size",
        offset(environ.bufConfig.indexSize),
        UnrangedInteger,
        {
            { NotUsed }
        },
        { 0 }
    },
    {
        RedSize,
        "Red Size",
        offset(environ.bufConfig.redSize),
        UnrangedInteger,
        {
            { NotUsed }
        },
        { 1 }
    },
    {
        GreenSize,
        "Green Size",
        offset(environ.bufConfig.greenSize),
        UnrangedInteger,
        {
            { NotUsed }
        },
        { 1 }
    },
    {
        BlueSize,
        "Blue Size",
        offset(environ.bufConfig.blueSize),
        UnrangedInteger,
        {
            { NotUsed }
        },
        { 1 }
    },
    {
        AlphaSize,
        "Alpha Size",
        offset(environ.bufConfig.alphaSize),
        UnrangedInteger,
        {
            { NotUsed }
        },
        { 0 }
    },
    {
        AccumRedSize,
        "Accum Red Size",
        offset(environ.bufConfig.accumRedSize),
        UnrangedInteger,
        {
            { NotUsed }
        },
        { 0 }
    },
    {
        AccumGreenSize,
        "Accum Green Size",
        offset(environ.bufConfig.accumGreenSize),
        UnrangedInteger,
        {
            { NotUsed }
        },
        { 0 }
    },
    {
        AccumBlueSize,
        "Accum Blue Size",
        offset(environ.bufConfig.accumBlueSize),
        UnrangedInteger,
        {
            { NotUsed }
        },
        { 0 }
    },
    {
        AccumAlphaSize,
        "Accum Alpha Size",
        offset(environ.bufConfig.accumAlphaSize),
        UnrangedInteger,
        {
            { NotUsed }
        },
        { 0 }
    },
    {
        DepthSize,
        "Depth Size",
        offset(environ.bufConfig.depthSize),
        UnrangedInteger,
        {
            { NotUsed }
        },
        { 1 }
    },
    {
        StencilSize,
        "Stencil Size",
        offset(environ.bufConfig.stencilSize),
        UnrangedInteger,
        {
            { NotUsed }
        },
        { 0 }
    },
    {
        AuxBuffers,
        "Auxiliary Buffer Count",
        offset(environ.bufConfig.auxBuffers),
        UnrangedInteger,
        {
            { NotUsed }
        },
        { 0 }
    },
#ifdef GL_SGIS_multisample
    {
        SampleBuffers,
        "Multisample Buffer Count",
        offset(environ.bufConfig.sampleBuffers),
        RangedInteger,
        {
            { 0 },
	    { 1 }
        },
        { 0 }
    },
    {
        SamplesPerPixel,
        "Multisamples Per Pixel",
        offset(environ.bufConfig.numSamples),
        RangedInteger,
        {
            { 0 },
	    { 16 }
        },
        { 0 }
    },
#endif
    {
        FrameBufferLevel,
        "Frame BufferLevel",
        offset(environ.bufConfig.level),
        UnrangedInteger,
        {
            { NotUsed }
        },
        { 0 }
    },
#if defined(XWINDOWS)
    {
        VisualId,
        "Visual ID",
        offset(environ.bufConfig.visualId),
        UnrangedHexInteger,
        {
            { NotUsed }
        },
        { NoVisual }
    },
    {
        VisualClass,
        "Visual Class",
        offset(environ.bufConfig.visualClass),
        Enumerated | NotSettable,
        {
            { StaticGray,       "StaticGray" },
            { GrayScale,        "GrayScale" },
            { StaticColor,      "StaticColor" },
            { PseudoColor,      "PseudoColor" },
            { TrueColor,        "TrueColor" },
            { DirectColor,      "DirectColor" },
            { End }
        },
        { -1 }
    },
#endif
    {
        WindowWidth,
        "Window Width",
        offset(environ.windowWidth),
        RangedInteger,
        {
            { 100 }, /* minimum value */
            { 2048 }, /* maximum value */
        },
        { 384 }
    },
    {
        WindowHeight,
        "Window Height",
        offset(environ.windowHeight),
        RangedInteger,
        {
            { 100 }, /* minimum value */
            { 2048 }, /* maximum value */
        },
        { 384 }
    },
    {
        ScreenWidth,
        "Screen Width",
        offset(environ.screenWidth),
        UnrangedInteger | NotSettable,
        {
            { NotUsed }
        },
        { -1 }
    },
    {
        ScreenHeight,
        "Screen Height",
        offset(environ.screenHeight),
        UnrangedInteger | NotSettable,
        {
            { NotUsed }
        },
        { -1 }
    },
#if defined(XWINDOWS)
    {
        DisplayName,
        "Display",
        offset(environ.display),
        StringType | NotSettable,
        {
            { NotUsed }
        },
        { NotUsed, (GLfloat)NotUsed, (char*)"unknown" }
    },
    {
        OpenGLServerVendor,
        "OpenGL Server Vendor",
        offset(environ.glServerVendor),
        StringType | NotSettable,
        {
            { NotUsed }
        },
        { NotUsed, (GLfloat)NotUsed, (char*)"unknown" }
    },
    {
        OpenGLServerVersion,
        "OpenGL Server Version",
        offset(environ.glServerVersion),
        StringType | NotSettable,
        {
            { NotUsed }
        },
        { NotUsed, (GLfloat)NotUsed, (char*)"unknown" }
    },
    {
        OpenGLServerExtensions,
        "OpenGL Server Extensions",
        offset(environ.glServerExtensions),
        StringType | NotSettable,
        {
            { NotUsed }
        },
        { NotUsed, (GLfloat)NotUsed, (char*)"unknown" }
    },
    {
        GLXVersion,
        "GLX Server Version",
        offset(environ.glxVersion),
        StringType | NotSettable,
        {
            { NotUsed }
        },
        { NotUsed, (GLfloat)NotUsed, (char*)"unknown" }
    },
    {
        GLXExtensions,
        "GLX Server Extensions",
        offset(environ.glxExtensions),
        StringType | NotSettable,
        {
            { NotUsed }
        },
        { NotUsed, (GLfloat)NotUsed, (char*)"unknown" }
    },
    {
        ScreenNumber,
        "Screen Number",
        offset(environ.screenNumber),
        UnrangedInteger | NotSettable,
        {
            { NotUsed }
        },
        { -1 }
    },
    {
        SharedMemConnection,
        "Shared Memory Connection",
        offset(environ.sharedMemConnection),
        Enumerated | NotSettable,
        {
            { True,     "True" },
            { False,    "False" },
            { End }
        },
        { False }
    },
#endif
#else  /* INC_REASON not defined, treat as plain include */
#ifndef _Test_h
#define _Test_h

#include "InfoItem.h"
#ifdef WIN32
#include <windows.h>
#include <gl\glaux.h>
#elif __amigaos__
#include <gl/glaux.h>
#else
#include "aux.h"
#endif
#include "Env.h"
#include "Printf.h"

typedef struct _Test {
#define INC_REASON INFO_ITEM_STRUCT
#include "Test.h"
#undef INC_REASON
} Test, *TestPtr;

#include "General.h"
#include "Print.h"
#include "TestName.h"
#include "PropName.h"
#include "Global.h"
#include "AttrName.h"
#ifdef WIN32
#include <windows.h>
#endif
#include <GL/gl.h>
#include <GL/glu.h>
#include "Random.h"
#include "Timer.h"

/* These were non-virtual member functions */
void new_Test(TestPtr this);
void delete_Test(TestPtr this);
int Test__SetState(TestPtr this);
int Test__TimesRun(TestPtr this);
void Test__Calibrate(TestPtr);
float Test__TimedRun(TestPtr);
int Test__SetupRunPrint(TestPtr, TestPtr, int);
#endif /* file not already included */
#endif /* INC_REASON not defined */
