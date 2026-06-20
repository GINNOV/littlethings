#ifndef _O0CODER_H
#define _O0CODER_H

/*

warning: calls CleanUp(char *ExitMess);

*/

struct O0coderInfo {  long Private; };

/*
 * new version
 *
 * codes with order(-1) on escape from order0
 *
 */

extern struct O0coderInfo * O0coder_Init(struct FAI * FAI,long NumChars);

extern void O0coder_AddC(struct O0coderInfo * O0I,long Char);
extern void O0coder_EncodeC(struct O0coderInfo * O0I,long Char);
extern long O0coder_DecodeC(struct O0coderInfo * O0I);

extern void O0coder_CleanUp(struct O0coderInfo * O0I);

#endif
