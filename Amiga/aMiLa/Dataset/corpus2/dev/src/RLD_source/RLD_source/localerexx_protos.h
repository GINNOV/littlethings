/*
  $Id: localerexx_protos.h,v 1.2 1997/10/21 22:35:08 wegge Stab wegge $

  $Log: localerexx_protos.h,v $
  Revision 1.2  1997/10/21 22:35:08  wegge
  Snapshot inden upload af 2.13 i source og binær form

  Revision 1.1  1997/10/21 03:49:58  wegge
  Initial revision

 */

#if !defined(LOCALEREXX_PROTOS_H)
#define LOCALEREXX_PROTOS_H

VOID GetLocaleString(struct RexxMatch_ret *RMR, struct RexxMsg *RxMsg);
VOID SupCloseLocale(struct RexxMatch_ret *RMR, struct RexxMsg *RxMsg);
VOID SupOpenLocale(struct RexxMatch_ret *RMR, struct RexxMsg *RxMsg);
VOID GetLocaleVars(struct RexxMatch_ret *RMR, struct RexxMsg *RxMsg);
VOID SupFormatDate(struct RexxMatch_ret *RMR, struct RexxMsg *RxMsg);
VOID SupParseDate(struct RexxMatch_ret *RMR, struct RexxMsg *RxMsg);
VOID rld_GetSysTime(struct RexxMatch_ret *RMR, struct RexxMsg *RxMsg);
VOID I2X(ULONG Val, UBYTE *Buf);
VOID Release_Locale(struct RexxRsrc *Node __asm("a0"), 
		    ULONG Base __asm("a6"));

struct Locale *FindCookie(struct RexxTask *TaskID, UBYTE *Cookie);
UBYTE *AddCookie(struct RexxTask *TaskID, struct Locale *AddLocale);
VOID DelCookie(struct RexxTask *TaskID, UBYTE *Cookie);

ULONG StringWriteHook(struct Hook *ThisHook __asm("a0"),
		      ULONG AddChr __asm("a1"), struct Locale
		      *ThisLocale __asm("a2"));
ULONG StringReadHook(struct Hook *ThisHook __asm("a0"),
		      ULONG AddChr __asm("a1"), struct Locale
		      *ThisLocale __asm("a2"));



#endif /* LOCALEREXX_PROTOS_H */
