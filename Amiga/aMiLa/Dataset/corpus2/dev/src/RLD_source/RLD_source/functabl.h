/*
  $Id: functabl.h,v 1.2 1997/10/21 22:35:08 wegge Stab wegge $

  $Log: functabl.h,v $
  Revision 1.2  1997/10/21 22:35:08  wegge
  Snapshot inden upload af 2.13 i source og binær form

  Revision 1.1  1997/10/21 03:49:58  wegge
  Initial revision

 */

/* Jumptable for the ARexx support functions. */

#if !defined(FUNCTABL_H)
#define FUNCTABL_H

#include "localerexx_protos.h"

struct JumpTable
  {
    UBYTE *FuncName;
    ULONG MinArg;
    ULONG MaxArg;
    VOID(*Func) (struct RexxMatch_ret *, struct RexxMsg *);
    ULONG StrLen;
  };

const struct JumpTable jt[] =
{

  {"CloseLocale",     1, 1, &SupCloseLocale,  11},
  {"FormatDate",      1, 3, &SupFormatDate,   10},
  {"GetLocaleString", 2, 2, &GetLocaleString, 15},
  {"GetLocaleVars",   2, 2, &GetLocaleVars,   13},
  {"GetSysTime",      0, 0, &rld_GetSysTime,  10},  
  {"OpenLocale",      0, 1, &SupOpenLocale,   10},
  {"ParseDate",       4, 4, &SupParseDate,     9}
};

#define JTABL_ENTRIES 7

#endif /* FUNCTABL_H */
