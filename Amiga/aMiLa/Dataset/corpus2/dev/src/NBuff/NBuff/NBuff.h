//===========================================================================
// NBUFF.H
// Include file necessary for working with NBuff.c
//===========================================================================

// remove the #ifdef surrounding the #includes below if you want to #include
// these files.  They will be #included automatically when you compile Nbuff.c

#ifdef NBUFF_C
#include <intuition/intuition.h>
#include <exec/memory.h>
#include <graphics/gfxbase.h>

#include <proto/exec.h>
#include <proto/graphics.h>
#include <proto/intuition.h>

#ifndef NOLAYERS
#include <graphics/layers.h>
#include <proto/layers.h>
#endif
#endif


#define NBUFS 5   // MAXIMUM number of buffers to be used.  This many buffers
                  // will not be allocated unless you allocate them with
                  // InitNBuff().

// function prototypes

struct RastPort *InitNBuff(struct Screen *, short, struct Window *, short);
struct BitMap *getBitMap(int, int, int, short);
void freeBitMap(struct BitMap *);
void ShowView(register short);
void FreeNBuff(struct Screen *, short, struct RastPort *, short);
