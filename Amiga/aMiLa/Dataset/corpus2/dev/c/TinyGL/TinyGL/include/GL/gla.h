#ifndef _gla_H
#define _gla_H

#include <proto/intuition.h>
#include <proto/graphics.h>
#include <clib/intuition_protos.h>
#include <cybergraphx/cybergraphics.h>
#include <proto/cybergraphics.h>

#include <GL/gl.h>

#ifdef __cplusplus
extern "C" {
#endif

typedef void* GLAContext;
typedef struct Window* GLADrawable;

GLAContext glACreateContext(void);
void glADestroyContext(GLAContext ctx);
void glASwapBuffers(GLADrawable drawable);
int glAMakeCurrent(GLADrawable drawable, GLAContext ctx1);

#ifdef __cplusplus
}
#endif

#endif
