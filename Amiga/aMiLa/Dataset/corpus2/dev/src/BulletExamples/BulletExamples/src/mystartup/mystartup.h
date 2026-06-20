#ifndef MYSTARTUP_H
#define MYSTARTUP_H

#include <workbench/startup.h>
#include <dos/dosextens.h>

extern struct WBStartup *WBStartup;

extern struct DosLibrary *DOSBase;

extern long __min_oslibver;

int main(void);

#endif
