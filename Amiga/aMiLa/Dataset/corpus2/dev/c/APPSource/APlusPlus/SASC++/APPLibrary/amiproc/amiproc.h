#ifndef D_DATASEG_H
#define D_DATASEG_H

#ifdef __cplusplus
extern "C" {
#endif

#include <dos.h>

// The following functions provide a convenient way to spawn
// a new subprocess with full autoinitialization, access to
// all the normal library functions, etc.

struct AmiProcMsg *AmiProc_Start(int (*FuncPtr)(void *), void *UserData);
int AmiProc_Wait(struct AmiProcMsg *);

#ifdef __cplusplus
}
#endif

#endif
