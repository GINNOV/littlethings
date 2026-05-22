#ifndef _PATMATCH_H
#define _PATMATCH_H

#include <crbinc/inc.h>

extern bool IsWild(char *Str);
extern bool MatchPattern(char *VsStr,char *PatStr);
extern bool MatchPatternNoCase(char *VsStr,char *PatStr);

extern bool RenameByPat(char *FmPat,char *FmStr,char *ToPat,char *ToStr);
  /** given the first three, fill in the last **/

#endif
