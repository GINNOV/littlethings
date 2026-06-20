#ifndef _ORDER0_H
#define _ORDER0_H

/*

warning: calls CleanUp(char *ExitMess);

*/

struct Order0Info { long Private; };

/*
 * new version
 *
 * codes with order(-1) on escape from order0
 *
 */

extern struct Order0Info * Order0_Init(struct FAI * FAI,long NumSymbols);

extern void Order0_EncodeC(struct Order0Info * O0I,long Symbol,ubyte * ExcludeMask);
extern void Order0_DecodeC(struct Order0Info * O0I,long * SymbolPtr,ubyte * ExcludeMask);

extern void Order0_CleanUp(struct Order0Info * O0I);

#endif
